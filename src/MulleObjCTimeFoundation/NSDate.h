//
//  NSDate.h
//  MulleObjCValueFoundation
//
//  Copyright (c) 2011 Nat! - Mulle kybernetiK.
//  Copyright (c) 2011 Codeon GmbH.
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


#import "NSDateFactory.h"

#import "NSTimeInterval.h"


//
// this is a class cluster with one subclass here for the regular NSDate
// and NSCalendarDate in a future library.
//
@interface NSDate : NSObject < MulleObjCClassCluster, NSDateFactory, NSCopying>
{
}


+ (instancetype) dateWithTimeIntervalSince1970:(NSTimeInterval) seconds;
+ (instancetype) dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval) seconds;
+ (instancetype) distantFuture;
+ (instancetype) distantPast;

- (instancetype) initWithTimeInterval:(NSTimeInterval) seconds
                            sinceDate:(NSDate *) refDate;
- (instancetype) initWithTimeIntervalSince1970:(NSTimeInterval) seconds;

//
// MEMO: if other is nil, then this will return "same", though counterintuitive
//       at first, this makes [date compare:nil] and [nil compare:date] return
//       the same value. Gotta check how NSNumber and NSString think about this
//
- (NSComparisonResult) compare:(id) other;
- (instancetype) dateByAddingTimeInterval:(NSTimeInterval) seconds;
- (NSDate *) earlierDate:(NSDate *) other;
- (NSDate *) laterDate:(NSDate *) other;
- (NSTimeInterval) timeIntervalSince1970;
- (NSTimeInterval) timeIntervalSinceDate:(NSDate *) other;

@end

@interface NSDate ( Subclasses)

- (instancetype) initWithTimeIntervalSinceReferenceDate:(NSTimeInterval) seconds;
- (NSTimeInterval) timeIntervalSinceReferenceDate;

@end


@interface NSDate ( Future)

// obsolete, use +object, keep typed
+ (NSDate *) date;
+ (NSTimeInterval) timeIntervalSinceReferenceDate;

@end
