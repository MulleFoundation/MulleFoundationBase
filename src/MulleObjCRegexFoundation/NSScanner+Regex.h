//
//  NSScanner+Regex.h
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
// prefer a local NSScanner over one in import.h
#ifdef __has_include
# if __has_include( "NSScanner.h")
#  import "NSScanner.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

#import "MulleObjCPattern.h"
#import "MulleObjCPatternMatch.h"


//
// Pattern scanning: what NSScanner does, but with a language instead of a
// character set or a literal. -scanString: bounds who can match, -scanPattern:
// asks whether a pattern matches at the cursor - the same question with a much
// larger answer - and hands back the match, so the capture groups come with it.
//
// Three things are deliberate and worth knowing:
//
//  1. The pattern has to match *starting at the cursor*. The engine searches
//     forward, so a pattern whose first match lies further ahead is not a match
//     here. Anchor the pattern to what it must be.
//  2. A zero length match is a failure as well, because a scan that consumes
//     nothing would never end. Together, 1 and 2 mean a successful
//     -scanPattern: always moves the scan location.
//  3. charactersToBeSkipped is applied first, as every other scan method does,
//     and those skipped characters stay consumed when the pattern then fails -
//     which is the behavior -scanCharactersFromSet: already has.
//
// The argument is a compiled MulleObjCPattern and not a pattern string on
// purpose: a string would be compiled on every call, which is the one thing a
// pattern is not for in a loop. Compile once and keep it.
//
@interface NSScanner( Regex)

// YES, and the scan location moves over the match
- (BOOL) scanPattern:(MulleObjCPattern *) pattern;

// the same, and hands out the match, so -range, -substring and
// -substringOfCaptureGroupAtIndex: come with it. nil when it returns NO
- (BOOL) scanPattern:(MulleObjCPattern *) pattern
           intoMatch:(MulleObjCPatternMatch **) matchp;

// advance until the pattern matches, gobbling up what was passed over, and leave
// the scan location at the match. NO - with the empty string - when the pattern
// never matches, like -scanUpToString: does it
- (BOOL) scanUpToPattern:(MulleObjCPattern *) pattern
              intoString:(NSString **) stringp;

@end
