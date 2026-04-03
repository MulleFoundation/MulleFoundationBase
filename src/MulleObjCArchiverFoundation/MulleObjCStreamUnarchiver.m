#import "MulleObjCStreamUnarchiver.h"
#import "MulleObjCArchiver-Private.h"
#include "mulle-buffer-archiver.h"
#import "import-private.h"


@interface MulleObjCUnarchiver (StreamPrivate)

- (BOOL) _nextBlobTable;
- (BOOL) _nextClassTable;
- (BOOL) _nextSelectorTable;
- (BOOL) _nextObjectTable;
- (void) _initObjects;
- (id) _nextObject;
- (void *) _decodeValueOfObjCType:(char *) type at:(void *) p;

@end


@interface MulleObjCStreamUnarchiver (Private)

- (instancetype) _initSharedState;

@end


@implementation MulleObjCStreamUnarchiver

- (instancetype) initWithStreamData:(NSData *) data
{
   struct mulle_allocator   *allocator;

   [super init];  // NSCoder init, skip MulleObjCUnarchiver's initForReadingWithData:

   allocator  = MulleObjCInstanceGetAllocator( self);
   _objects   = MulleObjCMapTableCreateWithAllocator( NSIntegerMapKeyCallBacks,
                                                NSNonRetainedObjectMapValueCallBacks,
                                                16,
                                                allocator);
   _offsets   = MulleObjCMapTableCreateWithAllocator( NSIntegerMapKeyCallBacks,
                                                mulle_container_valuecallback_intptr,
                                                16,
                                                allocator);
   _classes   = MulleObjCMapTableCreateWithAllocator( NSIntegerMapKeyCallBacks,
                                                NSNonRetainedObjectMapValueCallBacks,
                                                16,
                                                allocator);
   _selectors = MulleObjCMapTableCreateWithAllocator( NSIntegerMapKeyCallBacks,
                                                NSIntegerMapValueCallBacks,
                                                16,
                                                allocator);
   _blobs     = MulleObjCMapTableCreateWithAllocator( NSIntegerMapKeyCallBacks,
                                                NSOwnedPointerMapValueCallBacks,
                                                16,
                                                allocator);
   _classNameSubstitutions = MulleObjCMapTableCreateWithAllocator(
                                                mulle_container_keycallback_copied_cstring,
                                                mulle_container_valuecallback_copied_cstring,
                                                16,
                                                allocator);
   _objectSubstitutions    = MulleObjCMapTableCreateWithAllocator(
                                                NSObjectMapKeyCallBacks,
                                                NSObjectMapValueCallBacks,
                                                16,
                                                allocator);

   _streamData = [data retain];
   _streamPos  = 0;

   // read and verify stream header
   {
      char        header[ 16];
      NSInteger   version;
      const char  *bytes = [data bytes];
      NSUInteger  len    = [data length];

      if( len < 16)
      {
         [self release];
         return( nil);
      }
      memcpy( header, bytes, 16);
      if( memcmp( header, "mulle-obj-stream", 16))
      {
         [self release];
         return( nil);
      }
      _streamPos = 16;

      // read version varint from stream
      mulle_buffer_init_inflexible_with_static_bytes( &_buffer,
                                                      (void *)(bytes + _streamPos),
                                                      len - _streamPos);
      version = mulle_buffer_next_integer( &_buffer);
      _streamPos += mulle_buffer_get_length( &_buffer);
      (void) version;
      mulle_buffer_done( &_buffer);
   }

   return( self);
}


- (void) dealloc
{
   [_streamData release];
   [super dealloc];
}


//
// Read one chunk from the stream: delta tables + **dta** + object data
// Returns the root object of this chunk, or nil if no more data / error.
//
- (id) decodeNextObject
{
   const char               *bytes;
   NSUInteger               totalLen;
   size_t                   remaining;
   char                     marker[ 8];
   NSUInteger               blobBase;
   NSUInteger               classBase;
   NSUInteger               selBase;
   NSUInteger               i, n;
   struct mulle_allocator   *allocator;

   bytes    = [_streamData bytes];
   totalLen = [_streamData length];

   if( _streamPos >= totalLen)
      return( nil);

   allocator = MulleObjCInstanceGetAllocator( self);
   _inited   = NO;

   for(;;)
   {
      remaining = totalLen - _streamPos;
      if( remaining < 8)
         return( nil);

      memcpy( marker, bytes + _streamPos, 8);

      // release record
      if( ! memcmp( marker, "**rel**", 8))
      {
         _streamPos += 8;
         mulle_buffer_init_inflexible_with_static_bytes( &_buffer,
                                                         (void *)(bytes + _streamPos),
                                                         totalLen - _streamPos);
         n = (NSUInteger) mulle_buffer_next_integer( &_buffer);
         for( i = 0; i < n; i++)
         {
            NSUInteger   handle;
            id           obj;

            handle = (NSUInteger) mulle_buffer_next_integer( &_buffer);
            obj    = NSMapGet( _objects, (void *) handle);
            if( obj)
            {
               [obj release];
               NSMapRemove( _objects, (void *) handle);
            }
            NSMapRemove( _offsets, (void *) handle);
         }
         _streamPos += mulle_buffer_get_length( &_buffer);
         mulle_buffer_done( &_buffer);
         continue;
      }

      // blob delta
      if( ! memcmp( marker, "**blb**", 8))
      {
         blobBase    = _nextBlobHandle;
         _streamPos += 8;
         mulle_buffer_init_inflexible_with_static_bytes( &_buffer,
                                                         (void *)(bytes + _streamPos),
                                                         totalLen - _streamPos);
         n = (NSUInteger) mulle_buffer_next_integer( &_buffer);
         for( i = 0; i < n; i++)
         {
            size_t         len;
            struct blob    *blob;
            void           *blobBytes;

            len       = mulle_buffer_next_integer( &_buffer);
            blobBytes = mulle_buffer_reference_bytes( &_buffer, len);
            if( ! blobBytes && len)
               return( nil);

            blob           = mulle_allocator_malloc( allocator, sizeof( struct blob));
            blob->_storage = blobBytes;
            blob->_length  = len;
            NSMapInsert( _blobs, (void *)(blobBase + i + 1), blob);
         }
         _nextBlobHandle = blobBase + n;
         _streamPos += mulle_buffer_get_length( &_buffer);
         mulle_buffer_done( &_buffer);
         continue;
      }

      // class delta
      if( ! memcmp( marker, "**cls**", 8))
      {
         classBase   = _nextClsHandle;
         _streamPos += 8;
         mulle_buffer_init_inflexible_with_static_bytes( &_buffer,
                                                         (void *)(bytes + _streamPos),
                                                         totalLen - _streamPos);
         n = (NSUInteger) mulle_buffer_next_integer( &_buffer);
         for( i = 0; i < n; i++)
         {
            NSInteger               version;
            NSUInteger              name_index;
            struct blob             *blob;
            char                    *name;
            char                    *substitution;
            Class                   cls;
            mulle_objc_uniqueid_t   clshash;

            version    = (NSInteger) mulle_buffer_next_integer( &_buffer);
            (void) mulle_buffer_next_integer( &_buffer); // ivarhash
            name_index = (NSUInteger) mulle_buffer_next_integer( &_buffer);

            blob = NSMapGet( _blobs, (void *) name_index);
            if( ! blob)
               return( nil);

            name         = blob->_storage;
            substitution = NSMapGet( _classNameSubstitutions, name);
            if( substitution)
               name = substitution;

            clshash = mulle_objc_uniqueid_from_string( name);
            cls     = _mulle_objc_universe_lookup_infraclass(
                           MulleObjCObjectGetUniverse( self), clshash);
            if( ! cls)
               return( nil);
            if( [cls version] < version)
               return( nil);

            NSMapInsert( _classes, (void *)(classBase + i + 1), cls);
         }
         _nextClsHandle = classBase + n;
         _streamPos += mulle_buffer_get_length( &_buffer);
         mulle_buffer_done( &_buffer);
         continue;
      }

      // selector delta
      if( ! memcmp( marker, "**sel**", 8))
      {
         selBase     = _nextSelHandle;
         _streamPos += 8;
         mulle_buffer_init_inflexible_with_static_bytes( &_buffer,
                                                         (void *)(bytes + _streamPos),
                                                         totalLen - _streamPos);
         n = (NSUInteger) mulle_buffer_next_integer( &_buffer);
         for( i = 0; i < n; i++)
         {
            NSUInteger              sel_index;
            struct blob             *blob;
            mulle_objc_methodid_t   sel;

            sel_index = (NSUInteger) mulle_buffer_next_integer( &_buffer);
            blob      = NSMapGet( _blobs, (void *) sel_index);
            if( ! blob)
               return( nil);

            sel = mulle_objc_uniqueid_from_string( blob->_storage);
            NSMapInsert( _selectors, (void *)(selBase + i + 1), (void *)(uintptr_t) sel);
         }
         _nextSelHandle = selBase + n;
         _streamPos += mulle_buffer_get_length( &_buffer);
         mulle_buffer_done( &_buffer);
         continue;
      }

      // object table delta
      if( ! memcmp( marker, "**obj**", 8))
      {
         _streamPos += 8;
         mulle_buffer_init_inflexible_with_static_bytes( &_buffer,
                                                         (void *)(bytes + _streamPos),
                                                         totalLen - _streamPos);
         _newObjBase  = _nextObjHandle;
         n            = (NSUInteger) mulle_buffer_next_integer( &_buffer);
         _newObjCount = n;
         for( i = 0; i < n; i++)
         {
            NSUInteger   cls_index;
            size_t       offset;
            Class        cls;
            id           obj;

            cls_index = (NSUInteger) mulle_buffer_next_integer( &_buffer);
            offset    = (size_t) mulle_buffer_next_integer( &_buffer);

            cls = NSMapGet( _classes, (void *) cls_index);
            if( ! cls)
               return( nil);

            obj = [cls alloc];
            NSMapInsert( _objects, (void *)(_newObjBase + i + 1), obj);
            NSMapInsert( _offsets, (void *)(_newObjBase + i + 1), (void *) offset);
         }
         _nextObjHandle = _newObjBase + n;
         _streamPos += mulle_buffer_get_length( &_buffer);
         mulle_buffer_done( &_buffer);
         continue;
      }

      // data section
      if( ! memcmp( marker, "**dta**", 8))
      {
         id       result;
         size_t   dataLen;

         _streamPos += 8;

         // read data length
         mulle_buffer_init_inflexible_with_static_bytes( &_buffer,
                                                         (void *)(bytes + _streamPos),
                                                         totalLen - _streamPos);
         dataLen = (size_t) mulle_buffer_next_integer( &_buffer);
         _streamPos += mulle_buffer_get_length( &_buffer);
         mulle_buffer_done( &_buffer);

         // point buffer at data section
         mulle_buffer_init_inflexible_with_static_bytes( &_buffer,
                                                         (void *)(bytes + _streamPos),
                                                         dataLen);

         _inited = YES;
         [self _initNewObjects];

         result = [self _nextObject];

         mulle_buffer_done( &_buffer);
         _streamPos += dataLen;

         return( [[result retain] autorelease]);
      }

      // unknown marker
      return( nil);
   }
}


- (void) _initNewObjects
{
   NSUInteger   i;
   NSUInteger   handle;
   id           obj;
   id           inited;
   size_t       offset;
   size_t       memo;

   memo = mulle_buffer_get_seek( &_buffer);

   for( i = 0; i < _newObjCount; i++)
   {
      handle = _newObjBase + i + 1;
      obj    = NSMapGet( _objects, (void *) handle);
      offset = (size_t) NSMapGet( _offsets, (void *) handle);

      if( ! obj || (! offset && i > 0))
         continue;

      if( mulle_buffer_set_seek( &_buffer, offset, MULLE_BUFFER_SEEK_SET))
         [NSException raise:NSInconsistentArchiveException
                     format:@"archive damaged"];

      inited = [obj initWithCoder:self];
      if( ! inited)
         [NSException raise:NSInconsistentArchiveException
                     format:@"initWithCoder: returned nil"];

      if( inited != obj)
      {
         NSMapRemove( _objects, (void *) handle);
         NSMapInsert( _objects, (void *) handle, inited);
      }
   }

   // second pass for decodeWithCoder: (class clusters)
   for( i = 0; i < _newObjCount; i++)
   {
      handle = _newObjBase + i + 1;
      obj    = NSMapGet( _objects, (void *) handle);

      if( ! obj)
         continue;
      if( ! [obj respondsToSelector:@selector( decodeWithCoder:)])
         continue;

      offset = (size_t) NSMapGet( _offsets, (void *) handle);
      if( mulle_buffer_set_seek( &_buffer, offset, MULLE_BUFFER_SEEK_SET))
         [NSException raise:NSInconsistentArchiveException
                     format:@"archive damaged"];

      [obj decodeWithCoder:self];
   }

   mulle_buffer_set_seek( &_buffer, memo, MULLE_BUFFER_SEEK_SET);
}


- (void) decodeValueOfObjCType:(char *) type
                            at:(void *) p
{
   [self _decodeValueOfObjCType:type
                             at:p];
}


- (void *) decodeBytesWithReturnedLength:(NSUInteger *) len_p
{
   return( [self _decodeBytesWithReturnedLength:len_p]);
}

@end
