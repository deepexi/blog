---
title: 脚手架集成 consul

---

   # 脚手架集成 consul

> consul 是一个用Go语言编写的可以自动化网络配置，服务发现并连接云容器的软件
> 

 *为什么选择 consul ？*
 ✅服务发现 |  ✅储存数据元空间 | ✅集成Kubernetes | ✅健康检查 | ✅动态负载均衡 

## 安装generator-deepexi-spring-cloud相关依赖
### 安装yeoman
`` $ npm install -g yo ``

### 安装generator-deepexi-spring-cloud
 ``$ npm install -g generator-deepexi-spring-cloud ``

## 下载consul到本地并启动consul:
```docker
docker pull consul:latest 
docker run -d -p 8500:8500/tcp consul agent -server -ui -bootstrap-expect=1 -client=0.0.0.0
```

## 下载脚手架代码
```shell
mkdir {your folder}
cd {your folder}
git clone https://github.com/deepexi/generator-deepexi-spring-cloud.git
git checkout develop
```
## 调试模式启动脚手架

```shell
npm link 
```
即可将本地项目代替 npm module 中对应的包

## 利用脚手架创建生产者项目
```
mkdir consul-producer
$ cd consul-producer
$ yo deepexi-spring-cloud
```
-  根据交互任务调度类型选择 consul，生成 demo 选择 y.

- 修改applicaition.yml
	- spring.application.name 是consul首页上显示的service name，为了便于识别修改为spring-cloud-consul-producer
	- 由于consul的健康检查实际上依赖的是actuator，所以还要配置actuator。脚手架默认引入了actuator的依赖及配置， 所以我们只需设置其服务端口即可
		 ```yml
		 spring:
		  application:
			name: spring-cloud-consul-producer

		server:
		  port: 8086
		management:
		  server:
			port: 8083 
		```


 - 修改applicaition-local.yml
	  - 注意的是，如果想要management-port生效，服务需和consul处于同一集群下
  ```yml
    spring:
	  cloud:
		consul:
		  discovery:
			register-health-check: true
			register: true
			enabled: true
			management-port: 8083
  ```


|  属性名   |   说明   |
| --- | --- |
|   register-health-check     |  注册健康检查   |
|   register  |  注册为consul服务   |
|  enabled   |  是否启用服务发现   |
|  management-port    |  端口注册管理服务（即为actuator端口）   |

  - 新增代码清单：
    用于给生产者调用的接口 
 ```java
 @RestController
@Payload
public class ProducerController {

    @GetMapping("/hello")
    public String hello() {
        return "hello consul from producer";
    }
}

 ```
 ## 利用脚手架创建消费者项目
 ```
mkdir consul-consumer
$ cd consul-consumer
$ yo deepexi-spring-cloud
 ```
-  根据交互任务调度类型选择 consul，生成 demo 选择 y.
 
- 修改applicaition.yml
 ```yml
spring:
  application:
    name: spring-cloud-consul-consumer
	
server:
  port: 8080
management:
  server:
    port: 8081
 ```
 - 修改applicaition-local.yml
  ```yml
    spring:
          cloud:
            consul:
              discovery:
                register-health-check: true
                register: true
                enabled: true
                management-port: 8081
  ```
  - 新增代码清单：
      远程调用生产者接口的接口
 ```java
 @Payload
@RestController
class ConsumerController {
    @Autowired
    private LoadBalancerClient loadBalancer;

    @Bean
    @LoadBalanced
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    @Autowired
    private RestTemplate restTemplate;

    @RequestMapping("/call")
    public String call() {
        ServiceInstance serviceInstance = loadBalancer.choose("spring-cloud-consul-producer");
        System.out.println("Hostname:" + serviceInstance.getUri());
        System.out.println("service name:" + serviceInstance.getServiceId());

        String serviceResult1 = 
		new RestTemplate().getForObject(serviceInstance.getUri().toString() + "/hello", String.class);
        String serviceResult2 = 
		restTemplate.getForObject("http://spring-cloud-consul-producer/hello", String.class);
        return serviceResult1;
    }
}
 ```
服务发现相关接口：
```java
@Payload
@RestController
public class ServiceController {
    
    @Autowired
    private LoadBalancerClient loadBalancerClient;
    
    @Autowired
    private DiscoveryClient discoverClient;

    @RequestMapping("/services")
    public Object services() {
        return discoverClient.getInstances("spring-cloud-consul-producer");
    }

    @RequestMapping("/discover")
    public Object discover() {
        return loadBalancerClient.choose("spring-cloud-consul-producer").getUri().toString();
    }
}
```

## 运行项目并测试
ok，当走到这一步已经差不多要大功告成了：）

 - 将两个项目启动，并打开 http://localhost:8500/ui
 ![consul首页](/images/1593761510458.png)
 首页出现了绿色的打钩即说明健康检查正常

 - 测试远程调用接口
	  ```bash
	  curl -X GET "http://localhost:8080/call" -H "accept: */*"
	```
	  返回以下信息即说明调用链路没有问题
	  ```json
	{
		  "code": "1",
		  "payload": "{\"code\":\"1\",\"payload\":\"hello consul from producer\",\"success\":true}",
		  "success": true
	}
	  ```
   
  - 测试服务发现接口
    ```bash
	curl -X GET "http://localhost:8080/services" -H "accept: */*"
	```
	返回以下信息则说明服务发现成功：
	```json
	{
	  "code": "1",
	  "payload": [
		{
		  "serviceId": "spring-cloud-consul-producer",
		  "host": "DESKTOP-J4VTE9I",
		  "port": 8086,
		  "secure": false,
		  "metadata": {
			"secure": "false"
		  },
		  "uri": "http://DESKTOP-J4VTE9I:8086",
		  "scheme": null
		}
	  ],
	  "success": true
	}
	```