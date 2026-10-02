//
//  MulleObjCPatternEnumerator.h
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


@class MulleObjCPattern;


//
// Enumerates the matches of a MulleObjCPattern in a string lazily, one match
// at a time. It conforms to NSFastEnumeration, so
//
//    for( MulleObjCPatternMatch *match in
//            [pattern matchEnumeratorInString:@"VfL Bochum 1848"])
//
// works as expected. -nextObject yields the matches one by one as well.
//
// The string is converted to unichar once, so enumerating a large string is
// not quadratic.
//
@interface MulleObjCPatternEnumerator : NSObject < NSFastEnumeration >
{
   MulleObjCPattern   *_pattern;
   NSString           *_string;
   NSRange            _range;
   NSUInteger         _end;
   NSUInteger         _length;
   NSUInteger         _location;
   NSUInteger         _mutations;
   unichar            *_characters;
}

+ (instancetype) enumeratorWithPattern:(MulleObjCPattern *) pattern
                                string:(NSString *) string
                                 range:(NSRange) range;

- (instancetype) initWithPattern:(MulleObjCPattern *) pattern
                          string:(NSString *) string
                           range:(NSRange) range;

// returns nil, when all matches have been returned
- (MulleObjCPatternMatch *) nextObject;

// the total number of matches in the range, independent of how far the
// enumeration has progressed
- (NSUInteger) count;

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *) state
                                   objects:(id *) objects
                                     count:(NSUInteger) count;

@end
