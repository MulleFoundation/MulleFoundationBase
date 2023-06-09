//
//  NSString+Sprintf.h
//  MulleObjCValueFoundation
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

#import "NSString.h"


//
// MEMO: if you are getting suprising "nil" returns here your string
//       likely contains an unsupported formatting character.
//       If this is not the case, ensure that mulle-sprintf is "force"
//       linked (all-load) to your executable.
//
@interface NSString( Sprintf)

+ (instancetype) stringWithFormat:(NSString *) format
                  mulleVarargList:(mulle_vararg_list) arguments;

+ (instancetype) mulleStringWithFormat:(NSString *) format
                             arguments:(va_list) args;

+ (instancetype) stringWithFormat:(NSString *) format, ...;

- (instancetype) initWithFormat:(NSString *) format
                mulleVarargList:(mulle_vararg_list) arguments;
- (instancetype) initWithFormat:(NSString *) format
                      arguments:(va_list) va_list;

- (instancetype) initWithFormat:(NSString *) format, ...;

- (NSString *) stringByAppendingFormat:(NSString *) format, ...;

@end

