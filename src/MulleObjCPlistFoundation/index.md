# MulleObjCPlistFoundation Library Documentation for AI
<!-- Keywords: plist, propertylist, parsing, printing, objc, serialization -->

## 1. Introduction & Purpose

- MulleObjCPlistFoundation provides Objective-C APIs to parse, inspect and print "property lists" (OpenStep-style, optional JSON/XML support via add-on libraries). It converts between NSData/NSString and Foundation objects (NSDictionary, NSArray, NSString, NSNumber, NSData, NSDate, NSNull).
- Solves readable configuration and small-data serialization needs with support for Mulle-specific "loose" extensions (numbers, dates, __NSNULL__).
- Intended as a component within MulleFoundation; builds on MulleObjCStandardFoundation and integrates optionally with MulleObjCJSMNFoundation (JSON) or MulleObjCExpatFoundation (XML) for additional formats.

## 2. Key Concepts & Design Philosophy

- Mutable-by-default containers: the library typically returns mutable arrays/dictionaries unless immutable option is requested.
- Multiple format support: OpenStep (human-readable), Mulle loose/PBX extensions, JSON (via jsmn), XML (via expat when available).
- Plugin-style extensibility: parsers, print methods and format detectors can be registered at runtime (via +mulleAdd* methods) for custom formats.
- Small, focused API surface: high-level convenience methods on NSPropertyListSerialization and compact NSString/NSDictionary helpers for printing/parsing.

## 3. Core API & Data Structures

### 3.1. [MulleObjCPlistFoundation.h]
- Purpose: Project-level versioning and exports; include this to get the public API.
- No runtime types declared here beyond version macros and export headers.

### 3.2. [NSPropertyListSerialization.h]
- Purpose: Central serialization/deserialization facility (class methods only).
- Key enums/types:
  - NSPropertyListMutabilityOptions: NSPropertyListImmutable, NSPropertyListMutableContainers, NSPropertyListMutableContainersAndLeaves.
  - NSPropertyListFormat: NSPropertyListOpenStepFormat, MullePropertyListLooseFormat, MullePropertyListPBXFormat, MullePropertyListJSONFormat, NSPropertyListXMLFormat_v1_0, NSPropertyListBinaryFormat_v1_0.
  - MullePropertyListFormatOption: Detect / Prefer / Force.

- Lifecycle: No instance lifecycle; use class methods.

- Core operations (grouped):
  - Plugin registration (call during +load/+initialize):
    - +mulleAddFormatDetector:(SEL)detector
    - +mulleAddParserClass:(Class)parserClass method:(SEL)method forPropertyListFormat:(NSPropertyListFormat)format
    - +mulleAddPrintMethod:(SEL)method forPropertyListFormat:(NSPropertyListFormat)format
  - Validation:
    - +propertyList:isValidForFormat:
  - Serialization:
    - +dataFromPropertyList:format:errorDescription:  (legacy)
    - +dataWithPropertyList:format:options:error:       (preferred; returns NSData)
    - +stringWithPropertyList:format:                   (convenience string printer)
  - Deserialization:
    - +mullePropertyListFromData:mutabilityOption:format:formatOption:  (Mulle-specific reader)
    - +propertyListFromData:mutabilityOption:format:errorDescription:   (legacy)
    - +propertyListWithData:options:format:error:                        (preferred; uses NSError)

- Inspection helpers:
  - MulleStringFromPropertListFormatString(NSPropertyListFormat) — returns readable format name.

### 3.3. [NSDictionary+PropertyList.h]
- Methods:
  - - (NSString *) descriptionInStringsFileFormat;
    - Purpose: Produce a .strings-style textual representation of a dictionary (useful for localization files / strings files).

### 3.4. [NSString+PropertyList.h]
- Methods:
  - - (id) propertyList;
    - Purpose: Parse the receiver's contents as a property list and return the corresponding Foundation object (convenience wrapper around NSPropertyListSerialization).
    - Returns: NSDictionary/NSArray/NSString/NSNumber/NSData/NSDate/NSNull depending on contents. Caller should validate the returned class.

### 3.5. Internal/Other
- Files in src/Parsing, src/Printing, src/Stream implement low-level parsers/printers and are useful to consult when behavior differs from header documentation.
- PROPERTYLIST_README.md documents legacy stream-based code.

## 4. Performance Characteristics

- Parsing/printing are linear in input/output size (O(n)).
- Memory: full in-memory object graph created on parse; large plists can be memory-heavy.
- Thread-safety: API is not explicitly thread-safe for concurrent mutation of the same objects. Parsing into immutable containers is safer for multi-threaded reads.
- Trade-offs: favors readability and compatibility over maximum speed; "loose" parsing accepts more syntaxes at cost of complexity.

## 5. AI Usage Recommendations & Patterns

- Best Practices:
  - Prefer the NSError-returning methods (+propertyListWithData:options:format:error: and +dataWithPropertyList:format:options:error:) for robust error handling.
  - When possible, request immutable output (NSPropertyListImmutable) for safer shared use.
  - Register custom format detectors/parsers only during +load/+initialize to avoid race conditions.
  - Use NSString's -propertyList for quick inline parsing in tests and scripts.

- Common Pitfalls:
  - Do not assume numeric/date parsing unless MullePropertyListLooseFormat or appropriate detector is used.
  - Some convenience methods shown in older code use errorDescription (NSString **); prefer NSError APIs.
  - _Do not_ directly access underscore-prefixed internal structures; use public API only.

- Idiomatic patterns:
  - Use NSData-based APIs for file IO; use NSString convenience methods for small snippets and tests.
  - Validate parsed objects with -isKindOfClass: before further processing.

## 6. Integration Examples

Note: examples use the library's Objective-C style (message sends) and prefer convenience constructors.

### Example 1: Parse NSData into Foundation objects

```objc
#import "MulleObjCPlistFoundation.h"

int main() {
   NSData   *data;
   NSError  *error;
   id       plist;
   NSPropertyListFormat format;

   data = [NSData dataWithContentsOfFile:@"test/PropertyList/Movies.plist"];
   plist = [NSPropertyListSerialization 
           propertyListWithData:data 
           options:0 
           format:&format 
           error:&error];

   if (! plist) {
      NSLog(@"Parse failed: %@", [error localizedDescription]);
      return(1);
   }

   if ([plist isKindOfClass:[NSDictionary class]]) {
      NSDictionary *d;
      d = (NSDictionary *) plist;
      NSLog(@"keys: %lu", [d count]);
   }

   return(0);
}
```

### Example 2: Serialize an object to OpenStep-style plist string

```objc
#import "MulleObjCPlistFoundation.h"

int main() {
   NSDictionary *cfg;
   NSString     *out;

   cfg = [NSDictionary dictionaryWithObjectsAndKeys:
      @"localhost", @"host",
      [NSNumber numberWithInt:8080], @"port",
      nil];

   out = [NSPropertyListSerialization stringWithPropertyList:cfg 
                                                      format:NSPropertyListOpenStepFormat];

   NSLog(@"plist:\n%@", out);
   return(0);
}
```

### Example 3: Using NSString helper

```objc
#import "MulleObjCPlistFoundation.h"

int main() {
   NSString *s;
   id       obj;

   s = @"{ key = \"value\"; }";
   obj = [s propertyList];
   if ([obj isKindOfClass:[NSDictionary class]]) {
      NSLog(@"value: %@", [[(NSDictionary *)obj objectForKey:@"key"] description]);
   }
   return(0);
}
```

### Test-driven examples
- The `test/PropertyList/` directory contains many small, runnable examples demonstrating parsing edge cases (comments, quoting, data, booleans, arrays). Use these as canonical integration examples and expected-output checks.

## 7. Dependencies

- MulleObjCStandardFoundation (core NSString/NSNumber/NSDictionary support)
- mulle-objc-list (runtime listing support used by test tooling)
- Optional: MulleObjCJSMNFoundation for JSON parsing, MulleObjCExpatFoundation for XML plists

---

Source references used to build this TOC:
- src/NSPropertyListSerialization.h
- src/NSString+PropertyList.h
- src/NSDictionary+PropertyList.h
- test/PropertyList/* (integration examples)
- README.md
