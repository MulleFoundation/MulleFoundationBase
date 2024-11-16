#ifndef mulle_objc_unicode_foundation_h__
#define mulle_objc_unicode_foundation_h__

#import "import.h"

#include <stdint.h>

/*
 *  (c) 2020 nat ORGANIZATION
 *
 *  version:  major, minor, patch
 */
#define MULLE_OBJC_UNICODE_FOUNDATION_VERSION  ((0UL << 20) | (20 << 8) | 5)


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
