---
title: nodejs执行shell脚本，实时传输
date: 2019-07-02 21:25:53
updated: 2019-07-02 21:25:53
tags:
- 后端
- nodejs
- javascript
categories:
- javascript
- nodejs
---

### 接到需求

需要一个服务来执行shell脚本，要求可以实时打印shell脚本执行的过程，并看到脚本执行的结果。

### 明确任务目标：

- 这是一个web服务，需要执行shell脚本

- 当一个脚本执行的时候，再次发送请求需要等待当前脚本执行完毕，再自动执行这次请求
- 使用长连接而不是socket
- 添加脚本不需要重启服务器

这里采用的是express框架

### 开始

#### 首先搭好express基本框架

新建`app.js`文件, `npm install express`

```javascript
const express = require('express');
const app = express();

app.get('/:id', (req, res) => {
  const { id } = req.params;
  if (id === 'favicon.ico') {
    res.sendStatus(200);
    return;
  }
  // 执行脚本
});

app.set('port', 3018);
app.listen(app.get('port'), () => console.log(`server listening at ${app.get('port')}`));
```

#### 新建文件

新建`config.json`用于配置id和脚本名的对应关系，新建`scripts`目录用于存放脚本。

这里定义一个函数`execute`参数为id和response对象，代码如下：

```javascript
const pidDict = {};
async function execute(id, res) {
  delete require.cache[require.resolve('./config.json')];
  const config = require('./config.json');
  const filePath = config[id];
  if (!filePath) {
    res.sendStatus(404);
    return;
  }
  console.log(`The script:${filePath} with ${id} begin execute`);
  const readable = new Readable();
  readable._read = () => {};
  readable.pipe(res);
  while (pidDict[id]) {
    readable.push('\nWaiting for another script request.');
    await wait(5000);
  }
  const handle = spawn('sh', [`./scripts/${filePath}`]);
  pidDict[id] = handle.pid;

  handle.stdout.on('data', (data) => {
    readable.push(`\n${data}`);
    getLogger(filePath).log(`\n${data}`);
  });

  handle.stderr.on('data', (data) => {
    getLogger(filePath).warn(`\n${data}`);
    readable.push(`\n${data}`);
  });

  handle.on('error', (code) => {
    getLogger(filePath).error(`child process error with information: \n${code}`);
    readable.push(`child process error with information: \n${code}`);
    delete pidDict[id];
    readable.push(null);
  });

  handle.on('close', (code) => {
    getLogger(filePath).log(`child process close with code ${code}`);
    delete pidDict[id];
    readable.push(null);
  });
}
```

解释：

- 首先要加载`config.json`，需要注意的是，因为是需要动态引入，所以这里不能直接使用`require('config.json')`，在这之前，需要先删除引入的缓存：`delete require.cache[require.resolve('./config.json')];`

- 获取文件路径 `const filePath = config[id];`

- 新建读写流，可以直接发送到前端。

- 再执行脚本前，需要判断当前有无脚本执行，这里在外部定义了一个pidDict，文件对应的id直接指向文件执行的handle的pid

- 紧接着就是输入输出流了

  - handle.stdout是标准输出

  - handle.stderr是错误输出，这里指的是输出的警告
  - handle的error事件指的是脚本执行中遇到的错误，也就是脚本执行不成功报的错误信息


   这里定义了两个外部函数，一个是自定义的日志打印，另一个是遇到有脚本执行时的等待

   新建`utility.js`

   ```javascript
      const fs = require('fs');
      
      /**
       * time wait
       *
       * @param time {number} time(ms) to wait
       */
      /* eslint-disable compat/compat */
      const wait = async (time = 1000) => {
        return new Promise((resolve) => {
          setTimeout(resolve, time);
        });
      };
      
      /**
       * set log
       *
       * getLogger(path).level
       *    level:
       *        log
       *        trace
       *        debug
       *        info
       *        warn
       *        error
       * @param path
       */
      function getLogger(path) {
        return require('tracer').console({
          transport: (data) => {
            console.log(data.output);
            fs.appendFile(`./logs/${path}.log`, `${data.rawoutput} \n`, () => {});
          },
        });
      }
      
      module.exports = {
        wait,
        getLogger,
      };
      
   ```

#### 新建脚本

现在，新建scripts/hello-world.sh

```bash
#!/bin/sh
   
echo 'hello...'
sleep 5
echo 'world!'
```

config.json中注册该脚本

```json
{
  "hello-world": "hello-world.sh"
}
```

执行`node app.js`，通过`curl http://localhost:3018/hello-world`即可观察到运行结果。

### 附

这里放上app.js的完整代码

```javascript
const express = require('express');
const { spawn } = require('child_process');
const { Readable } = require('stream');
const { wait, getLogger } = require('./utility');

const app = express();

app.get('/:id', (req, res) => {
  // 执行脚本
  const { id } = req.params;
  if (id === 'favicon.ico') {
    res.sendStatus(200);
    return;
  }
  execute(id, res).then();
});

const pidDict = {};

/**
 * 执行sh脚本
 *
 * @param id 脚本id
 * @param res response object
 */
/* eslint-disable no-underscore-dangle, no-await-in-loop */
async function execute(id, res) {
  delete require.cache[require.resolve('./config.json')];
  const config = require('./config.json');
  const filePath = config[id];
  if (!filePath) {
    res.sendStatus(404);
    return;
  }
  console.log(`The script:${filePath} with ${id} begin execute`);
  const readable = new Readable();
  readable._read = () => {};
  readable.pipe(res);
  while (pidDict[id]) {
    readable.push('\nWaiting for another script request.');
    await wait(5000);
  }
  const handle = spawn('sh', [`./scripts/${filePath}`]);
  pidDict[id] = handle.pid;

  handle.stdout.on('data', (data) => {
    readable.push(`\n${data}`);
    getLogger(filePath).log(`\n${data}`);
  });

  handle.stderr.on('data', (data) => {
    getLogger(filePath).warn(`\n${data}`);
    readable.push(`\n${data}`);
  });

  handle.on('error', (code) => {
    getLogger(filePath).error(`child process error with information: \n${code}`);
    readable.push(`child process error with information: \n${code}`);
    delete pidDict[id];
    readable.push(null);
  });

  handle.on('close', (code) => {
    getLogger(filePath).log(`child process close with code ${code}`);
    delete pidDict[id];
    readable.push(null);
  });
}

app.set('port', 3018);
app.listen(app.get('port'), () => console.log(`server listening at ${app.get('port')}`));

```

