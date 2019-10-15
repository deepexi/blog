---
title: DeepEXI脚手架工具介绍
date: 2019-10-15 10:03:24
tags:
categories:
- scaffold
---

# DeepEXI 脚手架工具

## 概念

- 脚手架工具：指的是用于生成脚手架的工具
- 脚手架：项目雏形，一般基于脚手架可以直接开始开发工作

## 介绍

DeepEXI脚手架工具是用于微服务架构环境下，为快速开发而准备的一件利器。

基于我们的脚手架工具，您可以快速、按需地集成业界主流的框架或中间件以生成定制的脚手架，减少大量的前期项目环境的搭建时间成本。

如果您购买了我们的其它产品（如业务中台、数据中台），也可以通过脚手架工具快速地进行集成。

我们提供了多种方式方便您使用我们的脚手架工具，例如CLI、UI或DevOps。无论是新手还是大牛，研发还是产品，相信总有一种使用方式适合您。

我们的所有脚手架工具都是开源的，如果有好的需求、建议，欢迎前往各项目主页提issue或pr。

### 相关链接

- [spring cloud](https://github.com/deepexi/generator-deepexi-spring-cloud)
- [dubbo](https://github.com/deepexi/generator-deepexi-dubbo)
- [eggjs](https://github.com/deepexi/generator-deepexi-eggjs)
- [scaffold ui](https://github.com/deepexi/deepexi-scaffold-ui)

### 其它使用场景

除了用于实际开发外，您还可以将脚手架用于以下场景

#### 学习

我们的脚手架几乎对大多数的集成项都提供了相关的使用demo及文档，通过这些内容，您可以快速的学习一些尚不熟悉的框架的使用方式，快速扩宽您的知识面。

#### 实验性项目

许多时候，我们会突然想到一些好的点子，但这个点子的试验往往要创建一个新的项目来进行（担心弄乱现有项目），并且可能有许多麻烦的依赖要配置，而这个项目往往在验证完想法后就会被舍弃，为此花这么多时间来搭建实在不值得。这个时候，使用我们的脚手架工具就可以为您解决这个问题。

## 如何使用

> 以下说明均以[spring cloud脚手架工具](https://github.com/deepexi/generator-deepexi-spring-cloud)为例

### CLI

需要node.js环境

    ```sh
    $ npm install -g yo
    $ npm install -g generator-deepexi-spring-cloud
    $ mdir demo
    $ cd demo
    $ yo deepexi-spring-cloud
    ```

接下来按照交互模式的指引操作，即可生成属于你的脚手架

![scaffold cli](/images/scaffold_cli.jpg)

### UI

#### 本地部署

```sh
$ npm install -g yo
$ npm install deepexi-scaffold-ui -g
$ scaffold-ui start -p 7001 -s
```

等待web应用运行，访问 localhost:7001/index.html

第一次访问页面时需要读取脚手架工具的相关信息，可能会比较缓慢，请耐心等候，加载过一次之后就很快了。

![scaffold ui index](/images/scaffold_ui_index.jpg)

![scaffold ui sc](/images/scaffold_ui_sc.jpg)

#### 在DeepEXI DevOps上使用

TODO:: 待补充

## 其它示例截图

项目结构

![project structure](/images/project_structure.jpg)

Swagger运行时文档

![swagger](/images/swagger.jpg)


