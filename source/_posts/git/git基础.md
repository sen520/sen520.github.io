---
title: git基础
date: 2018-8-20 16:45:24
updated: 2018-8-20 16:45:24
tag:
- git
categories:
- git
---

对于一个新建的项目，我们首先要在项目目录中执行`git init`来初始化版本系统，之后可以通经过`git status` 来查看当前状态

- Unttacked files：尚未被追踪的文件
- Changes to committed：已经提交到暂存区，但尚未提交到版本管理中，对未被跟踪的文件执行`git add 文件名`命令后的状态。
- Changes not staged for commit：已经被追踪的文件发生了修改，但修改还未被添加到暂存区。
- nothing to commit, working directory clean：没有文件被修改或者被追踪。

{% asset_img slug Git状态变化图.jpg %}

本地提交的代码可以推送到远端，但是需要先设置远端的仓库地址：

`git remote add origin git@github.com`

代码推送到远端的master分支上

`git push -u origin master`

**其他命令**：

- 修改已提交的comment

  我们推荐一个commit只做一件事，比如修改一个bug，完成一个小功能点，但有时会出现已经提交了commit，又发现一个小问题，而修复后作为独立的commit不合适，此时可以使用

  `git commit --amend` 把新的改动加入到刚才的commit中

- 修改历史comment

   有时候还会有需要变更历史的需求，比如提交了多个相似的commit，需要将其合并为一个，`git rebase -i HEAD~3`命令，这个命令通过交互模式（-i的作用）的方式来进行调整，最后的`HEAD~3`指明我们想修改的最近三次commit，执行命令后会出现下图

    {% asset_img slug git_rebase.jpg %}

  这里我们可以调整注释，合并两个commit（使用squash）或者舍弃某个commit（直接去掉某个commit）

  需要注意的是：即使不修改任何内容，进入这个模式后，也会重写这几个commit（重新生成commit号）。我们可以通过删除所有的非注释内容来正常退出。

  ​		**这种操作不可在共用的分支上做，尤其是对于已经推送到远端的commit。**因为变更完成后只有通过`git push -f` 才能重新提交。如果是公用分支，会导致其他开发人员“崩溃”（代码冲突）。

- git blame审查代码

  其实大部分IDE都已经内置了这个功能。

  通过`git blame <文件名>`方式来查看每一行代码是由哪个开发人员编写的。

- 远端和本地

  通过`git remote add origin <远端仓库地址>`来增加远端仓库，其中，origin是远端仓库默认的名称

  然后通过`git push -u origin master`来推送本地master分支的代码到远端，并同时设置本地master关联远端的master分支。

  - git fetch 

    本地库的master的commitID不变，但是与git关联的仓库中的commitID变成了2，这时候我们本地相当于存储了两个代码的版本号，这时候我们要通过`git merge`去合并

  - git pull

     将本地的代码更新至远程仓库里面最新的代码版本
     
  - 同时提交到多个远程仓库
  
     - 首先通过`git remote -v` 查看远程仓库信息
     - `git remote set-url --add origin` + url 添加仓库信息
     - `git remote -v `就可以看到这个链接了
     - 提交，`git push origin --all`

