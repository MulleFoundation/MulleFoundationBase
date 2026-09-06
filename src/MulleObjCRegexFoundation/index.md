# MulleObjCRegexFoundation Library Documentation for AI
<!-- Keywords: regex, wildcards, sed, pattern-matching, replace -->

## 1. Introduction & Purpose

MulleObjCRegexFoundation adds powerful search and replace capabilities to
`NSString` through an Objective-C category, without subclassing. It supports
three pattern dialects:

- **POSIX-style regular expressions** (the default), with `(...)` grouping and
  `\1`..`\9` backreferences in substitutions.
- **Bash-style wildcards** (`*`, `?`, `[a-z]`, `[^a-z]`), matched greedily or
  non-greedily.
- **Sed-style patterns** using `\(` and `\)` for grouping.

Internally, patterns are converted to UTF-32 and compiled with the
`mulle-utf32regex` engine (from `mulle-regex`). The public API surface is small:
one options enum and two methods (with overloads). It is a component of the
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

## 3. Core API & Data Structures

### 3.1. `src/NSString+Regex.h`

This header contains the complete public API of the library.

#### `MulleObjCPatternOptions` (options bitmask)

```c
typedef   NS_ENUM( NSUInteger, MulleObjCPatternOptions)
{
   MulleObjCWildcardsShortestPath = 0x3000,              // #1#  // also sets MulleWildcards
   MulleObjCWildcards             = 0x1000,              // #2#
   MulleObjCSedPattern            = 0x4000,              // use \( instead of ( for grouping
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

The umbrella include; it pulls in `import.h`, `NSString+Regex.h`, and sets:

```c
#define MULLE_OBJC_REGEX_FOUNDATION_VERSION   ((0UL << 20) | (20 << 8) | 11)
```

`src/generic/MulleObjCDeps+MulleObjCRegexFoundation.h` declares the
`MulleObjCDeps( MulleObjCRegexFoundation)` loader class used by the
mulle-objc runtime to load this library's dependencies; you normally do not
call it yourself.

## 4. Performance Characteristics

- **Pattern compile:** Every call compiles the pattern from scratch (plus an
  internal `malloc`). Compilation is O(m) in the (converted) pattern length.
  There is no persistent, reusable compiled-pattern object in the public API.
- **Matching:** The engine is a backtracking regex (Henry Spencer style),
  typical near-linear, worst-case exponential on pathological patterns.
  `NSAnchoredSearch` / `NSBackwardsSearch` produce `^`/`$` anchored patterns
  which prune the search space. Leading literal characters (`regstart`) give
  fast skips.
- **Pattern conversion:** wildcard/sed patterns are rewritten into regex
  before compiling; the buffer grows by a factor of 3 for
  `MulleObjCWildcardsShortestPath`, 2 for `MulleObjCWildcards` /
  `MulleObjCSedPattern`, else 1 (`patternSizeWithOptions`).
- **Replacement:** Single first match only. Allocation is O(n + k) in input
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
- `mulle-objc-list` — build-time tool to inspect mulle-objc runtime
  information in executables.

The regex engine itself is `mulle-regex` (providing `mulle_utf32regex*`,
used via the `mulle-utf32regex.h` API), pulled in transitively through
`MulleObjCValueFoundation`. It is not a direct declared dependency of this
project.