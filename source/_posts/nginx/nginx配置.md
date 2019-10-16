---
title: nginx配置
date: 2019-09-30 20:21:17
updated: 2019-09-30 20:21:17
tags:
- 后端
- 服务器
categories:
- nginx
---

## 整体结构

Nginx配置文件的整体结构包含以下几个部分

### 1、全局块

该部分配置主要影响`Nginx`全局，通常包括下面几个部分

- 配置运行Nginx服务器用户【组】
- worker process数
- Nginx进程PID存放路径
- 错误日志的存放路径
- 配置文件的引入

### 2、events块

该部分配置主要影响Nginx服务器与用户的网络连接，主要包括：

- 设置网络连接的序列化
- 是否允许同时接收多个网络连接
- 时间驱动模型的选择
- 最大连接数的配置

### 3、http块

- 定义MIMI-Type

- 自定义服务日志
- 允许sendfile方式传输文件
- 连接超时时间
- 单连接请求数上限

### 4、server块

- 配置网络监听
- 基于名称的虚拟主机配置
- 基于IP的虚拟主机配置

### 5、location块

- location配置
- 请求根目录配置
- 更改location的URI
- 网站默认首页配置

{% asset_img slug 清单配置.jpg %}

## 配置信息

### 1、配置运行Nginx服务器用户【组】

指令格式

`user user [group];`

- user: 指定可以运行Nginx服务器的用户
- group: 可选项，可以运行Nginx服务器的用户组

如果user指令不配置，或者配置为`user nobody nobody` 则默认所有的用户都可以启动Nginx进程

### 2、worker process数配置

Nginx服务器实现并发处理服务的关键，指令格式：

`worker_processes number | auto;`

- number: Nginx进程最多可以产生的worker process数
- auto: Nginx进程将自动检测

可以通过`ps -aux|grep nginx`查看进程数量

### 3、Nginx进程PID存放路径

Nginx进程是作为系统守护进程在运行，需要在某文件中保存当前运行程序的主进程号，Nginx支持该保存文件路径的自定义，指令格式

`pid file;`

- file: 指定存放路径和文件名称
- 如果不指定默认置于路径`logs/nignx.pid`

### 4、错误日志的存放路径

指定格式

`error_log file | stderr;`

- file: 日志输出到某个文件file
- stderr: 日志输出到标准错误输出

### 5、配置文件的引入

指令格式

`include file;`

- 该指令主要用于将其他的Nginx配置或者第三方模块的配置引用到当前的主配置文件中

### 6、设置网络连接的序列化

指令格式

`accept_mutex on | off;`

- 该指令默认为on状态，表示会对多个Nginx进程接收连接进行序列化，防止多个进程对连接的争抢。

注意：当一个新网络裂解来到时，多个worker进程会被同时唤醒，但仅仅只有一个进程可以真正获得连接并做处理。如果每次唤醒的进程数目过多的话，会影响一部分性能。如果`accept_mutex on`，name多个worker将是以串行的方式来处理，其中只有一个worker会被唤醒；反之若`accept_mutex off`，那么所有的worker都会被唤醒，不过只有一个worker能获取新连接，其他的worker会重新进入休眠状态。

### 7、是否允许同时接收多个网络连接

指令格式

`multi_accept on | off;`

- 该指令默认为off状态，指每个`worker process`一次只能接收一个新到达的网络连接。若想让每个Nginx的workerprocess都有能力同时接收多个网络连接，则需要开启该配置

### 8、事件驱动模型的选择

指令格式

`use model`

- model模型可选择项包括：`selece`, `poll`, `kqueue`, `epoll`, `rtsig`等

### 9、最大连接数的配置

指令格式

`worker_connections number;`

- number默认值为512，表示允许每一个worker process 可以同时开启最大连接数

### 10、定义MIME-Type

指令格式：

`include mime.types;`

`default_type mime-type;`

- MIME-Type指的是网络资源的媒体类型，也即前端请求的资源类型
- include指令将mime.types文件包含进来

mime.types文件内容如下，其实就是一个types结构，里面包含了各种浏览器能够识别的MIME类型以及对应类型的文件名后缀名字

{% asset_img slug mime.typs.jpg %}

### 11、自定义服务日志

指令格式

`access_log path [format];`

- path: 自定义服务日志的路径 + 名称
- format: 可选项，自定义服务日至的字符串格式

### 12、允许sendfile方式传输文件

指令格式

`sendfile on | off;`

`sendfile_max_chunk size;`

- 前者用于开启或关闭使用`sendfile()`传输文件，默认off
- 后者指令若`size>0`，则Nginx进程的每个workerprocess每次调用sendfile()传输的数据最大不能超过此值；若size=0，则表示不限制。默认为0

### 13、连接超时时间配置

指令格式：

`keepalive_timeout timeout [header_timeout]`

- timeout 表示server端对连接的保持时间，默认为75秒
- header_timeout为可选项，表示在应答报文头部的Keep-Alive域设置超时时间`Keep-Alive:time=header_timeout`

### 14、单连接请求数上限

指令格式

`keepalive_requests number;`

- 该指令用于限制用户通过某一个连接向Nginx服务器发起请求的次数

### 15、配置网络监听

指令格式

配置监听IP地址`listen ip[:PORT];`

配置监听端口`listen PORT;`

例如

-  `listen 192.168.31.177:8080;` 

  监听具体IP和具体端口上的连接

- `listen 192.168.31.177;` 

  监听IP上所有端口上的连接

- `listen 8080;`

   监听具体端口上的所有IP的连接

### 16、基于名称和IP的虚拟主机配置

指令格式

`server_name name1 name2 ...`

`server_name IP地址`

- name可以有多个并列名称，而且此处的name支持正则表达式书写

### 17、location配置

指令格式

`location [ = | ~ | ~* | ^~ ] uri {...}`

这里的uri分为标准uri和正则uri，两者的唯一区别是uri中是否包含正则表达式

uri前面的方括号中的内容是可选项，解释如下：

- `=`：用于标准uri前，要求请求字符串与uri严格匹配，一旦匹配成功则停止

- `~`：用于正则uri前，并且区分大小写

- `~*`：用于正则uri前，但不区分大小写
- `^~`：用于标准uri前，要求Nginx找到标识uri和请求字符串匹配度最高的location后，立即使用此location处理请求，而不再使用location块中的正则uri和请求字符串做匹配

### 18、请求根目录配置

指令格式

`root path;`

- path：Nginx接收到请求以后查找资源的根目录路径

还可以通过alias指令来更改location接收到的URI请求路径，指令为：

`alias path;`

- path为修改后的根路径



### 19、设置网站的默认首页

指令格式

`index file ......;`

file可以包含多个用空格隔开的文件名，首先找到哪个页面，就使用哪个页面响应请求

### 附录

#### nginx整体结构

{% asset_img slug 整体结构.jpg %}