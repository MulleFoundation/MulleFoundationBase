//
//  NSUUID.m
//  MulleObjCUUIDFoundation
//
//  Copyright (c) 2022 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistribution of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistribution in binary form must reproduce the above copyright notice,
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
#import "NSUUID.h"

#import "import-private.h"


static int uuid4_init(void);
static void uuid4_generate(char *dst);

// this must be included like this for clib inclusion on MulleFoundationBase
// to find it fix it in CMakeLists.txt
#include "uuid4.c"



@implementation NSUUID

static struct
{
   mulle_thread_mutex_t   _lock;
} Self;


+ (void) load
{
   MULLE_C_UNUSED( uuid4_generate);

   mulle_thread_mutex_init( &Self._lock);
}


+ (void) done
{
   mulle_thread_mutex_done( &Self._lock);
}


void   MulleGenerateUUIDBytes( unsigned char bytes[ 16])
{
   union { unsigned char b[16]; uint64_t word[2]; } s;

   mulle_thread_mutex_do( Self._lock)
   {
      /* we only want to hit urandom or something else, when really needed
       * not at +load
       */
      if( ! seed[ 0] && ! seed[ 1])
         if( uuid4_init() == UUID4_EFAILURE)
            abort();

      /* get random */
      s.word[ 0] = xorshift128plus(seed);
      s.word[ 1] = xorshift128plus(seed);

      memcpy( bytes, &s.word[ 0], 16);

      MulleUUIDBytesZeroVersioningBits( bytes);
   }
}


//                                                         1 1 1 1 1 1
//                                 0 1 2 3  4 5  6 7  8 9  0 1 2 3 4 5
static const char   template[] = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx";

void   MulleUUIDBytesToUTF8String( unsigned char bytes[ 16], char output[ 37])
{
   static const char   chars[] = "0123456789abcdef";
   char  *p;
   char  *dst;
   int   i, n;

   dst = output;
   i   = 0;
   for( p = (char *) template; *p; p++)
   {
      n = bytes[ i >> 1];
      n = (i & 1) ? (n & 0xf) : (n >> 4);
      switch (*p)
      {
      case '4' : *dst = *p;                   i++; break;
      case 'x' : *dst = chars[n];             i++; break;
      case 'y' : *dst = chars[(n & 0x3) + 8]; i++; break;
      default  : *dst = *p;
      }
      dst++;
   }
   *dst++ = '\0';

   assert( dst == &output[ 37]);
   assert( i == 32); // 32 nybbles only used
}


static char  tonybble( char c)
{
   if( c >= '0' && c <= '9')
      return( c - '0');
   if( c >= 'a' && c <= 'f')
      return( c - 'a' + 10);
   if( c >= 'A' && c <= 'F')
      return( c - 'A' + 10);
   return( -1);
}


int   MulleUTF8StringToUUIDBytes( char input[ 37], unsigned char bytes[ 16])
{
   static const char template[] = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx";
   char              *p;
   char              *src;
   int               i;
   char              nybbles[ 32];

   src = input;
   i   = 0;

   for( p = (char *) template; *p; p++)
   {
      switch (*p)
      {
      default  :
         if( *p != *src++)
            goto fail;
         break;

      case '4' :
         if( *p != *src++)
            goto fail;
         nybbles[ i] = 0x0;
         ++i;
         break;

      case 'x'  :
         nybbles[ i] = tonybble( *src++);
         if( nybbles[ i] < 0)
            goto fail;
         i++;
         break;

      case 'y'  :
         nybbles[ i] = tonybble( *src++);
         nybbles[ i] = nybbles[ i] - 8;
         if( nybbles[ i] < 0 || nybbles[ i] > 0x3)
            goto fail;
         i++;
         break;
      }
   }

   // compose nybbles as bytes
   for( i = 0; i < 16; i++)
      bytes[ i] = (nybbles[ i * 2] << 4) | nybbles[ i * 2 + 1];
   return( 0);

fail:
   memset( bytes, 0, 16);
   return( -1);
}


+ (instancetype) alloc
{
   return( NSAllocateObject( self, 0, NULL));
}


- (instancetype) init
{
   MulleGenerateUUIDBytes( _bytes);
   return( self);
}


+ (instancetype) UUID
{
   return( [[self new] autorelease]);
}


- (instancetype) initWithUUIDBytes:(unsigned char *) bytes
{
   if( (bytes[ 6] & 0xF0) || (bytes[ 8] & 0xC0))
   {
      fprintf( stderr, "UUID bytes contain bits in non-representable positions\n");
      [self release];
      return( nil);
   }

   memcpy( &_bytes, bytes, 16);
   return( self);
}


- (void) getUUIDBytes:(unsigned char *) bytes
{
   memcpy( bytes, _bytes, 16);
}


- (instancetype) initWithUUIDString:(NSString *) s
{
   char   buf[ 37];

   [s mulleGetUTF8Characters:buf
                   maxLength:37];
   if( MulleUTF8StringToUUIDBytes( buf, _bytes) < 0)
   {
      [self release];
      return( nil);
   }

   return( self);
}


- (NSString *) UUIDString
{
   char   string[ 37];

   MulleUUIDBytesToUTF8String( _bytes, string);
   return( [NSString stringWithUTF8String:string]);
}


- (NSString *) description
{
   return( [self UUIDString]);
}


- (NSUInteger) length
{
   return( MulleUUIDBytesLength);
}


- (void *) bytes
{
   return( _bytes);
}

@end
