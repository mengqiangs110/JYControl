//
//  JYECommandSender.m
//  JYControl
//
//  Created by mq on 14-8-25.
//  Copyright (c) 2014年 mqq.com. All rights reserved.
//



#import "JYECommandSender.h"
#import "AsyncSocket.h"
@interface JYECommandSender ()
{
    AsyncSocket *_asyncSocket;
    NSString *_host;
    int _port;
}
@property(nonatomic,assign)BOOL isConnected;
@end

@implementation JYECommandSender

+(JYECommandSender *)shareSender
{
    static JYECommandSender *sender;
    static dispatch_once_t senderToken;
    dispatch_once(&senderToken, ^{
        
        sender = [[JYECommandSender alloc] init];
        
    });
    
    return sender;
}

-(id)init
{
    if (self = [super init]) {
        
        _asyncSocket = [[AsyncSocket alloc] initWithDelegate:self];
        _isConnected = false;
    }
    
    return self;
}


-(BOOL)connectToServer:(NSString *)host port:(int)port;
{
    if(_isConnected)
    {
        return _isConnected;
    }
    
    _host = host;
    
    _port = port;
    
    NSError *error = nil;
    if(![_asyncSocket connectToHost:_host onPort:_port error:&error])
        
    {
        
        NSLog(@"Error: %@", error);
        
      return   _isConnected = false;
        
        
    }
    
   return  _isConnected = true;

    
}

-(BOOL)isConnected
{
    // 重连
    if (!_isConnected) {
        
       return  [self connectToServer:_host port:_port];
    }
    
    return _isConnected;
}

-(void)sendMessage:(NSString *)message
{
   [_asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
}



-(BOOL)connectToDefaultServer
{
 
    return [self connectToServer:[JYEDataStore shareInstance].serverAddress port:[[JYEDataStore shareInstance].serverPort intValue]];
}



#pragma mark - delegate


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"onSocket:%p didConnectToHost:%@ port:%hu",sock,host,port);
//    [sock readDataWithTimeout:1 tag:0];
}
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
//    [sock readDataWithTimeout: -1 tag: 0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString* aStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",aStr);
    
//    [sock readDataWithTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didSecure:(BOOL)flag
{
    NSLog(@"onSocket:%p didSecure:YES", sock);
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"onSocket:%p willDisconnectWithError:%@", sock, err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    //断开连接了
    NSLog(@"onSocketDidDisconnect:%p", sock);

    _asyncSocket = nil;
}
@end
