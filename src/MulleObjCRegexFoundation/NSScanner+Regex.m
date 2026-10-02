//
//  NSScanner+Regex.m
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
#import "NSScanner+Regex.h"

#import "import-private.h"


//
// NSScanner applies charactersToBeSkipped in a file static helper that also
// caches the IMPs of -characterAtIndex: and -characterIsMember:, and a category
// can reach neither. So this is the same loop through normal dispatch. It moves
// the scan location, which is what makes an eventually failed scan still report
// the skipped characters as consumed - the behavior the built in methods have.
//
static void   skipCharactersToBeSkipped( NSScanner *self)
{
   NSCharacterSet   *set;
   NSString         *text;
   NSUInteger       length, location;
   unichar          c;

   set = [self charactersToBeSkipped];
   if( ! set)
      return;

   text     = [self string];
   length   = [text length];
   location = [self scanLocation];

   while( location < length)
   {
      c = [text characterAtIndex:location];
      if( ! [set characterIsMember:c])
         break;
      location++;
   }

   [self setScanLocation:location];
}


@implementation NSScanner( Regex)

- (BOOL) scanPattern:(MulleObjCPattern *) pattern
{
   return( [self scanPattern:pattern
                   intoMatch:NULL]);
}


- (BOOL) scanPattern:(MulleObjCPattern *) pattern
           intoMatch:(MulleObjCPatternMatch **) matchp
{
   MulleObjCPatternMatch   *match;
   NSString                *text;
   NSRange                 range;
   NSUInteger              length, location;

   assert( pattern);

   if( matchp)
      *matchp = nil;
   if( ! pattern)
      return( NO);

   skipCharactersToBeSkipped( self);

   text     = [self string];
   length   = [text length];
   location = [self scanLocation];
   if( location >= length)
      return( NO);

   match = [pattern firstMatchInString:text
                                 range:NSMakeRange( location, length - location)];
   if( ! match)
      return( NO);

   // the engine searches forward: a match further ahead is not a match here,
   // and one that is empty is not one either
   range = [match range];
   if( range.location != location || ! range.length)
      return( NO);

   [self setScanLocation:NSMaxRange( range)];
   if( matchp)
      *matchp = match;
   return( YES);
}


- (BOOL) scanUpToPattern:(MulleObjCPattern *) pattern
              intoString:(NSString **) stringp
{
   MulleObjCPatternMatch   *match;
   NSString                *text;
   NSRange                 range;
   NSUInteger              location;

   assert( pattern);

   if( stringp)
      *stringp = @"";
   if( ! pattern)
      return( NO);

   skipCharactersToBeSkipped( self);

   text     = [self string];
   location = [self scanLocation];

   match = [pattern firstMatchInString:text
                                 range:NSMakeRange( location, [text length] - location)];
   if( ! match)
      return( NO);

   //
   // a match at the cursor means nothing was passed over. That is YES with the
   // empty string and the location untouched, which is how -scanUpToString:
   // answers when the string is already sitting there.
   //
   range = [match range];
   if( range.location > location)
   {
      if( stringp)
         *stringp = [text substringWithRange:NSMakeRange( location, range.location - location)];
      [self setScanLocation:range.location];
   }
   return( YES);
}

@end
