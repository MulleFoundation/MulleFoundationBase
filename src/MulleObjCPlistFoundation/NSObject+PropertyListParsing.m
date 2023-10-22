//
//  NSObject+PropertyListParsing.m
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
#import "NSObject+PropertyListParsing.h"

// other files in this library
#import "NSArray+PropertyListParsing.h"
#import "NSDictionary+PropertyListParsing.h"
#import "NSData+PropertyListParsing.h"
#import "NSString+PropertyListParsing.h"
#import "_MulleObjCPropertyListReader.h"
#import "_MulleObjCPropertyListReader+InlineAccessors.h"

// other libraries of MulleObjCPosixFoundation

// std-c and dependencies

@interface NSObject( _NS)

- (BOOL) __isNSString;
- (BOOL) __isNSNumber;

@end


@implementation NSObject( NSPropertyListParsing)

//
// if it's unquoted it's known to be non-nil, unescaped and alnum
// (with possibly +-eE)
//
id   _MulleObjCNewObjectParsedUnquotedFromPropertyListWithReader( _MulleObjCPropertyListReader *reader)
{
   MulleObjCMemoryRegion  region;
   NSNumber               *nr;

   _MulleObjCPropertyListReaderBookmark( reader);
   _MulleObjCPropertyListReaderSkipUntilTrue( reader, _MulleObjCPropertyListReaderIsUnquotedStringEndChar);
   region = _MulleObjCPropertyListReaderBookmarkedRegion( reader);
   // empty string not possible

   if( [reader decodesNumber])
   {
      nr = MulleNewNumberWithUTF8Data( mulle_utf8data_make( (char *) region.bytes, region.length));
      if( nr)
         return( nr);
   }

   if( [reader decodesBool])
   {
      nr = MulleNewBoolWithUTF8Data( mulle_utf8data_make( (char *) region.bytes, region.length));
      if( nr)
         return( nr);
   }

   if( region.length == 8 && region.bytes[ 0] == '_')
   {
      if( ! memcmp( region.bytes, "__NULL__", 8))
         return( [reader->nsNull retain]);
      else
         return( _MulleObjCPropertyListReaderFail( reader,
                                                   @"stray '_' in input (needs to be quoted)"));
   }
   return( [[reader->nsStringClass alloc] mulleInitWithUTF8Characters:(char *) region.bytes
                                                               length:region.length]);
}


// nil means error, _MulleObjCPropertyListReaderFail should have complained
// already.
//
// NSNull means some plist is incomplete like a comma after a value is
// missing "{ x, }".If you get this at the beginning of a parse it indicates
// a malformed plist
//
id   _MulleObjCNewFromPropertyListWithStreamReader( _MulleObjCPropertyListReader *reader)
{
   long   x;
   id     plist;
   BOOL   missingSlash;
   BOOL   isLeaf;

   isLeaf = [reader isLeaf];
   [reader setLeaf:YES];

   x = _MulleObjCPropertyListReaderSkipWhiteAndComments( reader);
   switch( x)
   {
   case -1 :
      return( _MulleObjCPropertyListReaderFail( reader, @"empty property list is invalid"));

   default: // an unquoted string or number
      if( ! [reader decodesComments])
      {
         if( x == '/')
            return( _MulleObjCPropertyListReaderFail( reader,
                                                      @"stray '/' in input (needs to be quoted)"));
      }

      /* we missed a '/', only happens ifdef MULLE_PLIST_DECODE_PBX  */
      missingSlash = (x != _MulleObjCPropertyListReaderCurrentUTF32Character( reader));
      if( ! _MulleObjCPropertyListReaderIsUnquotedStringStartChar( reader, x))
         return( _MulleObjCPropertyListReaderFail( reader,
                                                   @"stray '%c' (%ld) in input (needs to be quoted)",
                                                   (int) x, x));

      plist = _MulleObjCNewObjectParsedUnquotedFromPropertyListWithReader( reader);
      if( missingSlash && plist)
      {
         [plist autorelease];
         plist  = [[@"/" stringByAppendingString:plist] retain];
      }
      break;

   case '"': // quoted string
      plist = _MulleObjCNewStringFromPropertyListWithReader( reader);
      if( isLeaf)
         return( plist);
      break;

   case '{': // dictionary (or set with {(
      plist = _MulleObjCNewDictionaryFromPropertyListWithReader( reader, nil);
      return( plist);

   case '(': // array
      plist = _MulleObjCNewArrayFromPropertyListWithReader( reader);
      return( plist);

   case '<': // data or date <@
      plist = _MulleObjCNewDataFromPropertyListWithReader( reader);
      return( plist);

   case '}' :
   case ')' :  // can happen in  (  v, y, c, ) situations
      return( [reader->nsNull retain]);
   }

   x = _MulleObjCPropertyListReaderSkipWhiteAndComments( reader);
   if( x != '=')
      return( plist);

   // known to be a string, lets check if it really is "strings format"
   NSCParameterAssert( [plist __isNSString] || [plist __isNSNumber]);

   /* it's a strings file really ! */
   [reader setStringsPlist:YES];
   plist = _MulleObjCNewDictionaryFromPropertyListWithReader( reader, plist);
   return( plist);
}

@end
