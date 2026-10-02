//
//  MulleObjCToken.m
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK. All rights reserved.
//
//  The token declared in MulleObjCToken.h.
//
#import "MulleObjCToken.h"

#import "import-private.h"


@implementation MulleObjCToken

+ (instancetype) tokenWithName:(NSString *) name
                         range:(NSRange) range
                  contentRange:(NSRange) contentRange
                        isSkip:(BOOL) isSkip
{
   MulleObjCToken   *token;

   token = [[self alloc] init];
   token->_name         = [name copy];
   token->_range        = range;
   token->_contentRange = contentRange;
   token->_isSkip       = isSkip;
   return( [token autorelease]);
}


- (void) finalize
{
   [_name autorelease];
   _name = nil;

   [super finalize];
}


- (NSString *) stringInText:(NSString *) text
{
   return( [text substringWithRange:_range]);
}


- (NSString *) contentInText:(NSString *) text
{
   return( [text substringWithRange:_contentRange]);
}


- (NSString *) description
{
   return( [NSString stringWithFormat:@"<%@ %lu+%lu>",
                     _name, (unsigned long) _range.location, (unsigned long) _range.length]);
}

@end
