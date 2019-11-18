---
title: Django的QuerySet接口和查询
date: 2019-10-13 15:35:45
updated: 2019-10-13 15:35:45
tags:
- 后端
- python
- django
categories:
- python
- web
- django
---

在Django的model层中，通过给model增加一个objects属性来提供数据操作的接口，比如，想要查询所有文章的数据，`Post.objects.all()`，这样就能拿到QuerySet对象，这个对象包含了我们需要的数据，当我们需要它时，它会去DB中获取数据。

QuerySet本质上是一个懒加载的对象，只有在真正用到的时候才会执行查询。

## 1.  支持链式调用的接口

- `all`：相当于`SELECT * FROM table_name`，用于查询所有数据。
- `filter`：根据条件过滤。
- `exclude`：同`filter`，只是相反的逻辑
- `reverse`：把QuerySet中的结果倒序排列
- `distinct`：用来进行去重查询
- `none`：返回空的QuerySet

## 2. 不支持链式调用的接口

- `get`：比如`Post.objects.get(id=1)`用于查询id为1的文章：如果存在，则直接返回对应的Post实例；如果不存在则抛出DoesNotExist异常
- `create`：直接创建一个Model对象
- `get_or_create`：根据条件查找，如果没有找到，就调用create创建
- `update_or_create`：同`get_or_create`，只是用来做更新操作
- `count`：返回QuerySet有多少记录，相当于`SELECT COUNT(*) FROM table_name`
- `latest`：返回最新的一条记录，但是需要在Model的meta中定义：`get_latest_by = <用来排序的字段0>`
- `earliest`：同上，返回最早的一条记录
- `first`：从当前QuerySet记录中获取第一条
- `last`：同上，获取最后一条
- `exists`：返回 True 或者 False，在数据层面执行`SELECT (1) AS "A" FROM table_name LIMIT 1`的查询，如果只是需要判断QuerySet是否有数据，用这个接口是最合适的方式。不要用 count 或者 len(queryset)这样的操作来判断是否存在。相反，如果可以预期接下来会用到QuerySet中的数据，可以考虑使用len(queryset)的方式来做判断，这样可以减少一次DB查询请求。
- `bulk_create`：同 create，用来批量创建记录
- `in_bulk`：批量查询，接收两个参数`id_list`和`filed_name`。可以通过`Post.objects.in_bulk([1, 2, 3])`查询出id为1、2、3的数据，返回结果是字典类型，字典类型的key为查询条件。
- `update`：根据条件批量更新记录。`Post.object.filter(owner__name='test').update(title='测试更新')`
- `delete`：同update，根据条件批量删除记录
- `values`：当我们明确知道只需要返回某个字段的值，不需要Model实例时。`title_list = Post.objects.filter(category_id=1).values('title')`
- `values_list`：同values，但是直接返回的是包含tuple的QuerySet。`title_list = Post.objects.filter(category=1).values_list('title')`，如果只是一个字段的话，可以通过增加`flat=True`参数，便于我们后续处理。
	```python
title_list = Post.objects.filter(category=1).values_list('title', flat=True)
	for title in title_list:
		print(title)
	```

## 3. 进阶接口

- `defer`：把不需要展示的字段做延迟加载。比如说，需要获取到文章中正文外的其他字段，就可以通过`posts = Post.objects.all().defer('content')`，这样拿到的记录中就不会包含content部分。但当我们需要用道这个字段时，在使用时会去加载

  ```python
  posts = Post.objects.all().defer('content')
  for post in posts: # 此时会执行数据库查询
  	print(post.content) # 此时会执行数据查询，获取到content
  ```

  **注意：**当不想加载某个过大的字段时（如text类型字段，会使用defer，但是上面的演示代码会产生N+1的查询问题，在实际使用时要注意）

  所谓的N+1的问题其实是1+N的问题，就是查询到的n条记录，我们可能只用到了其中的1条。

- `only`：同`defer`刚好相反，如果只想获取到所有的title记录，就可以使用only，只获取title的内容， 其他值在获取是会产生额外的查询。

- `select_related`：这就是用来解决外键产生的N+1问题的方案

  下面案例会产生这个问题：

  ```
  posts = Post.objects.all()
  for post in posts:
  	print(post.owner) # owner是外键的关联表
  ```

  解决方法：

  ```python
  posts = Post.objects.all().select_related('category')
  for post in posts:
  	print(post.category)
  ```

  当然，这个借口只能用来解决一对多的关联关系。

- `prefetch_related`：针对多对多关系的数据，可以通过这个接口来避免N+1查询。

  比如：post和tag的关系可以通过这种方式来避免

  ```python
  posts = Post.objects.all().prefetch_related('tag')
  for post in posts:
  	print(post.tag.all())
  ```

## 4. 常用的字段查询

- `contains`：包含，用来进行相似查询
- `icontains`：同`contains`，忽略大小写
- `exact`：精确匹配
- `iexact`：同exact，忽略大小写
- `in`：指定某个集合，比如`Post.objects.filter(id__in=[1, 2, 3])`相当于`SELECT * FROM blog_post WHERE IN (1, 2, 3);`
- `gt`：大于
- `gte`：大于等于
- `lt`：小于
- `lte`：小于等于
- `startswith`：以某个字符串开头，与`contains`类似，只是会产生`LIKE '<关键词>%'`这样的SQL
- `istartswith`：同`startswith`，忽略大小写
- `endswith`：以某个字符串结尾
- `iendswith`：同`endswith`，忽略大小写
- `range`：范围查询，多用于时间范围，`Post.objects.filter(created_time__range=('2018-05-01', '2018-06-01'))`会产生这样的查询：`SELECT ... WHERE created_time BETWEEN '2018-05-01' AND '2018-06-01';`

## 5. 进阶查询

- `F`：F 表达式常用来执行数据库层面的计算，从而避免出现竞争状态。比如需要处理每篇文章的访问量，假设存在`post.pv`这样的字段，当有用户访问时，我们对其加1：

  ```python
  post = Post.objects.get(id=1)
  post.pv = post.pv + 1
  pos.save()
  ```

  这在多线程的情况下会出现问题，其执行逻辑是先获取到当前的pv值，然后将其加1后赋值给post.pv，最后保存。如果多个线程同时执行了`post = Post.objects.get(id=1)`，那么每个线程里的post.pv值都是一样的，执行完加1和保存之后，相当于只执行了一次加1.

  这时通过F表达式就可以方便的解决这个问题：

  ```python
  from django.db.models import F
  	post = Post.objects.get(id=1)
  	post.pv = F('pv') + 1
  	post.save()
  ```

  这种方式最终会产生类似这样的SQL语句`UPDATE blog_post SET pv = pv + 1 WHERE ID = 1`。它在数据库层面执行原子性操作。

- `Q`：Q表达式就是用来解决前面提到的那个OR查询的，可以这么用：

  ```python
  from django.db.models import Q
  Post.objects.filter(Q(id=1) | Q(id=2))
  ```

  或者进行AND查询

  ```python
  Post.objects.filter(Q(id=1) & Q(id=2))
  ```

- `Count`：用来做聚合查询，比如想要得到某个分类下有多少篇文章：

  ```python
  category = Category.objects.get(id=1)
  posts_count = category.post_set.count()
  ```

  如果想要把这个结果放在category上，通过`category.post_count`可以访问：

  ```python
  from django.db.models import Count
  categories = Category.objects.annotate(posts_count=Count('post'))
  print(categories[0].posts_count)
  ```

  这相当于给category动态增加了属性`posts_count`，而这个属性的值来源于`Count('post')`

- `Sum`：和`Count`类似，只是它是用来做合计的。比如想要统计目前所有文章加起来的访问量有多少

  ```python
  from django.db.models import Sum
  Post.objects.aggregate(all_pv=Sum('pv'))
  # 输出类似结果： {'all_pv': 487}
  ```

上面演示了QuerySet的annotate和aggregate的用法，其中前者用来给QuerySet结果增加属性，后者只是用来直接计算结果。

除了`Count`和`Sum`外，还有`Avg`、`Min` 和 `Max`等表达式。