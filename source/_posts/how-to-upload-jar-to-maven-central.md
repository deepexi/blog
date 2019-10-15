---
title: 上传 jar 到 maven 中心仓库
date: 2019-09-10 17:09:17
tags:
    - maven
categories:
    - maven
---

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

![创建issue](https://raw.githubusercontent.com/deepexi/blog/master/source/_posts/image/issue审核状态.png)

这里可以看到审核结果，第一次审核有可能会需要比较长的时间。

## 三、配置 Maven Settings.xml & pom.xml

### 1. 配置 Maven 中的 conf/setting.xml

```xml
 <server>
    <id>sonatype-nexus-snapshots</id>
    <username>https://issues.sonatype.org的账号</username>
    <password>https://issues.sonatype.org的密码</password>
  </server>
  <server>
    <id>sonatype-nexus-staging</id>
    <username>https://issues.sonatype.org的账号</username>
    <password>https://issues.sonatype.org的密码</password>
  </server>
```

### 2. 配置使用项目中的 pom.xml

```xml
<parent>
	<groupId>org.sonatype.oss</groupId>
	<artifactId>oss-parent</artifactId>
	<version>7</version>
</parent>

<licenses>
	<license>
		<name>The Apache Software License, Version 2.0</name>
		<url>http://www.apache.org/licenses/LICENSE-2.0.txt</url>
		<distribution>repo</distribution>
	</license>
</licenses>

<!--写你自己的，这只是个例子-->
 <scm>
     <url>https://github.com/taccisum/shiro-starter</url>
     <connection>https://github.com/taccisum/shiro-starter.git</connection>
     <developerConnection>https://github.com/taccisum</developerConnection>
  </scm>
<!--写你自己的，这只是个例子-->
<developers>
    <developer>
        <name>taccisum</name>
        <email>514162920@qq.com</email>
        <url>https://taccisum.github.io</url>
    </developer>
</developers>
```

## 四、GPG 环境

需要安装一个 GPG 环境，用来对上传的文件进行加密和签名，防止 jar 包被篡改。[GPG下载地址](<https://www.gpg4win.org/>)

```bash
# 查看是否安装完成
$ gpg -version
# 生成 gen-key
$ gpg --gen-key
# 查看本地秘钥
$ gpg --list-keys
pub   rsa2048 2019-04-20 [SC] [有效至：2021-04-19]
      [xxxxxxxxx]
uid           [ 绝对 ] itmuch.com <eacdy0000@126.com>
sub   rsa2048 2019-04-20 [E] [有效至：2021-04-19]
```

过程中需要填写一个密码，打包上传的时候需要用到

## 五、发布

执行如下命令即可将依赖发布到中央仓库

```bash
mvn clean install deploy -P release
```

不出意外，构建会报xxx服务器无法找到GPG的异常。原因是前文生成的秘钥尚未发布到key server。keyserver的地址会在异常中打印出来。我的项目报的是 `http://keys.gnupg.net:11371/` 。于是执行

```bash
gpg --keyserver  http://keys.gnupg.net:11371/ --send-keys [xxxxxxxxx]
其中的[xxxxxxxxx]，可用gpg --list-keys显示出来。
```

然后在执行

```bash
mvn clean install deploy -P release
```

此时即可发布成功。

若要修改发布的版本

```bash
mvn versions:set -DnewVersion=1.0.2-SNAPHOST
```



