//
//  NSString+Search.h
//  MulleObjCStandardFoundation
//
//  Copyright (c) 2016 Nat! - Mulle kybernetiK.
//  Copyright (c) 2016 Codeon GmbH.
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
#import "import.h"

@class NSCharacterSet;


struct MulleStringCharacterFunctions
{
   int       (*isdigit)( unichar);
   int       (*iszero)( unichar);
   int       (*isspace)( unichar);
   unichar   (*tolower)( unichar);
   unichar   (*toupper)( unichar);
};


@interface NSString( Search)

// install during +load or +initialize only
+ (void) setStringCharacterFunctions:(struct MulleStringCharacterFunctions *) converters;
+ (struct MulleStringCharacterFunctions *) stringCharacterFunctions;

- (NSComparisonResult) compare:(id) other;
- (NSComparisonResult) compare:(id) other
                       options:(NSStringCompareOptions) mask;

- (NSComparisonResult) caseInsensitiveCompare:(NSString *) other;

- (NSRange) rangeOfString:(NSString *) other
                  options:(NSStringCompareOptions) options;

- (NSRange) rangeOfString:(NSString *) other
                  options:(NSStringCompareOptions) options
                    range:(NSRange) range;

- (NSRange) rangeOfString:(NSString *) other;

- (BOOL) containsString:(NSString *) s;

- (NSComparisonResult) compare:(NSString *) other
                       options:(NSStringCompareOptions) options
                         range:(NSRange) range;

// finds occurence
- (NSRange) rangeOfCharacterFromSet:(NSCharacterSet *) set
                            options:(NSStringCompareOptions) options
                              range:(NSRange) range;

- (NSRange) rangeOfCharacterFromSet:(NSCharacterSet *) set
                            options:(NSStringCompareOptions) options;

- (NSRange) rangeOfCharacterFromSet:(NSCharacterSet *) set;

- (NSString *) uppercaseString;
- (NSString *) lowercaseString;
- (NSString *) capitalizedString;

#pragma mark - mulle additions

//
// finds longest ranges from the start,
// use NSBackwardsSearch to find Suffix
// It's always NSAnchoredSearch implicitly!
//
// hint: to find characters not in set, compare returned range.length with
// input range.length. If it doesn't match, there you are
//
- (NSString *) mulleDecapitalizedString;

//
// match until a character matches no more
// so "bbaa" should return range of bb for set of 'b'
//
- (NSRange) mulleRangeOfCharactersFromSet:(NSCharacterSet *) set
                                  options:(NSStringCompareOptions) options
                                    range:(NSRange) range;

- (NSUInteger) mulleCountOccurrencesOfCharactersFromSet:(NSCharacterSet *) set
                                                 range:(NSRange) range;


- (NSString *) stringByReplacingOccurrencesOfString:(NSString *) s
                                         withString:(NSString *) replacement;
- (NSString *) stringByReplacingOccurrencesOfString:(NSString *) s
                                         withString:(NSString *) replacement
                                            options:(NSUInteger) options
                                              range:(NSRange) range;
- (NSString *) stringByReplacingCharactersInRange:(NSRange) range
                                       withString:(NSString *) replacement;

// for MulleObjCUnicode to use
@end


@interface NSObject( MulleCompareDescription)

- (NSComparisonResult) mulleCompareDescription:(id) other;;

@end

