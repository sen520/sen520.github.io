---
title: ES相关配置
date: 2020-01-09
tags:
- 后端
- 查询
- ES
categories:
- ES
---

## 1.设置最大返回条数

在ElasticSearch中一般做分页查询，通过from和size进行实现，from指定从哪一行开始，size指定一次读取多少。

但是有时候需要返回较多的数据，并不知道具体的数量，所以需要将size设定的足够大，但是ES最大查询结果只能到10000，这个是因为es的配置中的`index.max_result_window`的最大默认值是10000。

需要修改该值（或添加）

首先查询配置项(这里我的index为platform)：

```js
GET /127.0.0.1:9200/platform/_settings

{
    "platform": {
        "settings": {
            "index": {
                "number_of_shards": "5",
                "provided_name": "platform-alpha",
                "creation_date": "1578477702787",
                "number_of_replicas": "1",
                "uuid": "gG9VqLXVQsG9dV3e9CATKA",
                "version": {
                    "created": "5061699"
                }
            }
        }
    }
}
```

可以看到并没有这个配置项，所以我们需要添加该配置

```js
PUT /127.0.0.1:9200/platform/_settings
{
	"index": {
		"max_result_window": 2147483647
	}
}
```

**注意：**ES支持最大返回数目是`2 ^ 31 - 1`，也就是2147483647