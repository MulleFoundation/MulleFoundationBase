//
//  NSString+PropertyListPrinting.m
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

#import "NSString+PropertyListPrinting.h"

// other files in this library
#import "NSData+PropertyListPrinting.h"

// std-c and dependencies


@implementation NSString ( PropertyListPrinting)


- (void) mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt
{
   NSString  *s;

   if( ctxt->alwaysQuotesStrings)
      s = [self mulleQuotedString];
   else
      s = [self mulleQuotedDescriptionIfNeeded];

   [s mulleWriteToStream:ctxt->handle
           usingEncoding:NSUTF8StringEncoding];
}


//
// always in double quotes, different kind of escapes
//
- (void) mullePrintJSON:(struct MulleObjCPrintPlistContext *) ctxt
{
   char                     *s, *start;
   char                     *q, *sentinel;
   size_t                   len;
   size_t                   size;
   struct mulle_utf8data    data;
   char                     tmp1[ 32];
   char                     tmp2[ 64];

   data = MulleStringUTF8Data( self, mulle_utf8data_make( tmp1,
                                                             sizeof( tmp1)));

   // do proper quoting and escaping
   len      = data.length;
   q        = data.characters;
   sentinel = &q[ len];

   start    = tmp2;
   size     = 2 + len * 6;
   if( size > sizeof( tmp2))
      start = MulleObjCCallocAutoreleased( size, sizeof( char));
   s        = start;

   *s++ = '"';
   while( q < sentinel)
   {
      switch( *q)
      {
      case '\b' : *s++ = '\\'; *s++ = 'b'; break;
      case '\f' : *s++ = '\\'; *s++ = 'f'; break;
      case '\n' : *s++ = '\\'; *s++ = 'n'; break;
      case '\r' : *s++ = '\\'; *s++ = 'r'; break;
      case '\t' : *s++ = '\\'; *s++ = 't'; break;
      case '\\' : *s++ = '\\'; *s++ = '\\'; break;
      case '\"' : *s++ = '\\'; *s++ = '\"'; break;
#if ESCAPED_ZERO_IN_UTF8_STRING_IS_A_GOOD_THING
      case 0    : *s++ = '\\'; *s++ = '0'; break;
#endif
      default   :
                  if( (unsigned char) *q < 0x20)
                  {
                     *s++ = '\\';
                     *s++ = 'x';
                     *s++ = '0';
                     *s++ = '0';
                     *s++ = '0' + (*q >= 0x10);
                     *s++ = (*q < 0xa)
                               ? ('0' + (*q & 0xF))
                               : ('a' + (*q & 0xF) - 10);
                  }
                  else
                     *s++ = *q;
                  break;
      }
      ++q;
   }
   *s++ = '"';

   [ctxt->handle mulleWriteBytes:start
                          length:s - start];
}


@end
