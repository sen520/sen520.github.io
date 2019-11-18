---
title: git统计项目中成员代码量
date: 2019-10-11 21:45:23
updated: 2019-10-11 21:45:23
tag:
- git
categories:
- git
---

## 查看git上个人代码量

```
git log --author="username" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -
```

## 统计每个人的增删行数

```
git log --format='%aN' | sort -u | while read name; do echo -en "$name\t"; git log --author="$name" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -; done
```

## 查看仓库提交者排名前 5

```
git log --pretty='%aN' | sort | uniq -c | sort -k1 -n -r | head -n 5
```

## 贡献者统计：

```
git log --pretty='%aN' | sort -u | wc -l
```

## 提交数统计：

```
git log --oneline | wc -l
```

