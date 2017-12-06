

#import "JHBatchRequestManager.h"

@interface JHBatchRequestManager ()

@property (nonatomic, strong) NSMutableArray *requestArray;

@end

@implementation JHBatchRequestManager

#pragma mark - LifeCycle

+ (JHBatchRequestManager *)sharedInstance {
    static JHBatchRequestManager *instance;
    static dispatch_once_t SYBatchRequestManagerToken;
    dispatch_once(&SYBatchRequestManagerToken, ^{
        instance = [[JHBatchRequestManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addBatchRequest:(JHBatchRequest *)batchRequest {
    @synchronized (self) {
        [_requestArray addObject:batchRequest];
    }
}

- (void)removeBatchRequest:(JHBatchRequest *)batchRequest {
    @synchronized (self) {
        [_requestArray removeObject:batchRequest];
    }
}

@end
