---
title: python虚拟环境
date: 2017-10-10 9:54:28
updated: 2017-10-10 9:54:28
categories:
- python
- 基础
---

​		在实际开发过程中，我们可能需要维护多个项目，这些项目的依赖又不同，如果不同的依赖都直接安装在系统环境中，那么可能会出现冲突。因此，就有了这个方案——虚拟环境。

- Python3.3之后版本自带venv模块
- 第三方工具virtualenv
- 第三方工具pipenv

### 1. Python3.3之后版本自带venv模块

- 创建虚拟环境

  `python3.6 -m venv project-env`

- 进入虚拟环境目录

  `cd project-env`

- 激活虚拟环境

  `source bin/acrivite`

- 安装环境

  `pip install package`

- 退出虚拟环境

  `deactivate`

### 2. virtualenv用法

- 安装到系统目录（需要root权限）

  `pip install virtualenv`

- 安装到用户目录

  `pip install virtualenv --user`

- 接下来就可以直接使用了

  `virtualenv project-env`

  其余的和venv相同

#### `virtualenv`的增强包

如果要使用`virtualenv`的增强包的话

  `pip install virtualenvwrapper`

需要修改home目录(macOS下是`/Users/用户名/`)下的`.bashrc`文件。如果是oh-my-zsh用户，则需要修改`.zshrc`，最后一行添加如下内容

  ```
  export WORKON_HOME=$HOME/.virtualenvs
  source /usr/local/bin/virtualenwrapper.sh
  ```

如果使用`--user`的方式安装的话，应该是哟经下面的方式启动`virtualenvwrapper`：

  `source $HOME/.local/bin/virtualenvwrapper.sh`

配置好之后，通过mkvirtualenv project-env来创建环境，使用workon project-env 来激活虚拟环境