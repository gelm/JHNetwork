

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT void RSNetworkLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@class JHBaseRequest;

@interface JHNetworkUtil : NSObject

+ (BOOL)isValidateJSONObject:(id)jsonObject withJSONObjectValidator:(id)jsonObjectValidator;
+ (NSString *)cacheKeyWithRequest:(JHBaseRequest *)request;
+ (void)addDoNotBackupAttribute:(NSString *)path;

@end
