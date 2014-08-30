//
//  JYESettingViewController.m
//  JYControl
//
//  Created by mq on 14-8-25.
//  Copyright (c) 2014年 mqq.com. All rights reserved.
//

#import "JYESettingViewController.h"



@interface JYESettingViewController ()

@end

@implementation JYESettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![JYEUtil isFirstTimeLogin]) {
        
        [self initView];
    }
    
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    
    if ([JYEUtil isFirstTimeLogin]) {
        
        [JYEUtil showAlertWithTitle:@"配置您的信息" message:@"完成后点击save" inViewWithButton:@"OK"];
    }
    
}

-(void)initView
{
    JYEDataStore *dataStore  =  [JYEDataStore shareInstance];
    _address.text = dataStore.serverAddress;
    _port.text = [dataStore.serverPort stringValue];
    _addressCode.text = dataStore.serverCode;
    _password.text = dataStore.passwordString;
    _SSID.text = dataStore.ssidString;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)textFieldEndEdit:(UITextField *)sender {
    
    if (self.view.frame.origin.y < 0) {
        
        [UIView animateWithDuration:0.1f animations:^(){
            
            CGRect frame = self.view.frame;
            frame.origin.y += 200.0f;
            self.view.frame = frame;
            
        }];

    }
    
    
    [sender resignFirstResponder];
    
}

- (IBAction)cancelKeyboard:(id)sender {
    
    for (UIView *subView in [self.view subviews]) {
        
        if ([subView isKindOfClass:[UITextField class]]) {
            
            UITextField *view = (UITextField *)subView;
            
            [view resignFirstResponder];
            
        }
    }
    
}

- (IBAction)closeView:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)beginEdit:(id)sender {
    
    [UIView animateWithDuration:0.5f animations:^(){
    
        CGRect frame = self.view.frame;
        frame.origin.y -= 200.0f;
        self.view.frame = frame;
        
    }];
    
}

- (IBAction)save:(id)sender {
    
    JYEDataStore *dataStore  =   [JYEDataStore shareInstance];
    dataStore.serverCode = _addressCode.text;
    dataStore.serverAddress = _address.text;
    dataStore.passwordString = _password.text;
    dataStore.ssidString = _SSID.text;
    
    dataStore.serverPort = [NSNumber numberWithInteger:[_port.text integerValue]];
    
    [dataStore save];
    
    
    [JYEUtil setFirstTimeLoginOver];
    if ([[JYECommandSender shareSender] connectToServer:_address.text port:[_port.text integerValue]]) {
        
        [[JYECommandSender shareSender] sendMessage:[JYEUtil formConnectMessage]];
        
    }
    else
    {
        [JYEUtil showAlertWithTitle:@"错误" message:@"连接服务器失败" inViewWithButton:@"OK"];
    }
    
    
    
    
}
@end
