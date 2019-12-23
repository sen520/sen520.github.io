---
title: linux升级node版本
date: 2019-12-23
tags:
- 后端
- nodejs
- javascript
- linux
categories:
- javascript
- nodejs
---

#### 问题

在docker容器中启动node项目，但不希望每次都要`npm i`，所以要把源代码采用挂载的方式，放在镜像中。

需要在服务器中`npm i`，之后启动容器，结果报错了，原因是node版本不对。

后来采用了先挂载安装包，后再启动容器。

其实我们可以选择升级一下本地主机的node版本就方便多了

#### 升级node

`node -v`

1. 首先清理npm的缓存

   `npm cache clean -f`

2. 安装版本管理工具

   `npm install -g n`

3. 更新到最新的版本

   `n latest`

   ```
   n 常用的命令有：
   n 会列出所有安装的版本供你切换
   n latest 安装最新版本
   n stable 安装最新稳定版
   n lts 安装最新长期支持版本
   n rm [版本号] 删除某一版本
   n -h 帮助命令
   n [版本号] 安装指定版本node
   ```

4. 查看node安装路径

   `which node`

5. 配置环境

   `vim ~/.bash_profile`

   添加下面语句

   ```
   export N_PREFIX=/usr/local/node-v7.10.0-linux-x64 #第4步显示的路径
   export PATH=$N_PREFIX/bin:$PATH
   ```

6. 执行source使修改生效

   `source ~/.bash_profile`

7. 检查node，如果版本已更新，那就配置结束，如果未更新，则执行以下语句

   `n stable`


#### 升级npm

`npm i -g npm` 或者指定npm 版本 `npm i -g npm@5.0.0`