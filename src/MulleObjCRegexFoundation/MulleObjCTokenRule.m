//
//  MulleObjCTokenRule.m
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK. All rights reserved.
//
//  The rule declared in MulleObjCTokenRule.h.
//
#import "MulleObjCTokenRule.h"

#import "import-private.h"


@implementation MulleObjCTokenRule

+ (instancetype) ruleWithName:(NSString *) name
                      pattern:(NSString *) pattern
{
   return( [self ruleWithName:name
                      pattern:pattern
              firstCharacters:nil
                        flags:MulleObjCTokenRuleDefault]);
}


+ (instancetype) ruleWithName:(NSString *) name
                      pattern:(NSString *) pattern
              firstCharacters:(NSString *) firstCharacters
{
   return( [self ruleWithName:name
                      pattern:pattern
              firstCharacters:firstCharacters
                        flags:MulleObjCTokenRuleDefault]);
}


+ (instancetype) ruleWithName:(NSString *) name
                      pattern:(NSString *) pattern
              firstCharacters:(NSString *) firstCharacters
                        flags:(MulleObjCTokenRuleFlags) flags
{
   MulleObjCTokenRule   *rule;

   rule = [[self alloc] init];
   rule->_name            = [name copy];
   rule->_pattern         = [pattern copy];
   rule->_firstCharacters = [firstCharacters copy];
   rule->_flags           = flags;
   return( [rule autorelease]);
}


+ (instancetype) ruleWithName:(NSString *) name
                      pattern:(NSString *) pattern
           firstCharacterSet:(NSCharacterSet *) firstCharacterSet
                        flags:(MulleObjCTokenRuleFlags) flags
{
   MulleObjCTokenRule   *rule;

   rule = [[self alloc] init];
   rule->_name              = [name copy];
   rule->_pattern           = [pattern copy];
   rule->_firstCharacterSet = [firstCharacterSet retain];
   rule->_flags             = flags;
   return( [rule autorelease]);
}


- (void) finalize
{
   [_name autorelease];
   _name = nil;
   [_pattern autorelease];
   _pattern = nil;
   [_firstCharacters autorelease];
   _firstCharacters = nil;
   [_firstCharacterSet autorelease];
   _firstCharacterSet = nil;

   [super finalize];
}


- (BOOL) declaresFirstCharacters
{
   return( _firstCharacters || _firstCharacterSet);
}


- (BOOL) canStartWithCharacter:(unichar) c
{
   NSUInteger   i, n;

   //
   // the set first, because it is the general one: a rule that declares a set
   // and a literal means the union, and both orders answer the same
   //
   if( _firstCharacterSet)
      if( [_firstCharacterSet longCharacterIsMember:c])
         return( YES);

   if( ! _firstCharacters)
      return( NO);

   n = [_firstCharacters length];
   for( i = 0; i < n; i++)
      if( [_firstCharacters characterAtIndex:i] == c)
         return( YES);
   return( NO);
}


- (NSString *) description
{
   return( [NSString stringWithFormat:@"<%@ %@>", _name, _pattern]);
}

@end
