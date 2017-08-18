//
//  TestPlugin.h
//  myApp
//
//  Created by 桑云锋 on 2017/8/14.
//

#import <Cordova/CDV.h>
#import "MyMqtt.h"

@interface MqttPlugin:CDVPlugin{
    NSString *callbackId;
}
-(void)test:(CDVInvokedUrlCommand*)command;
-(void)connect:(CDVInvokedUrlCommand*)command;
-(void)disconnect:(CDVInvokedUrlCommand*)command;

-(void)subscribe:(CDVInvokedUrlCommand*)command;
-(void)unsubscribe:(CDVInvokedUrlCommand*)command;
-(void)publish:(CDVInvokedUrlCommand*)command;


@end
