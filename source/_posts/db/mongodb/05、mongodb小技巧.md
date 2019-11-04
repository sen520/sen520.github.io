---
title: MongoDB小技巧
date: 2019-11-04
updated: 2019-11-04
tags:
- 数据库
- 后端
categories:
- 数据库
- mongoDB
---

- `update`

  - `$push`

    数组指定位置插入数据

    ```js
    test.update({'_id': '0'}, {'$push': {'opId': {'$each': ['1'], '$position': 0}}})
    ```
  
- 关联查询

  - `unwind`：list做分割处理，每有一个元素，就多一个独立的整体

  - `lookup`：管道

  - `facet`：多个管道

    格式：

    `{ $facet: { test1: [...], test2: [...] } }`

  ```js
  user.aggregate([
  	{$match: ''},
  	{$lookup: {
  		from: user,
  		localField: postId,
  		foreignField: _id,
  		as: posts
  	}},
  	{$unwind: $posts}
  ])
  ```

  
