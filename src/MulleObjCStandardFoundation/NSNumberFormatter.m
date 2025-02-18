//
//  NSNumberFormatter.m
//  MulleObjCStandardFoundation
//
//  Copyright (c) 2011 Nat! - Mulle kybernetiK.
//  Copyright (c) 2011 Codeon GmbH.
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
#import "NSNumberFormatter.h"

// other files in this library

// other libraries of MulleObjCStandardFoundation
#import "MulleObjCStandardContainerFoundation.h"
#import "MulleObjCStandardExceptionFoundation.h"
#import "MulleObjCStandardValueFoundation.h"

// std-c and dependencies


@class NSDecimalNumberHandler;


@implementation NSNumberFormatter


static struct
{
   mulle_thread_mutex_t        _lock;
   NSMapTable                  *_table;
   NSNumberFormatterBehavior   _defaultBehavior;
   NSNumberFormatter           *_defaultFormatter;  // used for locale = nil
} Self;


static inline void   SelfLock( void)
{
   mulle_thread_mutex_lock( &Self._lock);
}


static inline void   SelfUnlock( void)
{
   mulle_thread_mutex_unlock( &Self._lock);
}


+ (void) initialize
{
   if( ! Self._table)
   {
      Self._table = NSCreateMapTable( NSIntegerMapKeyCallBacks,
                                      NSObjectMapValueCallBacks,
                                      4);
      if( mulle_thread_mutex_init( &Self._lock))
      {
         fprintf( stderr, "%s could not get a mutex\n", __FUNCTION__);
         abort();
      }
      Self._defaultBehavior  = NSNumberFormatterBehavior10_0;
      Self._defaultFormatter = [NSNumberFormatter new];
      NSMapInsertKnownAbsent( Self._table,
                              (void *) NSNumberFormatterBehavior10_0,
                              self);
   }
}


+ (void) deinitialize
{
   NSNumberFormatter   *formatter;
   NSMapTable          *table;

   @autoreleasepool
   {
      table       = Self._table;
      Self._table = NULL;
      NSFreeMapTable( table);

      formatter              = Self._defaultFormatter;
      Self._defaultFormatter = NULL;
      [formatter release];
   }
   mulle_thread_mutex_done( &Self._lock);
#ifdef DEBUG
   memset( &Self, 0xEE, sizeof( Self));
#endif
}


+ (void) setDefaultFormatterBehavior:(NSNumberFormatterBehavior) behavior
{
   NSParameterAssert( behavior == NSNumberFormatterBehavior10_0 ||
                      behavior == NSNumberFormatterBehavior10_4);

   SelfLock();
   {
      Self._defaultBehavior = behavior;
   }
   SelfUnlock();
}


+ (NSNumberFormatterBehavior) defaultFormatterBehavior
{
   NSNumberFormatterBehavior   behavior;

   SelfLock();
   {
      behavior = Self._defaultBehavior;
   }
   SelfUnlock();
   return( behavior);
}


- (void) setFormatterBehavior:(NSNumberFormatterBehavior) formatterBehavior
{
   Class   cls;

   cls = [self class];
   if( formatterBehavior == NSNumberFormatterBehaviorDefault)
      formatterBehavior = [cls defaultFormatterBehavior];

   SelfLock();
   {
      cls = NSMapGet( Self._table, (void *) formatterBehavior);
   }
   SelfUnlock();

   if( ! cls)
      MulleObjCThrowInternalInconsistencyException( @"no class for NSNumberFormatterBehavior %d loaded", formatterBehavior);

   MulleObjCInstanceSetClass( self, cls);
   // _formatterBehavior = formatterBehavior; // not sure
}


- (NSNumberFormatterBehavior) formatterBehavior
{
   return( NSNumberFormatterBehavior10_0);
}

#if 0 // UNUSED
static void   validate_behavior( NSNumberFormatterBehavior behavior)
{
   if( behavior != NSNumberFormatterBehaviorDefault && behavior != NSNumberFormatterBehavior10_0)
      MulleObjCThrowInvalidArgumentException( @"unsupported behavior");
}
#endif

- (void) _initDefaultValues
{
   _format            =
   _positiveFormat    =
   _negativeFormat    = @"";
   _decimalSeparator  = @".";
   _thousandSeparator = @",";
}


- (instancetype) init
{
   [self _initDefaultValues];
   return( self);
}


- (void) dealloc
{
   [_format release];  // need to release nonnull manually  (still true ??)
   [super dealloc];
}


- (void) setAllowsFloats:(BOOL) flag            {  _flags.allowsFloats = flag; }
- (void) setGeneratesDecimalNumbers:(BOOL) flag {  _flags.generatesDecimalNumbers = flag; }
- (void) setHasThousandSeparators:(BOOL) flag   {  _flags.hasThousandSeparators = flag; }
- (void) setLenient:(BOOL) flag                 {  _flags.isLenient = flag; }

- (BOOL) allowsFloats              { return( _flags.allowsFloats); }
- (BOOL) generatesDecimalNumbers   { return( _flags.generatesDecimalNumbers); }
- (BOOL) hasThousandSeparators     { return( _flags.hasThousandSeparators); }
- (BOOL) isLenient                 { return( _flags.isLenient); }


- (void) _setFormat:(NSString *) s
{
   NSArray    *components;
   NSString   *zero;
   NSString   *plus;
   NSString   *minus;

   components = [s componentsSeparatedByString:@";"];
   switch( [components count])
   {
   case 1 : zero  = s;
            plus  = s;
            minus = s;
            break;

   case 2 : plus  = [components objectAtIndex:0];
            minus = [components objectAtIndex:1];
            zero  = @"0";
            break;

   case 3 : plus  = [components objectAtIndex:0];
            zero  = [components objectAtIndex:1];
            minus = [components objectAtIndex:2];
            break;
   default :
            MulleObjCThrowInvalidArgumentException( @"malformed");
   }

   [_format autorelease];
   _format = [zero copy];
   [self setPositiveFormat:plus];
   [self setNegativeFormat:minus];
}


- (void) setFormat:(NSString *) s
{
   [self _setFormat:s];
   [self setNumberStyle:NSNumberFormatterNoStyle];
}


// TODO: not well coded at all
- (NSNumber *) numberFromString:(NSString *) s
{
   Class    cls;
   IMP      imp;
   SEL      sel;

   if( _flags.generatesDecimalNumbers)
   {
      // weak foward link
      cls = MulleObjCLookupClassByNameUTF8String( "NSDecimalNumber");
      sel = @selector( decimalNumberWithString:);
      imp = [cls methodForSelector:sel];
      if( imp)
         return( MulleObjCIMPCall( imp, cls, sel, s));

      [NSException raise:NSInternalInconsistencyException
                  format:@"There is no compatible NSDecimalNumber class in the runtime"];
   }
   return( [[[NSNumber alloc] mulleInitWithString:s] autorelease]);
}


- (NSString *) stringFromNumber:(NSNumber *) number
{
   return( [self stringForObjectValue:number]);
}


- (void) setLocalizesFormat:(BOOL) flag
{
   _flags.localizesFormat = flag;
}


- (BOOL) localizesFormat
{
   return( _flags.localizesFormat);
}


- (void) setLocale:(NSLocale *) locale
{
   NSParameterAssert( self != Self._defaultFormatter);

   [_locale autorelease];
   _locale = [locale retain];
}


+ (instancetype) mulleDefaultFormatter
{
   return( Self._defaultFormatter);
}


// TODO; code more
- (void) setNumberStyle:(NSNumberFormatterStyle) style
{
   if( _numberStyle == style)
      return;

   _numberStyle = style;
   switch( style)
   {
   case NSNumberFormatterNoStyle :
      [self _initDefaultValues];
      break;

   case NSNumberFormatterDecimalStyle :
      [self _setFormat:@"#.##"];
      break;

   case NSNumberFormatterPercentStyle :
      [self _setFormat:@"#.##%%"];
      break;

   case NSNumberFormatterScientificStyle :
      abort();
   case NSNumberFormatterSpellOutStyle :
      abort();
   case NSNumberFormatterOrdinalStyle :
      abort();

   case NSNumberFormatterCurrencyStyle :
      [self _setFormat:@"$#,##0.00"];
      break;
   case NSNumberFormatterCurrencyAccountingStyle :
      abort();
   case NSNumberFormatterCurrencyISOCodeStyle :
      abort();
   case NSNumberFormatterCurrencyPluralStyle :
      abort();
   }
}
@end
