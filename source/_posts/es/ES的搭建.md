---
title: ES的搭建
date: 2019-09-15 22:20:25
updated: 2019-09-15 22:20:25
tags:
- 后端
- 查询
- 服务器
- ES
categories:
- ES
---

## 1、搭建ES

采用docker-compose的方式搭建

```
# elasticsearch will server as the index search db
# kibana will server as the web ui of elasticsearch
# the version of the elasticsearch and kibana should be equal

elasticsearch:
    image: elasticsearch:5.6
    mem_limit: 1024m
    environment:
     - TZ=Asia/Shanghai
    ports:
     - "9200:9200"
    expose:
        - "9200"
        - "9300"

kibana:
    image: kibana:5.6
    ports:
     - "5601:5601"
    links:
     - elasticsearch
```

## 2、设置连接

这里是连接的mongodb数据库，要求mongodb数据库必须是集群，采用mongo-connector的方式连接

有关oplog全量导入的[官方](https://github.com/yougov/mongo-connector/wiki/Oplog-Progress-File)解释，大概就是说，当oplog.timestamp文件不存在的时候，将会采用全量导入。

这里有一个注意点，mongo-connector是通过oplog的方式进行数据同步，所以，所要链接的数据库必须是集群。

创建mongo-connector的Dockerfile

```
FROM ubuntu:18.04
ENV LANG C.UTF-8

RUN apt update
RUN apt install vim -y
RUN apt install python3 -y \
    && apt install python3-pip -y \
             && pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple 'mongo-connector[elastic5]' && pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple 'elastic2-doc-manager'
CMD mongo-connector -c /root/data/config
```

- 创建镜像

`docker build -t mongo-connector .`

- 配置文件

```
{
    "mainAddress": "",
    "oplogFile": "/root/data/log/oplog.timestamp",
    "continueOnError": true,
    "fields": [
        "name",
        "abs",
        "intro",
        "nick",
        "type",
        "asset.type",
        "_deleted",
        "portfolio.type"
    ],
    "namespaces": {
        "data.entity": true
    },
    "logging": {
        "type": "file",
        "filename": "/root/data/log/mongo-connector.log"
    },
    "docManagers": [
        {
            "docManager": "elastic2_doc_manager",
            "targetURL": "esurl",
            "uniqueKey": "_id",
            "autoCommitInterval": 0
        }
    ]
}

- mainAddress 为mongo集群的链接
- oplogFile 为mongo-connector每次执行的数据操作的时间戳
- continueOnError 出错后是否继续
- fields 同步的字段
- namespaces 同步的数据库和表
- logging 以mongo-connector 的操作日志
- docManagers 数据插入的格式，包括唯一键的设置，数据同步的时间（单位是s），默认是只同步一次，0为实时同步（实时指的是mongo-connector检测到所连接的数据库oplog有变化，由于连接的是数据库的副本集，所以这里的变化指的是副本集的oplog的变化）
```

[配置信息](https://github.com/yougov/mongo-connector/wiki/Configuration-Options)

[样例](https://github.com/yougov/mongo-connector/blob/master/mongo_connector/service/config.json)

- 运行容器

  `docker run  --restart=always -d -v /workspace/ES:/root/data mongo-connector:latest`