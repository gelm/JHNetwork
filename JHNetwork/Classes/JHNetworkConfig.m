

#import "JHNetworkConfig.h"

@implementation JHNetworkConfig

#pragma mark - LifeCycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _maxConcurrentOperationCount = 4;
        _securityPolicy = [AFSecurityPolicy defaultPolicy];
    }
    return self;
}

+ (JHNetworkConfig *)sharedInstance {
    static JHNetworkConfig *instance;
    static dispatch_once_t SYNetworkConfigToken;
    dispatch_once(&SYNetworkConfigToken, ^{
        instance = [[JHNetworkConfig alloc] init];
    });
    return instance;
}

@end
