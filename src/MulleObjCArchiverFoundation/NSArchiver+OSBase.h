//
//  NSArchiver+Posix.h
//  MulleObjCPosixFoundation
//
//  Created by Nat! on 18.04.16.
//  Copyright © 2016 Mulle kybernetiK. All rights reserved.
//

#import "NSArchiver.h"


@interface NSArchiver (OSBase)

+ (BOOL) archiveRootObject:(NSObject *) rootObject
                    toFile:(NSString *) path;

@end
