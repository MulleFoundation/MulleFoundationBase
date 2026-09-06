# MulleObjCUUIDFoundation Library Documentation for AI
<!-- Keywords: uuid, identifiers, rfc4122, value, nsuuid, objc -->

## 1. Introduction & Purpose

MulleObjCUUIDFoundation is a small mulle-objc library that provides the `NSUUID`
value class for generating and working with RFC 4122 **version 4, variant 2**
UUIDs — 128-bit identifiers with an astronomically low collision probability.

Key features at a high level:

- `NSUUID` is a subclass of `NSData` and conforms to `MulleObjCValueProtocols`,
  so instances behave like other value classes in the mulle-objc ecosystem
  (usable via `description`, `UTF8String`, equality/hash for collections).
- Strict validation: it only accepts canonical, strict-format UUID strings and
  only 16-byte arrays whose version/variant bits are cleared. Foreign UUIDs
  must be normalized first.
- Standalone C API (no objects needed) for generating random UUID bytes and
  converting between the 16-byte and 37-character representations.
- A component of the MulleFoundation library; layered on top of
  `MulleObjCValueFoundation`.

## 2. Key Concepts & Design Philosophy

- **Strict RFC 4122 v4**: The README states "The class will not accept any old
  16 byte array as an UUID." The version nibble (position 6, upper) must be `4`
  and the variant bits (position 8, upper two bits) must be `10` (variant 2).
  `initWithUUIDString:` and `initWithUUIDBytes:` enforce this strictly.
- **Two canonical representations**: 16 raw bytes (the internal `_bytes`
  member, `[MulleUUIDBytesLength]`) and the canonical hyphenated string
  `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx` of `[MulleUUIDStringLength]` chars
  (37 including the trailing `\0`). 6 of the 128 bits are "wasted" on
  versioning/variant.
- **Object-less C API first**: The byte <-> string conversion and random
  generation are implemented as plain C functions in `NSUUID.h`; the `NSUUID`
  methods are thin wrappers around them. This makes the functionality usable
  without instantiating any object.
- **OS-seeded PRNG**: Random bytes come from a `xorshift128plus` PRNG seeded
  once from an OS entropy source (`/dev/urandom` on Linux, `getrandom`,
  `CryptGenRandom` on Windows). Generation is guarded by a mutex and is
  thread-safe, but it is **not** a cryptographically secure RNG.
- **Value semantics**: Instances are immutable value objects; the `getUUIDBytes:`
  accessor copies out, it does not expose the internal buffer.

## 3. Core API & Data Structures

### 3.1. `src/NSUUID.h`

Constants:

```c
#define MulleUUIDBytesLength   16
#define MulleUUIDStringLength  37
```

#### `NSUUID : NSData < MulleObjCValueProtocols>`

Declaration (verbatim):

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

- **Purpose:** Immutable value class holding one UUID in 16 raw bytes.
- **Key Field:** `_bytes` — the 16-byte UUID storage; never access it directly,
  use `getUUIDBytes:` or `UUIDString`.
- **Lifecycle / Factory Methods:**
  - `+ (instancetype) UUID;` — Generates and returns a new random version-4
    UUID (`[[self new] autorelease]`; `new`/`-init` seeds `_bytes` via
    `MulleGenerateUUIDBytes`). This is the preferred way to create an NSUUID.
  - `- (instancetype) initWithUUIDBytes:(unsigned char *) bytes;` — Initializes
    from 16 bytes. Returns `nil` (and prints an error to stderr) if
    `(bytes[6] & 0xF0) || (bytes[8] & 0xC0)` — i.e. version/variant bits set.
    Call `MulleUUIDBytesZeroVersioningBits` first for foreign byte arrays.
  - `- (instancetype) initWithUUIDString:(NSString *) s;` — Initializes from a
    strict canonical string (exactly the format produced by `UUIDString`).
    Returns `nil` if the string does not match. There is no +factory for this;
    use the `[[[NSUUID alloc] initWith…] autorelease]` idiom.
- **Core Operations:**
  - `- (void) getUUIDBytes:(unsigned char *) bytes;` — Copies the 16 UUID
    bytes into the caller-supplied buffer.
  - `- (NSString *) UUIDString;` — Returns the canonical hyphenated string
    `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx` as a fresh `NSString`.
- **Inherited / Protocol behavior:** Because `NSUUID : NSData
  < MulleObjCValueProtocols>`, it inherits value-protocol members from
  `NSData`/`MulleObjCValueProtocols` (in `MulleObjCValueFoundation`), e.g.
  `description` (returns `UUIDString`), `UTF8String` (used as `[uuid UTF8String]`
  in tests), `length` (returns `MulleUUIDBytesLength`), `bytes` (borrowed
  pointer into `_bytes`), plus equality/hash for use in collections.

#### Standalone C functions

```c
// this is thread-safe
void   MulleGenerateUUIDBytes( unsigned char bytes[ MulleUUIDBytesLength]);
```

- Generates random version-4 bytes into the 16-byte buffer. Lazy: only the
  first call reads OS entropy to seed the PRNG; afterwards it is pure
  `xorshift128plus`. Thread-safe (internal mutex). `abort()`s if OS
  seeding fails.

```c
//
// generate output string (including \0) of strict format
// xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
// actual bits: 30*4 + 2 = 122 ... 6 bits are wasted on versioning
//
void   MulleUUIDBytesToUTF8String( unsigned char bytes[ MulleUUIDBytesLength],
                                   char output[ MulleUUIDStringLength]);
```

- Writes the canonical hyphenated string (lowercase hex, including trailing
  `\0`) for the given bytes. The `4` and `y` placeholders are overwritten, so
  the byte's version/variant bits do not influence the output.

```c
// return -1, if input is incompatible. must be strictly the same as
// was generated by UUIDString
int   MulleUTF8StringToUUIDBytes( char input[ MulleUUIDStringLength],
                                  unsigned char bytes[ MulleUUIDBytesLength]);
```

- Strictly parses a canonical string; the input must match the template
  `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx` exactly (the `4` must be a literal
  `'4'`, the `y` a hex digit `8`..`b` i.e. variant bits `10`). Returns `0` on
  success, `-1` on failure; on failure the output buffer is zeroed with
  `memset( bytes, 0, 16)`.

Static inline helpers:

```c
static inline void   MulleUUIDBytesZeroVersioningBits( unsigned char bytes[ MulleUUIDBytesLength])
```
- Clears the version/variant bits in place: `bytes[ 6] &= 0x0F; bytes[ 8] &= 0x3F;`.
  Use on foreign 16-byte values before `initWithUUIDBytes:`.

```c
static inline unsigned int   MulleUUIDBytesGetVersion( unsigned char bytes[ MulleUUIDBytesLength])
```
- Returns `bytes[ 6] >> 4`, the version nibble (4 for NSUUID).

```c
static inline int   MulleUTF8StringGetUUIDVersion( char s[ MulleUUIDStringLength])
```
- Returns the digit at `s[ 14]` ('0'..'9') or `-1`.

```c
static inline int   MulleUTF8StringGetUUIDVariant( char s[ MulleUUIDStringLength])
```
- Hex-parses `s[ 19]` and returns `c >> 2` (0..3) or `-1` if non-hex.

### 3.2. `src/MulleObjCUUIDFoundation.h`

The library version API:

```c
#define MULLE_OBJC_UUID_FOUNDATION_VERSION  ((0UL << 20) | (0 << 8) | 10)


static inline unsigned int   MulleObjCUUIDFoundation_get_version_major( void)
```
```c
static inline unsigned int   MulleObjCUUIDFoundation_get_version_minor( void)
```
```c
static inline unsigned int   MulleObjCUUIDFoundation_get_version_patch( void)
```
```c
MULLE_OBJC_UUID_FOUNDATION_GLOBAL
uint32_t   MulleObjCUUIDFoundation_get_version( void);
```

- Encoded `MULLE_OBJC_UUID_FOUNDATION_VERSION` is `(major << 20) | (minor << 8)
  | patch`; decode via the accessors or the full `uint32_t` value.

This header ends with `#import "NSUUID.h"`, so importing
`MulleObjCUUIDFoundation.h` brings in the whole API.

### 3.3. `src/generic/MulleObjCDeps+MulleObjCUUIDFoundation.h`

```objc
@interface MulleObjCDeps( MulleObjCUUIDFoundation)

+ (struct _mulle_objc_dependency *) dependencies;

@end
```

- Declared so dependent libraries can correctly declare their load of this
  library in their `MulleObjcLoader` class. Normally you don't use this
  directly.

## 4. Performance Characteristics

- **Generation:** O(1). Two `xorshift128plus` steps plus version-bit zeroing,
  guarded by a mutex. The first call additionally does one OS entropy read
  (e.g. `/dev/urandom`) to seed; subsequent calls never touch the OS.
- **Byte -> String / String -> Byte conversion:** O(1), fixed 16-byte input /
  37-byte output. Parsing is a strict template walk, not a regex or parse tree.
- **Comparison / Hashing:** inherited from `NSData`/`MulleObjCValueProtocols` —
  O(1) (16-byte compare) and constant-time hashing over the 16 bytes.
- **Memory:** 16 bytes of UUID payload per instance (plus object overhead);
  each `UUIDString` is a 37-byte string.
- **Thread-safety:** `MulleGenerateUUIDBytes` is documented thread-safe (mutex).
  Instances are immutable value objects — safe to share read-only across
  threads once created.
- **Trade-off:** `xorshift128plus` is fast but is *not* cryptographically
  secure; UUIDs are for uniqueness, not security tokens.

## 5. AI Usage Recommendations & Patterns

### Best Practices

- Always create random UUIDs with the factory `[NSUUID UUID]` — it handles
  seeding and version-bit formatting for you.
- For byte/string-initialized objects, use the one-shot idiom from the tests:
  `[[[NSUUID alloc] initWithUUIDBytes:bytes] autorelease]` (auto-released at
  scope end).
- Run `MulleUUIDBytesZeroVersioningBits( bytes)` on *any foreign* 16-byte
  value (e.g. an MD5/hash digest) before passing it to `initWithUUIDBytes:`.
- Persist/print UUIDs as strings via `UUIDString` / `[uuid UTF8String]`;
  prefer `isEqual:` (or value-protocol equality/hashing) over string
  comparison for lookups.
- Use the C functions `MulleGenerateUUIDBytes`, `MulleUUIDBytesToUTF8String`,
  `MulleUTF8StringToUUIDBytes` when you need UUID handling without object
  allocation.

### Common Pitfalls

- Do not pass arbitrary 16-byte arrays to `initWithUUIDBytes:` — it will print
  to stderr and return `nil` if the version/variant bits are set.
- `MulleUTF8StringToUUIDBytes` zeroes its output on failure; check the return
  value (0/-1) instead of peeking at the bytes.
- These are not cryptographic-quality random values.
- `[uuid bytes]` (inherited from `NSData`) is a *borrowed* pointer into the
  internal buffer — use `getUUIDBytes:` if you need your own copy.

### Idiomatic Usage

```objc
#import <MulleObjCUUIDFoundation/MulleObjCUUIDFoundation.h>
```

## 6. Integration Examples

### Example 1: Generate a Random UUID4

```objc
#import <MulleObjCUUIDFoundation/MulleObjCUUIDFoundation.h>


int   main( int argc, char *argv[])
{
   NSUUID    *uuid;
   NSString  *s;

   uuid = [NSUUID UUID];
   s    = [uuid UUIDString];
   mulle_printf( "%@\n", s);
   return( 0);
}
```

### Example 2: Wrap Foreign Bytes (with Version-Bit Clearing)

```objc
#import <MulleObjCUUIDFoundation/MulleObjCUUIDFoundation.h>


int   main( int argc, char *argv[])
{
   static unsigned char   bytes[ MulleUUIDBytesLength];
   NSUUID                 *uuid;

   memset( bytes, 0, sizeof( bytes));

   // foreign byte values must have version/variant bits cleared first
   MulleUUIDBytesZeroVersioningBits( bytes);
   uuid = [[[NSUUID alloc] initWithUUIDBytes:bytes] autorelease];

   // getUUIDBytes: copies out; does not expose the internal buffer
   [uuid getUUIDBytes:bytes];
   mulle_printf( "%s\n", [uuid UTF8String]);
   return( 0);
}
```

### Example 3: Strict String Parsing with Validation

```objc
#import <MulleObjCUUIDFoundation/MulleObjCUUIDFoundation.h>


int   main( int argc, char *argv[])
{
   NSUUID   *uuid;
   char     *s;

   s = "1f2e3d4c-5b6a-4988-97a6-b5c4d3e2f17f";
   mulle_printf( "%s (version: %u variant: %u)\n", s,
                 MulleUTF8StringGetUUIDVersion( s),
                 MulleUTF8StringGetUUIDVariant( s));

   uuid = [[[NSUUID alloc] initWithUUIDString:@( s)] autorelease];
   if( uuid)
      mulle_printf( "accepted as %@\n", uuid);
   else
      mulle_printf( "not accepted\n");
   return( 0);
}
```

### Example 4: Object-Less C API

```c
#import <MulleObjCUUIDFoundation/MulleObjCUUIDFoundation.h>


int   main( int argc, char *argv[])
{
   unsigned char   bytes[ MulleUUIDBytesLength];
   char            output[ MulleUUIDStringLength];

   MulleGenerateUUIDBytes( bytes);
   MulleUUIDBytesToUTF8String( bytes, output);
   mulle_printf( "%s\n", output);
   return( 0);
}
```

## 7. Dependencies

Direct `mulle-sde` dependencies (from `.mulle/etc/sourcetree/config`):

- `MulleObjCValueFoundation` — provides the `NSData` base class,
  `MulleObjCValueProtocols`, and `NSString` used by the API.
- `mulle-objc-list` — lists mulle-objc runtime information contained in
  executables (loader integration).
- `uuid4` — bundled C sources (rxi's uuid4) providing OS seeding and the
  `xorshift128plus` PRNG; included source-only (no build, no header export).