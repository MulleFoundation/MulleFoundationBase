# MulleFoundationBase Library Documentation for AI

## 1. Introduction & Purpose

MulleFoundationBase is an amalgamated library combining 11 core Foundation libraries into a single, efficient compilation unit. Aggregates platform-independent classes (containers, values, time, regex, plist, archiving, KVC, math, unicode, UUID) without OS-specific dependencies. Provides faster compilation, single linking target, and unified import path while preserving individual library compatibility.

## 2. Key Concepts & Design Philosophy

- **Amalgamation Pattern**: Single compilation unit containing multiple logical components
- **Modular Organization**: Internal folder structure mirrors individual libraries
- **Compatibility**: Preserves original #import paths for seamless integration
- **Performance**: Single library link + faster overall build times
- **Unified Namespace**: All libraries accessible through single header
- **Zero Duplication**: No redundant code; clean composition of dependencies

## 3. Core API & Data Structures

### Constituent Libraries

MulleFoundationBase includes complete implementations of 11 libraries:

#### 1. MulleObjCValueFoundation - Value Classes
- NSString, NSNumber, NSData, NSDate (immutable value types)
- Number representations (int, double, bool)
- String encoding/decoding
- Date/time values

#### 2. MulleObjCStandardFoundation - Base Classes
- NSObject base class
- NSArray, NSSet, NSDictionary (container basics)
- NSRange, NSError
- Standard Objective-C patterns

#### 3. MulleObjCContainerFoundation - Advanced Containers
- NSMutableArray, NSMutableSet, NSMutableDictionary
- NSEnumerator for iteration
- Container categories for manipulation
- Introspection & type checking

#### 4. MulleObjCTimeFoundation - Time & Date Handling
- NSDate/NSTimeInterval for absolute time
- NSTimeZone for timezone support
- NSCalendarDate for calendar operations
- Formatting & parsing

#### 5. MulleObjCUUIDFoundation - Unique Identifiers
- NSUUID for generating/representing UUIDs
- RFC 4122 compliant
- String representations (hyphenated/compact)
- Creation & comparison

#### 6. MulleObjCMathFoundation - Mathematical Functions
- NSNumber math extensions (sin, cos, sqrt, log, exp)
- Trigonometric functions (asin, acos, atan)
- Logarithmic/exponential operations
- Rounding & special functions

#### 7. MulleObjCUnicodeFoundation - Unicode Support
- NSString unicode operations
- NSCharacterSet with unicode categories
- Case conversion (upper, lower, capitalized)
- Character classification (alpha, digit, whitespace)

#### 8. MulleObjCKVCFoundation - Key-Value Coding
- valueForKey/setValue:forKey: dynamic access
- valueForKeyPath for nested access
- Batch operations (valuesForKeys, takeValuesFromDictionary)
- Array/Set aggregates (@sum, @avg, @max, @count)

#### 9. MulleObjCPlistFoundation - Property Lists
- NSPropertyListSerialization for plist I/O
- Multiple formats (binary, XML, text)
- NSCoder protocol implementation
- Serialization/deserialization

#### 10. MulleObjCArchiverFoundation - Object Serialization
- NSArchiver/NSUnarchiver for object encoding
- NSCoder protocol with encode/decode methods
- Class version support
- Portable object serialization

#### 11. MulleObjCRegexFoundation - Regular Expressions
- NSRegularExpression pattern matching
- Pattern search/replace in strings
- Match ranges & captured groups
- Options (case-insensitive, multiline, etc.)

### Single Import Path

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>
```

Provides access to all constituent libraries without individual imports.

### Modular Import Paths (Still Supported)

Individual libraries can be imported directly:

```objc
#import <MulleObjCValueFoundation/MulleObjCValueFoundation.h>
#import <MulleObjCContainerFoundation/MulleObjCContainerFoundation.h>
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>
// etc.
```

### Build Characteristics

- **Single Binary**: Links to one libMulleFoundationBase.a or .so
- **Internal Layering**: Value → Standard → Container → Time/Unicode/Math/KVC/Plist/Regex/Archiver
- **No External Dependencies**: Platform-independent (except system libc/libm)
- **Reduced Link Time**: Single library lookup vs. 11 individual libraries
- **Compilation Speed**: Parallelizable build within single unit

## 4. Performance Characteristics

- **Linking**: O(1) single library lookup (faster than 11 separate lookups)
- **Memory**: Single allocation unit; better locality than fragmented linking
- **Compilation**: Faster incremental rebuilds (single build target)
- **Runtime**: Identical to individual libraries (zero overhead)
- **Build Size**: Similar to sum of individual libraries (slight overhead reduction)
- **Library Loading**: Single dlopen/dyld operation vs. 11 individual loads

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Use Unified Import**: Include MulleFoundationBase.h for simplicity in most code
- **Preserve Modular Imports**: If code documents dependencies, keep specific imports
- **Leverage All Classes**: Amalgamation designed for use of entire ecosystem
- **Build Once**: Link once against single library; simplifies linking flags
- **Cross-Module**: Safely use classes from different constituent libraries together
- **Know Dependencies**: Understand layer ordering for optimal linking

### Common Pitfalls

- **Missing Classes**: Not realizing all constituent libraries included
- **Obsolete Split Linking**: Trying to link individual libraries when base available
- **Import Confusion**: Using wrong #import path when both work
- **Dependency Order**: Inner libraries depend on outer ones; ordering matters for custom builds
- **Version Mismatch**: Constituent versions locked; can't mix versions
- **Symbol Conflicts**: All constituent symbols present; potential name collisions if extending

### Idiomatic Usage

```objc
// Pattern 1: Import everything from MulleFoundationBase
#import <MulleFoundationBase/MulleFoundationBase.h>

// Now have access to all 11 constituent libraries
NSArray *arr = [NSArray array];
NSDate *date = [NSDate date];
NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*"];
NSUUID *uuid = [NSUUID UUID];
NSArchiver *archiver = [NSArchiver archiver];

// Pattern 2: Individual constituent imports still work
#import <MulleObjCValueFoundation/MulleObjCValueFoundation.h>
NSString *str = @"value";

// Pattern 3: Mix classes from different constituents
NSArray *uuids = [NSArray array];
for (int i = 0; i < 10; i++) {
    [uuids addObject:[NSUUID UUID]];
}
NSDate *createdAt = [NSDate date];
NSDictionary *record = @{@"uuids": uuids, @"created": createdAt};
```

## 6. Integration Examples

### Example 1: Using Multiple Constituent Libraries

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int main() {
    // From MulleObjCValueFoundation
    NSString *name = @"Project";
    NSDate *created = [NSDate date];
    
    // From MulleObjCUUIDFoundation
    NSUUID *projectId = [NSUUID UUID];
    
    // From MulleObjCContainerFoundation
    NSMutableArray *tasks = [NSMutableArray array];
    
    // From MulleObjCTimeFoundation
    NSCalendarDate *today = [NSCalendarDate calendarDate];
    
    // From MulleObjCMathFoundation
    NSNumber *version = [NSNumber numberWithDouble:1.5];
    NSNumber *rounded = [[version sqrt] ceil];
    
    NSLog(@"Project: %@ (v%@)", name, rounded);
    NSLog(@"ID: %@", [projectId UUIDString]);
    NSLog(@"Created: %@", created);
    
    return 0;
}
```

### Example 2: Building Complex Data Structures

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int main() {
    NSMutableArray *users = [NSMutableArray array];
    
    for (int i = 0; i < 3; i++) {
        NSMutableDictionary *user = [NSMutableDictionary dictionary];
        [user setObject:[NSString stringWithFormat:@"User%d", i] forKey:@"name"];
        [user setObject:[NSUUID UUID] forKey:@"id"];
        [user setObject:[NSDate date] forKey:@"joinDate"];
        [users addObject:user];
    }
    
    // Use KVC to extract all user IDs
    NSArray *userIds = [users valueForKey:@"id"];
    NSLog(@"User IDs: %@", userIds);
    
    // Count users via KVC
    NSNumber *count = [users valueForKey:@"@count"];
    NSLog(@"Total users: %@", count);
    
    return 0;
}
```

### Example 3: Pattern Matching with Regex

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int main() {
    NSString *text = @"Email: user@example.com and admin@company.org";
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression 
        regularExpressionWithPattern:@"[\\w\\.-]+@[\\w\\.-]+"
                             options:0
                               error:&error];
    
    if (error) {
        NSLog(@"Regex error: %@", error);
        return 1;
    }
    
    NSArray *matches = [regex matchesInString:text options:0 
                                       range:NSMakeRange(0, [text length])];
    
    NSLog(@"Found %lu emails:", [matches count]);
    for (NSTextCheckingResult *match in matches) {
        NSString *email = [text substringWithRange:[match range]];
        NSLog(@"  - %@", email);
    }
    
    return 0;
}
```

### Example 4: Serialization with Archiver

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

@interface Person : NSObject <NSCoding>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSUUID *id;
@property (nonatomic, retain) NSDate *birthDate;
@end

@implementation Person
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_id forKey:@"id"];
    [coder encodeObject:_birthDate forKey:@"birthDate"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    _name = [[coder decodeObjectForKey:@"name"] retain];
    _id = [[coder decodeObjectForKey:@"id"] retain];
    _birthDate = [[coder decodeObjectForKey:@"birthDate"] retain];
    return self;
}
@end

int main() {
    Person *person = [[Person alloc] init];
    person.name = @"Alice";
    person.id = [NSUUID UUID];
    person.birthDate = [NSDate date];
    
    // Archive to data
    NSMutableData *data = [NSMutableData data];
    NSArchiver *archiver = [NSArchiver archiverWithMutableData:data];
    [archiver encodeRootObject:person];
    [archiver finishEncoding];
    
    NSLog(@"Archived %lu bytes", [data length]);
    
    // Unarchive from data
    NSUnarchiver *unarchiver = [NSUnarchiver unarchiverWithData:data];
    Person *restored = [unarchiver decodeObject];
    NSLog(@"Restored: %@ (%@)", restored.name, [restored.id UUIDString]);
    
    [person release];
    [restored release];
    
    return 0;
}
```

### Example 5: Property List I/O

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int main() {
    NSDictionary *config = @{
        @"appName": @"MyApp",
        @"version": @"1.0",
        @"enabled": @YES,
        @"launchDate": [NSDate date],
        @"maxRetries": @5
    };
    
    // Serialize to plist
    NSError *error = nil;
    NSData *plistData = [NSPropertyListSerialization 
        dataWithPropertyList:config
                     format:NSPropertyListXMLFormat
                    options:0
                      error:&error];
    
    if (error) {
        NSLog(@"Serialization error: %@", error);
        return 1;
    }
    
    // Deserialize from plist
    NSDictionary *restored = [NSPropertyListSerialization 
        propertyListWithData:plistData
                    options:NSPropertyListImmutable
                     format:NULL
                      error:&error];
    
    NSLog(@"Restored app: %@", [restored objectForKey:@"appName"]);
    
    return 0;
}
```

### Example 6: Time & Date Operations

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int main() {
    NSDate *now = [NSDate date];
    NSDate *tomorrow = [now addTimeInterval:86400];  // 1 day in seconds
    
    NSCalendarDate *calDate = [NSCalendarDate dateWithYear:2025 
                                                     month:12 
                                                       day:25 
                                                       hour:9 
                                                     minute:0 
                                                     second:0 
                                                   timeZone:nil];
    
    NSLog(@"Today: %@", now);
    NSLog(@"Tomorrow: %@", tomorrow);
    NSLog(@"Christmas 2025: %@", calDate);
    
    // Calculate difference
    NSTimeInterval diff = [tomorrow timeIntervalSinceDate:now];
    NSLog(@"Difference: %.0f seconds (%.1f hours)", diff, diff / 3600.0);
    
    return 0;
}
```

### Example 7: UUID Generation & Comparison

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int main() {
    NSUUID *uuid1 = [NSUUID UUID];
    NSUUID *uuid2 = [NSUUID UUID];
    NSUUID *uuid1Copy = uuid1;
    
    NSLog(@"UUID1: %@", [uuid1 UUIDString]);
    NSLog(@"UUID2: %@", [uuid2 UUIDString]);
    
    if ([uuid1 isEqual:uuid1Copy]) {
        NSLog(@"UUID1 and UUID1Copy are identical");
    }
    
    if (![uuid1 isEqual:uuid2]) {
        NSLog(@"UUID1 and UUID2 are different");
    }
    
    // Use in collections
    NSMutableSet *uniqueIds = [NSMutableSet set];
    [uniqueIds addObject:uuid1];
    [uniqueIds addObject:uuid2];
    [uniqueIds addObject:uuid1];  // Won't duplicate
    
    NSLog(@"Unique UUIDs: %lu", [uniqueIds count]);
    
    return 0;
}
```

### Example 8: Complete Ecosystem Example

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int main() {
    // Create data structures using all libraries
    NSMutableArray *records = [NSMutableArray array];
    
    for (int i = 0; i < 3; i++) {
        NSMutableDictionary *record = [NSMutableDictionary dictionary];
        
        // From ValueFoundation
        [record setObject:[NSString stringWithFormat:@"Record%d", i] forKey:@"name"];
        [record setObject:[NSNumber numberWithInt:i * 10] forKey:@"value"];
        
        // From UUIDFoundation
        [record setObject:[NSUUID UUID] forKey:@"id"];
        
        // From TimeFoundation
        [record setObject:[NSDate date] forKey:@"created"];
        
        // From MathFoundation
        NSNumber *magnitude = [[NSNumber numberWithDouble:i] sqrt];
        [record setObject:magnitude forKey:@"magnitude"];
        
        [records addObject:record];
    }
    
    // Use KVC aggregates from KVCFoundation
    NSNumber *avgValue = [records valueForKey:@"@avg.value"];
    NSNumber *maxValue = [records valueForKey:@"@max.value"];
    NSArray *names = [records valueForKey:@"name"];
    
    NSLog(@"Records: %lu", [records count]);
    NSLog(@"Avg value: %@", avgValue);
    NSLog(@"Max value: %@", maxValue);
    NSLog(@"Names: %@", names);
    
    // Serialize with PlistFoundation
    NSError *error = nil;
    NSData *plistData = [NSPropertyListSerialization 
        dataWithPropertyList:records
                     format:NSPropertyListXMLFormat
                    options:0
                      error:&error];
    
    if (!error) {
        NSLog(@"Serialized to %lu bytes", [plistData length]);
    }
    
    return 0;
}
```

## 7. Constituent Library Dependencies

The 11 constituent libraries have internal dependencies:

```
MulleObjCValueFoundation (NSNumber, NSString, NSData, NSDate)
├─ MulleObjCStandardFoundation (NSObject, NSArray, NSSet)
├─ MulleObjCContainerFoundation (Mutable containers)
├─ MulleObjCMathFoundation (Math functions on NSNumber)
├─ MulleObjCUnicodeFoundation (Unicode on NSString)
├─ MulleObjCUUIDFoundation (NSUUID)
├─ MulleObjCTimeFoundation (Time/Calendar extensions)
├─ MulleObjCKVCFoundation (Key-Value Coding)
├─ MulleObjCPlistFoundation (Plist serialization)
├─ MulleObjCArchiverFoundation (Object archiving)
└─ MulleObjCRegexFoundation (Regular expressions)
```

All constituent libraries layer on MulleObjCStandardFoundation and MulleObjCValueFoundation. No circular dependencies.

## 8. Linking

Link against single library:

```sh
-lMulleFoundationBase
```

No need to link constituent libraries individually when using the amalgamation.
