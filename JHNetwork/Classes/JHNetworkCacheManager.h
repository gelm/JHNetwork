//
//  JHNetworkCacheManager.h
//  JHNetwork
//
//  Created by 各连明 on 2017/11/27.
//  Copyright © 2017年 JiuHe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JHNetworkCacheManager : NSObject

+ (JHNetworkCacheManager *)sharedInstance;

- (id<NSCoding>)objectForKey:(NSString *)key;
- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;

- (void)clearCache;

@end
