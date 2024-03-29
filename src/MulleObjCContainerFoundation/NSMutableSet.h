//
//  NSMutableSet.h
//  MulleObjCContainerFoundation
//
//  Copyright (c) 2016 Nat! - Mulle kybernetiK.
//  Copyright (c) 2016 Codeon GmbH.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

#import "NSSet.h"


@interface NSMutableSet : NSSet < NSMutableSet, MulleObjCClassCluster>

+ (instancetype) setWithCapacity:(NSUInteger) numItems;

- (void) intersectSet:(NSSet *) other;
- (void) minusSet:(NSSet *) other;
- (void) unionSet:(NSSet *) other;
- (void) setSet:(NSSet *) other;

@end


@interface NSSet( NSMutableSet) <NSMutableCopying>
@end


@interface NSMutableSet( Subclasses)

- (instancetype) initWithCapacity:(NSUInteger) numItems;
- (void) addObject:(id) object;
- (void) removeObject:(id) object;
- (void) removeAllObjects;

// adds object to set, if not present. If matching an already registered
// object, will return that instead
- (id) mulleRegisterObject:(id) object;

@end

@interface NSMutableSet( _NSMutableSetPlaceholder)

// not instancetype here
- (id) init;
- (id) initWithCapacity:(NSUInteger) count;
- (id) mulleInitForCoderWithCapacity:(NSUInteger) count;
- (id) mulleInitWithRetainedObjectStorage:(id *) objects
                                    count:(NSUInteger) count
                                     size:(NSUInteger) size;
- (id) mulleInitWithRetainedObjects:(id *) objects
                               count:(NSUInteger) count;
@end
