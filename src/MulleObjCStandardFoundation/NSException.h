//
//  NSException.h
//  MulleObjCStandardFoundation
//
//  Copyright (c) 2011 Nat! - Mulle kybernetiK.
//  Copyright (c) 2011 Codeon GmbH.
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
#import "import.h"


@class NSString;
@class NSDictionary;


@interface NSException : NSObject < MulleObjCException, MulleObjCImmutableProtocols>
{
   NSString       *_name;
   NSString       *_reason;
   id             _userInfo;
}

+ (NSException *) exceptionWithName:(NSString *) name
                             reason:(NSString *) reason
                           userInfo:(id) userInfo;

//
// MEMO: don't marker raise as MULLE_C_NO_RETURN because
//       when self is nil, it does return.
//
+ (void) raise:(NSString *) name
        format:(NSString *) format
mulleVarargList:(mulle_vararg_list) args;

+ (void) raise:(NSString *) name
        format:(NSString *) format
     arguments:(va_list) va;

+ (void) raise:(NSString *) name
        format:(NSString *) format, ...;


- (instancetype) initWithName:(NSString *) name
                       reason:(NSString *) reason
                     userInfo:(NSDictionary *) userInfo;

- (NSString *) name;
- (NSString *) reason;
- (id) userInfo;

@end


#define NS_DURING             @try {
#define NS_HANDLER            } @catch( NSException *localException) {
#define NS_ENDHANDLER         }
#define NS_VALUERETURN( v,t)  return (v)
#define NS_VOIDRETURN         return

MULLE_OBJC_STANDARD_FOUNDATION_GLOBAL
MULLE_C_NO_RETURN
void   MulleObjCThrowMallocException( struct mulle_allocator *allocator, void *block, size_t size);


MULLE_OBJC_STANDARD_FOUNDATION_GLOBAL NSString   *NSInternalInconsistencyException;
MULLE_OBJC_STANDARD_FOUNDATION_GLOBAL NSString   *NSGenericException;
MULLE_OBJC_STANDARD_FOUNDATION_GLOBAL NSString   *NSInvalidArgumentException;
MULLE_OBJC_STANDARD_FOUNDATION_GLOBAL NSString   *NSMallocException;
MULLE_OBJC_STANDARD_FOUNDATION_GLOBAL NSString   *NSRangeException;
MULLE_OBJC_STANDARD_FOUNDATION_GLOBAL NSString   *NSParseErrorException;