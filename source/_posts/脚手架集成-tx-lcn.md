---
title: generator-deepexi-spring-cloud 脚手架集成 TX-LCN
tags: 
 
grammar_cjkRuby: true
---
 # generator-deepexi-spring-cloud 脚手架集成 TX-LCN

> TX-LCN定位于一款事务协调性框架，框架其本身并不操作事务，而是基于对事务的协调从而达到事务一致性的效果。

 *为什么选择  TX-LCN？*
 - 性能优秀
 - 可靠性强
 - 支持LCN、TCC、TXC等事务模式，代码侵入性低

如下演示简单的LCN分布式事务：
 ## 步骤引导
- 准备依赖环境服务
JDK1.8+,Mysql5.6+,Redis3.2+,Consul(SpringCloud),ZooKeeper(Dubbo),Git,Maven
- 初始化数据 
- 启动TxManager(TM)
- 配置微服务模块

## 初始化数据
- TM数据初始化
TxManager(TM) 依赖 tx-manager 数据库 (MariaDB 、MySQL) 建表语句如下:
``` sql
DROP TABLE IF EXISTS `t_tx_exception`;
CREATE TABLE `t_tx_exception`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `unit_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `mod_id` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `transaction_state` tinyint(4) NULL DEFAULT NULL,
  `registrar` tinyint(4) NULL DEFAULT NULL COMMENT '-1 未知 0 Manager 通知事务失败， 1 client询问事务状态失败2 事务发起方关闭事务组失败',
  `ex_state` tinyint(4) NULL DEFAULT NULL COMMENT '0 待处理 1已处理',
  `create_time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 967 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;
```
TC 数据初始化, 微服务（服务A，服务B）演示 Demo 依赖 txlcn-dem o数据库 (MariaDB 、MySQL) 建表语句如下:

``` sql
DROP TABLE IF EXISTS `t_demo`;
CREATE TABLE `t_demo` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `kid` varchar(45) DEFAULT NULL,
  `demo_field` varchar(255) DEFAULT NULL,
  `group_id` varchar(64) DEFAULT NULL,
  `unit_id` varchar(32) DEFAULT NULL,
  `app_name` varchar(32) DEFAULT NULL,
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;
```

## 启动 TxManager(TM)
- TM下载与配置
git clone https://github.com/codingapi/tx-lcn.git

- 修改配置信息 (txlcn-tm\src\main\resources\application.properties)

``` yml
spring.application.name=tx-manager
server.port=7970

spring.datasource.driver-class-name=com.mysql.jdbc.Driver
spring.datasource.url=jdbc:mysql://127.0.0.1:3306/tx-manager?characterEncoding=UTF-8
spring.datasource.username=root
spring.datasource.password=root

mybatis.configuration.map-underscore-to-camel-case=true
mybatis.configuration.use-generated-keys=true

#tx-lcn.logger.enabled=true
# TxManager Host Ip
#tx-lcn.manager.host=127.0.0.1
# TxClient连接请求端口
#tx-lcn.manager.port=8070
# 心跳检测时间(ms)
#tx-lcn.manager.heart-time=15000
# 分布式事务执行总时间
#tx-lcn.manager.dtx-time=30000
#参数延迟删除时间单位ms
#tx-lcn.message.netty.attr-delay-time=10000
#tx-lcn.manager.concurrent-level=128
# 开启日志
#tx-lcn.logger.enabled=true
#logging.level.com.codingapi=debug
#redisIp
#spring.redis.host=127.0.0.1
#redis\u7AEF\u53E3
#spring.redis.port=6379
#redis\u5BC6\u7801
#spring.redis.password=
```

## TM 编译与启动
- 编译
进入到txlcn-tm路径下。 执行 mvn clean package '-Dmaven.test.skip=true'
- 启动
进入target文件夹下。执行 java -jar txlcn-tm-5.0.0.jar
- 启动TxManager


## 配置微服务模块
###  代码清单
####  服务A

``` java
spring:
  application:
    name: txlcn-demo-spring-service-a
```

``` java
spring:
  cloud:
    consul:
      discovery:
        register: true
        enabled: true
        register-health-check: false
  datasource:
    username: root
    password: root
    url: 'jdbc:mysql://127.0.0.1:3306/txlcn-demo'
```

``` java
  @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }
```

``` java
@RestController
@Payload
public class DemoController {

    private final DemoService demoService;

    @Autowired
    public DemoController(DemoService demoService) {
        this.demoService = demoService;
    }

    @RequestMapping("/txlcn")
    public String execute(@RequestParam("value") String value, @RequestParam(value = "ex", required = false) String exFlag) {
        return demoService.execute(value, exFlag);
    }


}
```

``` java
@AllArgsConstructor
@NoArgsConstructor
@Data
public class Demo {
    private Long id;
    private String kid = RandomUtils.randomKey();
    private String demoField;
    private String groupId;
    private Date createTime;
    private String appName;

}
```

 

``` java 
@Mapper
public interface DemoMapper  {
  @Insert("insert into t_demo(kid, demo_field, group_id, create_time,app_name) values(#{kid}, #{demoField}, #{groupId}, #{createTime},#{appName})")
    void save(Demo demo);
}

```

``` java
public interface DemoService {
    String execute(String value, String exFlag);
}
```

可以发现的是，想要开启TX-LCN的LCN事务功能，即在想要开启的地方加上 @LcnTransaction 注解

``` java
@Service
@Slf4j
public class DemoServiceImpl implements DemoService {
    @Autowired
    private DemoMapper demoMapper;

    @Autowired
    private RestTemplate restTemplate;

    @LcnTransaction//分布式事务
    @Transactional //本地事务
    @Override
    public String execute(String value, String exFlag) {
        // step1. call remote service B
        String bResp = restTemplate.getForObject("http://127.0.0.1:8083/rpc?value=" + value, String.class);

        // step2. local store operate. DTX commit if save success, rollback if not.
        Demo demo = new Demo();
        demo.setGroupId(TracingContext.tracing().groupId());
        demo.setDemoField(value);
        demo.setCreateTime(new Date());
        demo.setAppName(Transactions.getApplicationId());
        demoMapper.save(demo);

        // 置异常标志，DTX 回滚
        if (Objects.nonNull(exFlag)) {
            throw new IllegalStateException("by exFlag");
        }

        return bResp + " > " + "ok-A";
    }
}
```

#### 服务B

``` java
spring:
  application:
    name: txlcn-demo-spring-service-b
server:
  port: 8083
  
management:
  server:
    port: 8086
```

``` java
spring:
  cloud:
    consul:
      discovery:
        register: true
        enabled: true
        register-health-check: false
  datasource:
    username: root
    password: root
    url: 'jdbc:mysql://127.0.0.1:3306/txlcn-demo'
```

``` java
@RestController
@Payload
public class DemoController {

    @Autowired
    private DemoService demoService;

    @GetMapping("/rpc")
    public String rpc(@RequestParam("value") String value) {
        return demoService.rpc(value);
    }
}
```

``` java
@AllArgsConstructor
@NoArgsConstructor
@Data
public class Demo {
    private Long id;
    private String kid = RandomUtils.randomKey();
    private String demoField;
    private String groupId;
    private Date createTime;
    private String appName;

}

```


``` java
@Mapper
public interface DemoMapper{
  @Insert("insert into t_demo(kid, demo_field, group_id, create_time,app_name) values(#{kid}, #{demoField}, #{groupId}, #{createTime},#{appName})")
    void save(Demo demo);
}
```

``` java
@Service
@Slf4j
public class DemoServiceImpl implements DemoService {

    private final DemoMapper demoMapper;

    @Autowired
    public DemoServiceImpl(DemoMapper demoMapper) {
        this.demoMapper = demoMapper;
    }

    @Override
    @LcnTransaction//分布式事务
    @Transactional //本地事务
    public String rpc(String value) {
        Demo demo = new Demo();
        demo.setGroupId(TracingContext.tracing().groupId());
        demo.setDemoField(value);
        demo.setAppName(Transactions.getApplicationId());
        demo.setCreateTime(new Date());
        demoMapper.save(demo);
        return "ok-service-b";
    }
}

```

``` java
public interface DemoService {
    String rpc(String value);
}
```

## 启动模块与测试
### 正常提交事务

访问服务A提供的Rest接口 http://localhost:8080/txlcn?value=111
发现事务全部提交。


### 回滚事务
访问服务A提供的接口 http://localhost:8080/txlcn?value=111&ex=1
在返回结果前抛出了异常，发现由于本地事务回滚，而参与方B也被TX-LCN回滚数据

 