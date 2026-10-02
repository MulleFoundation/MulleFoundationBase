//
//  MulleObjCTokenizer.m
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK. All rights reserved.
//
//  The cursor declared in MulleObjCTokenizer.h.
//
#import "MulleObjCTokenizer.h"

#import "import-private.h"


@implementation MulleObjCTokenizer

+ (MulleObjCTokenSet *) defaultTokenSet
{
   return( [MulleObjCTokenSet tokenSet]);
}


+ (instancetype) tokenizerWithText:(NSString *) text
{
   return( [self tokenizerWithText:text
                          tokenSet:[self defaultTokenSet]]);
}


+ (instancetype) tokenizerWithText:(NSString *) text
                         tokenSet:(MulleObjCTokenSet *) tokenSet
{
   MulleObjCTokenizer   *tokenizer;

   tokenizer = [self alloc];
   tokenizer = [tokenizer initWithText:text
                             tokenSet:tokenSet];
   tokenizer = [tokenizer autorelease];
   return( tokenizer);
}


- (instancetype) initWithText:(NSString *) text
                     tokenSet:(MulleObjCTokenSet *) tokenSet
{
   MulleObjCTokenizer   *tokenizer;

   tokenizer = [super init];
   if( tokenizer)
   {
      tokenizer->_text     = [text copy];
      tokenizer->_tokenSet = [tokenSet retain];
      tokenizer->_location = 0;
   }
   return( tokenizer);
}


- (void) finalize
{
   [_text autorelease];
   _text = nil;
   [_tokenSet autorelease];
   _tokenSet = nil;

   [super finalize];
}


- (void) setLocation:(NSUInteger) location
{
   NSUInteger   length;

   length = [_text length];
   if( location > length)
      location = length;
   _location = location;
}


- (MulleObjCToken *) nextToken
{
   BOOL                    declared;
   BOOL                    isSkip;
   MulleObjCToken          *token;
   MulleObjCTokenRule      *rule;
   MulleObjCPattern        *pattern;
   MulleObjCPatternMatch   *match;
   NSArray                 *candidates;
   NSRange                 content, range;
   NSUInteger              contentEnd, contentStart, length, location;
   unichar                 c;

   length = [_text length];
   if( _location >= length)
      return( nil);

   location = _location;
   c        = [_text characterAtIndex:location];

   //
   // the rules that declared this code point, or every rule when none did. That
   // fallback is why a declaration is a speed decision and never a correctness
   // one.
   //
   candidates = [_tokenSet candidateRulesForCharacter:c];
   declared   = (candidates != nil);
   if( ! declared)
      candidates = [_tokenSet rules];

   for( rule in candidates)
   {
      pattern = [_tokenSet patternForPattern:[rule pattern]];
      if( ! pattern)
         continue;

      match = [pattern firstMatchInString:_text
                                    range:NSMakeRange( location, length - location)];
      if( ! match)
         continue;

      // the engine searches forward, so a match past the cursor is not a match
      // *here*. This check is what an anchored match API would make unnecessary.
      range = [match range];
      if( range.location != location || ! range.length)
         continue;

      isSkip       = (([rule flags] & MulleObjCTokenRuleSkip) != 0);
      contentStart = range.location;
      contentEnd   = NSMaxRange( range);

      //
      // the content range excludes a surrounding quote pair. The backslash is
      // left in: unquoting is the caller's decision.
      //
      if( ([rule flags] & MulleObjCTokenRuleContent) && range.length >= 2)
      {
         if( [_text characterAtIndex:contentStart] == '"')
            contentStart++;
         if( [_text characterAtIndex:contentEnd - 1] == '"')
            contentEnd--;
      }
      content = NSMakeRange( contentStart, contentEnd - contentStart);

      if( ! declared)
         [_tokenSet countUndeclaredStart];

      token     = [MulleObjCToken tokenWithName:[rule name]
                                          range:range
                                   contentRange:content
                                         isSkip:isSkip];
      _location = NSMaxRange( range);
      return( token);
   }

   //
   // No rule claimed this character. Produce a one character token rather than
   // stopping, and count it on the table: the owner of the table can then assert
   // the count is zero and get a report, which beats a scan that quietly ends
   // early. Counting it on the cursor would have counted it for nobody.
   //
   [_tokenSet countUnrecognizedCharacter];
   token = [MulleObjCToken tokenWithName:@"?"
                                   range:NSMakeRange( location, 1)
                            contentRange:NSMakeRange( location, 1)
                                  isSkip:NO];
   _location = location + 1;
   return( token);
}


- (MulleObjCToken *) nextSignificantToken
{
   MulleObjCToken   *token;

   while( (token = [self nextToken]))
      if( ! [token isSkip])
         return( token);
   return( nil);
}

@end
