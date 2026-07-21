# MulleFoundationBase Library Documentation for AI
<!-- Keywords: ObjectiveC, amalgamation, collections, foundation, archiver, plist, unicode, UUID -->

## 1. Introduction & Purpose

MulleFoundationBase is an amalgamated library combining 11 core MulleFoundation
libraries into a single compilation unit. It aggregates platform-independent
Objective-C classes (containers, values, time, regex, plist, archiving, KVC,
math, unicode, UUID) without OS-specific dependencies.

**Advantages:**
- Single library to link against (`-lMulleFoundationBase`)
- Faster compilation than building all 11 constituents individually
- `#import` statements of individual libraries remain valid
- Can also use single unified import: `#import <MulleFoundationBase/MulleFoundationBase.h>`

**Dependencies:** `mulle-objc-list` (build tool), `MulleObjC` (runtime),
`math` (libm).

## 2. Key Concepts & Design Philosophy

- **Amalgamation Pattern**: Source files from all 11 constituents are copied
  into `src/` with `clibmode=copy`. Each constituent lives in its own
  subdirectory. The unification is a single build target, not a composition
  of sub-targets.
- **No OS Dependencies**: All 11 constituents are platform-independent.
  Platform-specific functionality lives in higher layers (e.g.,
  `MulleObjCOSFoundation`).
- **Object Initialization Style**: Avoid `+alloc`/`-init`/`-autorelease`.
  Prefer convenience constructors (`+stringWithString:`, `+array`, etc.)
  and factory methods. Never call `-release` except in `-dealloc`.
- **No dot-syntax**: Use explicit message sends for property access.
- **No blocks**: Do not use `^` block syntax.
- **Mixin Pattern**: Uses `@mixin` for cross-cutting concerns (e.g.,
  `MulleObjCPropertyListPrinting`).

## 3. Core API & Data Structures

### 3.1. Unified Import Path

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>
```

This umbrella header imports all 11 constituent headers. Individual constituent
imports also work:

```objc
#import <MulleObjCValueFoundation/MulleObjCValueFoundation.h>
#import <MulleObjCContainerFoundation/MulleObjCContainerFoundation.h>
// ... etc.
```

### 3.2. MulleObjCValueFoundation — Value Classes

**Location**: `src/MulleObjCValueFoundation/`
**Key Headers**: `NSString.h`, `NSNumber.h`, `NSData.h`, `NSMutableString.h`,
`NSMutableData.h`, `NSStringEncoding.h`, `NSConstantString.h`, `NSString+NSData.h`

#### `NSString` (immutable string, class cluster)

```objc
@interface NSString : NSObject < MulleObjCClassCluster, MulleObjCImmutable, MulleObjCImmutableCopying>
```

- **Factory**: `+ (instancetype) string`, `+ (instancetype) stringWithString:(NSString *) other`
- **Init**: `- (instancetype) initWithString:(NSString *) s`
- **Substrings**: `- (NSString *) substringWithRange:(NSRange) range`, `substringFromIndex:`, `substringToIndex:`
- **Numeric conversion**: `- (BOOL) boolValue`, `- (int) intValue`, `- (NSInteger) integerValue`, `- (long long) longLongValue`, `- (float) floatValue`, `- (double) doubleValue`, `- (long double) mulleLongDoubleValue`
- **Comparison**: `- (BOOL) isEqualToString:(NSString *) other`, `- (BOOL) hasPrefix:(NSString *) prefix`, `- (BOOL) hasSuffix:(NSString *) suffix`
- **UTF32**: `+ (instancetype) stringWithCharacters:(unichar *) s length:(NSUInteger) len`, `- (void) getCharacters:(unichar *) buffer`
- **UTF8**: `+ (instancetype) stringWithUTF8String:(char *) s`, `- (char *) UTF8String`

#### `NSString( MulleAdditions)` category

- `- (NSUInteger) mulleUTF8StringLength`
- `- (BOOL) mulleFastGetASCIIData:(struct mulle_asciidata *) space`
- `- (BOOL) mulleFastGetUTF8Data:(struct mulle_utf8data *) space`
- `- (BOOL) mulleFastGetUTF16Data:(struct mulle_utf16data *) space`
- `- (BOOL) mulleFastGetUTF32Data:(struct mulle_utf32data *) space`
- `+ (instancetype) mulleStringWithCharactersNoCopy:(unichar *) s length:(NSUInteger) len allocator:(struct mulle_allocator *) allocator`
- `+ (instancetype) mulleStringWithUTF8CharactersNoCopy:(char *) s length:(NSUInteger) len allocator:(struct mulle_allocator *) allocator`
- `+ (instancetype) mulleStringWithUTF8Characters:(char *) s length:(NSUInteger) len`
- `- (void) mulleGetUTF8Characters:(char *) buf`
- `- (NSUInteger) mulleGetUTF8Characters:(char *) buf maxLength:(NSUInteger) maxLength`
- `- (NSUInteger) mulleGetUTF8Characters:(char *) buf maxLength:(NSUInteger) maxLength range:(NSRange) range`
- `- (NSUInteger) mulleGetUTF8String:(char *) buf bufferSize:(NSUInteger) size`
- `- (mulle_utf16_t *) mulleUTF16String`
- Subclass requirements (`@optional`): `- (unichar) :(NSUInteger) index`, `- (NSUInteger) length`, `- (unichar) characterAtIndex:(NSUInteger) index`

#### `NSString ( Future)` category

- `- (NSString *) stringByAppendingString:(NSString *) other`
- `- (NSString *) stringByPaddingToLength:(NSUInteger) length withString:(NSString *) other startingAtIndex:(NSUInteger) index`
- `- (NSString *) stringByReplacingOccurrencesOfString:(NSString *) search withString:(NSString *) replacement`
- `- (NSString *) stringByReplacingOccurrencesOfString:(NSString *) search withString:(NSString *) replacement options:(NSUInteger) options range:(NSRange) range`
- `- (NSString *) stringByReplacingCharactersInRange:(NSRange) range withString:(NSString *) replacement`
- `- (NSString *) mulleStringByRemovingPrefix:(NSString *) other`
- `- (NSString *) mulleStringByRemovingSuffix:(NSString *) other`

#### C Function

- `struct mulle_utf8data   MulleStringUTF8Data( NSString *self, struct mulle_utf8data space)`

#### `NSStringEncoding` (header: `NSStringEncoding.h`)

Encoding constants: `NSASCIIStringEncoding` (1), `NSUTF8StringEncoding` (4),
`NSISOLatin1StringEncoding` (5), `NSUTF16StringEncoding` (10),
`NSMacOSRomanStringEncoding` (30), `NSUTF16BigEndianStringEncoding` (0x90000100),
`NSUTF16LittleEndianStringEncoding` (0x94000100), `NSUTF32StringEncoding` (0x8c000100),
`NSUTF32BigEndianStringEncoding` (0x98000100), `NSUTF32LittleEndianStringEncoding` (0x9c000100).

```c
type NSUInteger   NSStringEncoding;

type NS_OPTIONS( NSUInteger, MulleStringEncodingOptions)
{
   MulleStringEncodingOptionBOM               = 1,
   MulleStringEncodingOptionBOMIfNeeded       = 2,
   MulleStringEncodingOptionTerminateWithZero = 4,
};

char              *MulleStringEncodingUTF8String( NSStringEncoding encoding);
NSStringEncoding   MulleStringEncodingParseUTF8String( char *s);
```

#### `NSNumber` (immutable numeric value, class cluster)

```objc
@interface NSNumber : NSValue < NSCopying, MulleObjCImmutableCopying, MulleObjCClassCluster>
```

- **Factory** (all typed): `+ (instancetype) numberWithChar:(char) value`, `numberWithUnsignedChar:`, `numberWithShort:`, `numberWithUnsignedShort:`, `numberWithInt:`, `numberWithUnsignedInt:`, `numberWithInteger:(NSInteger) value`, `numberWithUnsignedInteger:(NSUInteger) value`, `numberWithLong:`, `numberWithUnsignedLong:`, `numberWithLongLong:(long long) value`, `numberWithUnsignedLongLong:(unsigned long long) value`, `numberWithFloat:(float) value`, `numberWithDouble:(double) value`, `numberWithBool:(BOOL) value`
- **Init** mirrors the factory methods with `initWith...:`
- **Access**: `- (BOOL) boolValue`, `- (char) charValue`, `- (unsigned char) unsignedCharValue`, `- (short) shortValue`, `- (unsigned short) unsignedShortValue`, `- (int) intValue`, `- (unsigned int) unsignedIntValue`, `- (long) longValue`, `- (unsigned long) unsignedLongValue`, `- (float) floatValue`, `- (unsigned long long) unsignedLongLongValue`, `- (NSUInteger) unsignedIntegerValue`
- **Comparison**: `- (NSComparisonResult) compare:(id) other`, `- (BOOL) isEqualToNumber:(id) other`

#### `NSString+NSData.h` — String ⇄ Data Conversion

Import/export of strings from/to `NSData` with encoding. Validates encoding correctness
on import. `- initWithData:encoding:` / `- dataUsingEncoding:` available via this header.

#### `NSData` and `NSMutableData`

```objc
@interface NSData : NSObject < NSCopying, MulleObjCImmutableCopying, MulleObjCClassCluster>

+ (instancetype) data;
+ (instancetype) dataWithBytes:(void *) bytes length:(NSUInteger) length;
+ (instancetype) dataWithBytesNoCopy:(void *) bytes length:(NSUInteger) length;
+ (instancetype) dataWithBytesNoCopy:(void *) bytes length:(NSUInteger) length freeWhenDone:(BOOL) flag;
+ (instancetype) dataWithData:(NSData *) data;
+ (instancetype) mulleDataWithCData:(struct mulle_cdata) cdata;
```

`NSMutableData` extends `NSData` with mutation: `+ (instancetype) dataWithCapacity:(NSUInteger) n`,
`+ (instancetype) dataWithLength:(NSUInteger) length`, `- (void) appendBytes:length:`,
`- (void) appendData:`, `- (void) setData:`, etc.

### 3.3. MulleObjCStandardFoundation — Standard Base Classes

**Location**: `src/MulleObjCStandardFoundation/`
**Key Headers**: `NSCalendarDate.h`, `NSError.h`, `NSException.h`, `NSNotification.h`,
`NSNotificationCenter.h`, `NSAssertionHandler.h`, `NSCharacterSet.h`,
`NSDateFormatter.h`, `NSLocale.h`, `NSSortDescriptor.h`, `NSString+NSLocale.h`,
`NSTimeZone.h`

#### `NSCalendarDate`

```objc
@interface NSCalendarDate : NSDate

+ (instancetype) calendarDate;
+ (instancetype) dateWithYear:(NSUInteger) year
                        month:(NSUInteger) month
                          day:(NSUInteger) day
                         hour:(NSUInteger) hour
                       minute:(NSUInteger) minute
                       second:(NSUInteger) second
                     timeZone:(NSTimeZone *) tz;
```

#### `NSError`

```objc
@interface NSError : NSObject < NSCopying>

+ (instancetype) errorWithDomain:(NSErrorDomain) domain
                            code:(NSInteger) code
                        userInfo:(NSDictionary *) dict;
```

Error domain management via `+ (void) registerErrorDomain:(NSErrorDomain) domain errorStringFunction:`, `+ (void) removeErrorDomain:`. Mulle additions: `+ (NSError *) mulleExtract`, `+ (void) mulleSetError:(NSError *) error`, `+ (void) mulleSetErrorCode:domain:userInfo:`.

#### `NSCharacterSet`

```objc
@interface NSCharacterSet : NSObject < NSCopying, MulleObjCClassCluster>

- (instancetype) initWithBitmapRepresentation:(NSData *) data;
- (NSData *) bitmapRepresentation;
- (BOOL) isSupersetOfSet:(NSCharacterSet *) set;
- (BOOL) longCharacterIsMember:(long) c;
+ (instancetype) characterSetWithCharactersInString:(NSString *) s;
// Predefined sets:
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

`SubclassesFuture`: `- (BOOL) characterIsMember:(unichar) c`, `- (BOOL) hasMemberInPlane:(NSUInteger) plane`, `- (NSCharacterSet *) invertedSet`.

#### `NSException`

```objc
@interface NSException : NSObject
+ (instancetype) exceptionWithName:(NSExceptionName) name
                            reason:(NSString *) reason
                          userInfo:(NSDictionary *) dict;
+ (void) raise:(NSExceptionName) name format:(NSString *) format, ...;
+ (void) raise:(NSExceptionName) name
        format:(NSString *) format
     arguments:(va_list) args;
```

#### `NSNotification` / `NSNotificationCenter`

```objc
@interface NSNotification : NSObject < NSCopying>
+ (instancetype) notificationWithName:(NSNotificationName) name object:(id) obj;
+ (instancetype) notificationWithName:(NSNotificationName) name
                               object:(id) obj
                             userInfo:(NSDictionary *) dict;
```

`NSNotificationCenter` is the singleton dispatch: `+ (instancetype) defaultCenter`.

#### `NSLocale` (stub)

```objc
@interface NSLocale : NSObject < NSCopying>
+ (instancetype) localeWithLocaleIdentifier:(NSString *) ident;
+ (instancetype) autoupdatingCurrentLocale;
+ (instancetype) currentLocale;
+ (instancetype) systemLocale;
```

#### `NSTimeZone` (stub)

```objc
@interface NSTimeZone : NSObject < NSCopying>
+ (instancetype) timeZoneWithName:(NSString *) name;
+ (instancetype) timeZoneWithAbbreviation:(NSString *) abbreviation;
+ (instancetype) defaultTimeZone;
+ (instancetype) localTimeZone;
+ (instancetype) systemTimeZone;
- (NSString *) name;
- (NSString *) abbreviation;
- (NSInteger) secondsFromGMTForDate:(NSDate *) date;
- (NSTimeInterval) daylightSavingTimeOffsetForDate:(NSDate *) date;
- (BOOL) isDaylightSavingTimeForDate:(NSDate *) date;
```

#### `NSSortDescriptor`

```objc
@interface NSSortDescriptor : NSObject < NSCopying>
+ (instancetype) sortDescriptorWithKey:(NSString *) key ascending:(BOOL) flag;
- (instancetype) initWithKey:(NSString *) key ascending:(BOOL) flag;
- (instancetype) initWithKey:(NSString *) key ascending:(BOOL) flag selector:(SEL) selector;
- (NSString *) key;
- (BOOL) ascending;
```

#### `NSDateFormatter` (stub)

```objc
@interface NSDateFormatter : NSFormatter
+ (NSDateFormatterBehavior) defaultFormatterBehavior;
+ (void) setDefaultFormatterBehavior:(NSDateFormatterBehavior) behavior;
+ (void) mulleSetClass:(Class) cls forFormatterBehavior:(NSDateFormatterBehavior) behavior;
- (NSString *) stringFromDate:(NSDate *) date;
- (NSDate *) dateFromString:(NSString *) s;
- (void) setDateFormat:(NSString *) format;
- (NSString *) dateFormat;
```

#### `NSAssertionHandler`

```objc
@interface NSAssertionHandler : NSObject
+ (instancetype) currentHandler;
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

### 3.4. MulleObjCContainerFoundation — Containers

**Location**: `src/MulleObjCContainerFoundation/`
**Key Headers**: `NSArray.h`, `NSMutableArray.h`, `NSDictionary.h`,
`NSMutableDictionary.h`, `NSSet.h`, `NSMutableSet.h`, `NSEnumerator.h`

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
- (NSUInteger) indexOfObjectIdenticalTo:(id) obj inRange:(NSRange) range;
- (id) firstObjectCommonWithArray:(NSArray *) other;
- (id) lastObject;
- (NSArray *) sortedArrayUsingSelector:(SEL) comparator;
- (NSArray *) sortedArrayUsingFunction:(NSComparisonResult (*)(id, id, void *)) comparator context:(void *) context;
- (NSArray *) subarrayWithRange:(NSRange) range;
- (void) getObjects:(id *) objects;
```

`NSArray( MulleAdditions)`: `+ (instancetype) mulleArrayWithArray:(NSArray *) other range:(NSRange) range`, `+ (instancetype) mulleArrayWithRetainedObjects:(id *) objects count:(NSUInteger) count`, `- (instancetype) mulleInitWithArray:andObject:`, `- (instancetype) mulleInitWithArray:andArray:`, `- (id) mulleForEachObjectCallFunction:(BOOL (*)( id, void *)) f argument:(void *) userInfo preempt:(enum MullePreempt) preempt`.

`SubclassesFuture`: `- (id) :(NSUInteger) index` (shortcut), `- (id) objectAtIndex:(NSUInteger) index`, `- (void) getObjects:(id *) objects range:(NSRange) range`, and `NSFastEnumeration`.

#### `NSMutableArray`

```objc
@interface NSMutableArray : NSArray < NSMutableArray, MulleObjCMutableContainerProtocols>

+ (instancetype) arrayWithCapacity:(NSUInteger) capacity;
- (instancetype) initWithCapacity:(NSUInteger) capacity;
- (void) addObject:(id) obj;
- (void) addObjectsFromArray:(NSArray *) otherArray;
- (void) insertObject:(id) obj atIndex:(NSUInteger) index;
- (void) replaceObjectAtIndex:(NSUInteger) index withObject:(id) obj;
- (void) removeLastObject;
- (void) removeObject:(id) obj;
- (void) removeObjectAtIndex:(NSUInteger) index;
- (void) removeObjectsInRange:(NSRange) range;
- (void) removeObjectIdenticalTo:(id) obj;
- (void) removeObjectIdenticalTo:(id) obj inRange:(NSRange) range;
- (void) removeAllObjects;
- (void) exchangeObjectAtIndex:(NSUInteger) index1 withObjectAtIndex:(NSUInteger) index2;
- (void) setArray:(NSArray *) other;
- (void) sortUsingSelector:(SEL) comparator;
- (void) sortUsingFunction:(NSComparisonResult (*)(id, id, void *)) compare context:(void *) context;
```

Mulle additions: `- (void) mulleAddRetainedObject:(id) obj`, `- (void) mulleReverseObjects`, `- (void) mulleMoveObjectsInRange:(NSRange) range toIndex:(NSUInteger) index`, `- (id) mulleRemoveLastObject`.

#### `NSDictionary` (immutable dictionary, class cluster)

```objc
@interface NSDictionary : MulleObjCContainer < MulleObjCClassCluster, MulleObjCImmutableCopying>

+ (instancetype) dictionary;
+ (instancetype) dictionaryWithDictionary:(NSDictionary *) other;
+ (instancetype) dictionaryWithObject:(id) obj forKey:(id) key;
+ (instancetype) dictionaryWithObjects:(id *) objects forKeys:(id *) keys count:(NSUInteger) count;
+ (instancetype) dictionaryWithObjectsAndKeys:(id) firstObject, ...;
- (instancetype) initWithDictionary:(NSDictionary *) other;
- (instancetype) initWithObjects:(id *) objects forKeys:(id *) keys count:(NSUInteger) count;
- (NSUInteger) count;
- (id) objectForKey:(id) key;
- (NSArray *) allKeys;
- (NSArray *) allValues;
- (NSEnumerator *) keyEnumerator;
- (NSEnumerator *) objectEnumerator;
```

#### `NSMutableDictionary`

```objc
@interface NSMutableDictionary : NSDictionary

+ (instancetype) dictionaryWithCapacity:(NSUInteger) capacity;
- (instancetype) initWithCapacity:(NSUInteger) capacity;
- (void) setObject:(id) obj forKey:(id) key;
- (void) removeObjectForKey:(id) key;
- (void) removeAllObjects;
- (void) addEntriesFromDictionary:(NSDictionary *) other;
- (void) setDictionary:(NSDictionary *) other;
```

#### `NSSet` / `NSMutableSet`

```objc
@interface NSSet : MulleObjCContainer < MulleObjCClassCluster, MulleObjCImmutableCopying>

+ (instancetype) set;
+ (instancetype) setWithSet:(NSSet *) other;
+ (instancetype) setWithObject:(id) obj;
+ (instancetype) setWithObjects:(id) firstObject, ...;
+ (instancetype) setWithObjects:(id *) objects count:(NSUInteger) count;
- (instancetype) initWithSet:(NSSet *) other;
- (instancetype) initWithObjects:(id *) objects count:(NSUInteger) count;
- (NSUInteger) count;
- (id) member:(id) obj;
- (id) anyObject;
- (BOOL) containsObject:(id) obj;
- (NSArray *) allObjects;
- (NSEnumerator *) objectEnumerator;
```

`NSMutableSet` extends with: `+ (instancetype) setWithCapacity:(NSUInteger) capacity`, `- (void) addObject:`, `- (void) removeObject:`, `- (void) removeAllObjects`, `- (void) unionSet:`, `- (void) intersectSet:`, `- (void) setSet:`.

#### `NSEnumerator`

```objc
@interface NSEnumerator : NSObject
- (id) nextObject;
@end
```

Categories on `NSDictionary` (`NSDictionary+NSEnumerator.h`) and `NSArray` provide `keyEnumerator`, `objectEnumerator`, and `reverseObjectEnumerator`.

### 3.5. MulleObjCTimeFoundation — Time & Date

**Location**: `src/MulleObjCTimeFoundation/`
**Key Headers**: `NSDate.h`, `NSTimeInterval.h`, `NSTimer.h`

#### `NSDate`

```objc
@interface NSDate : NSObject < NSCopying, MulleObjCImmutableCopying, MulleObjCClassCluster>

+ (instancetype) date;
+ (instancetype) dateWithTimeIntervalSince1970:(NSTimeInterval) seconds;
+ (instancetype) dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval) seconds;
+ (instancetype) distantFuture;
+ (instancetype) distantPast;
- (NSTimeInterval) timeIntervalSince1970;
- (NSTimeInterval) timeIntervalSinceReferenceDate;
- (NSTimeInterval) timeIntervalSinceDate:(NSDate *) other;
- (NSComparisonResult) compare:(NSDate *) other;
- (NSDate *) addTimeInterval:(NSTimeInterval) seconds;
```

#### `NSTimer`

```objc
@interface NSTimer : NSObject
+ (instancetype) scheduledTimerWithTimeInterval:(NSTimeInterval) ti
                                     invocation:(NSInvocation *) invocation
                                        repeats:(BOOL) flag;
+ (instancetype) scheduledTimerWithTimeInterval:(NSTimeInterval) ti
                                         target:(id) target
                                       selector:(SEL) selector
                                       userInfo:(id) userInfo
                                        repeats:(BOOL) flag;
- (void) fire;
- (void) invalidate;
- (BOOL) isValid;
- (NSTimeInterval) timeInterval;
```

Also provides categories `NSCondition+NSDate`, `NSConditionLock+NSDate`,
`NSLock+NSDate`, `NSThread+NSDate` with date-based wait methods.

### 3.6. MulleObjCUnicodeFoundation — Unicode Support

**Location**: `src/MulleObjCUnicodeFoundation/`
**Key Headers**: `NSString+MulleObjCUnicode.h`, `NSCharacterSet+MulleObjCUnicode.h`,
`NSMutableCharacterSet+MulleObjCUnicode.h`

Extends `NSString` with Unicode-aware operations: uppercase/lowercase/uppercase
letter transforms, case-insensitive comparison, capitalization. Extends
`NSCharacterSet` and `NSMutableCharacterSet` with Unicode plane and category
support.

### 3.7. MulleObjCUUIDFoundation — UUIDs

**Location**: `src/MulleObjCUUIDFoundation/`
**Key Headers**: `NSUUID.h`, `uuid4.h`

#### `NSUUID`

```objc
#define MulleUUIDBytesLength   16
#define MulleUUIDStringLength  37

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

NSUUID is a subclass of `NSData` with exactly 16 bytes. The `UUIDString` format is
`xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx` (version 4, variant 1).

#### C-level UUID functions

```c
void   MulleGenerateUUIDBytes( unsigned char bytes[ MulleUUIDBytesLength]);
void   MulleUUIDBytesToUTF8String( unsigned char bytes[ MulleUUIDBytesLength],
                                   char output[ MulleUUIDStringLength]);
int    MulleUTF8StringToUUIDBytes( char input[ MulleUUIDStringLength],
                                   unsigned char bytes[ MulleUUIDBytesLength]);
// Inline helpers:
void   MulleUUIDBytesZeroVersioningBits( unsigned char bytes[ MulleUUIDBytesLength]);
unsigned int   MulleUUIDBytesGetVersion( unsigned char bytes[ MulleUUIDBytesLength]);
int    MulleUTF8StringGetUUIDVersion( char s[ MulleUUIDStringLength]);
int    MulleUTF8StringGetUUIDVariant( char s[ MulleUUIDStringLength]);
```

`MulleGenerateUUIDBytes` is thread-safe.

### 3.8. MulleObjCKVCFoundation — Key-Value Coding

**Location**: `src/MulleObjCKVCFoundation/`
**Key Headers**: `NSObject+KeyValueCoding.h`, `NSObject+KVCSupport.h`

Provides `- (id) valueForKey:(NSString *) key`, `- (void) setValue:(id) value forKey:(NSString *) key`,
`- (id) valueForKeyPath:(NSString *) keyPath`, `- (void) setValue:(id) value forKeyPath:(NSString *) keyPath`.

Also: `- (NSDictionary *) dictionaryWithValuesForKeys:(NSArray *) keys`,
`- (void) takeValuesFromDictionary:(NSDictionary *) dict`.

KVC collection operators (e.g., `@"@count"`, `@"@avg.value"`, `@"@max.value"`) are
supported on array-valued properties.

### 3.9. MulleObjCMathFoundation — Math on NSNumber

**Location**: `src/MulleObjCMathFoundation/`
**Key Headers**: `NSNumber+Math.h` (category)

Provides math operations as `NSNumber` extensions via categories:
- Trigonometric: `sin`, `cos`, `tan`, `asin`, `acos`, `atan`
- Exponential/Log: `exp`, `log`, `log10`, `pow:`
- Rounding: `ceil`, `floor`, `round`
- Other: `sqrt`, `fabs`, `fmod:`
- Constants: `MulleMath_PI`, `MulleMath_E`, etc.

### 3.10. MulleObjCPlistFoundation — Property List I/O

**Location**: `src/MulleObjCPlistFoundation/`
**Key Headers**: `MulleObjCPlistFoundation.h`, `MulleObjCPropertyListPrinting.h`,
`MulleObjCStream.h`, `NSPropertyListSerialization.h`

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

`MulleObjCInMemoryInputStream` wraps `NSData` as input stream.
`NSMutableData` conforms to `MulleObjCOutputStream`.

#### Property List Printing (`MulleObjCPropertyListPrinting.h`)

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

Context functions: `MulleObjCPrintPlistContextInit`, `MulleObjCPrintPlistContextSetHandle`,
`MulleObjCPrintPlistContextUTF8Indentation`, `MulleObjCPrintPlistContextWriteUTF8String`,
`MulleObjCPrintPlistContextWriteBytes`.

#### `NSPropertyListSerialization`

```objc
@interface NSPropertyListSerialization : NSObject

+ (NSData *) dataWithPropertyList:(id) plist
                           format:(NSPropertyListFormat) format
                          options:(NSPropertyListWriteOptions) opt
                            error:(NSError **) error;
+ (id) propertyListWithData:(NSData *) data
                    options:(NSPropertyListReadOptions) opt
                     format:(NSPropertyListFormat *) format
                      error:(NSError **) error;
+ (BOOL) propertyList:(id) plist isValidForFormat:(NSPropertyListFormat) format;
@end
```

Formats: `NSPropertyListOpenStepFormat`, `NSPropertyListXMLFormat_v1_0`,
`NSPropertyListBinaryFormat_v1_0`.

### 3.11. MulleObjCArchiverFoundation — Object Archiving

**Location**: `src/MulleObjCArchiverFoundation/`
**Key Headers**: `NSCoder.h`, `MulleObjCArchiver.h`, `MulleObjCUnarchiver.h`,
`NSArchiver.h`, `NSUnarchiver.h`, `NSKeyedArchiver.h`, `NSKeyedUnarchiver.h`,
`NSObject+NSCoder.h`

#### `NSCoder` (abstract)

```objc
@interface NSCoder : NSObject
// Encoding
- (void) encodeBytes:(const void *) addr length:(NSUInteger) length;
- (void) encodeBytes:(const void *) bytes length:(NSUInteger) length forKey:(NSString *) key;
- (void) encodeObject:(id) object;
- (void) encodeObject:(id) obj forKey:(NSString *) key;
- (void) encodeConditionalObject:(id) object;
- (void) encodeConditionalObject:(id) obj forKey:(NSString *) key;
- (void) encodePropertyList:(id) plist;
- (void) encodePropertyList:(id) plist forKey:(NSString *) key;
// Decoding
- (void *) decodeBytesWithReturnedLength:(NSUInteger *) length;
- (const uint8_t *) decodeBytesForKey:(NSString *) key returnedLength:(NSUInteger *) length;
- (id) decodeObject;
- (id) decodeObjectForKey:(NSString *) key;
- (NSInteger) versionForClassName:(NSString *) className;
@end
```

#### `MulleObjCArchiver` (binary archiver)

```objc
@interface MulleObjCArchiver : NSCoder

- (instancetype) initForWritingWithMutableData:(NSMutableData *) data;
+ (NSData *) archivedDataWithRootObject:(id) rootObject;
- (void) encodeRootObject:(id) rootObject;
- (NSString *) classNameEncodedForTrueClassName:(NSString *) trueName;
- (void) encodeClassName:(NSString *) runtime intoClassName:(NSString *) archive;
- (NSMutableData *) archiverData;
@end
```

#### `MulleObjCUnarchiver`

```objc
@interface MulleObjCUnarchiver : NSCoder

- (instancetype) initForReadingWithData:(NSData *) data;
- (BOOL) atEnd;
+ (id) unarchiveObjectWithData:(NSData *) data;
- (void) decodeClassName:(NSString *) inArchiveName asClassName:(NSString *) trueName;
- (NSString *) classNameDecodedForArchiveClassName:(NSString *) inArchiveName;
- (void) replaceObject:(id) object withObject:(id) newObject;
@end
```

`NSArchiver` and `NSUnarchiver` are concrete convenience wrappers around
`MulleObjCArchiver`/`MulleObjCUnarchiver`.

`NSKeyedArchiver`/`NSKeyedUnarchiver` provide keyed archiving support.
`NSObject+NSCoder` provides NSCoding protocol methods.

### 3.12. MulleObjCRegexFoundation — Regular Expressions

**Location**: `src/MulleObjCRegexFoundation/`
**Key Headers**: `NSString+Regex.h`

Pattern matching is provided as an `NSString( Regex)` category, **not** as a
separate `NSRegularExpression` class:

```objc
typedef NS_ENUM( NSUInteger, MulleObjCPatternOptions)
{
   MulleObjCWildcardsShortestPath = 0x3000,
   MulleObjCWildcards             = 0x1000,
   MulleObjCSedPattern            = 0x4000,
   MulleObjCAnchoredSearch        = NSAnchoredSearch,
   MulleObjCBackwardsSearch       = NSBackwardsSearch,
};

@interface NSString( Regex)

- (NSRange) mulleRangeOfPattern:(NSString *) pattern;
- (NSRange) mulleRangeOfPattern:(NSString *) pattern
                        options:(MulleObjCPatternOptions) options;
- (NSRange) mulleRangeOfPattern:(NSString *) pattern
                        options:(MulleObjCPatternOptions) options
                          range:(NSRange) range;

- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution;
- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution
                                     options:(MulleObjCPatternOptions) options;
- (NSString *) mulleStringByReplacingPattern:(NSString *) pattern
                                  withString:(NSString *) substitution
                                     options:(MulleObjCPatternOptions) options
                                       range:(NSRange) range;
@end
```

Wildcard support (`*`, `?`, `[a-z]`, `[^a-z]`): `MulleObjCWildcards` extends as far
as possible; `MulleObjCWildcardsShortestPath` extends as short as possible.

## 4. Performance Characteristics

- **Linking**: O(1) single library symbol resolution (vs. 11 separate libraries).
- **Runtime**: Zero overhead from amalgamation — identical to individual libraries.
  The classes are inlined from constituent sources but share the same runtime
  behavior.
- **Containers**: `NSArray`/`NSMutableArray` use contiguous storage with doubling
  capacity. `NSDictionary`/`NSSet` use hash tables. All O(1) amortized add/get/remove.
- **Strings**: Class cluster with ASCII (7-bit), UTF-16 (15-bit), and UTF-32
  internal representations. Conversion happens lazily through `mulleFastGet*` APIs.
- **Thread safety**: None of the mutable container classes are thread-safe.
  `MulleGenerateUUIDBytes` is explicitly thread-safe.
- **NSUUID**: O(1) generation and comparison. Uses RFC 4122 version 4 (random)
  generation.

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Use convenience constructors**: Prefer `+[NSArray array]`, `+[NSString
  stringWithUTF8String:]`, etc. over `+alloc`/`-init`/`-autorelease`.
- **Never call `-release`** except in `-dealloc` methods.
- **Use `+instance` patterns** for singleton-like objects where available.
- **`return( expr);`** — always parenthesize return expressions.
- **Use `#import <MulleFoundationBase/MulleFoundationBase.h>`** for simplicity;
  individual constituent imports also work.
- **Use `MulleUUIDBytesToUTF8String`** for C-level UUID-to-string conversion
  (avoids object allocation).

### Common Pitfalls

- **No `NSRegularExpression` class exists** — regex is done through
  `NSString(Regex)` category methods prefixed `mulle`.
- **`NSCharacterSet` and `NSCalendarDate`** are in `MulleObjCStandardFoundation`,
  not in Unicode or Time respectively.
- **`NSValue` was removed** from the amalgamation — `NSNumber` inherits from it
  but the base `NSValue` is provided by the runtime.
- **`@mixin` not `@interface`**: `MulleObjCPropertyListPrinting` and
  `MulleObjCOutputStream` use the `@mixin` keyword (MulleObjC extension).
- **Mutable containers do not deep-copy** — `-setArray:`, `-setDictionary:`, etc.
  perform shallow copies.
- **UTF8 strings from `NSString`** — returned `char *` pointers are borrowed;
  do not free them.

### Idiomatic Usage (project style)

```c
// 3-space indent, Allman braces, no inline init
void   example( void)
{
   NSUUID      *uuid;
   NSArray     *array;
   char        uuid_string[ MulleUUIDStringLength];
   NSUInteger  i, n;

   uuid = [NSUUID UUID];
   array = [NSArray arrayWithObjects:@"one", @"two", @"three", nil];

   n = [array count];
   for( i = 0; i < n; i++)
   {
      // Use explicit message sends, not dot-syntax
      [[array objectAtIndex:i] description];
   }

   MulleUUIDBytesToUTF8String( [uuid bytes], uuid_string);
   // uuid_string now holds e.g. "550e8400-e29b-41d4-a716-446655440000"
}
```

## 6. Integration Examples

### Example 1: Using Multiple Constituent Libraries

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

// mulle-sde style: 3-space indent, Allman braces, one var per line, C89 vars at top
int   main( void)
{
   NSMutableArray    *tasks;
   NSString          *name;
   NSDate            *created;
   NSUUID            *projectId;
   NSCalendarDate    *today;
   NSUInteger        i, n;

   tasks      = [NSMutableArray arrayWithCapacity:10];
   name       = @"Project";
   created    = [NSDate date];
   projectId  = [NSUUID UUID];
   today      = [NSCalendarDate calendarDate];

   [tasks addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                       name,                       @"name",
                       created,                    @"created",
                       [projectId UUIDString],     @"id",
                       nil]];

   n = [tasks count];
   for( i = 0; i < n; i++)
   {
      NSLog( @"%@", [[tasks objectAtIndex:i] objectForKey:@"name"]);
   }
   return( 0);
}
```

### Example 2: KVC and Container Operations

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int   main( void)
{
   NSMutableArray    *records;
   NSArray           *names;
   NSNumber          *avgValue;
   NSUInteger        i;

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
   avgValue = [records valueForKey:@"@avg.value"];

   NSLog( @"Names: %@", names);
   NSLog( @"Avg value: %@", avgValue);
   return( 0);
}
```

### Example 3: String Pattern Matching

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int   main( void)
{
   NSString    *text;
   NSRange     range;

   text = @"The quick brown fox jumps over the lazy dog";

   // find the first match
   range = [text mulleRangeOfPattern:@"brown" options:0 range:NSMakeRange( 0, [text length])];
   if( range.location != NSNotFound)
   {
      NSLog( @"Found 'brown' at location %lu", (unsigned long) range.location);
   }

   // wildcard search (b*wn)
   range = [text mulleRangeOfPattern:@"b*wn"
                             options:MulleObjCWildcards
                               range:NSMakeRange( 0, [text length])];
   if( range.location != NSNotFound)
   {
      NSLog( @"Wildcard match at location %lu", (unsigned long) range.location);
   }
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
   id             restored;

   error  = nil;
   config = @{
      @"name"  : @"MyApp",
      @"value" : @"1.0",
   };

   plistData = [NSPropertyListSerialization dataWithPropertyList:config
                                                          format:NSPropertyListXMLFormat
                                                         options:0
                                                           error:&error];
   if( error)
   {
      NSLog( @"Error: %@", error);
      return( 1);
   }

   restored = [NSPropertyListSerialization propertyListWithData:plistData
                                                        options:0
                                                         format:NULL
                                                          error:&error];
   NSLog( @"Restored: %@", restored);
   return( 0);
}
```

### Example 5: Object Archiving

```objc
#import <MulleFoundationBase/MulleFoundationBase.h>

int   main( void)
{
   NSData                *data;
   NSMutableDictionary   *dict;
   NSDictionary          *restored;

   dict = [NSMutableDictionary dictionaryWithCapacity:3];
   [dict setObject:[NSUUID UUID] forKey:@"id"];
   [dict setObject:[NSDate date] forKey:@"created"];
   [dict setObject:@"Hello World" forKey:@"message"];

   data    = [NSArchiver archivedDataWithRootObject:dict];
   NSLog( @"Archived to %lu bytes", (unsigned long) [data length]);

   restored = [NSUnarchiver unarchiveObjectWithData:data];
   NSLog( @"Restored message: %@", [restored objectForKey:@"message"]);
   return( 0);
}
```

## 7. Dependencies

Direct dependencies (from `.mulle/etc/sourcetree/config`):

| Dependency | Description |
|---|---|
| `MulleObjC` | Objective-C runtime and root classes |
| `mulle-objc-list` | Build-time tool for listing runtime info (no-link, no-header) |
| `math` (libm) | System math library (no-build, only-platform-linux) |

Internal constituent dependencies (copy-mode, no individual build):

| Constituent | Source directory |
|---|---|
| `MulleObjCArchiverFoundation` | `src/MulleObjCArchiverFoundation/` |
| `MulleObjCContainerFoundation` | `src/MulleObjCContainerFoundation/` |
| `MulleObjCKVCFoundation` | `src/MulleObjCKVCFoundation/` |
| `MulleObjCMathFoundation` | `src/MulleObjCMathFoundation/` |
| `MulleObjCPlistFoundation` | `src/MulleObjCPlistFoundation/` |
| `MulleObjCRegexFoundation` | `src/MulleObjCRegexFoundation/` |
| `MulleObjCStandardFoundation` | `src/MulleObjCStandardFoundation/` |
| `MulleObjCTimeFoundation` | `src/MulleObjCTimeFoundation/` |
| `MulleObjCUnicodeFoundation` | `src/MulleObjCUnicodeFoundation/` |
| `MulleObjCUUIDFoundation` | `src/MulleObjCUUIDFoundation/` |
| `MulleObjCValueFoundation` | `src/MulleObjCValueFoundation/` |

## 8. Linking

```
-lMulleFoundationBase
```

A single library provides all 11 constituent APIs. No need to link constituent
libraries individually.
