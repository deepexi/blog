# 上传 jar 到 maven 中心仓库

## 一、前奏准备

了解几个 maven 相关地址：

- [工单管理地址](https://issues.sonatype.org/)，就是申请上传资格和 groupId 的地方，没有账号的要先从这个地址里面注册账号
- [构建仓库](<https://oss.sonatype.org/#welcome>)，把 jar 包上传到这里，Release 之后就会同步到 maven 中央仓库
- [中心仓库查找地址](<http://search.maven.org/>)，最终表现在这里可以搜索到

## 二、创建工单

没有账号的先去[工单管理地址]([https://issues.sonatype.org](https://issues.sonatype.org/))注册账号，**账密要记住**。

![创建issue](https://raw.githubusercontent.com/deepexi/blog/master/source/_posts/image/创建issue.png)

- **Group Id**，唯一标识，采用 com.github.xxxxx 会比较方便，也可以使用自己的网站
- **ProjectURL**，填写项目地址，如果不想公开源码，填写一个只含 README 的项目的地址就可以了。

***其实管理员主要是审核 Group Id***

![创建issue](https://raw.githubusercontent.com/deepexi/blog/master/source/_posts/image/issue审核结果.png)

这里可以看到审核结果，第一次审核有可能会需要比较长的时间，因为时差可能需要一天左右。