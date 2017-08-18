//
//  MyMqtt.m
//  Demo1
//
//  Created by 桑云锋 on 2017/8/11.
//  Copyright © 2017年 桑云锋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyMqtt.h"
#import "MQTTCFSocketTransport.h"

@implementation MyMqtt{
    CallBack mqttReceived;
    ConnectLost mqttConnectLost;
}


static MyMqtt* _instance = nil;

+(MyMqtt*) mqttService
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
        //不是使用alloc方法，而是调用[[super allocWithZone:NULL] init]
        //已经重载allocWithZone基本的对象分配方法，所以要借用父类（NSObject）的功能来帮助出处理底层内存分配的杂物
    }) ;
    
    return _instance ;
}

- (void)newMessage:(MQTTSession*)session
              data:(NSData*)data
               onTopic:(NSString*)topic
               qos:(MQTTQosLevel)qos
              retained:(BOOL)retained
               mid:(unsigned int)mid{
    NSLog(@"推送消息");
    NSString *strData = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"消息：%@  主题：%@",strData,topic);
    
    uint64_t datetime = [[NSDate date] timeIntervalSince1970];
    NSString* time = [NSString stringWithFormat:@"%llu",datetime]; //utc秒数
    NSDictionary* record = [NSDictionary dictionaryWithObjectsAndKeys:topic,@"topic",
                            strData,@"message",
                            time,@"time",
                            nil];
    mqttReceived(record);
}


-(void)mqttConnect:(CallBack)callback
                  :(CallBack)received
                  :(ConnectLost)onConnectLost
                  host:(NSString*)host
                  port:(UInt32)port
                  username:(NSString*)username
                  password:(NSString*)password
                  clientId:(NSString*)clientId
                  live:(UInt16)alive{
    mqttReceived = received;
    mqttConnectLost = onConnectLost;
    
    NSLog(@"mqttConnect 建立连接");
    self.session = [[MQTTSession alloc] init];
    self.session.protocolLevel = 4;
    
    MQTTCFSocketTransport *tp = [[MQTTCFSocketTransport alloc] init];
    tp.port = port;
    tp.host = host;
    
    self.session.transport = tp;
    
//    self.session.userName = @"87601";
//    self.session.password = @"TZJHHyfz6T0g8fzwwbZ0AKYxbAM=";
    
    [self.session setUserName:username];
    [self.session setPassword:password];
    
    self.session.clientId = clientId;
    
    self.session.delegate = self;
    
    self.session.keepAliveInterval = alive;
    
    [self.session connectWithConnectHandler:^(NSError *error) {
        NSDictionary *result = nil;
        if (error) {
            NSLog(@"连接错误：%@",[error localizedDescription]);
            result = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"-1",@"code",
                      @"连接错误",@"msg",
                      nil];
        } else {
            NSLog(@"连接成功");
            //[self.session subscribeToTopic:@"#" atLevel:1];
            result = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"0",@"code",
                      @"连接成功",@"msg",
                      nil];
       }
        callback(result);
    }];
 
}

//mqtt 连接断开回调具柄
-(void)connectionClosed:(MQTTSession *)session{
    mqttConnectLost();
}

//断开链接
-(void)mqttDisConnect:(DisCallBack)callback{
    [self.session closeWithDisconnectHandler:^(NSError *error) {
        UInt16 result = 0;
        if (error) {
            result = -1;
        }else{
            result = 0;
        }
        callback(result);
    }];
    mqttConnectLost();
}

-(void) subscribeTopic:(NSString*)topic :(int)qos :(DisCallBack)subCallback{
    //订阅主题
    NSString* qosStr = [NSString stringWithFormat:@"%d",qos];
    NSLog(@"订阅主题：%@  质量：%@",topic,qosStr);
    [self.session subscribeToTopic:topic atLevel:qos subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        UInt16 result = 0;
        if (error) {
            result=-1;
        } else {
            result=0;
        }
        subCallback(result);
    }];
    
}

-(void) unsubscribeTopic:(NSString*)topic :(DisCallBack)subCallback{
    //解除订阅主题
    NSLog(@"订阅主题：%@",topic);
    [self.session unsubscribeTopic:topic unsubscribeHandler:^(NSError *error) {
        UInt16 result = 0;
        if (error) {
            result=-1;
        } else {
            result=0;
        }
        subCallback(result);
    }];
}

-(void) publishData:(NSData*)data :(NSString*) topic :(int)qos :(DisCallBack)pubCallback{
    //发布信息
    //int转字符串
    NSString* qosStr = [NSString stringWithFormat:@"%d",qos];
    
    NSLog(@"发布信息：%@  主题：%@  质量：%@",[[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding],topic,qosStr);
    [self.session publishData:data onTopic:topic retain:nil qos:qos  publishHandler:^(NSError *error) {
        UInt16 result = 0;
        if (error) {
            result=-1;
        } else {
            result=0;
        }
        pubCallback(result);
    }];

}

@end

