# MulleFoundationBase Library Documentation for AI
<!-- Keywords: ObjectiveC, amalgamation, containers, values, foundation, plist, unicode -->

## 1. Introduction & Purpose

MulleFoundationBase is an **amalgamation** of 10 platform-independent
MulleFoundation Objective-C libraries compiled as a single library target.
It bundles containers, values, time, regex, plist, KVC, math, unicode and UUID
support without OS-specific dependencies (those live one layer up in
`MulleObjCOSFoundation`).

**Advantages:**

- Only one library to link against (`-lMulleFoundationBase`).
- Compiles faster than building the 10 constituents separately.
- Existing per-library `#import` statements keep working.
- A single umbrella import is also available.

**Constituents (all under `src/`):**

| Directory | Purpose |
|-----------|---------|
| `MulleObjCValueFoundation` | NSString, NSData, NSNumber value classes |
| `MulleObjCContainerFoundation` | NSArray, NSDictionary, NSSet, NSOrderedSet |
| `MulleObjCStandardFoundation` | NSCharacterSet, NSError, NSException, NSLocale, formatters, notifications |
| `MulleObjCTimeFoundation` | NSDate, NSTimer, time-aware locks |
| `MulleObjCUnicodeFoundation` | Unicode categories on NSString/NSCharacterSet |
| `MulleObjCUUIDFoundation` | NSUUID and C UUID helpers |
| `MulleObjCKVCFoundation` | Key-Value Coding categories and collection operators |
| `MulleObjCMathFoundation` | NSNumber floating-point unification (needs libm) |
| `MulleObjCPlistFoundation` | Property list parsing/printing and streams |
| `MulleObjCRegexFoundation` | Regex/wildcard/sed patterns, compiled patterns, tokenizer |

Each constituent has its own, more detailed `index.md` at
`src/<Constituent>/index.md`; this document is the amalgamated summary.

**Dependencies:** `MulleObjC` (runtime root classes), `math` (libm, via the
`m` alias), `mulle-objc-list` (build/load tooling).

## 2. Key Concepts & Design Philosophy

- **Amalgamation, not composition:** sources are copied into `src/` with
  `clibmode=copy`; the unification is one build target. There are no
  sub-libraries at runtime.
- **No OS dependencies:** everything here is portable C/ObjC. Platform-specific
  behavior (files, sockets, runloops) is supplied by higher layers via
  categories.
- **Class clusters:** `NSString`, `NSData`, `NSNumber`, `NSArray`,
  `NSDictionary`, `NSSet`, `NSOrderedSet`, `NSDate`, `NSCharacterSet` are class
  clusters. Public factories return private concrete subclasses. Do not touch
  `_`-prefixed concrete classes or ivars.
- **`SubclassesFuture` pattern:** primitive methods that a concrete class must
  implement (`-count`, `-objectAtIndex:`, `-objectForKey:`, `-length`,
  `-bytes`, ...) are declared in `SubclassesFuture` categories conforming to
  `<MulleObjCFuture>`. The abstract base does not implement them.
- **`Future` categories:** methods in categories marked `<MulleObjCFuture>`
  are legacy/planned; prefer typed factory methods. `+[NSDate date]` and
  `+[NSString string]` are examples.
- **Immutability by default:** immutable classes are safe for concurrent reads;
  mutable variants (`NSMutable*`) require external synchronization.
- **Mulle conventions:** avoid `+alloc`/`-init`/`-autorelease`; prefer factory
  methods. Never call `-release` except in `-dealloc`. No dot-syntax, no
  blocks, no `__bridge`. Use explicit message sends.
- **`unichar` is 32-bit:** `typedef mulle_utf32_t unichar`, not a 16-bit type.

## 3. Core API & Data Structures

**All signatures below MUST be copied verbatim from headers. Use the exact
parameter types, parameter names, and return types as declared. Do not
paraphrase or simplify signatures.**

### 3.1. Unified Import Path

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>
```

The umbrella header (`src/MulleFoundationBase/MulleFoundationBase.h`) imports
all 10 constituent umbrella headers. Individual constituent imports also work:

```objc
#import <MulleObjCValueFoundation/MulleObjCValueFoundation.h>
#import <MulleObjCContainerFoundation/MulleObjCContainerFoundation.h>
// ... etc.
```

### 3.2. MulleObjCValueFoundation — Value Classes

**Location:** `src/MulleObjCValueFoundation/`
**Key Headers:** `NSString.h`, `NSMutableString.h`, `NSData.h`,
`NSMutableData.h`, `NSNumber.h`, `NSStringEncoding.h`, `NSConstantString.h`,
`NSString+NSData.h`, `NSString+Hash.h`, `NSString+Enumerator.h`,
`NSString+Sprintf.h`, `NSString+ClassCluster.h`, `NSStringObjCFunctions.h`,
`NSObject+NSString.h`, `mulle-chardata.h`

#### `NSString` (immutable, class cluster)

```objc
@interface NSString : NSObject < MulleObjCClassCluster, MulleObjCImmutable, MulleObjCImmutableCopying>
```

- **Factory:** `+ (instancetype) string`,
  `+ (instancetype) stringWithString:(NSString *) other`,
  `+ (instancetype) stringWithUTF8String:(char *) s`,
  `+ (instancetype) stringWithCharacters:(unichar *) s length:(NSUInteger) len`
- **Init:** `- (instancetype) initWithString:(NSString *) s`
- **Substrings:** `- (NSString *) substringWithRange:(NSRange) range`,
  `- (NSString *) substringFromIndex:(NSUInteger) index`,
  `- (NSString *) substringToIndex:(NSUInteger) index`
- **Numeric conversion:** `- (BOOL) boolValue`, `- (int) intValue`,
  `- (NSInteger) integerValue`, `- (long long) longLongValue`,
  `- (float) floatValue`, `- (double) doubleValue`,
  `- (long double) mulleLongDoubleValue`
- **Comparison:** `- (BOOL) isEqualToString:(NSString *) other`,
  `- (BOOL) hasPrefix:(NSString *) prefix`, `- (BOOL) hasSuffix:(NSString *) suffix`
- **UTF8/UTF32:** `- (char *) UTF8String`,
  `- (void) getCharacters:(unichar *) buffer`

`NSString( MulleAdditions)` adds zero-copy and fast-path accessors:
`- (NSUInteger) mulleUTF8StringLength`,
`- (BOOL) mulleFastGetASCIIData:(struct mulle_asciidata *) space`,
`- (BOOL) mulleFastGetUTF8Data:(struct mulle_utf8data *) space`,
`- (BOOL) mulleFastGetUTF16Data:(struct mulle_utf16data *) space`,
`- (BOOL) mulleFastGetUTF32Data:(struct mulle_utf32data *) space`,
`+ (instancetype) mulleStringWithCharactersNoCopy:(unichar *) s length:(NSUInteger) len allocator:(struct mulle_allocator *) allocator`,
`+ (instancetype) mulleStringWithUTF8CharactersNoCopy:(char *) s length:(NSUInteger) len allocator:(struct mulle_allocator *) allocator`,
`+ (instancetype) mulleStringWithUTF8Characters:(char *) s length:(NSUInteger) len`,
`+ (BOOL) mulleAreValidUTF8Characters:(char *) buffer length:(NSUInteger) length`,
`+ (instancetype) mulleStringWithUTF16String:(mulle_utf16_t *) s`,
`- (mulle_utf16_t *) mulleUTF16String`.

C function:

```c
struct mulle_utf8data   MulleStringUTF8Data( NSString *self, struct mulle_utf8data space);
```

`NSStringCompareOptions` (in `NSString.h`):

```c
enum {
   NSCaseInsensitiveSearch = 0x001,
   NSLiteralSearch         = 0x002,
   NSBackwardsSearch       = 0x004,
   NSAnchoredSearch        = 0x008,
   NSNumericSearch         = 0x040,
};
typedef NSUInteger   NSStringCompareOptions;
```

#### `NSMutableString`

```objc
@interface NSMutableString : NSString < MulleObjCMutableValueProtocols, MulleObjCStringPrimitive>
```

- `+ (instancetype) stringWithCapacity:(NSUInteger) capacity`
- `- (instancetype) initWithCapacity:(NSUInteger) capacity`
- `- (void) appendString:(NSString *) s`
- `- (void) appendFormat:(NSString *) format, ...`
- `- (void) replaceCharactersInRange:(NSRange) aRange withString:(NSString *) replacement`
- `- (void) deleteCharactersInRange:(NSRange) aRange`
- `- (void) setString:(NSString *) s` (nil clears)
- `- (void) mulleAppendCharacters:(unichar *) buf length:(NSUInteger) length`
- `- (void) mulleAppendUTF8String:(char *) cStr`

Convert to immutable with `[[m copy] autorelease]` when construction is done.

#### `NSString` categories

- **`NSString+Sprintf.h`:** `+ (instancetype) stringWithFormat:(NSString *) format, ...`,
  `+ (instancetype) stringWithFormat:(NSString *) format mulleVarargList:(mulle_vararg_list) arguments`,
  `+ (instancetype) mulleStringWithFormat:(NSString *) format arguments:(va_list) args`,
  `- (instancetype) initWithFormat:(NSString *) format, ...`,
  `- (NSString *) stringByAppendingFormat:(NSString *) format, ...`
- **`NSString+NSData.h`:** `+ (NSStringEncoding *) availableStringEncodings`,
  `- (NSStringEncoding) fastestEncoding`, `- (NSStringEncoding) smallestEncoding`,
  `- (BOOL) canBeConvertedToEncoding:(NSStringEncoding) encoding`,
  `- (NSData *) dataUsingEncoding:(NSStringEncoding) encoding`,
  `- (instancetype) initWithData:(NSData *) data encoding:(NSUInteger) encoding`,
  `- (instancetype) initWithBytes:(void *) bytes length:(NSUInteger) length encoding:(NSStringEncoding) encoding`,
  `- (NSUInteger) lengthOfBytesUsingEncoding:(NSStringEncoding) encoding`,
  `+ (instancetype) mulleStringWithUTF8Data:(NSData *) data`
- **`NSString+Hash.h`:** FNV-1a hashing; `MulleObjCStringHashASCII(char *buf, NSUInteger length)`,
  `MulleObjCStringHashUTF16Bit15(mulle_utf16_t *buf, NSUInteger length)`,
  `MulleObjCStringHashUTF32(mulle_utf32_t *buf, NSUInteger length)`
- **`NSString+Enumerator.h`:** `struct MulleStringEnumerator` plus the
  `MulleStringFor( s, c)` / `MulleStringReverseFor( s, c)` iteration macros,
  `MulleStringEnumeratorNext(rover, &c)`, `MulleStringEnumeratorPrevious(rover, &c)`,
  `MulleStringEnumeratorGetIndex(rover)`, `MulleStringEnumeratorHasCharacters(rover)`,
  `MulleStringEnumeratorRestart(rover)`, `MulleStringEnumeratorFinish(rover)`
- **`NSObject+NSString.h`:** `- (NSString *) description`,
  `- (NSString *) mulleTestDescription`, `- (NSString *) mulleQuotedDescriptionIfNeeded`,
  `- (NSComparisonResult) mulleCompareDescription:(id) other`
- **`NSStringObjCFunctions.h`:** `MulleObjCClassFromString`, `MulleObjCSelectorFromString`,
  `MulleObjCStringFromClass`, `MulleObjCStringFromSelector`, `MulleObjCStringFromRange`,
  `MulleObjCPrintf`, `MulleObjCFprintf`

#### `NSStringEncoding` (`NSStringEncoding.h`)

Encoding constants include `NSASCIIStringEncoding` (1), `NSUTF8StringEncoding` (4),
`NSISOLatin1StringEncoding` (5), `NSUTF16StringEncoding` (10),
`NSMacOSRomanStringEncoding` (30), `NSUTF16BigEndianStringEncoding` (0x90000100),
`NSUTF16LittleEndianStringEncoding` (0x94000100), `NSUTF32StringEncoding` (0x8c000100),
`NSUTF32BigEndianStringEncoding` (0x98000100), `NSUTF32LittleEndianStringEncoding` (0x9c000100).

```c
char              *MulleStringEncodingUTF8String( NSStringEncoding encoding);
NSStringEncoding   MulleStringEncodingParseUTF8String( char *s);
```

#### `NSData` (immutable, class cluster)

```objc
@interface NSData : NSObject < MulleObjCClassCluster, MulleObjCValueProtocols>

+ (instancetype) data;
+ (instancetype) dataWithBytes:(void *) bytes length:(NSUInteger) length;
+ (instancetype) dataWithBytesNoCopy:(void *) bytes length:(NSUInteger) length;
+ (instancetype) dataWithBytesNoCopy:(void *) bytes length:(NSUInteger) length freeWhenDone:(BOOL) flag;
+ (instancetype) dataWithData:(NSData *) other;
+ (instancetype) mulleDataWithCData:(struct mulle_data) data;
- (instancetype) initWithBytesNoCopy:(void *) bytes length:(NSUInteger) length;
- (instancetype) initWithBytesNoCopy:(void *) bytes length:(NSUInteger) length freeWhenDone:(BOOL) flag;
- (instancetype) initWithData:(NSData *) other;
- (void) getBytes:(void *) bytes;
- (void) getBytes:(void *) bytes length:(NSUInteger) length;
- (void) getBytes:(void *) bytes range:(NSRange) range;
- (BOOL) isEqualToData:(NSData *) other;
- (NSData *) subdataWithRange:(NSRange) range;
- (NSRange) rangeOfData:(id) other options:(NSUInteger) options range:(NSRange) range;
```

`SubclassesFuture` primitives: `- (NSUInteger) length`, `- (void *) bytes`,
`- (struct mulle_data) mulleCData`.

#### `NSMutableData`

```objc
@interface NSMutableData : NSData < MulleObjCClassCluster, MulleObjCThreadUnsafe>
```

`+ (instancetype) dataWithCapacity:(NSUInteger) aNumItems`,
`+ (instancetype) dataWithLength:(NSUInteger) length`,
`- (instancetype) initWithLength:(NSUInteger) length`,
`- (instancetype) initWithCapacity:(NSUInteger) capacity`,
`- (void) appendBytes:(void *) bytes length:(NSUInteger) length`,
`- (void) appendData:(NSData *) otherData`, `- (void) setData:(NSData *) aData`,
`- (void) increaseLengthBy:(NSUInteger) extraLength`, `- (void *) mutableBytes`,
`- (struct mulle_data) mulleMutableData`, `- (void) resetBytesInRange:(NSRange) range`,
`- (void) replaceBytesInRange:(NSRange) range withBytes:(void *) bytes`,
`- (void) setLength:(NSUInteger) length`,
`- (void) mulleSetLengthDontZero:(NSUInteger) length`,
`+ (instancetype) mulleNonZeroedDataWithLength:(NSUInteger) length`.

#### `NSNumber` (immutable numeric value, class cluster)

```objc
@interface NSNumber : NSValue < NSCopying, MulleObjCImmutableCopying, MulleObjCClassCluster>
```

- **Factory (all typed):** `numberWithBool:`, `numberWithChar:`,
  `numberWithUnsignedChar:`, `numberWithShort:`, `numberWithUnsignedShort:`,
  `numberWithInt:`, `numberWithUnsignedInt:`, `numberWithInteger:(NSInteger)`,
  `numberWithUnsignedInteger:(NSUInteger)`, `numberWithLong:`,
  `numberWithUnsignedLong:`, `numberWithLongLong:(long long)`,
  `numberWithUnsignedLongLong:(unsigned long long)`, `numberWithFloat:(float)`,
  `numberWithDouble:(double)`, `numberWithLongDouble:(long double)` (if `_C_LNG_DBL`)
- **Access:** `- (BOOL) boolValue`, `- (char) charValue`,
  `- (unsigned char) unsignedCharValue`, `- (short) shortValue`,
  `- (unsigned short) unsignedShortValue`, `- (int) intValue`,
  `- (unsigned int) unsignedIntValue`, `- (long) longValue`,
  `- (unsigned long) unsignedLongValue`, `- (float) floatValue`,
  `- (unsigned long long) unsignedLongLongValue`,
  `- (NSUInteger) unsignedIntegerValue`
- **`SubclassesFuture`:** `- (NSInteger) integerValue`, `- (double) doubleValue`,
  `- (long double) longDoubleValue` (if `_C_LNG_DBL`), `- (long long) longLongValue`
- **Comparison:** `- (NSComparisonResult) compare:(id) other`,
  `- (BOOL) isEqualToNumber:(id) other`
- **`NSNumber+NSString.h`:** `- (NSString *) stringValue`

`NSNumber` inherits from `NSValue`, which is defined in `MulleObjC`, not here.

### 3.3. MulleObjCContainerFoundation — Containers

**Location:** `src/MulleObjCContainerFoundation/`
**Key Headers:** `MulleObjCContainer.h`, `NSArray.h`, `NSMutableArray.h`,
`NSDictionary.h`, `NSMutableDictionary.h`, `NSSet.h`, `NSMutableSet.h`,
`NSOrderedSet.h`, `NSMutableOrderedSet.h`, `NSEnumerator.h`,
`NSArray+NSEnumerator.h`, `NSDictionary+NSEnumerator.h`

#### `MulleObjCContainer` (common base)

```objc
@interface MulleObjCContainer : NSObject

- (void) makeObjectsPerformSelector:(SEL) sel;
- (void) makeObjectsPerformSelector:(SEL) sel withObject:(id) obj;
- (id) anyObject;
```

#### `NSArray` (immutable array, class cluster)

```objc
@interface NSArray : MulleObjCContainer < NSArray, MulleObjCClassCluster, MulleObjCImmutableCopying>

+ (instancetype) array;
+ (instancetype) arrayWithArray:(NSArray *) other;
+ (instancetype) arrayWithObject:(id) obj;
+ (instancetype) arrayWithObjects:(id) firstObject, ...;
+ (instancetype) arrayWithObjects:(id *) objects count:(NSUInteger) count;
- (instancetype) initWithArray:(NSArray *) other;
- (instancetype) initWithArray:(NSArray *) other copyItems:(BOOL) flag;
- (instancetype) initWithObjects:(id) firstObject, ...;
- (instancetype) initWithObjects:(id *) objects count:(NSUInteger) count;
- (NSArray *) arrayByAddingObject:(id) obj;
- (NSArray *) arrayByAddingObjectsFromArray:(NSArray *) other;
- (BOOL) containsObject:(id) obj;
- (BOOL) containsObject:(id) obj inRange:(NSRange) range;
- (NSUInteger) indexOfObject:(id) obj;
- (NSUInteger) indexOfObject:(id) obj inRange:(NSRange) range;
- (NSUInteger) indexOfObjectIdenticalTo:(id) obj;
- (id) firstObjectCommonWithArray:(NSArray *) other;
- (id) lastObject;
- (BOOL) isEqualToArray:(NSArray *) other;
- (NSArray *) sortedArrayUsingSelector:(SEL) comparator;
- (NSArray *) sortedArrayUsingFunction:(NSComparisonResult (*)(id, id, void *)) comparator context:(void *) context;
- (NSArray *) subarrayWithRange:(NSRange) range;
- (void) getObjects:(id *) objects;
```

`NSArray( MulleAdditions)`: `+ (instancetype) mulleArrayWithArray:(NSArray *) other range:(NSRange) range`,
`+ (instancetype) mulleArrayWithRetainedObjects:(id *) objects count:(NSUInteger) count`,
`- (id) mulleForEachObjectCallFunction:(BOOL (*)( id, void *)) f argument:(void *) userInfo preempt:(enum MullePreempt) preempt`,
`- (id) mulleFirstObject`, `- (BOOL) mulleContainsObjectIdenticalTo:(id) obj`.

`SubclassesFuture`: `- (id) :(NSUInteger) index`, `- (id) objectAtIndex:(NSUInteger) index`,
`- (void) getObjects:(id *) objects range:(NSRange) range`, and `<NSFastEnumeration>`.

#### `NSMutableArray`

```objc
@interface NSMutableArray : NSArray < NSMutableArray, MulleObjCMutableContainerProtocols>
```

`+ (instancetype) arrayWithCapacity:(NSUInteger) capacity`,
`- (instancetype) initWithCapacity:(NSUInteger) capacity`,
`- (void) addObject:(id) obj`, `- (void) addObjectsFromArray:(NSArray *) otherArray`,
`- (void) insertObject:(id) obj atIndex:(NSUInteger) index`,
`- (void) replaceObjectAtIndex:(NSUInteger) index withObject:(id) obj`,
`- (void) replaceObjectsInRange:(NSRange) range withObjects:(id *) objects count:(NSUInteger) count`,
`- (void) removeLastObject`, `- (void) removeObject:(id) obj`,
`- (void) removeObjectAtIndex:(NSUInteger) index`,
`- (void) removeObjectsInRange:(NSRange) range`, `- (void) removeAllObjects`,
`- (void) exchangeObjectAtIndex:(NSUInteger) index1 withObjectAtIndex:(NSUInteger) index2`,
`- (void) setArray:(NSArray *) other`, `- (void) sortUsingSelector:(SEL) comparator`.

Mulle additions: `- (void) mulleAddRetainedObject:(id) obj`,
`- (void) mulleReverseObjects`,
`- (void) mulleMoveObjectsInRange:(NSRange) range toIndex:(NSUInteger) index`,
`- (id) mulleRemoveLastObject`.

#### `NSDictionary` (immutable dictionary, class cluster)

```objc
@interface NSDictionary : MulleObjCContainer < NSDictionary, MulleObjCClassCluster, MulleObjCImmutable, MulleObjCImmutableCopying >

+ (instancetype) dictionary;
+ (instancetype) dictionaryWithDictionary:(NSDictionary *) dictionary;
+ (instancetype) dictionaryWithObject:(id) anObject forKey:(id<NSObject, MulleObjCImmutableCopying>) aKey;
+ (instancetype) dictionaryWithObjects:(id *) objects forKeys:(id *) keys count:(NSUInteger) count;
+ (instancetype) dictionaryWithObjectsAndKeys:(id) firstObject , ...;
- (instancetype) initWithDictionary:(NSDictionary *) otherDictionary;
- (instancetype) initWithDictionary:(NSDictionary *) otherDictionary copyItems:(BOOL) flag;
- (instancetype) initWithObjects:(id *) objects forKeys:(id *) keys count:(NSUInteger) count;
- (BOOL) isEqualToDictionary:(NSDictionary *) other;
- (void) getObjects:(id *) objects andKeys:(id *) keys;
```

Mulle additions: `- (id) mulleForEachObjectAndKeyCallFunction:(BOOL (*)( id, id, void *)) f argument:(void *) userInfo preempt:(enum MullePreempt) preempt`,
`- (NSInteger) mulleCountCollisions:(NSInteger *) perfects`.

`SubclassesFuture` (`<NSFastEnumeration, MulleObjCFuture>`):
`- (NSEnumerator *) keyEnumerator`, `- (id) :(id) key` (shortcut),
`- (id) objectForKey:(id) key`,
`- (void) getObjects:(id *) objects andKeys:(id *) keys count:(NSUInteger) count`.

#### `NSMutableDictionary`

```objc
@interface NSMutableDictionary : NSDictionary < NSMutableDictionary, MulleObjCClassCluster>
```

`+ (instancetype) dictionaryWithCapacity:(NSUInteger) capacity`.

`SubclassesFuture`: `- (instancetype) initWithCapacity:(NSUInteger) capacity`,
`- (void) setObject:(id) anObject forKey:(id <NSObject, MulleObjCImmutableCopying>) aKey`,
`- (void) removeObjectForKey:(id)aKey`, `- (void) removeAllObjects`,
`- (void) addEntriesFromDictionary:(NSDictionary *) other`,
`- (void) setDictionary:(NSDictionary *) other`,
`- (void) mulleSetRetainedObject:(id) anObject forKey:(id <NSObject, MulleObjCImmutableCopying>) aKey`.

#### `NSSet` / `NSMutableSet`

```objc
@interface NSSet : MulleObjCContainer < NSSet, MulleObjCClassCluster, MulleObjCImmutable, MulleObjCImmutableCopying>

+ (instancetype) set;
+ (instancetype) setWithObject:(id) object;
+ (instancetype) setWithObjects:(id) object, ...;
+ (instancetype) setWithObjects:(id *) objects count:(NSUInteger) count;
+ (instancetype) setWithSet:(NSSet *) set;
- (instancetype) initWithSet:(NSSet *) set;
- (instancetype) initWithSet:(NSSet *) set copyItems:(BOOL) flag;
- (NSSet *) setByAddingObject:(id) object;
- (NSSet *) setByAddingObjectsFromSet:(NSSet *) set;
- (BOOL) containsObject:(id) object;
- (BOOL) isSubsetOfSet:(NSSet *) set;
- (BOOL) intersectsSet:(NSSet *) set;
- (BOOL) isEqualToSet:(NSSet *) set;
- (id) :(id) object;  // shortcut for member:
```

`SubclassesFuture` (`<NSFastEnumeration, MulleObjCFuture>`):
`- (NSUInteger) count`, `- (id) member:(id) object`,
`- (NSEnumerator *) objectEnumerator`.

`NSMutableSet` adds `+ (instancetype) setWithCapacity:(NSUInteger) numItems`,
`- (void) addObject:`, `- (void) removeObject:`, `- (void) removeAllObjects`,
`- (void) unionSet:`, `- (void) intersectSet:`, `- (void) minusSet:`,
`- (void) setSet:`, `- (id) mulleRegisterObject:(id) object`.

#### `NSOrderedSet` / `NSMutableOrderedSet`

Insertion-ordered set. Storage is a map (object -> object, O(1) membership and
uniqueness) plus a pointer array that preserves insertion order and is what
gets enumerated.

```objc
@interface NSOrderedSet : MulleObjCContainer < NSSet, MulleObjCClassCluster, MulleObjCImmutable, MulleObjCImmutableCopying >

+ (instancetype) orderedSet;
+ (instancetype) orderedSetWithObject:(id) object;
+ (instancetype) orderedSetWithObjects:(id) firstObject, ...;
+ (instancetype) orderedSetWithObjects:(id *) objects count:(NSUInteger) count;
+ (instancetype) orderedSetWithArray:(NSArray *) array;
+ (instancetype) orderedSetWithSet:(NSSet *) set;
+ (instancetype) orderedSetWithOrderedSet:(NSOrderedSet *) set;
- (instancetype) initWithObject:(id) object;
- (instancetype) initWithObjects:(id *) objects count:(NSUInteger) count;
- (instancetype) initWithArray:(NSArray *) array;
- (instancetype) initWithSet:(NSSet *) set;
- (instancetype) initWithOrderedSet:(NSOrderedSet *) set;
- (id) firstObject;
- (id) lastObject;
- (BOOL) containsObject:(id) object;
- (NSUInteger) indexOfObject:(id) object;
- (NSArray *) array;
- (NSSet *) set;
- (BOOL) isEqualToOrderedSet:(NSOrderedSet *) other;
```

`SubclassesFuture`: `- (NSUInteger) count`, `- (id) member:(id) object`,
`- (id) objectAtIndex:(NSUInteger) index`,
`- (void) getObjects:(id *) objects range:(NSRange) range`,
`- (NSEnumerator *) objectEnumerator`.

`NSMutableOrderedSet` adds capacity creation and mutation:
`+ (instancetype) orderedSetWithCapacity:(NSUInteger) capacity`,
`- (void) addObject:`, `- (void) addObjectsFromArray:`,
`- (void) insertObject:atIndex:`, `- (void) replaceObjectAtIndex:withObject:`,
`- (void) removeObject:`, `- (void) removeObjectAtIndex:`, `- (void) removeAllObjects`.

#### `NSEnumerator`

```objc
@protocol NSEnumerator
- (id) nextObject;
- (id <NSArray>) allObjects;
@end

@interface NSEnumerator : NSObject
@end
```

Categories on `NSArray` provide `-objectEnumerator` and `-reverseObjectEnumerator`.
Categories on `NSDictionary` provide `-keyEnumerator`, `-objectEnumerator` and `-anyKey`.

### 3.4. MulleObjCStandardFoundation — Standard Base Classes

**Location:** `src/MulleObjCStandardFoundation/`
**Key Headers:** `NSCharacterSet.h`, `NSMutableCharacterSet.h`, `NSScanner.h`,
`NSFormatter.h`, `NSCalendarDate.h`, `NSDateFormatter.h`, `NSTimeZone.h`,
`NSException.h`, `NSError.h`, `NSAssertionHandler.h`, `NSLocale.h`,
`NSNumberFormatter.h`, `NSNotification.h`, `NSNotificationCenter.h`,
`NSUndoManager.h`, `NSSortDescriptor.h`, `NSString+Search.h`,
`NSString+Components.h`, `NSString+Escaping.h`, `NSString+DoubleQuotes.h`,
`NSString+NSCharacterSet.h`

#### `NSCharacterSet` (immutable, class cluster)

```objc
@interface NSCharacterSet : NSObject < NSCopying, MulleObjCClassCluster>

- (instancetype) initWithBitmapRepresentation:(NSData *) data;
- (NSData *) bitmapRepresentation;
- (BOOL) isSupersetOfSet:(NSCharacterSet *) set;
- (BOOL) longCharacterIsMember:(long) c;
+ (instancetype) characterSetWithCharactersInString:(NSString *) s;
- (void) mulleGetBitmapBytes:(unsigned char *) bytes plane:(NSUInteger) plane;
+ (instancetype) alphanumericCharacterSet;
+ (instancetype) controlCharacterSet;
+ (instancetype) capitalizedLetterCharacterSet;
+ (instancetype) decimalDigitCharacterSet;
+ (instancetype) letterCharacterSet;
+ (instancetype) lowercaseLetterCharacterSet;
+ (instancetype) punctuationCharacterSet;
+ (instancetype) symbolCharacterSet;
+ (instancetype) uppercaseLetterCharacterSet;
+ (instancetype) whitespaceAndNewlineCharacterSet;
+ (instancetype) whitespaceCharacterSet;
```

`SubclassesFuture`: `- (BOOL) characterIsMember:(unichar) c`,
`- (BOOL) hasMemberInPlane:(NSUInteger) plane`,
`- (NSCharacterSet *) invertedSet`.

`NSMutableCharacterSet` adds `- addCharactersInString:`,
`- removeCharactersInString:`, `- addCharactersInRange:`,
`- removeCharactersInRange:`, `- formUnionWithCharacterSet:`,
`- formIntersectionWithCharacterSet:`, `- invert`.

#### `NSScanner`

```objc
@interface NSScanner : NSObject <NSObject, NSCopying>

+ (instancetype) scannerWithString:(NSString *)string;
- (instancetype) initWithString:(NSString *)string;
- (NSString *) string;
- (NSString *) mulleUnscannedString;
- (BOOL) isAtEnd;
- (BOOL) scanCharactersFromSet:(NSCharacterSet *) charset intoString:(NSString **) stringp;
- (BOOL) scanUpToCharactersFromSet:(NSCharacterSet *)charset intoString:(NSString **)stringp;
- (BOOL) scanUpToString:(NSString *) string intoString:(NSString **) stringp;
- (BOOL) scanString:(NSString *) string intoString:(NSString **) stringp;
- (BOOL) scanInt:(int *)valuep;
- (BOOL) scanInteger:(NSInteger *)valuep;
- (BOOL) scanLongLong:(long long *)valuep;
- (BOOL) scanFloat:(float *)valuep;
- (BOOL) scanDouble:(double *)valuep;
- (BOOL) scanHexInt:(unsigned *)valuep;
```

`NSScanner( NSLocale)` adds `+ (instancetype) localizedScannerWithString:(NSString *) string`.

#### `NSFormatter` (abstract)

```objc
@interface NSFormatter : NSObject < MulleObjCThreadUnsafe>

- (NSString *) editingStringForObjectValue:(id) obj;
- (BOOL) getObjectValue:(id *) obj forString:(NSString *) s errorDescription:(NSString **) error;
- (BOOL) isPartialStringValid:(NSString *) s newEditingString:(NSString **) newString errorDescription:(NSString **) error;
- (NSString *) stringForObjectValue:(id) obj;
```

#### `NSCalendarDate`

```objc
@interface NSCalendarDate : NSDate < NSDateFactory, MulleObjCClassCluster, MulleObjCValueProtocols>

+ (instancetype) calendarDate;
+ (instancetype) dateWithYear:(NSInteger) year
                        month:(NSUInteger) month
                          day:(NSUInteger) day
                         hour:(NSUInteger) hour
                       minute:(NSUInteger) minute
                       second:(NSUInteger) second
                     timeZone:(NSTimeZone *) aTimeZone;
- (instancetype) initWithYear:(NSInteger) year
                        month:(NSUInteger) month
                          day:(NSUInteger) day
                         hour:(NSUInteger) hour minute:(NSUInteger) minute
                       second:(NSUInteger) second
                     timeZone:(NSTimeZone *) aTimeZone;
- (NSString *) calendarFormat;
- (instancetype) mulleInitWithMiniTM:(struct mulle_mini_tm) tm timeZone:(NSTimeZone *) tz;
```

NSCalendarDate always has a timezone and is integer-based (no subsecond
precision). `Subclasses` (Future) provide component access:
`- (struct mulle_mini_tm) mulleMiniTM`, `- (NSInteger) secondOfMinute`,
`- (NSInteger) minuteOfHour`, `- (NSInteger) hourOfDay`,
`- (NSInteger) dayOfMonth`, `- (NSInteger) monthOfYear`,
`- (NSInteger) yearOfCommonEra`, `- (NSTimeZone *) timeZone`,
`- (BOOL) isEqualToCalendarDate:(NSCalendarDate *) date`.

#### `NSDateFormatter`

```objc
@interface NSDateFormatter : NSFormatter

+ (instancetype) dateFormatterWithDateFormat:(NSString *) format allowNaturalLanguage:(BOOL) flag;
- (instancetype) initWithDateFormat:(NSString *) format allowNaturalLanguage:(BOOL) flag;
+ (void) setDefaultFormatterBehavior:(NSDateFormatterBehavior) behavior;
+ (NSDateFormatterBehavior) defaultFormatterBehavior;
- (void) setFormatterBehavior:(NSDateFormatterBehavior) behavior;
- (NSDateFormatterBehavior) formatterBehavior;
+ (void) mulleSetClass:(Class) cls forFormatterBehavior:(NSDateFormatterBehavior) formatterBehavior;
```

Conversion methods (`Future`): `- (NSDate *) dateFromString:(NSString *) s`,
`- (NSString *) stringFromDate:(NSDate *) date`.

#### `NSTimeZone`

```objc
@interface NSTimeZone : NSObject < MulleObjCInvariant, MulleObjCImmutableProtocols>

+ (instancetype) timeZoneWithName:(NSString *) name;
+ (instancetype) timeZoneWithAbbreviation:(NSString *) abbreviation;
+ (NSTimeZone *) timeZoneForSecondsFromGMT:(NSInteger) seconds;
- (NSString *) name;
+ (NSTimeZone *) systemTimeZone;
+ (NSTimeZone *) defaultTimeZone;
+ (NSTimeZone *) localTimeZone;
- (BOOL) isEqualToTimeZone:(NSTimeZone *) tz;
- (NSInteger) secondsFromGMT;
- (NSString *) abbreviation;
- (BOOL) isDaylightSavingTime;
+ (NSTimeZone *) mulleGMTTimeZone;
```

#### `NSException`

```objc
@interface NSException : NSObject < MulleObjCException, MulleObjCImmutableProtocols>

+ (NSException *) exceptionWithName:(NSString *) name
                             reason:(NSString *) reason
                           userInfo:(id) userInfo;
+ (void) raise:(NSString *) name
        format:(NSString *) format mulleVarargList:(mulle_vararg_list) args;
+ (void) raise:(NSString *) name
        format:(NSString *) format
     arguments:(va_list) va;
+ (void) raise:(NSString *) name
        format:(NSString *) format, ...;
- (instancetype) initWithName:(NSString *) name
                       reason:(NSString *) reason
                     userInfo:(NSDictionary *) userInfo;
```

Exception name globals: `NSInternalInconsistencyException`, `NSGenericException`,
`NSInvalidArgumentException`, `NSMallocException`, `NSRangeException`,
`NSParseErrorException`. Macros: `NS_DURING` / `NS_HANDLER` / `NS_ENDHANDLER`.

#### `NSError`

```objc
@interface NSError : NSObject < MulleObjCImmutableProtocols>

+ (void) registerErrorDomain:(NSString *) domain
         errorStringFunction:(NSString *(*)( NSInteger)) translator;
+ (void) removeErrorDomain:(NSString *) domain;
- (instancetype) initWithDomain:(NSString *) domain
                           code:(NSInteger) code
                       userInfo:(NSDictionary *) userInfo;
+ (instancetype) errorWithDomain:(NSString *) domain
                            code:(NSInteger) code
                        userInfo:(NSDictionary *) userInfo;
- (NSString *) localizedDescription;
- (NSString *) localizedFailureReason;
- (NSString *) localizedRecoverySuggestion;
```

Thread-local error pattern (mulle extension): `+ (void) mulleSetErrorDomain:`,
`+ (NSString *) mulleErrorDomain`, `+ (void) mulleSetError:`,
`+ (void) mulleSetErrorCode:(NSInteger) code domain:(NSString *) domain userInfo:(NSDictionary *) userInfo`,
`+ (instancetype) mulleExtract`, `+ (void) mulleClear`,
`+ (void) mulleSetGenericErrorWithDomain:localizedDescription:`,
`+ (instancetype) mulleGenericErrorWithDomain:localizedDescription:`.

C functions: `MulleObjCSetErrorCode()`, `MulleObjCSetErrorDomain()`,
`MulleObjCGetErrorDomain()`, `MulleObjCExtractError()`, `MulleObjCClearError()`.

#### `NSAssertionHandler`

```objc
@interface NSAssertionHandler : NSObject < MulleObjCImmutableProtocols>

+ (NSAssertionHandler *) currentHandler;
- (void) handleFailureInMethod:(SEL) selector
                        object:(id) object
                          file:(NSString *) fileName
                    lineNumber:(NSInteger) line
                   description:(NSString *) format, ...;
- (void) handleFailureInFunction:(NSString *) functionName
                            file:(NSString *) fileName
                      lineNumber:(NSInteger) line
                     description:(NSString *) format, ...;
```

Macros `NSAssert` / `NSCAssert` / `NSParameterAssert` / `NSCParameterAssert`
delegate to `MulleObjCAssert` / `MulleObjCCAssert`.

#### `NSLocale`

```objc
@interface NSLocale : NSObject < MulleObjCImmutableProtocols >

+ (instancetype) localeWithLocaleIdentifier:(NSString *) s;
+ (instancetype) autoupdatingCurrentLocale;
+ (instancetype) systemLocale;
+ (instancetype) currentLocale;
- (NSString *) displayNameForKey:(id) key value:(id) value;
- (NSString *) localeIdentifier;
- (NSString *) languageCode;
- (NSString *) scriptCode;
- (NSString *) variantCode;
- (NSString *) collationIdentifier;
- (NSString *) currencyCode;
- (NSString *) calendarIdentifier;
- (NSString *) localizedStringForLocaleIdentifier:(NSString *)localeIdentifier;
- (NSString *) localizedStringForCountryCode:(NSString *) countryCode;
- (NSString *) localizedStringForLanguageCode:(NSString *) languageCode;
```

`Future` API adds `+[NSLocale availableLocaleIdentifiers]`,
`+[NSLocale ISOLanguageCodes]`, `+[NSLocale ISOCountryCodes]`,
`+[NSLocale ISOCurrencyCodes]`, `+[NSLocale componentsFromLocaleIdentifier:]`,
`+[NSLocale localeIdentifierFromComponents:]`, `-[NSLocale :(id) key]`,
`-[NSLocale objectForKey:(id) key]`, `-[NSLocale isEqualToLocale:]`.
Numerous `NSLocale*` key globals are exported (`NSLocaleLanguageCode`,
`NSLocaleCountryCode`, `NSLocaleDecimalSeparator`, `NSLocaleCurrencyCode`,
`NSLocaleCalendar`, ...).

#### `NSNumberFormatter`

```objc
@interface NSNumberFormatter : NSFormatter

+ (NSNumberFormatterBehavior) defaultFormatterBehavior;
+ (void) setDefaultFormatterBehavior:(NSNumberFormatterBehavior) behavior;
- (BOOL) allowsFloats;
- (BOOL) generatesDecimalNumbers;
- (BOOL) hasThousandSeparators;
- (BOOL) isLenient;
- (void) setAllowsFloats:(BOOL) flag;
- (void) setGeneratesDecimalNumbers:(BOOL) flag;
- (void) setHasThousandSeparators:(BOOL) flag;
- (void) setLenient:(BOOL) flag;
- (NSNumber *) numberFromString:(NSString *) string;
- (NSString *) stringFromNumber:(NSNumber *) number;
+ (instancetype) mulleDefaultFormatter;
```

#### `NSNotification` / `NSNotificationCenter`

```objc
@interface NSNotification : NSObject < MulleObjCImmutableProtocols>

+ (instancetype) notificationWithName:(NSString *) aName object:(id) anObject;
+ (instancetype) notificationWithName:(NSString *) aName
                               object:(id) anObject
                             userInfo:(id <NSCopying, MulleObjCRuntimeObject>) userInfo;

@interface NSNotificationCenter : NSObject < MulleObjCSingleton, MulleObjCThreadSafe>

+ (instancetype) defaultCenter;
- (void) addObserver:(id) observer
            selector:(SEL) sel
                name:(NSString *) name
              object:(id) sender;
- (void) postNotification:(NSNotification *) notification;
- (void) postNotificationName:(NSString *) name object:(id) sender;
- (void) postNotificationName:(NSString *) name object:(id) sender userInfo:(NSDictionary *) userInfo;
- (void) removeObserver:(id) observer;
- (void) removeObserver:(id) observer name:(NSString *) name object:(id) sender;
```

`NSNotificationCenter` is internally locked; observers are called synchronously
on the posting thread. `NSNotification.userInfo` is untyped (not necessarily a
dictionary) — a mulle extension.

#### `NSUndoManager`

```objc
@interface NSUndoManager : NSObject <MulleObjCThreadUnsafe>

- (NSInteger) groupingLevel;
- (void) beginUndoGrouping;
- (void) endUndoGrouping;
- (void) disableUndoRegistration;
- (void) enableUndoRegistration;
- (BOOL) isUndoRegistrationEnabled;
- (void) undo;
- (void) redo;
- (void) undoNestedGroup;
- (BOOL) canUndo;
- (BOOL) canRedo;
- (BOOL) isUndoing;
- (BOOL) isRedoing;
- (void) removeAllActions;
- (void) removeAllActionsWithTarget:(id) target;
- (void) registerUndoWithTarget:(id) target
                       selector:(SEL) selector
                         object:(id) anObject;
- (id) prepareWithInvocationTarget:(id) target;
```

#### `NSSortDescriptor`

```objc
@interface NSSortDescriptor : NSObject <MulleObjCImmutableProtocols>

+ (NSSortDescriptor *) sortDescriptorWithKey:(NSString *) key ascending:(BOOL) flag;
+ (NSSortDescriptor *) sortDescriptorWithKey:(NSString *) key
                                   ascending:(BOOL) flag
                                    selector:(SEL) selector;
- (NSString *) key;
- (SEL) selector;
- (BOOL) ascending;
- (NSSortDescriptor *) reversedSortDescriptor;
```

#### `NSString` categories in StandardFoundation

- **`NSString+Search.h`:** `- (NSComparisonResult) compare:(id) other`,
  `- (NSComparisonResult) compare:(id) other options:(NSStringCompareOptions) mask`,
  `- (NSComparisonResult) caseInsensitiveCompare:(NSString *) other`,
  `- (NSRange) rangeOfString:(NSString *) other`,
  `- (NSRange) rangeOfString:(NSString *) other options:(NSStringCompareOptions) options`,
  `- (BOOL) containsString:(NSString *) s`,
  `- (NSRange) rangeOfCharacterFromSet:(NSCharacterSet *) set`,
  `- (NSString *) uppercaseString`, `- (NSString *) lowercaseString`,
  `- (NSString *) capitalizedString`,
  `- (NSString *) mulleDecapitalizedString`,
  `- (NSString *) stringByReplacingOccurrencesOfString:(NSString *) s withString:(NSString *) replacement`,
  `- (NSString *) stringByReplacingCharactersInRange:(NSRange) range withString:(NSString *) replacement`
- **`NSString+Components.h`:** `- (NSArray *) componentsSeparatedByString:(NSString *) s`,
  `- (NSArray *) componentsSeparatedByCharactersInSet:(NSCharacterSet *) separators`,
  plus `mulleMutableComponentsSeparatedByString:` /
  `mulleMutableComponentsSeparatedByCharactersInSet:` and the C helpers
  `MulleObjCComponentsSeparatedByString`, `MulleObjCComponentsSeparatedByCharacterSet`
- **`NSString+Escaping.h`:** `- (NSString *) stringByAddingPercentEncodingWithAllowedCharacters:(NSCharacterSet *) allowedCharacters`,
  `- (NSString *) stringByRemovingPercentEncoding`,
  `- (NSString *) mulleQuotedString`, `- (NSString *) mulleUnquotedString`,
  `- (NSString *) mulleEscapedString`, `- (NSString *) mulleUnescapedString`,
  `char *MulleUTF8StringEscape( char *src, NSUInteger length, char *dst)`,
  `char *MulleUTF8StringUnescape( char *src, NSUInteger length, char *dst)`
- **`NSString+DoubleQuotes.h`:** `- (NSArray *) mulleComponentsSeparatedByWhitespaceWithDoubleQuoting`,
  `- (NSArray *) mulleComponentsSeparatedByWhitespaceWithSingleQuoting`,
  `- (NSArray *) mulleComponentsSeparatedByWhitespaceWithSingleAndDoubleQuoting`
- **`NSString+NSCharacterSet.h`:** `- (NSString *) stringByTrimmingCharactersInSet:(NSCharacterSet *) set`

### 3.5. MulleObjCTimeFoundation — Time & Date

**Location:** `src/MulleObjCTimeFoundation/`
**Key Headers:** `NSTimeInterval.h`, `NSDateFactory.h`, `NSDate.h`, `NSTimer.h`,
`NSTimer+NSDate.h`, `NSLock+NSDate.h`, `NSCondition+NSDate.h`,
`NSConditionLock+NSDate.h`, `NSThread+NSDate.h`

#### `NSTimeInterval` (`NSTimeInterval.h`)

```c
typedef mulle_calendartime_t    NSTimeInterval;
#define NSTimeIntervalSince1970  978307200.0
```

The reference epoch is **1.1.2001 GMT**, not 1970. `NSTimeIntervalSince1970`
is the offset between the epochs. Helpers: `_NSTimeIntervalNow()`,
`_NSTimeIntervalSince1970AsReferenceDate()`,
`_NSTimeIntervalSinceReferenceDateAsSince1970()`.

#### `NSDate` (immutable, class cluster)

```objc
@interface NSDate : NSObject < MulleObjCClassCluster, NSDateFactory, MulleObjCImmutable>

+ (instancetype) dateWithTimeIntervalSince1970:(NSTimeInterval) seconds;
+ (instancetype) dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval) seconds;
+ (instancetype) distantFuture;
+ (instancetype) distantPast;
- (instancetype) initWithTimeInterval:(NSTimeInterval) seconds sinceDate:(NSDate *) refDate;
- (instancetype) initWithTimeIntervalSince1970:(NSTimeInterval) seconds;
- (NSComparisonResult) compare:(id) other;
- (instancetype) dateByAddingTimeInterval:(NSTimeInterval) seconds;
- (NSDate *) earlierDate:(NSDate *) other;
- (NSDate *) laterDate:(NSDate *) other;
- (NSTimeInterval) timeIntervalSince1970;
- (NSTimeInterval) timeIntervalSinceDate:(NSDate *) other;
```

`SubclassesFuture`: `- (instancetype) initWithTimeIntervalSinceReferenceDate:(NSTimeInterval) seconds`,
`- (NSTimeInterval) timeIntervalSinceReferenceDate`.
`Future`: `+ (NSDate *) date`, `+ (NSTimeInterval) timeIntervalSinceReferenceDate`.

#### `NSTimer` (immutable, relative-time based)

```c
typedef void   NSTimerCallback_t( NSTimer *, id userInfo);
```

```objc
@interface NSTimer : NSObject < MulleObjCImmutableProtocols>

+ (instancetype) mulleTimerWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                     repeatInterval:(mulle_relativetime_t) repeatSeconds
                                         invocation:(NSInvocation *) invocation;
+ (instancetype) mulleTimerWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                     repeatInterval:(mulle_relativetime_t) repeatSeconds
                                             target:(id) target
                                           selector:(SEL) sel
                                           userInfo:(id) userInfo
                         fireUsesUserInfoAsArgument:(BOOL) flag;
+ (instancetype) mulleTimerWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                     repeatInterval:(mulle_relativetime_t) repeatSeconds
                                           callback:(NSTimerCallback_t) callback
                                           userInfo:(id) userInfo;
- (BOOL) isValid;
- (void) fire;
- (BOOL) mulleIsRelativeTimer;
- (mulle_relativetime_t) mulleRelativeTimeInterval;
- (mulle_relativetime_t) mulleRepeatTimeInterval;
```

Relative timers use monotonic `mulle_relativetime_t` and are intended for
`UIApplication`. Calendar ("absolute") timers are in `NSTimer( NSDate)`:
`+ (instancetype) timerWithTimeInterval:(NSTimeInterval) seconds target:(id) target selector:(SEL) selector userInfo:(id) userInfo repeats:(BOOL) repeats`,
`- (instancetype) initWithFireDate:(NSDate *) date interval:(NSTimeInterval) repeatSeconds target:(id) target selector:(SEL) selector userInfo:(id) userInfo repeats:(BOOL) repeats`,
`- (NSDate *) fireDate`, `- (NSTimeInterval) timeInterval` (this is the
**repeat** interval). Absolute timers must be added to a runloop/application
immediately after creation or they skew.

#### Time-aware locking categories

- `NSLock( NSDate)`: `- (BOOL) lockBeforeDate:(NSDate *) limit`
- `NSCondition( NSDate)`: `- (BOOL) waitUntilDate:(NSDate *) limit`,
  `- (BOOL) mulleWaitUntilTimeInterval:(NSTimeInterval) timeInterval`,
  `- (BOOL) mulleWaitWithTimeout:(mulle_relativetime_t) seconds`
- `NSConditionLock( NSDate)`: `- (BOOL) lockWhenCondition:(NSInteger) condition beforeDate:(NSDate *) limit`,
  `- (BOOL) lockBeforeDate:(NSDate *) limit`,
  `- (BOOL) mulleLockWhenCondition:(NSInteger) condition timeout:(mulle_relativetime_t) seconds`,
  `- (BOOL) mulleLockWhenCondition:(NSInteger) condition beforeTimeInterval:(NSTimeInterval) timeInterval`,
  `- (BOOL) mulleLockWithTimeout:(mulle_relativetime_t) seconds`.
  The `beforeDate:`/`beforeTimeInterval:`/`timeout:` family cannot deadlock;
  the `waitUntilDate:`/`waitUntilTimeInterval:` family can.
- `NSThread( NSDate)`: `+ (void) sleepUntilDate:(NSDate *) aDate`

### 3.6. MulleObjCUnicodeFoundation — Unicode Support

**Location:** `src/MulleObjCUnicodeFoundation/`
**Key Headers:** `NSString+MulleObjCUnicode.h`, `NSCharacterSet+MulleObjCUnicode.h`,
`NSMutableCharacterSet+MulleObjCUnicode.h`

Extends `NSCharacterSet` with additional predefined sets:

```objc
+ (instancetype) capitalizedLetterCharacterSet;
+ (instancetype) nonBaseCharacterSet;
+ (instancetype) decomposableCharacterSet;
+ (instancetype) illegalCharacterSet;
```

The umbrella header exposes version accessors
(`MulleObjCUnicodeFoundation_get_version_major/minor/patch`,
`MulleObjCUnicodeFoundation_get_version`) and inline private-character checks
(`mulle_unicode16_is_privatecharacter`, `mulle_unicode32_is_privatecharacter`,
`mulle_unicode_is_privatecharacterplane`). The `NSString` and
`NSMutableCharacterSet` categories are mostly placeholders; there is no
separate public selector list for them.

### 3.7. MulleObjCUUIDFoundation — UUIDs

**Location:** `src/MulleObjCUUIDFoundation/`
**Key Headers:** `NSUUID.h`, `uuid4.h`

```c
#define MulleUUIDBytesLength   16
#define MulleUUIDStringLength  37
```

#### `NSUUID` (subclass of NSData, exactly 16 bytes)

```objc
@interface NSUUID : NSData < MulleObjCValueProtocols>
{
   unsigned char  _bytes[ MulleUUIDBytesLength];
}

+ (instancetype) UUID;
- (instancetype) initWithUUIDString:(NSString *) s;
- (instancetype) initWithUUIDBytes:(unsigned char *) bytes;
- (void) getUUIDBytes:(unsigned char *) bytes;
- (NSString *) UUIDString;

@end
```

Strict RFC 4122 **version 4, variant 2**: `initWithUUIDString:` and
`initWithUUIDBytes:` reject inputs whose version/variant bits are not exactly
`4`/`10`. Format: `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`. `[NSUUID UUID]` is the
preferred constructor.

#### C-level UUID functions

```c
void   MulleGenerateUUIDBytes( unsigned char bytes[ MulleUUIDBytesLength]);

void   MulleUUIDBytesToUTF8String( unsigned char bytes[ MulleUUIDBytesLength],
                                   char output[ MulleUUIDStringLength]);

int    MulleUTF8StringToUUIDBytes( char input[ MulleUUIDStringLength],
                                   unsigned char bytes[ MulleUUIDBytesLength]);

static inline void           MulleUUIDBytesZeroVersioningBits( unsigned char bytes[ MulleUUIDBytesLength]);
static inline unsigned int   MulleUUIDBytesGetVersion( unsigned char bytes[ MulleUUIDBytesLength]);
static inline int            MulleUTF8StringGetUUIDVersion( char s[ MulleUUIDStringLength]);
static inline int            MulleUTF8StringGetUUIDVariant( char s[ MulleUUIDStringLength]);
```

`MulleGenerateUUIDBytes` is thread-safe but **not** cryptographically secure.
Call `MulleUUIDBytesZeroVersioningBits` on foreign 16-byte values first.

### 3.8. MulleObjCKVCFoundation — Key-Value Coding

**Location:** `src/MulleObjCKVCFoundation/`
**Key Headers:** `NSObject+KeyValueCoding.h`, `NSObject+KVCSupport.h`,
`MulleObjCContainerKeyValueCoding.h`, `NSNumber+MulleObjCKVCArithmetic.h`

Global exception name: `NSString *NSUndefinedKeyException`.

**Primary category** (`NSObject( _KeyValueCoding)`):

```objc
- (id) valueForKey:(NSString *) key;
- (void) takeValue:(id) value forKey:(NSString *) key;
- (void) takeValue:(id) value forKeyPath:(NSString *) keyPath;

+ (BOOL) useStoredAccessor;
- (id) storedValueForKey:(NSString *) key;
- (void) takeStoredValue:(id) value forKey:(NSString *) key;

- (id) handleQueryWithUnboundKey:(NSString *) key;
- (id) valueForUndefinedKey:(NSString *) key;
- (void) handleTakeValue:(id) value forUnboundKey:(NSString *) key;
- (void) unableToSetNilForKey:(NSString *) key;

- (NSDictionary *) valuesForKeys:(NSArray *) keys;
- (void) takeValuesFromDictionary:(NSDictionary *) properties;
```

**Compatibility category** (`NSObject( _KeyValueCodingCompatibility)`) —
"modern" KVC, thin forwarders:

```objc
- (void) setValue:(id) value forKey:(NSString *) key;
- (void) setValue:(id) value forKeyPath:(NSString *) key;
- (void) setValue:(id) value forUndefinedKey:(NSString *) key;
- (void) setNilValueForKey:(NSString *) key;
- (NSDictionary *) dictionaryWithValuesForKeys:(NSArray *) keys;
```

**Container helpers** (`MulleObjCContainerKeyValueCoding.h`):

```c
id     MulleObjCContainerValueForKey( id self, NSString *key, id container);
void   MulleObjCContainerTakeValueForKey( id self, id value, NSString *key);
```

**Arithmetic** (`NSNumber( MulleObjCKVCArithmetic)`):
`- (NSNumber *) _add:(NSNumber *) other`,
`- (NSNumber *) _divideByInteger:(NSUInteger) divisor`.

KVC maps keys over containers: `NSArray`/`NSSet` return a mapped collection
(nil elements become `[NSNull null]`; empty containers return `nil`),
`NSDictionary` maps to `objectForKey:`. Key paths split on `.`; a segment
starting with `@` is a collection operator: `@count` (O(1)), `@sum`, `@avg`,
`@min`, `@max`, optionally with a rest path (`@"@sum.price"`). Key resolution
("divination") is cached per class+key+method-type, so repeated accesses are
O(1) amortized.

### 3.9. MulleObjCMathFoundation — NSNumber Unification

**Location:** `src/MulleObjCMathFoundation/`
**Key Header:** `MulleObjCMathFoundation.h` (umbrella)

This library does **not** provide `sin`/`cos`/`exp`/`pow`. It exists solely to
refine `NSNumber` floating-point creation via the `NSNumber( Math)` category,
which needs `libm`. The refinement **unifies** numbers: an integral float such
as `1.0` becomes an integer `NSNumber`, while `1.5` stays a `double`; fractional
`long double` values are preserved and never degraded to `double`.

Overridden initializers (`@implementation NSNumber( Math)`):

```objc
- (instancetype) initWithFloat:(float) value;
- (instancetype) initWithDouble:(double) value;
- (instancetype) initWithLongDouble:(long double) value;  // only if _C_LNG_DBL
```

Prefer the ordinary factories `[NSNumber numberWithFloat:]`,
`[NSNumber numberWithDouble:]`, `[NSNumber numberWithLongDouble:]`; they invoke
these initializers automatically.

### 3.10. MulleObjCPlistFoundation — Property List I/O

**Location:** `src/MulleObjCPlistFoundation/`
**Key Headers:** `MulleObjCStream.h`, `MulleObjCPropertyListPrinting.h`,
`NSPropertyListSerialization.h`, `NSDictionary+PropertyList.h`,
`NSString+PropertyList.h`

#### Streams (`MulleObjCStream.h`)

```objc
@protocol MulleObjCInputStream < NSObject>
- (NSData *) readDataOfLength:(NSUInteger) length;
@end

@mixin MulleObjCOutputStream < NSObject>
@required
- (void) mulleWriteBytes:(void *) bytes length:(NSUInteger) length;
@optional
- (void) writeData:(NSData *) data;
- (void) mulleWriteUTF8String:(char *) s;
@end
```

`MulleObjCInMemoryInputStream` wraps `NSData`;
`NSMutableData( MulleObjCOutputStream)` conforms to `MulleObjCOutputStream`.
`NSString( MulleObjCOutputStream)` adds `- mulleWriteToStream:usingEncoding:` and
`- mulleWriteAsUTF8ToStream:`.

#### Property list printing (`MulleObjCPropertyListPrinting.h`)

```objc
@mixin MulleObjCPropertyListPrinting < NSObject>
- (void) mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt;
- (void) mullePrintJSON:(struct MulleObjCPrintPlistContext *) ctxt;
@optional
- (NSString *) mullePropertyListDescription;
- (NSString *) mulleJSONDescription;
- (void) mullePrintPlistToStream:(id <MulleObjCOutputStream>) handle;
- (void) mullePrintLoosePlistToStream:(id <MulleObjCOutputStream>) handle;
- (void) mullePrintJSONToStream:(id <MulleObjCOutputStream>) handle;
@end
```

#### `NSPropertyListSerialization`

```objc
@interface NSPropertyListSerialization : NSObject

+ (void) mulleAddFormatDetector:(SEL) detector;
+ (void) mulleAddParserClass:(Class) parserClass
                      method:(SEL) method
       forPropertyListFormat:(NSPropertyListFormat) format;
+ (void) mulleAddPrintMethod:(SEL) method
       forPropertyListFormat:(NSPropertyListFormat) format;
+ (BOOL) propertyList:(id) plist isValidForFormat:(NSPropertyListFormat) format;
+ (NSData *) dataFromPropertyList:(id) plist
                           format:(NSPropertyListFormat) format
                 errorDescription:(NSString **) errorString;
+ (NSData *) dataWithPropertyList:(id) plist
                           format:(NSPropertyListFormat) format
                          options:(NSPropertyListWriteOptions) options
                            error:(NSError **) p_error;
+ (id) mullePropertyListFromData:(NSData *) data
                mutabilityOption:(NSPropertyListMutabilityOptions) opt
                          format:(NSPropertyListFormat *) format
                    formatOption:(enum MullePropertyListFormatOption) formatOption;
+ (id) propertyListFromData:(NSData *) data
           mutabilityOption:(NSPropertyListMutabilityOptions) opt
                     format:(NSPropertyListFormat *) format
           errorDescription:(NSString **) errorString;
+ (id) propertyListWithData:(NSData *) data
                    options:(NSPropertyListMutabilityOptions) opt
                     format:(NSPropertyListFormat *) p_format
                      error:(NSError **) p_error;
@end

NSString   *MulleStringFromPropertListFormatString( NSPropertyListFormat format);
```

Formats: `NSPropertyListOpenStepFormat` (1), `MullePropertyListLooseFormat` (2),
`MullePropertyListPBXFormat` (3), `MullePropertyListYAMLFormat` (read-only,
needs `MulleObjCPlistYAMLFoundation`), `MullePropertyListJSONFormat` (6),
`NSPropertyListXMLFormat_v1_0` (100), `NSPropertyListBinaryFormat_v1_0` (200).
Mutability: `NSPropertyListImmutable`, `NSPropertyListMutableContainers`,
`NSPropertyListMutableContainersAndLeaves`. Format options:
`MullePropertyListFormatOptionDetect`, `...Prefer`, `...Force`.

#### Convenience categories

- `NSDictionary( PropertyList)`: `- (NSString *) descriptionInStringsFileFormat`
- `NSString( PropertyList)`: `- (id) propertyList`

### 3.11. MulleObjCRegexFoundation — Regular Expressions

**Location:** `src/MulleObjCRegexFoundation/`
**Key Headers:** `NSString+Regex.h`, `MulleObjCPattern.h`,
`MulleObjCPatternMatch.h`, `MulleObjCPatternEnumerator.h`, `NSScanner+Regex.h`,
`MulleObjCToken.h`, `MulleObjCTokenRule.h`, `MulleObjCTokenProblem.h`,
`MulleObjCTokenSet.h`, `MulleObjCTokenizer.h`

There is **no** `NSRegularExpression` class. Search/replace is a category on
`NSString`, and compiled patterns live in `MulleObjCPattern`.

#### `MulleObjCPatternOptions` (`NSString+Regex.h`)

```c
typedef   NS_ENUM( NSUInteger, MulleObjCPatternOptions)
{
   MulleObjCWildcardsShortestPath = 0x3000,              // also sets MulleWildcards
   MulleObjCWildcards             = 0x1000,
   MulleObjCSedPattern            = 0x4000,              // use \( instead of ( for grouping
   MulleObjCExtendedPattern       = 0x8000,
   MulleObjCAnchoredSearch        = NSAnchoredSearch,
   MulleObjCBackwardsSearch       = NSBackwardsSearch
};
```

#### `NSString( Regex)` — first-match only

```objc
@interface NSString( Regex)

- (NSRange) mulleRangeOfPattern:(NSString *) pattern;

- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution;

- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution
                                     options:(MulleObjCPatternOptions) options
                                       range:(NSRange) range;

- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution
                                     options:(MulleObjCPatternOptions) options;

- (NSRange) mulleRangeOfPattern:(NSString *) pattern
                        options:(MulleObjCPatternOptions) options
                          range:(NSRange) range;

- (NSRange) mulleRangeOfPattern:(NSString *) pattern
                        options:(MulleObjCPatternOptions) options;

@end
```

Replacement is **not global** (first match only). Substitution understands
`\1`..`\9` in the default and sed dialects; wildcards have no groups. On no
match `mulleRangeOfPattern` returns `NSRangeMake( 0, 0)`, not `NSNotFound`.

#### `MulleObjCPattern` — compiled, all-matches

```objc
@interface MulleObjCPattern : NSObject

+ (instancetype) patternWithString:(NSString *) pattern;
+ (instancetype) patternWithString:(NSString *) pattern options:(MulleObjCPatternOptions) options;
- (instancetype) initWithString:(NSString *) pattern options:(MulleObjCPatternOptions) options;
- (NSUInteger) numberOfCaptureGroups;
- (MulleObjCPatternMatch *) firstMatchInString:(NSString *) string;
- (MulleObjCPatternMatch *) firstMatchInString:(NSString *) string range:(NSRange) range;
- (NSArray *) matchesInString:(NSString *) string;
- (NSArray *) matchesInString:(NSString *) string range:(NSRange) range;
- (NSUInteger) numberOfMatchesInString:(NSString *) string;
- (NSUInteger) numberOfMatchesInString:(NSString *) string range:(NSRange) range;
- (MulleObjCPatternEnumerator *) matchEnumeratorInString:(NSString *) string;
- (MulleObjCPatternEnumerator *) matchEnumeratorInString:(NSString *) string range:(NSRange) range;
- (NSString *) stringByReplacingMatchesInString:(NSString *) string withTemplate:(NSString *) template;
- (NSString *) stringByReplacingMatchesInString:(NSString *) string range:(NSRange) range withTemplate:(NSString *) template;

@end
```

`MulleObjCPatternMatch` exposes `- (NSRange) range`,
`- (NSRange) rangeOfCaptureGroupAtIndex:(NSUInteger) index`,
`- (NSString *) substring`,
`- (NSString *) substringOfCaptureGroupAtIndex:(NSUInteger) index`.
`MulleObjCPatternEnumerator` conforms to `<NSFastEnumeration>` and offers
`- (MulleObjCPatternMatch *) nextObject` and `- (NSUInteger) count`.

#### `NSScanner( Regex)`

```objc
- (BOOL) scanPattern:(MulleObjCPattern *) pattern;
- (BOOL) scanPattern:(MulleObjCPattern *) pattern intoMatch:(MulleObjCPatternMatch **) matchp;
- (BOOL) scanUpToPattern:(MulleObjCPattern *) pattern intoString:(NSString **) stringp;
```

#### Tokenizer (`MulleObjCToken*`)

A table-driven tokenizer: `MulleObjCTokenSet` is the rule table (a subclass
overrides `+rules` / `+patternOptions` to define a language), and
`MulleObjCTokenizer` is a cursor into one text. `MulleObjCToken` reports which
rule matched and where. `MulleObjCTokenProblem` records characters the table
did not anticipate. Key methods:

```objc
// MulleObjCTokenSet
+ (NSArray *) rules;
+ (MulleObjCPatternOptions) patternOptions;
+ (instancetype) tokenSet;
+ (instancetype) tokenSetWithRules:(NSArray *) rules;
- (NSString *) problem;
- (BOOL) hasProblems;

// MulleObjCTokenizer
+ (instancetype) tokenizerWithText:(NSString *) text;
+ (instancetype) tokenizerWithText:(NSString *) text tokenSet:(MulleObjCTokenSet *) tokenSet;
- (MulleObjCToken *) nextToken;
- (MulleObjCToken *) nextSignificantToken;
```

## 4. Performance Characteristics

- **Linking:** O(1) symbol resolution against one library instead of 10.
- **Runtime:** zero overhead versus the individual libraries.
- **Values:** small values use tagged pointers (integers, floats, doubles, 5/7
  char ASCII strings) — no heap allocation. `UTF8String` on UTF-16/UTF-32
  strings is O(n) on first access (cached shadow), O(1) afterwards.
- **Containers:** `NSArray`/`NSMutableArray` use contiguous storage with
  doubling capacity; `NSDictionary`/`NSSet`/`NSOrderedSet` use hash tables.
  Average O(1) insert/lookup/remove; worst case O(n) under pathological
  collisions. `NSOrderedSet` keeps an additional ordered pointer array.
- **Strings:** ASCII (7-bit), UTF-16 (15-bit) and UTF-32 (full Unicode) internal
  representations; UTF-8 is the primary exchange format.
- **KVC:** key resolution is cached per class+key+method-type; O(1) amortized.
  Container key mapping and operators are O(n).
- **Regex:** `NSString` category compiles on every call; `MulleObjCPattern`
  compiles once and reuses. The engine is a backtracking regex — near-linear
  typical, exponential on pathological patterns.
- **Plist:** parsing/printing is O(n) in input/output size; the full object
  graph is materialized in memory.
- **UUID:** O(1) generation and conversion; `xorshift128plus` PRNG seeded once
  from OS entropy, guarded by a mutex.
- **Thread safety:** immutable classes are safe for concurrent reads; mutable
  containers and `NSMutableString`/`NSMutableData` require external locking.
  `NSNotificationCenter` is internally locked. `MulleGenerateUUIDBytes` is
  thread-safe. KVC caches are not thread-safe.

## 5. AI Usage Recommendations & Patterns

### Best Practices

- Import `<MulleFoundationBase/MulleFoundationBase.h>` once; per-constituent
  imports also work.
- Use convenience constructors (`+[NSArray array]`, `+[NSString stringWithUTF8String:]`,
  `+[NSNumber numberWithInt:]`, `+[NSUUID UUID]`) instead of `+alloc`/`-init`.
- Never call `-release` except in `-dealloc`; use `[[x copy] autorelease]` to
  convert mutable objects to immutable ones.
- Use `return( expr);` with parentheses, 3-space indent, Allman braces, one
  variable per line, no inline initialization.
- Prefer immutable classes for shared/concurrent reads; lock mutable containers.
- Use KVC key paths and collection operators for generic data-driven code.
- Use `MulleObjCPattern` when you need all matches or repeated matching; the
  `NSString` category only does the first match and recompiles each call.
- Persist plists with the `NSError`-based APIs
  (`dataWithPropertyList:format:options:error:` /
  `propertyListWithData:options:format:error:`).

### Common Pitfalls

- **No `NSRegularExpression`** — regex is `NSString(Regex)` plus
  `MulleObjCPattern`.
- **No `MulleObjCArchiverFoundation`** in this amalgamation — archiving is not a
  constituent. Do not document or `#import` it.
- **`unichar` is 32-bit** (`mulle_utf32_t`), not 16-bit.
- **`NSValue` is defined in `MulleObjC`**, not here, although `NSNumber`
  inherits from it.
- **`SubclassesFuture` methods are not on the abstract base** — `-count`,
  `-objectAtIndex:`, `-objectForKey:`, `-length`, `-bytes` are implemented by
  concrete cluster classes.
- **`NSDate` reference epoch is 2001**, not 1970. Mixing
  `timeIntervalSince1970` and `*SinceReferenceDate` is off by
  `NSTimeIntervalSince1970` (978307200.0).
- **`NSTimer( NSDate) -timeInterval` is the repeat interval**, not the fire
  time; use `fireDate` / `mulleFireTimeInterval`. Absolute timers must be added
  to a runloop immediately.
- **KVC unbound keys are fatal by default** (`NSUndefinedKeyException` on get);
  empty containers map to `nil`, missing elements to `[NSNull null]`.
- **Regex no-match returns `NSRangeMake( 0, 0)`**, so `location != NSNotFound`
  does not detect "no match". Replacement is first-match only.
- **`NSUUID` is strict v4/variant 2**; clear version bits on foreign byte arrays
  with `MulleUUIDBytesZeroVersioningBits` first.
- **`MulleObjCMathFoundation` has no trig/log/exp functions** — only NSNumber
  float/double/long-double unification.
- **`@mixin`** (not `@interface`) is used by `MulleObjCOutputStream` and
  `MulleObjCPropertyListPrinting`.
- Do not access `_`-prefixed concrete classes, ivars, or internal divination
  functions.

### Idiomatic Usage

```c
// 3-space indent, Allman braces, aligned declarations, no inline init
void   example( void)
{
   NSUUID      *uuid;
   NSArray     *array;
   NSUInteger  i, n;

   uuid  = [NSUUID UUID];
   array = [NSArray arrayWithObjects:@"one", @"two", @"three", nil];

   n = [array count];
   for( i = 0; i < n; i++)
   {
      // explicit message sends, never dot-syntax
      [[array objectAtIndex:i] description];
   }
}
```

## 6. Integration Examples

### Example 1: Containers, Values and UUIDs

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int   main( void)
{
   NSMutableArray   *tasks;
   NSString         *name;
   NSDate           *created;
   NSUUID           *projectId;
   NSUInteger       i, n;

   tasks     = [NSMutableArray arrayWithCapacity:10];
   name      = @"Project";
   created   = [NSDate dateWithTimeIntervalSince1970:1690000000.0];
   projectId = [NSUUID UUID];

   [tasks addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                        name,                   @"name",
                        created,                @"created",
                        [projectId UUIDString], @"id",
                        nil]];

   n = [tasks count];
   for( i = 0; i < n; i++)
   {
      mulle_printf( "%s\n",
                    [[[tasks objectAtIndex:i] objectForKey:@"name"] UTF8String]);
   }
   return( 0);
}
```

### Example 2: KVC and Collection Operators

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int   main( void)
{
   NSMutableArray   *records;
   NSArray          *names;
   NSNumber         *avgValue;
   NSUInteger       i;

   records = [NSMutableArray arrayWithCapacity:4];
   for( i = 0; i < 3; i++)
   {
      NSMutableDictionary   *record;

      record = [NSMutableDictionary dictionaryWithCapacity:3];
      [record setObject:[NSString stringWithFormat:@"Record%lu", (unsigned long) i]
                 forKey:@"name"];
      [record setObject:[NSNumber numberWithInt:(int) i * 10]
                 forKey:@"value"];
      [records addObject:record];
   }

   names    = [records valueForKey:@"name"];
   avgValue = [records valueForKeyPath:@"@avg.value"];

   mulle_printf( "Names: %s\n", [[names description] UTF8String]);
   mulle_printf( "Avg:   %.1f\n", [avgValue doubleValue]);
   return( 0);
}
```

### Example 3: Regex Pattern Matching

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int   main( void)
{
   NSString   *text;
   NSRange    range;

   text = @"The quick brown fox jumps over the lazy dog";

   range = [text mulleRangeOfPattern:@"brown"];
   if( range.location != NSNotFound)
      mulle_printf( "found at %lu\n", (unsigned long) range.location);

   range = [text mulleRangeOfPattern:@"b*wn"
                             options:MulleObjCWildcards];
   if( range.location != NSNotFound)
      mulle_printf( "wildcard at %lu len %lu\n",
                    (unsigned long) range.location,
                    (unsigned long) range.length);
   return( 0);
}
```

### Example 4: Property List Serialization

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int   main( void)
{
   NSDictionary   *config;
   NSData         *plistData;
   NSError        *error;

   error  = nil;
   config = [NSDictionary dictionaryWithObjectsAndKeys:
                @"MyApp", @"name",
                @"1.0",   @"version",
                nil];

   plistData = [NSPropertyListSerialization dataWithPropertyList:config
                                                          format:NSPropertyListXMLFormat_v1_0
                                                         options:0
                                                           error:&error];
   if( ! plistData)
      mulle_printf( "error: %s\n", [[error localizedDescription] UTF8String]);
   return( 0);
}
```

### Example 5: Time and Timers

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int   main( void)
{
   NSDate   *now;
   NSDate   *deadline;

   now      = [NSDate date];
   deadline = [now dateByAddingTimeInterval:0.5];

   if( [now compare:deadline] == NSOrderedAscending)
      mulle_printf( "now is earlier\n");

   mulle_printf( "now since 1970: %.0f\n", [now timeIntervalSince1970]);
   return( 0);
}
```

## 7. Dependencies

Direct `mulle-sde` dependencies (from `.mulle/etc/sourcetree/config`):

- `MulleObjC` — the Objective-C root classes, runtime, allocator and tagged
  pointer support (via `no-singlephase`).
- `math` — system `libm` (alias `m`), required by `MulleObjCMathFoundation`.

The 10 constituent directories under `src/` are themselves declared as
amalgamated dependencies (`clibmode=copy`, `no-build,no-header,no-link`), so
they are not separate libraries at link time.

Build/load tooling:
- `mulle-objc-list` — lists mulle-objc runtime information in executables
  (load-time bookkeeping, headers only).
