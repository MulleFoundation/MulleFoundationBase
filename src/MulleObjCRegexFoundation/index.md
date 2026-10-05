# MulleObjCRegexFoundation Library Documentation for AI
<!-- Keywords: regex, wildcards, sed, pattern-matching, replace -->

## 1. Introduction & Purpose

MulleObjCRegexFoundation adds powerful search and replace capabilities to
`NSString` through an Objective-C category, without subclassing. It supports
four pattern dialects:

- **POSIX-style regular expressions** (the default), with `(...)` grouping and
  `\1`..`\9` backreferences in substitutions.
- **Bash-style wildcards** (`*`, `?`, `[a-z]`, `[^a-z]`), matched greedily or
  non-greedily.
- **Sed-style patterns** using `\(` and `\)` for grouping.
- **Extended patterns** (`MulleObjCExtendedPattern`) with escapes and named
  classes such as `[[:alpha:]]` and `[[:ident:]]`.

Internally, patterns are converted to UTF-32 and compiled with the
`mulle-utf32regex` engine (from `mulle-regex`). The core `NSString` category
offers one options enum and two methods (with overloads). On top of it sit
compiled patterns with capture groups and match enumeration
(`MulleObjCPattern`), an `NSScanner` category, and a table-driven tokenizer
built from patterns (`MulleObjCToken*`). It is a component of the
`MulleFoundation` library and depends on `MulleObjCValueFoundation` for
`NSString` and `NSRange`.

## 2. Key Concepts & Design Philosophy

- **Category extension**: `@interface NSString ( Regex)` augments
  `NSString` with regex methods directly; no factory, subclass, or allocator
  involvement is needed.
- **Pattern dialects selected by options**: a single `MulleObjCPatternOptions`
  bitmask switches between wildcards, sed, and default regex behavior, and
  additionally anchors or reverses the search.
- **First-match semantics**: all operations find or replace only the *first*
  match in the given range. Replacement is not global.
- **Option-based anchoring**: `NSAnchoredSearch` and `NSBackwardsSearch` are
  implemented by prepending `^` and appending `$` to the compiled pattern.
- **Pure operations**: `NSString` is immutable; methods return a new string
  (or the receiver itself when nothing matches) and never mutate the receiver.
- **Compiled patterns**: `MulleObjCPattern` compiles a pattern once and can
  then find, enumerate and replace *all* matches (the `NSString` category only
  does the first). Options are baked in at compile time.
- **Table-driven tokenizer**: `MulleObjCTokenSet` is an ordered table of
  `MulleObjCTokenRule` patterns; `MulleObjCTokenizer` is a cursor into one
  text with one table. The table is instance data, so no global state.

## 3. Core API & Data Structures

### 3.1. `src/NSString+Regex.h`

This header contains the `NSString` category and the `MulleObjCPatternOptions`
enum (the compiled-pattern and tokenizer classes are in their own headers
below).

#### `MulleObjCPatternOptions` (options bitmask)

```c
typedef   NS_ENUM( NSUInteger, MulleObjCPatternOptions)
{
   MulleObjCWildcardsShortestPath = 0x3000,              // #1#  // also sets MulleWildcards
   MulleObjCWildcards             = 0x1000,              // #2#
   MulleObjCSedPattern            = 0x4000,              // use \( instead of ( for grouping
   MulleObjCExtendedPattern       = 0x8000,              // #3#
   MulleObjCAnchoredSearch        = NSAnchoredSearch,
   MulleObjCBackwardsSearch       = NSBackwardsSearch
};
```

- **Purpose:** Selects the pattern dialect and matching direction.
- `MulleObjCWildcardsShortestPath (0x3000)`: wildcards, matches the shortest
  possible range (`x*y` behaves like `x`; `a*c` on `abcabc` matches only `abc`).
  Implies `MulleObjCWildcards`.
- `MulleObjCWildcards (0x1000)`: wildcards, extends the match as far as
  possible (`a*c` on `abcabc` matches `abcabc` entirely). No grouping, so
  replacement replaces the whole match.
- `MulleObjCSedPattern (0x4000)`: sed syntax; `\(` and `\)` are grouping;
  plain `(` and `)` become literals.
- `MulleObjCExtendedPattern (0x8000)`: extended pattern language, which adds
  escapes and named classes to character classes: `[ \t\r\n]` (space, tab,
  carriage return, newline) and `[[:space:]]`, `[[:alpha:]]`, `[[:digit:]]`,
  `[[:alnum:]]`, `[[:word:]]`, `[[:punct:]]`, `[[:ident:]]`, `[[:identstart:]]`,
  `[[:identcont:]]` (named classes resolved by mulle-unicode). Without it a
  backslash is an ordinary character, so `[ \t\r\n]` is the set
  `{ ' ', '\\', 't', 'r', 'n' }`. Independent of the other options.
- `MulleObjCAnchoredSearch` (= `NSAnchoredSearch`): anchor at the beginning
  of the input (a `^` is prepended).
- `MulleObjCBackwardsSearch` (= `NSBackwardsSearch`): anchor at the end of
  the input (a `$` is appended).

If neither wildcard nor sed option is given, the pattern is passed verbatim to
the regex engine (default dialect, `(...)` grouping).

#### `@interface NSString ( Regex)`

All message sends are of the form `[receiver message:arg]`. `NSString` is
immutable; these methods never modify the receiver.

Lifecycle: none. Instances are plain `NSString` values.

- `- (NSRange) mulleRangeOfPattern:(NSString *) pattern;`
  Find the range (location,length) of the first match of `pattern` in the full
  string, default options.
- `- (NSRange) mulleRangeOfPattern:(NSString *) pattern
                        options:(MulleObjCPatternOptions) options;`
  Same, with a pattern dialect / anchor options bitmask.
- `- (NSRange) mulleRangeOfPattern:(NSString *) pattern
                        options:(MulleObjCPatternOptions) options
                          range:(NSRange) range;`
  Same, restricted to `range` of the receiver; result locations are absolute
  (offset by `range.location`).
- `- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution;`
  Replace the first match of `pattern` with `substitution`, default options.
  Returns the receiver itself if the pattern does not match.
- `- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution
                                     options:(MulleObjCPatternOptions) options;`
  Same, with options.
- `- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution
                                     options:(MulleObjCPatternOptions) options
                                       range:(NSRange) range;`
  Same, restricted to `range`.

Behavioral notes (from the implementation):

- **Return values on no match:** `mulleRangeOfPattern` initializes its result
  to `NSRangeMake( NSNotFound, 0)`. If the pattern compiles and executes
  without error but does not match, it returns `NSRangeMake( 0, 0)` instead.
  `NSNotFound` only surfaces on compile/execute failure. `mulleStringByReplacingPattern`
  returns the receiver (`self`) when there is no match.
- **Substitution backreferences:** `\1`..`\9` in `substitution` refer to
  captured groups, in both the default and sed dialects (the engine resolves
  them). There is no grouping with wildcards; the whole matched range is
  replaced by `substitution`.
- **Option composition:** `MulleObjCWildcards|NSAnchoredSearch`,
  `MulleObjCWildcardsShortestPath`, `MulleObjCSedPattern` etc. combine freely
  with `NSAnchoredSearch` / `NSBackwardsSearch` via `|`.

### 3.2. `src/MulleObjCRegexFoundation.h`

The umbrella include; it pulls in `import.h`, `NSString+Regex.h`,
`NSScanner+Regex.h`, `MulleObjCPattern.h`, `MulleObjCPatternEnumerator.h`,
`MulleObjCPatternMatch.h`, and the tokenizer headers `MulleObjCToken.h`,
`MulleObjCTokenRule.h`, `MulleObjCTokenProblem.h`, `MulleObjCTokenSet.h`,
`MulleObjCTokenizer.h`, and sets:

```c
#define MULLE_OBJC_REGEX_FOUNDATION_VERSION   ((0UL << 20) | (21 << 8) | 0)
```

`src/generic/MulleObjCDeps+MulleObjCRegexFoundation.h` declares the
`MulleObjCDeps( MulleObjCRegexFoundation)` loader class used by the
mulle-objc runtime to load this library's dependencies; you normally do not
call it yourself.

### 3.3. `src/MulleObjCPattern.h`

A compiled regular expression, with capture groups and match enumeration. The
pattern language and options are the ones of
`NSString( Regex) -mulleRangeOfPattern:options:range:`. Because mulle-regex
converts pattern options (anchoring, wildcards, sed, extended) into the pattern
itself, the options are baked in at compilation time and cannot be varied per
search. The engine works on the buffer handed to it, so `^` matches the start
of each search and `$` the end of the searched range.

```objc
@interface MulleObjCPattern : NSObject

+ (instancetype) patternWithString:(NSString *) pattern;
+ (instancetype) patternWithString:(NSString *) pattern
                           options:(MulleObjCPatternOptions) options;

// returns nil, if the pattern is malformed
- (instancetype) initWithString:(NSString *) pattern
                        options:(MulleObjCPatternOptions) options;

- (NSUInteger) numberOfCaptureGroups;

- (MulleObjCPatternMatch *) firstMatchInString:(NSString *) string;
- (MulleObjCPatternMatch *) firstMatchInString:(NSString *) string
                                          range:(NSRange) range;

- (NSArray *) matchesInString:(NSString *) string;
- (NSArray *) matchesInString:(NSString *) string
                        range:(NSRange) range;

- (NSUInteger) numberOfMatchesInString:(NSString *) string;
- (NSUInteger) numberOfMatchesInString:(NSString *) string
                                 range:(NSRange) range;

- (MulleObjCPatternEnumerator *) matchEnumeratorInString:(NSString *) string;
- (MulleObjCPatternEnumerator *) matchEnumeratorInString:(NSString *) string
                                                   range:(NSRange) range;

- (NSString *) stringByReplacingMatchesInString:(NSString *) string
                                    withTemplate:(NSString *) template;

- (NSString *) stringByReplacingMatchesInString:(NSString *) string
                                          range:(NSRange) range
                                    withTemplate:(NSString *) template;

@end
```

The `template` understands `&` for the whole match, `\1`..`\9` for the capture
groups and `\0nnn` for an octal character, exactly like
`-mulleStringByReplacingPattern:withString:`.

### 3.4. `src/MulleObjCPatternMatch.h`

A single match of a `MulleObjCPattern`, including its capture groups. Group 0
is the whole match, so a pattern with n groups yields n + 1 ranges. The range of
a group that did not participate in the match is `NSNotFound`;
`-substringOfCaptureGroupAtIndex:` returns nil for such a group.

```objc
#define MULLE_OBJC_PATTERN_MAX_CAPTURE_GROUPS   9

@interface MulleObjCPatternMatch : NSObject

+ (instancetype) matchWithString:(NSString *) string
                          ranges:(NSRange *) ranges
                           count:(NSUInteger) count;

- (instancetype) initWithString:(NSString *) string
                         ranges:(NSRange *) ranges
                          count:(NSUInteger) count;

- (NSUInteger) numberOfCaptureGroups;

- (NSRange) range;
- (NSRange) rangeOfCaptureGroupAtIndex:(NSUInteger) index;

- (NSString *) substring;
- (NSString *) substringOfCaptureGroupAtIndex:(NSUInteger) index;

- (NSString *) string;

@end
```

### 3.5. `src/MulleObjCPatternEnumerator.h`

Enumerates the matches of a `MulleObjCPattern` lazily, one match at a time. It
conforms to `NSFastEnumeration`, so
`for( MulleObjCPatternMatch *match in [pattern matchEnumeratorInString:...])`
works. The string is converted to unichar once, so enumerating a large string
is not quadratic.

```objc
@interface MulleObjCPatternEnumerator : NSObject < NSFastEnumeration >

+ (instancetype) enumeratorWithPattern:(MulleObjCPattern *) pattern
                                string:(NSString *) string
                                 range:(NSRange) range;

- (instancetype) initWithPattern:(MulleObjCPattern *) pattern
                          string:(NSString *) string
                           range:(NSRange) range;

// returns nil, when all matches have been returned
- (MulleObjCPatternMatch *) nextObject;

// the total number of matches in the range, independent of how far the
// enumeration has progressed
- (NSUInteger) count;

- (NSUInteger) countByEnumeratingWithState:(NSFastEnumerationState *) state
                                   objects:(id *) objects
                                     count:(NSUInteger) count;

@end
```

### 3.6. `src/NSScanner+Regex.h`

Pattern scanning: what `NSScanner` does, but with a language instead of a
character set or a literal. `-scanString:` bounds who can match, `-scanPattern:`
asks whether a pattern matches at the cursor and hands back the match (with its
capture groups). The pattern must match *starting at the cursor* (anchor it), a
zero length match is a failure, and `charactersToBeSkipped` is applied first and
stays consumed when the pattern then fails. The argument is a compiled
`MulleObjCPattern` and not a pattern string, so it is not recompiled per call.

```objc
@interface NSScanner( Regex)

// YES, and the scan location moves over the match
- (BOOL) scanPattern:(MulleObjCPattern *) pattern;

// the same, and hands out the match, so -range, -substring and
// -substringOfCaptureGroupAtIndex: come with it. nil when it returns NO
- (BOOL) scanPattern:(MulleObjCPattern *) pattern
           intoMatch:(MulleObjCPatternMatch **) matchp;

// advance until the pattern matches, gobbling up what was passed over, and leave
// the scan location at the match. NO - with the empty string - when the pattern
// never matches, like -scanUpToString: does it
- (BOOL) scanUpToPattern:(MulleObjCPattern *) pattern
              intoString:(NSString **) stringp;

@end
```

### 3.7. `src/MulleObjCToken.h`

A table-driven tokenizer, in two objects because they have different lifetimes:
a `MulleObjCTokenSet` is the table and a `MulleObjCTokenizer` is a cursor into
one text with one table. One token is which rule matched and where; no
characters unless asked for.

```objc
@interface MulleObjCToken : NSObject

@property( readonly, copy) NSString   *name;          // the rule that matched
@property( readonly) NSRange          range;          // always, into the text
@property( readonly) NSRange          contentRange;   // without a quote pair
@property( readonly, assign) BOOL     isSkip;         // from the rule

+ (instancetype) tokenWithName:(NSString *) name
                         range:(NSRange) range
                  contentRange:(NSRange) contentRange
                        isSkip:(BOOL) isSkip;

// the characters, on demand rather than during the scan
- (NSString *) stringInText:(NSString *) text;

// the characters without the surrounding quotes, for a Content rule
- (NSString *) contentInText:(NSString *) text;

@end
```

### 3.8. `src/MulleObjCTokenRule.h`

One entry of a `MulleObjCTokenSet`'s table. `pattern` is an extended pattern
(`MulleObjCExtendedPattern`) and must be able to match the first character of a
token, or the rule will never be reached in order. What a rule can start on is
declared with `firstCharacters` (an exact literal string, which makes dispatch a
lookup and `-problem` exact) or `firstCharacterSet` (general, only the literal
part is checkable). A rule that declares neither can start on anything.

```objc
typedef enum
{
   MulleObjCTokenRuleDefault = 0,
   MulleObjCTokenRuleSkip    = 1 << 0,   // whitespace, comments
   MulleObjCTokenRuleContent = 1 << 1    // contentRange excludes a surrounding quote pair
} MulleObjCTokenRuleFlags;


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

+ (instancetype) ruleWithName:(NSString *) name
                      pattern:(NSString *) pattern
           firstCharacterSet:(NSCharacterSet *) firstCharacterSet
                        flags:(MulleObjCTokenRuleFlags) flags;

- (BOOL) canStartWithCharacter:(unichar) c;

- (BOOL) declaresFirstCharacters;

@end
```

### 3.9. `src/MulleObjCTokenProblem.h`

Something a scan found that the table did not anticipate. A problem is not an
error: the scan still completes, and the answer may still be right, so it comes
back as a value the caller can count, inspect and report. `text` is derived from
`kind` and `count` at construction, so a report cannot disagree with the problem
it describes.

```objc
typedef enum
{
   // every candidate was tried at the cursor and none matched, so the
   // tokenizer had to step over the character
   MulleObjCTokenProblemUnrecognizedCharacter = 1,
   // a rule matched, but no rule had declared that it can start there
   MulleObjCTokenProblemUndeclaredStart        = 2
} MulleObjCTokenProblemKind;


@interface MulleObjCTokenProblem : NSObject

@property( readonly, assign) MulleObjCTokenProblemKind kind;
// how many times it happened, not how many problems were found
@property( readonly, assign) NSUInteger                count;
// one clause, no file name and no trailing punctuation: the caller joins them
@property( readonly, copy)   NSString                 *text;

- (instancetype) initWithKind:(MulleObjCTokenProblemKind) kind
                        count:(NSUInteger) count;

+ (instancetype) problemWithKind:(MulleObjCTokenProblemKind) kind
                           count:(NSUInteger) count;

@end
```

### 3.10. `src/MulleObjCTokenSet.h`

The table: rules, plus the compiled patterns and the start dispatch that both
fall out of them. A subclass is a *language*: it overrides `+rules` and, if it
needs to, `+patternOptions` (extended by default). `+tokenSet` returns nil when
`-problem` found something (under `!NDEBUG` it prints and aborts, because a
degenerate table is a defect in the source). The dynamic counters of what the
table failed to anticipate in the text it actually scanned live on the set, not
on the cursor.

```objc
@interface MulleObjCTokenSet : NSObject

@property( readonly, copy) NSArray                *rules;

// code point -> the rules that declared it (NSNumber keyed)
@property( readonly, retain) NSMutableDictionary  *dispatch;
// the rules whose start is not a finite list
@property( readonly, retain) NSArray              *openRules;
// compiled on first use, kept for the life of the set
@property( readonly, retain) NSMutableDictionary  *patterns;

// override points; default implementations are on the class
+ (NSArray *) rules;
+ (MulleObjCPatternOptions) patternOptions;

+ (instancetype) tokenSet;
+ (instancetype) tokenSetWithRules:(NSArray *) rules;

- (MulleObjCTokenRule *) ruleNamed:(NSString *) name;

- (MulleObjCPattern *) patternForPattern:(NSString *) pattern;

- (NSArray *) candidateRulesForCharacter:(unichar) c;

- (NSString *) problem;

@property( readonly) NSUInteger unrecognizedCount;    // no rule claimed the character
@property( readonly) NSUInteger undeclaredStartCount; // a rule matched, but none had declared it

- (NSArray *) problems;

- (BOOL) hasProblems;

- (void) countUnrecognizedCharacter;
- (void) countUndeclaredStart;

@end
```

### 3.11. `src/MulleObjCTokenizer.h`

The cursor: one text, one table, one position. The counters of what no rule
claimed are on the set, not here, because a cursor is created per call and
thrown away. `+tokenizerWithText:` makes a fresh set every time; pass a held set
via `+tokenizerWithText:tokenSet:` when you already have one, so the patterns
are not recompiled per call.

```objc
@interface MulleObjCTokenizer : NSObject

- (instancetype) initWithText:(NSString *) text
                     tokenSet:(MulleObjCTokenSet *) tokenSet;

@property( readonly) NSString                *text;
@property( readonly, retain) MulleObjCTokenSet *tokenSet;
@property( readonly) NSUInteger              location;

// the table this tokenizer class speaks; default is an empty set
+ (MulleObjCTokenSet *) defaultTokenSet;

+ (instancetype) tokenizerWithText:(NSString *) text;

+ (instancetype) tokenizerWithText:(NSString *) text
                         tokenSet:(MulleObjCTokenSet *) tokenSet;

- (void) setLocation:(NSUInteger) location;

// every token, including the skip rules. nil at the end of the text
- (MulleObjCToken *) nextToken;

// the next token that is not a skip rule, or nil
- (MulleObjCToken *) nextSignificantToken;

@end
```

## 4. Performance Characteristics

- **Pattern compile:** The `NSString` category compiles the pattern from scratch
  on every call (plus an internal `malloc`); `MulleObjCPattern` compiles once
  and is reusable, and a `MulleObjCTokenSet` compiles each of its patterns once
  and keeps them. Compilation is O(m) in the (converted) pattern length.
- **Matching:** The engine is a backtracking regex (Henry Spencer style),
  typical near-linear, worst-case exponential on pathological patterns.
  `NSAnchoredSearch` / `NSBackwardsSearch` produce `^`/`$` anchored patterns
  which prune the search space. Leading literal characters (`regstart`) give
  fast skips.
- **Pattern conversion:** wildcard/sed patterns are rewritten into regex
  before compiling; the buffer grows by a factor of 3 for
  `MulleObjCWildcardsShortestPath`, 2 for `MulleObjCWildcards` /
  `MulleObjCSedPattern`, else 1 (`patternSizeWithOptions`).
- **Replacement:** The `NSString` category replaces the first match only;
  `MulleObjCPattern` replaces all matches. Allocation is O(n + k) in input
  and substitution length (a new `NSString` is built; wildcard mode copies
  through `NSMutableString`). No-match returns the receiver without copying.
- **Thread-safety:** `NSString` is immutable and methods hold no shared
  mutable state, so the operations are thread-safe.

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Choose the dialect deliberately:** use `MulleObjCWildcards` /
  `MulleObjCWildcardsShortestPath` for glob-style patterns and the default
  (no option) or `MulleObjCSedPattern` for grouping/backreference needs.
- **Scope with `range:`** to limit work to a substring; result locations are
  absolute in the receiver.
- **Greediness:** use `MulleObjCWildcardsShortestPath` (0x3000) when a
  wildcard must not extend to the last possible match.
- **Anchoring:** pass `NSAnchoredSearch` (start) or `NSBackwardsSearch` (end)
  via `options:` instead of only relying on `*` spanning everything.
- **Escaping in string literals:** in `@"..."` literals use `\\1`, `\\(` etc.
  to produce a single backslash in the pattern/substitution.

### Common Pitfalls

- **Replacement is not global:** `mulleStringByReplacingPattern` replaces only
  the first match. Do not expect all occurrences to be replaced.
- **No-match range value:** `mulleRangeOfPattern` returns `NSRangeMake( 0, 0)`
  when the pattern simply does not match; checking
  `match.location != NSNotFound` will not detect this case. Only compile or
  execute errors leave `NSNotFound`.
- **Wildcards have no groups:** `\1` backreferences in `substitution` are only
  meaningful with the default or sed dialect.
- **Escaping:** shell users must escape regex metacharacters; `(`/`)` are
  literal under `MulleObjCSedPattern` (use `\(`/`\)` for grouping there), the
  reverse of the default dialect.
- **`MulleObjCWildcardsShortestPath` formatting:** it transforms `*x` into
  `[^x]*x`; be aware of the semantics when a class follows `*`.

### Idiomatic Usage

```objc
// First match of a default regex (case: "VfL Bochum 1848")
NSString  *s;

s = [@"VfL Bxchum 1848" mulleStringByReplacingPattern:@"x"
                                            withString:@"o"];
```

## 6. Integration Examples

### Example 1: Wildcard search (shortest vs. longest)

```objc
#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>


int   main( int argc, char *argv[])
{
   NSRange   shortest;
   NSRange   longest;

   shortest = [@"abcabc" mulleRangeOfPattern:@"a*c"
                                   options:MulleObjCWildcardsShortestPath];
   longest  = [@"abcabc" mulleRangeOfPattern:@"a*c"
                                   options:MulleObjCWildcards];
   mulle_printf( "shortest: %lu %lu\n", shortest.location, shortest.length);
   mulle_printf( "longest:  %lu %lu\n", longest.location, longest.length);
   return( 0);
}
```

### Example 2: Wildcard replace with anchor options

```objc
#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>


int   main( int argc, char *argv[])
{
   mulle_printf( "%@\n", [@"/a/b/c" mulleStringByReplacingPattern:@"*/b"
                                                        withString:@"."
                                                           options:MulleObjCWildcards]);
   mulle_printf( "%@\n", [@"/a/b/c" mulleStringByReplacingPattern:@"*/b"
                                                        withString:@"."
                                                           options:MulleObjCWildcards|NSAnchoredSearch]);
   mulle_printf( "%@\n", [@"/a/b/c" mulleStringByReplacingPattern:@"b/*"
                                                        withString:@"."
                                                           options:MulleObjCWildcards|NSBackwardsSearch]);
   return( 0);
}
```

### Example 3: Sed-style pattern with backreference

```objc
#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>


int   main( int argc, char *argv[])
{
   mulle_printf( "%@\n", [@"/a/b/c" mulleStringByReplacingPattern:@"\\(b\\)"
                                                        withString:@"-\\1-"
                                                           options:MulleObjCSedPattern]);
   return( 0);
}
```

### Example 4: Default regex replace (no options)

```objc
#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>


int   main( int argc, char *argv[])
{
   mulle_printf( "%@\n", [@"VfL Bxchum 1848" mulleStringByReplacingPattern:@"x"
                                                                 withString:@"o"]);
   return( 0);
}
```

### Example 5: Range-limited, anchored search

```objc
#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>


int   main( int argc, char *argv[])
{
   NSRange   match;
   NSRange   range;

   range = NSMakeRange( 6, 11);
   match = [@"lorem ipsum dolor" mulleRangeOfPattern:@"^ipsum"
                                               options:MulleObjCAnchoredSearch
                                                 range:range];
   mulle_printf( "%lu %lu\n", match.location, match.length);
   return( 0);
}
```

## 7. Dependencies

Direct `mulle-sde` dependencies (from `.mulle/etc/sourcetree/config`):

- `MulleObjCValueFoundation` — supplies `NSString`, `NSRange`,
  `NSStringCompareOptions` (`NSAnchoredSearch`, `NSBackwardsSearch`).
- `MulleObjCContainerFoundation` — supplies `NSArray`, `NSMutableDictionary`,
  used by the pattern and tokenizer classes.
- `MulleObjCStandardFoundation` — supplies `NSScanner`, `NSCharacterSet` and
  `NSFastEnumeration`, used by the scanner category and the tokenizer.
- `mulle-objc-list` — build-time tool to inspect mulle-objc runtime
  information in executables.

The regex engine itself is `mulle-regex` (providing `mulle_utf32regex*`,
used via the `mulle-utf32regex.h` API), pulled in transitively through
`MulleObjCValueFoundation`. It is not a direct declared dependency of this
project.