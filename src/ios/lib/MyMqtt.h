//
//  MyMqtt.h
//  Demo1
//
//  Created by 桑云锋 on 2017/8/11.
//  Copyright © 2017年 桑云锋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MQTTSession.h"

//自定义函数方法
typedef void (^CallBack)(NSDictionary *resultDic);
typedef void (^ConnectLost)();
typedef void (^DisCallBack)(UInt16 result);

@interface MyMqtt : NSObject<MQTTSessionDelegate>

@property (strong,nonatomic) MQTTSession *session;

//静态类方法
+(MyMqtt*)mqttService;

-(void) mqttConnect:(CallBack)callback
                   :(CallBack)received
                   :(ConnectLost)onConnectLost
               host:(NSString*)host
               port:(UInt32)port
           username:(NSString*)username
           password:(NSString*)password
           clientId:(NSString*)clientId
               live:(UInt16)alive;

-(void) mqttDisConnect:(DisCallBack)callback;
-(void) subscribeTopic:(NSString*)topic :(int)qos :(DisCallBack)subCallback;
-(void) unsubscribeTopic:(NSString*)topic :(DisCallBack)subCallback;

-(void) publishData:(NSData*)data :(NSString*) topic :(int)qos :(DisCallBack)pubCallback;

@end
