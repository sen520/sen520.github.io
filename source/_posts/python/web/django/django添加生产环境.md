---
title: Django添加生产环境配置
date: 2019-10-13 10:35:45
updated: 2019-10-13 10:35:45
tags:
- 后端
- python
- django
categories:
- python
- web
- django
---

在初始化阶段，Django会帮我们创建一个`settings.py`目录，所有Django的配置都在这个模块中，这样就会产生一些问题，比如同一份配置怎么来更好的区分开发环境和线上环境。当然可以在settings中编写`if....else`之类的条件，但是这样会导致settings会越来越复杂。

理论上说开发环境的配置和生产环境的配置完全没关系，我们在维护生产环境的配置时，不需要考虑其他环境的配置，因此就有了拆分的逻辑。

具体的做法是把之前的`settings.py`中的内容放在`settings/base.py`中，删除原`settings.py`文件，同时新增`__init__.py`、`develop.py`和`product.py`。拆分独立模块之后，把需要的独立配置的内容分别放在不同的模块中，比如DATABASE配置，在`develop.py`中可以配置SQLite数据库，在`produect.py`中配置正式的MySQL数据库等。

下面是相关的具体配置(仅以创建develop，区分不同数据库为例，product类似)：

1. 在`settings.py`同级目录下创建`setttings`的python package文件夹。

   **tips:** 或者新建文件夹，创建`__init__.py`文件

2. 将`setting.py ` copy 到`settings`文件夹中，并重命名为`base.py`， 新建`develop.py`

3. 在`develop.py` 中进行相关数据库配置

   ```python
   from .base import *

    DEBUG = True

    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.sqlite3',
            'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
        }
    }
   ```

4. 修改django的启动文件

   将`manage.py`和`wsgi.py`中的代码

   ` os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ideatype.settings')`
   
   替换为
   
   ```
   profile = os.environ.get('TYPEIDEA_PROFILE', 'develop')
   os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ideatype.settings.%s' %profile)
   
   ```
   
5. 配置环境变量

   开发环境：`TYPEIDEA_PROFILE = develop`

   执行命令：

   - `echo  export TYPEIDEA_PROFILE=develop >>  /etc/profile`
   - `source /etc/profile`