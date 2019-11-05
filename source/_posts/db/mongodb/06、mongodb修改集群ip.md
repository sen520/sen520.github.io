---
title: MongoDB修改集群IP
date: 2019-11-05
updated: 2019-11-05
tags:
- 服务器
- 数据库
- 后端
categories:
- 数据库
- mongoDB
---

### 修改集群ip

以单节点模式启动数据库

`mongo 192.168.1.35:27018`

```js
> use local
> db.system.replset.find()
{ "_id" : "lcc2", "version" : 1, "protocolVersion" : NumberLong(1), "members" : [ { "_id" : 1, "host" : "xx.xx.xx.xx:29012", "arbiterOnly" : false, "buildIndexes" : true, "hidden" : false, "priority" : 3, "tags" : {  }, "slaveDelay" : NumberLong(0), "votes" : 1 }, { "_id" : 2, "host" : "xx.xx.xx.xx:29012", "arbiterOnly" : false, "buildIndexes" : true, "hidden" : false, "priority" : 2, "tags" : {  }, "slaveDelay" : NumberLong(0), "votes" : 1 }, { "_id" : 3, "host" : "xx.xx.xx.xx:29012", "arbiterOnly" : false, "buildIndexes" : true, "hidden" : false, "priority" : 1, "tags" : {  }, "slaveDelay" : NumberLong(0), "votes" : 1 } ], "settings" : { "chainingAllowed" : true, "heartbeatIntervalMillis" : 2000, "heartbeatTimeoutSecs" : 10, "electionTimeoutMillis" : 10000, "getLastErrorModes" : {  }, "getLastErrorDefaults" : { "w" : 1, "wtimeout" : 0 }, "replicaSetId" : ObjectId("5c24cbaa2045a8fe36840702") } }
// 修改为新集群IP
> cfg={ "_id" : "lcc2", "version" : 1, "protocolVersion" : NumberLong(1), "members" : [ { "_id" : 1, "host" : "xx.xx.xx.xx:29012", "arbiterOnly" : false, "buildIndexes" : true, "hidden" : false, "priority" : 3, "tags" : {  }, "slaveDelay" : NumberLong(0), "votes" : 1 }, { "_id" : 2, "host" : "xx.xx.xx.xx:29012", "arbiterOnly" : false, "buildIndexes" : true, "hidden" : false, "priority" : 2, "tags" : {  }, "slaveDelay" : NumberLong(0), "votes" : 1 }, { "_id" : 3, "host" : "xx.xx.xx.xx:29012", "arbiterOnly" : false, "buildIndexes" : true, "hidden" : false, "priority" : 1, "tags" : {  }, "slaveDelay" : NumberLong(0), "votes" : 1 } ], "settings" : { "chainingAllowed" : true, "heartbeatIntervalMillis" : 2000, "heartbeatTimeoutSecs" : 10, "electionTimeoutMillis" : 10000, "getLastErrorModes" : {  }, "getLastErrorDefaults" : { "w" : 1, "wtimeout" : 0 }, "replicaSetId" : ObjectId("5c24cbaa2045a8fe36840702") } }
> db.system.replset.update({"_id":"lcc2”},cfg)
```

然后重启

### 修改副本集ip

添加副本，在登录到主节点下输入

```
rs.add("ip:port");
```

删除副本

```
rs.remove("ip:port");
```

新增仲裁节点

```
rs.addArb("ip:port");
```

修改副本host

```js
shard1:PRIMARY> cfg = rs.conf()
{
        "_id" : "shard1",
        "version" : 5,
        "protocolVersion" : NumberLong(1),
        "members" : [
                {
                        "_id" : 0,
                        "host" : "127.0.0.1:2777",
                        "arbiterOnly" : false,
                        "buildIndexes" : true,
                        "hidden" : false,
                        "priority" : 1,
                        "tags" : {

                        },
                        "slaveDelay" : NumberLong(0),
                        "votes" : 1
                }
        ],
        "settings" : {
                "chainingAllowed" : true,
                "heartbeatIntervalMillis" : 2000,
                "heartbeatTimeoutSecs" : 10,
                "electionTimeoutMillis" : 10000,
                "getLastErrorModes" : {

                },
                "getLastErrorDefaults" : {
                        "w" : 1,
                        "wtimeout" : 0
                },
                "replicaSetId" : ObjectId("5d9c7a7e76695600e03e231f")
        }
}


shard1:PRIMARY> cfg.members[0].host = "10.13.10.2:2777"
10.130.10.72:2777
shard1:PRIMARY> rs.reconfig(cfg)
{ "ok" : 1 }
shard1:PRIMARY> rs.status()
{
        "set" : "shard1",
        "date" : ISODate("2019-10-09T02:59:26.916Z"),
        "myState" : 1,
        "term" : NumberLong(1),
        "heartbeatIntervalMillis" : NumberLong(2000),
        "members" : [
                {
                        "_id" : 0,
                        "name" : "10.130.10.72:2777",
                        "health" : 1,
                        "state" : 1,
                        "stateStr" : "PRIMARY",
                        "uptime" : 54711,
                        "optime" : {
                                "ts" : Timestamp(1570589961, 1),
                                "t" : NumberLong(1)
                        },
                        "optimeDate" : ISODate("2019-10-09T02:59:21Z"),
                        "electionTime" : Timestamp(1570536062, 2),
                        "electionDate" : ISODate("2019-10-08T12:01:02Z"),
                        "configVersion" : 6,
                        "self" : true
                }
        ],
        "ok" : 1
}
```

