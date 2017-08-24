# ios-plugin-mqtt
为解决前端使用cordova框架开发ios移动应用中使用到的mqtt通讯协议，而自定义扩展的cordova插件。

_Thanks for 'MQTT-Client-Framework' library files from Mr ckrey.  
[https://github.com/ckrey/MQTT-Client-Framework](https://github.com/ckrey/MQTT-Client-Framework)
本Cordova插件是基于Mr ckrey的mqtt库构建的。_

## 安装插件（环境：安装nodejs引擎并安装cordova插件）
cordova plugin add ios-plugin-mqtt

## 插件使用接口说明：

### 1. 建立mqtt连接
    接口：connect(options)
    参数：options
    参数说明：
    options={
      username:“用户名”
      password:“密码”
      clientId:“编号”
      keepAlive:“保持连接的时间周期，单位：秒数”
      url:“连接地址 例如：tcp://127.0.0.1”
      port:"端口号"
    }
`
//案例
`
`
cordova.plugins.CordovaMqTTPlugin.connect({
`
`	url:"tcp://127.0.0.1", 
`
`	port:3000,
`
`	clientId:"1002010",
`
`	username:"admin",
`
`	password:"123",
`
`	keepAlive:86400,
`
`	success:function(s){//连接成功回调
`
`	},
`
`	error:function(e){//连接出错信息回调
`
`	},
`
`	onConnectionLost:function (){//连接断开丢失回调
`
`	}
`
`});
`

### 2.断开mqtt连接
    接口：disconnect(options)
    参数：options
`
//案例
`
`
cordova.plugins.CordovaMqTTPlugin.disconnect({
`
`      success:function(s){//连接断开成功回调
`
`	},
`
`	error:function(e){//连接断开出错信息回调
`
`	}
`
`});
`

### 3.订阅主题
    接口：subscribe(options)
    参数：options
    参数说明：
    options={
      topic:“主题”
      qos:“发送质量”
    }
`
//案例
`
`cordova.plugins.CordovaMqTTPlugin.subscribe({
     `
` topic:"topic/*",
    `
`  qos:0,
  `
`    success:function(s){//订阅主题成功回调
`
`	},
`
`	error:function(e){//订阅主题出错信息回调
`
`	}
`
`});
`

### 4.解除订阅主题
    接口：unsubscribe(options)
    参数：options
    参数说明：
    options={
      topic:“主题”
    }
`
//案例
`
`
cordova.plugins.CordovaMqTTPlugin.unsubscribe({
`
`
      topic:"topic/*",
 `
`     success:function(s){//解除订阅主题成功回调},
`
`	error:function(e){//解除订阅主题出错信息回调}
`
`});
`

### 5.向主题发送信息
    接口：publish(options)
    参数：options
    参数说明：
    options={
      topic:“主题”
      qos:“发送质量”
      payload:"发送信息"
    }
`
//案例
`
`
cordova.plugins.CordovaMqTTPlugin.publish({
      `
`topic:"topic/*",
    `
`  qos:0
  `
`    payload:'hello world'
`
`      success:function(s){//发送信息成功回调
`
`	},
`
`	error:function(e){//发送信息出错信息回调
`
`	}
`
`});
`


### 6.设置侦听接收信息的主题
    接口：listen(theme,callback)
    参数说明：
      theme:“正则匹配相关的主题”
      callback:"开启侦听回调"
`
//案例
`
`cordova.plugins.CordovaMqTTPlugin.listen(theme:"topic/*",
  `
`       function(e){//开启侦听回调
`
`});
`





