//
//  NSCondition+NSDate.m
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
#define _GNU_SOURCE

#import "NSCondition+NSDate.h"

#import "import-private.h"

#import "NSTimeInterval.h"
#import "NSDate.h"   
#import <math.h>  // for isinf... hmmmm


@implementation NSCondition( NSDate)

- (BOOL) waitUntilDate:(NSDate *) date
{
   NSTimeInterval   interval;

   interval = [date timeIntervalSinceReferenceDate];
   return( [self mulleWaitUntilTimeInterval:interval]);
}


#ifndef  _WIN32
static void  rval_perror_abort( char *s, int rval)
{
   errno = rval;
   perror( s);
   abort();
}
#endif



- (BOOL) mulleWaitUntilTimeInterval:(NSTimeInterval) interval
{
#ifndef  _WIN32
   struct timespec   wait_time;
   NSTimeInterval    secondsSince1970;
   int               rval;

   if( isinf( interval))
   {
      _mulleIsLocked = NO;

      [self wait];

      _mulleIsLocked = YES;
      return( YES);
   }

   secondsSince1970  = _NSTimeIntervalSinceReferenceDateAsSince1970( interval);
   wait_time.tv_sec  = (long) secondsSince1970;
   wait_time.tv_nsec = (long) ((secondsSince1970 - wait_time.tv_sec) * (double) (1000.0*1000*1000));
   _mulleIsLocked    = NO;
   rval              = pthread_cond_timedwait( &self->_condition,
                                               &self->_lock,
                                               &wait_time);
   if( rval == ETIMEDOUT)
   {
      // surprisingly, we have to do this... pthread is so strange
      rval = pthread_mutex_unlock( &self->_lock);
      assert( ! rval);
      return( NO);
   }
   if( rval)
      rval_perror_abort( "pthread_cond_timedwait", rval);
#endif

   _mulleIsLocked = YES;
   return( YES);
}


- (BOOL) mulleWaitWithTimeout:(mulle_relativetime_t) seconds
{
   NSTimeInterval   interval;

   interval = _NSTimeIntervalNow() + seconds;
   return( [self mulleWaitUntilTimeInterval:interval]);
}

@end

