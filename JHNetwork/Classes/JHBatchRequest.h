

#import <Foundation/Foundation.h>

@class RSmartRequest;
@class JHBatchRequest;
@protocol RSBaseRequestAccessory;

@protocol RSBatchRequestDelegate <NSObject>

- (void)batchRequestSuccess:(JHBatchRequest *)batchRequest;
- (void)batchRequestFailure:(JHBatchRequest *)batchRequest;

@end

@interface JHBatchRequest : NSObject

@property (nonatomic, weak) id <RSBatchRequestDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray *requestArray;
@property (nonatomic, assign, readonly) BOOL enableAccessory;
@property (nonatomic, strong) NSMutableArray<id<RSBaseRequestAccessory>> *accessoryArray;
@property (nonatomic, copy) void (^successCompletionBlock)(JHBatchRequest *request);
@property (nonatomic, copy) void (^failureCompletionBlock)(JHBatchRequest *request);

- (instancetype)initWithRequestArray:(NSArray<RSmartRequest *> *)requestArray enableAccessory:(BOOL)enableAccessory;

- (void)start;
- (void)stop;
- (void)startWithBlockSuccess:(void (^)(JHBatchRequest *batchRequest))success
                      failure:(void (^)(JHBatchRequest *batchRequest))failure;

- (void)clearCompletionBlock;

@end

@interface JHBatchRequest (RequestAccessory)

- (void)toggleAccessoriesStartCallBack;
- (void)toggleAccessoriesStopCallBack;

@end
