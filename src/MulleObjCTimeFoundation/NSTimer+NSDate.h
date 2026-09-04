//
//  NSTimer+NSDate.h
//  MulleObjCTimeFoundation
//
//  Copyright (c) 2022 Nat! - Mulle kybernetiK.
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
# if __has_include( "NSTimer.h")
#  import "NSTimer.h"
# endif
#endif

#import "import.h"

@class NSDate;


//
// Create calendar based "absolute" timers. These timers have a fixed
// fire date, where they fire. They are NSRunLoop timers.
// MEMO: it may be good (?) to leave out invocation, so NSTimer if completely
// immutable (?)
//
@interface NSTimer( NSDate)


+ (instancetype) timerWithTimeInterval:(NSTimeInterval) seconds
                            invocation:(NSInvocation *) invocation
                               repeats:(BOOL) repeats;

+ (instancetype) timerWithTimeInterval:(NSTimeInterval) seconds
                                target:(id) target
                              selector:(SEL) selector
                              userInfo:(id) userInfo
                               repeats:(BOOL) repeats;


- (instancetype) initWithFireDate:(NSDate *) date
                         interval:(NSTimeInterval) repeatSeconds
                           target:(id) target
                         selector:(SEL) selector
                         userInfo:(id) userInfo
                          repeats:(BOOL) repeats;

- (instancetype) mulleInitWithFireTimeInterval:(NSTimeInterval) timeInterval
                                repeatInterval:(mulle_relativetime_t) repeatSeconds
                                    invocation:(NSInvocation *) invocation;

- (instancetype) mulleInitWithFireTimeInterval:(NSTimeInterval) timeInterval
                                repeatInterval:(mulle_relativetime_t) repeatInterval
                                        target:(id) target
                                      selector:(SEL) sel
                                      userInfo:(id) userInfo
                    fireUsesUserInfoAsArgument:(BOOL) flag;


- (NSDate *) fireDate;            // nil for relative timer

// returns -INFINITY for relative timers, otherwise the fireDate as
// a NSTimeInterval
- (NSTimeInterval) mulleFireTimeInterval;

- (NSTimeInterval) timeInterval;  // this is the repeat interval!!!!

@end
