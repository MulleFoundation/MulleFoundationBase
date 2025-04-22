//
//  NSObject+PropertyListPrinting.m
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
#import "MulleObjCPropertyListPrinting.h"

// other files in this library
#import "MulleObjCStream.h"

#import "import-private.h"

// std-c and dependencies



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"
#pragma clang diagnostic ignored "-Wobjc-root-class"


void  MulleObjCPrintPlistContextSetHandle( struct MulleObjCPrintPlistContext *ctxt,
                                           id <MulleObjCOutputStream> handle)
{
   ctxt->handle            = handle;
   ctxt->writeBytes_length = [(id) handle methodForSelector:@selector( mulleWriteBytes:length:)];
}


void  MulleObjCPrintPlistContextInit( struct MulleObjCPrintPlistContext *ctxt,
                                      id <MulleObjCOutputStream> handle)
{
   memset( ctxt, 0, sizeof( *ctxt));

   MulleObjCPrintPlistContextSetHandle( ctxt, handle);
   ctxt->dateFormatter     = [[[NSDateFormatter alloc] initWithDateFormat:MulleDateFormatISOWithMilliseconds
                                                     allowNaturalLanguage:NO] autorelease];
   ctxt->indentPerLevel    = 1;
   ctxt->indentChar        = '\t';
   ctxt->sortsDictionary   = YES;
}


PROTOCOLCLASS_IMPLEMENTATION( MulleObjCPropertyListPrinting)

- (void) mullePrintPlistToStream:(id <MulleObjCOutputStream>) handle;
{
   struct MulleObjCPrintPlistContext  ctxt;

   MulleObjCPrintPlistContextInit( &ctxt, handle);

   // though the NSDateFormatter class is known here, the actual
   // implementations are in MulleObjCOSFoundation, so you need
   // to link with OSFoundation or some other provider of
   // formatter functionality
   ctxt.dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:MulleDateFormatISO
                                                allowNaturalLanguage:NO] autorelease];

   [self mullePrintPlist:&ctxt];
}


- (void) mullePrintLoosePlistToStream:(id <MulleObjCOutputStream>) handle
{
   struct MulleObjCPrintPlistContext  ctxt;

   MulleObjCPrintPlistContextInit( &ctxt, handle);
   ctxt.dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:MulleDateFormatISOWithMilliseconds
                                                allowNaturalLanguage:NO] autorelease];
   ctxt.allowsNull    = YES;
   ctxt.printsBool    = YES;

   [self mullePrintPlist:&ctxt];
}


- (void) mullePrintJSONToStream:(id <MulleObjCOutputStream>) handle;
{
   struct MulleObjCPrintPlistContext  ctxt;

   MulleObjCPrintPlistContextInit( &ctxt, handle);
   ctxt.dateFormatter       = [[[NSDateFormatter alloc] initWithDateFormat:@"%d.%m.%Y %H:%M:%S.%F"
                                                      allowNaturalLanguage:NO] autorelease];
   ctxt.allowsNull          = YES;
   ctxt.alwaysQuotesStrings = YES; // or ?

   [self mullePrintJSON:&ctxt];
}


- (NSString *) mullePropertyListDescription
{
   NSMutableData  *data;
   NSString       *s;

   data = [NSMutableData data];
   [self mullePrintPlistToStream:data];

   s = [[[NSString alloc] initWithData:data
                              encoding:NSUTF8StringEncoding] autorelease];
   return( s);
}


- (NSString *) mulleJSONDescription
{
   NSMutableData  *data;
   NSString       *s;

   data = [NSMutableData data];
   [self mullePrintJSONToStream:data];

   s = [[[NSString alloc] initWithData:data
                              encoding:NSUTF8StringEncoding] autorelease];
   return( s);
}


/*
 *
 */
static char   tabs[]   = "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t";
static char   spaces[] = "                                                ";

char   *_MulleObjCPrintPlistContextUTF8Indentation( NSUInteger indent,
                                                    NSUInteger indentPerLevel,
                                                    NSUInteger indentChar)
{
   NSUInteger   n;
   size_t       size;
   char         *s;

   if( ! indent)
      return( "");

   switch( indentChar)
   {
   case '\t' : s = tabs;   size = sizeof( tabs) - 1;   break;
   case ' '  : s = spaces; size = sizeof( spaces) - 1; break;
   default   : s = NULL;   size = 0;                   break;
   }

   n = indent * indentPerLevel;
   // size is strlen
   if( n <= size)
      return( &s[ size - n]);

   s = MulleObjCCallocAutoreleased( n + 1, sizeof( char));
   memset( s,
           indentChar,
           n);
   return( s);
}


char   *MulleObjCPrintPlistContextUTF8Indentation( struct MulleObjCPrintPlistContext *ctxt)
{
   return( _MulleObjCPrintPlistContextUTF8Indentation( ctxt->indent,
                                                       ctxt->indentPerLevel,
                                                       ctxt->indentChar));
}


void   MulleObjCPrintPlistContextWriteUTF8Indentation( struct MulleObjCPrintPlistContext *ctxt)
{
   char   *s;

   s = _MulleObjCPrintPlistContextUTF8Indentation( ctxt->indent,
                                                   ctxt->indentPerLevel,
                                                   ctxt->indentChar);
   MulleObjCPrintPlistContextWriteUTF8String( ctxt, s);
}


PROTOCOLCLASS_END()

#pragma clang diagnostic pop
