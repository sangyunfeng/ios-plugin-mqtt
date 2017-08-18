cordova.define("ios-plugin-mqtt", function(require, exports, module) {
               
   var exec = require('cordova/exec');
   
   //建立连接
   exports.connect = function(options) {
       
       console.log("connect--->",options);

       if(options.onConnectionLost==null){
           options.onConnectionLost=function(){};
       }
       
       //处理与android差异url地址前缀tcp://
       options.url = options.url.replace("tcp://","");
   
       exec(function(record){
            if(record){
                if(record.code!=null){
                    //连接成功
                    if(record.code==0){
                        if(options.success)options.success(record);

                    }
                    //连接丢失或断开
                    if(record.code==-1){
                        options.onConnectionLost();
                    }
            
                }else{
                    //没有code码返回的信息都被认为是推送报文
                    //获取接受主题推送消息的路由器
                    exports.router(record);
                }
            }
        }, options.error, "MqttPlugin", "connect", [options.username,options.password,options.clientId,options.keepAlive,options.url,options.port]);
   
   };
               
   //断开连接
   exports.disconnect = function(options) {
       if(options==null){
           options={};
       }
       console.log("disconnect");
       exec(options.success, options.error, "MqttPlugin", "disconnect", []);
   
   };
   
   //订阅主题
   exports.subscribe = function(options) {
       if(options==null){
           options={};
       }
       console.log("subscribe");
       exec(options.success, options.error, "MqttPlugin", "subscribe", [options.topic,options.qos]);
   };
   
   //解除订阅
   exports.unsubscribe = function(options) {
       if(options==null){
       options={};
       }
       console.log("unsubscribe");
       exec(options.success, options.error, "MqttPlugin", "unsubscribe", [options.topic]);
   };
   
   //发布数据到主题
   exports.publish = function(options) {
       if(options==null){
               options={};
       }
       console.log("publish");
       exec(options.success, options.error, "MqttPlugin", "publish", [options.payload,options.topic,options.qos]);
   
   };
   
   //侦听路由器
   exports.router = function(record){
       var topic = record.topic;
       var utctime = record.time;//utc秒数
       var message = record.message;
       if(exports.listenMap&&exports.listenMap.length>0){
           for(var i=0;i<exports.listenMap.length;i++){
               var item = exports.listenMap[i];
               var regStr = item.theme.replace("#","\\.*");
               var reg = new RegExp(regStr);
               if(reg.test(topic)==true){
                   //{singlewc:room,multiwc:hall}
                   item.callback(message,{});
               }
           }
       }
   };
   
   var listenMap = [];
   
   //客户端自定义侦听接收topic消息接口，获取推送的数据
   exports.listen = function(theme,callback){
       if(theme&&callback&&theme!=""){
           listenMap.push({
              theme:theme,
              callback:callback
           });
       }
   };
   
   
});

