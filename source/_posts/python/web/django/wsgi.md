---
title: WSGI——python-Web框架基础
date: 2019-10-12 9:53:28
updated: 2019-10-12 9:53:28
tags:
- 后端
categories:
- python
- web
- django
---

## 1. 简介

### WSGI

​        `WSGI`：web服务器网关接口，这是python中定义的一个网关协议，规定了Web Server如何跟应用程序交互。可以理解为一个web应用的容器，通过它可以启动应用，进而提供HTTP服务。

​		它最主要的目的是保证在Python中所有的Web Server程序或者说Gateway程序，能够通过统一的协议跟Web框架或者说Web应用进行交互。

### uWSGI

​      `uWGSI`：是一个web服务器，或者wsgi server服务器，他的任务就是接受用户请求，由于用户请求是通过网络发过来的，其中用户到服务器端之间用的是http协议，所以我们uWSGI要想接受并且正确解出相关信息，我们就需要uWSGI实现http协议，没错，uWSGI里面就实现了http协议。所以现在我们uWSGI能准确接受到用户请求，并且读出信息。现在我们的uWSGI服务器需要把信息发给Django，我们就需要用到WSGI协议，刚好uWSGI实现了WSGI协议，所以。uWSGI把接收到的信息作一次简单封装传递给Django，Django接收到信息后，再经过一层层的中间件，于是，对信息作进一步处理，最后匹配url，传递给相应的视图函数，视图函数做逻辑处理......后面的就不叙述了，然后将处理后的数据通过中间件一层层返回，到达Djagno最外层，然后，通过WSGI协议将返回数据返回给uWSGI服务器，uWSGI服务器通过http协议将数据传递给用户。这就是整个流程。

​        这个过程中我们似乎没有用到uwsgi协议，但是他也是uWSGI实现的一种协议，鲁迅说过，存在即合理，所以说，他肯定在某个地方用到了。我们过一会再来讨论

​        我们可以用这条命令：`python manage.py runserver`，启动Django自带的服务器。DJango自带的服务器（runserver 起来的 HTTPServer 就是 Python 自带的 simple_server）。是默认是单进程单多线程的，对于同一个http请求，总是先执行一个，其他等待，一个一个串行执行。无法并行。而且django自带的web服务器性能也不好，只能在开发过程中使用。于是我们就用uWSGI代替了。

### 为什么有了WSGI为什么还需要nginx？

​        因为nginx具备优秀的静态内容处理能力，然后将动态内容转发给uWSGI服务器，这样可以达到很好的客户端响应。支持的并发量更高，方便管理多进程，发挥多核的优势，提升性能。这时候nginx和uWSGI之间的沟通就要用到uwsgi协议。

{% asset_img slug 1.png %}

{% asset_img slug 2.png %}

{% asset_img slug 3.png %}

{% asset_img slug 4.png %}

## 2. 简单的Web Server

在了解WSGI协议之前，首先看一个通过socker编程实现的Web服务的代码。

```python
import socket
EOL1 = b'\n\n'
EOL2 = b'\n\r\n'
body = """hello world <h1> from test</h1>"""
response_params = [
    'HTTP/1.0 200 OK',
    'DATE: Sun, 27 may 2019 01:01:01 GMT',
    'Content-Type:text/plain; charset=utf-8',
    'Content-Length: {}\r\n'.format(len(body.encode())),
    body,
]
response = '\r\n'.join(response_params)


def handle_connection(conn, addr):
    request = b""
    print('new conn', conn, addr)
    import time
    time.sleep(100)
    while EOL1 not in request and EOL2 not in request:
        request += conn.recv(1024)
    print(request)
    conn.send(response.encode())
    conn.close()


def main():
    serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serversocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    serversocket.bind(('127.0.0.1', 8000))
    serversocket.listen(5)
    print('http://127.0.0.1:8000')
    try:
        while True:
            conn, address = serversocket.accept()
            handle_connection(conn, address)
    finally:
        serversocket.close()


if __name__ == '__main__':
    main()
```

多线程

```python
import errno
import socket
import threading
import time
EOL1 = b'\n\n'
EOL2 = b'\n\r\n'
body = """hello world <h1> from test</h1>"""
response_params = [
    'HTTP/1.0 200 OK',
    'DATE: Sun, 27 may 2019 01:01:01 GMT',
    'Content-Type:text/plain; charset=utf-8',
    'Content-Length: {}\r\n'.format(len(body.encode())),
    body,
]
response = '\r\n'.join(response_params)

def handle_connection(conn, addr):
    print(conn, addr)
    time.sleep(60)
    request = b""
    while EOL1 not in request and EOL2 not in request:
        request += conn.recv(1024)
    print(request)
    current_thread = threading.currentThread()
    content_length = len(body.format(thread_name=current_thread.name).encode())
    print(current_thread.name)
    conn.send(response.format(thread_name=current_thread.name, length=content_length).encode())
    conn.close()

def main():
    serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    serversocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    serversocket.bind(('127.0.0.1', 8000))
    serversocket.listen(10)
    print('http://127.0.0.1:8000')
    serversocket.setblocking(True) # 设置socket为阻塞模式
    try:
        i = 0
        while True:
            try:
                conn, address = serversocket.accept()
            except socket.error as e:
                if e.args[0] != errno.EAGAIN:
                    raise
                continue
            i += 1
            print(i)
            t = threading.Thread(target=handle_connection, args=(conn, address), name='thread-%s'%i)
            t.start()
    finally:
        serversocket.close()

if __name__ == '__main__':

    main()
```

## 3. 简单的WSGI Application

该协议分为两个部分：

- Web Server 或者Gateway

  监听在某个端口上接收外部的请求

- Web Application

​       Web Server接收请求之后，会通过WSGI协议规定的方式把数据传递给Web Application，在Web Application中处理完之后，设置对应的状态和header，之后返回body部分。Web Server拿到返回的数据之后，再进行HTTP协议的封装，最终返回完整的HTTPResponse数据。

下面我们来实现一个简单的应用：

```python
app.py

def simple_app(environ, start_response):
    status = '200 OK'
    response_headers = [('Content-type', 'text/plain')]
    start_response(status, response_headers)
    return [b'Hello world! -by test \n']
```

我们需要一个脚本运行上面这个应用：

```python
import os
import sys

from app import simple_app


def wsgi_to_bytes(s):
    return s.encode()


def run_with_cgi(application):
    environ = dict(os.environ.items())
    environ['wsgi.input'] = sys.stdin.buffer
    environ['wsgi.errors'] = sys.stderr
    environ['wsgi.version'] = (1, 0)
    environ['wsgi.multithread'] = False
    environ['wsgi.multiprocess'] = True
    environ['wsgi.run_once'] = True
    if environ.get('HTTPS', 'off') in ('on', '1'):
        environ['wsgi.url_scheme'] = 'https'
    else:
        environ['wsgi.url_scheme'] = 'http'

    headers_set = []
    headers_sent = []

    def write(data):
        out = sys.stdout.buffer
        if not headers_set:
            raise AssertionError('Write() before start_response()')
        elif not headers_sent:
            # 在输出第一行数据之前，先发送响应头
            status, response_headers = headers_sent[:] = headers_set
            out.write(wsgi_to_bytes('Status: %s\r\n' % status))
            for header in response_headers:
                out.write(wsgi_to_bytes('%s: %s\r\n' % header))
            out.write(wsgi_to_bytes('\r\n'))
        out.write(data)
        out.flush()

    def start_response(status, response_headers, exc_info=None):
        if exc_info:
            try:
                if headers_sent:
                    # 如果已经发送了header，则重新抛出原始异常信息
                    raise (exc_info[0], exc_info[1], exc_info[2])
            finally:
                exc_info = None
        elif headers_set:
            raise AssertionError('*Headers already set!')
        headers_set[:] = [status, response_headers]
        return write

    result = application(environ, start_response)
    try:
        for data in result:
            if data:
                write(data)
        if not headers_sent:
            write('')
    finally:
        if hasattr(result, 'close'):
            result.close()


if __name__ == '__main__':
    run_with_cgi(simple_app)
```

运行结果：

```
Status: 200 OK
Content-type: text/plain

Hello world! -by test 
```

如果不是windows系统，还可以采用另一种方式运行：

- `pip install gunicorn`
- `gunicorn app:simle_app`

## 4. 理解

​        对于上述代码我们只需要关注一点，`result = application(environ, start_response)`，我们要实现的Application，只需要能够接收一个环境变量以及一个回调函数即可。但处理完请求之后，通过回调函数（start_response）来设置response的状态和header，最终返回结果，也就是body。

WSGI协议规定，application必须是一个可调用对象，这意味这个对象既可以是Python中的一个函数，也可以是一个实现了\_\_call\_\_方法的类的实例，比如：

### 样例一

```python
class AppClass(object):
    status = '200 OK'
    response_headers = [('Content-type', 'text/plain')]

    def __call__(self, environ, start_response):
        print(environ, start_response)
        start_response(self.status, self.response_headers)
        return [b'Hello AppClass.__call__\n']


application = AppClass()
```

`gunicorn app: application`运行上述文件

### 样例二

​        除此之外，我们还可以通过另一种方式实现WSGI协议，从上面的simple_app和这里的AppClass.\__call__的返回值来看，WSGI Server只需要返回一个可迭代的对象就行

```python
class AppClassIter(object):
    status = '200 OK'
    response_headers = [('Content-type', 'text/plain')]
    
    def __init__(self, environ, start_response):
        self.environ = environ
        self.start_response = start_response
        
    def __iter__(self):
        self.start_response(self.status, self.response_headers)
        yield b'Hello AppClassIter\n'
```

`gunicorn app: AppClassIter`运行上述文件

​       这里的启动命令并不是一个类的实例，而是类本身。通过上面两个代码，我们可以看到能够被调用的方法会传environ和start_response过来，而现在这个实现没有可调用的方式，所以就需要在实例化的时候通过参数传递进来，这样在返回body之前，可以先调用start_response方法。

​       因此，可以推测出WSGI Server是如何调用WSGI Application的，大概代码如下：

```python
def start_response(status, headers):
    # 伪代码
    set_status(status)
    for k, v in headers:
        set_header(k, v)
def handle_conn(conn):
    # 调用我们定义的application(也就是上面的simple_app, 或者是AppClass的实例，或者是AppClassIter本身)
    app = application(environ, start_response)
    # 遍历返回的结果，生成response
    for data in app:
        response += data
        
    conn.sendall(response)
```

## 5. WSGI中间件和Werkzeug

​        WSGI中间件可以理解为Python中的一个装饰器，可以在不改变原方法的情况下对方法的输入和输出部分进行处理。

类似这样：

```python
def simple_app(enbiron, start_response):
	response = Response('Hello World', start_response=start_response)
	response.set_header('Content-Type', 'text/plain') # 这个函数里面调用start_response
	return response
```

这样就看起来更加自然一点。

​        因此，就存在Werkzeug这样的WSGI工具集，让你能够跟WSGI协议更加友好的交互。从理论上来看，我们可以直接通过WSGI协议的简单实现写一个Web服务。但是有了Werkzeug之后，我们可以写的更加容易。

## 6. 杂谈

django 的并发能力真的是令人担忧，这里就使用 nginx + uwsgi 提供高并发

nginx 的并发能力超高，单台并发能力过万（这个也不是绝对），在纯静态的 web 服务中更是突出其优越的地方，由于其底层使用 epoll 异步IO模型进行处理，使其深受欢迎

做过运维的应该都知道，

**Python需要使用nginx + uWSGI 提供静态页面访问，和高并发**

**php 需要使用 nginx + fastcgi 提供高并发，**

**java 需要使用 nginx + tomcat 提供 web 服务**

```
django 原生为单线程序，当第一个请求没有完成时，第二个请求辉阻塞，知道第一个请求完成，第二个请求才会执行。
Django就没有用异步，通过线程来实现并发，这也是WSGI普遍的做法，跟tornado不是一个概念

官方文档解释django自带的server默认是多线程
django开两个接口,第一个接口sleep(20),另一个接口不做延时处理(大概耗时几毫秒)
先请求第一个接口,紧接着请求第二个接口,第二个接口返回数据,第一个接口20秒之后返回数据
证明django的server是默认多线程

启动uWSGI服务器
# 在django项目目录下 Demo工程名
uwsgi --http 0.0.0.0:8000 --file Demo/wsgi.py
经过上述的步骤测试,发现在这种情况下启动django项目,uWSGI也是单线程,访问接口需要"排队"
不给uWSGI加进程,uWSGI默认是单进程单线程

uwsgi --http 0.0.0.0:8000 --file Demo/wsgi.py --processes 4 --threads 2
# processes: 进程数 # processes 和 workers 一样的效果 # threads : 每个进程开的线程数
经过测试,接口可以"同时"访问,uWSGI提供多线程
```

- Python因为GIL的存在,在一个进程中,只允许一个线程工作,导致单进程多线程无法利用多核
- 多进程的线程之间不存在抢GIL的情况,每个进程有一个自己的线程锁,多进程多GIL