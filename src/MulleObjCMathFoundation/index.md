# MulleObjCMathFoundation Library Documentation for AI
<!-- Keywords: math, numbers, float, double, precision, libm -->

## 1. Introduction & Purpose

`MulleObjCMathFoundation` is a small Objective-C extension library for `MulleObjCValueFoundation`. It refines the `NSNumber` class via a category named `NSNumber( Math)` to improve how floating-point values (`float`, `double`, `long double`) are turned into `NSNumber` instances.

The library exists because this refinement requires the C math library (`libm`, linked with `-lm`), so it is factored out of `MulleObjCValueFoundation` as an optional add-on. It does NOT provide trig/log/exp functions — those "methods" do not exist here. Its single job is **number unification**: deciding whether a floating-point input is actually an integral value (and thus should become an integer `NSNumber`) or a true fractional value (and thus should become a `double` or `long double` `NSNumber`).

It is a component of the `MulleFoundation` library family.

## 2. Key Concepts & Design Philosophy

- **Number Unification:** The core idea is that a float like `1.0` should become an integer `NSNumber`, while `1.5` should become a double `NSNumber`. The category checks if a `float`/`double`/`long double` value is integral and fits into a signed 64-bit integer.
- **Precision Preservation:** Fractional `long double` values are never silently degraded to `double`. The correct concrete number subclass is chosen from the universe foundation space (`numbersubclasses[ _NSNumberClassClusterDoubleType]` / `_NSNumberClassClusterLongDoubleType]`).
- **Category Extension, not Subclassing:** Uses a `@implementation NSNumber( Math)` category to override the `initWithFloat:`, `initWithDouble:` and `initWithLongDouble:` methods.
- **libm Dependency:** Uses `feclearexcept`, `fetestexcept`, `llrint`, `llrintl`, `isfinite` and `round` from `libm` to robustly detect integral values, including on Windows.
- **Delegation:** On detection of an integral value it delegates to `[self initWithLongLong:]`; otherwise it allocates the appropriate concrete number subclass.

## 3. Core API & Data Structures

### 3.1. `src/MulleObjCMathFoundation.h`

Main public header. Defines version information.

- `#define MULLE_OBJC_MATH_FOUNDATION_VERSION ((0UL << 20) | (21 << 8) | 2)` — encodes major/minor/patch (currently 0.21.2).
- `static inline unsigned int MulleObjCMathFoundation_get_version_major( void)` — returns the major version.
- `static inline unsigned int MulleObjCMathFoundation_get_version_minor( void)` — returns the minor version.
- `static inline unsigned int MulleObjCMathFoundation_get_version_patch( void)` — returns the patch version.
- `MULLE_OBJC_MATH_FOUNDATION_GLOBAL uint32_t MulleObjCMathFoundation_get_version( void);` — returns the full encoded version, installed by `src/MulleObjCMathFoundation.m`.

The header imports `MulleObjCValueFoundation/MulleObjCValueFoundation.h` (via `generic/import.h`) and the generated export/versioncheck headers.

### 3.2. `src/MulleObjCDeps+MulleObjCMathFoundation.h`

- `@interface MulleObjCDeps( MulleObjCMathFoundation)` — declares the category method `+ (struct _mulle_objc_dependency *) dependencies;` which returns the list of runtime dependencies needed for object loading (generated into `objc-deps.inc` during the build).

### 3.3. `src/NSNumber+Math.m` — the `NSNumber( Math)` category

Implements `@implementation NSNumber( Math)` with overridden initializers.

#### `- (instancetype) initWithFloat:(float) value`
- **Purpose:** Creates an `NSNumber` from a `float`.
- **Behavior:** If the value is an integral number that fits into a signed 64-bit integer, delegates to `initWithLongLong:` (yielding an integer number). Otherwise creates the double number subclass. Non-finite values (`inf`, `nan`) always become double numbers.

#### `- (instancetype) initWithDouble:(double) value`
- **Purpose:** Creates an `NSNumber` from a `double`.
- **Behavior:** Same unification logic as `initWithFloat:`. `1.0` → integer number; `18.48` → `_MulleObjCDoubleNumber`; `INFINITY`/`NAN` → `_MulleObjCDoubleNumber`.

#### `- (instancetype) initWithLongDouble:(long double) value`
- **Purpose:** Creates an `NSNumber` from a `long double`.
- **Availability:** Only compiled when `_C_LNG_DBL` is defined (the `mulle-c11` long-double feature). Aborts on `__MULLE_COSMOPOLITAN__` (unsupported).
- **Behavior:** Integral values delegate to `initWithLongLong:`. Fractional values become `_MulleObjCLongDoubleNumber` — never degraded to double, so precision is preserved.

Helper logic (static, not public): `double_is_long_long( double)` and (under `_C_LNG_DBL`) `long_double_is_long_long( long double)` use `feclearexcept(FE_INVALID)`, `llrint`/`llrintl`, `fetestexcept` and an equality round-trip check. On Windows/Cosmopolitan a `isfinite` + bounds + `round` comparison is used instead.

#### Resulting concrete number classes (from tests)
- Integral small values → `_MulleObjCTaggedPointerIntegerNumber`
- Large integral values → `_MulleObjCInt64Number`
- Fractional `double`/`float` → `_MulleObjCDoubleNumber`
- Fractional `long double` → `_MulleObjCLongDoubleNumber`

## 4. Performance Characteristics

- **O(1):** Each initializer does a constant number of libm calls (an `llrint`/`llrintl`, a round-trip conversion, and an exception check) before delegating or allocating.
- **Allocation:** A single `NSNumber` is produced; no temporary or intermediate allocations are made.
- **Precision cost:** `long double` detection does not degrade precision, but `long double` operations may be slower on platforms without hardware support.
- **Thread-safety:** The libm functions used are thread-safe; the universe foundation space read is done per call. Resulting `NSNumber` instances are immutable in practice.

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Use the factory methods** `[NSNumber numberWithFloat:]`, `[NSNumber numberWithDouble:]`, `[NSNumber numberWithLongDouble:]` from `MulleObjCValueFoundation` — they internally invoke these refined initializers, so you get unification for free.
- **Inspect the concrete class** (e.g. `NSStringFromClass( [nr class])`) when exact number type matters.
- **Rely on unification:** pass plain C values; the category decides integer vs. double vs. long double automatically.
- **Use `long double` for highest precision inputs** (only when `_C_LNG_DBL` is defined).

### Common Pitfalls

- **Do not expect math functions here:** there is no `sin`, `cos`, `exp`, `pow`, `erf` etc. in this library. Those must be computed with C `math.h` functions on extracted values.
- **Non-integral values never become integers:** `18.48` stays a `double` — do not assume truncation happens.
- **`initWithLongDouble:` may be unavailable:** it is compiled only under `_C_LNG_DBL` and aborts on `__MULLE_COSMOPOLITAN__`. Guard usage with `#ifdef _C_LNG_DBL`.
- **`inf`/`nan` are not errors here:** they deliberately produce double/long-double number instances rather than failing.
- **Floating-point round-trip:** values near the `long long` limits are handled via bounds checks on Windows/Cosmopolitan; extreme values become floating numbers.

### Idiomatic Usage

```objc
NSNumber   *n;

// 1.0 unifies into an integer number, 18.48 stays a double
n = [NSNumber numberWithDouble:1.0];
n = [NSNumber numberWithDouble:18.48];
```

## 6. Integration Examples

### Example 1: Creating Numbers and Observing the Unified Class

```objc
#import <MulleObjCMathFoundation/MulleObjCMathFoundation.h>

#include <math.h>


static void   test_value( double v)
{
   NSNumber   *nr;
   NSString   *className;

   nr        = [NSNumber numberWithDouble:v];
   className = NSStringFromClass( [nr class]);

   mulle_printf( "%s : %s\n", [[nr stringValue] UTF8String], [className UTF8String]);
}


int   main( int argc, char *argv[])
{
   test_value( 0.0);          // _MulleObjCTaggedPointerIntegerNumber
   test_value( 1848);         // _MulleObjCTaggedPointerIntegerNumber
   test_value( 18.48);        // _MulleObjCDoubleNumber
   test_value( INFINITY);     // _MulleObjCDoubleNumber
   test_value( NAN);          // _MulleObjCDoubleNumber

   return( 0);
}
```

### Example 2: Long Double Precision Preservation

```objc
#import <MulleObjCMathFoundation/MulleObjCMathFoundation.h>

#include <float.h>
#include <math.h>


#ifdef _C_LNG_DBL
static void   test_value( char *s, long double v)
{
   NSNumber   *nr;
   NSString   *className;

   nr        = [NSNumber numberWithLongDouble:v];
   className = NSStringFromClass( [nr class]);

   mulle_printf( "%s: %s (%s)\n", s, [[nr stringValue] UTF8String], [className UTF8String]);
}
#endif


int   main( int argc, char *argv[])
{
#ifdef _C_LNG_DBL
   test_value( "0.0L", 0.0L);     // integer number
   test_value( "18.48L", 18.48L); // _MulleObjCLongDoubleNumber (kept, not degraded)
   test_value( "LDBL_MAX", LDBL_MAX);
#else
   mulle_printf( "_C_LNG_DBL not defined, no test for you!\n");
#endif
   return( 0);
}
```

## 7. Dependencies

- `MulleObjCValueFoundation` — the `NSNumber` value class this library refines (host library).
- `mulle-objc-list` — lists mulle-objc runtime information (headers only, no linking).
- `math` (system `libm`, linked via `-lm` alias `m`) — provides `llrint`, `llrintl`, `isfinite`, `feclearexcept`, `fetestexcept`, `round`.

## 8. Shortcut

The previous `index.md` was committed along with the current source at `3909509` and has not changed since. However, the previously documented math methods (`sin`, `cos`, `exp`, `erf`, ...) could not be found in any header and were removed; this file now documents only the actual public API.