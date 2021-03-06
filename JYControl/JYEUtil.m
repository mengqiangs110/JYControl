//
//  JYEUtil.m
//  JYControl
//
//  Created by mq on 14-8-26.
//  Copyright (c) 2014年 mqq.com. All rights reserved.
//

#define kHeadString @"SAT:"
#define kFristTime @"isFirstTime"
#import "JYEUtil.h"
#import "UIView+Extend.h"



@implementation JYEUtil

+(NSString *)formConnectMessage{

    NSMutableString *outPut = [[NSMutableString alloc] initWithString:kHeadString];
    
    [outPut appendString:[NSString stringWithFormat:@"PA%@-PB%@-PC%@-PD%@-PE%@-PF",[JYEDataStore shareInstance].serverAddress,[[JYEDataStore shareInstance].serverPort stringValue],[JYEDataStore shareInstance].serverCode,[JYEDataStore shareInstance].ssidString,[JYEDataStore shareInstance].passwordString]];
    
    NSLog(@"%@",outPut);
    
    return outPut;
}


+(NSString *)formControlMessageWithButtonTag:(NSInteger)tag  SendMessage:(NSString *)input{
    
      NSMutableString *outPut = [[NSMutableString alloc] initWithString:kHeadString];
    
    if (tag< 10) {
      
        
        [outPut appendString:[NSString stringWithFormat:@"0%d-:%@-:%@-:CRL",tag,[JYEDataStore shareInstance].serverCode,input]];
    }
    else
    {
    
    [outPut appendString:[NSString stringWithFormat:@"%d-:%@-:%@-:CRL",tag,[JYEDataStore shareInstance].serverCode,input]];
    
    }
    return outPut;
    
}



+(BOOL) isFirstTimeLogin{
    
    NSDictionary *option = @{@"firstTime": @"YES"};
    [[NSUserDefaults standardUserDefaults] registerDefaults:option];
    
    
    
    NSString *isString = [[NSUserDefaults standardUserDefaults] valueForKey:@"firstTime"];
    
    if ([isString isEqualToString:@"YES"]) {
        
        return YES;
        
    }
    else{
        
        return NO;
    }
    
}
+(void)setFirstTimeLoginOver{
    
    [[NSUserDefaults standardUserDefaults] setValue:@"NO" forKey:@"firstTime"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message inViewWithButton:(NSString *)buttonName{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:buttonName otherButtonTitles: nil];
    
    [alert show];
    
    
}
+(void)showConnectServerSuccess
{
//    [JYEUtil showAlertWithTitle:@"" message:@"连接成功" inViewWithButton:@"OK"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kConnectNotificaton object:nil userInfo:@{@"connect":@1}];
    
}


+(void)alertConnectServerFail
{
    
    
//    UIViewController *controller = [JYEUtil getCurrentRootViewController];
//    
//    [controller.view showNotification:@"连接失败" WithStyle:hudStyleFailed];
//    
//    [JYEUtil showAlertWithTitle:@"错误" message:@"连接服务器失败" inViewWithButton:@"OK"];
    
      [[NSNotificationCenter defaultCenter] postNotificationName:kConnectNotificaton object:nil userInfo:@{@"connect":@0}];
}


+(UIViewController *)getCurrentRootViewController {
    
    UIViewController *result;
    
    // Try to find the root view controller programmically
    
    // Find the top window (that is not an alert view or other window)
    
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (topWindow.windowLevel != UIWindowLevelNormal)
        
    {
        
        NSArray *windows = [[UIApplication sharedApplication] windows];
        
        for(topWindow in windows)
            
        {
            
            if (topWindow.windowLevel == UIWindowLevelNormal)
                
                break;
            
        }
        
    }
    
    UIView *rootView = [[topWindow subviews] objectAtIndex:0];
    
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        
        result = nextResponder;
    
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil)
        
        result = topWindow.rootViewController;
    
    else
        
        NSAssert(NO, @"ShareKit: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
    
    return result;    
    
}

+(BOOL)isValidatIPAndPort:(NSString *)ipAddress serverPort:(NSString *)port{
    
    NSString  *urlRegEx =@"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$"; //服务器IP地址匹配格式，本格式来自网络
    
    NSString  *portRegEx =@"^([1-9][0-9]{0,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]{1}|6553[0-5])$"; //服务器端口号匹配格式，本方式来自网络
    
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    NSPredicate *portTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", portRegEx];
    return [urlTest evaluateWithObject:ipAddress] && [portTest evaluateWithObject:port];
}

+(NSString *)formControlMessageWithSliderValue:(NSInteger)value SendMessage:(NSString *)message Type:(NSInteger)type
{
    NSMutableString *retMessage = [[NSMutableString alloc] init];
    
    if (type == 1) {
        
        [retMessage appendString:@"SAF"];
    }
    else if(type == 0)
    {
        [retMessage appendString:@"SAG"];
    }
    else
    {
         [retMessage appendString:@"SAJ"];
    }
    
    [retMessage appendString:[NSString stringWithFormat:@":%ld-:%@-:%@-:CRL",(long)value,[JYEDataStore shareInstance].serverCode,message]];
    
    
    return [retMessage copy];
    
}


+(void)sendMessageWithType:(NSUInteger)type valueNow:(float)value valueOri:(NSUInteger *)oriValue
{
    float  f = value - *oriValue;
    
    if (f> 3|| f < -3) {
        
        
        
        NSString * message = [JYEUtil formControlMessageWithSliderValue:value SendMessage:@"" Type:type];
        
        [[JYECommandSender shareSender] sendMessage:message];
        
        *oriValue = value;
        
    }
    
    
    
}

+(void)saveSliderValueWithColor:(NSUInteger) colorValue light:(NSUInteger) lightValue temprature:(NSUInteger)tempratureValue
{
  
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:colorValue] forKey:@"ColorValue"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:lightValue] forKey:@"LightValue"];
    
    if (tempratureValue > -1) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:tempratureValue] forKey:@"TempratureValue"];

    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)parseReturnString:(NSString *)parseString
{
    
    NSRange rang = [parseString rangeOfString:@"DISP:"];
    
    rang.location = rang.location +rang.length;
    rang.length = 3;
    
    NSMutableArray *numArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i<4 ; i++) {
        
        NSString *numString = [parseString substringWithRange:rang];
        NSInteger num = [numString integerValue];
        
        [numArray addObject:[NSNumber numberWithInteger:num]];
        
        rang.location = rang.location + 4;
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kReturnStringNotification object:self userInfo:numArray];
    
    
}

+(NSString *)judgeStringByNum:(NSNumber *)num
{
     int   intNum  =  [num intValue];
    NSString * returnString = @"ON";
    
    if (intNum == 0) {
        
        
        
    }
    else if(intNum == 100)
    {
        returnString = @"OFF";
    }
    else
    {
        returnString = @"ON-";
        returnString = [returnString stringByAppendingString:[num stringValue]];
    }
    
    return returnString;
}


@end
