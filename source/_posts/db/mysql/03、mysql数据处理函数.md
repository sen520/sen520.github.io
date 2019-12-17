---
title: mysql数据处理函数
date: 2019-12-12
tags:
- 数据库
- 后端
- mysql
categories:
- 数据库
- mysql
---

## 函数

SQL支持利用函数来处理数据。函数一般是在数据上执行的，它给数据的转换和处理提供了方便。

### 文本处理函数

| 函数          | 说明              |
| ------------- | ----------------- |
| `Left()`      | 返回串左边的字符  |
| `Length()`    | 返回串的长度      |
| `Locate()`    | 找出串的一个子串  |
| `Lower()`     | 将串转换为小写    |
| `LTrim()`     | 去掉串左边的空格  |
| `Right()`     | 返回串右边的字符  |
| `RTrim()`     | 去掉串右边的空格  |
| `Soundex()`   | 返回串的SOUNDEX值 |
| `SubString()` | 返回子串的字符    |
| `Upper()`     | 将串转换为大写    |

`SELECT vend_name, Upper(vend_name) AS vend_name_upcase FROM vendors ORDER BY vend_name;`

![](http://silencew.cn/uploads/1576129039738.png)

### 日期和时间处理函数

| 函数            | 说明                           |
| --------------- | ------------------------------ |
| `AddDate()`     | 增加一个日期(天、周等)         |
| `AddTime()`     | 增加一个时间(时、分等)         |
| `CurDate()`     | 返回当前日期                   |
| `CurTime()`     | 返回当前时间                   |
| `Date()`        | 返回日期时间的日期部分         |
| `DateDiff()`    | 计算两个日期的差               |
| `Date_Add()`    | 高度灵活的日期运算函数         |
| `Date_Format()` | 返回一个格式化的日期或时间串   |
| `Day()`         | 返回一个日期的天数部分         |
| `DayOfWeek()`   | 对于一个日期，返回对应的星期几 |
| `Hour()`        | 返回一个时间的小时部分         |
| `Minute()`      | 返回一个时间的分钟部分         |
| `Month()`       | 返回一个时间的月份部分         |
| `Now()`         | 返回当前日期和时间             |
| `Second()`      | 返回一个时间的秒部分           |
| `Time()`        | 返回一个日期时间的时间部分     |
| `Year()`        | 返回一个日期的年份部分         |

匹配订单日期在2005-09-01那天：

`SELECT cust_id, order_num FROM orders WHERE Date(order_date) = '2005-09-01';`

订单日期在2005年9月份的：

`SELECT cust_id, order_num FROM orders WHERE Date(order_date) BETWEEN '2005-09-01' AND '2005-09-30';`

也可以按照下面这种写法，这种写法不必考虑一个月有多少天：

`SELECT cust_id, order_num FROM orders WHERE Year(order_date) = 2005 AND Month(order_date) = 9;`

### 数值处理函数

| 函数     | 说明               |
| -------- | ------------------ |
| `Abs()`  | 返回一个数的绝对值 |
| `Cos()`  | 返回一个角度的余弦 |
| `Exp()`  | 返回一个数的指数值 |
| `Mod()`  | 返回除操作的余数   |
| `Pi()`   | 返回圆周率         |
| `Rand()` | 返回一个随机数     |
| `Sin()`  | 返回一个角度的正弦 |
| `Sqrt()` | 返回一个数的平方根 |
| `Tan()`  | 返回一个角度的正切 |

### 聚集函数

| 函数      | 说明             |
| --------- | ---------------- |
| `AVG()`   | 返回某列的平均值 |
| `COUNT()` | 返回某列的行数   |
| `MAX()`   | 返回某列的最大值 |
| `MIN()`   | 返回某列的最小值 |
| `SUM()`   | 返回某列值之和   |

#### AVG() 函数

返回products表中所有产品的平均价格：`SELECT AVG(prod_price) AS avg_price FROM products;`

也可以用来确定特定列或行的平均值。

返回特定供应商所提供的产品的平均价格：

`SELECT AVG(prod_price) AS avg_price FROM products WHERE vend_id = 1003;`

**AVG()函数只能用于单个列，且忽略列值为NULL的行**

#### COUNT() 函数

返回customers表中客户的总数：

`SELETE COUNT(*) AS num_cust FROM customers;`

只对具有电子邮件地址的客户计数：

`SELECT COUNT(cust_email) AS num_cust FROM customers;`

**NULL值，如果制定列名，则制定列的值为空的行被COUNT()函数忽略，但如果COUNT()函数中用的是*，则不忽略。**

#### MAX() 函数

返回products表中最贵的物品的价格：

`SELECT MAX(prod_price) AS max_price FROM products;`

**对非数值数据使用MAX()，虽然MAX()一般用来找出最大的数值或时间，但MySQL允许将它用来返回任意列中的最大值，包括返回文本列中的最大值。用于文本数据时，如果数据按相应的列排序，则返回最后一行**

**MAX() 函数忽略列值为NULL的行**

#### MIN() 函数

正好与MAX()功能相反

`SELECT MIN(prod_price) AS min_price FROM product;`

#### SUM() 函数

`orderitems`表包含订单中实际的物品，每个物品有相应的数量(quantity)。检索所订购物品的总数（所有quantity值之和）:

`SELECT SUM(quantity) AS items_ordered FROM orderitems WHERE order_num = 20005;`

SUM()也可以用来合计计算值。

合计每项物品的`item_price*quantity`，得出总的订单金额(where 保证了只统计某个物品订单中的物品)：

`SELECT SUM(item_price*quantity) AS total_price FROM orderitems WHERE order_num = 20005;`

#### 聚类不同值

- 对所有行执行计算，指定ALL参数或者不给参数。(某人是ALL)
- 只包含不同的值，指定DISTINCT参数。

`SELECT AVG(DISTINCT prod_price) AS avg_price FROM products WHERE vend_id = 1003;`

**注意：**如果指定列名，则DISTINCT只能用于COUNT()。DISTINCT 不能用于COUNT(*)，因此，不允许使用COUNT(DISTINCT)。类似的，DISTINCT必须使用列名，不能用于计算或表达式。

#### 组合聚集函数

```sql
SELECT COUNT(*) AS num_items, 
	   MIN(prod_price) AS price_min, 
	   MAX(prod_price) AS price_max, 
	   AVG(prod_price) AS price_avg 
FROM products;
```

![](http://silencew.cn/uploads/1576139707847.png)

