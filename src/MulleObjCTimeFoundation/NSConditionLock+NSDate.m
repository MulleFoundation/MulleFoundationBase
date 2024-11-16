//
//  NSConditionLock+NSDate.m
//  MulleObjCLockFoundation
//
//  Copyright (c) 2021 Nat! - Mulle kybernetiK.
//  Copyright (c) 2021 Codeon GmbH.
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
#import "NSConditionLock+NSDate.h"

#import "import-private.h"

#import "NSCondition+NSDate.h"
#import "NSTimeInterval.h"
#import "NSDate.h"


@implementation NSConditionLock( NSDate)


- (BOOL) mulleLockWhenCondition:(NSInteger) value
                  waitUntilDate:(NSDate *) date
{
   NSTimeInterval   timeInterval;

   timeInterval = [date timeIntervalSinceReferenceDate];
   return( [self mulleLockWhenCondition:value
                  waitUntilTimeInterval:timeInterval]);
}


- (BOOL) lockWhenCondition:(NSInteger) value
                beforeDate:(NSDate *) date
{
   NSTimeInterval   timeInterval;

   timeInterval = [date timeIntervalSinceReferenceDate];
   return( [self mulleLockWhenCondition:value
                     beforeTimeInterval:timeInterval]);
}


- (BOOL) lockBeforeDate:(NSDate *) date
{
   NSTimeInterval   timeInterval;

   timeInterval = [date timeIntervalSinceReferenceDate];
   return( [self mulleLockBeforeTimeInterval:timeInterval]);
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

