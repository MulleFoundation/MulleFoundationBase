# MulleObjCRegexFoundation Library Documentation for AI
<!-- Keywords: regex, pattern-matching -->

## 1. Introduction & Purpose

MulleObjCRegexFoundation provides powerful regular expression and pattern matching capabilities for NSString through convenient category methods. Supports POSIX regular expressions, bash-style wildcards (with * ? [ ] patterns), and sed-style patterns with backreferences. Enables sophisticated search, replace, and text transformation operations in mulle-objc applications.

## 2. Key Concepts & Design Philosophy

- **Category Extensions**: NSString category adds regex methods without subclassing
- **Multiple Pattern Types**: Supports regex, wildcards, and sed patterns
- **Range-Based Operations**: All operations work within NSString ranges
- **Greedy vs Non-Greedy**: Wildcards support both shortest and longest matching modes
- **Substitution Support**: Full pattern replacement with backreference support
- **Option Flags**: Comprehensive options control matching behavior (anchored, backwards, etc.)

## 3. Core API & Data Structures

### NSString (Regex) Category

#### Pattern Matching Options

```objc
typedef NS_ENUM(NSUInteger, MulleObjCPatternOptions) {
    MulleObjCWildcardsShortestPath = 0x3000,  // Wildcards, shortest match
    MulleObjCWildcards             = 0x1000,  // Wildcards, longest match
    MulleObjCSedPattern            = 0x4000,  // Sed-style with \( \) grouping
    MulleObjCAnchoredSearch        = NSAnchoredSearch,  // Match at boundary
    MulleObjCBackwardsSearch       = NSBackwardsSearch  // Search right to left
};
```

#### Pattern Search Methods

- `- mulleRangeOfPattern:(NSString *)pattern` → `NSRange`: Find first occurrence of pattern
- `- mulleRangeOfPattern:(NSString *)pattern options:(MulleObjCPatternOptions)options` → `NSRange`: Find with options
- `- mulleRangeOfPattern:(NSString *)pattern options:(MulleObjCPatternOptions)options range:(NSRange)range` → `NSRange`: Find within range

#### Pattern Replacement Methods

- `- mulleStringByReplacingPattern:(NSString *)pattern withString:(NSString *)substitution` → `NSString *`: Replace all occurrences
- `- mulleStringByReplacingPattern:(NSString *)pattern withString:(NSString *)substitution options:(MulleObjCPatternOptions)options` → `NSString *`: Replace with options
- `- mulleStringByReplacingPattern:(NSString *)pattern withString:(NSString *)substitution options:(MulleObjCPatternOptions)options range:(NSRange)range` → `NSString *`: Replace within range

### Pattern Types

#### Bash-Style Wildcards (MulleObjCWildcards)

- `*` - Matches zero or more characters
- `?` - Matches exactly one character
- `[a-z]` - Character class (inclusive)
- `[^a-z]` - Negated character class (exclusive)

Matching modes:
- `MulleObjCWildcardsShortestPath`: Matches as few characters as possible (non-greedy)
- `MulleObjCWildcards`: Matches as many characters as possible (greedy)

#### POSIX Regular Expressions (Default)

- Standard regex metacharacters: `^`, `$`, `.`, `*`, `+`, `?`, `|`, `()`, `[]`
- Full POSIX ERE (Extended Regular Expression) support

#### Sed-Style Patterns (MulleObjCSedPattern)

- Uses `\(` and `\)` for grouping instead of standard `()` and `()`
- Backreferences in replacement: `\1`, `\2`, etc. refer to captured groups

## 4. Performance Characteristics

- **Pattern Compilation**: O(m) where m is pattern length (compiled on use)
- **Search**: O(n×m) average case, O(n) for simple wildcards
- **Replacement**: O(n+k) where k is output length
- **Memory**: Immutable strings; no additional allocation during search/replace
- **Thread-Safety**: NSString immutable (thread-safe); pattern options don't modify state

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Choose Right Pattern Type**: Wildcards for simple glob patterns, regex for complex matching
- **Anchor Patterns**: Use `^` and `$` to match start/end of string
- **Test Patterns**: Always test regex patterns for expected behavior before deployment
- **Limit Range**: Use range parameters to limit search scope when possible
- **Precompile Regex**: Consider storing compiled patterns for repeated use

### Common Pitfalls

- **Greedy Matching**: `a*b` matches as much as possible; use `MulleObjCWildcardsShortestPath` for non-greedy
- **Special Characters**: Regex metacharacters need escaping (e.g., `\.` for literal dot)
- **Unicode**: Pattern matching works on characters, not bytes
- **Performance**: Complex regex on large strings can be slow; consider alternative approaches
- **Backreferences**: Only available in sed-style patterns, not standard regex

### Idiomatic Usage

```objc
// Pattern 1: Simple wildcard search
NSRange match = [str mulleRangeOfPattern:@"*.txt"];

// Pattern 2: Regex with anchors
NSRange match = [str mulleRangeOfPattern:@"^[A-Z][a-z]*$"];

// Pattern 3: Replace with sed pattern
NSString *result = [str mulleStringByReplacingPattern:@"\\([0-9]\\)-\\([0-9]\\)" 
                                           withString:@"\2-\1"
                                              options:MulleObjCSedPattern];
```

## 6. Integration Examples

### Example 1: Basic Wildcard Pattern

```objc
#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>

int main() {
    NSString *filename = @"document.txt";
    NSRange match = [filename mulleRangeOfPattern:@"*.txt"];
    
    if (match.location != NSNotFound) {
        NSLog(@"Found .txt file");
    }
    return 0;
}
```

### Example 2: Pattern Search with Options

```objc
#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>

int main() {
    NSString *text = @"HELLO world";
    NSString *pattern = @"[a-z]+";
    
    NSRange match = [text mulleRangeOfPattern:pattern 
                                      options:0];
    
    if (match.location != NSNotFound) {
        NSLog(@"Found lowercase: %@", [text substringWithRange:match]);
    }
    return 0;
}
```

### Example 3: String Replacement with Wildcards

```objc
#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>

int main() {
    NSString *path = @"/usr/local/bin/myapp";
    NSString *result = [path mulleStringByReplacingPattern:@"/*/local/*"
                                                withString:@"/opt"
                                                   options:MulleObjCWildcards];
    
    NSLog(@"New path: %@", result);
    return 0;
}
```

### Example 4: Regex with Backreferences

```objc
#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>

int main() {
    NSString *dates = @"12-31-2024 and 01-15-2025";
    
    // Swap month and day using sed pattern
    NSString *result = [dates mulleStringByReplacingPattern:@"\\([0-9][0-9]\\)-\\([0-9][0-9]\\)"
                                                 withString:@"\2-\1"
                                                    options:MulleObjCSedPattern];
    
    NSLog(@"Swapped: %@", result);
    return 0;
}
```

### Example 5: Range-Limited Search

```objc
#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>

int main() {
    NSString *text = @"The quick brown fox jumps";
    NSRange searchRange = NSMakeRange(10, 10);
    
    NSRange match = [text mulleRangeOfPattern:@"[a-z]+"
                                      options:0
                                        range:searchRange];
    
    if (match.location != NSNotFound) {
        NSLog(@"Found in range: %@", [text substringWithRange:match]);
    }
    return 0;
}
```

### Example 6: Email Validation Pattern

```objc
#import <MulleObjCRegexFoundation/MulleObjCRegexFoundation.h>

int main() {
    NSString *email = @"user@example.com";
    NSString *emailPattern = @"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}$";
    
    NSRange match = [email mulleRangeOfPattern:emailPattern];
    
    if (match.location != NSNotFound) {
        NSLog(@"Valid email");
    } else {
        NSLog(@"Invalid email");
    }
    return 0;
}
```

## 7. Dependencies

- MulleObjCValueFoundation (NSString)
- MulleObjCRegex (underlying regex library)
