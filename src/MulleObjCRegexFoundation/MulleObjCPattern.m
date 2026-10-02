//
//  MulleObjCPattern.m
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
#import "MulleObjCPattern.h"

#import "import-private.h"

#import "MulleObjCPattern-Private.h"
#import "MulleObjCPatternEnumerator.h"

#include <limits.h>


//
// mulle_utf32regex_range_for_index() signals a group, that did not take part
// in the match, with LONG_MAX and a length of zero.
//
// This is NOT the same as NSNotFound on Windows, where long is 32 bit and
// INTPTR_MAX is 64 bit. Never compare the ranges of the engine against
// NSNotFound directly, or a non-participating group silently becomes a valid
// range there.
//
#define MULLE_UTF32REGEX_NORANGE   ((uintptr_t) LONG_MAX)


//
// Counts the capture groups of an already converted pattern. A `(' opens a
// group, unless it is escaped or inside a character class.
//
static NSUInteger   countCaptureGroups( unichar *characters,
                                        MulleObjCPatternOptions options)
{
   unichar      c;
   NSUInteger   count;
   int          extended;

   count    = 0;
   extended = (options & MulleObjCExtendedPattern) ? 1 : 0;

   for(;;)
   {
      c = *characters++;
      if( ! c)
         break;

      if( c == '\\')
      {
         if( ! *characters)
            break;
         ++characters;
         continue;
      }

      if( c == '[')
      {
         //
         // skip a possibly negated character class. A `]' is literal, when
         // it is the first character of the class.
         //
         if( *characters == '^')
            ++characters;
         if( *characters == ']')
            ++characters;
         while( (c = *characters) && c != ']')
         {
            ++characters;
            //
            // an extended pattern knows class escapes, so a quoted `]' does
            // not end the class. mulle-regex reads it the same way.
            //
            if( c == '\\' && extended && *characters)
               ++characters;
         }
         if( c)
            ++characters;
         continue;
      }

      if( c == '(')
         ++count;
   }

   return( count);
}


@implementation MulleObjCPattern

+ (instancetype) patternWithString:(NSString *) pattern
{
   return( [[[self alloc] initWithString:pattern
                                  options:0] autorelease]);
}


+ (instancetype) patternWithString:(NSString *) pattern
                           options:(MulleObjCPatternOptions) options
{
   return( [[[self alloc] initWithString:pattern
                                  options:options] autorelease]);
}


- (instancetype) initWithString:(NSString *) pattern
                        options:(MulleObjCPatternOptions) options
{
   size_t    size;
   unichar   *p;

   _regex = NULL;

   size = MulleObjCPatternSize( pattern, options);
   mulle_alloca_do( characters, unichar, size)
   {
      p      = MulleObjCPatternConvert( pattern, characters, options);
      _regex = MulleObjCPatternCompile( characters, options);

      assert( (p - characters) <= size);
      MULLE_C_UNUSED( p);

      _numberOfCaptureGroups = countCaptureGroups( characters, options);
      if( _numberOfCaptureGroups > MULLE_OBJC_PATTERN_MAX_CAPTURE_GROUPS)
         _numberOfCaptureGroups = MULLE_OBJC_PATTERN_MAX_CAPTURE_GROUPS;
   }

   // malformed regular expression
   if( ! _regex)
   {
      [self release];
      return( nil);
   }

   return( self);
}


- (void) dealloc
{
   if( _regex)
      mulle_utf32regex_free( _regex);

   [super dealloc];
}


- (NSUInteger) numberOfCaptureGroups
{
   return( _numberOfCaptureGroups);
}


//
// #1#
//
- (BOOL) mulleFindNextMatch:(NSRange *) ranges
                 characters:(unichar *) characters
                        end:(NSUInteger) end
                   location:(NSUInteger *) pLocation
{
   int                  result;
   NSUInteger           i, location;
   struct mulle_range   range;

   location = *pLocation;
   if( location == NSNotFound || location > end)
   {
      *pLocation = NSNotFound;
      return( NO);
   }

   result = mulle_utf32regex_execute( _regex, &characters[ location]);
   if( result <= 0)
   {
      *pLocation = NSNotFound;
      return( NO);
   }

   for( i = 0; i <= MULLE_OBJC_PATTERN_MAX_CAPTURE_GROUPS; ++i)
   {
      range = mulle_utf32regex_range_for_index( _regex, i);
      if( range.location == MULLE_UTF32REGEX_NORANGE)
         ranges[ i] = NSRangeMake( NSNotFound, 0);
      else
         ranges[ i] = NSRangeMake( location + range.location, range.length);
   }

   //
   // an empty match does not advance the scan by itself, so skip one
   // character. This also terminates the enumeration of patterns, that can
   // match the empty string.
   //
   if( ranges[ 0].length)
      location = NSMaxRange( ranges[ 0]);
   else
      location = ranges[ 0].location + 1;

   *pLocation = location;
   return( YES);
}


- (MulleObjCPatternMatch *) firstMatchInString:(NSString *) string
{
   return( [self firstMatchInString:string
                              range:MulleMakeFullRange()]);
}


- (MulleObjCPatternMatch *) firstMatchInString:(NSString *) string
                                          range:(NSRange) range
{
   return( [[self matchEnumeratorInString:string
                                    range:range] nextObject]);
}


- (NSArray *) matchesInString:(NSString *) string
{
   return( [self matchesInString:string
                           range:MulleMakeFullRange()]);
}


- (NSArray *) matchesInString:(NSString *) string
                        range:(NSRange) range
{
   MulleObjCPatternEnumerator   *rover;
   MulleObjCPatternMatch        *match;
   NSMutableArray               *array;

   array = [NSMutableArray array];
   rover = [self matchEnumeratorInString:string
                                   range:range];
   while( (match = [rover nextObject]))
      [array addObject:match];

   return( array);
}


- (NSUInteger) numberOfMatchesInString:(NSString *) string
{
   return( [self numberOfMatchesInString:string
                                   range:MulleMakeFullRange()]);
}


- (NSUInteger) numberOfMatchesInString:(NSString *) string
                                 range:(NSRange) range
{
   return( [[self matchEnumeratorInString:string
                                    range:range] count]);
}


- (MulleObjCPatternEnumerator *) matchEnumeratorInString:(NSString *) string
{
   return( [self matchEnumeratorInString:string
                                   range:MulleMakeFullRange()]);
}


- (MulleObjCPatternEnumerator *) matchEnumeratorInString:(NSString *) string
                                                   range:(NSRange) range
{
   return( [MulleObjCPatternEnumerator enumeratorWithPattern:self
                                                      string:string
                                                       range:range]);
}


- (NSString *) stringByReplacingMatchesInString:(NSString *) string
                                    withTemplate:(NSString *) template
{
   return( [self stringByReplacingMatchesInString:string
                                            range:MulleMakeFullRange()
                                     withTemplate:template]);
}


- (NSString *) stringByReplacingMatchesInString:(NSString *) string
                                          range:(NSRange) range
                                    withTemplate:(NSString *) template
{
   NSMutableString   *result;
   NSRange           ranges[ MULLE_OBJC_PATTERN_MAX_CAPTURE_GROUPS + 1];
   NSUInteger        end, last, length, location, template_length;

   length = [string length];
   range  = MulleObjCRangeValidateAgainstLength( range, length);
   if( range.location == NSNotFound)
      return( string);

   end    = NSMaxRange( range);
   result = [NSMutableString stringWithCapacity:length];

   mulle_alloca_do( characters, unichar, length + 1)
   {
      [string getCharacters:characters];
      characters[ length] = 0;

      //
      // fake the end of the searched range, so that EOL ($) stops there too
      //
      if( end < length)
         characters[ end] = 0;

      template_length = [template length];
      mulle_alloca_do( template_characters, unichar, template_length + 1)
      {
         [template getCharacters:template_characters];
         template_characters[ template_length] = 0;

         location = range.location;
         last     = range.location;
         while( [self mulleFindNextMatch:ranges
                              characters:characters
                                     end:end
                                location:&location])
         {
            // everything between the previous match and this one
            [result mulleAppendCharacters:&characters[ last]
                                   length:ranges[ 0].location - last];

            [self mulleAppendSubstitution:template_characters
                                       to:result];

            last = NSMaxRange( ranges[ 0]);
         }

         if( last < end)
            [result mulleAppendCharacters:&characters[ last]
                                   length:end - last];
      }
   }

   return( result);
}


//
// #2#
//
// The substitution is computed by mulle-regex itself, so that the template
// syntax is the same as in -mulleStringByReplacingPattern:withString:. It
// reads the group ranges, that the preceding match has left in the engine.
//
- (void) mulleAppendSubstitution:(unichar *) substitution
                              to:(NSMutableString *) result
{
   size_t   length;

   length = mulle_utf32regex_substitution_length( _regex, substitution);

   // (size_t) -1 and (unsigned int) -1 both signal an error
   if( length >= (size_t) (unsigned int) -1)
      return;

   if( ! length)
      return;

   mulle_alloca_do( buf, unichar, length + 1)
   {
      if( mulle_utf32regex_substitute( _regex, substitution, buf, length + 1, 1) >= 0)
         [result mulleAppendCharacters:buf
                                length:length];
   }
}

@end


//
// #1#
//
// Declared in MulleObjCPattern.h as a category, so that
// MulleObjCPatternEnumerator can drive the engine over a buffer it owns.
//
// #2#
//
// Not declared in the header, it is an implementation detail of
// -stringByReplacingMatchesInString:range:withTemplate:.
//
