//
//  MulleObjCArchiver-Private.h
//  MulleObjCArchiverFoundation
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

#import "NSArchiver.h"

#import "import.h"

//
// this is all static inline to share code w/o littering the namespace
// between NSArchiver and NSUnarchiver

struct blob
{
   size_t   _length;
   void     *_storage;
};


static inline  uintptr_t   blob_hash( struct mulle_container_keycallback *ignore,
                                      struct blob *blob)
{
   NSUInteger   len;

   len = blob->_length;
   if( len > 256)
      len = 256;
   return( mulle_data_hash( mulle_data_make( blob->_storage, len)));
}


static inline int   blob_is_equal( struct mulle_container_keycallback *ignore,
                                   struct blob  *a,
                                   struct blob  *b)
{
   assert( a && b);
   if( a->_length != b->_length)
      return( 0);
   return( ! memcmp( a->_storage, b->_storage, a->_length));
}


static inline char   *blob_describe( struct mulle_container_keycallback *ignore,
                                     void  *_blob,
                                     struct mulle_allocator **p_allocator)
{
   struct blob  *blob = _blob;

   *p_allocator = NULL;
   return( [[NSString stringWithFormat:@"<%ld %p %.*s>",
                                          blob->_length, blob->_storage,
                                          blob->_length, blob->_storage] UTF8String]);
}



#pragma mark - MulleObjCPointerHandleMap


MULLE_C_NONNULL_FIRST_THIRD
static inline void   MulleObjCPointerHandleMapInit( struct MulleObjCPointerHandleMap *map,
                                                    unsigned int capacity,
                                                    struct mulle_container_keyvaluecallback *callback,
                                                    struct mulle_allocator *allocator)
{
   _mulle_map_init( &map->map, capacity, callback, allocator);
   _mulle_pointerarray_init( &map->array, capacity, allocator);
}


MULLE_C_NONNULL_FIRST
static inline void   MulleObjCPointerHandleMapDone( struct MulleObjCPointerHandleMap *map)
{
   _mulle_map_done( &map->map);
   _mulle_pointerarray_done( &map->array);
}


MULLE_C_NONNULL_FIRST
static inline intptr_t  MulleObjCPointerHandleMapGetOrAdd( struct MulleObjCPointerHandleMap *map,
                                                           void *p)
{
   intptr_t   handle;

   handle = (intptr_t) _mulle_map_get( &map->map, p);
   if( handle)
      return( handle);

   handle      = _mulle_map_get_count( &map->map) + 1;
   _mulle_map_set( &map->map, p, (void *) handle);
   _mulle_pointerarray_add( &map->array, p);

   return( handle);
}
