

#import <Foundation/Foundation.h>

@class JHBaseRequest;

@interface JHNetworkManager : NSObject

+ (JHNetworkManager *)sharedInstance;

- (void)addRequest:(JHBaseRequest *)request;
- (void)removeRequest:(JHBaseRequest *)request completion:(void (^)(void))completion;
- (void)removeAllRequest;

@end
