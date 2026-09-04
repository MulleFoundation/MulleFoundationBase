# MulleObjCTimeFoundation Library Documentation for AI
<!-- Keywords: time, date -->

## 1. Introduction & Purpose

MulleObjCTimeFoundation provides essential Objective-C time and scheduling classes for the mulle-objc framework, including NSDate (immutable timestamp representation), NSTimeInterval (floating-point time intervals), NSTimer (scheduled event firing), and synchronization primitives (NSLock, NSCondition, NSConditionLock) with time-based operations. Bridges to mulle-time for efficient underlying time management.

## 2. Key Concepts & Design Philosophy

- **Class Cluster**: NSDate uses class cluster pattern for multiple subclass implementations
- **Immutable Values**: NSDate and NSTimeInterval are immutable value types
- **Monotonic Dispatch**: NSTimer uses mulle-time's monotonic clock for reliable scheduling
- **Synchronization Primitives**: Lock/condition variants with timeout support
- **Reference Semantics**: Follows NSObject model with reference counting
- **Convenience Methods**: Category extensions add NSDate support to threading/locking classes

## 3. Core API & Data Structures

### NSDate - Date/Time Values

#### Creation & Factory Methods

- `+ dateWithTimeIntervalSince1970:(NSTimeInterval)seconds` → `instancetype`: Create date from Unix timestamp
- `+ dateWithTimeIntervalSinceReferenceDate:(NSTimeInterval)seconds` → `instancetype`: Create date from reference epoch
- `+ distantFuture` → `instancetype`: Get a date far in the future
- `+ distantPast` → `instancetype`: Get a date far in the past

#### Initialization

- `- initWithTimeInterval:(NSTimeInterval)seconds sinceDate:(NSDate *)refDate` → `instancetype`: Initialize relative to another date
- `- initWithTimeIntervalSince1970:(NSTimeInterval)seconds` → `instancetype`: Initialize from Unix timestamp
- `- initWithTimeIntervalSinceReferenceDate:(NSTimeInterval)seconds` → `instancetype`: Initialize from reference epoch

#### Comparison & Arithmetic

- `- compare:(id)other` → `NSComparisonResult`: Compare two dates (NSOrderedAscending, Same, or Descending)
- `- dateByAddingTimeInterval:(NSTimeInterval)seconds` → `instancetype`: Create new date offset by interval
- `- earlierDate:(NSDate *)other` → `NSDate *`: Return earlier of two dates
- `- laterDate:(NSDate *)other` → `NSDate *`: Return later of two dates

#### Time Interval Accessors

- `- timeIntervalSince1970` → `NSTimeInterval`: Seconds since Unix epoch (Jan 1 1970)
- `- timeIntervalSinceDate:(NSDate *)other` → `NSTimeInterval`: Seconds since another date
- `- timeIntervalSinceReferenceDate` → `NSTimeInterval`: Seconds since reference epoch

#### String Representation

- `- description` → `NSString *`: Human-readable date string

### NSTimeInterval - Time Duration Type

- **Type**: Double-precision floating-point representing seconds
- **Usage**: Represents both absolute timestamps and relative durations
- **Precision**: Nanosecond precision through double representation
- **Constants**: 
  - `NSTimeIntervalSince1970`: Reference epoch offset
  - `NSDistantFutureTimeInterval`: Maximum representable future time
  - `NSDistantPastTimeInterval`: Minimum representable past time

### NSTimer - Scheduled Events

#### Creation

- `+ scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats` → `instancetype`: Create and schedule timer
- `- initWithFireDate:(NSDate *)fireDate interval:(NSTimeInterval)interval target:(id)target selector:(SEL)selector userInfo:(id)userInfo repeats:(BOOL)repeats` → `instancetype`: Create with specific fire date

#### Control

- `- invalidate` → `void`: Stop timer and remove from run loop
- `- fire` → `void`: Force immediate firing

#### Accessors

- `- isValid` → `BOOL`: Check if timer is still scheduled
- `- timeInterval` → `NSTimeInterval`: Get scheduling interval
- `- fireDate` → `NSDate *`: Get next scheduled fire time
- `- userInfo` → `id`: Get associated user data

### Synchronization with Time Support

#### NSLock + NSDate Category

- `- lockBeforeDate:(NSDate *)limit` → `BOOL`: Acquire lock with timeout

#### NSCondition + NSDate Category

- `- waitUntilDate:(NSDate *)limit` → `BOOL`: Wait with timeout
- `- lockBeforeDate:(NSDate *)limit` → `BOOL`: Lock with timeout

#### NSConditionLock + NSDate Category

- `- lockWhenCondition:(int)condition beforeDate:(NSDate *)limit` → `BOOL`: Conditional lock with timeout
- `- waitUntilDate:(NSDate *)limit forCondition:(int)condition` → `BOOL`: Condition wait with timeout

#### NSThread + NSDate Category

- `+ sleepUntilDate:(NSDate *)date` → `void`: Sleep until specified time

## 4. Performance Characteristics

- **NSDate Creation**: O(1); minimal allocation
- **Comparison**: O(1) double comparison
- **Arithmetic**: O(1) floating-point operation
- **NSTimer**: O(1) scheduling (timer managed by run loop)
- **Memory**: Immutable; safe for caching
- **Thread-Safety**: NSDate immutable (thread-safe); locks provide synchronization

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Use NSDate for Timestamps**: Prefer over raw NSTimeInterval for semantic clarity
- **Compare Dates Properly**: Always use -compare: rather than subtraction
- **Timer Invalidation**: Always call invalidate() on timers when done
- **Timeout Constants**: Use NSTimeInterval constants for distant future/past
- **NSDate Caching**: Safe to cache NSDate instances (immutable)

### Common Pitfalls

- **NSTimer References**: Timer holds strong reference to target; can cause retain cycles if target holds timer
- **Invalidation Required**: Timer continues firing until explicitly invalidated (or autoreleased)
- **Timezone Issues**: NSDate is timezone-agnostic; times in GMT
- **Precision Loss**: Floating-point arithmetic may accumulate rounding errors
- **Run Loop Dependency**: NSTimer requires active run loop to fire

### Idiomatic Usage

```c
// Pattern 1: Check if date is in future
NSDate *now = [NSDate date];
if ([futureDate compare:now] == NSOrderedDescending) {
    // futureDate is in the future
}

// Pattern 2: Safely schedule timer without retain cycle
NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                 target:someObject 
                                               selector:@selector(callback:) 
                                               userInfo:nil 
                                                repeats:YES];
// Later: [timer invalidate];

// Pattern 3: Calculate time elapsed
NSDate *start = [NSDate date];
// ... do work ...
NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:start];
```

## 6. Integration Examples

### Example 1: Basic Date Operations

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

int main() {
    NSDate *now = [NSDate date];
    NSLog(@"Current date: %@", now);
    
    NSTimeInterval tomorrow = 24 * 60 * 60;
    NSDate *futureDate = [now dateByAddingTimeInterval:tomorrow];
    NSLog(@"Tomorrow: %@", futureDate);
    
    NSComparisonResult result = [futureDate compare:now];
    NSLog(@"Tomorrow is after today: %s", 
          result == NSOrderedDescending ? "yes" : "no");
    
    return 0;
}
```

### Example 2: Date Comparison

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

int main() {
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:0];  // Jan 1, 1970
    NSDate *date2 = [NSDate date];
    
    NSTimeInterval elapsed = [date2 timeIntervalSinceDate:date1];
    NSLog(@"Seconds since 1970: %.0f", elapsed);
    
    NSDate *earlier = [date1 earlierDate:date2];
    NSDate *later = [date1 laterDate:date2];
    
    NSLog(@"Earlier: %@", earlier);
    NSLog(@"Later: %@", later);
    
    return 0;
}
```

### Example 3: Timer with Callback

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

@interface Counter : NSObject
- (void)tick:(NSTimer *)timer;
@end

@implementation Counter
- (void)tick:(NSTimer *)timer {
    NSLog(@"Timer fired!");
}
@end

int main() {
    Counter *counter = [[Counter alloc] init];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                                     target:counter 
                                                   selector:@selector(tick:) 
                                                   userInfo:nil 
                                                    repeats:YES];
    
    // Timer will fire every 1 second
    // Later: [timer invalidate];
    
    [counter release];
    return 0;
}
```

### Example 4: Lock with Timeout

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

int main() {
    NSLock *lock = [[NSLock alloc] init];
    
    NSDate *deadline = [[NSDate date] dateByAddingTimeInterval:2.0];
    
    if ([lock lockBeforeDate:deadline]) {
        NSLog(@"Lock acquired");
        [lock unlock];
    } else {
        NSLog(@"Timeout - could not acquire lock");
    }
    
    [lock release];
    return 0;
}
```

### Example 5: Time Interval Calculation

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

int main() {
    NSDate *start = [NSDate date];
    
    // Do some work
    for (int i = 0; i < 1000000; i++) {
        asm volatile("");
    }
    
    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:start];
    NSLog(@"Elapsed time: %.6f seconds", elapsed);
    
    return 0;
}
```

### Example 6: Condition Wait with Timeout

```objc
#import <MulleObjCTimeFoundation/MulleObjCTimeFoundation.h>

int main() {
    NSCondition *condition = [[NSCondition alloc] init];
    
    [condition lock];
    
    NSDate *timeout = [[NSDate date] dateByAddingTimeInterval:3.0];
    BOOL signaled = [condition waitUntilDate:timeout];
    
    if (signaled) {
        NSLog(@"Condition was signaled");
    } else {
        NSLog(@"Timeout - condition not signaled");
    }
    
    [condition unlock];
    [condition release];
    return 0;
}
```

## 7. Dependencies

- MulleObjC (core framework)
- mulle-time (underlying time support)
- MulleFoundationBase
