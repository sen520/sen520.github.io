1、将 Hexo 编译生成 HTML 代码，命令如下：

```
hexo generate
```

2、博客在本地运行起来，命令如下：

```
hexo server
```

3、部署命令如下：

```
hexo deploy
```

4、现在整个站点只有一篇文章，那么我们怎样来增加其他的文章呢？

这个很简单，只需要调用 Hexo 提供的命令即可，比如我们要新建一篇「HelloWorld」的文章，命令如下：

```
hexo new hello-world
```

5、导入图片

图片放在与文档同名的文件夹中

```
{% asset_img slug mongo固定集合.png %}
```





