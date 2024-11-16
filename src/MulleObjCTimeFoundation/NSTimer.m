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
   fprintf( stderr, "%s %s\n", [self UTF8String], __PRETTY_FUNCTION__);
#endif

   [self invalidate];
}


// this is clobbered by -[NSTimer(NSRunLoop) invalidate]
// if you change code here also change it there, it's crap but
// want to stay compatible here
- (void) invalidate
{
#ifdef NSTIMER_DEBUG
   fprintf( stderr, "%s %s\n", [self UTF8String], __PRETTY_FUNCTION__);
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
   fprintf( stderr, "%s %s\n", [self UTF8String], __PRETTY_FUNCTION__);
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

