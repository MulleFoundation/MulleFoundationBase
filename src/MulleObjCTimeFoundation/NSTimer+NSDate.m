/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSTimer.m is a part of MulleFoundation
 *
 *  Copyright (C) 2019 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */

#import "NSTimer+NSDate.h"

#import "import-private.h"

#import "NSDate.h"

#include <math.h>  // for INFINITY



@implementation NSTimer( NSDate)


+ (instancetype) timerWithTimeInterval:(NSTimeInterval) timeInterval
                            invocation:(NSInvocation *) invocation
                               repeats:(BOOL) repeats
{
   NSTimeInterval   fireTimeInterval;

   if( ! invocation)
      return( nil);

   // true to spec!
   timeInterval     = timeInterval <= 0.0 ? _NSTIMER_MIN_TIMEINTERVAL : timeInterval;
   fireTimeInterval = _NSTimeIntervalNow() + timeInterval;
   return( [[[self alloc] mulleInitWithFireTimeInterval:fireTimeInterval
                                         repeatInterval:repeats ? timeInterval : 0.0
                                             invocation:invocation] autorelease]);
}


+ (instancetype) timerWithTimeInterval:(NSTimeInterval) timeInterval
                                target:(id) target
                              selector:(SEL) selector
                              userInfo:(id) userInfo
                               repeats:(BOOL) repeats
{
   NSTimeInterval   fireTimeInterval;

   if( ! target || ! selector)
      return( nil);

   // true to spec!
   timeInterval     = timeInterval <= 0.0 ? _NSTIMER_MIN_TIMEINTERVAL : timeInterval;
   fireTimeInterval = _NSTimeIntervalNow() + timeInterval;
   return( [[[self alloc] mulleInitWithFireTimeInterval:fireTimeInterval
                                         repeatInterval:repeats ? timeInterval : 0.0
                                                 target:target
                                               selector:selector
                                               userInfo:userInfo
                             fireUsesUserInfoAsArgument:NO] autorelease]);
}


- (instancetype) initWithFireDate:(NSDate *) date
                         interval:(NSTimeInterval) repeatInterval
                           target:(id) target
                         selector:(SEL) selector
                         userInfo:(id) userInfo
                          repeats:(BOOL) repeats
{
   NSTimeInterval   fireTimeInterval;

   fireTimeInterval = [date timeIntervalSinceReferenceDate];
   if( repeats)
      repeatInterval = repeatInterval <= 0.0 ? _NSTIMER_MIN_TIMEINTERVAL : repeatInterval;
   else
      repeatInterval = 0.0;
   return( [self mulleInitWithFireTimeInterval:fireTimeInterval
                                repeatInterval:repeatInterval
                                        target:target
                                      selector:selector
                                      userInfo:userInfo
                    fireUsesUserInfoAsArgument:NO]);
}



- (instancetype) mulleInitWithFireTimeInterval:(NSTimeInterval) timeInterval
                                repeatInterval:(mulle_relativetime_t) repeatInterval
                                    invocation:(NSInvocation *) invocation
{
   NSTimeInterval   fireTimeInterval;

   if( ! invocation)
   {
      [self release];
      return( nil);
   }

   // true to spec!
   timeInterval     = timeInterval <= 0.0 ? _NSTIMER_MIN_TIMEINTERVAL : timeInterval;
   fireTimeInterval = _NSTimeIntervalNow() + timeInterval;

   self->_interval.calendar = fireTimeInterval;
   self->_repeatInterval    = repeatInterval < 0.0 ? _NSTIMER_MIN_TIMEINTERVAL : repeatInterval;
   self->_o.invocation      = [invocation retain];

   return( self);
}


- (instancetype) mulleInitWithFireTimeInterval:(NSTimeInterval) timeInterval
                                repeatInterval:(mulle_relativetime_t) repeatInterval
                                        target:(id) target
                                      selector:(SEL) sel
                                      userInfo:(id) userInfo
                    fireUsesUserInfoAsArgument:(BOOL) flag
{
   if( ! target || ! sel)
   {
      [self release];
      return( nil);
   }

   self->_interval.calendar = timeInterval;
   self->_repeatInterval    = repeatInterval < 0.0 ? _NSTIMER_MIN_TIMEINTERVAL : repeatInterval;
   self->_selector          = sel;
   self->_userInfo          = [userInfo retain];
   self->_o.target          = [target retain];
   self->_passUserInfo      = flag;

   return( self);
}


- (NSDate *) fireDate
{
   if( _isRelative)
      return( nil);
   return( [NSDate dateWithTimeIntervalSinceReferenceDate:_interval.calendar]);
}



- (NSTimeInterval) mulleFireTimeInterval
{
   if( _isRelative)
      return( -INFINITY);
   return( _interval.calendar);
}


//- (void) setFireDate:(NSDate *) date
//{
//#ifdef DEBUG
//   fprintf( stderr, "Not possible in mulle-objc\n");
//   abort();
//#endif
//}


// If the timer is non-repeating, returns 0 even if a time interval was set.

- (NSTimeInterval) timeInterval
{
   return( _repeatInterval);
}


@end
