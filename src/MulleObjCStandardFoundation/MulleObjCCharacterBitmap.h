//
//  MulleObjCCharacterBitmap.h
//  MulleObjCStandardFoundation
//
//  Copyright (c) 2019 Nat! - Mulle kybernetiK.
//  Copyright (c) 2019 Codeon GmbH.
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


@class NSString;
@class NSData;

//
// there are no planes where everything is 0
// each plane is 65536 bits
//
struct MulleObjCCharacterBitmap
{
   uint32_t   *planes[ 0x11];
};



enum MulleObjCCharacterBitmapLogicOpcode
{
   MulleObjCCharacterBitmapAND  = 0,
   MulleObjCCharacterBitmapOR   = 1,
   MulleObjCCharacterBitmapNAND = 2,
   MulleObjCCharacterBitmapNOR  = 3
};

// -1: failed
int  MulleObjCCharacterBitmapInitWithBitmapRepresentation( struct MulleObjCCharacterBitmap *p,
                                                           NSData *data,
                                                           struct mulle_allocator *allocator);
void  MulleObjCCharacterBitmapInitWithPlanes( struct MulleObjCCharacterBitmap *p,
                                              uint32_t **planes,
                                              unsigned int n_planes);
void   MulleObjCCharacterBitmapFreePlanes( struct MulleObjCCharacterBitmap *p,
                                           struct mulle_allocator *allocator);


void   MulleObjCCharacterBitmapSetBitsInRange( struct MulleObjCCharacterBitmap *p,
                                               NSRange range,
                                               struct mulle_allocator *allocator);

void   MulleObjCCharacterBitmapClearBitsInRange( struct MulleObjCCharacterBitmap *p,
                                                 NSRange range,
                                                 struct mulle_allocator *allocator);

int   MulleObjCCharacterBitmapGetBit( struct MulleObjCCharacterBitmap *p,
                                      unsigned int c);

void   MulleObjCCharacterBitmapSetBitsWithString( struct MulleObjCCharacterBitmap *p,
                                                  NSString *s,
                                                  struct mulle_allocator *allocator);
void   MulleObjCCharacterBitmapClearBitsWithString( struct MulleObjCCharacterBitmap *p,
                                                    NSString *s,
                                                    struct mulle_allocator *allocator);


void   MulleObjCCharacterBitmapInvert( struct MulleObjCCharacterBitmap *p,
                                       struct mulle_allocator *allocator);

void   MulleObjCCharacterBitmapLogicOperation( struct MulleObjCCharacterBitmap *p,
                                               struct MulleObjCCharacterBitmap *q,
                                               enum MulleObjCCharacterBitmapLogicOpcode opcode,
                                               struct mulle_allocator *allocator);


static inline void  _mulle_uint32_bitmap_set( uint32_t *bitmap, uint16_t d)
{
   unsigned int   index;
   unsigned int   bindex;
   uint32_t       bit;

   index           = d >> 5;
   bindex          = d & 0x1F;
   bit             = (1U << bindex);
   bitmap[ index] |= bit;
}


static inline void  _mulle_uint32_bitmap_clr( uint32_t *bitmap, uint16_t d)
{
   unsigned int   index;
   unsigned int   bindex;
   uint32_t       bit;

   index           = d >> 5;
   bindex          = d & 0x1F;
   bit             = (1U << bindex);
   bitmap[ index] &= ~bit;
}


static inline int  _mulle_uint32_bitmap_get( uint32_t *bitmap, uint16_t d)
{
   unsigned int   index;
   unsigned int   bindex;
   uint32_t       bit;

   index  = d >> 5;
   bindex = d & 0x1F;
   bit    = (1U << bindex);
   bit    = bitmap[ index] & bit;

   return( bit ? 1 : 0);
}
