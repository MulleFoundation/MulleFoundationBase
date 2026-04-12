# MulleObjCUUIDFoundation Library Documentation for AI
<!-- Keywords: uuid, identifiers -->

## 1. Introduction & Purpose

MulleObjCUUIDFoundation provides NSUUID class for generating and working with UUID (Universally Unique Identifier) values. UUIDs are 128-bit values used to uniquely identify objects, requests, transactions, and other entities with extremely high probability of uniqueness across time and space.

## 2. Key Concepts & Design Philosophy

- **Immutable Value**: NSUUID instances are immutable
- **RFC 4122 Compliant**: Follows standard UUID specification
- **Version 4 (Random)**: Primary generation method uses cryptographically secure random
- **Canonical String**: Standard hyphenated format (8-4-4-4-12)
- **Binary Representation**: Direct access to 16-byte UUID data

## 3. Core API & Data Structures

### NSUUID

#### Creation

- `+ UUID` → `instancetype`: Generate random UUID (version 4)
- `+ UUIDWithBytes:(const unsigned char *)bytes` → `instancetype`: Create from 16 bytes
- `+ UUIDWithUUIDString:(NSString *)string` → `instancetype`: Parse string representation
- `- initWithUUIDBytes:(const unsigned char *)bytes` → `instancetype`
- `- initWithUUIDString:(NSString *)string` → `instancetype`

#### Accessors

- `- getUUIDBytes:(unsigned char *)uuid` → `void`: Get 16-byte representation
- `- UUIDString` → `NSString *`: Get canonical string format
- `- description` → `NSString *`: Human-readable string

#### Comparison

- `- isEqual:(id)object` → `BOOL`: Compare UUIDs
- `- hash` → `NSUInteger`: Hash for use in collections

## 4. Performance Characteristics

- **Generation**: O(1) random UUID creation
- **Parsing**: O(1) constant-time parsing
- **String Conversion**: O(1) conversion to/from string
- **Comparison**: O(1) equality check
- **Memory**: Fixed 16 bytes per UUID

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Use for Identifiers**: UUID for any global unique identifier need
- **Cache UUIDs**: Store UUID strings for persistence (smaller than binary)
- **Comparison**: Use isEqual: rather than string comparison
- **Hashing**: Safe to use in NSSet/NSDictionary keys

### Common Pitfalls

- **String Parsing**: Invalid UUID strings may fail silently
- **Collisions**: UUID collisions theoretically possible (but extremely rare)
- **Randomness**: UUID generation depends on quality random source

## 6. Integration Examples

### Example 1: Generate UUID

```objc
#import <MulleObjCUUIDFoundation/MulleObjCUUIDFoundation.h>

int main() {
    NSUUID *uuid = [NSUUID UUID];
    NSLog(@"Generated UUID: %@", [uuid UUIDString]);
    return 0;
}
```

### Example 2: UUID from String

```objc
#import <MulleObjCUUIDFoundation/MulleObjCUUIDFoundation.h>

int main() {
    NSUUID *uuid = [NSUUID UUIDWithUUIDString:@"550e8400-e29b-41d4-a716-446655440000"];
    NSLog(@"Parsed UUID: %@", [uuid UUIDString]);
    return 0;
}
```

### Example 3: UUID in Collection

```objc
#import <MulleObjCUUIDFoundation/MulleObjCUUIDFoundation.h>

int main() {
    NSMutableSet *seen = [NSMutableSet set];
    
    for (int i = 0; i < 5; i++) {
        NSUUID *uuid = [NSUUID UUID];
        [seen addObject:uuid];
        NSLog(@"UUID %d: %@", i, [uuid UUIDString]);
    }
    
    NSLog(@"Unique UUIDs: %lu", [seen count]);
    return 0;
}
```

## 7. Dependencies

- MulleObjC
- MulleFoundationBase
