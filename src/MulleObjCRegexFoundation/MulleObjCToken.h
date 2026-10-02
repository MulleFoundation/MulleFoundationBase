//
//  MulleObjCToken.h
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK. All rights reserved.
//
//  A table driven tokenizer, in two objects because they have different
//  lifetimes: a MulleObjCTokenSet is the table (the rules, what they are called,
//  which are skipped, and the dispatch that falls out of the declared first
//  characters) and a MulleObjCTokenizer is a cursor into one text with one
//  table. There is one cursor per text - or per line.
//
//  This file and its four siblings (MulleObjCTokenRule, MulleObjCTokenProblem,
//  MulleObjCTokenSet, MulleObjCTokenizer) contain no knowledge of any language.
//  They started as one cmake specific file in a tool and were split once the
//  table turned out to be the only cmake part of it; see CMakeObjC's
//  CMakeTokens.h for the subclass that supplies the cmake rules. They live here
//  because a table of patterns is the layer above MulleObjCPattern: nothing
//  static, state in objects.
//
//  Four semantics, each of them paid for by the hand-written character walks
//  this replaces:
//
//  1. Rules are tried in table order and the first match at the cursor wins. So
//     the table is *ordered*, and a rule that an earlier rule already covers can
//     never fire - which -problem reports, because a dead rule is a silent
//     mis-lex and not something anyone would notice.
//  2. Positions are the result. Every token carries its NSRange in the source
//     and nothing is sliced out while scanning; -stringInText: is there for the
//     caller that wants characters. (The walks this replaces built one NSString
//     per character, with -substringWithRange:NSMakeRange( i, 1).)
//  3. A skip rule - whitespace, comments - still reports its range, so offsets
//     keep lining up with the original text, and its *name* is still there for
//     the caller that wants to distinguish them. Skipping is a property of the
//     token, not a gap in the stream.
//  4. The rule table is instance data, passed to the initializer. There is no
//     global registry and no shared mutable state, so two tools can hold
//     different tables and two tokenizers can coexist.
//
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#import "import.h"


//
// One token: which rule matched, and where. No characters unless asked for.
//
@interface MulleObjCToken : NSObject

@property( readonly, copy) NSString   *name;          // the rule that matched
@property( readonly) NSRange          range;          // always, into the text
@property( readonly) NSRange          contentRange;   // without a quote pair
@property( readonly, assign) BOOL     isSkip;         // from the rule

+ (instancetype) tokenWithName:(NSString *) name
                         range:(NSRange) range
                  contentRange:(NSRange) contentRange
                        isSkip:(BOOL) isSkip;

// the characters, on demand rather than during the scan
- (NSString *) stringInText:(NSString *) text;

// the characters without the surrounding quotes, for a Content rule
- (NSString *) contentInText:(NSString *) text;

@end
