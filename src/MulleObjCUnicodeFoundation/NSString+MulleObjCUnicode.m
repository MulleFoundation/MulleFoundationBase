//
//  NSString+MulleObjCUnicode.h
//  MulleObjCUnicodeFoundation
//
//  Copyright (c) 2020 Nat! - Mulle kybernetiK.
//  Copyright (c) 2020 Codeon GmbH.
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
#import "NSString+MulleObjCUnicode.h"


// other files in this library
#import "NSCharacterSet+MulleObjCUnicode.h"

// std-c and dependencies
#import "import-private.h"

#if MULLE_UNICODE_VERSION < ((0 << 20) | (0 << 8) | 0)
# error "mulle_unicode is too old"
#endif


@implementation NSString( MulleObjCUnicode)


MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCStandardFoundation);

+ (void) load
{
   static struct MulleStringCharacterFunctions   functions =
   {
      mulle_unicode_is_decimaldigit,
      mulle_unicode_is_zerodigit,
      mulle_unicode_is_whitespace,
      mulle_unicode_tolower,
      mulle_unicode_toupper
   };
   [self setStringCharacterFunctions:&functions];
}

@end
