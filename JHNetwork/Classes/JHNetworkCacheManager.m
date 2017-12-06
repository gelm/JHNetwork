//
//  JHNetworkCacheManager.m
//  JHNetwork
//
//  Created by 各连明 on 2017/11/27.
//  Copyright © 2017年 JiuHe. All rights reserved.
//

#import "JHNetworkCacheManager.h"
#import "JHNetworkUtil.h"

@implementation JHNetworkCacheManager

+ (JHNetworkCacheManager *)sharedInstance {
    static JHNetworkCacheManager *instance;
    static dispatch_once_t SYNetworkCacheManagerToken;
    dispatch_once(&SYNetworkCacheManagerToken, ^{
        instance = [[JHNetworkCacheManager alloc] init];
    });
    return instance;
}

#pragma mrak - tool method

- (void)checkDirectory:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
}

- (void)createBaseDirectoryAtPath:(NSString *)path {
    __autoreleasing NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        NSLog(@"create cache directory failed, error = %@", error);
    } else {
        [JHNetworkUtil addDoNotBackupAttribute:path];
    }
}

- (NSString *)cacheBasePath {
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"JHLazyRequestCache"];
    
    [self checkDirectory:path];
    return path;
}


- (NSString *)cacheFilePath:(NSString *)cacheFileName {
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

- (void)saveJsonResponseToCacheFile:(id<NSCoding>)jsonResponse cacheFilePath:(NSString *)path{
    if (jsonResponse != nil) {
        if(![NSKeyedArchiver archiveRootObject:jsonResponse toFile:path]){
            NSLog(@"data cache failed!");
        }
        
    }
}

#pragma mark - Public method

- (id<NSCoding>)objectForKey:(NSString *)key {
    id<NSCoding> cacheObject;
    NSString *path = [self cacheFilePath:key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path isDirectory:nil] == YES) {
        cacheObject = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    }
    return cacheObject;
}

- (void)setObject:(id<NSCoding>)object forKey:(NSString *)key {
    [self saveJsonResponseToCacheFile:object cacheFilePath:[self cacheFilePath:key]];
}

- (void)removeObjectForKey:(NSString *)key {
    NSString *path = [self cacheFilePath:key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:path error:&error];
    if(error){
        NSLog(@"remove the cache file failed, error = %@",error);
    }
}

- (void)clearCache {
    NSString *path = [self cacheBasePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    [fileManager removeItemAtPath:path error:&error];
    if(error){
        NSLog(@"clear the cache directory failed, error = %@",error);
    }
}


@end
