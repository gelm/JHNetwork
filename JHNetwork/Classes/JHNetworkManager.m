

#import "JHNetworkManager.h"
#import "JHNetworkUtil.h"
#import "JHNetworkConfig.h"
#import "JHNetworkCacheManager.h"
#import "JHBaseRequest.h"

#import <AFNetworking/AFNetworking.h>

@interface JHNetworkManager ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *requestIdentifierDictionary;
@property (nonatomic, strong) dispatch_queue_t requestProcessingQueue;

@end

@implementation JHNetworkManager

#pragma mark - Life Cycle

+ (JHNetworkManager *)sharedInstance {
    static JHNetworkManager *instance;
    static dispatch_once_t RSNetworkManagerToken;
    dispatch_once(&RSNetworkManagerToken, ^{
        instance = [[JHNetworkManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self manager];
        [self requestIdentifierDictionary];
    }
    return self;
}

#pragma mark - Public method

- (void)addRequest:(JHBaseRequest *)request {
    dispatch_async(self.requestProcessingQueue, ^{
        NSString *url = request.requestURLString;
        JHRequestMethod method = request.requestMethod;
        id parameters = request.requestParameter;
        //Request Serializer
        switch (request.requestSerializerType) {
                case JHRequestSerializerTypeHTTP: {
                    self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                    break;
                }
                case JHRequestSerializerTypeJSON: {
                    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
                    break;
                }
            default: {
                RSNetworkLog(@"Error, unsupport method type");
                break;
            }
        }
        self.manager.requestSerializer.cachePolicy = request.requestCachePolicy;
        self.manager.requestSerializer.timeoutInterval = request.requestTimeoutInterval;
        //HTTPHeaderFields
        NSDictionary *requestHeaderFieldDictionary = request.requestHeader;
        if (requestHeaderFieldDictionary) {
            for (NSString *key in requestHeaderFieldDictionary.allKeys) {
                NSString *value = requestHeaderFieldDictionary[key];
                [self.manager.requestSerializer setValue:value forHTTPHeaderField:key];
            }
        }
        
        NSURLRequest *customUrlRequest= [request buildURLRequest];
        if (customUrlRequest) {
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
            AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
            serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
            manager.responseSerializer = serializer;
            request.sessionDataTask = [manager dataTaskWithRequest:customUrlRequest uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
                
            } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
                [self handleRequest:request progress:downloadProgress];
            } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                if(error){
                    [self handleRequestFailureWithSessionDatatask:request.sessionDataTask error:error];
                }else{
                    [self handleRequestSuccessWithSessionDataTask:request.sessionDataTask responseObject:[NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil]];
                }
            }];
            [self addRequestIdentifierWithRequest:request];
            [request.sessionDataTask resume];
        }else{
            switch (method) {
                case JHRequestMethodGET: {
                    request.sessionDataTask = [self.manager GET:url
                                                     parameters:parameters
                                                       progress:^(NSProgress * _Nonnull downloadProgress) {
                                                           [self handleRequest:request progress:downloadProgress];
                                                       } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                           [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                                                       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                           [self handleRequestFailureWithSessionDatatask:task error:error];
                                                       }];
                    break;
                }
                case JHRequestMethodPOST: {
                    if (request.constructingBodyBlock) {
                        request.sessionDataTask = [self.manager POST:url
                                                          parameters:parameters
                                           constructingBodyWithBlock:request.constructingBodyBlock
                                                            progress:^(NSProgress * _Nonnull uploadProgress) {
                                                                [self handleRequest:request progress:uploadProgress];
                                                            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                                                            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                [self handleRequestFailureWithSessionDatatask:task error:error];
                                                            }];
                    } else {
                        request.sessionDataTask = [self.manager POST:url
                                                          parameters:parameters
                                                            progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                [self handleRequest:request progress:downloadProgress];
                                                            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                                [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                                                            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                                [self handleRequestFailureWithSessionDatatask:task error:error];
                                                            }];
                    }
                    break;
                }
                case JHRequestMethodHEAD: {
                    request.sessionDataTask = [self.manager HEAD:url
                                                      parameters:parameters
                                                         success:^(NSURLSessionDataTask * _Nonnull task) {
                                                             [self handleRequestSuccessWithSessionDataTask:task responseObject:nil];
                                                         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                             [self handleRequestFailureWithSessionDatatask:task error:error];
                                                         }];
                    break;
                }
                case JHRequestMethodPUT: {
                    request.sessionDataTask = [self.manager PUT:url
                                                     parameters:parameters
                                                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                            [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                                                        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                            [self handleRequestFailureWithSessionDatatask:task error:error];
                                                        }];
                    break;
                }
                case JHRequestMethodDELETE: {
                    request.sessionDataTask = [self.manager DELETE:url
                                                        parameters:parameters
                                                           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                               [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                                                           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                               [self handleRequestFailureWithSessionDatatask:task error:error];
                                                           }];
                    break;
                }
                case JHRequestMethodPATCH: {
                    request.sessionDataTask = [self.manager PATCH:url
                                                       parameters:parameters
                                                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                                              [self handleRequestSuccessWithSessionDataTask:task responseObject:responseObject];
                                                          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                              [self handleRequestFailureWithSessionDatatask:task error:error];
                                                          }];
                    break;
                }
                default: {
                    RSNetworkLog(@"Error, unsupport method type");
                    break;
                }
            }
            [self addRequestIdentifierWithRequest:request];
        }
        
    });
}

- (void)removeRequest:(JHBaseRequest *)request completion:(void (^)(void))completion {
    dispatch_async(self.requestProcessingQueue, ^{
        [request.sessionDataTask cancel];
        [self removeRequestIdentifierWithRequest:request];
        completion?completion():nil;
    });
}

- (void)removeAllRequest {
    NSDictionary *requestIdentifierDictionary = self.requestIdentifierDictionary.copy;
    for (NSString *key in requestIdentifierDictionary.allValues) {
        JHBaseRequest *request = self.requestIdentifierDictionary[key];
        [request.sessionDataTask cancel];
        [self.requestIdentifierDictionary removeObjectForKey:key];
    }
}

#pragma mark - Private method

- (BOOL)isValidResultWithRequest:(JHBaseRequest *)request {
    BOOL result = YES;
    if (request.jsonObjectValidator != nil) {
        result = [JHNetworkUtil isValidateJSONObject:request.responseObject
                             withJSONObjectValidator:request.jsonObjectValidator];
    }
    return result;
}

- (void)handleRequest:(JHBaseRequest *)request progress:(NSProgress *)progress {
    if ([request.delegate respondsToSelector:@selector(requestProgress:)]) {
        [request.delegate requestProgress:progress];
    }
    if (request.progressBlock) {
        request.progressBlock(progress);
    }
}

- (void)handleRequestSuccessWithSessionDataTask:(NSURLSessionDataTask *)sessionDataTask responseObject:(id)responseObject {
    NSString *key = @(sessionDataTask.taskIdentifier).stringValue;
    JHBaseRequest *request = self.requestIdentifierDictionary[key];
    request.responseData = responseObject;
    if (request) {
        if ([self isValidResultWithRequest:request]) {
            if (request.enableCache) {
                NSString *cacheKey = [JHNetworkUtil cacheKeyWithRequest:request];
                [[JHNetworkCacheManager sharedInstance] setObject:request.responseData forKey:cacheKey];
            }
            if ([request.delegate respondsToSelector:@selector(requestSuccess:)]) {
                [request.delegate requestSuccess:request];
            }
            if (request.successBlock) {
                request.successBlock(request);
            }
            [request toggleAccessoriesStopCallBack];
        } else {
            RSNetworkLog(@"Request %@ failed, status code = %@", NSStringFromClass([request class]), @(request.responseStatusCode));
            if ([request.delegate respondsToSelector:@selector(requestFailure:error:)]) {
                [request.delegate requestFailure:request error:nil];
            }
            if (request.failureBlock) {
                request.failureBlock(request, nil);
            }
            [request toggleAccessoriesStopCallBack];
        }
    }
    [request clearCompletionBlock];
    [self removeRequestIdentifierWithRequest:request];
}

- (void)handleRequestFailureWithSessionDatatask:(NSURLSessionDataTask *)sessionDataTask error:(NSError *)error {
    NSString *key = @(sessionDataTask.taskIdentifier).stringValue;
    JHBaseRequest *request = self.requestIdentifierDictionary[key];
    request.responseData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (request) {
        if ([request.delegate respondsToSelector:@selector(requestFailure:error:)]) {
            [request.delegate requestFailure:request error:error];
        }
        if (request.failureBlock) {
            request.failureBlock(request, error);
        }
        [request toggleAccessoriesStopCallBack];
    }
    [request clearCompletionBlock];
    [self removeRequestIdentifierWithRequest:request];
}

- (void)addRequestIdentifierWithRequest:(JHBaseRequest *)request {
    if (request.sessionDataTask != nil) {
        NSString *key = @(request.sessionDataTask.taskIdentifier).stringValue;
        @synchronized (self) {
            [self.requestIdentifierDictionary setObject:request forKey:key];
        }
    }
    RSNetworkLog(@"Add request: %@", NSStringFromClass([request class]));
}

- (void)removeRequestIdentifierWithRequest:(JHBaseRequest *)request {
    NSString *key = @(request.sessionDataTask.taskIdentifier).stringValue;
    @synchronized (self) {
        [self.requestIdentifierDictionary removeObjectForKey:key];
    }
    RSNetworkLog(@"Request queue size = %@", @(self.requestIdentifierDictionary.count));
}

#pragma mark - Property method

- (AFHTTPSessionManager *)manager {
    if (_manager == nil) {
        JHNetworkConfig *config = [JHNetworkConfig sharedInstance];
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.securityPolicy = config.securityPolicy;
        _manager.operationQueue.maxConcurrentOperationCount = config.maxConcurrentOperationCount;
    }
    return _manager;
}

- (NSMutableDictionary *)requestIdentifierDictionary {
    if (_requestIdentifierDictionary == nil) {
        _requestIdentifierDictionary = [NSMutableDictionary dictionary];
    }
    return _requestIdentifierDictionary;
}

- (dispatch_queue_t)requestProcessingQueue {
    if (_requestProcessingQueue == nil) {
        _requestProcessingQueue = dispatch_queue_create("net.sunnyyoung.synetwork.request.processing", DISPATCH_QUEUE_SERIAL);
    }
    return _requestProcessingQueue;
}

@end
