//
//  MulleObjCPattern.h
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
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
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#import "import.h"

#import "MulleObjCPatternMatch.h"
#import "NSString+Regex.h"


@class MulleObjCPatternEnumerator;

// declared here, so that this header does not expose mulle-regex
struct mulle_utf32regex;


//
// A compiled regular expression, with capture groups and match enumeration.
//
// The pattern language and the options are the ones of
// NSString( Regex) -mulleRangeOfPattern:options:range:, which this class
// shares. Because mulle-regex converts pattern options (anchoring,
// wildcards, sed syntax) into the pattern itself, the options are baked in
// at compilation time and can not be varied per search.
//
// The engine works on the buffer handed to it. `^` therefore matches the
// start of each search and `$` the end of the searched range. When
// enumerating, `^` is consequently satisfied at every match start.
//
@interface MulleObjCPattern : NSObject
{
   struct mulle_utf32regex   *_regex;
   NSUInteger                _numberOfCaptureGroups;
}

+ (instancetype) patternWithString:(NSString *) pattern;
+ (instancetype) patternWithString:(NSString *) pattern
                           options:(MulleObjCPatternOptions) options;

// returns nil, if the pattern is malformed
- (instancetype) initWithString:(NSString *) pattern
                        options:(MulleObjCPatternOptions) options;

- (NSUInteger) numberOfCaptureGroups;

- (MulleObjCPatternMatch *) firstMatchInString:(NSString *) string;
- (MulleObjCPatternMatch *) firstMatchInString:(NSString *) string
                                          range:(NSRange) range;

- (NSArray *) matchesInString:(NSString *) string;
- (NSArray *) matchesInString:(NSString *) string
                        range:(NSRange) range;

- (NSUInteger) numberOfMatchesInString:(NSString *) string;
- (NSUInteger) numberOfMatchesInString:(NSString *) string
                                 range:(NSRange) range;

- (MulleObjCPatternEnumerator *) matchEnumeratorInString:(NSString *) string;
- (MulleObjCPatternEnumerator *) matchEnumeratorInString:(NSString *) string
                                                   range:(NSRange) range;

//
// The template understands `&` for the whole match, `\1` to `\9` for the
// capture groups and `\0nnn` for an octal character, exactly like
// -mulleStringByReplacingPattern:withString: does.
//
- (NSString *) stringByReplacingMatchesInString:(NSString *) string
                                    withTemplate:(NSString *) template;

- (NSString *) stringByReplacingMatchesInString:(NSString *) string
                                          range:(NSRange) range
                                    withTemplate:(NSString *) template;

@end


//
// #1#
//
// Internal. Used by MulleObjCPatternEnumerator, so that a string is
// converted to unichar only once per enumeration. Finds the match at or
// after *pLocation in the NUL terminated `characters`, writes up to ten
// group ranges (in characters coordinates) into `ranges` and advances
// *pLocation past the match. Returns NO and sets *pLocation to NSNotFound,
// if there is no more match at or before `end`.
//
@interface MulleObjCPattern( Private)

- (BOOL) mulleFindNextMatch:(NSRange *) ranges
                 characters:(unichar *) characters
                        end:(NSUInteger) end
                   location:(NSUInteger *) pLocation;

@end
