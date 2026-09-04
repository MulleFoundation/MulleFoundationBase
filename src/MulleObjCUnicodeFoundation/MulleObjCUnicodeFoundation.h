//
//  MulleObjCUnicodeFoundation.h
//  MulleObjCUnicodeFoundation
//
//  Copyright (c) 2020 Nat! - Mulle kybernetiK.
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
#ifndef mulle_objc_unicode_foundation_h__
#define mulle_objc_unicode_foundation_h__

#import "import.h"

#include <stdint.h>

/*
 *  (c) 2020 nat ORGANIZATION
 *
 *  version:  major, minor, patch
 */
#define MULLE_OBJC_UNICODE_FOUNDATION_VERSION  ((0UL << 20) | (21 << 8) | 2)


static inline unsigned int   MulleObjCUnicodeFoundation_get_version_major( void)
{
   return( MULLE_OBJC_UNICODE_FOUNDATION_VERSION >> 20);
}


static inline unsigned int   MulleObjCUnicodeFoundation_get_version_minor( void)
{
   return( (MULLE_OBJC_UNICODE_FOUNDATION_VERSION >> 8) & 0xFFF);
}


static inline unsigned int   MulleObjCUnicodeFoundation_get_version_patch( void)
{
   return( MULLE_OBJC_UNICODE_FOUNDATION_VERSION & 0xFF);
}


MULLE_OBJC_UNICODE_FOUNDATION_GLOBAL
uint32_t   MulleObjCUnicodeFoundation_get_version( void);


#import "_MulleObjCUnicodeFoundation-export.h"



// define some "missing" functions for code completion
static inline int   mulle_unicode16_is_privatecharacter( uint16_t c)
{
   return( mulle_utf16_is_privatecharacter( c));
}


static inline int   mulle_unicode32_is_privatecharacter( int32_t c)
{
   return( mulle_utf32_is_privatecharacter( c));
}


static inline int   mulle_unicode_is_privatecharacterplane( unsigned int plane)
{
   return( mulle_utf_is_privatecharacterplane( plane));
}


#ifdef __has_include
# if __has_include( "_MulleObjCUnicodeFoundation-versioncheck.h")
#  include "_MulleObjCUnicodeFoundation-versioncheck.h"
# endif
#endif

#endif
