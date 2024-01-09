//
//  NSString+Regex.m
//  MulleStringExpansion
//
//  Copyright (c) 2023 Nat! - Mulle kybernetiK.
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
#import "NSString+Regex.h"

#import "import-private.h"


#if ! defined( DEBUG_REGEX)
# ifdef DEBUG
#  define DEBUG_REGEX   1
# else
#  define DEBUG_REGEX   0
# endif
#endif



@implementation NSString ( Regex)

// blows things up by a factor of two
static unichar   *convertSedPattern( NSString *pattern, unichar *copy)
{
   unichar   c;
   unichar   d;
   unichar   *p;

   p = copy;
   d = 0;
   MulleStringFor( pattern, c)
   {
      if( d == '\\')
      {
         if( c != '(' && c != ')')
            *p++ = d;
         *p++ = c;
      }
      else
         switch( c)
         {
         case '\\' :
            break;

         //
         // we have to change *x to [!x]*x, can be problematic though,
         // if we get *[x-z]... hmmm
         //
         case '(' :
         case ')' :
            *p++ = '\\';
            *p++ = c;
            break;

         default :
            *p++ = c;
         }
      d = c;
   }

   // if we have a trailing '\\', we pass it on to error later on
   if( d == '\\')
      *p++ = d;

   return( p);
}


// blows things up by a factor of three
static unichar   *convertWildcardPatternForShortestRange( NSString *pattern,
                                                          unichar *copy)
{
   unichar                        a;
   unichar                        b;
   unichar                        c;
   unichar                        d;
   unichar                        *p;
   unichar                        *memo;
   unichar                        *sentinel;
   struct MulleStringEnumerator   *rover;

   p = copy;
   d = 0;
   MulleStringFor( pattern, c)
   {
      if( d == '\\')
      {
         *p++ = d;
         *p++ = c;
      }
      else
         switch( c)
         {
         case '\\' :
            break;

         //
         // we have to change *x to [!x]*x, can be problematic though,
         // if we get *[x-z]... hmmm
         //
         case '*'  :
            rover = MulleStringForGetEnumerator( c);
            if( ! MulleStringEnumeratorNext( rover, &a))
               break;

            // so we have
            if( a == '[')
            {
               // memorize output and then copy at the back
               memo = p;
               *p++ = '[';

               if( ! MulleStringEnumeratorNext( rover, &a))
                  abort();

               if( a != '!')
               {
                  *p++ = '^';
                  *p++ = a;
               }

               b = a;
               while( MulleStringEnumeratorNext( rover, &a))
               {
                  *p++ = a;
                  if( b == '\\')
                     continue;
                  if( a == ']')
                     break;
               }

               if( a != ']')
                  abort();

               sentinel = p;

               *p++ = '*';

               // now copy pattern again worst case is *[x] to [^x]*[x]
               // 4 to 8, two times larger
               *p++ = *memo++;
               if( *memo != '^')
                  *p++ = '^';
               do
               {
                  a    = *memo++;
                  *p++ = a;
               }
               while( memo < sentinel);

               c = a;
            }
            else
            {
               // we read *a and explode to [^a]*a, three times larger
               b    = 0;
               *p++ = '[';
               *p++ = '^';
               if( a == '\\')
               {
                  *p++ = a;
                  if( ! MulleStringEnumeratorNext( rover, &b))
                     abort();
                  *p++ = b;
               }
               *p++ = ']';
               *p++ = '*';
               *p++ = a;
               if( b)
                  *p++ = b;

               c = b;
            }
            break;

         case '?'  :
            *p++ = '.';
            break;

         // char(s) that need escaping (maybe {} in the future)
         case '('  :
         case ')'  :
         case '|'  :
         case '^'  :
         case '$'  :
         case '.'  :
            *p++ = '\\';
            *p++ = c;
            break;

         case '!'  :
            // gotta check for
            if( d == '[')
            {
               // check if we don't get \\[
               if( &p[ -2] < copy || p[ -2] != '\\')
                  *p++ = '^';
               else
                  *p++ = c;
            }
            else
               *p++ = c;   // replace [!  with ]
            break;

         default :
            *p++ = c;
         }
      d = c;
   }

   // if we have a trailing '\\', we pass it on to error later on
   if( d == '\\')
      *p++ = d;

   return( p);
}


static unichar   *convertWildcardPatternForLongestRange( NSString *pattern,
                                                         unichar *copy)
{
   unichar   c;
   unichar   d;
   unichar   *p;

   p = copy;
   d = 0;
   MulleStringFor( pattern, c)
   {
      if( d == '\\')
      {
         *p++ = d;
         *p++ = c;
      }
      else
         switch( c)
         {
         case '\\' :
            break;

         case '*'  :
            *p++ = '.';
            *p++ = '*';
            break;

         case '?'  :
            *p++ = '.';
            break;

         // char(s) that need escaping
         case '('  :
         case ')'  :
         case '|'  :
         case '^'  :
         case '$'  :
         case '.'  :
            *p++ = '\\';
            *p++ = c;
            break;

         case '!'  :
            // gotta check for
            if( d == '[')
            {
               // check if we don't get \\[
               if( &p[ -2] < copy || p[ -2] != '\\')
                  *p++ = '^';
               else
                  *p++ = c;
            }
            else
               *p++ = c;   // replace [!  with ]
            break;

         default :
            *p++ = c;
         }
      d = c;
   }

   // if we have a trailing '\\', we pass it on to error later on
   if( d == '\\')
      *p++ = d;

   return( p);
}


static unichar   *convertPatternWithOptions( NSString *pattern,
                                             unichar *copy,
                                             MulleObjCPatternOptions options)
{
   unichar   *p;

   p = copy;
   if( options & NSAnchoredSearch)
      *p++ = '^';

   if( options & MulleObjCWildcards)
   {
      if( (options & MulleObjCWildcardsShortestPath) == MulleObjCWildcardsShortestPath)
         p = convertWildcardPatternForShortestRange( pattern, p);
      else
         p = convertWildcardPatternForLongestRange( pattern, p);
   }
   else
   {
      if( options & MulleObjCSedPattern)
         p = convertSedPattern( pattern, p);
      else
      {
         [pattern getCharacters:p];
         p += [pattern length];
      }
   }

   if( options & NSBackwardsSearch)
      *p++ = '$';
   *p++ = 0;

   return( p);
}


static size_t    patternSizeWithOptions( NSString *pattern,
                                         MulleObjCPatternOptions options)
{
   NSUInteger   length;
   NSUInteger   growFactor;

   length     = [pattern length];
   growFactor = (options & MulleObjCWildcardsShortestPath)
                ? 3
                : (options & (MulleObjCWildcards|MulleObjCSedPattern))
                  ? 2
                  : 1;
   return( length * growFactor + 3);
}


- (NSRange) mulleRangeOfPattern:(NSString *) pattern
                        options:(NSStringCompareOptions) options
                          range:(NSRange) range
{
   NSRange      resultRange;
   NSUInteger   pattern_length;
   int          result;
   unichar      *p;
   void         *r;
   size_t       size;

   range       = MulleObjCRangeValidateAgainstLength( range, [self length]);
   resultRange = NSMakeRange( NSNotFound, 0);
   size        = patternSizeWithOptions( pattern, options);

   mulle_alloca_do( pattern_characters, unichar, size)
   {
      p = convertPatternWithOptions( pattern, pattern_characters, options);

      pattern_length = p - pattern_characters;
      assert( pattern_length <= size);

      //
      // This is maybe too big to alloca, and its variable sized, so init
      // is tough as well. So, can't get rid of this malloc easily
      //
      r = mulle_utf32regex_compile( pattern_characters);
      if( ! r)
         break;

#if DEBUG_REGEX
      {
         extern void   mulle_utf32regex_dump( struct mulle_utf32regex *r);

         mulle_utf32regex_dump( r);
      }
#endif

      mulle_alloca_do( characters, unichar, range.length + 1)
      {
         [self getCharacters:characters
                       range:range];
         characters[ range.length] = 0;

         result = mulle_utf32regex_execute( r, characters);
         if( result < 0)
             break;

         if( result == 0)  // no match, keep what we've got
            resultRange = NSMakeRange( 0, 0);
         else
         {
            resultRange = mulle_utf32regex_range_for_index( r, 0);
            resultRange.location += range.location;
         }
      }
      mulle_utf32regex_free( r);
   }
   return( resultRange);
}


- (NSRange) mulleRangeOfPattern:(NSString *) pattern
                        options:(NSStringCompareOptions) options
{
   return( [self mulleRangeOfPattern:pattern
                             options:options
                               range:MulleMakeFullRange()]);
}


- (NSRange) mulleRangeOfPattern:(NSString *) pattern
{
   return( [self mulleRangeOfPattern:pattern
                             options:0
                               range:MulleMakeFullRange()]);
}


- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution
                                     options:(MulleObjCPatternOptions) options
                                       range:(NSRange) range
{
   NSUInteger                pattern_length;
   NSUInteger                substitution_length;
   NSUInteger                rep_length;
   NSUInteger                dst_length;
   NSUInteger                length;
   NSString                  *s;
   NSMutableString           *mutableSelf;
   NSRange                   resultRange;
   NSRange                   affixRanges[ 2];
   struct mulle_utf32regex   *r;
   struct mulle_allocator    *allocator;
   mulle_utf32_t             *buf;
   mulle_utf32_t             *rep;
   int                       result;
   size_t                    size;
   unichar                   *p;

   length = [self length];
   range  = MulleObjCRangeValidateAgainstLength( range, length);
   size   = patternSizeWithOptions( pattern, options);
   s      = nil;

   mulle_alloca_do( pattern_characters, unichar, size)
   {
      p = convertPatternWithOptions( pattern, pattern_characters, options);

      pattern_length = p - pattern_characters;
      assert( pattern_length <= size);

      //
      // This is maybe too big to alloca, and its variable sized, so init
      // is tough as well. So, can't get rid of this malloc easily
      //
      r = mulle_utf32regex_compile( pattern_characters);
      if( ! r)
         break;

#if DEBUG_REGEX
      {
         extern void   mulle_utf32regex_dump( struct mulle_utf32regex *r);

         mulle_utf32regex_dump( r);
      }
#endif
      mulle_alloca_do( characters, unichar, range.length + 1)
      {
         [self getCharacters:characters
                       range:range];
         characters[ range.length] = 0;

         result = mulle_utf32regex_execute( r, characters);
         if( result < 0)
            break;
         if( result == 0)  // no match, keep what we've got
         {
            s = self;
            break;
         }

         resultRange = mulle_utf32regex_range_for_index( r, 0);

         // if we are using wildcards, then we replace the whole matched pattern with string
         // (there are no \1 and \2)
         if( options & MulleObjCWildcards)
         {
            mutableSelf = [NSMutableString stringWithString:self];
            [mutableSelf replaceCharactersInRange:resultRange
                                       withString:substitution];
            s = [[mutableSelf copy] autorelease];
            break;
         }

         substitution_length = [substitution length];
         mulle_alloca_do( substitution_characters, unichar, substitution_length + 1)
         {
            [substitution getCharacters:substitution_characters];
            substitution_characters[ substitution_length] = 0;

            //
            // figure out the length of the prefix and the suffix we want to
            // keep.
            //
            MulleObjCRangeSubtract( NSMakeRange( 0, length), resultRange, affixRanges);

            // figure out the length of the substitution
            rep_length = mulle_utf32regex_substitution_length( r, substitution_characters);
            if( rep_length == (unsigned int) -1)
               break;

            dst_length  = rep_length;
            dst_length += affixRanges[ 0].length;
            dst_length += affixRanges[ 1].length;
            if( ! dst_length)
            {
               s = @"";
               break;
            }

            allocator = &mulle_default_allocator;
            buf       = mulle_allocator_malloc( allocator, sizeof( mulle_utf32_t) * (dst_length + 1));

            // add prefix
            rep = buf;
            mulle_utf32_memcpy( rep, characters, affixRanges[ 0].length);
            rep = &rep[ affixRanges[ 0].length];

            result = mulle_utf32regex_substitute( r, substitution_characters, rep, rep_length + 1, 1);
            if( result < 0)
            {
               mulle_free( buf);
               break;
            }

            // Gotta take care of that trailing zero...

            // add suffix (could be in affixRanges[ 0]).
            mulle_utf32_memcpy( &rep[ rep_length],
                                &characters[ affixRanges[ 1].location],
                                affixRanges[ 1].length);

            s = [NSString mulleStringWithCharactersNoCopy:buf
                                                   length:dst_length
                                                allocator:allocator];
         }
      }
      mulle_utf32regex_free( r);
   }
   return( s);
}


- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution
                                    options:(MulleObjCPatternOptions) options
{
   return( [self mulleStringByReplacingPattern:pattern
                                    withString:substitution
                                       options:options
                                         range:MulleMakeFullRange()]);
}


- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution
{
   return( [self mulleStringByReplacingPattern:pattern
                                    withString:substitution
                                       options:0
                                         range:MulleMakeFullRange()]);
}

@end
