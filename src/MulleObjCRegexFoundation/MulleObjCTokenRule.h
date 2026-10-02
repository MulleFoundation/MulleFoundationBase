//
//  MulleObjCTokenRule.h
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK. All rights reserved.
//
//  One entry of a MulleObjCTokenSet's table. Framework material that currently
//  lives in a tool; see MulleObjCToken.h for the reasoning.
//
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#import "import.h"


typedef enum
{
   MulleObjCTokenRuleDefault = 0,
   MulleObjCTokenRuleSkip    = 1 << 0,   // whitespace, comments
   MulleObjCTokenRuleContent = 1 << 1    // contentRange excludes a surrounding quote pair
} MulleObjCTokenRuleFlags;


//
// `pattern` is an extended pattern (MulleObjCExtendedPattern) and must be able
// to match the first character of a token, or the rule will never be reached in
// order.
//
// What a rule can start on is declared in one of two ways, and which one is used
// is the difference between a table that can be checked and a table that is
// general:
//
//   * `firstCharacters` - a literal string of the characters: `(`, `)`, `#`, the
//     members of a finite set like cmake's identifier start. Exact, and it makes
//     the dispatch a lookup, which is what lets -problem prove that no earlier
//     rule has already taken every character this one can start with, i.e. that
//     it is dead.
//   * `firstCharacterSet` - an NSCharacterSet, for "any character that is a
//     letter" and the like. The only way to say that without listing half of
//     Unicode. What it costs is the proof: whether two sets overlap, and whether
//     one contains another, is not decidable in general, so -problem can be
//     exact only about the literal part of such a rule.
//
// Neither is derived from `pattern`. Deriving it would mean writing a pattern
// parser, and a wrong derivation is a silent mis-lex.
//
// A rule that declares neither can start on anything, and the tokenizer treats
// it that way: a candidate at every position, in table order like every other
// rule. A rule that declares one of the two says it can only start there.
//
// A character that nothing declared still scans, by falling back to trying the
// rules in order, and the tokenizer counts the fallbacks. Correctness never
// depends on the declaration; only speed does.
//
// `unichar` is mulle-objc's, which is `mulle_utf32_t`: a character is a code
// point and not a UTF-16 code unit, so there is no surrogate to reason about and
// nothing here stops below `0x10000`.
//
// Two caveats about the patterns themselves, both of them the kind that produce
// a wrong answer instead of an error:
//
//   * a negated class with a *single* member does not repeat under `*` or `+` in
//     the current engine. `[^a]+`, `[^\n]+` and `[^ ]+` match zero characters,
//     while `[^ab]+` and `[^"#]+` and `[^\r\n]*` repeat normally. The pattern
//     compiles either way, so -problem can not see it - write such a class with
//     two members.
//   * a pattern that only matches *somewhere ahead* is not a match at the
//     cursor: the tokenizer searches forward and then checks that the match
//     starts where it is. Anchor the pattern to what it must be.
//
@interface MulleObjCTokenRule : NSObject

@property( readonly, copy) NSString                 *name;
@property( readonly, copy) NSString                 *pattern;
@property( readonly, copy) NSString                 *firstCharacters;
@property( readonly, retain) NSCharacterSet         *firstCharacterSet;
@property( readonly, assign) MulleObjCTokenRuleFlags flags;

+ (instancetype) ruleWithName:(NSString *) name
                      pattern:(NSString *) pattern;

+ (instancetype) ruleWithName:(NSString *) name
                      pattern:(NSString *) pattern
              firstCharacters:(NSString *) firstCharacters;

+ (instancetype) ruleWithName:(NSString *) name
                      pattern:(NSString *) pattern
              firstCharacters:(NSString *) firstCharacters
                        flags:(MulleObjCTokenRuleFlags) flags;

// the general form: any character the set is a member of. Prefer firstCharacters
// when the set is a finite list you can write down, because the dispatch gets to
// be a lookup and -problem gets to be exact.
+ (instancetype) ruleWithName:(NSString *) name
                      pattern:(NSString *) pattern
           firstCharacterSet:(NSCharacterSet *) firstCharacterSet
                        flags:(MulleObjCTokenRuleFlags) flags;

// YES if the rule says it can start on this character. Only the rule's own
// declaration is consulted, so this is NO for a rule that declares nothing -
// such a rule is a candidate everywhere and the tokenizer knows that separately,
// via -declaresFirstCharacters.
- (BOOL) canStartWithCharacter:(unichar) c;

// NO when neither a literal nor a set was declared, i.e. the rule can start on
// anything.
- (BOOL) declaresFirstCharacters;

@end
