//
//  NSObject+NSString.h
//  MulleObjCValueFoundation
//
//  Created by Nat! on 09.05.17.
//  Copyright © 2017 Mulle kybernetiK. All rights reserved.
//

#import "import.h"



@class NSString;


@interface NSObject( NSString)

- (NSString *) description;

//
// mulleTestDescription can be the same as description, but shouldn't present
// any pointer addresses or other text that varies between test runs
//
- (NSString *) mulleTestDescription;
- (char *) UTF8String;
- (NSComparisonResult) mulleCompareDescription:(id) other;

// this is intended to possibly output quoted for NSNumber and NSString
// and "as is" for all others
- (NSString *) mulleQuotedDescriptionIfNeeded;

@end



