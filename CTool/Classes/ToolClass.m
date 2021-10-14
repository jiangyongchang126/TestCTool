//
//  ToolClass.m
//  llcb
//
//  Created by zjp on 2020/6/17.
//  Copyright © 2020 pp. All rights reserved.
//


static NSString * const FORMAT_PAST_SHORT = @"yyyy/MM/dd";
static NSString * const FORMAT_PAST_TIME = @"ahh:mm";
static NSString * const FORMAT_THIS_WEEK = @"eee ahh:mm";
static NSString * const FORMAT_THIS_WEEK_SHORT = @"eee";
static NSString * const FORMAT_YESTERDAY = @"ahh:mm";
static NSString * const FORMAT_TODAY = @"ahh:mm";

#import "ToolClass.h"
#import "RSA.h"
#import "AES.h"
#import "sys/utsname.h"
#import "UIImage+Resize.h"
#import "NSDate+Utilities.h"
#import "NTESSessionViewController.h"

@implementation ToolClass

+ (BOOL)validateContactNumber:(NSString *)mobileNum {
    if (mobileNum.length != 11) {
          return NO;
      } else {
          NSString *phoneRegex = @"1[3456789]([0-9]){9}";
          NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
          BOOL isMatch = [phoneTest evaluateWithObject:mobileNum];
          if (isMatch) {

              return YES;

          } else {

              return NO;

          }
      }
}

+ (BOOL)validateContactEmail:(NSString *)email {
    if (email.length == 0) {
        return NO;
    }
    
    NSString *expression = [NSString stringWithFormat:@"^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$"];
    NSError *error = NULL;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:expression
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:email
                                                    options:0
                                                      range:NSMakeRange(0,[email length])];
    if (!match) {
        return NO;
    }
    return YES;
}

+ (BOOL)judgePassWordLegal:(NSString*)pwd{
    BOOL result =false;
   if(pwd.length >=6){
       NSString * regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,12}$";
       NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
       result = [pred evaluateWithObject:pwd];
   }
    return result;
}

+ (NSString *)dictToJSONString:(NSDictionary *)dict{
    
    NSError *error;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *jsonString;
    
    if (!jsonData) {
        
        NSLog(@"%@",error);
        
    }else{
        
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
//    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    
//    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}

+ (NSString *)dictToRSAString:(NSDictionary *)dict{
    
    NSString *strRSA = [RSA encryptString:[self dictToJSONString:dict] publicKey:@"MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgGj8WNUSzCn0rHqfIXk9XPdJp60uJnM+mVZVxY1lZmUCVA7t3eJZ0R0z1hUHkVb51eryDZcsz0QLSav3cmQv00ullK188aOs2SXZe6rcQf6XmOsVBqgADkrN+WePZJmb5Fr0NUkQ/sr7+R71cDZ87Y9QKm998BFOiWoEGxWWvDsTAgMBAAE="];
    return strRSA;
}

+ (NSString *)strToRSAString:(NSString *)str {
    NSString *strRSA = [RSA encryptString:str publicKey:@"MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgGj8WNUSzCn0rHqfIXk9XPdJp60uJnM+mVZVxY1lZmUCVA7t3eJZ0R0z1hUHkVb51eryDZcsz0QLSav3cmQv00ullK188aOs2SXZe6rcQf6XmOsVBqgADkrN+WePZJmb5Fr0NUkQ/sr7+R71cDZ87Y9QKm998BFOiWoEGxWWvDsTAgMBAAE="];
    return strRSA;
}


+ (NSString *)getFriendlyDateString:(NSTimeInterval)timeInterval {
  return [ToolClass getFriendlyDateString:timeInterval forConversation:NO];
}

/**
下午11:56 （是今天的）
会话：同样以上字符 - 下午11:56

昨天 上午10:22 （昨天的）
会话：只显示 - 昨天

星期二 上午08:21 （今天昨天之前的一周显示星期）
会话：只显示 - 星期二

2015年1月22日 上午11:58 （一周之前显示具体的日期了）
会话：显示 - 2015/04/18
*/
//设置格式 年yyyy 月 MM 日dd 小时hh(HH) 分钟 mm 秒 ss MMM单月 eee周几 eeee星期几 a上午下午
+ (NSString *)getFriendlyDateString:(NSTimeInterval)timeInterval
                    forConversation:(BOOL)isShort {
    //转为现在时间
    NSDate* theDate = [NSDate dateWithTimeIntervalSince1970:timeInterval/1000];

    NSString *output = nil;

  NSTimeInterval theDiff = -theDate.timeIntervalSinceNow;

  //上述时间差输出不同信息
  if (theDiff < 60) {
    output = @"刚刚";

  } else if (theDiff < 60 * 60) {
    int minute = (int) (theDiff / 60);
    output = [NSString stringWithFormat:@"%d分钟前", minute];

  } else {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
    [formatter setLocale:locale];

    BOOL isTodayYesterday = NO;
    BOOL isPastLong = NO;

    if ([theDate isToday]) {
      [formatter setDateFormat:FORMAT_TODAY];
    } else if ([theDate isYesterday]) {
      [formatter setDateFormat:FORMAT_YESTERDAY];
      isTodayYesterday = YES;
    } else if ([theDate isThisWeek]) {
      if (isShort) {
        [formatter setDateFormat:FORMAT_THIS_WEEK_SHORT];
      } else {
        [formatter setDateFormat:FORMAT_THIS_WEEK];
      }
    } else {
      if (isShort) {
        [formatter setDateFormat:FORMAT_PAST_SHORT];
      } else {
        [formatter setDateFormat:FORMAT_PAST_TIME];
        isPastLong = YES;
      }
    }

    if (isTodayYesterday) {
      NSString *todayYesterday = [ToolClass getTodayYesterdayString:theDate];
      if (isShort) {
        output = todayYesterday;
      } else {
        output = [formatter stringFromDate:theDate];
        output = [NSString stringWithFormat:@"%@ %@", todayYesterday, output];
      }
    } else {
      output = [formatter stringFromDate:theDate];
      if (isPastLong) {
        NSString *thePastDate = [ToolClass getPastDateString:theDate];
        output = [NSString stringWithFormat:@"%@ %@", thePastDate, output];
      }
    }
  }

  return output;
}

+ (NSString *)getTodayYesterdayString:(NSDate *)theDate {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
  [formatter setLocale:locale];
  formatter.dateStyle = NSDateFormatterShortStyle;
  formatter.timeStyle = NSDateFormatterNoStyle;
  formatter.doesRelativeDateFormatting = YES;
  return [formatter stringFromDate:theDate];
}

+ (NSString *)getPastDateString:(NSDate *)theDate {
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
  [formatter setLocale:locale];
  formatter.dateStyle = NSDateFormatterLongStyle;
  formatter.timeStyle = NSDateFormatterNoStyle;
  return [formatter stringFromDate:theDate];
}

+ (NSString *)dictionary2String:(NSDictionary *)dictionary {
  if (![dictionary count]) {
    return nil;
  }

  NSString *tempStr1 = [[dictionary description] stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
  NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
  NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
  NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
  NSString *str = [NSPropertyListSerialization propertyListFromData:tempData
                                                   mutabilityOption:NSPropertyListImmutable
                                                             format:NULL
                                                   errorDescription:NULL];
  return str;
}


- (NSString *)deviceString {
  struct utsname systemInfo;
  uname(&systemInfo);
  NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
  
  if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
  if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
  if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
  if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
  if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
  if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
  if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
  if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
  if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
  if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
  if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
  if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
  if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
  if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
  if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
  if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
  if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
  NSLog(@"NOTE: Unknown device type: %@", deviceString);
  return deviceString;
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
  
  NSString  *urlRegEx =@"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
  "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
  "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
  "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
  
  NSError *error;
  NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
  
  if (regex != nil) {
    NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
    
    if (firstMatch) {
      NSRange resultRange = [firstMatch rangeAtIndex:0];
      NSString *result=[ipAddress substringWithRange:resultRange];
      //输出结果
      NSLog(@"%@",result);
      return YES;
    }
  }
  
  return NO;
}

//+ (NSString *)conversationIdWithConversation:(JMSGConversation *)conversation {
//  NSString *conversationId = nil;
//  if (conversation.conversationType == kJMSGConversationTypeSingle) {
//    JMSGUser *user = conversation.target;
//    conversationId = [NSString stringWithFormat:@"%@_%ld",user.username, kJMSGConversationTypeSingle];
//  } else {
//    JMSGGroup *group = conversation.target;
//    conversationId = [NSString stringWithFormat:@"%@_%ld",group.gid,kJMSGConversationTypeGroup];
//  }
//  return conversationId;
//}

+ (CGSize)stringSizeWithWidthString:(NSString *)string withWidthLimit:(CGFloat)width withFont:(UIFont *)font {
  CGSize maxSize = CGSizeMake(width, 2000);
//  UIFont *font =[UIFont systemFontOfSize:18];
  NSMutableParagraphStyle *paragraphStyle= [[NSMutableParagraphStyle alloc] init];
  CGSize realSize = [string boundingRectWithSize:maxSize options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
  return realSize;
}

//
+ (BOOL)isEmpty:(NSString *)str {

    if (!str) {

        return true;

    } else {

        if ([str isKindOfClass:[NSNull class]]) {
            return true;

        }
        
        if ([str containsString:@"null"]) {
            return true;

        }
        
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];

        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];

        if ([trimedString length] == 0) {

            return true;

        } else {

            return false;

        }

    }

}

+ (NSString *)arrayToJSONString:(NSArray *)array
 {
     
     
     
     
     
     
    NSError *error = nil;
//    NSMutableArray *muArray = [NSMutableArray array];
//    for (NSString *userId in array) {
//        [muArray addObject:[NSString stringWithFormat:@"\"%@\"", userId]];
//    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSString *jsonTemp = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    NSString *jsonResult = [jsonTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
//    NSLog(@"json array is: %@", jsonResult);
    return jsonString;
}

#pragma mark - 添加阴影效果
+ (void)addShadowToView:(UIView *)theView withColor:(UIColor *)theColor {

    theView.layer.masksToBounds = NO;
    // 阴影颜色
    theView.layer.shadowColor = theColor.CGColor;
    // 阴影偏移，默认(0, -3)
    theView.layer.shadowOffset = CGSizeMake(0,5);
    // 阴影透明度，默认0
    theView.layer.shadowOpacity = 0.5;
    // 阴影半径，默认3
    theView.layer.shadowRadius = 5;
}


+ (NSString *)getUserName:(int)roleId withWorkerId:(NSString*)workerId {
    
    NSString * userNameStr = @"";
    
    if (roleId ==1|| roleId ==3||roleId ==11)
    {
        NSLog(@"这些角色没有聊天功能");
        userNameStr = @"NOIM";
    }
    else
    {
        
        if (roleId ==2|| roleId ==4||roleId ==8) {
            userNameStr = [NSString stringWithFormat:@"company%@",workerId];
        }
        else if (roleId ==9|| roleId ==10)
        {
            
            userNameStr = [NSString stringWithFormat:@"worker%@",workerId];
            
        }
        else
        {
            NSLog(@"后台返回错误");
            userNameStr = @"error";
            
            
        }
        
        
        
    }
    return userNameStr;
    
}

+ (BOOL)validateIDCardNumber:(NSString *)value {

    

    value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    int length =0;

    if (!value) {

        return NO;

    }else {

        length = value.length;

        if (length !=18) {

            return NO;

        }

    }

    

    // 省份代码

    

    NSArray *areasArray =@[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41",@"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];

    NSString *valueStart2 = [value substringToIndex:2];

    BOOL areaFlag =NO;

    for (NSString *areaCode in areasArray) {

        if ([areaCode isEqualToString:valueStart2]) {

            areaFlag =YES;

            break;

        }

    }

    

    if (!areaFlag) {

        

        return false;

        

    }

    NSRegularExpression *regularExpression;

    

    NSUInteger numberofMatch;

    int year =0;

    

    switch (length) {

            

        case 15:

            

            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;

            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {

                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"

                                     

                                                                       options:NSRegularExpressionCaseInsensitive

                                     

                                                                         error:nil];//测试出生日期的合法性

            }else {

                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"

                                     

                                                                       options:NSRegularExpressionCaseInsensitive

                                     

                                                                         error:nil];//测试出生日期的合法性

                

            }

            

            numberofMatch = [regularExpression numberOfMatchesInString:value

                             

                                                              options:NSMatchingReportProgress

                             

                                                                range:NSMakeRange(0, value.length)];

//            [regularExpression release];

            if(numberofMatch >0) {

                

                return YES;

                

            }else {

                

                return NO;

                

            }

            

        case 18:

            year = [value substringWithRange:NSMakeRange(6,4)].intValue;

            

            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {

                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}[0-9Xx]$"

                                                                       options:NSRegularExpressionCaseInsensitive

                                     

                                                                         error:nil];//测试出生日期的合法性

                

            }else {

                

                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}19[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}[0-9Xx]$"

                                     

                                                                       options:NSRegularExpressionCaseInsensitive

                                     

                                                                         error:nil];//测试出生日期的合法性

                

            }

            

            numberofMatch = [regularExpression numberOfMatchesInString:value

                             

                                                              options:NSMatchingReportProgress

                             

                                                                range:NSMakeRange(0, value.length)];

            if(numberofMatch >0) {

                

                int S = ([value substringWithRange:NSMakeRange(0,1)].intValue + [value substringWithRange:NSMakeRange(10,1)].intValue) *7 + ([value substringWithRange:NSMakeRange(1,1)].intValue + [value substringWithRange:NSMakeRange(11,1)].intValue) *9 + ([value substringWithRange:NSMakeRange(2,1)].intValue + [value substringWithRange:NSMakeRange(12,1)].intValue) *10 + ([value substringWithRange:NSMakeRange(3,1)].intValue + [value substringWithRange:NSMakeRange(13,1)].intValue) *5 + ([value substringWithRange:NSMakeRange(4,1)].intValue + [value substringWithRange:NSMakeRange(14,1)].intValue) *8 + ([value substringWithRange:NSMakeRange(5,1)].intValue + [value substringWithRange:NSMakeRange(15,1)].intValue) *4 + ([value substringWithRange:NSMakeRange(6,1)].intValue + [value substringWithRange:NSMakeRange(16,1)].intValue) *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;

                

                int Y = S %11;

                

                NSString *M =@"F";

                

                NSString *JYM =@"10X98765432";

                

                M = [JYM substringWithRange:NSMakeRange(Y,1)];// 判断校验位

                

                if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) {

                    

                    return YES;// 检测ID的校验位

                    

                }else {

                    

                    return NO;

                    

                }

            }else {

                

                return NO;

                

            }

            

        default:

            

            return false;

            

    }

    

}

+ (BOOL)judgeIdentityStringValid:(NSString *)identityString {
  if (identityString.length != 18) return NO;
  // 正则表达式判断基本 身份证号是否满足格式
  NSString *regex2 = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
  NSPredicate *identityStringPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
  //如果通过该验证，说明身份证格式正确，但准确性还需计算
  if(![identityStringPredicate evaluateWithObject:identityString]) return NO;
  //** 开始进行校验 *//
  //将前17位加权因子保存在数组里
  NSArray *idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
  //这是除以11后，可能产生的11位余数、验证码，也保存成数组
  NSArray *idCardYArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
  //用来保存前17位各自乖以加权因子后的总和
  NSInteger idCardWiSum = 0;
  for(int i = 0;i < 17;i++) {
    NSInteger subStrIndex  = [[identityString substringWithRange:NSMakeRange(i, 1)] integerValue];
    NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
    idCardWiSum      += subStrIndex * idCardWiIndex;
  }
  //计算出校验码所在数组的位置
  NSInteger idCardMod=idCardWiSum%11;
  //得到最后一位身份证号码
  NSString *idCardLast= [identityString substringWithRange:NSMakeRange(17, 1)];
  //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
  if(idCardMod==2) {
    if(![idCardLast isEqualToString:@"X"]||[idCardLast isEqualToString:@"x"]) {
      return NO;
    }
  }else{
    //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
    if(![idCardLast isEqualToString: [idCardYArray objectAtIndex:idCardMod]]) {
      return NO;
    }
  }
  return YES;
}

+ (UIViewController *)getCurrentVC
{
    UIViewController *result =nil;

    UIWindow * window = [[UIApplication sharedApplication] keyWindow];

    if(window.windowLevel != UIWindowLevelNormal) {

        NSArray *windows = [[UIApplication sharedApplication] windows];

        for (UIWindow * tmpWin in windows) {

            if(tmpWin.windowLevel == UIWindowLevelNormal) {

                window = tmpWin;

                break;

            }

        }

    }

    // 从根控制器开始查找

    UIViewController *rootVC = window.rootViewController;

    id nextResponder = [rootVC.view nextResponder];
    //NSLog(@"nextResponder---%@",nextResponder);
    
    do {
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {

            result = ((UINavigationController*)nextResponder).topViewController;

            if ([result isKindOfClass:[UITabBarController class]]) {

                result = ((UITabBarController *)result).selectedViewController;

            }

        } else if ([nextResponder isKindOfClass:[UITabBarController class]]) {

            result = ((UITabBarController*)nextResponder).selectedViewController;

            if([result isKindOfClass:[UINavigationController class]]) {

                result = ((UINavigationController *)result).topViewController;

            }

        } else if ([nextResponder isKindOfClass:[UIViewController class]]) {

            result = nextResponder;

        } else {

            result = window.rootViewController;

            if ([result isKindOfClass:[UINavigationController class]]) {

                result = ((UINavigationController *)result).topViewController;

                if ([result isKindOfClass:[UITabBarController class]]) {

                    result = ((UITabBarController *)result).selectedViewController;

                }

            } else if([result isKindOfClass:[UIViewController class]]) {

                result = nextResponder;

            }
        }
        
        nextResponder = result;
        
    } while ([nextResponder isKindOfClass:[UITabBarController class]]);

    return result;
}

+ (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) *0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) *0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

+ ( UIImage *)imageWithImageSimple:( UIImage *)image scaledToSize:( CGSize )newSize
{
    
    UIGraphicsBeginImageContext (newSize);
    
    [image drawInRect : CGRectMake ( 0 , 0 ,newSize. width ,newSize. height )];
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext ();
    
    UIGraphicsEndImageContext ();
    
    return newImage;
    
}

// 压缩图片，如果图片大于100kb，就循环压缩
+ (NSData *)compressionWithImage:(UIImage *)image {
   
    // 先按宽度压缩
    UIImage *newImage = [image resizeImageGreaterThan:480];
   
    NSData *data;
    float quality = 1.0f;
    if (UIImageJPEGRepresentation(newImage, quality)) {
        data = UIImageJPEGRepresentation(newImage, quality);
        while (data.length / 1024.0f > 100 && quality > 0.5) {
            quality -= 0.1f;
            data = UIImageJPEGRepresentation(newImage, quality);
        }
    }
   
    if (data == nil) {
        data = UIImageJPEGRepresentation(newImage, 0.5);
    }
   
    return data;
}

+ (void)loginWithSuccessBlock:(void(^)(void))successBlock
{
//    JMSGDeviceInfo
    int roleId = [ROLEID intValue];

    NSString * userNameStr = [ToolClass getUserName:roleId withWorkerId:USERID];

    
//    [JMSGUser loginWithUsername:userNameStr
//                       password:@"lanlingchengbang"
//              completionHandler:^(id resultObject, NSError *error) {
//        NSLog(@"%@",resultObject);
//        if (error == nil) {
//            
//            successBlock();
//        
//        } else {
//            
//           
//            
//        }
//    }];
//    
    
//    [JMSGUser loginWithUsername:userNameStr password:@"lanlingchengbang" devicesInfo:^(NSArray<__kindof JMSGDeviceInfo *> * _Nonnull devices) {
//
//    } completionHandler:^(id resultObject, NSError *error) {
//        if (error == nil) {
//
//            successBlock();
//
//        } else {
//
//
//
//        }
//    }];
    
}

+ (BOOL)loginJidSuccess
{
    
    
//    if ([ToolClass isEmpty:[JMSGUser myInfo].username]) {
//
//        return NO;
//    }
//    else
//    {
//
        return YES;
//    }
    
}

+ (void)createSingleConversationWithUserId:(NSString *)userId withVC:(UIViewController*)fatherVC
{
       UINavigationController *nav = fatherVC.navigationController;
       NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
       NTESSessionViewController *vc = [[NTESSessionViewController alloc] initWithSession:session];
       [nav pushViewController:vc animated:YES];
}

+ (NSString *)getVerificationCode
{
    NSArray *strArr = [[NSArray alloc]initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",nil] ;
    NSMutableString *getStr = [[NSMutableString alloc]initWithCapacity:5];
    for(int i = 0; i < 6; i++) //得到六位随机字符,可自己设长度
    {
        int index = arc4random() % ([strArr count]);  //得到数组中随机数的下标
        [getStr appendString:[strArr objectAtIndex:index]];
        
    }
    return getStr;
}

+ (NSString*)getCurrentYM {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

    [formatter setDateFormat:@"YYYY-MM"];

    //现在时间,你可以输出来看下是什么格式

    NSDate *datenow = [NSDate date];

    //----------将nsdate按formatter格式转成nsstring

    NSString *currentTimeString = [formatter stringFromDate:datenow];

    NSLog(@"currentTimeString =  %@",currentTimeString);

    return currentTimeString;

}


+ (NSDictionary *)dictionaryForJsonData:(NSData *)jsonData
{

    if (![jsonData isKindOfClass:[NSData class]] || jsonData.length < 1) {

        return nil;

    }

    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];

    if (![jsonObj isKindOfClass:[NSDictionary class]]) {

        return nil;

    }

    return [NSDictionary dictionaryWithDictionary:(NSDictionary *)jsonObj];

}

+ (NSData *)compactFormatDataForDictionary:(NSDictionary *)dicJson
{

    if (![dicJson isKindOfClass:[NSDictionary class]]) {

        return nil;

    }

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson options:0 error:nil];

    if (![jsonData isKindOfClass:[NSData class]]) {

        return nil;

    }

    return jsonData;

}


+ (NSArray *)arrayForJsonData:(NSData *)jsonData
{

    if (![jsonData isKindOfClass:[NSData class]] || jsonData.length < 1) {

        return nil;

    }

//    id jsonObj = [NSKeyedUnarchiver unarchiveObjectWithData:jsonData ];
    NSError *error;
    if (@available(iOS 11.0, *)) {
        NSSet *clsSet = [NSSet setWithObjects:[NSMutableArray class],[NIMRecentSession class],[NIMSession class],[NIMMessage class], nil];

        id jsonObj =  [NSKeyedUnarchiver unarchivedObjectOfClasses:clsSet fromData:jsonData error:&error];
        if (![jsonObj isKindOfClass:[NSArray class]]) {
            
            return nil;
            
        }
        
        return [NSArray arrayWithArray:(NSArray*)jsonObj];
    } else {
        // Fallback on earlier versions
        id jsonObj =  [NSKeyedUnarchiver unarchiveObjectWithData:jsonData];
        if (![jsonObj isKindOfClass:[NSArray class]]) {
            
            return nil;
            
        }
        
        return [NSArray arrayWithArray:(NSArray*)jsonObj];
    }

}

+ (NSData *)compactFormatDataForArray:(NSArray *)arrJson
{

    if (![arrJson isKindOfClass:[NSArray class]]) {

        return nil;

    }

    NSData *jsonData = [NSKeyedArchiver archivedDataWithRootObject:arrJson];


    if (![jsonData isKindOfClass:[NSData class]]) {

        return nil;

    }

    return jsonData;

}

+ (UIColor *)colorWithHexString:(NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }

    // 判断前缀并剪切掉
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];

    // 从六位数值中找到RGB对应的位数并转换
    NSRange range;
    range.location = 0;
    range.length = 2;

    //R、G、B
    NSString *rString = [cString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cString substringWithRange:range];

    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];

    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}
@end
