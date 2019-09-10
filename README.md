# DeepEXI Team Blog

## 简介

为了方便团队间的技术交流与共享，采用 Hexo 与 github 实现开源博客项目的快速构建与发布。

## 环境准备

- Git: v2.21.0

- Node.js: v6.9.0

## 使用教程

1. clone 该项目

   ```bash
   $ git clone https://github.com/deepexi/blog.git
   ```

2. 安装 hexo

   ```bash
   $ npm install hexo --save
   ```

3. 写博文

   ```bash
   $ hexo new 'my_post'
   ```

4. 本地启动

   ```bash
   $ hexo s [g]
   $ open http://localhost:4000
   # 或者直接使用脚本启动
   $ ./deploy.sh
   ```

5. 部署到服务器

   ```bash
   $ hexo d
   $ open https://deepexi.github.io
   ```

