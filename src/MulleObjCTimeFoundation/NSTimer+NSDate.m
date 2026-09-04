//
//  NSTimer+NSDate.m
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
//   mulle_fprintf( stderr, "Not possible in mulle-objc\n");
//   abort();
//#endif
//}


// If the timer is non-repeating, returns 0 even if a time interval was set.

- (NSTimeInterval) timeInterval
{
   return( _repeatInterval);
}


@end
