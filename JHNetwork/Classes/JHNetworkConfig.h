

#import <Foundation/Foundation.h>
#import <AFNetworking/AFSecurityPolicy.h>

@interface JHNetworkConfig : NSObject

@property (nonatomic, copy) NSString *baseURL;
@property (nonatomic, assign) NSUInteger maxConcurrentOperationCount;
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

+ (JHNetworkConfig *)sharedInstance;

@end
