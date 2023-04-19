//
//  NSObject+PropertyListPrinting.h
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
#import "import.h"

#import "MulleObjCStream.h"


@class NSLocale;

struct MulleObjCPrintPlistContext
{
   id <MulleObjCOutputStream>   handle;
   IMP                          writeBytes_length;
   NSUInteger                   indent;
   NSUInteger                   indentPerLevel;
   char                         indentChar;

   BOOL                         allowsNull;
   BOOL                         printsBool;
   BOOL                         sortsDictionary;
   BOOL                         alwaysQuotesStrings;
   BOOL                         usesExtensions; // can print but nor parse

   NSDateFormatter              *dateFormatter;
};


MULLE_OBJC_PLIST_FOUNDATION_GLOBAL
void  MulleObjCPrintPlistContextInit( struct MulleObjCPrintPlistContext *ctxt,
                                      id <MulleObjCOutputStream> handle);

MULLE_OBJC_PLIST_FOUNDATION_GLOBAL
void  MulleObjCPrintPlistContextInit( struct MulleObjCPrintPlistContext *ctxt,
                                      id <MulleObjCOutputStream> handle);

MULLE_OBJC_PLIST_FOUNDATION_GLOBAL
void  MulleObjCPrintPlistContextSetHandle( struct MulleObjCPrintPlistContext *ctxt,
                                           id <MulleObjCOutputStream> handle);


// TODO: prefix with mulle, this is all incompatible

PROTOCOLCLASS_INTERFACE0( MulleObjCPropertyListPrinting)

//
// This is what participating classes should implement. This also allows
// more control over what is printed. You put the handle into the ctxt and
// also set some configs (see above)
//
- (void) mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt;
- (void) mullePrintJSON:(struct MulleObjCPrintPlistContext *) ctxt;

@optional

// simple conveniences to just get a list or json

- (NSString *) mullePropertyListDescription;
- (NSString *) mulleJSONDescription;

//
// MulleObjCOutputStream can be a NSFileHandle or a NSMutableData
// and that the plist or json is printed into
//
- (void) mullePrintPlistToStream:(id <MulleObjCOutputStream>) handle;
- (void) mullePrintLoosePlistToStream:(id <MulleObjCOutputStream>) handle;
- (void) mullePrintJSONToStream:(id <MulleObjCOutputStream>) handle;


PROTOCOLCLASS_END()


// these helper methods produce indentation
MULLE_OBJC_PLIST_FOUNDATION_GLOBAL
MULLE_C_NONNULL_RETURN
char   *MulleObjCPrintPlistContextUTF8Indentation( struct MulleObjCPrintPlistContext *ctxt);

MULLE_OBJC_PLIST_FOUNDATION_GLOBAL
MULLE_C_NONNULL_RETURN
char   *_MulleObjCPrintPlistContextUTF8Indentation( NSUInteger indent,
                                                    NSUInteger indentPerLevel,
                                                    NSUInteger indentChar);

MULLE_OBJC_PLIST_FOUNDATION_GLOBAL
void   MulleObjCPrintPlistContextWriteUTF8Indentation( struct MulleObjCPrintPlistContext *ctxt);

//
static inline void
   MulleObjCPrintPlistContextWriteUTF8String( struct MulleObjCPrintPlistContext *ctxt,
                                              char *s)
{
   MulleObjCIMPCall2( ctxt->writeBytes_length,
                      ctxt->handle,
                      @selector( mulleWriteBytes:length:),
                      (id) s,
                      (id) strlen( s));
}

static inline void
   MulleObjCPrintPlistContextWriteBytes( struct MulleObjCPrintPlistContext *ctxt,
                                         void *bytes,
                                         NSUInteger length)
{
   MulleObjCIMPCall2( ctxt->writeBytes_length,
                      ctxt->handle,
                      @selector( mulleWriteBytes:length:),
                      (id) bytes,
                      (id) length);
}

