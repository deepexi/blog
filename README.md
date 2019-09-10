# Team Blog

## 简介

为了方便团队间的技术交流与共享，采用 Hexo 与 github 实现开源博客项目的快速构建与发布

## 环境准备

- Git: v2.21.0

- Node.js: v6.9.0

## 使用教程

1. clone 该项目

   ```bash
   git clone https://github.com/deepexi/blog.git
   ```

2. 安装 hexo

   ```bash
   npm install hexo --save
   ```

3. 将本地编辑好的 blog 放到指定位置：blog(项目开始位置) -->> source -->>_posts

4. 根据模板生成 blog

   ```bash
   hexo g
   ```

5. 发布 blog

   ```bash
   hexo d
   ```

通过访问 <https://deepexi.github.io/> 即可查看已发布的文件