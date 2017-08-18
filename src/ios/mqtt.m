//
//  TestPlugin.m
//  myApp
//
//  Created by 桑云锋 on 2017/8/14.

//*****注意：
//1.如何保持cordova对话的时效性？-->类似通过cordova建立前后端的长连接，进行数据通信。
//[pluginResult setKeepCallbackAsBool:YES];
//必须对每一个关联操作都要保持callbackId的有效，否则会中断，导致前端无法接收到！
//

#import <Foundation/Foundation.h>
#import "mqtt.h"
#import "MyMqtt.h"

@implementation MqttPlugin

//初始化插件，并获取配置参数
- (void)pluginInitialize {
//    CDVViewController *viewController = (CDVViewController *)self.viewController;
//    host = [viewController.settings objectForKey:@"host"];
//    NSString* portstr = [viewController.settings objectForKey:@"port"];
//    port = [portstr intValue];
    
      //@采用前端接口传递参数。url  port
}

-(void)test:(CDVInvokedUrlCommand *)command{
    //前端参数和环境参数都封装在command变量里面
    
    callbackId = command.callbackId;
    
    //获取前端传递的参数code
    NSString* code = [command.arguments objectAtIndex:0];
    
    CDVPluginResult* pluginResult;
    
    //字典变量初始化，参数序列，@“value”=》@“key”
    NSDictionary* resultDic = [NSDictionary dictionaryWithObjectsAndKeys:@"value",@"key",
                               code,@"code",
                               nil];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    
}

-(void)connect:(CDVInvokedUrlCommand *)command{
    
    //将mqtt连接配置参数写入app配置文件config.xml,通过环境变量获取使用
    callbackId = command.callbackId;
    
    //将连接参数通过前端传递过来
    NSString* username = [command.arguments objectAtIndex:0];
    NSString* password = [command.arguments objectAtIndex:1];
    NSString* clientId = [command.arguments objectAtIndex:2];
    int alive = [[command.arguments objectAtIndex:3] intValue];
    NSString* host = [command.arguments objectAtIndex:4];
    int port = [[command.arguments objectAtIndex:5] intValue];
    NSLog(@"connect: %@ %@ %@ %d %@ %d",username,password,clientId,alive,host,port);
    
    [[MyMqtt mqttService] mqttConnect:^(NSDictionary *resultDic) {
        NSLog(@"连接结果：%@",resultDic);
        CDVPluginResult* pluginResult;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        //保持回调状态
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    } :^(NSDictionary *resultDic) {
        NSLog(@"推送数据：%@",resultDic);
        CDVPluginResult* pluginResult;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
        //保持回调状态
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
    } :^() {
        NSLog(@"连接断开");
        CDVPluginResult* pluginResult;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:[NSDictionary dictionaryWithObjectsAndKeys:@"-1",@"code", nil] ];
        //保持回调状态
        [pluginResult setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        
        //重新建立连接
        [self connect:command];
    }
     host:host
     port:port
     username:username
     password:password
     clientId:clientId
     live:alive];
    
}

-(void)disconnect:(CDVInvokedUrlCommand *)command{
    callbackId = command.callbackId;
    [[MyMqtt mqttService] mqttDisConnect:^(UInt16 result) {
        NSLog(@"连接断开结果：%d",result);
        if (result==0) {
            CDVPluginResult* pluginResult;
            pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        } else {
            CDVPluginResult* pluginResult;
            pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:-1];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }];
}

-(void)subscribe:(CDVInvokedUrlCommand *)command{
    callbackId = command.callbackId;
    NSString* topic = [command.arguments objectAtIndex:0];
    int qos = [[command.arguments objectAtIndex:1] intValue];
    [[MyMqtt mqttService] subscribeTopic:topic :qos :^(UInt16 result) {
        NSLog(@"订阅主题%@结果：%d",topic,result);
        if (result==0) {
            CDVPluginResult* pluginResult;
            pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        } else {
            CDVPluginResult* pluginResult;
            pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:-1];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }];
}

-(void)unsubscribe:(CDVInvokedUrlCommand *)command{
    callbackId = command.callbackId;
    NSString* topic = [command.arguments objectAtIndex:0];
    [[MyMqtt mqttService] unsubscribeTopic:topic :^(UInt16 result) {
        NSLog(@"订阅主题%@结果：%d",topic,result);
        if (result==0) {
            CDVPluginResult* pluginResult;
            pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        } else {
            CDVPluginResult* pluginResult;
            pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:-1];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }];
}


-(void)publish:(CDVInvokedUrlCommand *)command{
    callbackId = command.callbackId;
    NSString* message = [command.arguments objectAtIndex:0];
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSString* topic = [command.arguments objectAtIndex:1];
    int qos = [[command.arguments objectAtIndex:2] intValue];
    [[MyMqtt mqttService] publishData:data :topic :qos :^(UInt16 result) {
        NSLog(@"发送数据结果：%d",result);
        if (result==0) {
            CDVPluginResult* pluginResult;
            pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:0];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        } else {
            CDVPluginResult* pluginResult;
            pluginResult =[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:-1];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }];
}

@end
