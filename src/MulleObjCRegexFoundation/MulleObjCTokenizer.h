//
//  MulleObjCTokenizer.h
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK. All rights reserved.
//
//  The cursor. One text, one table, one position. See MulleObjCToken.h for the
//  reasoning.
//
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#import "import.h"

#import "MulleObjCToken.h"
#import "MulleObjCTokenSet.h"


@interface MulleObjCTokenizer : NSObject

- (instancetype) initWithText:(NSString *) text
                     tokenSet:(MulleObjCTokenSet *) tokenSet;

@property( readonly) NSString                *text;
@property( readonly, retain) MulleObjCTokenSet *tokenSet;
@property( readonly) NSUInteger              location;

//
// The counters of what no rule claimed are on *the set*, not here, and that is
// deliberate: a cursor is created per call and thrown away, so a count kept on
// one can never be read by anybody. See MulleObjCTokenSet.h.
//

// the table this tokenizer class speaks. Subclasses return their own set, which
// is what lets a caller say [CMakeTokenizer tokenizerWithText:] and not have to
// pass one. The default is an empty set.
+ (MulleObjCTokenSet *) defaultTokenSet;

+ (instancetype) tokenizerWithText:(NSString *) text;

//
// The same, with the table passed in. This is the one to use when you already
// hold a set: a set compiles each of its patterns once and then reuses them, so
// handing in the one the owner already has is what keeps a scan from compiling
// the table again per call. +tokenizerWithText: makes a fresh set every time,
// which is only right for a one-off scan.
//
+ (instancetype) tokenizerWithText:(NSString *) text
                         tokenSet:(MulleObjCTokenSet *) tokenSet;

- (void) setLocation:(NSUInteger) location;

// every token, including the skip rules. nil at the end of the text
- (MulleObjCToken *) nextToken;

// the next token that is not a skip rule, or nil
- (MulleObjCToken *) nextSignificantToken;

@end
