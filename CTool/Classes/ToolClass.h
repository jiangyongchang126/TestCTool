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

@end

NS_ASSUME_NONNULL_END
