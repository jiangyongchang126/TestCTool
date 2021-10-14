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


@end
