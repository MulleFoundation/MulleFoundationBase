//
//  MulleObjCTokenProblem.h
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK. All rights reserved.
//
//  Something a scan found that the table did not anticipate. See
//  MulleObjCToken.h for the reasoning.
//
//  A problem is not an error. A table declares which characters can start which
//  rule, and this is where that declaration did not hold for the text in hand.
//  The scan still completes, and the answer it produced may still be right; what
//  is missing is any reason to believe it. So it comes back as a value the
//  caller can count, inspect and report, rather than as an exception that would
//  end the scan at the first one and leave the rest unexamined.
//
//  Which is also why the wording lives here and nowhere else: `text` is derived
//  from `kind` and `count` at construction, so a report cannot disagree with the
//  problem it describes. The owner of the set knows which file it scanned, so it
//  adds that itself - this object deliberately has no idea where it came from.
//
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#import "import.h"


typedef enum
{
   //
   // A character no rule could lex: every candidate was tried at the cursor and
   // none matched, so the tokenizer had to step over it.
   //
   MulleObjCTokenProblemUnrecognizedCharacter = 1,
   //
   // A rule matched, but no rule had declared that it can start there. Correct
   // - the fallback did the work - and it means the table is describing less of
   // the language than it is actually handling.
   //
   MulleObjCTokenProblemUndeclaredStart        = 2
} MulleObjCTokenProblemKind;


@interface MulleObjCTokenProblem : NSObject

@property( readonly, assign) MulleObjCTokenProblemKind kind;
// how many times it happened, not how many problems were found
@property( readonly, assign) NSUInteger                count;
// one clause, no file name and no trailing punctuation: the caller joins them
@property( readonly, copy)   NSString                 *text;

- (instancetype) initWithKind:(MulleObjCTokenProblemKind) kind
                        count:(NSUInteger) count;

+ (instancetype) problemWithKind:(MulleObjCTokenProblemKind) kind
                           count:(NSUInteger) count;

@end
