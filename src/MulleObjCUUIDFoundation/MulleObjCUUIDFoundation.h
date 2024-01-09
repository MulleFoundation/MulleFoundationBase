#import "import.h"

/*
 *  (c) 2022 nat ORGANIZATION
 *
 *  version:  major, minor, patch
 */
#define MULLE_OBJC_UUID_FOUNDATION_VERSION  ((0UL << 20) | (0 << 8) | 3)


static inline unsigned int   MulleObjCUUIDFoundation_get_version_major( void)
{
   return( MULLE_OBJC_UUID_FOUNDATION_VERSION >> 20);
}


static inline unsigned int   MulleObjCUUIDFoundation_get_version_minor( void)
{
   return( (MULLE_OBJC_UUID_FOUNDATION_VERSION >> 8) & 0xFFF);
}


static inline unsigned int   MulleObjCUUIDFoundation_get_version_patch( void)
{
   return( MULLE_OBJC_UUID_FOUNDATION_VERSION & 0xFF);
}


MULLE_OBJC_UUID_FOUNDATION_GLOBAL
uint32_t   MulleObjCUUIDFoundation_get_version( void);


#import "NSUUID.h"

