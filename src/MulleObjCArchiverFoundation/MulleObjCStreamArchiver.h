#import "MulleObjCArchiver.h"
#import "import.h"


struct MulleObjCStreamMemo
{
   unsigned int   n_objects;
   unsigned int   n_classes;
   unsigned int   n_selectors;
   unsigned int   n_blobs;
   size_t         buffer_offset;
};


@interface MulleObjCStreamArchiver : MulleObjCArchiver < MulleObjCUnkeyedArchiver>
{
   struct MulleObjCStreamMemo   _memo;
   NSMutableData                *_output;
}

- (instancetype) init;

// simple API (begin+encode+commit in one)
- (void) encodeRootObject:(id) obj;
- (void) forgetObject:(id) obj;

// frame API for producer/consumer with frame dropping
- (void) beginFrame;
- (void) encodeFrameObject:(id) obj;
- (NSData *) commitFrame;    // returns the new chunk, appended to streamData
- (void) discardFrame;       // rolls back tables + buffer to pre-beginFrame state

- (NSData *) streamData;

@end
