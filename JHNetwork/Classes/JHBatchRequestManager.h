

#import <Foundation/Foundation.h>

@class JHBatchRequest;

@interface JHBatchRequestManager : NSObject

+ (JHBatchRequestManager *)sharedInstance;

- (void)addBatchRequest:(JHBatchRequest *)batchRequest;
- (void)removeBatchRequest:(JHBatchRequest *)batchRequest;

@end
