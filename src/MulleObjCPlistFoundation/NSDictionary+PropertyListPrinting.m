//
//  NSDictionary+PropertyListPrinting.m
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
#import "NSDictionary+PropertyListPrinting.h"

// other files in this library
#import "MulleObjCPropertyListPrinting.h"

// std-c and dependencies


//
// ugliness... make this thread local at the very least
//
BOOL   _MulleObjCPropertyListSortedDictionary;
BOOL   _MulleObjCJSONSortedDictionary;

@interface NSObject( _NS)

- (BOOL) __isNSString;
- (BOOL) __isNSNull;

@end


@implementation NSDictionary( PropertyListPrinting)

struct dictionary_format_info
{
   char   empty[ 2];
   char   separator[ 2];
   char   separator2[ 1];
   char   opener[ 2];
   char   closer[ 1];
   char   divider[ 3];
   SEL    keyMethod;
};


static struct dictionary_format_info   plist_format_info =
{
   { '{', '}'      },  // empty
   { ';', '\n'     },  // separator
   { '\n'          },  // separator2
   { '{', '\n'     },  // opener
   { '}'           },  // closer
   { ' ', '=', ' ' },  // divider
   @selector( self)
};



static struct dictionary_format_info   json_format_info =
{
   { '{', '}'    },    // empty
   { ',', '\n'   },    // separator
   { '\n'        },    // separator2
   { '{', '\n'   },    // opener
   { '}'         },    // closer
   { ':', ' ', 0 },    // divider
   @selector( description)  // not sure
};


//
// driven by formatInfo to support propertyList and JSON format
//
- (void) _mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt
             memberMethod:(SEL) memberMethod
     dictionaryFormatInfo:(struct dictionary_format_info *) info
{
   char         *indentation;
   id           key, value;
   NSArray      *keys;
   NSUInteger   n;

   n = [self count];
   if( ! n)
   {
      [ctxt->handle mulleWriteBytes:info->empty
                             length:sizeof( info->empty)];
      return;
   }

   [ctxt->handle mulleWriteBytes:info->opener
                         length:2];

   ++ctxt->indent; // inside '{'
   indentation = MulleObjCPrintPlistContextUTF8Indentation( ctxt);

   //
   // don't really care if sorted or not but WTF.. :)
   // + consistent output, easier to diff
   // - obviously slower, possibly a bottleneck for huge plists
   // thought: use plists for "huge" data ?
   //
   keys = [self allKeys];
   if( ctxt->sortsDictionary)
      keys = [keys sortedArrayUsingSelector:@selector( mulleCompareDescription:)];
   for( key in keys)
   {
      value = [self objectForKey:key];
      if( ! ctxt->allowsNull && [value __isNSNull])
         continue;

      [ctxt->handle mulleWriteUTF8String:indentation];
      //[key mullePrintPropertyList:handle
      //                           indent:0];
      key = MulleObjCObjectPerformSelector0( key, info->keyMethod);
      MulleObjCObjectPerformSelector( key, memberMethod, (id) ctxt);
      [ctxt->handle mulleWriteBytes:info->divider
                             length:info->divider[ 2] ? 3 : 2];
      //[value mullePrintPropertyList:handle
      //                           indent:0];
      MulleObjCObjectPerformSelector( value, memberMethod, (id) ctxt);
      if( --n)
         [ctxt->handle mulleWriteBytes:info->separator
                                length:sizeof( info->separator)];
      else
         [ctxt->handle mulleWriteBytes:info->separator2
                                length:sizeof( info->separator2)];
   }

   --ctxt->indent;
   indentation = MulleObjCPrintPlistContextUTF8Indentation( ctxt);
   [ctxt->handle mulleWriteUTF8String:indentation];
   [ctxt->handle mulleWriteBytes:info->closer
                          length:sizeof( info->closer)];
}


- (void) mullePrintPlist:(struct MulleObjCPrintPlistContext *) ctxt
{
   [self _mullePrintPlist:ctxt
             memberMethod:_cmd
     dictionaryFormatInfo:&plist_format_info];
}


- (void) mullePrintJSON:(struct MulleObjCPrintPlistContext *) ctxt

{
   [self _mullePrintPlist:ctxt
             memberMethod:_cmd
     dictionaryFormatInfo:&json_format_info];
}

@end
