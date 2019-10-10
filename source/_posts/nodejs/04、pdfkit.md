---
title: pdfkit
date: 2019-10-09 22:28:13
updated: 2019-10-09 22:28:13
tags:
- 后端
- nodejs
categories:
- nodejs
---

### pdfkit

[官方文档](http://pdfkit.org/)

#### 0、准备

需要引入两个包，首先要`npm install pdfkit`安装pdfkit包

```javascript
const PDF = require('pdfkit');
const fs = require('fs');
```

通过下面方法创建pdf对象，如果没有传入任何的参数，默认自动创建第一页，页面大小为A4

`doc = new PDF();`

通过管道流创建名为`test.pdf`的文件

`doc.pipe(fs.createWriteStream('test.pdf')); `

写入内容

`doc.text('test')`

结束写入，生成文件

`doc.end()`

#### 1、页面和文本设置

首先要解决的问题就是页面的设置了，在这里我们要求的是16:9的页面比例，而并非默认的A4纸的页面。

- 创建对象，取消生成第一页

  `doc = new PDF({ autoFirstPage: false });`

- 添加页面，设置页面大小

  `doc.addPage({ margin: 10, size: [960,540] });`

- 设置中文字体，支持中文

  此时，需要有一个本地中文文件，在`C:\Windows\Fonts`中可以找到，这里使用的是微软雅黑

  `doc.font('../WeiRuanYaHei-1.ttf');`

- 在输入文本前，创建文件流

  `doc.pipe(fs.createWriteStream('test.pdf'));`

- 插入文本

  ```javascript
  doc.text('Hello world!')
  doc.text('Hello world!', 100, 100) //设定文本位置，如果要上下移动，只需要使用您要移动的行数（默认为1）调用moveDownor moveUp方法。
  doc.lineGap(4);
  ```

  - 文本属性(同样的可以直接配置doc的属性作为全局属性)

    - `lineBreak`-设置为`false`禁用所有换行
    - `width` -文本应换行的宽度（默认情况下，页面宽度减去左右边距）
    - `height` -文本应剪切到的最大高度
    - `ellipsis`-太长时显示在文本末尾的字符。设置为`true`使用默认字符。
    - `columns` -文本流入的列数
    - `columnGap` -每列之间的间距（默认为1/4英寸）
    - `indent` -以PDF磅为单位（每英寸72英寸）的缩进量
    - `paragraphGap` -文本各段之间的间距
    - `lineGap` -每行文字之间的间距
    - `wordSpacing` -文本中每个单词之间的间距
    - `characterSpacing` -文本中每个字符之间的间距
    - `fill`-是否填写文字（`true`默认情况下）
    - `stroke` -是否描边文本
    - `link` -链接此文本的URL（创建注释的快捷方式）
    - `underline` -是否在文字下划线
    - `strike` -是否删除文字
    - `oblique`-是否倾斜文字（角度或度数`true`）
    - `baseline`-文本相对于其插入点的垂直对齐方式（值为[canvas textBaseline](https://www.w3schools.com/tags/canvas_textbaseline.asp)）

    可以连续对文本进行操作

    ```javascript
    doc.fillColor('green')
       .text(lorem.slice(0, 500), {
         width: 465,
         continued: true
       }).fillColor('red')
       .text(lorem.slice(500));
    ```

#### 2、插入图片和图形

```javascript
doc.image('image/img.png', x, y, {width: 100, height: 100}) // 插入图片，并设置图片大小
doc.rect(100, 100, 90, 100).dash(3, {space: 3}).fillAndStroke("#11487B"); // 在（100， 100）处，画一个90*100的方形，并用#11487B颜色填充，设置边框为曲线，space为线条长度。
```

- image方法可以插入图片

- rect可以画一个方形，可以使用dash使边框变为虚线，undash再变为实线。
- fillAndStroke填充颜色，第二个参数为描边颜色

```javascript
const PDF = require('pdfkit');
const fs = require('fs');
const doc = new PDF({ autoFirstPage: false });//creating a new PDF object
doc.lineGap(4);
doc.addPage({ margin: 10, size: [960,540] });
doc.font('./WeiRuanYaHei-1.ttf');
doc.pipe(fs.createWriteStream('test.pdf'));  //creating a write stream
const x = 30
doc.rect(x, 85, 315, 145).dash(3, {space: 3}).strokeColor("#808080").stroke();
doc.image('./kit/banner.png', x+110, 110, { width: 90 });
doc.end()
```

上述代码生成结果：

{% asset_img slug result.jpg %}

