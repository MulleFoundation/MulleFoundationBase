# MulleObjCMathFoundation Library Documentation for AI
<!-- Keywords: math, numeric-functions -->

## 1. Introduction & Purpose

MulleObjCMathFoundation extends MulleObjCValueFoundation's NSNumber class with mathematical functions requiring the math library (libm). Provides NSNumber category methods for trigonometric, logarithmic, exponential, and other mathematical operations. Enables mathematical computations on NSNumber objects directly, maintaining Objective-C object semantics throughout scientific and engineering calculations.

## 2. Key Concepts & Design Philosophy

- **Category Extension**: Extends NSNumber without subclassing
- **Math Library Integration**: Wraps standard C math functions (sin, cos, log, sqrt, etc.)
- **Unified API**: All math operations return NSNumber for consistency
- **Type Unification**: Automatically determines if result should be long or double
- **Precision Preservation**: Uses long double internally where possible for accuracy
- **Exception Handling**: Integrates with Objective-C exception handling for math errors

## 3. Core API & Data Structures

### NSNumber (Math) Category

#### Basic Trigonometric Functions

- `- sin` → `NSNumber *`: Sine function (radians)
- `- cos` → `NSNumber *`: Cosine function (radians)
- `- tan` → `NSNumber *`: Tangent function (radians)
- `- asin` → `NSNumber *`: Arcsine (inverse sine)
- `- acos` → `NSNumber *`: Arccosine (inverse cosine)
- `- atan` → `NSNumber *`: Arctangent (inverse tangent)
- `- atan2:(NSNumber *)x` → `NSNumber *`: Two-argument arctangent

#### Hyperbolic Functions

- `- sinh` → `NSNumber *`: Hyperbolic sine
- `- cosh` → `NSNumber *`: Hyperbolic cosine
- `- tanh` → `NSNumber *`: Hyperbolic tangent
- `- asinh` → `NSNumber *`: Inverse hyperbolic sine
- `- acosh` → `NSNumber *`: Inverse hyperbolic cosine
- `- atanh` → `NSNumber *`: Inverse hyperbolic tangent

#### Exponential & Logarithmic Functions

- `- exp` → `NSNumber *`: e raised to power
- `- log` → `NSNumber *`: Natural logarithm (base e)
- `- log10` → `NSNumber *`: Logarithm base 10
- `- log2` → `NSNumber *`: Logarithm base 2
- `- exp2` → `NSNumber *`: 2 raised to power
- `- exp10` → `NSNumber *`: 10 raised to power
- `- expm1` → `NSNumber *`: exp(x) - 1 (accurate for small x)
- `- log1p` → `NSNumber *`: log(1 + x) (accurate for small x)

#### Power & Root Functions

- `- sqrt` → `NSNumber *`: Square root
- `- cbrt` → `NSNumber *`: Cube root
- `- pow:(NSNumber *)exponent` → `NSNumber *`: x raised to power
- `- hypot:(NSNumber *)y` → `NSNumber *`: Euclidean distance sqrt(x^2 + y^2)

#### Rounding & Truncation

- `- ceil` → `NSNumber *`: Round up to nearest integer
- `- floor` → `NSNumber *`: Round down to nearest integer
- `- trunc` → `NSNumber *`: Truncate to integer
- `- round` → `NSNumber *`: Round to nearest integer
- `- rint` → `NSNumber *`: Round to nearest integer (locale-aware)
- `- nearbyint` → `NSNumber *`: Round to nearest integer

#### Absolute Value & Sign

- `- fabs` → `NSNumber *`: Absolute value (floating-point)
- `- copysign:(NSNumber *)y` → `NSNumber *`: Copy sign from y

#### Floating-Point Decomposition

- `- modf:(NSNumber **)fracPart` → `NSNumber *`: Split into integer and fractional parts
- `- frexp:(int *)exponent` → `NSNumber *`: Extract mantissa and exponent
- `- ldexp:(int)exponent` → `NSNumber *`: Build from mantissa and exponent
- `- significand` → `NSNumber *`: Get significand (mantissa)
- `- exponent` → `NSNumber *`: Get exponent
- `- fmod:(NSNumber *)divisor` → `NSNumber *`: Floating-point remainder

#### Special Functions

- `- erf` → `NSNumber *`: Error function
- `- erfc` → `NSNumber *`: Complementary error function
- `- tgamma` → `NSNumber *`: Gamma function
- `- lgamma` → `NSNumber *`: Natural log of absolute gamma function

#### Comparison & Classification

- `- isnan` → `BOOL`: Check if NaN (Not a Number)
- `- isinf` → `BOOL`: Check if infinity
- `- isfinite` → `BOOL`: Check if finite value
- `- isnormal` → `BOOL`: Check if normal (not zero, subnormal, infinity, NaN)

#### Initialization

- `- initWithFloat:(float)value` → `instancetype`: Create from float with math handling
- `- initWithDouble:(double)value` → `instancetype`: Create from double with math handling
- `- initWithLongDouble:(long double)value` → `instancetype`: Create from long double

## 4. Performance Characteristics

- **Math Operations**: O(1) computation time; performance depends on underlying C math library
- **Type Conversion**: Automatic type unification adds minimal overhead
- **Memory**: Result NSNumber allocation only; minimal temporary memory
- **Precision**: Uses long double internally where available for intermediate calculations
- **Optimization**: Results cached/unified (long vs double) for memory efficiency
- **Thread-Safety**: Math operations thread-safe; NSNumber immutable

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Use for Object-Oriented Code**: Keep NSNumber objects rather than extracting primitives
- **Chain Operations**: Object chaining (e.g., `[[num sqrt] log] exp`) maintains clarity
- **Error Checking**: Check for NaN/infinity results from domain error operations
- **Type Consistency**: NSNumber results maintain type compatibility with rest of foundation
- **Accuracy**: Use long double initialization for highest precision inputs
- **Performance**: Cache frequently-used math results rather than recalculating

### Common Pitfalls

- **Domain Errors**: `sqrt(-1)`, `log(0)` produce NaN/infinity; check results
- **Precision Loss**: Converting large numbers loses precision; use long double
- **Rounding Mode**: Rounding behavior depends on C library; may differ between platforms
- **Infinity/NaN Propagation**: Operations on infinity/NaN propagate through calculations
- **Sign Handling**: Special functions like gamma may have discontinuities; validate domain
- **Denormalized Numbers**: Very small numbers become zero; check with `isnormal`

### Idiomatic Usage

```objc
// Pattern 1: Math operations on NSNumber objects
NSNumber *x = [NSNumber numberWithDouble:2.0];
NSNumber *result = [[x sqrt] pow:[NSNumber numberWithInt:3]];

// Pattern 2: Check for special values
NSNumber *result = [x log];  // log of negative may be NaN
if ([result isnan]) {
    NSLog(@"Domain error");
}

// Pattern 3: Type preservation through operations
NSNumber *int_result = [[NSNumber numberWithInt:4] sqrt];  // Returns 2.0 as NSNumber

// Pattern 4: Chained math
NSNumber *answer = [[[NSNumber numberWithDouble:100.0] log10] exp] sin];
```

## 6. Integration Examples

### Example 1: Basic Math Operations

```objc
#import <MulleObjCMathFoundation/MulleObjCMathFoundation.h>

int main() {
    NSNumber *num = [NSNumber numberWithDouble:2.0];
    
    NSNumber *sqrt_result = [num sqrt];
    NSNumber *exp_result = [num exp];
    NSNumber *sin_result = [num sin];
    
    NSLog(@"sqrt(2): %@", sqrt_result);
    NSLog(@"exp(2): %@", exp_result);
    NSLog(@"sin(2): %@", sin_result);
    
    return 0;
}
```

### Example 2: Error Function

```objc
#import <MulleObjCMathFoundation/MulleObjCMathFoundation.h>

int main() {
    NSNumber *x = [NSNumber numberWithDouble:1.5];
    NSNumber *erf_result = [x erf];
    NSNumber *erfc_result = [x erfc];
    
    NSLog(@"erf(1.5): %@", erf_result);
    NSLog(@"erfc(1.5): %@", erfc_result);
    
    return 0;
}
```

### Example 3: Checking for Special Values

```objc
#import <MulleObjCMathFoundation/MulleObjCMathFoundation.h>

int main() {
    NSNumber *zero = [NSNumber numberWithDouble:0.0];
    NSNumber *result = [zero log];  // log(0) = -infinity
    
    if ([result isinf]) {
        NSLog(@"Result is infinity");
    }
    
    NSNumber *negative = [NSNumber numberWithDouble:-1.0];
    NSNumber *sqrt_neg = [negative sqrt];  // sqrt(-1) = NaN
    
    if ([sqrt_neg isnan]) {
        NSLog(@"Result is NaN (domain error)");
    }
    
    return 0;
}
```

### Example 4: Rounding Functions

```objc
#import <MulleObjCMathFoundation/MulleObjCMathFoundation.h>

int main() {
    NSNumber *value = [NSNumber numberWithDouble:3.7];
    
    NSNumber *ceil_result = [value ceil];    // 4
    NSNumber *floor_result = [value floor];  // 3
    NSNumber *round_result = [value round];  // 4
    NSNumber *trunc_result = [value trunc];  // 3
    
    NSLog(@"ceil(3.7): %@", ceil_result);
    NSLog(@"floor(3.7): %@", floor_result);
    NSLog(@"round(3.7): %@", round_result);
    NSLog(@"trunc(3.7): %@", trunc_result);
    
    return 0;
}
```

### Example 5: Trigonometric Functions

```objc
#import <MulleObjCMathFoundation/MulleObjCMathFoundation.h>
#import <math.h>

int main() {
    NSNumber *pi = [NSNumber numberWithDouble:M_PI];
    NSNumber *pi_2 = [NSNumber numberWithDouble:M_PI / 2.0];
    
    NSNumber *sin_result = [pi sin];      // sin(π) ≈ 0
    NSNumber *cos_result = [pi cos];      // cos(π) = -1
    NSNumber *sin_90 = [pi_2 sin];        // sin(π/2) = 1
    
    NSLog(@"sin(π): %@", sin_result);
    NSLog(@"cos(π): %@", cos_result);
    NSLog(@"sin(π/2): %@", sin_90);
    
    return 0;
}
```

### Example 6: Floating-Point Decomposition

```objc
#import <MulleObjCMathFoundation/MulleObjCMathFoundation.h>

int main() {
    NSNumber *value = [NSNumber numberWithDouble:3.5];
    NSNumber *frac_part = nil;
    
    // Split into integer and fractional parts
    NSNumber *int_part = [value modf:&frac_part];
    
    NSLog(@"Value: %@", value);
    NSLog(@"Integer part: %@", int_part);
    NSLog(@"Fractional part: %@", frac_part);
    
    // Get exponent and significand
    int exp;
    NSNumber *mant = [value frexp:&exp];
    NSLog(@"Mantissa: %@, Exponent: %d", mant, exp);
    
    return 0;
}
```

## 7. Dependencies

- MulleObjCValueFoundation (NSNumber)
- libm (math C library) - linked with -lm
- MulleFoundationBase
