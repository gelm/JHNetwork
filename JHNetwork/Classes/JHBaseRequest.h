//
//  JHBaseRequest.h
//  JHNetwork
//
//  Created by 各连明 on 2017/11/27.
//  Copyright © 2017年 JiuHe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFURLRequestSerialization.h>

@class JHBaseRequest;

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^JHRequestSuccessBlock)(__kindof JHBaseRequest *request);
typedef void (^JHRequestFailureBlock)(__kindof JHBaseRequest *request, NSError *error);
typedef void (^JHRequestProgressBlock)(NSProgress *progress);

typedef NS_ENUM(NSInteger , JHRequestMethod) {
    JHRequestMethodGET = 0,
    JHRequestMethodPOST,
    JHRequestMethodHEAD,
    JHRequestMethodPUT,
    JHRequestMethodDELETE,
    JHRequestMethodPATCH
};

typedef NS_ENUM(NSUInteger, JHRequestSerializerType) {
    JHRequestSerializerTypeHTTP = 0,
    JHRequestSerializerTypeJSON
};

@protocol JHBaseRequestDelegate <NSObject>

@optional
- (void)requestSuccess:(JHBaseRequest *)request;
- (void)requestFailure:(JHBaseRequest *)request error:(NSError *)error;
- (void)requestProgress:(NSProgress *)progress;

@end

@protocol JHBaseRequestAccessory <NSObject>

@optional
- (void)requestStart:(id)request;
- (void)requestStop:(id)request;

@end

@interface JHBaseRequest : NSObject

@property (nonatomic, weak) id <JHBaseRequestDelegate> delegate;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;
@property (nonatomic, strong) NSMutableArray<id<JHBaseRequestAccessory>> *accessoryArray;
@property (nonatomic, copy) JHRequestSuccessBlock successBlock;
@property (nonatomic, copy) JHRequestFailureBlock failureBlock;
@property (nonatomic, copy) JHRequestProgressBlock progressBlock;

//Response
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong, readonly) NSString *requestURLString;
@property (nonatomic, assign, readonly) NSInteger responseStatusCode;
@property (nonatomic, strong, readonly) NSDictionary *responseHeader;
@property (nonatomic, strong, readonly) NSString *responseString;
@property (nonatomic, strong, readonly) id responseObject;

//Cache
@property (nonatomic, strong, readonly) NSData *cacheData;
@property (nonatomic, strong, readonly) id cacheJSONObject;

//overwrite
- (BOOL)enableCache;
- (BOOL)enableAccessory;
- (JHRequestMethod)requestMethod;
- (JHRequestSerializerType)requestSerializerType;
- (NSURLRequestCachePolicy)requestCachePolicy;
- (NSString *)baseURL;
- (NSString *)requestUrl;
- (id)requestParameter;
- (id)cacheSensitiveData;
- (NSTimeInterval)requestTimeoutInterval;
- (id)jsonObjectValidator;
- (NSDictionary<NSString *, NSString *> *)requestHeader;
- (AFConstructingBlock)constructingBodyBlock;

- (NSURLRequest *)buildURLRequest;

//call
- (void)start;
- (void)stop;
- (void)startRequestWithHandleCompletionSuccess:(JHRequestSuccessBlock)success
                                        failure:(JHRequestFailureBlock)failure;
- (void)startRequestWithHandleProgress:(JHRequestProgressBlock)progress
                               success:(JHRequestSuccessBlock)success
                               failure:(JHRequestFailureBlock)failure;

- (void)clearCompletionBlock;

@end

@interface JHBaseRequest (RequestAccessory)

- (void)toggleAccessoriesStartCallBack;
- (void)toggleAccessoriesStopCallBack;

@end
