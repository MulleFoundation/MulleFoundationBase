//
//  NSString+PropertyListParsing.m
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
#import "NSString+PropertyListParsing.h"

// other files in this library
#import "_MulleObjCPropertyListReader+InlineAccessors.h"

// other libraries of MulleObjCPlistFoundation

// std-c and dependencies



@implementation NSString ( NSPropertyListParsing)


NSString   *
   _MulleObjCNewStringParsedQuotedFromPropertyListWithReader( _MulleObjCPropertyListReader *reader)
{
   long                    x;
   size_t                  escaped;
   MulleObjCMemoryRegion   region;
   NSMutableData           *data;
   char                    *dst;
   char                    *buf;
   NSString                *s;

   //
   // If we bookmark after the read, we already have read the next character
   // which could be a composed character, so we would bookmark only the last
   // character of the sequence. As we know its only byte we are going to read
   // we use an offset to bookmark.
   //
   _MulleObjCPropertyListReaderBookmarkAtOffset( reader, 1);

   // grab '"' off
   x = _MulleObjCPropertyListReaderNextUTF32Character( reader);

   escaped = 0;

   //
   // consume string... figure out how long it is
   // first slurp in the string unescaped and check boundaries
   //
   while( x != '"')
   {
      if( x == '\\')
      {
         ++escaped;

         x = _MulleObjCPropertyListReaderNextUTF32Character( reader);
         if( x == -1)
            return( _MulleObjCPropertyListReaderFail( reader, @"escape in quoted string not finished !"));
      }
      x = _MulleObjCPropertyListReaderNextUTF32Character( reader);
      if( x < 0)
         return( _MulleObjCPropertyListReaderFail( reader, @"quoted string not closed (expected '\"')"));
   }

   // get region without the trailing quote
   region = _MulleObjCPropertyListReaderBookmarkedRegion( reader);
   // now we can't read the stream anymore, until we are done with the region
   // it's fragile but faster

   if( ! region.length)
   {
      _MulleObjCPropertyListReaderConsumeCurrentUTF32Character( reader); // skip '"'
      return( [[reader->nsStringClass alloc] initWithString:@""]);
   }

   if( ! escaped)
   {
      s = [[reader->nsStringClass alloc] mulleInitWithUTF8Characters:(char *) region.bytes
                                                              length:region.length];
      _MulleObjCPropertyListReaderConsumeCurrentUTF32Character( reader); // skip '"'
      return( s);
   }

   data = [[NSMutableData alloc] initWithLength:region.length];
   buf  = (char *) [data bytes];
   dst  = MulleUTF8StringUnescape( (char *) region.bytes, region.length, buf);
   [data setLength:dst - buf];

   s = [[reader->nsStringClass alloc] initWithData:data
                                          encoding:[reader stringEncoding]];
   [data release];

   _MulleObjCPropertyListReaderConsumeCurrentUTF32Character( reader);  // skip '"'
   return( s);
}


NSString   *
   _MulleObjCNewStringFromPropertyListWithReader( _MulleObjCPropertyListReader *reader)
{
   long  x;

   x = _MulleObjCPropertyListReaderCurrentUTF32Character( reader);
   if( x == '"')
      return( _MulleObjCNewStringParsedQuotedFromPropertyListWithReader( reader));
   return( _MulleObjCNewObjectParsedUnquotedFromPropertyListWithReader( reader));
}

@end
