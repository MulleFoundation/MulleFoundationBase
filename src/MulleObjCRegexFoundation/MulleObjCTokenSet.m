//
//  MulleObjCTokenSet.m
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK. All rights reserved.
//
//  The table declared in MulleObjCTokenSet.h. There is nothing cmake specific
//  in here - a subclass answers +rules, and that is the whole difference between
//  one language and another.
//
#import "MulleObjCTokenSet.h"

#import "import-private.h"

#import "MulleObjCTokenProblem.h"

#include <assert.h>


@interface MulleObjCTokenSet ()

// the rules of a table that can be started on a finite list of characters,
// indexed by code point
+ (NSMutableDictionary *) dispatchForRules:(NSArray *) rules;

// the rules that can start somewhere the map can not enumerate
+ (NSArray *) openRulesForRules:(NSArray *) rules;

@end


@implementation MulleObjCTokenSet

//
// The base class is a table with no rules. It is not useful on its own, and it
// is not meant to be: a language subclass says what its table is.
//
+ (NSArray *) rules
{
   return( @[]);
}


+ (MulleObjCPatternOptions) patternOptions
{
   return( MulleObjCExtendedPattern);
}


+ (instancetype) tokenSet
{
   return( [self tokenSetWithRules:[self rules]]);
}


+ (instancetype) tokenSetWithRules:(NSArray *) rules
{
   MulleObjCTokenSet   *set;
   NSString            *problem;

   set = [[self alloc] init];
   set->_rules     = [rules copy];
   set->_dispatch  = [[self dispatchForRules:rules] retain];
   set->_openRules = [[self openRulesForRules:rules] retain];
   set->_patterns  = [NSMutableDictionary new];

   //
   // Checked here rather than left to the caller, because -problem is exactly
   // the check nobody remembered to run: it was declared and documented and
   // called from nowhere. It compiles the patterns, so it has to come last.
   //
   problem = [set problem];
   if( problem)
   {
      //
      // The reason goes to stderr, because -problem is about to be released
      // along with the set and nil says only that something is wrong. Then a
      // Debug build stops: a degenerate table is a defect in the source and no
      // input will fix it, so reporting it politely to a caller who cannot act
      // would be theatre. assert() is compiled away under NDEBUG, which is the
      // same switch that separates "shipped" from "being worked on" - so a test
      // that needs to observe the nil return has to be built with NDEBUG too.
      //
      MulleObjCFprintf( stderr, @"%@\n", problem);
      assert( ! problem);
      [set release];
      return( nil);
   }
   return( [set autorelease]);
}


- (void) finalize
{
   [_rules autorelease];
   _rules = nil;
   [_dispatch autorelease];
   _dispatch = nil;
   [_openRules autorelease];
   _openRules = nil;
   [_patterns autorelease];
   _patterns = nil;

   [super finalize];
}


- (MulleObjCPattern *) patternForPattern:(NSString *) pattern
{
   MulleObjCPattern   *compiled;

   compiled = [_patterns objectForKey:pattern];
   if( compiled)
      return( compiled);

   compiled = [MulleObjCPattern patternWithString:pattern
                                          options:[[self class] patternOptions]];
   if( compiled)
      [_patterns setObject:compiled
                    forKey:pattern];
   return( compiled);
}


//
// Built from what the rules declare, so the map is as big as the declarations
// and nothing decides in advance what a character is. It used to be a 256 entry
// array indexed by character, which is a table that quietly stops being able to
// describe anything above U+00FF - and mulle-objc's unichar is a code point, so
// that ceiling was ours and not the platform's.
//
// The candidates are stored per declared code point, in table order, so the
// tokenizer gets them without rebuilding the list and without asking any rule.
//
+ (NSMutableDictionary *) dispatchForRules:(NSArray *) rules
{
   MulleObjCTokenRule    *rule;
   NSMutableArray        *candidates;
   NSMutableDictionary   *dispatch;
   NSString              *characters;
   NSUInteger            i, n;
   unichar               c;

   dispatch = [NSMutableDictionary dictionary];

   for( rule in rules)
   {
      characters = [rule firstCharacters];
      n          = [characters length];
      for( i = 0; i < n; i++)
      {
         c = [characters characterAtIndex:i];
         candidates = [dispatch objectForKey:[NSNumber numberWithUnsignedLongLong:c]];
         if( ! candidates)
         {
            candidates = [NSMutableArray array];
            [dispatch setObject:candidates
                         forKey:[NSNumber numberWithUnsignedLongLong:c]];
         }
         // a rule that names the same character twice must not be tried twice
         if( [candidates indexOfObjectIdenticalTo:rule] == NSNotFound)
            [candidates addObject:rule];
      }
   }
   // each list is filled in table order, so none of them needs sorting
   return( dispatch);
}


+ (NSArray *) openRulesForRules:(NSArray *) rules
{
   MulleObjCTokenRule   *rule;
   NSMutableArray       *open;

   open = nil;
   for( rule in rules)
      if( [rule firstCharacterSet] || ! [rule declaresFirstCharacters])
      {
         if( ! open)
            open = [NSMutableArray array];
         [open addObject:rule];
      }
   return( open);
}


- (void) countUnrecognizedCharacter
{
   _unrecognizedCount++;
}


- (void) countUndeclaredStart
{
   _undeclaredStartCount++;
}


//
// The counters above, described. One object per kind that happened rather than
// one per occurrence: a table that is missing a character does so for every
// occurrence of it, and a list of a thousand identical problems is a worse
// report than a count of a thousand.
//
- (NSArray *) problems
{
   NSMutableArray   *problems;

   if( ! _unrecognizedCount && ! _undeclaredStartCount)
      return( @[]);

   problems = [NSMutableArray array];
   // unrecognized first, which is the order the report reads in
   if( _unrecognizedCount)
      [problems addObject:[MulleObjCTokenProblem problemWithKind:MulleObjCTokenProblemUnrecognizedCharacter
                                                           count:_unrecognizedCount]];
   if( _undeclaredStartCount)
      [problems addObject:[MulleObjCTokenProblem problemWithKind:MulleObjCTokenProblemUndeclaredStart
                                                           count:_undeclaredStartCount]];
   return( problems);
}


- (BOOL) hasProblems
{
   return( _unrecognizedCount != 0 || _undeclaredStartCount != 0);
}


- (MulleObjCTokenRule *) ruleNamed:(NSString *) name
{
   MulleObjCTokenRule   *rule;

   for( rule in _rules)
      if( [[rule name] isEqualToString:name])
         return( rule);
   return( nil);
}


//
// The rules to try at the cursor, in table order, or nil when nothing declared
// the character. A rule that declared nothing is a candidate everywhere, which
// is why it is in openRules.
//
- (NSArray *) candidateRulesForCharacter:(unichar) c
{
   MulleObjCTokenRule   *rule;
   NSArray              *declared;
   NSMutableArray       *merged;

   declared = [_dispatch objectForKey:[NSNumber numberWithUnsignedLongLong:c]];
   if( ! [_openRules count])
      return( declared);

   // something in the table starts outside a finite list of characters, so the
   // candidates have to be decided here - and in table order, because which rule
   // matches first is the difference between two answers
   merged = nil;
   for( rule in _rules)
   {
      if( [_openRules indexOfObjectIdenticalTo:rule] != NSNotFound)
      {
         if( ! [rule declaresFirstCharacters] || [rule canStartWithCharacter:c])
         {
            if( ! merged)
               merged = [NSMutableArray array];
            [merged addObject:rule];
         }
         continue;
      }
      if( declared && [declared indexOfObjectIdenticalTo:rule] != NSNotFound)
      {
         if( ! merged)
            merged = [NSMutableArray array];
         [merged addObject:rule];
      }
   }
   return( merged);
}


- (NSString *) problem
{
   MulleObjCTokenRule   *rule;
   NSMutableString      *taken;
   NSString             *characters;
   NSUInteger           i, j, length;
   BOOL                 isDead;
   unichar              c;

   // a pattern that does not compile is the worst kind of table bug: the rule
   // simply never matches and every result is quietly wrong
   for( rule in _rules)
   {
      if( ! [self patternForPattern:[rule pattern]])
         return( [NSString stringWithFormat:@"rule \"%@\": the pattern \"%@\" does not compile",
                    [rule name], [rule pattern]]);
   }

   taken  = [NSMutableString stringWithCapacity:0];
   length = [_rules count];

   for( i = 0; i < length; i++)
   {
      rule       = [_rules objectAtIndex:i];
      characters = [rule firstCharacters];

      //
      // A rule that declared a set is left out of the proof in both directions.
      // Its literals go in as characters it claims, but it is never reported
      // dead, because the set may still make it reachable. Being unable to
      // decide is not a finding.
      //
      if( ! [rule firstCharacterSet] && [characters length])
      {
         isDead = YES;
         for( j = 0; j < [characters length]; j++)
         {
            c = [characters characterAtIndex:j];
            if( [taken rangeOfString:[NSString stringWithCharacters:&c
                                                             length:1]].location == NSNotFound)
            {
               isDead = NO;
               break;
            }
         }
         if( isDead)
            return( [NSString stringWithFormat:@"rule \"%@\" can never match: every character it can"
                       " start with (%@) is already taken by an earlier rule",
                       [rule name], characters]);
      }

      if( characters)
         [taken appendString:characters];
   }
   return( nil);
}

@end
