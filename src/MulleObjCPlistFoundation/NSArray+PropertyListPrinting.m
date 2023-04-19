//
//  NSArray+PropertyListPrinting.m
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
#import "NSArray+PropertyListPrinting.h"

// other files in this library

// other libraries of MulleObjCPlistFoundation

// std-c and dependencies


@implementation NSArray ( PropertyListPrinting)


struct format_info
{
   char   empty[ 2];
   char   separator[ 2];
   char   opener[ 2];
   char   closer[ 2];
};


static struct format_info   plist_format_info =
{
   { '(', ')' },
   { ',', ' ' },
   { '(', ' ' },
   { ' ', ')' }
};


static struct format_info   json_format_info =
{
   { '[', ']' },
   { ',', ' ' },
   { '[', ' ' },
   { ' ', ']' }
};


//static char   empty[]     = { '(', ')' };


- (void) _mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt
             memberMethod:(SEL) memberMethod
               formatInfo:(struct format_info *) info

{
   NSUInteger   n;
   id           value;

   n = [self count];
   if( ! n)
   {
      MulleObjCPrintPlistContextWriteBytes( ctxt, info->empty, sizeof( info->empty));
      return;
   }

   MulleObjCPrintPlistContextWriteBytes( ctxt, info->opener, sizeof( info->opener));
   for( value in self)
   {
      MulleObjCObjectPerformSelector( value, memberMethod, (id) ctxt);
      if( --n)
         MulleObjCPrintPlistContextWriteBytes( ctxt, info->separator, sizeof( info->separator));
   }

   MulleObjCPrintPlistContextWriteBytes( ctxt, info->closer, sizeof( info->closer));
}


- (void) mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt

{
   [self _mullePrintPlist:ctxt
             memberMethod:_cmd
               formatInfo:&plist_format_info];
}


- (void) mullePrintJSON:(struct MulleObjCPrintPlistContext *) ctxt

{
   [self _mullePrintPlist:ctxt
             memberMethod:_cmd
               formatInfo:&json_format_info];
}

@end
