//
//  NSString+Regex.m
//  MulleStringExpansion
//
//  Copyright (c) 2023 Nat! - Mulle kybernetiK.
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
// prefer a local NSString over one in import.h
#ifdef __has_include
# if __has_include( "NSString.h")
#  import "NSString.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

// this is basically an extension of NSStringCompareOptions
typedef   NS_ENUM( NSUInteger, MulleObjCPatternOptions)
{
   MulleObjCWildcardsShortestPath = 0x3000,              // #1#  // also sets MulleWildcards
   MulleObjCWildcards             = 0x1000,              // #2#
   MulleObjCSedPattern            = 0x4000,              // use \( instead of ( for grouping
   MulleObjCAnchoredSearch        = NSAnchoredSearch,
   MulleObjCBackwardsSearch       = NSBackwardsSearch
};


@interface NSString( Regex)

- (NSRange) mulleRangeOfPattern:(NSString *) pattern;

- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution;

// variations
- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution
                                     options:(MulleObjCPatternOptions) options
                                       range:(NSRange) range;

- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution
                                     options:(MulleObjCPatternOptions) options;

- (NSRange) mulleRangeOfPattern:(NSString *) pattern
                        options:(MulleObjCPatternOptions) options
                          range:(NSRange) range;

- (NSRange) mulleRangeOfPattern:(NSString *) pattern
                        options:(MulleObjCPatternOptions) options;


@end


// #1#
//
// find bash like wildcards * ? [a-z] [^a-z]. This will try to keep the matched
// range as short as possible. E.g.  x*y is the same as just x
// e.g. a*c will ony match abc of abcabc. There is no grouping with wildcards,
// so you can only replace wholesale.
//

// #2#
//
// find bash like wildcards * ? [a-z] [^a-z]. This will extend as far as possible
// e.g. a*c will match abcabc fully
//