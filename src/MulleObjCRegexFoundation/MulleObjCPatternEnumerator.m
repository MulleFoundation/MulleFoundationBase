//
//  MulleObjCPatternEnumerator.m
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
#import "MulleObjCPatternEnumerator.h"

#import "import-private.h"

#import "MulleObjCPattern.h"


@implementation MulleObjCPatternEnumerator

+ (instancetype) enumeratorWithPattern:(MulleObjCPattern *) pattern
                                string:(NSString *) string
                                 range:(NSRange) range
{
   return( [[[self alloc] initWithPattern:pattern
                                   string:string
                                    range:range] autorelease]);
}


- (instancetype) initWithPattern:(MulleObjCPattern *) pattern
                          string:(NSString *) string
                           range:(NSRange) range
{
   NSUInteger   length;

   length = [string length];
   range  = MulleObjCRangeValidateAgainstLength( range, length);

   _pattern  = [pattern retain];
   _string   = [string retain];
   _range    = range;
   _length   = length;
   _location = range.location;
   _end      = (range.location == NSNotFound) ? 0 : NSMaxRange( range);
   if( _end > length)
      _end = length;

   _characters = mulle_malloc( sizeof( unichar) * (length + 1));
   [string getCharacters:_characters];
   _characters[ length] = 0;

   //
   // fake the end of the searched range, so that EOL ($) and the engine's
   // scan stop there and not at the end of the string
   //
   if( _end < length)
      _characters[ _end] = 0;

   return( self);
}


- (void) dealloc
{
   mulle_free( _characters);

   [_string release];
   [_pattern release];

   [super dealloc];
}


- (MulleObjCPatternMatch *) nextObject
{
   NSRange   ranges[ MULLE_OBJC_PATTERN_MAX_CAPTURE_GROUPS + 1];

   if( ! [_pattern mulleFindNextMatch:ranges
                           characters:_characters
                                  end:_end
                             location:&_location])
      return( nil);

   //
   // the pattern knows how many groups it has, so a group that did not
   // participate in the match is still addressable (its range is NSNotFound)
   //
   return( [MulleObjCPatternMatch matchWithString:_string
                                           ranges:ranges
                                            count:[_pattern numberOfCaptureGroups] + 1]);
}


- (NSUInteger) count
{
   NSRange      ranges[ MULLE_OBJC_PATTERN_MAX_CAPTURE_GROUPS + 1];
   NSUInteger   location, n;

   location = _range.location;
   n        = 0;
   while( [_pattern mulleFindNextMatch:ranges
                            characters:_characters
                                   end:_end
                              location:&location])
      ++n;

   return( n);
}


- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *) state
                                   objects:(id *) objects
                                     count:(NSUInteger) count
{
   NSUInteger   i;
   id           match;

   state->itemsPtr     = objects;
   state->mutationsPtr = &_mutations;

   for( i = 0; i < count; ++i)
   {
      match = [self nextObject];
      if( ! match)
         break;
      objects[ i] = match;
   }
   return( i);
}

@end
