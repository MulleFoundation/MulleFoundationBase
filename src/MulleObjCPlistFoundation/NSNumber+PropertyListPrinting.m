//
//  NSNumber+PropertyListPrinting.m
//  MulleObjCPlistFoundation
//
//  Copyright (c) 2009 Nat! - Mulle kybernetiK.
//  Copyright (c) 2009 Codeon GmbH.
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

#import "NSNumber+PropertyListPrinting.h"

// other files in this library
#import "NSString+PropertyListPrinting.h"

// other libraries of MulleObjCPlistFoundation
#import "import-private.h"

// private classes of MulleObjCValueFoundation
#import <MulleObjCValueFoundation/_MulleObjCValueTaggedPointer.h>
#import <MulleObjCValueFoundation/_MulleObjCConcreteNumber.h>
#import <MulleObjCValueFoundation/_MulleObjCTaggedPointerIntegerNumber.h>
#import <MulleObjCValueFoundation/NSNumber-Private.h>

// std-c and dependencies


@implementation NSNull( PropertyListPrinting)

// an extension
- (void) mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt
{
   [ctxt->handle mulleWriteBytes:"__NULL__"
                         length:8];
}


- (void) mullePrintJSON:(struct MulleObjCPrintPlistContext *) ctxt
{
   [ctxt->handle mulleWriteBytes:"null"
                          length:4];
}

@end



@implementation _MulleObjCBoolNumber( PropertyListPrinting)

- (void) mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt
{
   BOOL   flag;
   char   c;

   flag = [self boolValue];
   if( ! ctxt->printsBool)
   {
      c = flag + '0';
      [ctxt->handle mulleWriteBytes:&c
                             length:1];
      return;
   }

   if( flag)
      [ctxt->handle mulleWriteBytes:"YES"
                             length:3];
   else
      [ctxt->handle mulleWriteBytes:"NO"
                             length:2];
}


- (void) mullePrintJSON:(struct MulleObjCPrintPlistContext *) ctxt
{
   if( [self boolValue])
      [ctxt->handle mulleWriteBytes:"true"
                             length:4];
   else
      [ctxt->handle mulleWriteBytes:"false"
                             length:5];
}

@end


void   MullePlistPrintNumberToStream( NSNumber *self, id <MulleObjCOutputStream> handle)
{
   char                     tmp[ 64];
   struct mulle_asciidata   data;

   data = mulle_asciidata_make( tmp, sizeof( tmp));
   [self _mulleConvertToASCIICharacters:&data];
   [handle mulleWriteBytes:data.characters
                    length:data.length];
}



@implementation NSNumber( PropertyListPrinting)

- (void) mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt
{
   MullePlistPrintNumberToStream( self, ctxt->handle);
}

- (void) mullePrintJSON:(struct MulleObjCPrintPlistContext *) ctxt
{
   MullePlistPrintNumberToStream( self, ctxt->handle);
}

@end



//
// The core problem here is, that a double has no 1:1 representation with
// many numbers like f.e. 0.8, the double value is really 0.80000000000000004.
// If we parse a string "0.8" we get 0.80000000000000004 (ez to reproduce
// in any debugger with "p 0.8". The 'next' higher possible number seems to be
// 0.80000000000000016, the 'previous' lower is 0.79999999999999993.
//
// Values from 0.79999999999999999 to 0.80000000000000009
// all parse to 0.80000000000000004
//
// There are two competing views here.
//
// a) I don't want plist to be lossy. Writing a double into a plist and
//    reading back from it, must not change the value.
//
// b) I wrote a plist with { "a" = 0.8; }, but when I wrote it back it
//    changed into { "a" = 0.80000000000000004; }, that's not as readable
//    and not what I want.
//
// The "proper" solution would need to store a string representation of the
// input along with NSNumber.
//
// I experimented here with printing the output first rounded, parsing it again
// and then checking that the parsed value is the same as we had.
//
void   MullePListPrintFPNumberToStream( NSNumber *self,
                                        id <MulleObjCOutputStream> handle)
{
   char          *type;
   long double   lv1, lv2;
   double        v1, v2;
   char          buf[ 32];
   int           len;

   // TODO: need to set locale here ?
   type = [self objCType];
   switch( *type)
   {
   default :
      abort();

   case _C_FLT :
      v1  = [self doubleValue];
      len = sprintf( buf, "%0.7g", v1);
      v2  = strtod( buf, NULL);
      if( v1 != v2)
         len = sprintf( buf, "%0.8g", v1);
      break;

   case _C_DBL :
      v1  = [self doubleValue];
      len = sprintf( buf, "%0.16g", v1);
      v2  = strtod( buf, NULL);
      if( v1 != v2)
         len = sprintf( buf, "%0.17g", v1);
      break;

   case _C_LNG_DBL :
      lv1 = [self longDoubleValue];
      len = sprintf( buf, "%0.20Lg", lv1);
      lv2 = strtold( buf, NULL);
      if( lv1 != lv2)
        len = sprintf( buf, "%0.21Lg", lv1);
      break;
   }
   [handle mulleWriteBytes:buf
                    length:len];
}


@implementation _MulleObjCDoubleNumber( PropertyListPrinting)

- (void) mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt
{
   MullePListPrintFPNumberToStream( self, ctxt->handle);
}

- (void) mullePrintJSON:(struct MulleObjCPrintPlistContext *) ctxt
{
   MullePListPrintFPNumberToStream( self, ctxt->handle);
}

@end


@implementation _MulleObjCLongDoubleNumber( PropertyListPrinting)

- (void) mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt
{
   MullePListPrintFPNumberToStream( self, ctxt->handle);
}

- (void) mullePrintJSON:(struct MulleObjCPrintPlistContext *) ctxt
{
   MullePListPrintFPNumberToStream( self, ctxt->handle);
}

@end

