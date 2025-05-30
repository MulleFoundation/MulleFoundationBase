//
//  _MulleObjCCheatingASCIIString.h
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

// Can't do this because it's private
// #import "_MulleObjCASCIIString.h"


@interface _MulleObjCCheatingASCIIString : _MulleObjCReferencingASCIIString < MulleObjCValueProtocols>
@end


//
// the cheating ASCII String is used internally for "on stack" objects
// for these very special moments
//
struct _MulleObjCCheatingASCIIStringStorage
{
   struct _mulle_objc_objectheader   _header;
   @defs( _MulleObjCCheatingASCIIString);
};



static inline id
   _MulleObjCCheatingASCIIStringStorageGetObject( struct _MulleObjCCheatingASCIIStringStorage *p)
{
   return( (id) _mulle_objc_objectheader_get_object( &p->_header));
}


static inline char  *
   _MulleObjCCheatingASCIIStringStorageGetStorage( struct _MulleObjCCheatingASCIIStringStorage *p)
{
   return( p->_storage);
}


static inline size_t
   _MulleObjCCheatingASCIIStringStorageGetLength( struct _MulleObjCCheatingASCIIStringStorage *p)
{
   return( p->_length);
}


//
// the cheating ASCII string is always zero terminated
// size is the length of the string plus zero termination
//
static inline id
   _MulleObjCCheatingASCIIStringStorageInit( struct _MulleObjCCheatingASCIIStringStorage *storage,
                                             char *buf,
                                             NSUInteger length)
{
   _MulleObjCCheatingASCIIString   *p;
   Class                           cls;

   assert( strlen( buf) == length);

   p = _MulleObjCCheatingASCIIStringStorageGetObject( storage);

   cls = [_MulleObjCCheatingASCIIString class];
   MulleObjCInstanceSetClass( p, cls);
   MulleObjCInstanceConstantify( p);
   MulleObjCInstanceSetThreadAffinity( p, mulle_thread_self());
   storage->_storage = buf;
   storage->_length  = length;
   storage->_shadow  = 0;

   return( p);
}
