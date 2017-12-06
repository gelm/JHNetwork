

#import <Foundation/Foundation.h>

@class JHBaseRequest;
@class JHChainRequest;
@protocol RSBaseRequestAccessory;

@protocol RSChainRequestDelegate <NSObject>

- (void)chainRequestSuccess:(JHChainRequest *)chainRequest;
- (void)chainRequest:(JHChainRequest *)chainRequest failure:(JHBaseRequest *)request;

@end

typedef void (^RSChainRequestCallback)(JHChainRequest *chainRequest, __kindof JHBaseRequest *request);

@interface JHChainRequest : NSObject

@property (nonatomic, weak) id <RSChainRequestDelegate> delegate;
@property (nonatomic, strong, readonly) NSMutableArray *requestArray;
@property (nonatomic, assign, readonly) BOOL enableAccessory;
@property (nonatomic, strong) NSMutableArray<id<RSBaseRequestAccessory>> *accessoryArray;

- (instancetype)initWithEnableAccessory:(BOOL)enableAccessory;

- (void)addRequest:(JHBaseRequest *)request callback:(RSChainRequestCallback)callback;
- (void)start;
- (void)stop;

@end

@interface JHChainRequest (RequestAccessory)

- (void)toggleAccessoriesStartCallBack;
- (void)toggleAccessoriesStopCallBack;

@end
