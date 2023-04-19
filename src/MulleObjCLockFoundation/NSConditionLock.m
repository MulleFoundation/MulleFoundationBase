/*
 *  MulleFoundation - the mulle-objc class library
 *
 *  NSConditionLock.m is a part of MulleFoundation
 *
 *  Copyright (C) 2011 Nat!, Mulle kybernetiK.
 *  All rights reserved.
 *
 *  Coded by Nat!
 *
 *  $Id$
 *
 */
#define _GNU_SOURCE

#import "NSConditionLock.h"

// other files in this library

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies
#include <math.h>  // for infinity


#ifdef MULLE_TEST
# define LOCK_DEBUG
#endif


@implementation NSConditionLock

- (instancetype) initWithCondition:(NSInteger) value
{
   [super init];

   _mulle_atomic_pointer_nonatomic_write( &_currentCondition, (void *) value);

#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ init -> %td\n",
                           [NSThread currentThread], self, [self condition]);
#endif
   return( self);
}


- (NSInteger) condition
{
   return( (NSUInteger) _mulle_atomic_pointer_read( &_currentCondition));
}


- (void) lockWhenCondition:(NSInteger) value
{
#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ lockWhenCondition:%td (%td)\n",
                           [NSThread currentThread], self, value, [self condition]);
#endif

   [self lock];

   while( value != (NSUInteger) _mulle_atomic_pointer_nonatomic_read( &_currentCondition))
      [self wait];

#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ lockWhenCondition:%td == success\n",
                           [NSThread currentThread], self, value);
#endif
}


- (void) mulleLockWhenNotCondition:(NSInteger) value
{
#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ mulleLockWhenNotCondition:%td (%td)\n",
                           [NSThread currentThread], self, value, [self condition]);
#endif

   [self lock];

   while( value == (NSUInteger) _mulle_atomic_pointer_nonatomic_read( &_currentCondition))
      [self wait];

#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ mulleLockWhenNotCondition:%td == success\n",
                           [NSThread currentThread], self, value);
#endif
}


- (BOOL) tryLockWhenCondition:(NSInteger) value
{
#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ tryLockWhenCondition:%td (%td)\n",
                           [NSThread currentThread], self, value, [self condition]);
#endif
   if( ! [self tryLock])
   {
#ifdef LOCK_DEBUG
      mulle_fprintf( stderr, "%@: %@ tryLockWhenCondition:%td == failed, no lock acquired\n",
                              [NSThread currentThread], self, value);
#endif
      return( NO);
   }

   if( value == (NSInteger) _mulle_atomic_pointer_nonatomic_read( &_currentCondition))
   {
#ifdef LOCK_DEBUG
      mulle_fprintf( stderr, "%@: %@ tryLockWhenCondition:%td == success, condition matched (locked)\n",
                              [NSThread currentThread], self, value);
#endif
      return( YES);
   }

   [self unlock];
#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ tryLockWhenCondition:%td == failed, condition did not matched (unlocked)\n",
                           [NSThread currentThread], self, value);
#endif
   return( NO);
}


- (BOOL) mulleTryLockWhenNotCondition:(NSInteger) value
{
#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ mulleTryLockWhenNotCondition: %td (%td)\n",
                           [NSThread currentThread], self, value, [self condition]);
#endif
   if( ! [self tryLock])
   {
#ifdef LOCK_DEBUG
      mulle_fprintf( stderr, "%@: %@ mulleTryLockWhenNotCondition:%td == failed, no lock acquired\n",
                              [NSThread currentThread], self, value);
#endif
      return( NO);
   }

   if( value != (NSInteger) _mulle_atomic_pointer_nonatomic_read( &_currentCondition))
   {
#ifdef LOCK_DEBUG
      mulle_fprintf( stderr, "%@: %@ mulleTryLockWhenNotCondition:%td == success, condition didn't match (locked)\n",
                              [NSThread currentThread], self, value);
#endif
      return( YES);
   }

   [self unlock];
#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ mulleTryLockWhenNotCondition:%td == failed, condition did match (unlocked)\n",
                           [NSThread currentThread], self, value);
#endif
   return( NO);
}



- (void) unlockWithCondition:(NSInteger) value
{
#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ unlockWithCondition:%td\n",
                           [NSThread currentThread], self, value);
#endif

   _mulle_atomic_pointer_nonatomic_write( &_currentCondition, (void *) value);

   //
   // so we broadcast here, because if we only signal we could signal a thread
   // that doesn't really care and then nothing goes anymore ?
   //
   [self broadcast];
   [self unlock];
}


- (void) mulleUnlockWithCondition:(NSInteger) value
                        broadcast:(BOOL) broadcast
{
#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ mulleUnlockWithCondition:broadacst: %td\n",
                           [NSThread currentThread], self, value);
#endif

   _mulle_atomic_pointer_nonatomic_write( &_currentCondition, (void *) value);

   //
   // so we broadcast here, because if we only signal we could signal a thread
   // that doesn't really care and then nothing goes anymore ?
   //
   if( broadcast)
      [self broadcast];
   else
      [self signal];
   [self unlock];
}


static BOOL   tryLockUntilTimeInterval( NSConditionLock *self, NSTimeInterval timeInterval)
{
   NSTimeInterval   now;

   while( ! [self tryLock])
   {
      now = _NSTimeIntervalNow();
      if( now >= timeInterval)
      {
#ifdef LOCK_DEBUG
        mulle_fprintf( stderr, "%@: %@ tryLockUntilTimeInterval:%.3f == failed\n",
                           [NSThread currentThread], self, timeInterval);
#endif

         return( NO);
      }

      mulle_thread_yield(); // nanosleep ?
   }

   // calculate remaining time
#ifdef LOCK_DEBUG
  mulle_fprintf( stderr, "%@: %@ tryLockUntilTimeInterval: %.3f == success\n",
                           [NSThread currentThread], self, timeInterval);
#endif

   return( YES);
}


static mulle_relativetime_t   tryLockUntilTimeout( NSConditionLock *self,
                                                   mulle_relativetime_t timeout)
{
   mulle_absolutetime_t   now;
   mulle_absolutetime_t   then;
   mulle_relativetime_t   diff;
#ifdef LOCK_DEBUG
   mulle_absolutetime_t   last = -INFINITY;
#endif

   then = 0.0;
   diff = timeout;
   while( ! [self tryLock])
   {
      now = mulle_absolutetime_now();
      if( then == 0.0)
         then = timeout + now;
      diff = then - now;
      if( diff <= 0.0)
      {
#ifdef LOCK_DEBUG
        mulle_fprintf( stderr, "%@: %@ tryLockUntilTimeout:%.3f == failed\n",
                           [NSThread currentThread], self, timeout);
#endif

         return( -1.0);
      }
#ifdef LOCK_DEBUG
      {
         if( now > last)
         {
            mulle_fprintf( stderr, "%@: %@ tryLockUntilTimeout: %,3f waiting (%.3f -> %.3f)\n",
                                 [NSThread currentThread], self, timeout, now, then);
            last = now + 0.5;
         }
      }
#endif
      mulle_thread_yield(); // nanosleep, but for how long ? yields seems better
   }

   // calculate remaining time
#ifdef LOCK_DEBUG
  mulle_fprintf( stderr, "%@: %@ tryLockUntilTimeout: %.3f == success (remaining: %.3f)\n",
                           [NSThread currentThread], self, timeout, diff);
#endif

   return( diff);
}


- (BOOL) mulleLockWhenCondition:(NSInteger) value
                        timeout:(mulle_relativetime_t) timeout
{
   mulle_relativetime_t   remain;

   remain = tryLockUntilTimeout( self, timeout);
   if( remain < 0)
      return( NO);

   // now we are locked and can wait on the condition
   // waiting means, we unlock, get signalled and then relock
   while( value != (NSUInteger) _mulle_atomic_pointer_nonatomic_read( &_currentCondition))
      if( ! [self mulleWaitWithTimeout:remain])
      {
#ifdef LOCK_DEBUG
         mulle_fprintf( stderr, "%@: %@ %s %td,%.3f == failed, timeout reached\n",
                              [NSThread currentThread], self, __PRETTY_FUNCTION__, value, remain);
#endif
         return( NO);
      }

#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ %s %td == success (locked)\n",
                           [NSThread currentThread], self, __PRETTY_FUNCTION__, value);
#endif
   return( YES);
}


- (BOOL) mulleLockWhenCondition:(NSInteger) value
              beforeTimeInterval:(NSTimeInterval) timeInterval
{
   if( ! tryLockUntilTimeInterval( self, timeInterval))
      return( NO);

   // now we are locked and can wait on the condition
   // waiting means, we unlock, get signalled and then relock
   while( value != (NSUInteger) _mulle_atomic_pointer_nonatomic_read( &_currentCondition))
      if( ! [self mulleWaitUntilTimeInterval:timeInterval])
      {
#ifdef LOCK_DEBUG
         mulle_fprintf( stderr, "%@: %@ %s %td == failed, timeInterval reached\n",
                              [NSThread currentThread], self, __PRETTY_FUNCTION__, value);
#endif
         return( NO);
      }

#ifdef LOCK_DEBUG
   mulle_fprintf( stderr, "%@: %@ %s %td == success (locked)\n",
                           [NSThread currentThread], self, __PRETTY_FUNCTION__, value);
#endif
   return( YES);
}


- (BOOL) mulleLockWhenCondition:(NSInteger) value
          waitUntilTimeInterval:(NSTimeInterval) timeInterval
{
   [self lock];
   while( value != (NSUInteger) _mulle_atomic_pointer_nonatomic_read( &_currentCondition))
      if( ! [self mulleWaitUntilTimeInterval:timeInterval])
         return( NO);
   return( YES);
}


- (BOOL) mulleLockWithTimeout:(mulle_relativetime_t) timeout
{
   mulle_relativetime_t   remain;

   remain = tryLockUntilTimeout( self, timeout);
   return( remain >= 0.0);
}


- (BOOL) mulleLockBeforeTimeInterval:(NSTimeInterval) interval
{
   return( tryLockUntilTimeInterval( self, interval));
}

@end


