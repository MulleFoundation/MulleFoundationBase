# MulleObjCPlistFoundation Library Documentation for AI
<!-- Keywords: plist, serialization -->

## 1. Introduction & Purpose

MulleObjCPlistFoundation provides property list serialization and deserialization, enabling objects to be converted to human-readable text format (classic Objective-C plist format) and back. PropertyLists are ideal for configuration files, data exchange, and human-editable data storage. Complements NSCoding/archiving with a text-based, portable format.

## 2. Key Concepts & Design Philosophy

- **Text-Based Format**: Human-readable, editable format unlike binary archives
- **Structural Representation**: Supports dictionaries, arrays, strings, numbers, dates
- **Portable**: Cross-platform compatibility; format parseable by other tools
- **Safe Parsing**: Validates format and structure during deserialization
- **Round-Trip Safe**: Objects survive serialize/deserialize cycle without loss

## 3. Core API & Data Structures

### NSPropertyListSerialization

#### Serialization

- `+ dataWithPropertyList:(id)plist format:(NSPropertyListFormat)format options:(NSPropertyListWriteOptions)opts error:(NSError **)error` → `NSData *`: Serialize object to data
- `+ stringWithPropertyList:(id)plist format:(NSPropertyListFormat)format` → `NSString *`: Serialize to string

#### Deserialization

- `+ propertyListWithData:(NSData *)data options:(NSPropertyListReadOptions)opts format:(NSPropertyListFormat *)format error:(NSError **)error` → `id`: Parse data
- `+ propertyListWithString:(NSString *)string format:(NSPropertyListFormat *)format` → `id`: Parse string

#### Formats

- `NSPropertyListOpenStepFormat`: Classic Objective-C format (default, human-readable)
- `NSPropertyListXMLFormat`: XML format
- `NSPropertyListBinaryFormat`: Binary compact format

#### Options

- `NSPropertyListImmutable`: Return immutable collections
- `NSPropertyListMutableContainers`: Mutable dictionaries/arrays
- `NSPropertyListMutableContainersAndLeaves`: Mutable everything

## 4. Performance Characteristics

- **Parsing**: O(n) where n is file size
- **Serialization**: O(n) in output size
- **Memory**: Deserializing creates object graph in memory
- **Readability**: Text format human-readable; compact representation smaller than JSON

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Use for Configuration**: Ideal for config files (readable, editable)
- **Type Validation**: Always check returned object type matches expected structure
- **Error Handling**: Check error parameter; invalid plists raise exceptions
- **Immutable Parsing**: Parse as immutable when possible for thread-safety
- **Backup Format**: Use for backup/export (text portable, survives tool changes)

### Common Pitfalls

- **Format Mismatches**: Parsing XML plist as OpenStep fails; check format
- **Type Assumptions**: Don't assume structure; validate parsed object
- **Circular References**: Plist format doesn't support circular object references
- **Performance**: Text format larger than binary; use binary for large data
- **Dates Encoded Strangely**: Date objects may not preserve exact timestamps

## 6. Integration Examples

### Example 1: Serialize Dictionary

```objc
#import <MulleObjCPlistFoundation/MulleObjCPlistFoundation.h>

int main() {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"Alice", @"name",
        [NSNumber numberWithInt:30], @"age",
        nil];
    
    NSError *error = nil;
    NSData *plistData = [NSPropertyListSerialization 
        dataWithPropertyList:dict 
        format:NSPropertyListOpenStepFormat 
        options:0 
        error:&error];
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    } else {
        NSLog(@"Plist length: %lu bytes", [plistData length]);
    }
    
    return 0;
}
```

### Example 2: Parse Plist from String

```objc
#import <MulleObjCPlistFoundation/MulleObjCPlistFoundation.h>

int main() {
    NSString *plistStr = @"{name = Alice; age = 30;}";
    NSPropertyListFormat format;
    
    id obj = [NSPropertyListSerialization 
        propertyListWithString:plistStr 
        format:&format];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)obj;
        NSLog(@"Name: %@", [dict objectForKey:@"name"]);
    }
    
    return 0;
}
```

### Example 3: Save and Load Configuration

```objc
#import <MulleObjCPlistFoundation/MulleObjCPlistFoundation.h>

int main() {
    // Save
    NSDictionary *config = [NSDictionary dictionaryWithObjectsAndKeys:
        @"localhost", @"host",
        [NSNumber numberWithInt:8080], @"port",
        nil];
    
    NSError *error = nil;
    NSData *data = [NSPropertyListSerialization 
        dataWithPropertyList:config 
        format:NSPropertyListOpenStepFormat 
        options:0 
        error:&error];
    
    [data writeToFile:@"config.plist" atomically:YES];
    
    // Load
    NSData *loadedData = [NSData dataWithContentsOfFile:@"config.plist"];
    NSDictionary *loadedConfig = [NSPropertyListSerialization 
        propertyListWithData:loadedData 
        options:NSPropertyListImmutable 
        format:NULL 
        error:&error];
    
    NSLog(@"Host: %@", [loadedConfig objectForKey:@"host"]);
    
    return 0;
}
```

### Example 4: Nested Structure

```objc
#import <MulleObjCPlistFoundation/MulleObjCPlistFoundation.h>

int main() {
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObjects:@"item1", @"item2", nil], @"items",
        [NSDictionary dictionaryWithObjectsAndKeys:
            @"value1", @"key1",
            nil], @"metadata",
        nil];
    
    NSError *error = nil;
    NSString *plist = [NSPropertyListSerialization 
        stringWithPropertyList:data 
        format:NSPropertyListOpenStepFormat];
    
    NSLog(@"Plist:\n%@", plist);
    
    return 0;
}
```

### Example 5: XML Format

```objc
#import <MulleObjCPlistFoundation/MulleObjCPlistFoundation.h>

int main() {
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
        @"test", @"key",
        nil];
    
    NSError *error = nil;
    NSData *xmlData = [NSPropertyListSerialization 
        dataWithPropertyList:dict 
        format:NSPropertyListXMLFormat 
        options:0 
        error:&error];
    
    NSString *xmlString = [[NSString alloc] initWithData:xmlData 
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"XML:\n%@", xmlString);
    [xmlString release];
    
    return 0;
}
```

### Example 6: Error Handling

```objc
#import <MulleObjCPlistFoundation/MulleObjCPlistFoundation.h>

int main() {
    NSString *invalidPlist = @"{bad format";
    NSPropertyListFormat format;
    NSError *error = nil;
    
    id obj = [NSPropertyListSerialization 
        propertyListWithString:invalidPlist 
        format:&format];
    
    if (!obj) {
        NSLog(@"Parse failed");
    } else if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    return 0;
}
```

## 7. Dependencies

- MulleObjCValueFoundation (NSString, NSNumber, NSData)
- MulleObjCContainerFoundation (NSArray, NSDictionary)
