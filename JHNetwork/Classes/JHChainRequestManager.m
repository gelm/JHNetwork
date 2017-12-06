//
//  JHChainRequestManager.m
//  JHNetwork
//
//  Created by 各连明 on 2017/11/27.
//  Copyright © 2017年 JiuHe. All rights reserved.
//

#import "JHChainRequestManager.h"
#import "JHChainRequest.h"

@interface JHChainRequestManager ()

@property (nonatomic, strong) NSMutableArray *requestArray;

@end

@implementation JHChainRequestManager

+ (JHChainRequestManager *)sharedInstance {
    static JHChainRequestManager *instance;
    static dispatch_once_t SYChainRequestManagerToken;
    dispatch_once(&SYChainRequestManagerToken, ^{
        instance = [[JHChainRequestManager alloc] init];
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

- (void)addChainRequest:(JHChainRequest *)chainRequest {
    @synchronized (self) {
        [self.requestArray addObject:chainRequest];
    }
}

- (void)removeChainRequest:(JHChainRequest *)chainRequest {
    @synchronized (self) {
        [self.requestArray removeObject:chainRequest];
    }
}

@end
