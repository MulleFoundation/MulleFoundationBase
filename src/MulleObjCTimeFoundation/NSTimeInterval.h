//
//  NSTimeInterval.h
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
#ifndef NSTimeInterval_h__
#define NSTimeInterval_h__

#include "include.h"


typedef mulle_calendartime_t    NSTimeInterval;


// compatible values for NSTimeIntervalSinceReferenceDate
#define _NSDistantFuture   63113904000.0
#define _NSDistantPast    -63114076800.0


//
// This is the time interval to **add** to 1.1.1970 GMT.
// to get to 1.1.2001 GMT.
//#define NSTimeIntervalSinceReferenceDate  0.0
#define NSTimeIntervalSince1970           978307200.0


static inline NSTimeInterval
   _NSTimeIntervalSince1970AsReferenceDate( NSTimeInterval interval)
{
   return( interval - NSTimeIntervalSince1970);
}

static inline NSTimeInterval
   _NSTimeIntervalSinceReferenceDateAsSince1970( NSTimeInterval interval)
{
   return( interval + NSTimeIntervalSince1970);
}


static inline NSTimeInterval   _NSTimeIntervalNow( void)
{
   NSTimeInterval    seconds;

   seconds = mulle_calendartime_now();
   return( _NSTimeIntervalSince1970AsReferenceDate( seconds));
}

#endif

