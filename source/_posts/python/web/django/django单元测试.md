---
title: Django单元测试
date: 2019-10-12 19:24:28
updated: 2019-10-12 19:24:28
tags:
- 后端
categories:
- python
- web
- django
---

## 单元测试

​        单元测试是实际开发中很重要但也经常被忽视的部分，其主要原因是编写Web功能测试所耗费的时间可能会大于你开发此功能的时间，因此，对于需要快速开发、上线的业务来说，项目中关于单元测试的部分很少。但是对于需要长期维护的项目，还需要考虑增加单元测试。只是第一次编写时会比较耗费时间，一旦基础结构完成，后续跟着功能的增加来增加单元测试并不会耗费多少时间，但是收益却是十分明显的。

​        单元测试的主要目的是**让代码更健壮**，尤其是在进行重构或者业务增加的时候，跑通单元测试，就意味着新加入的代码或者修改的代码没有问题。在实际开发中，单元测试的覆盖率没有那么高，其主要原因也是写单元测试的成本过高，尤其是对于很复杂的业务。下面就Django内置的测试工具进行说明。

### TestCase中几个方法的说明

​       在Django中运行测试用例时，如果我们使用的SQLite数据库，Django会帮助我们创建一个基于内存测试的数据库，用于测试。

​		但是对于MySQL数据库，Django会直接用配置的数据库用户和密码创建一个名为`test_student_db`的数据库，用于测试。因此需要保证有建表和建库的权限

​		当然，也可以自定义测试用的数据库名称，通过setting配置：

```
DATABASE = {
	'default': {
		'ENGINE': 'django.db.backends.mysql',
		'USER': 'mydatabaseuser',
		'NAME': 'mydatabase',
		'TEST': {
			'NAME': 'mytestdatabase', # 这里配置
		}，
	}，
}
```

Django提供了一个名为`TestCase`的基类，我们可以通过继承这个类来实现自己的测试逻辑。TestCase为我们系统了以下方法（需要用到的）：

- `def setUp(self)`：用来初始化环境，包括创建初始化的数据，或者做一些其他准备工作。
- `def test_xxxx(self)`：方法后面的`xxxx`可以是任意东西。以`test_`开头的方法，会被认为是需要测试的方法，跑测试时会被执行，每个需要被测试的方法是相互独立的。
- `def tearDown(self)`：跟setUp相对，用来清理测试环境和测试数据。

#### 样例代码：

##### Model层测试

主要保证数据的写入和查询是可用的，同时也需要保证我们在model所提供的方法是复合预期的。

比如在Model中增加了sex_show这样的属性，用来展示sex这个字段的中文显示，而不是1，2。当然，这个功能是Django已经提供给我们的。

```python

from django.db import models

# Create your models here.

class Student(models.Model):
    SEX_ITEMS = [
        (1, '男'),
        (2, '女'),
        (0, '未知'),
    ]
    STATUS_ITEMS = [
        (0, '申请'),
        (1, '通过'),
        (2, '拒绝'),
    ]
    name = models.CharField(max_length=128, verbose_name='姓名')
    sex = models.IntegerField(choices=SEX_ITEMS, verbose_name='性别')
    profession = models.CharField(max_length=128, verbose_name='职业')
    email = models.EmailField(verbose_name='Email')
    qq = models.CharField(max_length=128, verbose_name='QQ')
    phone = models.CharField(max_length=128, verbose_name='电话')

    status = models.IntegerField(choices=STATUS_ITEMS, default=0, verbose_name='审核状态')
    created_time = models.DateTimeField(auto_now_add=True, editable=False, verbose_name='创建时间')

    def __str__(self):
        return '<Student: ()>'.format(self.name)

    class Meta:
        verbose_name = verbose_name_plural = '学员信息'

    @property
    def sex_show(self):
        return dict(self.SEX_ITEMS)[self.sex]

    @classmethod
    def get_all(cls):
        return cls.objects.all()
```

views.py同级目录下的test.py，它是App初始化时Django默认帮我们创建的

```python
from django.test import TestCase, Client
from .models import Student

# Create your tests here.
class StudentTestCase(TestCase):
    def setUp(self) -> None:
        Student.objects.create(
            name='test',
            sex=1,
            email='test@test.com',
            profession='test职业',
            qq='123',
            phone='123456',
        )

    def test_create_and_sex_show(self):
        student = Student.objects.create(
            name='zhangsan',
            sex=1,
            email='zhangsan@test.com',
            profession='程序员',
            qq='123123',
            phone='12121212',
        )
        self.assertEqual(student.sex_show, '男', '性别字段内容更展示不一致')

    def test_filter(self):
        Student.objects.create(
            name='lisi',
            sex=1,
            email='lisi@test.com',
            profession='程序员',
            qq='2124325',
            phone='11111111'
        )
        name='test'
        students= Student.objects.filter(name=name)
        self.assertEqual(students.count(), 1, '应该只存在一个名称为{}的记录'.format(name))
        
```

在setUp中，创建了一条数据用于测试。test_create_and_sex_show用来测试数据创建以及sex字段的正确展示，test_filter测试查询是否可用。

需要说明的是，每一个以`test_`开头的函数都是独立运行的。因此，setUp和tearDown也会在每个函数运行时被执行。简单理解就是每个函数都处于独立的运行环境。

##### View层测试

test.py 添加如下代码

```python
    def test_get_index(self):
        # 测试首页的可用性
        client = Client()
        response = client.get('/')
        self.assertEqual(response.status_code, 200, 'status code must be 200!')

    def test_post_student(self):
        client = Client()
        data = dict(
            name='test_for_post',
            sex=1,
            email='333@test.com',
            profession='程序员',
            qq='333',
            phone='222',
        )
        response=client.post('/', data)
        self.assertEqual(response.status_code, 302, 'status code must be 302!')

        response = client.get('/')
        self.assertEqual(b'test_for_post' in response.content, 'response content must contain `test_for_post`')
```

