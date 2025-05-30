//
//  ns-hash-table.h
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
#ifndef ns_hash_table_h__
#define ns_hash_table_h__


#import "import.h"



typedef struct mulle_container_keycallback   NSHashTableCallBacks;

//
// NSHashTable is pretty much mulle_set with a copy of the callbacks
// This is tied to the runtime, through the exception mechanism
// otherwise it's pure C
//
typedef struct
{
   NSHashTableCallBacks   _callback;   // callbacks must be first (!) (for callbacks)
   struct mulle_set       _set;
} NSHashTable;

typedef struct mulle_setenumerator   NSHashEnumerator;


//
// in order on darwin to not clobber the links symbols of foundation
// we only use MulleObjC prefix, but the static inline gives the 
// familiar name

MULLE_OBJC_CONTAINER_FOUNDATION_GLOBAL
NSHashTable *
   MulleObjCHashTableCreate( NSHashTableCallBacks callBacks, NSUInteger capacity);

MULLE_OBJC_CONTAINER_FOUNDATION_GLOBAL
void   MulleObjCHashTableFree( NSHashTable *table);


static inline void   MulleObjCHashTableInit( NSHashTable *table,
                                      NSHashTableCallBacks *callBacks,
                                      NSUInteger capacity)
{
   table->_callback = *callBacks;
   mulle_set_init( &table->_set,
                  (unsigned int) capacity,
                  &table->_callback,
                  &mulle_default_allocator);
}



static inline void   MulleObjCHashTableDone( NSHashTable *table)
{
   mulle_set_done( &table->_set);
}


MULLE_OBJC_CONTAINER_FOUNDATION_GLOBAL
void   MulleObjCHashTableInsert( NSHashTable *table, void *p);

MULLE_OBJC_CONTAINER_FOUNDATION_GLOBAL
void   MulleObjCHashTableInsertKnownAbsent( NSHashTable *table, void *p);

MULLE_OBJC_CONTAINER_FOUNDATION_GLOBAL
void   *MulleObjCHashTableInsertIfAbsent( NSHashTable *table, void *p);




# pragma mark - compatibility (preferred)

static inline NSHashTable *
   NSCreateHashTable( NSHashTableCallBacks callBacks, NSUInteger capacity)
{
   return( MulleObjCHashTableCreate( callBacks, capacity));
}


static inline void   NSFreeHashTable( NSHashTable *table)
{
   MulleObjCHashTableFree( table);
}

static inline void   NSHashInsert( NSHashTable *table, void *p)
{
   MulleObjCHashTableInsert( table, p);
}


static inline void   NSHashInsertKnownAbsent( NSHashTable *table, void *p)
{
   MulleObjCHashTableInsertKnownAbsent( table, p);
}


static inline void   *NSHashInsertIfAbsent( NSHashTable *table, void *p)
{
   return( MulleObjCHashTableInsertIfAbsent( table, p));
}



static inline NSHashTable   *
   NSCreateHashTableWithZone( NSHashTableCallBacks callBacks,
                              NSUInteger capacity,
                              NSZone *zone)
{
   return( NSCreateHashTable( callBacks, capacity));
}


static inline void   NSResetHashTable( NSHashTable *table)
{
   mulle_set_reset( &table->_set);
}


static inline void   *NSHashGet( NSHashTable *table, void *p)
{
   return( mulle_set_get( &table->_set, p));
}


static inline void   NSHashRemove( NSHashTable *table, void *p)
{
   mulle_set_remove( &table->_set, p);
}


static inline NSUInteger   NSCountHashTable( NSHashTable *table)
{
   return( mulle_set_get_count( &table->_set));
}


# pragma mark - copying


MULLE_OBJC_CONTAINER_FOUNDATION_GLOBAL
NSHashTable   *MulleObjCHashTableCopy( NSHashTable *table);


static inline NSHashTable   *NSCopyHashTableWithZone( NSHashTable *table,
                                                      NSZone *zone)
{
   return( MulleObjCHashTableCopy( table));
}


# pragma mark - enumeration


static inline NSHashEnumerator   NSEnumerateHashTable( NSHashTable *table)
{
   if( ! table)
      return( *(NSHashEnumerator *) &mulle_setenumerator_empty);
   return( mulle_set_enumerate( &table->_set));
}


static inline void   *NSNextHashEnumeratorItem( NSHashEnumerator *rover)
{
   void   *value;

   // value can be 0 if not-a-key is set for integers for example
   mulle_setenumerator_next( rover, &value);
   return( value);
}


static inline void   NSEndHashTableEnumeration( NSHashEnumerator *rover)
{
   mulle_setenumerator_done( rover);
}



//MulleObjUTF8String *MulleObjUTF8StringFromHashTable( NSHashTable *table);
//MulleObjCArray *MulleObjCAllHashTableObjects( NSHashTable *table);
//MULLE_OBJC_CONTAINER_FOUNDATION_EXTERN_GLOBAL
//NSHashTableCallBacks   MulleObjCNonRetainedObjectHashCallBacks;
//
//MULLE_OBJC_CONTAINER_FOUNDATION_EXTERN_GLOBAL
//NSHashTableCallBacks   MulleObjCObjectHashCallBacks;
//
//MULLE_OBJC_CONTAINER_FOUNDATION_EXTERN_GLOBAL
//NSHashTableCallBacks   MulleObjCOwnedObjectIdentityHashCallBacks;


#define NSIntHashCallBacks                 (*(NSHashTableCallBacks *) &MulleObjCIntMapKeyCallBacks)
#define NSIntegerHashCallBacks             (*(NSHashTableCallBacks *) &MulleObjCIntegerMapKeyCallBacks)
#define NSNonOwnedPointerHashCallBacks     (*(NSHashTableCallBacks *) &MulleObjCNonOwnedPointerMapKeyCallBacks)
#define NSOwnedPointerHashCallBacks        (*(NSHashTableCallBacks *) &MulleObjCOwnedPointerMapKeyCallBacks)
#define NSNonOwnedPointerHashCallBacks     (*(NSHashTableCallBacks *) &MulleObjCNonOwnedPointerMapKeyCallBacks)
#define NSNonRetainedObjectHashCallBacks   (*(NSHashTableCallBacks *) &MulleObjCNonRetainedObjectMapKeyCallBacks)
#define NSObjectHashCallBacks              (*(NSHashTableCallBacks *) &MulleObjCObjectMapKeyCallBacks)


#define NSHashTableFor( name, value)                                              \
   assert( sizeof( value) == sizeof( void *));                                    \
   for( NSHashEnumerator                                                          \
           rover__ ## value = NSEnumerateHashTable( name),                        \
           *rover__  ## value ## __i = (void *) 0;                                \
        ! rover__  ## value ## __i;                                               \
        rover__ ## value ## __i = (NSEndHashTableEnumeration( &rover__ ## value), \
                                              (void *) 1))                        \
      while( NSNextMapEnumeratorPair( &rover__ ## value,                          \
                                      (void **) &value))


#endif
