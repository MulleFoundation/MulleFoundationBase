//
//  NSString+ClassCluster.m
//  MulleObjCValueFoundation
//
//  Copyright (c) 2016 Nat! - Mulle kybernetiK.
//  Copyright (c) 2016 Codeon GmbH.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "NSString+ClassCluster.h"

// other files in this library
#import "_MulleObjCValueTaggedPointer.h"
#import "_MulleObjCTaggedPointerChar5String.h"
#import "_MulleObjCTaggedPointerChar7String.h"
#import "_MulleObjCASCIIString.h"
#import "_MulleObjCUTF16String.h"
#import "_MulleObjCUTF32String.h"

// other libraries of MulleObjCValueFoundation

// std-c and dependencies
#import "import-private.h"


@implementation NSString( ClassCluster)


static void   _NSThrowInvalidUTF8Exception( char *s,
                                            size_t len,
                                            struct mulle_utf_information *info)
{
   struct mulle_buffer   buffer;
   auto char             space[ 256];
   char                  *p;
   char                  *invalid;

   if( ! s || ! info)
      MulleObjCThrowInternalInconsistencyExceptionUTF8String( "UTF8 internal corruption");

   invalid = info->invalid;
   if( s > invalid)
      MulleObjCThrowInvalidArgumentExceptionUTF8String( "UTF8 internal corruption, no data can be shown");

   if( len == -1)
      len = mulle_utf8_strlen( s);

   p   = invalid;
   p  -= 8;
   if( p < s)
      p = s;

   len = &s[ len] - invalid;
   if( len > 8)
      len = 8;

   mulle_buffer_init_with_static_bytes( &buffer, space, sizeof( space), NULL);
   mulle_buffer_hexdump_line( &buffer,
                              p,
                              invalid - p,
                              (size_t) (s - p),
                              mulle_buffer_hexdump_no_ascii);
   mulle_buffer_add_string( &buffer, " > ");
   mulle_buffer_hexdump_line( &buffer,
                              invalid,
                              len,
                              (size_t) (invalid - s),
                              mulle_buffer_hexdump_no_offset|mulle_buffer_hexdump_no_ascii);
   mulle_buffer_zero_last_byte( &buffer);
   MulleObjCThrowInvalidArgumentExceptionUTF8String( "Invalid UTF8: %s", space);
}


static void   _NSThrowInvalidUTF32Exception( mulle_utf32_t *s,
                                             size_t len,
                                             struct mulle_utf_information *info,
                                             struct mulle_allocator *allocator)
{
   struct mulle_buffer   buffer;
   auto char             space[ 256];
   mulle_utf32_t         *p;
   mulle_utf32_t         *invalid;

   invalid = (mulle_utf32_t *) info->invalid;
   if( s > (mulle_utf32_t *) info->invalid)
   {
      if( allocator)
         mulle_allocator_free( allocator, s);
      MulleObjCThrowInvalidArgumentExceptionUTF8String( "UTF32 internal corruption, no data can be shown");
   }

   p   = invalid;
   p  -= 2;
   if( p < s)
      p = s;

   len = &s[ len] - invalid;
   if( len > 2)
      len = 2;

   mulle_buffer_init_with_static_bytes( &buffer, space, sizeof( space), NULL);
   mulle_buffer_hexdump_line( &buffer,
                              (uint8_t *) p, (invalid - p) * sizeof( mulle_utf32_t),
                              (size_t) (s - p) * sizeof( mulle_utf32_t),
                              mulle_buffer_hexdump_no_ascii);
   mulle_buffer_add_string( &buffer, " > ");
   mulle_buffer_hexdump_line( &buffer,
                              (uint8_t *) invalid,
                              len * sizeof( mulle_utf32_t),
                              (size_t) (invalid - s) * sizeof( mulle_utf32_t),
                              mulle_buffer_hexdump_no_offset|mulle_buffer_hexdump_no_ascii);
   mulle_buffer_zero_last_byte( &buffer);

   if( allocator)
      mulle_allocator_free( allocator, s);

   MulleObjCThrowInvalidArgumentExceptionUTF8String( "Invalid UTF32 (0x%x): %s", *invalid, space);
}


// info known to be 8 bit characters
static NSString  *
   MulleObjCNewUTF16StringWithUTF8Information( struct mulle_utf_information *info,
                                               struct mulle_allocator *allocator)
{
   mulle_utf16_t   *buf;
   mulle_utf16_t   *end;

   buf = mulle_allocator_malloc( allocator, info->utf16len * sizeof( mulle_utf16_t));
   end = _mulle_utf8_convert_to_utf16( info->start,
                                       info->utf8len,
                                       buf);
   assert( end == &buf[ info->utf16len]);
   MULLE_C_UNUSED( end);

   return( [_MulleObjCAllocatorUTF16String newWithUTF16CharactersNoCopy:buf
                                                                 length:info->utf16len
                                                              allocator:allocator]);
}


static NSString  *
   MulleObjCNewUTF32StringWithUTF8Information( struct mulle_utf_information *info,
                                               struct mulle_allocator *allocator)
{
   mulle_utf32_t   *buf;
   mulle_utf32_t   *end;

   buf = mulle_allocator_malloc( allocator, info->utf32len * sizeof( mulle_utf32_t));
   end = _mulle_utf8_convert_to_utf32( info->start,
                                       info->utf8len,
                                       buf);
   assert( end == &buf[ info->utf32len]);
   MULLE_C_UNUSED( end);

   return( [_MulleObjCAllocatorUTF32String newWithUTF32CharactersNoCopy:buf
                                                                 length:info->utf32len
                                                              allocator:allocator]);
}


static NSString  *
   MulleObjCNewUTF16StringWithUTF32Characters( mulle_utf32_t *s,
                                               NSUInteger length,
                                               struct mulle_allocator *allocator)
{
   struct mulle_buffer   buffer;
   struct mulle_data     data;

   assert( length);
   mulle_buffer_init( &buffer, 0, allocator);

   // make intital alloc large enough for optimal case
   mulle_buffer_guarantee( &buffer, length * sizeof( mulle_utf16_t));
   mulle_utf32_bufferconvert_to_utf16( s,
                                       length,
                                       &buffer,
                                       mulle_buffer_add_bytes_callback);

   data = mulle_buffer_extract_data( &buffer);
   mulle_buffer_done( &buffer);

   return( [_MulleObjCAllocatorUTF16String newWithUTF16CharactersNoCopy:data.bytes
                                                                 length:data.length / sizeof( mulle_utf16_t)
                                                              allocator:allocator]);
}

#if 0 // UNUSED
static NSString  *
   MulleObjCNewUTF32StringWithUTF8Characters( char *s,
                                              NSUInteger length,
                                              struct mulle_allocator *allocator)
{
   struct mulle_buffer   buffer;
   struct mulle_data     data;

   assert( length);
   assert( allocator);

   mulle_buffer_init( &buffer, allocator);

   // make initial alloc large enough for optimal case
   mulle_buffer_guarantee( &buffer, length * sizeof( mulle_utf32_t));
   mulle_utf8_bufferconvert_to_utf32( s,
                                      length,
                                      &buffer,
                                      mulle_buffer_add_bytes_callback);

   data = mulle_buffer_extract_data( &buffer);
   mulle_buffer_done( &buffer);

   return( [_MulleObjCAllocatorUTF32String newWithUTF32CharactersNoCopy:data.bytes
                                                                 length:data.length / sizeof( unichar)
                                                              allocator:allocator]);
}
#endif

static NSString  *MulleObjCNewUTF32StringWithUTF32Characters( mulle_utf32_t *s,
                                                              NSUInteger length)
{
   assert( length);
   return( [_MulleObjCGenericUTF32String newWithUTF32Characters:s
                                                         length:length]);
}


static NSString  *newStringOrNilWithUTF8Characters( char *buf,
                                                    NSUInteger len,
                                                    struct mulle_allocator *allocator,
                                                    struct _mulle_objc_universe *universe)
{
   struct mulle_utf_information   info;

   if( ! len)
      return( @"");

   if( mulle_utf8_information( buf, len, &info))
      return( nil);

#ifdef __MULLE_OBJC_TPS__
   if( info.is_ascii && info.utf8len <= mulle_char7_get_maxlength())
      return( MulleObjCTaggedPointerChar7StringWithASCIICharacters( (char *) info.start, info.utf8len));
   if( info.is_char5 && info.utf8len <= mulle_char5_get_maxlength())
      return( MulleObjCTaggedPointerChar5StringWithASCIICharacters( (char *) info.start, info.utf8len));
#endif

   if( info.is_ascii)
      return( _MulleObjCNewASCIIStringWithASCIICharacters( (char *) info.start, info.utf8len, universe));

   if( info.is_utf15)
      return( MulleObjCNewUTF16StringWithUTF8Information( &info, allocator));

   return( MulleObjCNewUTF32StringWithUTF8Information( &info, allocator));
}


static NSString  *newStringWithUTF8Characters( char *buf,
                                               NSUInteger len,
                                               struct mulle_allocator *allocator,
                                               struct _mulle_objc_universe *universe)
{
   struct mulle_utf_information   info;

   if( ! len)
      return( @"");

   if( mulle_utf8_information( buf, len, &info))
      _NSThrowInvalidUTF8Exception( buf, len, &info);

#ifdef __MULLE_OBJC_TPS__
   if( MulleObjCChar7TPSIndex <= mulle_objc_get_taggedpointer_mask()
       && info.is_ascii
       && info.utf8len <= mulle_char7_get_maxlength())
   {
      return( MulleObjCTaggedPointerChar7StringWithASCIICharacters( (char *) info.start, info.utf8len));
   }
   if( MulleObjCChar7TPSIndex <= mulle_objc_get_taggedpointer_mask()
       && info.is_char5
       && info.utf8len <= mulle_char5_get_maxlength())
   {
      return( MulleObjCTaggedPointerChar5StringWithASCIICharacters( (char *) info.start, info.utf8len));
   }
#endif

   if( info.is_ascii)
      return( _MulleObjCNewASCIIStringWithASCIICharacters( (char *) info.start, info.utf8len, universe));

   if( info.is_utf15)
      return( MulleObjCNewUTF16StringWithUTF8Information( &info, allocator));

   return( MulleObjCNewUTF32StringWithUTF8Information( &info, allocator));
}


static NSString  *newStringWithUTF32Characters( mulle_utf32_t *buf,
                                                NSUInteger len,
                                                struct mulle_allocator *allocator,
                                                struct _mulle_objc_universe *universe)
{
   struct mulle_utf_information  info;

   if( ! len)
      return( @"");

   if( mulle_utf32_information( buf, len, &info))
      _NSThrowInvalidUTF32Exception( buf, len, &info, NULL);

#ifdef __MULLE_OBJC_TPS__
   if( info.is_ascii && info.utf32len <= mulle_char7_get_maxlength())
      return( MulleObjCTaggedPointerChar7StringWithCharacters( (unichar *) info.start, info.utf32len));
   if( info.is_char5 && info.utf32len <= mulle_char5_get_maxlength())
      return( MulleObjCTaggedPointerChar5StringWithCharacters( (unichar *) info.start, info.utf32len));
#endif

   if( info.is_ascii)
      return( _MulleObjCNewASCIIStringWithUTF32Characters( info.start, info.utf32len, universe));

   if( info.is_utf15)
      return( MulleObjCNewUTF16StringWithUTF32Characters( info.start, info.utf32len, allocator));

   return( MulleObjCNewUTF32StringWithUTF32Characters( info.start, info.utf32len));
}


#pragma mark - standard public class cluster init

- (instancetype) initWithUTF8String:(char *) s
{
   struct mulle_allocator       *allocator;
   struct _mulle_objc_universe  *universe;

   assert( [self __isClassClusterObject]);

   if( ! s)
      MulleObjCThrowInvalidArgumentExceptionUTF8String( "argument must not be null");

   allocator = MulleObjCInstanceGetAllocator( self);
   universe  = MulleObjCObjectGetUniverse( self);
   self      = newStringWithUTF8Characters( s,
                                            strlen( s),
                                            allocator,
                                            universe);
   return( self);
}


- (instancetype) initWithCharacters:(unichar *) s
                             length:(NSUInteger) len
{
   struct mulle_allocator        *allocator;
   struct _mulle_objc_universe   *universe;

   assert( [self __isClassClusterObject]);

   allocator = MulleObjCInstanceGetAllocator( self);
   universe  = MulleObjCObjectGetUniverse( self);
   self      = (id) newStringWithUTF32Characters( s, len, allocator, universe);
   return( self);
}


- (instancetype) initWithCharactersNoCopy:(unichar *) chars
                                   length:(NSUInteger) length
                             freeWhenDone:(BOOL) flag
{
   struct mulle_allocator   *allocator;

   assert( [self __isClassClusterObject]);

   allocator = flag ? &mulle_stdlib_allocator : NULL;
   self      = [self mulleInitWithCharactersNoCopy:chars
                                            length:length
                                         allocator:allocator];
   return( self);
}


#pragma mark - mulle public class cluster init

//
// this is a mulle addition, public method
//
- (instancetype) mulleInitWithUTF8Characters:(char *) s
                                      length:(NSUInteger) len
{
   struct mulle_allocator        *allocator;
   struct _mulle_objc_universe   *universe;

   allocator = MulleObjCInstanceGetAllocator( self);
   universe  = MulleObjCObjectGetUniverse( self);
   self      = (id) newStringWithUTF8Characters( s, len, allocator, universe);
   return( self);
}


//
// as above but will return nil, if UTF8 is wrong
//
- (instancetype) mulleInitOrNilWithUTF8Characters:(char *) s
                                           length:(NSUInteger) len
{
   struct mulle_allocator       *allocator;
   struct _mulle_objc_universe   *universe;

   allocator = MulleObjCInstanceGetAllocator( self);
   universe  = MulleObjCObjectGetUniverse( self);
   self      = (id) newStringOrNilWithUTF8Characters( s, len, allocator, universe);
   return( self);
}


//
// this is a mulle addition, public method
//
- (instancetype) mulleInitWithCharactersNoCopy:(unichar *) s
                                        length:(NSUInteger) length
                                     allocator:(struct mulle_allocator *) allocator
{
   struct mulle_utf_information   info;

   if( mulle_utf32_information( s, length, &info))
      _NSThrowInvalidUTF32Exception( s, length, &info, allocator);

   if( ! info.utf32len)
   {
      if( allocator)
         mulle_allocator_free( allocator, s);
      return( @"");
   }

   if( info.has_bom)
   {
      self = [self initWithCharacters:s
                               length:length];
      if( allocator)
         mulle_allocator_free( allocator, s);
      return( self);
   }

   self = [_MulleObjCAllocatorUTF32String newWithUTF32CharactersNoCopy:info.start
                                                                length:info.utf32len
                                                             allocator:allocator];
   return( self);
}


static NSString  *
   initNonASCIIStringWithUTFInformation( id self, struct mulle_utf_information *info)
{
   struct mulle_allocator   *allocator;

   assert( info);

   // need to copy it, because it's not ASCII
   allocator = MulleObjCInstanceGetAllocator( self);

   // convert it to UTF16
   // make it a regular string
   if( info->is_utf15)
      return( MulleObjCNewUTF16StringWithUTF8Information( info, allocator));
   return( MulleObjCNewUTF32StringWithUTF8Information( info, allocator));
}



static NSString *
   initWithUTF8CharactersNoCopyWithAllocator( NSString *self,
                                              char *s,
                                              NSUInteger length,
                                              struct mulle_allocator *allocator)
{
   struct mulle_utf_information   info;

   if( mulle_utf8_information( s, length, &info))
      _NSThrowInvalidUTF8Exception( s, length, &info);

   if( ! info.utf8len)
   {
      if( allocator)
         mulle_allocator_free( allocator, s);
      return( @"");
   }

   if( info.is_ascii)
   {
      if( info.has_terminating_zero)
      {
         self = [_MulleObjCAllocatorZeroTerminatedASCIIString newWithZeroTerminatedASCIICharactersNoCopy:info.start
                                                                                                  length:info.utf8len
                                                                                               allocator:allocator];
         return( self);
      }

      self = [_MulleObjCAllocatorASCIIString newWithASCIICharactersNoCopy:info.start
                                                                   length:info.utf8len
                                                                allocator:allocator];
      return( self);
   }

   self = initNonASCIIStringWithUTFInformation( self, &info);
   // free it, because we don't use it
   if( allocator)
      mulle_allocator_free( allocator, s);

   return( self);
}


- (instancetype) mulleInitWithUTF8CharactersNoCopy:(char *) s
                                            length:(NSUInteger) length
                                         allocator:(struct mulle_allocator *) allocator
{
   return( initWithUTF8CharactersNoCopyWithAllocator( self, s, length, allocator));
}


- (instancetype) mulleInitWithUTF8CharactersNoCopy:(char *) s
                                            length:(NSUInteger) length
                                      freeWhenDone:(BOOL) flag;
{
   struct mulle_allocator   *allocator;

   allocator = flag ? &mulle_stdlib_allocator : NULL;
   return( initWithUTF8CharactersNoCopyWithAllocator( self, s, length, allocator));
}


#pragma mark - mulle private class cluster init

- (instancetype) mulleInitWithUTF8CharactersNoCopy:(char *) s
                                            length:(NSUInteger) length
                                     sharingObject:(id) object
{
   struct mulle_utf_information   info;

   if( ! object)
      MulleObjCThrowInvalidArgumentExceptionUTF8String( "object is nil");

   if( mulle_utf8_information( s, length, &info))
      _NSThrowInvalidUTF8Exception( s, length, &info);

   if( ! info.utf8len)
      return( @"");

   if( info.is_ascii)
   {
      self = [_MulleObjCSharedASCIIString newWithASCIICharactersNoCopy:info.start
                                                                length:info.utf8len
                                                         sharingObject:object];
      return( self);
   }
   self = initNonASCIIStringWithUTFInformation( self, &info);

   return( self);

}


- (instancetype) mulleInitWithCharactersNoCopy:(unichar *) s
                                        length:(NSUInteger) length
                                 sharingObject:(id) object
{
   struct mulle_utf_information   info;

   if( ! object)
      MulleObjCThrowInvalidArgumentExceptionUTF8String( "object is nil");

   if( mulle_utf32_information( s, length, &info))
      _NSThrowInvalidUTF32Exception( s, length, &info, NULL);

   if( ! info.utf32len)
      return( @"");

   self = [_MulleObjCSharedUTF32String newWithUTF32CharactersNoCopy:info.start
                                                             length:info.utf32len
                                                      sharingObject:object];
   return( self);
}

@end
