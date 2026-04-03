# MulleObjCUnicodeFoundation Library Documentation for AI
<!-- Keywords: unicode, character-sets -->

## 1. Introduction & Purpose

MulleObjCUnicodeFoundation adds Unicode 3.x support to mulle-objc through NSString and NSCharacterSet categories. Provides character classification, case conversion, Unicode-aware string operations, and character set utilities. No new classes added; all functionality available through existing Foundation classes via category methods.

## 2. Key Concepts & Design Philosophy

- **Category-Based**: Extends NSString and NSCharacterSet without subclassing
- **Unicode 3.x Standard**: Follows Unicode 3.x specification for character properties
- **Character Classification**: Determine if characters are letters, digits, whitespace, etc.
- **Case Operations**: Uppercase, lowercase, and capitalization aware of Unicode rules
- **Character Sets**: Named predefined sets (letters, digits, punctuation, etc.)
- **Composition**: Support for decomposable characters and Unicode normalization

## 3. Core API & Data Structures

### NSCharacterSet (MulleObjCUnicode) Category

#### Predefined Character Sets

- `+ capitalizedLetterCharacterSet` → `instancetype`: Uppercase letters (Lu category)
- `+ nonBaseCharacterSet` → `instancetype`: Non-base characters (combining marks)
- `+ decomposableCharacterSet` → `instancetype`: Characters with decompositions
- `+ illegalCharacterSet` → `instancetype`: Illegal/unassigned characters

### NSMutableCharacterSet (MulleObjCUnicode) Category

#### Modification Methods

- `- addCombinableCharacters` → `void`: Add Unicode combining characters
- `- addNonCharacterCodePoints` → `void`: Add non-character code points
- `- removeSurrogateCharacters` → `void`: Remove surrogate pairs
- `- removeNonCharacterCodePoints` → `void`: Remove non-characters

### NSString (MulleObjCUnicode) Category

#### Character Classification

- `- isAlpha` → `BOOL`: Check if all characters are alphabetic
- `- isDigit` → `BOOL`: Check if all are digits (0-9)
- `- isAlphaNumeric` → `BOOL`: Check if all are alphanumeric
- `- isWhitespace` → `BOOL`: Check if all are whitespace
- `- isLower` → `BOOL`: Check if all are lowercase letters
- `- isUpper` → `BOOL`: Check if all are uppercase letters
- `- isSpace` → `BOOL`: Check if contains only space characters
- `- isPunctuation` → `BOOL`: Check if all are punctuation

#### Case Conversion

- `- uppercaseString` → `NSString *`: Convert to uppercase
- `- lowercaseString` → `NSString *`: Convert to lowercase
- `- capitalizedString` → `NSString *`: Capitalize first character
- `- mulleDecapitalizedString` → `NSString *`: Decapitalize first character

#### Unicode Properties

- `- unicodeLength` → `NSUInteger`: Count of Unicode characters (not UTF-16 units)
- `- isComposedCharacter:(NSUInteger)index` → `BOOL`: Check if position is composed character
- `- decomposedString` → `NSString *`: Get decomposed form (NFD)
- `- precomposedString` → `NSString *`: Get composed form (NFC)

#### Character Access

- `- unicodeCharacterAtIndex:(NSUInteger)index` → `unichar`: Get Unicode character
- `- unicodeCharactersInRange:(NSRange)range` → `NSString *`: Get substring of Unicode characters

### NSCharacterSet - Base API Reference

While not new in this library, these are essential related methods:

#### Creation

- `+ alphanumericCharacterSet` → `instancetype`: Letters and digits
- `+ letterCharacterSet` → `instancetype`: All Unicode letters
- `+ lowercaseLetterCharacterSet` → `instancetype`: Lowercase letters
- `+ uppercaseLetterCharacterSet` → `instancetype`: Uppercase letters
- `+ decimalDigitCharacterSet` → `instancetype`: Digits 0-9
- `+ whitespaceCharacterSet` → `instancetype`: Whitespace (space, tab, newline)
- `+ whitespaceAndNewlineCharacterSet` → `instancetype`: All whitespace including CR/LF
- `+ punctuationCharacterSet` → `instancetype`: Punctuation marks
- `+ symbolCharacterSet` → `instancetype`: Symbol characters
- `+ newlineCharacterSet` → `instancetype`: Newline characters
- `+ controlCharacterSet` → `instancetype`: Control characters
- `+ characterSetWithCharactersInString:(NSString *)str` → `instancetype`: Create from string
- `+ characterSetWithRange:(NSRange)range` → `instancetype`: Create from Unicode range

#### Testing Membership

- `- characterIsMember:(unichar)character` → `BOOL`: Test single character
- `- longCharacterIsMember:(unsigned int)character` → `BOOL`: Test 32-bit character
- `- isSupersetOfSet:(NSCharacterSet *)other` → `BOOL`: Check containment

#### Operations

- `- invertedSet` → `NSCharacterSet *`: Complement (all characters NOT in set)
- `- union:(NSCharacterSet *)other` → `NSCharacterSet *`: Union of two sets
- `- subtract:(NSCharacterSet *)other` → `NSCharacterSet *`: Difference (members not in other)
- `- intersect:(NSCharacterSet *)other` → `NSCharacterSet *`: Intersection

## 4. Performance Characteristics

- **Character Classification**: O(1) lookup via Unicode tables
- **Case Conversion**: O(n) where n is string length
- **Set Operations**: O(1) membership test; O(n) for union/intersect
- **Memory**: Character sets use efficient bit vectors or lookup tables
- **Unicode Data**: Embedded Unicode 3.x database (lightweight)
- **Thread-Safety**: NSCharacterSet immutable (thread-safe); NSMutableCharacterSet not

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Use Predefined Sets**: Use provided sets rather than creating custom ones
- **Cache Character Sets**: Create once, reuse rather than recreating
- **Input Validation**: Use character sets to validate input strings
- **Normalize Unicode**: Use decomposed/precomposed forms consistently
- **Case-Insensitive Compare**: Use case conversion before comparison
- **Unicode Aware**: Remember that Unicode strings may be longer than ASCII

### Common Pitfalls

- **UTF-16 vs Unicode**: NSString length is UTF-16 units; use unicodeLength for character count
- **Combining Characters**: Some characters combine (e.g., accents); handled by decomposition
- **Surrogate Pairs**: Characters outside BMP (U+10000+) use surrogate pairs in UTF-16
- **Case Sensitivity**: Unicode case conversion may expand/contract string (ß → SS)
- **Composed Forms**: Same visual character can have multiple representations (é = e + ´)
- **Right-to-Left**: Some scripts (Arabic, Hebrew) read RTL; not handled by NSString

### Idiomatic Usage

```objc
// Pattern 1: Input validation
NSCharacterSet *allowed = [NSCharacterSet alphanumericCharacterSet];
if ([userInput rangeOfCharacterFromSet:allowed].location == NSNotFound) {
    // userInput contains only alphanumeric
}

// Pattern 2: Case-insensitive comparison
NSString *lower1 = [str1 lowercaseString];
NSString *lower2 = [str2 lowercaseString];
if ([lower1 isEqual:lower2]) {
    // Equal ignoring case
}

// Pattern 3: Unicode normalization
NSString *normalized = [userInput precomposedString];

// Pattern 4: Character classification
if ([inputString isAlpha]) {
    // All characters are letters
}
```

## 6. Integration Examples

### Example 1: Character Classification

```objc
#import <MulleObjCUnicodeFoundation/MulleObjCUnicodeFoundation.h>

int main() {
    NSString *str1 = @"abc123";
    NSString *str2 = @"ABC";
    NSString *str3 = @"Hello World";
    
    NSLog(@"'%@' isAlpha: %s", str1, [str1 isAlpha] ? "yes" : "no");     // no
    NSLog(@"'%@' isAlphaNumeric: %s", str1, [str1 isAlphaNumeric] ? "yes" : "no"); // yes
    NSLog(@"'%@' isUpper: %s", str2, [str2 isUpper] ? "yes" : "no");     // yes
    NSLog(@"'%@' isWhitespace: %s", str3, [str3 isWhitespace] ? "yes" : "no"); // no (has letters)
    
    return 0;
}
```

### Example 2: Case Conversion

```objc
#import <MulleObjCUnicodeFoundation/MulleObjCUnicodeFoundation.h>

int main() {
    NSString *input = @"Hello World";
    
    NSString *upper = [input uppercaseString];
    NSString *lower = [input lowercaseString];
    NSString *capitalized = [input capitalizedString];
    
    NSLog(@"Original: %@", input);
    NSLog(@"Uppercase: %@", upper);
    NSLog(@"Lowercase: %@", lower);
    NSLog(@"Capitalized: %@", capitalized);
    
    return 0;
}
```

### Example 3: Character Set Validation

```objc
#import <MulleObjCUnicodeFoundation/MulleObjCUnicodeFoundation.h>

int main() {
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *letters = [NSCharacterSet letterCharacterSet];
    
    NSString *phoneNumber = @"5551234567";
    NSString *name = @"Alice";
    
    // Check if all characters are in set
    NSRange digitRange = [phoneNumber rangeOfCharacterFromSet:
        [digits invertedSet]];
    
    if (digitRange.location == NSNotFound) {
        NSLog(@"Phone number contains only digits");
    }
    
    // Validate username (alphanumeric only)
    NSCharacterSet *allowed = [NSCharacterSet alphanumericCharacterSet];
    NSRange invalidRange = [@"user_name" rangeOfCharacterFromSet:
        [allowed invertedSet]];
    
    if (invalidRange.location != NSNotFound) {
        NSLog(@"Username contains invalid character: %c",
              [@"user_name" characterAtIndex:invalidRange.location]);
    }
    
    return 0;
}
```

### Example 4: String Trimming

```objc
#import <MulleObjCUnicodeFoundation/MulleObjCUnicodeFoundation.h>

int main() {
    NSString *str = @"  \t  Hello World  \n  ";
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSString *trimmed = [str stringByTrimmingCharactersInSet:whitespace];
    NSLog(@"Original: '%@'", str);
    NSLog(@"Trimmed: '%@'", trimmed);
    
    return 0;
}
```

### Example 5: Unicode Normalization

```objc
#import <MulleObjCUnicodeFoundation/MulleObjCUnicodeFoundation.h>

int main() {
    // This é can be represented two ways in Unicode
    NSString *composed = @"café";      // composed form (NFC)
    NSString *decomposed = [composed decomposedString]; // decomposed form (NFD)
    
    NSLog(@"Composed: %@", composed);
    NSLog(@"Decomposed: %@", decomposed);
    NSLog(@"Length composed: %lu", [composed length]);
    NSLog(@"Length decomposed: %lu", [decomposed length]);
    
    // After recomposing, should match original
    NSString *recomposed = [decomposed precomposedString];
    if ([recomposed isEqual:composed]) {
        NSLog(@"Normalization round-trip successful");
    }
    
    return 0;
}
```

### Example 6: Parsing with Character Sets

```objc
#import <MulleObjCUnicodeFoundation/MulleObjCUnicodeFoundation.h>

int main() {
    NSString *input = @"Hello123World456";
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *letters = [NSCharacterSet letterCharacterSet];
    
    NSMutableArray *tokens = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0, [input length]);
    NSRange foundRange;
    
    while (searchRange.location < [input length]) {
        // Find next digit or letter
        foundRange = [input rangeOfCharacterFromSet:letters
                                            options:0
                                              range:searchRange];
        
        if (foundRange.location == NSNotFound) break;
        
        // Extract token
        NSString *token = [input substringWithRange:foundRange];
        [tokens addObject:token];
        
        searchRange.location = foundRange.location + foundRange.length;
        searchRange.length = [input length] - searchRange.location;
    }
    
    NSLog(@"Tokens: %@", tokens);
    
    return 0;
}
```

## 7. Dependencies

- MulleObjCValueFoundation (NSString)
- MulleObjCContainerFoundation (NSArray, NSSet)
- MulleObjCStandardFoundation
- Unicode 3.x database (embedded)
