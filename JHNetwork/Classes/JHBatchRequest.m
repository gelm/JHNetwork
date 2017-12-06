

#import "JHBatchRequest.h"
#import "JHBatchRequestManager.h"
#import "JHBaseRequest.h"
#import "JHNetworkUtil.h"

@interface JHBatchRequest () <JHBaseRequestDelegate>

@property (nonatomic, strong) NSArray *requestArray;
@property (nonatomic, assign) NSInteger finishedRequestCount;

@end

@implementation JHBatchRequest

#pragma mark - LifeCycle

- (instancetype)initWithRequestArray:(NSArray<RSmartRequest *> *)requestArray enableAccessory:(BOOL)enableAccessory {
    self = [super init];
    if (self) {
        _requestArray = requestArray.copy;
        _enableAccessory = enableAccessory;
        _finishedRequestCount = 0;
    }
    return self;
}

- (void)dealloc {
    [self clearBatchRequest];
}

#pragma mark - SYBaseRequest Delegate

- (void)requestSuccess:(RSmartRequest *)request {
    self.finishedRequestCount++;
    if (self.finishedRequestCount == self.requestArray.count) {
        if ([self.delegate respondsToSelector:@selector(batchRequestSuccess:)]) {
            [self.delegate batchRequestSuccess:self];
        }
        if (self.successCompletionBlock) {
            self.successCompletionBlock(self);
        }
        [self batchRequestDidStop];
    }
}

- (void)requestFailure:(JHBaseRequest *)request error:(NSError *)error {
    for (JHBaseRequest *reqeust in self.requestArray) {
        [reqeust stop];
    }
    if ([self.delegate respondsToSelector:@selector(batchRequestFailure:)]) {
        [self.delegate batchRequestFailure:self];
    }
    if (self.failureCompletionBlock) {
        self.failureCompletionBlock(self);
    }
    [self batchRequestDidStop];
}

#pragma mark - Public method

- (void)start {
    if (self.finishedRequestCount > 0) {
        RSNetworkLog(@"Error! BatchRequest has already started.");
        return;
    }
    [self toggleAccessoriesStartCallBack];
    [[JHBatchRequestManager sharedInstance] addBatchRequest:self];
    for (JHBaseRequest *request in self.requestArray) {
        request.delegate = self;
        [request start];
    }
}

- (void)stop {
    [self clearBatchRequest];
    [self toggleAccessoriesStopCallBack];
    [[JHBatchRequestManager sharedInstance] removeBatchRequest:self];
}

- (void)startWithBlockSuccess:(void (^)(JHBatchRequest *))success failure:(void (^)(JHBatchRequest *))failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
    [self start];
}

- (void)clearCompletionBlock {
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

#pragma mark - Property method

- (NSMutableArray<id<RSBaseRequestAccessory>> *)accessoryArray {
    if (_accessoryArray == nil) {
        _accessoryArray = [NSMutableArray array];
    }
    return _accessoryArray;
}

#pragma mark - Private method

- (void)batchRequestDidStop {
    [self clearCompletionBlock];
    [self toggleAccessoriesStopCallBack];
    self.finishedRequestCount = 0;
    self.requestArray = nil;
    [[JHBatchRequestManager sharedInstance] removeBatchRequest:self];
}

- (void)clearBatchRequest {
    self.delegate = nil;
    for (JHBaseRequest *request in self.requestArray) {
        [request stop];
    }
    [self clearCompletionBlock];
}

@end

@implementation JHBatchRequest (RequestAccessory)

- (void)toggleAccessoriesStartCallBack {
    if (self.enableAccessory) {
        for (id<JHBaseRequestAccessory> accessory in self.accessoryArray) {
            if ([accessory respondsToSelector:@selector(requestStart:)]) {
                [accessory requestStart:self];
            }
        }
    }
}

- (void)toggleAccessoriesStopCallBack {
    if (self.enableAccessory) {
        for (id<JHBaseRequestAccessory> accessory in self.accessoryArray) {
            if ([accessory respondsToSelector:@selector(requestStop:)]) {
                [accessory requestStop:self];
            }
        }
    }
}

@end
