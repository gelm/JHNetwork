//
//  JHChainRequestManager.h
//  JHNetwork
//
//  Created by 各连明 on 2017/11/27.
//  Copyright © 2017年 JiuHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JHChainRequest;

@interface JHChainRequestManager : NSObject

+ (JHChainRequestManager *)sharedInstance;

- (void)addChainRequest:(JHChainRequest *)chainRequest;
- (void)removeChainRequest:(JHChainRequest *)chainRequest;

@end
