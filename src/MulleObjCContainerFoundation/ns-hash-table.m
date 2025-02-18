//
//  ns_hash_table.c
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
#import "ns-hash-table.h"

// other files in this library

// other libraries of MulleObjCContainerFoundation

// std-c and dependencies
#import "import-private.h"


NSHashTable   *MulleObjCHashTableCreate( NSHashTableCallBacks callBacks, NSUInteger capacity)
{
   NSHashTable   *table;

   table  = mulle_malloc( sizeof( NSHashTable));
   MulleObjCHashTableInit( table, &callBacks, capacity);
   return( table);
}


void   MulleObjCHashTableFree( NSHashTable *table)
{
   mulle_set_done( &table->_set);
   mulle_free( table);
}


NSHashTable   *MulleObjCHashTableCopy( NSHashTable *table)
{
   NSHashTable   *clone;

   clone = MulleObjCHashTableCreate( table->_callback, mulle_set_get_count( &table->_set));
   mulle_set_copy_items( &clone->_set, &table->_set);

   return( clone);
}


void   MulleObjCHashTableInsert( NSHashTable *table, void *p)
{
   if( p == table->_callback.notakey)
      MulleObjCThrowInvalidArgumentExceptionUTF8String( "key is not a key marker (%p)", p);
   mulle_set_set( &table->_set, p);
}


void   MulleObjCHashTableInsertKnownAbsent( NSHashTable *table, void *p)
{
   if( p == table->_callback.notakey)
      MulleObjCThrowInvalidArgumentExceptionUTF8String( "key is not a key marker (%p)", p);

   if( mulle_set_get( &table->_set, p))
      MulleObjCThrowInvalidArgumentExceptionUTF8String( "key is already present (%p)", p);

   mulle_set_set( &table->_set, p);
}


void   *MulleObjCHashTableInsertIfAbsent( NSHashTable *table, void *p)
{
   void  *old;

   old = mulle_set_get( &table->_set, p);
   if( old)
      return( old);

   mulle_set_set( &table->_set, p);
   return( NULL);
}
