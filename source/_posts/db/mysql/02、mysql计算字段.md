---
title: mysql计算字段
date: 2019-12-12
tags:
- 数据库
- 后端
- mysql
categories:
- 数据库
- mysql
---

## 计算字段

存储在数据库表中的数据一般不是应用程序所需要的格式。

- 如果想在一个字段中既显示公司名，又显示公司的地址，但是这两个信息一般包含在不同的表列中。
- 城市、州和邮政编码存储在不同的列中，但邮件标签打印程序却需要把它们作为一个恰当格式的字段检索出来。
- 列数据是大小写混合的，但报表程序需要把所有数据按大写表示出来
- 物品订单表存储物品的价格和数量，但不需要存储每个物品的总价格（用价格乘以数量即可）。
- 根据表数据进行总数，平均数计算或其他计算

### 1. 拼接字段

举例：vendors表中包含供应商名和位置信息。假如要生成一个供应商报表，需要在供应商的名字中按照name(location)这样的格式列出供应商的位置。

此报表需要单个值，而表中数据存储在两个列`vend_name`和`vend_country`中。此外，需要用括号将`vend_country`括起来。

#### 拼接

可以使用`Contcat()`函数来拼接两个列

`SELECT Concat(vend_name, ' (', vend_country, ')') FROM vendors ORDER BY vend_name;`

同时，我们需要删除数据右侧多余的空格，可以使用`RTrim()`来完成

`SELECT Concat(RTrim(vend_name), ' (', RTrim(vend_country), ')') FROM vendors ORDER BY vend_name;`

去除空格还可以用`LTrim()`去掉左边的空格，`Trim()`去掉右边的空格

#### 使用别名

`SELECT Concat(RTrim(vend_name), ' (', RTrim(vend_country), ')') AS vend_title FROM vendors ORDER BY vend_name;`

### 2. 执行算术计算

orders表包含收到的所有订单，orderitems表包含每个订到的各项物品。下面的SQL语句检索订单号20005中的所有物品

`SELECT prod_id, quantity, item_price FROM orderitems WHERE order_num = 20005;`

{% asset_img slug 1576122299642.png %}

item_prict 列包好订单中每项物品的单价，如下可以汇总物品的价格

`SELECT prod_id, quantity, item_price, quantity*item_price AS expanded_price FROM orderitems WHERE order_num = 20005;` 

#### MySQL算术操作符

| 操作符 | 说明 |
| ------ | ---- |
| +      | 加   |
| -      | 减   |
| *      | 乘   |
| /      | 除   |

#### Tips

`SELECT Now();` 会利用`Now()`函数返回当前日期和时间