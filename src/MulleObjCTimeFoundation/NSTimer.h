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
#import "import.h"


#import "NSTimeInterval.h"



// NSTimer in MulleObjC is dual use. It can be used for the standard
// NSRunLoop but can also be used by UIApplication, which doesn't use
// a NSRunLoop (yet). An NSTimer is immutable (The invocation passed in
// could be mutable though)
//
// When you use an "absolute time" with the fireTimeInterval methods,
// you must add the timer immediately to a runloop or UIApplication,
// else you get skew.
//
// Candidate for a class-cluster! Could be immutable, if it weren't for
// -invalidate. Could make this ThreadSafe though...
//
@class NSTimer;
@class NSInvocation;



#define _NSTIMER_MIN_TIMEINTERVAL   0.0001


typedef void   NSTimerCallback_t( NSTimer *, id userInfo);


//
// The timer is immutable and the invocation is private, but the target and
// userinfo can change behind our backs. So the contents are not completely
// immutable.
//
@interface NSTimer : NSObject < MulleObjCImmutableProtocols>
{
   union
   {
      mulle_relativetime_t   relative;
      NSTimeInterval         calendar;
   } _interval;

   mulle_relativetime_t   _repeatInterval;
   NSTimerCallback_t      *_callback;
   union
   {
      id               target;
      NSInvocation     *invocation;
   } _o;
   SEL                 _selector;  // if 0: use _target as _invocation
   id                  _userInfo;
   char                _passUserInfo;
   char                _isRelative;
}

@property( readonly, retain) id   userInfo;


//
// used to create a NSTimer that is relative. Like 2s in the future. If the
// computer sleeps inbetween, that time shouldn't count towards the two
// seconds delay.
//
// mulleFireTimeInterval will be 0.0, but timeInterval will be set
// relative NSTimer are not mutable
//
+ (instancetype) mulleTimerWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                     repeatInterval:(mulle_relativetime_t) repeatSeconds
                                         invocation:(NSInvocation *) invocation;

+ (instancetype) mulleTimerWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                     repeatInterval:(mulle_relativetime_t) repeatSeconds
                                             target:(id) target
                                           selector:(SEL) sel
                                           userInfo:(id) userInfo
                         fireUsesUserInfoAsArgument:(BOOL) flag;

+ (instancetype) mulleTimerWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                     repeatInterval:(mulle_relativetime_t) repeatSeconds
                                           callback:(NSTimerCallback_t) callback
                                           userInfo:(id) userInfo;


- (instancetype) mulleInitWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                    repeatInterval:(mulle_relativetime_t) repeatSeconds
                                       invocation:(NSInvocation *) invocation;

- (instancetype) mulleInitWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                    repeatInterval:(mulle_relativetime_t) repeatSeconds
                                            target:(id) target
                                          selector:(SEL) sel
                                          userInfo:(id) userInfo
                        fireUsesUserInfoAsArgument:(BOOL) flag;

- (instancetype) mulleInitWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                    repeatInterval:(mulle_relativetime_t) repeatSeconds
                                          callback:(NSTimerCallback_t) callback
                                          userInfo:(id) userInfo;

- (BOOL) isValid;
- (void) fire;

- (BOOL) mulleIsRelativeTimer;

- (mulle_relativetime_t) mulleRelativeTimeInterval;
- (mulle_relativetime_t) mulleRepeatTimeInterval;

@end



// useful for testing
@interface NSTimer( Private)

- (BOOL) mulleFiresWithUserInfoAsArgument;

- (id) mulleTarget;  // also target of invocation
- (SEL) mulleSelector; // also selector of invocation

- (NSTimerCallback_t *) mulleTimerCallback;

@end
