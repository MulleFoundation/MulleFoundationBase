//
//  MulleObjCPatternMatch.h
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


//
// The mulle-regex engine provides the whole match plus up to nine capture
// groups. MULLE_UTF32REGEX_NSUBEXP is 10, where index 0 is the whole match.
//
#define MULLE_OBJC_PATTERN_MAX_CAPTURE_GROUPS   9


//
// A single match of a MulleObjCPattern, including its capture groups.
//
@interface MulleObjCPatternMatch : NSObject
{
   NSRange      _ranges[ MULLE_OBJC_PATTERN_MAX_CAPTURE_GROUPS + 1];
   NSUInteger   _count;
   NSString     *_string;
}

+ (instancetype) matchWithString:(NSString *) string
                          ranges:(NSRange *) ranges
                           count:(NSUInteger) count;

- (instancetype) initWithString:(NSString *) string
                         ranges:(NSRange *) ranges
                          count:(NSUInteger) count;

//
// group 0 is the whole match, so a pattern with n groups yields n + 1 ranges
//
- (NSUInteger) numberOfCaptureGroups;

- (NSRange) range;
- (NSRange) rangeOfCaptureGroupAtIndex:(NSUInteger) index;

- (NSString *) substring;
- (NSString *) substringOfCaptureGroupAtIndex:(NSUInteger) index;

//
// the string, that was searched
//
- (NSString *) string;

@end


//
// The range of a group, that did not participate in the match, is NSNotFound.
// -substringOfCaptureGroupAtIndex: returns nil for such a group.
//
