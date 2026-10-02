//
//  MulleObjCPatternMatch.m
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
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
#import "MulleObjCPatternMatch.h"

#import "import-private.h"


@implementation MulleObjCPatternMatch

+ (instancetype) matchWithString:(NSString *) string
                          ranges:(NSRange *) ranges
                           count:(NSUInteger) count
{
   return( [[[self alloc] initWithString:string
                                  ranges:ranges
                                   count:count] autorelease]);
}


- (instancetype) initWithString:(NSString *) string
                         ranges:(NSRange *) ranges
                          count:(NSUInteger) count
{
   NSUInteger   i;

   if( count > MULLE_OBJC_PATTERN_MAX_CAPTURE_GROUPS + 1)
      count = MULLE_OBJC_PATTERN_MAX_CAPTURE_GROUPS + 1;

   _string = [string retain];
   _count  = count;
   for( i = 0; i < count; ++i)
      _ranges[ i] = ranges[ i];

   return( self);
}


- (void) dealloc
{
   [_string release];

   [super dealloc];
}


- (NSUInteger) numberOfCaptureGroups
{
   return( _count ? _count - 1 : 0);
}


- (NSRange) range
{
   return( [self rangeOfCaptureGroupAtIndex:0]);
}


- (NSRange) rangeOfCaptureGroupAtIndex:(NSUInteger) index
{
   if( index >= _count)
      return( NSRangeMake( NSNotFound, 0));

   return( _ranges[ index]);
}


- (NSString *) string
{
   return( _string);
}


- (NSString *) substring
{
   return( [self substringOfCaptureGroupAtIndex:0]);
}


- (NSString *) substringOfCaptureGroupAtIndex:(NSUInteger) index
{
   NSRange   range;

   range = [self rangeOfCaptureGroupAtIndex:index];
   if( range.location == NSNotFound)
      return( nil);

   return( [_string substringWithRange:range]);
}

@end
