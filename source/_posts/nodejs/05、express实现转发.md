---
title: express实现转发
date: 2019-10-17 23:24:28
updated: 2019-10-17 23:24:28
tags:
- 后端
categories:
- nodejs
---

#### 1. 需求

现在需要对一个整体的web后端项目做拆分，并且放在不同的docker容器【服务器中】，中间需要一个容器做路由转发，这样所有的服务不受程序语言，框架的影响。并且如果一个容器挂掉也不会影响到其他容器和项目功能的使用。

#### 2. 选择框架

因为项目整体语言为`nodejs-express`，比较熟悉，所以这里也使用`nodejs-express`进行开发。

需要安装的包

- `express`
- `node-fetch`

利用express的特性，所有的请求都会经过中间件之后才会到达路由请求的处理。这里将会采用中间件的方式直接做转发。

#### 3. 开始

- `npm i express`安装express

- 新建app.js

  ```javascript
  const express = require('express');
  const app = express();
  const bodyParser = require('body-parser');
  
  app.use(bodyParser.json()); // for parsing application/json
  app.use(bodyParser.urlencoded({ extended: true }));
  
  const route = require('./route.js');
  app.use(route);
  
  module.exports = app;
  ```

  这里还需要一个包是`body-parser`，主要用于请求体解析，转码。

- 新建route.js

  ```javascript
  const express = require('express');
  const http = require('http');
  const fetch = require('node-fetch');
  const router = express.Router();
  let _fn;
  const apiHost = 'your server host';
  
  router.get('/', function (req, res, next) {
      const path = req.originalUrl;
      _fn.getData(path, function (data) {
          res.send(data);
      })
  });
  
  router.post('/users/*', function (req, res, next) {
      const path = req.originalUrl;
      const content = req.body;
      _fn.postData(path, content, function (data) {
          res.send(data);
      })
  });
  _fn = {
      getData: function (path, callback) {
          fetch(`http://${apiHost}${path}`).then(
              async res => callback(await res.text())
          )
      },
      postData: function (path, data, callback) {
          data = data || {};
          const content = JSON.stringify(data);
          const options = {
              method: 'POST',
              headers: {
                  Accept: 'application/json',
                  'Content-Type': 'application/json',
              },
              body: content,
          };
          fetch(`http://${apiHost}${path}`, options).then(
             async res => callback(await res.text())
          )
      }
  };
  
  module.exports = router;
  
  ```

  这里对上述代码进行一一说明

  - `router`：express的路由管理，`get`方法是处理GET请求，`post`方法是处理POST请求，第一个参数是路由，支持正则，第二个参数是一个函数，参数主要是`request, response, next`。

    这里使用`req.originalUrl`来过去请求路径

    `req.body`来获取请求体

  - `_fn`：定义一个对象，有两个key，一个用于发送`get`请求，一个用于发送`post`请求。方法参数为路由和一个回调函数，回调函数会将结果直接做为一个数据返回个这个请求的最终发送方

    - get：只需要将路由和路径拼接起来即可

    - post：将数据转化为字符串，然后将请求转发。

  

#### 4. 启动

新建`start.js`

```javascript
const app = require('./app');


app.set('port', 80);
// app.set('port', port);

const server = app.listen(app.get('port'), () => {
  const host = server.address().address;
  const { port } = server.address();

  console.log('Example app listening at http://%s:%s', host, port);
});
```

之后执行`node start.js`即可。