//
//  NSCharacterSet+MulleObjCUnicode.m
//  MulleObjCStandardFoundation
//
//  Copyright (c) 2016-2020 Nat! - Mulle kybernetiK.
//  Copyright (c) 2016-2020 Codeon GmbH.
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
#import "NSCharacterSet+MulleObjCUnicode.h"

#import "import-private.h"

// other files in this library
#import <MulleObjCStandardFoundation/_MulleObjCConcreteCharacterSet.h>

// other libraries of MulleObjCStandardFoundation

// std-c and dependencies


#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"


@implementation NSCharacterSet( MulleObjCUnicode)


MULLE_OBJC_DEPENDS_ON_LIBRARY( MulleObjCStandardFoundation);


+ (instancetype) alphanumericCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_alphanumeric
                                                    planeFunction:mulle_unicode_is_alphanumericplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) capitalizedLetterCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_capitalized
                                                    planeFunction:(int (*)(unsigned int)) mulle_unicode_is_capitalizedplane
                                                          invert:NO] autorelease]);
}


+ (instancetype) controlCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_control
                                                    planeFunction:mulle_unicode_is_controlplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) decimalDigitCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_decimaldigit
                                                    planeFunction:mulle_unicode_is_decimaldigitplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) decomposableCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_decomposable
                                                    planeFunction:mulle_unicode_is_decomposableplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) illegalCharacterSet
{
   NSCharacterSet  *characterSet;

   characterSet = [_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_legalcharacter
                                                          planeFunction:mulle_unicode_is_legalcharacterplane
                                                                 invert:NO];
   return( [characterSet invertedSet]);
}


+ (instancetype) letterCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_letter
                                                    planeFunction:mulle_unicode_is_letterplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) lowercaseLetterCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_lowercase
                                                    planeFunction:mulle_unicode_is_lowercaseplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) nonBaseCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_nonbase
                                                    planeFunction:mulle_unicode_is_nonbaseplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) punctuationCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_punctuation
                                                    planeFunction:mulle_unicode_is_punctuationplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) symbolCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_symbol
                                                    planeFunction:mulle_unicode_is_symbolplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) uppercaseLetterCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_uppercase
                                                    planeFunction:mulle_unicode_is_uppercaseplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) whitespaceAndNewlineCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_whitespaceornewline
                                                    planeFunction:mulle_unicode_is_whitespaceornewlineplane
                                                           invert:NO] autorelease]);
}


+ (instancetype) whitespaceCharacterSet
{
   return( [[_MulleObjCConcreteCharacterSet newWithMemberFunction:mulle_unicode_is_whitespace
                                                    planeFunction:mulle_unicode_is_whitespaceplane
                                                           invert:NO] autorelease]);
}

@end
