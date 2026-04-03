#import "MulleObjCStreamArchiver.h"
#import "MulleObjCArchiver-Private.h"
#include "mulle-buffer-archiver.h"
#import "import-private.h"


@interface MulleObjCArchiver (StreamPrivate)

- (void) _appendUTF8String:(char *) s;
- (void) _appendClass:(Class) cls;
- (void) _appendObject:(id) obj;
- (void) _appendBytes:(void *) bytes length:(size_t) len;
- (void *) _encodeValueOfObjCType:(char *) type at:(void *) p;

@end


@implementation MulleObjCStreamArchiver

- (instancetype) init
{
   self = [super init];
   if( self)
   {
      _output = [[NSMutableData alloc] init];
      // write stream header once
      mulle_buffer_add_bytes( &_buffer, "mulle-obj-stream", 16);
      mulle_buffer_add_integer( &_buffer, [self systemVersion]);
      [self _flushBufferToOutput];
   }
   return( self);
}


- (void) dealloc
{
   [_output release];
   [super dealloc];
}


- (void) _flushBufferToOutput
{
   size_t   len;
   void     *bytes;

   len = mulle_buffer_get_length( &_buffer);
   if( ! len)
      return;

   bytes = mulle_buffer_get_bytes( &_buffer);
   [_output appendBytes:bytes
                 length:len];
   mulle_buffer_reset( &_buffer);
}


- (void) _snapshotMemo
{
   _memo.n_objects     = (unsigned int) mulle_pointerarray_get_count( &_objects.array);
   _memo.n_classes     = (unsigned int) mulle_pointerarray_get_count( &_classes.array);
   _memo.n_selectors   = (unsigned int) mulle_pointerarray_get_count( &_selectors.array);
   _memo.n_blobs       = (unsigned int) mulle_pointerarray_get_count( &_blobs.array);
   _memo.buffer_offset = mulle_buffer_get_seek( &_buffer);
}


//
// Roll back all four handle tables to the state captured in _memo.
// Entries added since the snapshot are removed from both the map (for lookup)
// and the array (for ordered iteration). The buffer is also rewound.
// After this, the archiver state is as if the last encodeRootObject:/beginFrame
// never happened — the consumer will never see those handles.
//
- (void) _rollbackToMemo
{
   unsigned int   i, n;
   void           *p;

   // rollback objects
   n = (unsigned int) mulle_pointerarray_get_count( &_objects.array);
   for( i = _memo.n_objects; i < n; i++)
   {
      p = (void *) _mulle_pointerarray_get( &_objects.array, i);
      mulle_map_remove( &_objects.map, p);
   }
   _objects.array._curr = _objects.array._storage + _memo.n_objects;

   // rollback classes
   n = (unsigned int) mulle_pointerarray_get_count( &_classes.array);
   for( i = _memo.n_classes; i < n; i++)
   {
      p = (void *) _mulle_pointerarray_get( &_classes.array, i);
      mulle_map_remove( &_classes.map, p);
   }
   _classes.array._curr = _classes.array._storage + _memo.n_classes;

   // rollback selectors
   n = (unsigned int) mulle_pointerarray_get_count( &_selectors.array);
   for( i = _memo.n_selectors; i < n; i++)
   {
      p = (void *) _mulle_pointerarray_get( &_selectors.array, i);
      mulle_map_remove( &_selectors.map, p);
   }
   _selectors.array._curr = _selectors.array._storage + _memo.n_selectors;

   // rollback blobs
   n = (unsigned int) mulle_pointerarray_get_count( &_blobs.array);
   for( i = _memo.n_blobs; i < n; i++)
   {
      struct blob   *blob;
      blob = (struct blob *) _mulle_pointerarray_get( &_blobs.array, i);
      mulle_map_remove( &_blobs.map, blob);
      mulle_allocator_free( &_allocator, blob);
   }
   _blobs.array._curr = _blobs.array._storage + _memo.n_blobs;

   // rewind buffer
   mulle_buffer_reset( &_buffer);
   // also truncate _output back to where it was before this frame
   // (buffer was flushed to _output at memo time, nothing new flushed yet
   //  since we haven't called _flushBufferToOutput — so _output is already clean)
}


- (void) _emitDeltaTables
{
   unsigned int   i, n;
   Class          cls;
   char           *name;
   char           *substitute;
   SEL            sel;
   struct blob    *blob;
   id             obj;
   size_t         offset;
   unsigned int   blobStart;
   unsigned int   clsStart;
   unsigned int   selStart;
   unsigned int   objStart;

   blobStart = _memo.n_blobs;
   clsStart  = _memo.n_classes;
   selStart  = _memo.n_selectors;
   objStart  = _memo.n_objects;

   // Pre-pass 1: register classes for all new objects
   // (so class handles are assigned before we emit the class delta)
   n = (unsigned int) mulle_pointerarray_get_count( &_objects.array);
   for( i = objStart; i < n; i++)
   {
      obj = (id) _mulle_pointerarray_get( &_objects.array, i);
      cls = [obj classForCoder];
      // register class if not already known (adds to _classes.map and _classes.array)
      MulleObjCPointerHandleMapGetOrAdd( &_classes, cls);
   }

   // Pre-pass: ensure class names and selector names are in blobs
   // (calling _appendUTF8String: adds to _blobs but must not write to _buffer yet)
   // We do this by temporarily using _appendUTF8String: which writes a handle
   // to _buffer - but we don't want that yet. Instead, inline the blob registration.

   n = (unsigned int) mulle_pointerarray_get_count( &_classes.array);
   for( i = clsStart; i < n; i++)
   {
      cls  = (Class) _mulle_pointerarray_get( &_classes.array, i);
      name = _mulle_objc_infraclass_get_name( cls);
      substitute = NSMapGet( _classNameSubstitutions, name);
      if( substitute)
         name = substitute;
      // register blob without writing to buffer
      {
         struct blob    search;
         intptr_t       handle;

         search._length  = strlen( name) + 1;
         search._storage = name;
         handle = (intptr_t) mulle_map_get( &_blobs.map, &search);
         if( ! handle)
         {
            struct blob   *newblob;
            handle  = mulle_map_get_count( &_blobs.map) + 1;
            newblob = mulle_allocator_malloc( &_allocator, sizeof( struct blob) + search._length);
            newblob->_storage = newblob + 1;
            newblob->_length  = search._length;
            memcpy( newblob->_storage, name, search._length);
            mulle_map_set( &_blobs.map, newblob, (void *) handle);
            _mulle_pointerarray_add( &_blobs.array, newblob);
         }
      }
   }

   n = (unsigned int) mulle_pointerarray_get_count( &_selectors.array);
   for( i = selStart; i < n; i++)
   {
      sel  = (SEL)(intptr_t) _mulle_pointerarray_get( &_selectors.array, i);
      name = mulle_objc_universe_lookup_methodname( MulleObjCObjectGetUniverse( self),
                                                    (mulle_objc_methodid_t) sel);
      if( ! name)
         [NSException raise:NSInconsistentArchiveException
                     format:@"can't archive unregistered selector"];
      {
         struct blob    search;
         intptr_t       handle;

         search._length  = strlen( name) + 1;
         search._storage = name;
         handle = (intptr_t) mulle_map_get( &_blobs.map, &search);
         if( ! handle)
         {
            struct blob   *newblob;
            handle  = mulle_map_get_count( &_blobs.map) + 1;
            newblob = mulle_allocator_malloc( &_allocator, sizeof( struct blob) + search._length);
            newblob->_storage = newblob + 1;
            newblob->_length  = search._length;
            memcpy( newblob->_storage, name, search._length);
            mulle_map_set( &_blobs.map, newblob, (void *) handle);
            _mulle_pointerarray_add( &_blobs.array, newblob);
         }
      }
   }

   // Now emit blob delta (includes class/selector name blobs added above)
   n = (unsigned int) mulle_pointerarray_get_count( &_blobs.array);
   if( n > blobStart)
   {
      mulle_buffer_add_bytes( &_buffer, "**blb**", 8);
      mulle_buffer_add_integer( &_buffer, n - blobStart);
      for( i = blobStart; i < n; i++)
      {
         blob = (struct blob *) _mulle_pointerarray_get( &_blobs.array, i);
         mulle_buffer_add_integer( &_buffer, blob->_length);
         mulle_buffer_add_bytes( &_buffer, blob->_storage, blob->_length);
      }
   }

   // emit class delta
   n = (unsigned int) mulle_pointerarray_get_count( &_classes.array);
   if( n > clsStart)
   {
      mulle_buffer_add_bytes( &_buffer, "**cls**", 8);
      mulle_buffer_add_integer( &_buffer, n - clsStart);
      for( i = clsStart; i < n; i++)
      {
         struct blob   search;
         intptr_t      blobHandle;

         cls  = (Class) _mulle_pointerarray_get( &_classes.array, i);
         name = _mulle_objc_infraclass_get_name( cls);
         substitute = NSMapGet( _classNameSubstitutions, name);
         if( substitute)
            name = substitute;

         mulle_buffer_add_integer( &_buffer, [cls version]);
         mulle_buffer_add_integer( &_buffer, _mulle_objc_infraclass_get_ivarhash( cls));

         search._length  = strlen( name) + 1;
         search._storage = name;
         blobHandle = (intptr_t) mulle_map_get( &_blobs.map, &search);
         mulle_buffer_add_integer( &_buffer, (uint64_t) blobHandle);
      }
   }

   // emit selector delta
   n = (unsigned int) mulle_pointerarray_get_count( &_selectors.array);
   if( n > selStart)
   {
      mulle_buffer_add_bytes( &_buffer, "**sel**", 8);
      mulle_buffer_add_integer( &_buffer, n - selStart);
      for( i = selStart; i < n; i++)
      {
         struct blob   search;
         intptr_t      blobHandle;

         sel  = (SEL)(intptr_t) _mulle_pointerarray_get( &_selectors.array, i);
         name = mulle_objc_universe_lookup_methodname( MulleObjCObjectGetUniverse( self),
                                                       (mulle_objc_methodid_t) sel);
         search._length  = strlen( name) + 1;
         search._storage = name;
         blobHandle = (intptr_t) mulle_map_get( &_blobs.map, &search);
         mulle_buffer_add_integer( &_buffer, (uint64_t) blobHandle);
      }
   }

   // emit object table delta
   n = (unsigned int) mulle_pointerarray_get_count( &_objects.array);
   if( n > objStart)
   {
      mulle_buffer_add_bytes( &_buffer, "**obj**", 8);
      mulle_buffer_add_integer( &_buffer, n - objStart);
      for( i = objStart; i < n; i++)
      {
         intptr_t   clsHandle;

         obj = (id) _mulle_pointerarray_get( &_objects.array, i);
         cls = [obj classForCoder];

         // look up existing class handle (class was already registered above)
         clsHandle = (intptr_t) mulle_map_get( &_classes.map, cls);
         mulle_buffer_add_integer( &_buffer, (uint64_t) clsHandle);

         offset = (size_t) NSMapGet( _offsets, obj);
         mulle_buffer_add_integer( &_buffer, offset);
      }
   }
}


- (void) encodeRootObject:(id) obj
{
   if( ! obj)
      return;
   [self beginFrame];
   [self encodeFrameObject:obj];
   [self commitFrame];
}


- (void) beginFrame
{
   [self _snapshotMemo];
   mulle_buffer_reset( &_buffer);
   NSResetMapTable( _offsets);
}


- (void) encodeFrameObject:(id) obj
{
   unsigned int   i, n;
   id             queuedObj;

   if( ! obj)
      return;

   [self _appendObject:obj];

   n = _memo.n_objects;
   for(;;)
   {
      unsigned int   start = n;
      n = (unsigned int) mulle_pointerarray_get_count( &_objects.array);
      if( n == start)
         break;
      for( i = start; i < n; i++)
      {
         queuedObj = (id) _mulle_pointerarray_get( &_objects.array, i);
         NSMapInsert( _offsets, queuedObj,
                      (void *)(intptr_t) mulle_buffer_get_seek( &_buffer));
         [queuedObj encodeWithCoder:self];
         mulle_buffer_add_byte( &_buffer, 0);
      }
   }
}


- (NSData *) commitFrame
{
   struct mulle_buffer   dataBuf;
   size_t                dataLen;
   void                  *dataBytes;
   NSUInteger            outputBefore;

   outputBefore = [_output length];

   dataLen   = mulle_buffer_get_length( &_buffer);
   dataBytes = mulle_buffer_get_bytes( &_buffer);
   mulle_buffer_init( &dataBuf, dataLen ? dataLen : 1, &_allocator);
   mulle_buffer_add_bytes( &dataBuf, dataBytes, dataLen);
   mulle_buffer_reset( &_buffer);

   [self _emitDeltaTables];

   mulle_buffer_add_bytes( &_buffer, "**dta**", 8);
   mulle_buffer_add_integer( &_buffer, dataLen);
   mulle_buffer_add_bytes( &_buffer, mulle_buffer_get_bytes( &dataBuf), dataLen);
   mulle_buffer_done( &dataBuf);

   [self _flushBufferToOutput];

   // return just the bytes added by this frame
   return( [_output subdataWithRange:NSMakeRange( outputBefore,
                                                  [_output length] - outputBefore)]);
}


- (void) discardFrame
{
   [self _rollbackToMemo];
}


- (void) forgetObject:(id) obj
{
   intptr_t   handle;

   if( ! obj)
      return;

   handle = (intptr_t) mulle_map_get( &_objects.map, obj);
   if( ! handle)
      return;

   mulle_buffer_add_bytes( &_buffer, "**rel**", 8);
   mulle_buffer_add_integer( &_buffer, 1);
   mulle_buffer_add_integer( &_buffer, (uint64_t) handle);

   mulle_map_remove( &_objects.map, obj);
   // note: we don't remove from array (handles stay stable), just from map
   // so it won't be found as "already known" and will be re-defined if needed

   [self _flushBufferToOutput];
}


- (NSData *) streamData
{
   return( [[_output copy] autorelease]);
}


// NSCoder protocol - delegate to super's encode machinery
- (void) encodeValueOfObjCType:(char *) type
                            at:(void *) p
{
   [self _encodeValueOfObjCType:type
                             at:p];
}


- (void) encodeBytes:(void *) bytes
              length:(NSUInteger) len
{
   [self _appendBytes:bytes
               length:len];
}

@end
