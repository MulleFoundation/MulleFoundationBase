# MulleObjCArchiverFoundation Library Documentation for AI

## 1. Introduction & Purpose

MulleObjCArchiverFoundation provides object serialization and deserialization through NSCoding protocol and archiver/unarchiver classes. Enables encoding objects into binary format for storage (files, caches) or transport, and decoding them back. Supports both sequential archiving (NSArchiver/NSUnarchiver) and keyed archiving (NSKeyedArchiver/NSKeyedUnarchiver) for flexibility and forwards compatibility.

## 2. Key Concepts & Design Philosophy

- **NSCoding Protocol**: Objects implement encoding/decoding interface
- **Sequential vs Keyed**: NSArchiver for sequential access, NSKeyedArchiver for named keys
- **Type Encoding**: Preserves type information for safe deserialization
- **Mutable Objects**: Supports proper serialization of mutable containers
- **Reference Cycles**: Handles object graphs with circular references
- **Type Safety**: Validates types during deserialization to prevent corruption

## 3. Core API & Data Structures

### NSCoder (Abstract Base Class)

#### Encoding Methods

- `- encodeObject:(id)obj forKey:(NSString *)key` → `void`: Encode object with key
- `- encodeInt:(int)value forKey:(NSString *)key` → `void`: Encode integer
- `- encodeFloat:(float)value forKey:(NSString *)key` → `void`: Encode float
- `- encodeDouble:(double)value forKey:(NSString *)key` → `void`: Encode double
- `- encodeBool:(BOOL)value forKey:(NSString *)key` → `void`: Encode boolean
- `- encodeBytes:(const void *)bytes length:(NSUInteger)length forKey:(NSString *)key` → `void`: Encode raw data

#### Decoding Methods

- `- decodeObjectForKey:(NSString *)key` → `id`: Decode object
- `- decodeIntForKey:(NSString *)key` → `int`: Decode integer
- `- decodeFloatForKey:(NSString *)key` → `float`: Decode float
- `- decodeDoubleForKey:(NSString *)key` → `double`: Decode double
- `- decodeBoolForKey:(NSString *)key` → `BOOL`: Decode boolean
- `- decodeBytesForKey:(NSString *)key returningLength:(NSUInteger *)lengthp` → `const void *`: Decode raw data

### NSArchiver (Sequential Encoder)

#### Encoding

- `+ archiverWithMutableData:(NSMutableData *)data` → `instancetype`: Create archiver
- `- encodeRootObject:(id)obj` → `void`: Archive top-level object
- `- encodeBycopyObject:(id)obj` → `void`: Archive by value (deep copy)
- `- encodeByrefObject:(id)obj` → `void`: Archive by reference (pointer)
- `- finishEncoding` → `void`: Flush and finalize archive

#### Result

- `- archivedData` → `NSData *`: Get encoded data

### NSUnarchiver (Sequential Decoder)

#### Decoding

- `+ unarchiveObjectWithData:(NSData *)data` → `id`: Convenience decoder
- `- initForReadingWithData:(NSData *)data` → `instancetype`: Initialize decoder
- `- decodeObject` → `id`: Decode next object (root if first call)
- `- finishDecoding` → `void`: Close archive

### NSKeyedArchiver (Keyed Encoder)

#### Encoding

- `+ archivedDataWithRootObject:(id)obj` → `NSData *`: Encode object to data
- `- initForWritingWithMutableData:(NSMutableData *)data` → `instancetype`: Create encoder
- `- encodeObject:(id)obj forKey:(NSString *)key` → `void`: Encode with named key
- `- encodeRootObject:(id)obj` → `void`: Set root object
- `- finishEncoding` → `void`: Finalize encoding
- `- encodingFailureReason` → `NSString *`: Get error reason if encoding failed

### NSKeyedUnarchiver (Keyed Decoder)

#### Decoding

- `+ unarchiveObjectWithData:(NSData *)data` → `id`: Convenience decoder
- `- initForReadingWithData:(NSData *)data` → `instancetype`: Create decoder
- `- decodeObjectForKey:(NSString *)key` → `id`: Decode object by key
- `- containsValueForKey:(NSString *)key` → `BOOL`: Check if key exists
- `- finishDecoding` → `void`: Close decoder
- `- decodingFailureReason` → `NSString *`: Get error reason if decoding failed

### NSCoding Protocol (for Custom Objects)

Implement for custom classes:

```objc
@protocol NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end
```

## 4. Performance Characteristics

- **Encoding**: O(n) where n is object graph size
- **Decoding**: O(n) linear in archived data size
- **Memory**: Decoding creates new object instances; temporary memory proportional to data size
- **Type Checking**: O(1) per field; minimal overhead during serialization
- **Reference Tracking**: Handles cycles efficiently with object ID mapping

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Implement NSCoding**: Any class stored in archives must implement NSCoding protocol
- **Use Keyed Archiving**: Prefer NSKeyedArchiver for forwards/backwards compatibility
- **Version Your Objects**: Include version markers for schema evolution
- **Error Checking**: Always check for encoding/decoding failures
- **Test Round-Trips**: Verify objects survive encode/decode cycle
- **Security**: Validate decoded data; untrusted archives can be malicious

### Common Pitfalls

- **Forgotten NSCoding**: Objects without NSCoding implementation cause runtime errors
- **Type Mismatches**: Decoding as wrong type (e.g., int instead of string) corrupts data
- **Circular References**: Improperly handled circular objects cause infinite loops
- **Version Evolution**: Decoding old archives with new schema may fail silently
- **Security**: Arbitrary object decoding is code execution risk (deserialization attack)

### Idiomatic Usage

```objc
// Pattern 1: Sequential archiving
NSMutableData *data = [NSMutableData data];
NSArchiver *archiver = [NSArchiver archiverWithMutableData:data];
[archiver encodeRootObject:obj];
[archiver finishEncoding];

// Pattern 2: Keyed archiving (preferred)
NSData *archived = [NSKeyedArchiver archivedDataWithRootObject:obj];
id restored = [NSKeyedUnarchiver unarchiveObjectWithData:archived];

// Pattern 3: Custom NSCoding implementation
@implementation MyClass
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:name forKey:@"name"];
    [coder encodeInt:age forKey:@"age"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    name = [[decoder decodeObjectForKey:@"name"] retain];
    age = [decoder decodeIntForKey:@"age"];
    return self;
}
@end
```

## 6. Integration Examples

### Example 1: Archive Object to File

```objc
#import <MulleObjCArchiverFoundation/MulleObjCArchiverFoundation.h>

int main() {
    NSArray *array = [NSArray arrayWithObjects:@"one", @"two", @"three", nil];
    NSData *archived = [NSKeyedArchiver archivedDataWithRootObject:array];
    
    [archived writeToFile:@"/tmp/data.archive" atomically:YES];
    NSLog(@"Archived to /tmp/data.archive");
    
    return 0;
}
```

### Example 2: Unarchive from File

```objc
#import <MulleObjCArchiverFoundation/MulleObjCArchiverFoundation.h>

int main() {
    NSData *data = [NSData dataWithContentsOfFile:@"/tmp/data.archive"];
    NSArray *restored = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSLog(@"Restored array: %@", restored);
    return 0;
}
```

### Example 3: Custom Object with NSCoding

```objc
#import <MulleObjCArchiverFoundation/MulleObjCArchiverFoundation.h>

@interface Person : NSObject <NSCoding>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) int age;
@end

@implementation Person
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:name forKey:@"name"];
    [coder encodeInt:age forKey:@"age"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    name = [[decoder decodeObjectForKey:@"name"] retain];
    age = [decoder decodeIntForKey:@"age"];
    return self;
}

- (void)dealloc {
    [name release];
    [super dealloc];
}
@end

int main() {
    Person *person = [[Person alloc] init];
    person.name = @"Alice";
    person.age = 30;
    
    NSData *archived = [NSKeyedArchiver archivedDataWithRootObject:person];
    Person *restored = [NSKeyedUnarchiver unarchiveObjectWithData:archived];
    
    NSLog(@"Restored: %@ age %d", restored.name, restored.age);
    
    [person release];
    [restored release];
    return 0;
}
```

### Example 4: Using Multiple Objects

```objc
#import <MulleObjCArchiverFoundation/MulleObjCArchiverFoundation.h>

int main() {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:@"first" forKey:@"item1"];
    [archiver encodeObject:@"second" forKey:@"item2"];
    [archiver encodeInt:42 forKey:@"count"];
    
    [archiver finishEncoding];
    [archiver release];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSString *item1 = [unarchiver decodeObjectForKey:@"item1"];
    NSString *item2 = [unarchiver decodeObjectForKey:@"item2"];
    int count = [unarchiver decodeIntForKey:@"count"];
    
    NSLog(@"Items: %@, %@ (count: %d)", item1, item2, count);
    
    [unarchiver finishDecoding];
    [unarchiver release];
    return 0;
}
```

### Example 5: Sequential Archiving (Legacy)

```objc
#import <MulleObjCArchiverFoundation/MulleObjCArchiverFoundation.h>

int main() {
    NSMutableData *data = [NSMutableData data];
    NSArchiver *archiver = [NSArchiver archiverWithMutableData:data];
    
    NSArray *array = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
    [archiver encodeRootObject:array];
    [archiver finishEncoding];
    
    NSUnarchiver *unarchiver = [[NSUnarchiver alloc] initForReadingWithData:data];
    NSArray *restored = [unarchiver decodeObject];
    [unarchiver finishDecoding];
    
    NSLog(@"Restored: %@", restored);
    [unarchiver release];
    return 0;
}
```

### Example 6: Error Handling

```objc
#import <MulleObjCArchiverFoundation/MulleObjCArchiverFoundation.h>

int main() {
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [archiver encodeObject:@"test" forKey:@"value"];
    [archiver finishEncoding];
    
    if ([archiver encodingFailureReason]) {
        NSLog(@"Encoding failed: %@", [archiver encodingFailureReason]);
    }
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id value = [unarchiver decodeObjectForKey:@"value"];
    
    if ([unarchiver decodingFailureReason]) {
        NSLog(@"Decoding failed: %@", [unarchiver decodingFailureReason]);
    }
    
    NSLog(@"Value: %@", value);
    
    [archiver release];
    [unarchiver release];
    return 0;
}
```

## 7. Dependencies

- MulleObjCValueFoundation (NSString, NSData)
- MulleObjCContainerFoundation (NSArray, NSDictionary)
- MulleObjCStandardFoundation

