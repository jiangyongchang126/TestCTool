//
//  ToolClass.h
//  llcb
//
//  Created by zjp on 2020/6/17.
//  Copyright © 2020 pp. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToolClass : NSObject

//手机号校验
+ (BOOL)validateContactNumber:(NSString *)mobileNum;
//邮箱校验
+ (BOOL)validateContactEmail:(NSString *)email;
//密码格式校验(6-20位，数字字母组合)
+ (BOOL)judgePassWordLegal:(NSString *)pwd;

// 字典转json字符串
+ (NSString *)dictToJSONString:(NSDictionary *)dict;

+ (NSString *)dictToRSAString:(NSDictionary *)dict;
+ (NSString *)strToRSAString:(NSString *)str;


+ (NSString *)dictionary2String:(NSDictionary *)dictionary;

+ (NSString *)getFriendlyDateString:(NSTimeInterval)timeInterval;

+ (NSString *)getFriendlyDateString:(NSTimeInterval)timeInterval
                    forConversation:(BOOL)isShort;

+ (BOOL)isValidatIP:(NSString *)ipAddress;

//+ (NSString *)conversationIdWithConversation:(JMSGConversation *)conversation;

+ (CGSize)stringSizeWithWidthString:(NSString *)string withWidthLimit:(CGFloat)width withFont:(UIFont *)font;

//判断是否为空  或者全为空字符
+ (BOOL)isEmpty:(NSString *)str;

//数组转字符串
+ (NSString *)arrayToJSONString:(NSArray *)array;

+ (void)addShadowToView:(UIView *)theView withColor:(UIColor *)theColor;

//1 平台财务(不需要IM)  2 项目经理（company）  3 财务(不需要IM)  4工长（company）  8 领队（company）  9 组长（worker）   10 工人（worker）  11 企业主体(不需要IM)
+ (NSString *)getUserName:(int)roleId withWorkerId:(NSString *)workerId;

//身份证号码校验
+ (BOOL)validateIDCardNumber:(NSString *)value;
+ (BOOL)judgeIdentityStringValid:(NSString *)identityString;


+ (UIViewController *)getCurrentVC;

+ (UIImage *)imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
+ (UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:(CGSize)newSize;

// 压缩图片，如果图片大于100kb，就循环压缩
+ (NSData *)compressionWithImage:(UIImage *)image;

+ (void)loginWithSuccessBlock:(void(^)(void))successBlock;

+ (BOOL)loginJidSuccess;

+ (void)createSingleConversationWithUserId:(NSString *)userId withVC:(UIViewController*)fatherVC;
+ (NSString *)getVerificationCode;
+ (NSString *)getCurrentYM;
+ (NSDictionary *)dictionaryForJsonData:(NSData *)jsonData;
+ (NSData *)compactFormatDataForDictionary:(NSDictionary *)dicJson;

+ (NSArray *)arrayForJsonData:(NSData *)jsonData;
+ (NSData *)compactFormatDataForArray:(NSArray *)arrJson;

+ (UIColor *)colorWithHexString:(NSString *)color;
@end

NS_ASSUME_NONNULL_END
