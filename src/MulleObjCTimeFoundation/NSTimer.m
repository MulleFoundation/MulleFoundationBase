//
//  NSTimer.m
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
#import "NSTimer.h"

#import "import-private.h"

#include <math.h>  // for INFINITY


//#define NSTIMER_DEBUG   1

@implementation NSTimer


+ (instancetype) mulleTimerWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                     repeatInterval:(mulle_relativetime_t) repeatSeconds
                                        invocation:(NSInvocation *) invocation
{
   return( [[[self alloc] mulleInitWithRelativeTimeInterval:seconds
                                             repeatInterval:repeatSeconds
                                                 invocation:invocation] autorelease]);
}


+ (instancetype) mulleTimerWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                     repeatInterval:(mulle_relativetime_t) repeatSeconds
                                             target:(id) target
                                           selector:(SEL) sel
                                           userInfo:(id) userInfo
                         fireUsesUserInfoAsArgument:(BOOL) flag
{
   return( [[[self alloc] mulleInitWithRelativeTimeInterval:seconds
                                             repeatInterval:repeatSeconds
                                                     target:target
                                                   selector:sel
                                                   userInfo:userInfo
                                 fireUsesUserInfoAsArgument:flag] autorelease]);
}


+ (instancetype) mulleTimerWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                     repeatInterval:(mulle_relativetime_t) repeatSeconds
                                           callback:(NSTimerCallback_t) callback
                                           userInfo:(id) userInfo
{
   return( [[[self alloc] mulleInitWithRelativeTimeInterval:seconds
                                             repeatInterval:repeatSeconds
                                                   callback:callback
                                                   userInfo:userInfo] autorelease]);
}


/*
 * Relative timers for use with MulleUI
 */
- (instancetype) mulleInitWithRelativeTimeInterval:(mulle_relativetime_t) timeInterval
                                    repeatInterval:(mulle_relativetime_t) repeatInterval
                                        invocation:(NSInvocation *) invocation
{
   if( ! invocation)
   {
      [self release];
      return( nil);
   }

   self->_interval.relative = timeInterval <= 0.0 ? _NSTIMER_MIN_TIMEINTERVAL : timeInterval;
   self->_repeatInterval    = repeatInterval < 0.0 ? 0.0 : repeatInterval;
   self->_o.invocation      = [invocation retain];
   self->_isRelative        = YES;

   return( self);
}


- (instancetype) mulleInitWithRelativeTimeInterval:(mulle_relativetime_t) timeInterval
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

   self->_interval.relative = timeInterval <= 0.0 ? _NSTIMER_MIN_TIMEINTERVAL : timeInterval;
   self->_repeatInterval    = repeatInterval < 0.0 ? 0.0 : repeatInterval;
   self->_selector          = sel;
   self->_userInfo          = [userInfo retain];
   self->_o.target          = [target retain];
   self->_passUserInfo      = flag;
   self->_isRelative        = YES;

   return( self);
}


- (instancetype) mulleInitWithRelativeTimeInterval:(mulle_relativetime_t) timeInterval
                                    repeatInterval:(mulle_relativetime_t) repeatInterval
                                          callback:(NSTimerCallback_t) callback
                                          userInfo:(id) userInfo
{
   if( ! callback)
   {
      [self release];
      return( nil);
   }

   self->_interval.relative = timeInterval <= 0.0 ? _NSTIMER_MIN_TIMEINTERVAL : timeInterval;
   self->_repeatInterval    = repeatInterval < 0.0 ? 0.0 : repeatInterval;
   self->_callback          = callback;
   self->_userInfo          = [userInfo retain];
   self->_isRelative        = YES;

   return( self);
}


- (void) dealloc
{
   [_userInfo release];
   [self->_o.target  release];

   [super dealloc];
}


- (BOOL) isValid
{
   return( self->_o.target != nil || self->_callback != NULL);
}


- (void) finalize
{
#ifdef NSTIMER_DEBUG
   mulle_fprintf( stderr, "%s %s\n", [self UTF8String], __PRETTY_FUNCTION__);
#endif

   [self invalidate];
}


// this is clobbered by -[NSTimer(NSRunLoop) invalidate]
// if you change code here also change it there, it's crap but
// want to stay compatible here
- (void) invalidate
{
#ifdef NSTIMER_DEBUG
   mulle_fprintf( stderr, "%s %s\n", [self UTF8String], __PRETTY_FUNCTION__);
#endif
   [self->_o.target autorelease];
   self->_o.target = nil;
   [self->_userInfo autorelease];
   self->_userInfo = nil;
   self->_selector = 0;
   self->_callback = NULL;
}


// finalize does all
// - (void) dealloc
// {
//    [self->_o.target release];
//    [self->_userInfo release];
//    [super dealloc];
// }


- (void) fire
{
   id   argument;

#ifdef NSTIMER_DEBUG
   mulle_fprintf( stderr, "%s %s\n", [self UTF8String], __PRETTY_FUNCTION__);
#endif
   //
   // usually NSTimer passes self as argument and then you need to
   // get userInfo from it, but here you can set the flag
   //
   if( self->_selector)
   {
      argument = _passUserInfo ? _userInfo : self;
      MulleObjCObjectPerformSelector( self->_o.target, self->_selector, argument);
   }
   else
   {
      if( self->_callback)
         (*self->_callback)( self, _userInfo);
      else
         [self->_o.invocation invoke];
   }

   if( self->_repeatInterval == 0.0)
      [self invalidate];
}


- (id) userInfo
{
   return( _userInfo);
}


- (BOOL) mulleIsRelativeTimer
{
   return( _isRelative);
}


- (mulle_relativetime_t) mulleRepeatTimeInterval
{
   return( _repeatInterval);
}


- (mulle_relativetime_t) mulleRelativeTimeInterval
{
   return( _isRelative ? _interval.relative : -INFINITY);
}


- (BOOL) mulleFiresWithUserInfoAsArgument
{
   return( _passUserInfo);
}


// asking the invocation is more convenient for NSRunLoop
- (id) mulleTarget
{
   return( _selector ? _o.target : [_o.invocation target]);
}


// asking the invocation is more convenient for NSRunLoop
- (SEL) mulleSelector;
{
   return( _selector ? _selector : [_o.invocation selector]);
}


- (NSTimerCallback_t *) mulleTimerCallback
{
   return( _callback);
}


@end

