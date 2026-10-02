//
//  MulleObjCTokenProblem.m
//  MulleObjCRegexFoundation
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK. All rights reserved.
//
//  See MulleObjCTokenProblem.h for what a problem is and why it is a value.
//
#import "MulleObjCTokenProblem.h"

#import "import-private.h"


@implementation MulleObjCTokenProblem

- (instancetype) initWithKind:(MulleObjCTokenProblemKind) kind
                        count:(NSUInteger) count
{
   self = [super init];
   if( self)
   {
      _kind  = kind;
      _count = count;

      //
      // Derived and not passed in, so that the text and the number it mentions
      // cannot drift apart - a description that disagrees with its own count is
      // worse than no description.
      //
      switch( kind)
      {
      case MulleObjCTokenProblemUnrecognizedCharacter :
         _text = [[NSString stringWithFormat:@"%lu character(s) no rule could lex",
                                                      (unsigned long) count] copy];
         break;

      case MulleObjCTokenProblemUndeclaredStart :
         _text = [[NSString stringWithFormat:@"%lu token(s) starting on a character no rule declared",
                                                      (unsigned long) count] copy];
         break;

      //
      // Not reachable from the engine, which only makes the two kinds above. A
      // kind it does not know must still say something: a caller collecting
      // problems must not get an object whose -text is nil.
      //
      default :
         _text = [[NSString stringWithFormat:@"%lu problem(s) of unknown kind %ld",
                                                      (unsigned long) count,
                                                      (long) kind] copy];
         break;
      }
   }
   return( self);
}


+ (instancetype) problemWithKind:(MulleObjCTokenProblemKind) kind
                           count:(NSUInteger) count
{
   MulleObjCTokenProblem   *problem;

   problem = [self alloc];
   problem = [problem initWithKind:kind
                             count:count];
   problem = [problem autorelease];
   return( problem);
}


- (void) finalize
{
   [_text autorelease];
   _text = nil;

   [super finalize];
}

@end
