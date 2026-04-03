#import "MulleObjCUnarchiver.h"
#import "import.h"


@interface MulleObjCStreamUnarchiver : MulleObjCUnarchiver < MulleObjCUnkeyedUnarchiver>
{
   NSData       *_streamData;
   size_t       _streamPos;
   NSUInteger   _newObjBase;
   NSUInteger   _newObjCount;
   NSUInteger   _nextObjHandle;
   NSUInteger   _nextClsHandle;
   NSUInteger   _nextSelHandle;
   NSUInteger   _nextBlobHandle;
}

- (instancetype) initWithStreamData:(NSData *) data;
- (id) decodeNextObject;

@end
