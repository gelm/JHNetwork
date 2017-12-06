//
//  JHBaseRequest.m
//  JHNetwork
//
//  Created by 各连明 on 2017/11/27.
//  Copyright © 2017年 JiuHe. All rights reserved.
//

#import "JHBaseRequest.h"
#import "JHNetworkUtil.h"
#import "JHNetworkConfig.h"
#import "JHNetworkManager.h"
#import "JHNetworkCacheManager.h"

@implementation JHBaseRequest


#pragma mark - Default Config

- (BOOL)enableCache {
    return NO;
}

- (BOOL)enableAccessory {
    return NO;
}

- (JHRequestMethod)requestMethod {
    return JHRequestMethodGET;
}

- (JHRequestSerializerType)requestSerializerType {
    return JHRequestSerializerTypeHTTP;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestUseProtocolCachePolicy;
}

- (NSString *)baseURL {
    return @"";
}

- (NSString *)requestUrl {
    return @"";
}

- (id)requestParameter {
    return nil;
}

- (id)cacheSensitiveData {
    return nil;
}

- (NSTimeInterval)requestTimeoutInterval {
    return 20.0;
}

- (id)jsonObjectValidator {
    return nil;
}

- (NSDictionary<NSString *, NSString *> *)requestHeader {
    return nil;
}

- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

- (NSURLRequest *)buildURLRequest{
    return nil;
}

#pragma mark - Public method

- (void)start {
    [self toggleAccessoriesStartCallBack];
    [[JHNetworkManager sharedInstance] addRequest:self];
}

- (void)stop {
    self.delegate = nil;
    [[JHNetworkManager sharedInstance] removeRequest:self completion:^{
        [self toggleAccessoriesStopCallBack];
    }];
}

- (void)startRequestWithHandleCompletionSuccess:(JHRequestSuccessBlock)success
                                        failure:(JHRequestFailureBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
    [self start];
}

- (void)startRequestWithHandleProgress:(JHRequestProgressBlock)progress
                               success:(JHRequestSuccessBlock)success
                               failure:(JHRequestFailureBlock)failure {
    self.progressBlock = progress;
    self.successBlock = success;
    self.failureBlock = failure;
    [self start];
}

- (void)clearCompletionBlock {
    self.progressBlock = nil;
    self.successBlock = nil;
    self.failureBlock = nil;
}

#pragma mark - Property method

- (NSMutableArray<id<JHBaseRequestAccessory>> *)accessoryArray {
    if (_accessoryArray == nil) {
        _accessoryArray = [NSMutableArray array];
    }
    return _accessoryArray;
}

- (NSString *)requestURLString {
    NSString *baseURL = nil;
    if (self.baseURL.length > 0) {
        baseURL = self.baseURL;
    } else {
        baseURL = [JHNetworkConfig sharedInstance].baseURL;
    }
    NSLog(@"网络请求url-------->%@",[NSString stringWithFormat:@"%@%@", baseURL, self.requestUrl]);
    return [NSString stringWithFormat:@"%@%@", baseURL, self.requestUrl];
}

- (NSInteger)responseStatusCode {
    return ((NSHTTPURLResponse *)self.sessionDataTask.response).statusCode;
}

- (NSDictionary *)responseHeader {
    return ((NSHTTPURLResponse *)self.sessionDataTask.response).allHeaderFields;
}

- (NSString *)responseString {
    if (self.responseData == nil) {
        return nil;
    }
    return [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
}

- (id)responseObject {
    if (self.responseData == nil) {
        return nil;
    }
    NSError *error = nil;
    id responseJSONObject = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        RSNetworkLog(@"%@", error.localizedDescription);
        return nil;
    } else {
        return responseJSONObject;
    }
}

- (NSData *)cacheData {
    NSString *cacheKey = [JHNetworkUtil cacheKeyWithRequest:self];
    return (NSData *)[[JHNetworkCacheManager sharedInstance] objectForKey:cacheKey];
}

- (id)cacheJSONObject {
    if (self.cacheData == nil) {
        return nil;
    }
    NSError *error = nil;
    id cacheJSONObject = [NSJSONSerialization JSONObjectWithData:self.cacheData options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        RSNetworkLog(@"%@", error.localizedDescription);
        return nil;
    } else {
        return cacheJSONObject;
    }
}


@end

@implementation JHBaseRequest (RequestAccessory)

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
