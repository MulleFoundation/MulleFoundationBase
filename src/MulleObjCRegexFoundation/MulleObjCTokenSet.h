//
//  MulleObjCTokenSet.h
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK. All rights reserved.
//
//  The table: rules, plus the compiled patterns and the start dispatch that both
//  fall out of them. See MulleObjCToken.h for the reasoning.
//
//  A subclass is a *language*: it answers +rules and, if it needs to, the
//  +patternOptions the patterns are compiled with. Everything else is inherited.
//
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#import "import.h"

// the patterns this table compiles
#import "MulleObjCPattern.h"

#import "MulleObjCTokenRule.h"

// -problems hands these out, so whoever holds a set can name one without
// importing this themselves - the same reason MulleObjCTokenRule.h is above
#import "MulleObjCTokenProblem.h"


@interface MulleObjCTokenSet : NSObject

@property( readonly, copy) NSArray                *rules;

//
// Storage. It has to be in the primary interface, because MulleObjC will not
// synthesize an instance variable for a property declared in a class
// extension, and by the same token it has to be readonly: a readwrite property
// is cleared by the runtime, which would double release what -finalize owns.
//
// Both of these are per set rather than process wide: the engine compiles a
// pattern once per set, and two sets for two languages do not share anything.
//

// code point -> the rules that declared it, for the rules that declared a finite
// list. Built from the declarations, so it is exactly as large as the table says
// and has no opinion about what a character can be. Keyed by NSNumber.
@property( readonly, retain) NSMutableDictionary  *dispatch;

// the rules whose start is not a finite list: one that declared a character set,
// or nothing at all. Empty for a table that declared only literals, which is
// what keeps the lookup above the whole story when it can be.
@property( readonly, retain) NSArray              *openRules;

// compiled on first use, kept for the life of the set
@property( readonly, retain) NSMutableDictionary  *patterns;


// -------------------------------------------------------------------------
// override points. The default implementations of both are on the class, not
// on an instance, so that a subclass is all a language needs to be.
// -------------------------------------------------------------------------

// the table, in the order the rules must be tried. An empty table is a valid
// but useless set, which is why -problem exists.
+ (NSArray *) rules;

// what the patterns are compiled with. Extended by default; a language whose
// patterns are not extended ones can say so.
+ (MulleObjCPatternOptions) patternOptions;


//
// nil when -problem found something. A table that cannot be built is not worth
// handing out: every scan made with it completes and is quietly wrong, which is
// the failure mode the table exists to stop repeating. nil is the one answer no
// caller can mistake for a table, and it is unambiguous here because -problem is
// the only way this factory can fail.
//
// Under NDEBUG it just returns nil. Otherwise assert() prints the problem and
// aborts, because a degenerate table is a defect in the source and no input will
// fix it - reporting it politely to a caller who cannot act would be theatre. A
// test that needs to observe the nil return therefore has to be built with
// NDEBUG, which is the same switch that says "this is shipped and must not
// abort".
//
+ (instancetype) tokenSet;

// as above, for a table assembled at runtime rather than by a +rules override
+ (instancetype) tokenSetWithRules:(NSArray *) rules;

- (MulleObjCTokenRule *) ruleNamed:(NSString *) name;

- (MulleObjCPattern *) patternForPattern:(NSString *) pattern;

//
// The rules that can start on this code point, in table order, or nil when
// nothing declared it. Not for general use - the tokenizer's fallback needs it -
// and nil is not "no rule applies", it is "nobody said".
//
- (NSArray *) candidateRulesForCharacter:(unichar) c;

//
// The table is ordered, so this is the check that the order is not hiding a
// rule, or a pattern that does not compile. Returns a description, or nil.
// Worth asserting on: both of the things it finds produce a scan that completes
// and is wrong.
//
// It is exact for a table that declares literals, which is cmake. A rule that
// declares a character set could be contained in an earlier rule and could not
// be told apart from one that is not, so the check deliberately says nothing
// about those rather than guess: a proof that can be wrong is worse than no
// proof, because it gets trusted.
//
- (NSString *) problem;

//
// What the table failed to anticipate in the text it actually scanned. -problem
// is the static half of the claim a table makes about its language; these are
// the dynamic half.
//
// They live on the set and not on the cursor, which is where they started. A
// cursor is made per call - one per line, in the comment stripper - and thrown
// away, so a count kept on one could not be read by anyone, and was not. The set
// is the thing that is handed down and owned, so the set is the thing that can
// be asked.
//
@property( readonly) NSUInteger unrecognizedCount;    // no rule claimed the character
@property( readonly) NSUInteger undeclaredStartCount; // a rule matched, but none had declared it

//
// The same two facts as MulleObjCTokenProblem objects, one per kind that
// happened, unrecognized first. Empty and not nil when there were none: "no
// problems" is an answer a caller should not have to tell apart from "no
// answer".
//
// This is the interface, and the two counters above are the raw numbers under
// it - a report wants the description, a caller that only branches wants
// -hasProblems. Neither is an error and neither stops a scan.
//
- (NSArray *) problems;

// the cheap form, for a caller that has no use for the descriptions
- (BOOL) hasProblems;

// called by the tokenizer as it scans
- (void) countUnrecognizedCharacter;
- (void) countUndeclaredStart;

@end
