#ifdef __MULLE_OBJC__

#import "MulleObjCLoader+MulleObjCTimeFoundation.h"


@implementation MulleObjCLoader( MulleObjCTimeFoundation)

//
// The file objc-loader.inc is generated by the mulle-objc-developer
// tool set automatically during a cmake build. Creation of this file can 
// be turned off in CMakeLists.txt with CREATE_OBJC_LOADER_INC=OFF
//
+ (struct _mulle_objc_dependency *) dependencies
{
   static struct _mulle_objc_dependency   dependencies[] =
   {
#include "objc-loader.inc"

      { MULLE_OBJC_NO_CLASSID, MULLE_OBJC_NO_CATEGORYID }
   };

   return( dependencies);
}

@end

#endif


/*
 * extension : mulle-objc/objc
 * directory : project-oneshot/library
 * template  : .../MulleObjCLoader+PROJECT_NAME.PROJECT_EXTENSION
 * Suppress this comment with `export MULLE_SDE_GENERATE_FILE_COMMENTS=NO`
 */
