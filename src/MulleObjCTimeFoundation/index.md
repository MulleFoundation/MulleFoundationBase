# MulleObjCTimeFoundation Library Documentation for AI
<!-- Keywords: time, date, timer, interval, scheduling, objective-c -->

## 1. Introduction & Purpose

MulleObjCTimeFoundation provides the time-related classes of the mulle-objc
framework: `NSDate` (an immutable timestamp value), `NSTimeInterval` (a
floating-point time duration/absolute-time type), and `NSTimer` (scheduled
event firing). It also extends threading and synchronization classes of
`MulleObjC` (`NSLock`, `NSCondition`, `NSConditionLock`, `NSThread`) with
time- and deadline-based operations, and gives `NSDate` a `NSCoding`
(coder) capability.

The library interfaces with the C library
[mulle-time](https://github.com/mulle-core/mulle-time) for the underlying
time primitives (`mulle_calendartime_t`, `mulle_relativetime_t`,
`mulle_absolutetime_t`). It is a component of the
`MulleFoundation` collection and builds on top of `MulleObjC`
(the Objective-C root classes).

## 2. Key Concepts & Design Philosophy

- **Reference date epoch:** `NSDate` stores timestamps as `NSTimeInterval`
  (double seconds) relative to a *reference date*, which is **1.1.2001 GMT**,
  not 1.1.1970. `NSTimeIntervalSince1970` (978307200.0) is the offset between
  the two epochs. Helper functions convert between the two bases.
- **Absolute vs. monotonic time:** The library distinguishes calendar
  (absolute, UTC) time intervals — used by `NSDate` and by calendar `NSTimer`s —
  from *relative* monotonic time (`mulle_relativetime_t`) — used by relative
  timers and by guaranteed timeouts. Relative time is not affected by wall-clock
  or sleep changes.
- **Class cluster:** `NSDate` is a class cluster (`MulleObjCClassCluster`).
  Instances are always actually the concrete subclass
  `_MulleObjCConcreteDate`. The cluster methods (`init`,
  `initWithTimeIntervalSinceReferenceDate:`) create a concrete instance and
  return it.
- **Immutable value semantics:** `NSDate` and `NSTimer` are immutable
  (`MulleObjCImmutable` / `MulleObjCImmutableProtocols`). Timestamps are safe
  to cache. Equality, ordering and `hash` are based on the stored interval.
- **Category extension pattern:** time-aware capabilities are distributed over
  mulle-objc classes via mulle-objc *categories*, e.g. `NSLock( NSDate)`,
  `NSCondition( NSDate)`, `NSConditionLock( NSDate)`, `NSThread( NSDate)`,
  `NSTimer( NSDate)`, `NSDate( NSCoder)`.
- **Dual-use timer:** `NSTimer` works both with the standard `NSRunLoop` and
  with `UIApplication` (which does not use a run loop yet). Relative timers
  (`mulleTimerWithRelativeTimeInterval:*`) are intended for `UIApplication`;
  calendar "absolute" timers (`NSTimer( NSDate)`) are `NSRunLoop` timers.
- **Deadlock-aware timeout variants:** For `NSConditionLock`, methods named
  `lockWhenCondition:*beforeDate:` / `*beforeTimeInterval:` / `*timeout:`
  first try-lock in a yield loop and *cannot deadlock*. Methods named
  `waitUntilDate:` / `waitUntilTimeInterval:` follow the POSIX idiom
  (`pthread_mutex_lock` + timed condition wait) and *can* deadlock.

## 3. Core API & Data Structures

All signatures below are copied verbatim from the shipped public headers.

### 3.1. `src/NSTimeInterval.h`

#### `NSTimeInterval` typedef

- **Purpose:** The fundamental time type; a `double` count of seconds.

```c
typedef mulle_calendartime_t    NSTimeInterval;
```

#### Constants

- `_NSDistantFuture  63113904000.0` — large future offset for the reference
  epoch (used by `[NSDate distantFuture]`).
- `_NSDistantPast   -63114076800.0` — large past offset
  (used by `[NSDate distantPast]`).
- `NSTimeIntervalSince1970  978307200.0` — the interval to **add** to
  1.1.1970 GMT to get 1.1.2001 GMT (the reference date).

#### Static helper functions

- `_NSTimeIntervalSince1970AsReferenceDate( NSTimeInterval interval)` —
  converts a since-1970 interval into a since-reference-date interval.
- `_NSTimeIntervalSinceReferenceDateAsSince1970( NSTimeInterval interval)` —
  converts a since-reference-date interval into a since-1970 interval.
- `_NSTimeIntervalNow( void)` — current time, as seconds since the reference
  date (wraps `mulle_calendartime_now()`).

### 3.2. `src/NSDateFactory.h`

#### `NSDateFactory` protocol

- **Purpose:** A marker `@protocol` that `NSDate` conforms to
  (`@interface NSDate : NSObject < MulleObjCClassCluster, NSDateFactory, MulleObjCImmutable>`).
  It declares no methods itself, but flags that `NSDate` provides factory
  creation methods.

### 3.3. `src/NSDate.h`

#### `NSDate` class

- **Purpose:** An immutable timestamp value. `+ date`, the class
  `timeIntervalSinceReferenceDate`, and all factory methods are the usual way
  to obtain dates. Internally every instance is a `_MulleObjCConcreteDate`
  holding one `NSTimeInterval _interval`.
- **Lifecycle:** Instances are obtained from the factory (`+`) methods or via
  `init`/`initWith*:` within `[[[NSDate alloc] ...] autorelease]`. Follow
  standard mulle-objc retain/release semantics; values are immutable so no
  mutators exist.

##### Factory (class) methods

```c
+ (instancetype) dateWithTimeIntervalSince1970:(NSTimeInterval) seconds;
+ (instancetype) dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval) seconds;
+ (instancetype) distantFuture;
+ (instancetype) distantPast;
```

- `dateWithTimeIntervalSince1970:` — date from seconds since 1.1.1970 GMT
  (internally subtracts `NSTimeIntervalSince1970`).
- `dateWithTimeIntervalSinceReferenceDate:` — date from seconds since the
  1.1.2001 reference epoch.
- `distantFuture` / `distantPast` — dates far outside any realistic range,
  useful as infinite timeouts.

##### Initialization methods

```c
- (instancetype) initWithTimeInterval:(NSTimeInterval) seconds
                            sinceDate:(NSDate *) refDate;
- (instancetype) initWithTimeIntervalSince1970:(NSTimeInterval) seconds;
```

- `initWithTimeInterval:sinceDate:` — date = `refDate + seconds`.
- `initWithTimeIntervalSince1970:` — date from seconds since 1.1.1970 GMT.

##### Comparison & arithmetic

```c
- (NSComparisonResult) compare:(id) other;
- (instancetype) dateByAddingTimeInterval:(NSTimeInterval) seconds;
- (NSDate *) earlierDate:(NSDate *) other;
- (NSDate *) laterDate:(NSDate *) other;
```

- `compare:` returns `NSOrderedAscending`/`NSOrderedSame`/`NSOrderedDescending`.
  If `other` is nil it returns `NSOrderedSame` (Apple-compatible, stabilizes
  sorting).
- `dateByAddingTimeInterval:` — new date offset by `seconds`; immutable, does
  not modify the receiver.
- `earlierDate:` / `laterDate:` — returns the earlier/later of the two dates;
  returns `self` if `other` is nil (Apple-compatible).

##### Interval accessors

```c
- (NSTimeInterval) timeIntervalSince1970;
- (NSTimeInterval) timeIntervalSinceDate:(NSDate *) other;
```

- `timeIntervalSince1970` — seconds since 1.1.1970 GMT.
- `timeIntervalSinceDate:` — `[self timeIntervalSinceReferenceDate] -
  [other timeIntervalSinceReferenceDate]` (positive when self is later).

##### `NSDate( SubclassesFuture)` extension

```c
- (instancetype) initWithTimeIntervalSinceReferenceDate:(NSTimeInterval) seconds;
- (NSTimeInterval) timeIntervalSinceReferenceDate;
```

- `initWithTimeIntervalSinceReferenceDate:` — cluster entry point; releases
  the intermediate cluster object and returns a `_MulleObjCConcreteDate`
  initialized to `seconds` since the 1.1.2001 reference epoch.
- `timeIntervalSinceReferenceDate` — seconds since the 1.1.2001 reference epoch.

##### `NSDate( Future)` extension (obsolete)

```c
+ (NSDate *) date;
+ (NSTimeInterval) timeIntervalSinceReferenceDate;
```

- `date` — a date for "now"; simple convenience, prefer `+object`.
- Class-level `timeIntervalSinceReferenceDate` — current time as interval
  since the reference epoch (used by tests to build relative deadlines).

##### Implementation notes (from `NSDate.m`)

- `-init` initializes to `_NSTimeIntervalNow()`.
- `-hash` is `mulle_double_hash( [self timeIntervalSinceReferenceDate])`.
- `__isNSDate` (private runtime method): `NO` on `NSObject`, `YES` on
  `NSDate`. The tests rely on it.
- Equality methods (`-isEqual:`, `-isEqualToDate:`) are implemented and
  compare the stored intervals; equality/hash are consistent for use in
  `NSSet`/`NSCast` collections, though they are not declared in the public
  header (tests forward-declare `isEqualToDate:`).

### 3.4. `src/NSDate+NSCoder.h`

#### `NSDate( NSCoder)` category

- **Purpose:** `@interface NSDate( NSCoder) <NSCoding>` — makes `NSDate`
  encodable/decodable via the mulle-objc `NSCoder` (serialization) framework.

### 3.5. `src/_MulleObjCDateSubclasses.h`

#### `_MulleObjCConcreteDate` (concrete NSDate subclass)

- **Purpose:** The actual, instantiable implementation of `NSDate`. Holds a
  single `NSTimeInterval _interval` field and conforms to
  `MulleObjCValueProtocols`.

```c
@interface _MulleObjCConcreteDate : NSDate < MulleObjCValueProtocols>
{
   NSTimeInterval   _interval;
}

+ (instancetype) newWithTimeIntervalSinceReferenceDate:(NSTimeInterval) interval;
```

- `newWithTimeIntervalSinceReferenceDate:` — allocates a concrete date value.
- `_MulleObjCConcreteDate( NSCoder) <NSCoding>` — the concrete class also
  encodes.
- **Notes from the header:** `NSDate` is a container for UTC *calendar* time,
  not a physical time; module-level arithmetic in months/years is error-prone
  due to leap years, and pre-15.10.1582 values deviate from physical time
  under the proleptic Gregorian calendar.

### 3.6. `src/NSTimer.h`

#### `NSTimer` class

- **Purpose:** A scheduled-event object. Drivers: a run loop (`NSRunLoop`) for
  calendar timers, or `UIApplication` for relative timers. "Dual use" — it can
  also be fired manually. An `NSTimer` is immutable except for `-invalidate`
  (which clears its held references), and the target/userInfo contents can
  change behind its back.
- **Key private fields (from the interface):**

```c
union
{
   mulle_relativetime_t   relative;
   NSTimeInterval         calendar;
} _interval;

mulle_relativetime_t   _repeatInterval;
NSTimerCallback_t      *_callback;
union
{
   id               target;
   NSInvocation     *invocation;
} _o;
SEL                 _selector;  // if 0: use _target as _invocation
id                  _userInfo;
char                _passUserInfo;
char                _isRelative;
```

- **Property:** `@property( readonly, retain) id userInfo;` — read via
  `[timer userInfo]`.

#### Callback type and constants

```c
typedef void   NSTimerCallback_t( NSTimer *, id userInfo);
```

- `_NSTIMER_MIN_TIMEINTERVAL 0.0001` — any non-positive delay/repeat interval
  is clamped up to this minimum.

#### Factory methods (relative timers)

Relative timers count down `seconds` of monotonic time ("2s from now",
unaffected by computer sleep).

```c
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
```

- Three flavours: selector-on-target, C `NSTimerCallback_t`, or `NSInvocation`.
- `fireUsesUserInfoAsArgument:YES` passes `userInfo` to the selector on fire,
  otherwise the timer itself is passed as the argument.
- A nil `target`/`selector`/`callback`/`invocation` makes the factory return
  `nil` — always check the result.

#### Initialization methods (relative timers)

```c
- (instancetype) mulleInitWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                    repeatInterval:(mulle_relativetime_t) repeatSeconds
                                       invocation:(NSInvocation *) invocation;

- (instancetype) mulleInitWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                    repeatInterval:(mulle_relativetime_t) repeatSeconds
                                            target:(id) target
                                          selector:(SEL) sel
                                          userInfo:(id) userInfo
                        fireUsesUserInfoAsArgument:(BOOL) flag;

- (instancetype) mulleInitWithRelativeTimeInterval:(mulle_relativetime_t) seconds
                                    repeatInterval:(mulle_relativetime_t) repeatSeconds
                                          callback:(NSTimerCallback_t) callback
                                          userInfo:(id) userInfo;
```

#### Core operations

```c
- (BOOL) isValid;
- (void) fire;
```

- `isValid` — `YES` while the timer still holds a target or callback (i.e. not
  invalidated). Non-repeating timers invalidate themselves after firing.
- `fire` — dispatch immediately: perform `selector` on `_target` (argument is
  `_userInfo` if `_passUserInfo`, else the timer), invoke the callback, or
  `invoke` the `NSInvocation`. Afterwards, if `_repeatInterval == 0.0` the
  timer invalidates itself.
- `- (void) invalidate` — implemented by `NSTimer.m` (and clobbered by the
  `NSTimer( NSRunLoop)` category): autoreleases and clears target/userInfo,
  zeroes selector/callback. `-finalize` calls it.

#### Inspection functions

```c
- (BOOL) mulleIsRelativeTimer;
- (mulle_relativetime_t) mulleRelativeTimeInterval;
- (mulle_relativetime_t) mulleRepeatTimeInterval;
```

- `mulleIsRelativeTimer` — `YES` for relative timers, `NO` for calendar timers.
- `mulleRelativeTimeInterval` — the relative interval; `-INFINITY` for
  calendar timers.
- `mulleRepeatTimeInterval` — the repeat interval; `0.0` for non-repeating
  timers (negative repeats are clamped to `0.0`).

##### `NSTimer( Private)` extension

```c
- (BOOL) mulleFiresWithUserInfoAsArgument;
- (id) mulleTarget;                 // also target of invocation
- (SEL) mulleSelector;              // also selector of invocation
- (NSTimerCallback_t *) mulleTimerCallback;
```

Mainly useful for testing and for the `NSRunLoop`.

### 3.7. `src/NSTimer+NSDate.h` — calendar timers

- **Purpose:** `@interface NSTimer( NSDate)` creates calendar-based "absolute"
  timers with a fixed fire date. They are `NSRunLoop` timers. **Warning in the
  header:** when using absolute time via the `*FireTimeInterval` methods you
  must add the timer immediately to a runloop or `UIApplication`, otherwise
  the timer will skew.

```c
+ (instancetype) timerWithTimeInterval:(NSTimeInterval) seconds
                            invocation:(NSInvocation *) invocation
                               repeats:(BOOL) repeats;

+ (instancetype) timerWithTimeInterval:(NSTimeInterval) seconds
                                target:(id) target
                              selector:(SEL) selector
                              userInfo:(id) userInfo
                               repeats:(BOOL) repeats;

- (instancetype) initWithFireDate:(NSDate *) date
                         interval:(NSTimeInterval) repeatSeconds
                           target:(id) target
                         selector:(SEL) selector
                         userInfo:(id) userInfo
                          repeats:(BOOL) repeats;

- (instancetype) mulleInitWithFireTimeInterval:(NSTimeInterval) timeInterval
                                repeatInterval:(mulle_relativetime_t) repeatSeconds
                                    invocation:(NSInvocation *) invocation;

- (instancetype) mulleInitWithFireTimeInterval:(NSTimeInterval) timeInterval
                                repeatInterval:(mulle_relativetime_t) repeatInterval
                                        target:(id) target
                                      selector:(SEL) sel
                                      userInfo:(id) userInfo
                    fireUsesUserInfoAsArgument:(BOOL) flag;
```

- `timerWithTimeInterval:*` — fires `seconds` from now (computed internally
  via `_NSTimeIntervalNow()`). If `repeats` is `YES`, the repeat interval
  equals `seconds`; a non-positive `seconds` is clamped to
  `_NSTIMER_MIN_TIMEINTERVAL`.
- `initWithFireDate:` — explicit absolute fire date; `repeatSeconds` becomes
  the repeat interval only when `repeats` is `YES`, otherwise it is forced to
  `0.0`. Same nil-guard behavior for `target`/`selector`/`invocation`.

#### Accessors

```c
- (NSDate *) fireDate;            // nil for relative timer
- (NSTimeInterval) mulleFireTimeInterval;
- (NSTimeInterval) timeInterval;  // this is the repeat interval!!!!
```

- `fireDate` — an `NSDate` for the next fire time; `nil` for relative timers.
- `mulleFireTimeInterval` — absolute fire time; `-INFINITY` for relative
  timers.
- `timeInterval` — the *repeat* interval (0.0 for non-repeating timers), not
  the fire time.

### 3.8. `src/NSLock+NSDate.h`

#### `NSLock( NSDate)` category

```c
- (BOOL) lockBeforeDate:(NSDate *) limit;
```

- Acquires the lock, returning `NO` (with the lock still unlocked) once
  `limit` has been reached. `(BOOL)` result: `NO` means the deadline passed.

### 3.9. `src/NSCondition+NSDate.h`

#### `NSCondition( NSDate)` category

```c
- (BOOL) waitUntilDate:(NSDate *) limit;
- (BOOL) mulleWaitUntilTimeInterval:(NSTimeInterval) timeInterval;
- (BOOL) mulleWaitWithTimeout:(mulle_relativetime_t) seconds;
```

- `waitUntilDate:` / `mulleWaitUntilTimeInterval:` — wait on the condition
  until the given (absolute calendar) deadline. Enter in the locked state and
  unlock afterwards. Returns `NO` on timeout. **Platform note from the
  header:** on some platforms (Windows/Wine) `mulleWaitUntilTimeInterval` may
  return slightly early due to clock precision; use `mulleWaitWithTimeout` for
  guaranteed timeouts.
- `mulleWaitWithTimeout:` — guarantees a wait of at least `seconds` using
  monotonic time (loops/retries internally against an absolute-time start).

### 3.10. `src/NSConditionLock+NSDate.h`

#### `NSConditionLock( NSDate)` category

```c
- (BOOL) mulleLockWhenCondition:(NSInteger) value
                  waitUntilDate:(NSDate *) date;

- (BOOL) lockWhenCondition:(NSInteger) condition
                beforeDate:(NSDate *) limit;

- (BOOL) lockBeforeDate:(NSDate *) limit;

- (BOOL) mulleLockWhenCondition:(NSInteger) condition
                        timeout:(mulle_relativetime_t) seconds;

- (BOOL) mulleLockWhenCondition:(NSInteger) condition
             beforeTimeInterval:(NSTimeInterval) timeInterval;

- (BOOL) mulleLockWhenCondition:(NSInteger) value
          waitUntilTimeInterval:(NSTimeInterval) timeInterval;

- (BOOL) mulleLockWithTimeout:(mulle_relativetime_t) seconds;

- (BOOL) mulleLockBeforeTimeInterval:(NSTimeInterval) timeInterval;
```

- `lockWhenCondition:beforeDate:` / `lockBeforeDate:`,
  `mulleLockWhenCondition:*beforeTimeInterval:` / `*timeout:` /
  `mulleLockWithTimeout:` — the non-deadlocking family: they first
  `tryLock` in a `mulle_thread_yield()` loop up to the deadline, then wait for
  the condition with the remaining time (re-checking the deadline before and
  while waiting). They return the lock in the locked state on `YES`.
- `mulleLockWhenCondition:waitUntilDate:` / `waitUntilTimeInterval:` — the
  common POSIX idiom (`pthread_mutex_lock` + timed condition wait). **These
  may deadlock**: the timeout bounds the condition wait, not the holding of
  the lock; on timeout they return `NO` with the lock released.
- The timeout family (`*timeout:`, with monotonic `mulle_relativetime_t`)
  guarantees a minimum wait; the `*TimeInterval:`/`*Date:` family uses
  absolute calendar deadlines.

### 3.11. `src/NSThread+NSDate.h`

#### `NSThread( NSDate)` category

```c
+ (void) sleepUntilDate:(NSDate *) aDate;
```

- Blocks the current thread until `aDate`; returns immediately for past dates.

### 3.12. `src/MulleObjCTimeFoundation.h`

- Version macro: `MULLE_OBJC_TIME_FOUNDATION_VERSION ((0UL << 20) | (2 << 8) | 6)`
  (version 0.2.6). It imports `_MulleObjCTimeFoundation-export.h` and
  `_MulleObjCTimeFoundation-provide.h`; `#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>`
  pulls in the whole public API.

### 3.13. `src/MulleObjCDeps+MulleObjCTimeFoundation.h`

- `@interface MulleObjCDeps( MulleObjCTimeFoundation) + (struct _mulle_objc_dependency *) dependencies;`
  — load-time dependency declaration for the mulle-objc class loader. This
  header must stay public so dependent libraries can declare their load in
  their `MulleObjcLoader` class.

## 4. Performance Characteristics

- **NSDate:** all operations are O(1) double-precision floating point
  (creation, `compare:`, `dateByAddingTimeInterval:`, interval accessors,
  `hash`). No allocation beyond one small object; immutable, so instances can
  be cached and shared freely.
- **NSTimer:** creation is O(1) with a handful of retained references. Firing
  is a single selector dispatch / callback call / invocation; non-repeating
  timers invalidate in O(1). Scheduling responsiveness is owned by the
  `NSRunLoop`/`UIApplication`, not by this library.
- **NSConditionLock timeout variants:** the `tryLock` + `mulle_thread_yield()`
  loop before the deadline is a *busy wait* — it consumes CPU under
  contention but never sleeps past the deadline and never deadlocks. Under no
  contention the lock round-trip is O(1). The `waitUntil*` variants hand the
  wait to the OS condition primitive (the most efficient path, but with the
  deadlock caveat above).
- **Guaranteed wait:** `mulleWaitWithTimeout` / `mulleLockWithTimeout` /
  `mulleLockWhenCondition:*timeout:` use the monotonic clock and retry on
  early return, trading a little latency for a guaranteed minimum duration.
  Plain `*UntilTimeInterval:` may return slightly early on Windows/Wine.
- **Thread safety:** `NSDate`/`NSTimeInterval` are immutable — thread-safe to
  read and cache. `NSTimer`, locking and condition objects are not thread-safe
  by themselves; they are the synchronization mechanism for coordinating
  threads, and accessors like `-invalidate` must not race a run loop.

## 5. AI Usage Recommendations & Patterns

### Best Practices

- Always obtain dates from the factory methods (`[NSDate date]`,
  `+ dateWithTimeIntervalSinceReferenceDate:`, `+ dateWithTimeIntervalSince1970:`,
  `+ distantFuture`, `+ distantPast`) inside an `@autoreleasepool`, or use
  `init`-style constructors with `autorelease`.
- Prefer `NSDate` over raw `NSTimeInterval` for timestamps and deadlines for
  semantic clarity; use raw intervals and the `_NSTimeInterval*` helpers only
  for arithmetic.
- For "now, plus N seconds", write
  `[NSDate dateWithTimeIntervalSinceReferenceDate:[NSDate timeIntervalSinceReferenceDate] + N]`.
- Use `-compare:` for ordering (nil-safe, Apple-compatible). Use `-isEqual:`
  / forward-declared `-isEqualToDate:` for equality of cached values.
- For infinite-ish timeouts, use `distantFuture`/`distantPast` (or `isinf`
  intervals, which `NSCondition` treats as "wait forever").
- When a `NSConditionLock` or `NSCondition` deadline must be honored reliably,
  prefer the monotonic `*WithTimeout:` / `*timeout:` variants over the
  calendar `*UntilTimeInterval:` ones.
- For timers, always check the factory result for `nil` (invalid
  target/selector/callback/invocation yields `nil`).

### Common Pitfalls

- **Epoch confusion:** `+ dateWithTimeIntervalSince1970:` and
  `- timeIntervalSince1970` are in seconds since **1.1.1970**; all the
  `*SinceReferenceDate` methods and `NSTimeInterval` values from `NSDate` are
  in seconds since **1.1.2001**. Mixing the two off by `NSTimeIntervalSince1970`
  produces dates 31 years off.
- **`timeInterval` on `NSTimer( NSDate)` is the repeat interval**, not the
  fire time (0.0 for non-repeating timers). Use `fireDate` /
  `mulleFireTimeInterval` for the fire time.
- **Deadlock:** `NSConditionLock`'s `mulleLockWhenCondition:waitUntilDate:`
  and `waitUntilTimeInterval:` can deadlock; the `beforeDate:` /
  `beforeTimeInterval:` / `timeout:` family cannot. The header says so
  explicitly.
- **Calendar timers skew:** absolute-time timers must be added to a run loop /
  `UIApplication` immediately after creation ("else you get skew").
- **Retain cycles:** `NSTimer` retains its target and userInfo; a target that
  retains its timer forms a cycle. Call `-invalidate` (or drop the timer, which
  triggers `-finalize` → `-invalidate`) to break it. `-invalidate` is
  implemented in `NSTimer.m`; tests access it via forward declaration.
- **Autorelease discipline:** factory/`+` methods return autoreleased objects;
  do not add an extra `-release` on them. Never call `-retain`/`-release`
  outside of `-init`/`-dealloc` style code.

### Idiomatic Usage

- The mulle-objc way: `NSDate` values are created, passed around and compared;
  timers are created once, owned by a run loop, and invalidated when done;
  deadlines combine `[NSDate ...]` with the category methods
  `lockBeforeDate:` / `waitUntilDate:` / `lockWhenCondition:beforeDate:`.

## 6. Integration Examples

### Example 1: Creating and Inspecting NSDate Values

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

int   main( void)
{
   @autoreleasepool
   {
      NSDate   *now;
      NSDate   *epoch1970;

      //
      // "now" via convenient class method
      //
      now = [NSDate date];

      //
      // create a date from a Unix timestamp
      //
      epoch1970 = [NSDate dateWithTimeIntervalSince1970:0.0];

      //
      // convert back and forth between the two epochs
      //
      printf( "now   since 1970:     %.0f\n", [now timeIntervalSince1970]);
      printf( "epoch since 1970:     %.0f\n", [epoch1970 timeIntervalSince1970]);
      printf( "now   since reference: %.0f\n",
              [now timeIntervalSinceReferenceDate]);
   }
   return( 0);
}
```

### Example 2: Comparing Dates and Computing Intervals

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

int   main( void)
{
   @autoreleasepool
   {
      NSDate            *d1;
      NSDate            *d2;
      NSTimeInterval    diff;
      NSComparisonResult result;

      d1 = [NSDate dateWithTimeIntervalSinceReferenceDate:100.0];
      d2 = [NSDate dateWithTimeIntervalSinceReferenceDate:250.0];

      result = [d1 compare:d2];   // NSOrderedAscending
      diff   = [d2 timeIntervalSinceDate:d1];  // 150.0

      printf( "150.0 == %.1f\n", diff);
      printf( "earlier: %s\n", [d1 earlierDate:d2] == d1 ? "d1" : "d2");

      if( result == NSOrderedAscending)
         printf( "d1 < d2\n");

      // immutable arithmetic: creates a new date, does not modify d1
      d1 = [d1 dateByAddingTimeInterval:150.0];
   }
   return( 0);
}
```

### Example 3: Calendar (Absolute) Timer with Target/Selector

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

@interface Bell : NSObject
{
   int   _ringCount;
}

- (int) ringCount;
- (void) ring:(id) ignored;

@end


@implementation Bell

- (int) ringCount   { return( _ringCount); }

- (void) ring:(id) ignored
{
   _ringCount++;
}

@end


int   main( void)
{
   @autoreleasepool
   {
      Bell     *bell;
      NSTimer  *timer;

      bell  = [[[Bell alloc] init] autorelease];

      //
      // a calendar timer: fires 2.0s from now, then keeps firing every
      // 2.0s because repeats is YES
      //
      timer = [NSTimer timerWithTimeInterval:2.0
                                      target:bell
                                    selector:@selector( ring:)
                                    userInfo:nil
                                     repeats:YES];
      if( ! timer)
      {
         fprintf( stderr, "timer creation failed\n");
         return( 1);
      }

      printf( "fireDate set:    %s\n", [timer fireDate] ? "YES" : "NO");
      printf( "repeat interval: %.1f\n", [timer timeInterval]);

      [timer fire];
      printf( "rang:            %d\n", [bell ringCount]);

      [timer invalidate];   // stop and drop retained references
   }
   return( 0);
}
```

### Example 4: Relative Timer with C Callback

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

static int   gLaps;
static id    gLastInfo;

static void   lap( NSTimer *timer, id userInfo)
{
   gLaps++;
   gLastInfo = userInfo;
}

int   main( void)
{
   @autoreleasepool
   {
      NSTimer  *timer;
      NSDate   *mark;

      mark  = [NSDate dateWithTimeIntervalSinceReferenceDate:1.0];

      // relative (monotonic) timer: 1.0s delay, repeat every 0.5s
      timer = [NSTimer mulleTimerWithRelativeTimeInterval:1.0
                                           repeatInterval:0.5
                                                 callback:lap
                                                 userInfo:mark];

      [timer fire];
      printf( "laps:       %d\n", gLaps);
      printf( "userInfo:   %s\n", gLastInfo == (id) mark ? "mark" : "other");

      [timer invalidate];
   }
   return( 0);
}
```

### Example 5: Locking a NSConditionLock with a Deadline

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

int   main( void)
{
   @autoreleasepool
   {
      NSConditionLock  *lock;
      NSDate           *deadline;

      lock     = [[[NSConditionLock alloc] initWithCondition:7] autorelease];
      deadline = [NSDate dateWithTimeIntervalSinceReferenceDate:
                     [NSDate timeIntervalSinceReferenceDate] + 0.5];

      //
      // lockWhenCondition:beforeDate: cannot deadlock; on success the
      // lock is held, on timeout it is not
      //
      if( [lock lockWhenCondition:7 beforeDate:deadline])
      {
         printf( "lock acquired with condition 7\n");
         [lock unlockWithCondition:7];
      }
      else
         printf( "deadline passed\n");
   }
   return( 0);
}
```

### Example 6: Sleeping a Thread Until a Date

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

int   main( void)
{
   @autoreleasepool
   {
      NSDate   *wakeUp;

      //
      // sleep the current thread until now + 20ms; past dates return
      // immediately
      //
      wakeUp = [NSDate dateWithTimeIntervalSinceReferenceDate:
                   [NSDate timeIntervalSinceReferenceDate] + 0.02];
      [NSThread sleepUntilDate:wakeUp];

      printf( "woke up\n");
   }
   return( 0);
}
```

## 7. Dependencies

Direct `mulle-sde` library dependencies (from `.mulle/etc/sourcetree/config`
and `clib.json`):

- `MulleObjC` — the Objective-C root classes this library extends
  (`NSObject`, `NSLock`, `NSCondition`, `NSConditionLock`, `NSThread`,
  `NSInvocation`, `NSRunLoop`; carries the `mulle-core`/`mulle-time` C
  foundations providing `mulle_calendartime_t`, `mulle_relativetime_t`,
  `mulle_absolutetime_t`).
- `mulle-objc-list` — lists mulle-objc runtime information contained in
  executables (load-time bookkeeping).

The C library `mulle-time` is used directly for calendar/relative/absolute
time primitives but is brought in transitively via `MulleObjC` (not declared
as a direct sourcetree dependency).