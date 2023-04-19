//
//  NSNumber-Math.h
//  MulleObjCMathFoundation
//
//  Copyright (c) 2020 Nat! - Mulle kybernetiK.
//  Copyright (c) 2020 Codeon GmbH.
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
#import "import-private.h"

// private stuff from MulleObjC
#import <MulleObjCValueFoundation/NSNumber-Private.h>
#import <MulleObjCValueFoundation/_MulleObjCConcreteNumber.h>
#import <MulleObjC/mulle-objc-exceptionhandlertable-private.h>
#import <MulleObjC/mulle-objc-universeconfiguration-private.h>


#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
//
// override some methods in NSNumber for a more exact "unification" of
// numbers into long or double
//
@implementation NSNumber( Math)


// static inline int   double_is_long( double value)
// {
//    long     l_val;
//    double   d_val;
//
//    feclearexcept( FE_INVALID);
//    l_val = lrint( value);
//    d_val = (double) l_val;
//    if( fetestexcept( FE_INVALID))
//       return( 0);
//    return( d_val == value);
// }


static inline int   double_is_long_long( double value)
{
   long long   l_val;
   double      d_val;

   feclearexcept( FE_INVALID);
   l_val = llrint( value);
   d_val = (double) l_val;
   if( fetestexcept( FE_INVALID))
      return( 0);
   return( d_val == value);
}


static inline int   long_double_is_long_long( long double value)
{
   long long     ll_val;
   long double   d_val;

   feclearexcept( FE_INVALID);
   ll_val = llrintl( value);
   d_val  = (long double) ll_val;
   if( fetestexcept( FE_INVALID))
      return( 0);
   return( d_val == value);
}


static inline id   initWithDouble( NSNumber *self, double value)
{
   struct _mulle_objc_universefoundationinfo   *config;
   struct _mulle_objc_universe                 *universe;

   if( double_is_long_long( value))
      return( [self initWithLongLong:(long long) value]);

   universe = _mulle_objc_object_get_universe( self);
   _mulle_objc_universe_get_foundationspace( universe, (void **) &config, NULL);

   self = [config->numbersubclasses[ _NSNumberClassClusterDoubleType] newWithDouble:value];
   return( self);
}


static inline id   initWithLongDouble( NSNumber *self, long double value)
{
   struct _mulle_objc_universefoundationinfo   *config;
   struct _mulle_objc_universe                 *universe;

   // see comment above
   if( long_double_is_long_long( value))
      return( [self initWithLongLong:(long long) value]);

   // MEMO: don't degrade to double as we would lose precision
   universe = _mulle_objc_object_get_universe( self);
   _mulle_objc_universe_get_foundationspace( universe, (void **) &config, NULL);

   self = [config->numbersubclasses[ _NSNumberClassClusterLongDoubleType] newWithLongDouble:value];
   return( self);
}


- (instancetype) initWithFloat:(float) value
{
   return( initWithDouble( self, value));
}


- (instancetype) initWithDouble:(double) value
{
   return( initWithDouble( self, value));
}


- (instancetype) initWithLongDouble:(long double) value
{
   return( initWithLongDouble( self, value));
}


@end


