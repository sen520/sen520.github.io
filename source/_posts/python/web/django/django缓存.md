---
title: Django缓存
date: 2019-10-18 19:24:28
updated: 2019-10-18 19:24:28
tags:
- 后端
categories:
- python
- web
- django
---

##### 粒度

Django中提供了各种粒度的缓存方案，大致分为以下几种：

- 整站缓存：简单粗暴，直接在setting的MIDDLEWARE中第一行增加`django.middleware.cache.UpdateCacheMiddleware`。

- 页面缓存，在url.py的路由配置中

  ```python
  from django.views.decorators.cache import eache_page
  urlpatterns = [
      url('/',cache_page(60*20, key_profix='index_cache_'))
  ]
  ```

- 局部数据缓存：这个包括函数中某部分逻辑缓存，也包括模板中一部分数据的缓存。

  比如model层的post.hot_posts更新频率不高，可以进行较长的缓存。

  ```python
  from django.core.cache import cache
  class Post(models.Model):
  	@classmethod
  	def hot_posts(self):
          result = cache.get('hot_posts')
          if not result:
              result = cls.objects.filter(status=1)
              cache.set('hot_posts', result, 10*60)
          return result
  ```

如果需要缓存部分模板数据，可以这么做

```
{% load cache %}
{% cache 50 sidebar %}
	...sidebar...
{% endcache %}
```

##### 内置的缓存

在django中，内置支持以下几种缓存配置。

- `local-memory caching`: 内存缓存。线程安全，进程间独立，也就是每个进程一份缓存。这是Django的默认配置。

- `filesystem caching`：把数据缓存到文件系统中。

- `database caching`：数据库缓存，需要创建缓存用的表，这些表是用来存储缓存数据的。

- `memcached`：这是Django推荐的缓存系统，也是分布式的。

  ```python
  # local-memory caching
  CACHES = {
  	'default': {
  		'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
  		'LOCATION': 'unique-snowflake',
  	}
  }
  ```

  ```python
  # filesystem caching
  CACHES = {
  	'default': {
  		'BACKEND': 'django.core.cache.backends.filebased.FileBasedCache',
  		'LOCATION': '/var/tmp/django_cache',
  	}
  }
  ```

  ```python
  # database caching
  CACHES = {
  	'default': {
  		'BACKEND': 'django.core.cache.backends.db.DatabaseCache',
  		'LOCATION': 'my_cache_table',
  	}
  }
  ```

  ```python
  # memcached
  CACHES = {
  	'default': {
  		'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
  		'LOCATION':{
  			'172.19.26.240:11211',
  			'172.19.26.242:11211',
  		}
  	}
  }
  ```

##### 配置Redis缓存

`pip install django-redis`

`pip install hiredis`

我们同时安装了hiredis，其作用是提升Redis解析性能。

我们在settings.py中可做如下配置

```python
REDIS_URL = '127.0.0.1:6379:1'
CACHES = {
	'default': {
		'BACKEND': 'django_redis.cache.RedisCache',
		'LOCATION': REDIS_URL,
		'TIMEOUT': 300,
		'OPTIONS': {
			'PASSWORD': '对应的密码'，
			'CLIENT_CLASS': 'django_redis.client.DefaultClient',
			'PARSER_CLASS': 'redis.connection.HiredisParser',
		},
		'CONNECTION_POOL_CLASS': 'redis.connection.BlockingConnectionPool',
	}
}
```

