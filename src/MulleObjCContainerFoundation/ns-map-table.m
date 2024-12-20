//
//  ns_map_table.c
//  MulleObjCContainerFoundation
//
//  Copyright (c) 2011 Nat! - Mulle kybernetiK.
//  Copyright (c) 2011 Codeon GmbH.
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
#import "ns-map-table.h"

// other files in this library

// other libraries of MulleObjCContainerFoundation

// std-c and dependencies
#import "import-private.h"



void   MulleObjCMapTableInsert( NSMapTable *table, void *key, void *value)
{
   if( key == table->_callback.keycallback.notakey)
      MulleObjCThrowInvalidArgumentExceptionUTF8String( "key is not a key marker (%p)", key);

   _mulle__map_insert( &table->_map, key, value, &table->_callback, table->_allocator);
}



#pragma mark - setup and teardown

static void   _NSMapTableInitWithAllocator( NSMapTable *table,
                                            NSMapTableKeyCallBacks *keyCallBacks,
                                            NSMapTableValueCallBacks *valueCallBacks,
                                            NSUInteger capacity,
                                            struct mulle_allocator *allocator)
{
   table->_callback.keycallback   = *keyCallBacks;
   table->_callback.valuecallback = *valueCallBacks;
   table->_allocator              = allocator;

   _mulle__map_init( &table->_map, capacity, &table->_callback, table->_allocator);
}


void    MulleObjCMapTableReset( NSMapTable *table)
{
   _mulle__map_done( &table->_map, &table->_callback, table->_allocator);
   _NSMapTableInitWithAllocator( table, &table->_callback.keycallback, &table->_callback.valuecallback, 0, table->_allocator);
}


NSMapTable   *MulleObjCMapTableCreate( NSMapTableKeyCallBacks keyCallBacks,
                                       NSMapTableValueCallBacks valueCallBacks,
                                       NSUInteger capacity)
{
   NSMapTable   *table;

   table = mulle_malloc( sizeof( NSMapTable));
   _NSMapTableInitWithAllocator( table, &keyCallBacks, &valueCallBacks, capacity, &mulle_default_allocator);
   return( table);
}


NSMapTable   *MulleObjCMapTableCreateWithAllocator( NSMapTableKeyCallBacks keyCallBacks,
                                              NSMapTableValueCallBacks valueCallBacks,
                                              NSUInteger capacity,
                                              struct mulle_allocator *allocator)
{
   NSMapTable   *table;

   table = mulle_allocator_malloc( allocator, sizeof( NSMapTable));
   _NSMapTableInitWithAllocator( table, &keyCallBacks, &valueCallBacks, capacity, allocator);
   return( table);
}


void   MulleObjCMapTableFree( NSMapTable *table)
{
   if( table)
      _mulle__map_destroy( &table->_map, &table->_callback, table->_allocator);
}



#pragma mark - operations


void   MulleObjCMapTableInsertKnownAbsent( NSMapTable *table, void *key, void *value)
{
   if( key == table->_callback.keycallback.notakey)
      MulleObjCThrowInvalidArgumentExceptionUTF8String( "key is not a key marker (%p)", key);

   if( _mulle__map_get( &table->_map, key, &table->_callback))
      MulleObjCThrowInvalidArgumentExceptionUTF8String( "key is already present (%p)", key);

   _mulle__map_insert( &table->_map, key, value, &table->_callback, table->_allocator);
}


void   *MulleObjCMapTableInsertIfAbsent( NSMapTable *table, void *key, void *value)
{
   void   *old;

   old =  _mulle__map_get( &table->_map, key, &table->_callback);
   if( old)
      return( old);

   _mulle__map_insert( &table->_map, key, value, &table->_callback, table->_allocator);
   return( NULL);
}


#pragma mark - copying

NSMapTable   *MulleObjCMapTableCopy( NSMapTable *table)
{
   NSMapTable   *other;

   other = NSCreateMapTable( table->_callback.keycallback, table->_callback.valuecallback, 0);
   if( other)
      _mulle__map_copy_items( (struct mulle__map *) other, &table->_map, &table->_callback, table->_allocator);
   return( other);
}
