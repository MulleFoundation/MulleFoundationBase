/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTimer.h is a part of MulleFoundation
 *
 *  Copyright (C)  2019 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#import "NSTimer.h"


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


