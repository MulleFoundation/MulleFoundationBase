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

