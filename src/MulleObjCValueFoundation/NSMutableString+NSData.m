//
//  NSMutableString+NSData.m
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

#import "NSMutableString.h"

// other files in this library
#import "NSString+NSData.h"

// other libraries of MulleObjCValueFoundation

// std-c and dependencies


@implementation NSMutableString (NSData)

- (instancetype) initWithBytes:(void *) bytes
                        length:(NSUInteger) length
                      encoding:(NSStringEncoding) encoding;
{
   NSString  *s;

   s = nil;
   if( length)
   {
      s = [[NSString alloc] initWithBytes:bytes
                                   length:length
                                 encoding:encoding];
      if( ! s)
      {
         [self release];
         return( nil);
      }
   }

   self = [self initWithStrings:&s
                          count:s ? 1 : 0];
   [s release];

   return( self);
}


// this method is a lie, it will copy
// use initWithCharactersNoCopy:
// also your bytes will be freed immediately, when freeWhenDone is YES
- (instancetype) initWithBytesNoCopy:(void *) bytes
                              length:(NSUInteger) length
                            encoding:(NSStringEncoding) encoding
                        freeWhenDone:(BOOL) flag;
{
   NSString  *s;

   s = [[NSString alloc] initWithBytesNoCopy:bytes
                                      length:length
                                    encoding:encoding
                                freeWhenDone:flag];
   if( ! s)
   {
      [self release];
      return( nil);
   }

   self = [self initWithStrings:&s
                          count:1];
   [s release];

   return( self);
}

@end
