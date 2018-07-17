---
title: Hexo版本升级和Next主题升级之坑
date: 2018-07-17 21:15:06
tags: [hexo, next]
categories: hexo
---
## 缘起
差不多用了一年hexo的3.2.0版本，next主题版本也用的5.0的，本来用的好好的，但是最近访问其他人的博客，发现访问速度比我的提升了不止一点点，遂决定折腾一番。

## 过程
### Hexo版本升级
Hexo版本升级可以通过npm实现，相关命令如下：
先全局升级`hexo-cli`：-g表示全局升级。`hexo`本身是一个静态博客生成工具，具备编译Markdown、拼接主题模板、生成 HTML、上传 Git 等基本功能。`hexo-cli`能够将这些功能封装为命令，提供给用户通过` hexo server / hexo deploy `等命令调用的模块。`CLI = Command Line Interface `命令行界面。
```
npm i hexo-cli -g
```
然后直接输入：(其实这个命令应该不正确)，输入之后发现出现了一系列的warn。
```
npm update
```
再输入`hexo vesion`查看当前版本，发现版本已经更新成功了。
```
hexo: 3.7.1    # 之前为3.2.0
hexo-cli: 1.1.0
os: Windows_NT 10.0.16299 win32 x64
http_parser: 2.8.0
node: 8.11.3
v8: 6.2.414.54
uv: 1.19.1
zlib: 1.2.11
ares: 1.10.1-DEV
modules: 57
nghttp2: 1.32.0
napi: 3
openssl: 1.0.2o
icu: 60.1
unicode: 10.0
cldr: 32.0
tz: 2017c
```
但是其实上面的更新命令并不是很准确。
　　1. `npm-check`检查更新
```
npm install -g npm-check
npm-check
```
　　2.  `npm-upgrade`更新
```
npm install -g npm-upgrade
npm-upgrade
```
　　3. 更新全局包：
```
npm update <name> -g
```
　　4. 更新生产环境依赖包：
```
npm update <name> --save
```
save参数：`npm install X –save`:

 - 会把X包安装到`node_modules`目录中
 - 会在`package.json`的`dependencies`属性下添加X
 - 之后运行`npm install`命令时，会自动安装X到`node_modules`目录中
 
如果不加save参数的话，之后把X包安装到`node_modules`目录中，不会添加到dependencies文件中。再查看hexo文件夹下面的`dependencies`文件,可以看到hexo的版本已经更新了。
```json
{
  "name": "hexo-site",
  "version": "0.0.0",
  "private": true,
  "hexo": {
    "version": "3.7.1"
  },
  "dependencies": {
    "hexo": "^3.7.1",
    "hexo-deployer-git": "^0.3.1",
    "hexo-fs": "^0.2.3",
    "hexo-generator-archive": "^0.1.5",
    "hexo-generator-category": "^0.1.3",
    "hexo-generator-index": "^0.2.1",
    "hexo-generator-tag": "^0.2.0",
    "hexo-renderer-ejs": "^0.3.1",
    "hexo-renderer-marked": "^0.3.2",
    "hexo-renderer-stylus": "^0.3.3",
    "hexo-server": "^0.3.2"
  }
}
```

### Next主题升级
因为5.0版本和6.0版本差别还是比较大，直接按照官网给的方法更新。参考[官方文档][1]。之前的5.0版本仍然可以用，相当于重新克隆了一个新的6.0版本。

- 克隆新的 v6.x 仓库到任一异于 next 的目录（如 next-reloaded名称可以自定义）：
```
$ git clone https://github.com/theme-next/hexo-theme-next themes/next-reloaded
```
- 然后在 Hexo 的主配置文件中设置主题：
```
theme: next-reloaded
```
然后进入配置文件`_config.yml`,配置相关设置。

## 问题
就在将主题配置好之后，输入命令：
```
hexo g
hexo s
```
在本地服务器上测试运行，这时发现页面内容没有显示，侧边栏内容可以完整显示，文章位置的内容还在只是没有显示。
![显示问题][2]
第一反应是hexo和Next版本的问题，在网上也看很多由于版本引起的问题，可能是版本太高和之前的模块不兼容造成的，有部分页面没有渲染。然后就寻找版本回退的方法，将hexo版本退回到3.2.0,使用命令：
```
npm install -g hexo@版本号
```
回退之后，在3.2.0版本下重新运行，发现这个问题还是存在。想到可能是Node.js版本的问题，node版本也很久没有更新了，都处理8.0的稳定版，我用的还是6.0版本。试着用命令更新：
```
npm cache clean -f  # 清除node.js的cache
npm install-g n
n stable
```
一顿更新之后，发现问题还是存在，之前能用的版本现在也不能用了，有点重新安装配置的冲动了。

## 解决
也就是突然的灵光一闪，既然是显示的问题，为什么不能打开浏览器看看源码到底是怎么样的呢？按下F12查看网页源码，发现果然出现了很多错误。第一个错误就是什么`fancybox`，大概是什么`lib`文件没有找到，让我想起来`_config.yml`有一个`fancybox`配置选项。
![问题详情][3]
打开配置文件查看：我在这里给它设置为了true,然后查找错误的那个路径。
```
# Fancybox. There is support for old version 2 and new version 3.
# Please, choose only any one variant, do not need to install both.
# For install 2.x: https://github.com/theme-next/theme-next-fancybox
# For install 3.x: https://github.com/theme-next/theme-next-fancybox3
fancybox: true
```
发现果然没有找到`fancybox`的相关内容,打开官网文档中的链接看看有没有什么信息。

![文件路径][4]

官方文档中详细给出了`fancybox`的安装步骤，安装这个步骤进行安装。

![安装步骤][5]

再打开之前那个路径：发现已经多了fancybox文件夹。

![lib文件][6]

然后再重新生成页面，在本地服务器运行，发现问题已经解决了，访问速度确实也得到了提升。以后遇到这种问题要多查官方文档，很多东西在文档中写了很清楚的，只是当时没有注意到，还就是要注意解决问题的思考维度，不要把思维固化。




  [1]: https://github.com/theme-next/hexo-theme-next/blob/master/docs/zh-CN/UPDATE-FROM-5.1.X.md
  [2]: https://dn-whjkm.qbox.me/blog%E9%97%AE%E9%A2%98.PNG
  [3]: https://dn-whjkm.qbox.me/%E9%97%AE%E9%A2%98%E8%AF%A6%E6%83%85.PNG
  [4]: https://dn-whjkm.qbox.me/%E6%96%87%E4%BB%B6%E8%B7%AF%E5%BE%84.PNG
  [5]: https://dn-whjkm.qbox.me/%E5%AE%89%E8%A3%85%E6%AD%A5%E9%AA%A4.PNG
  [6]: https://dn-whjkm.qbox.me/lib%E6%96%87%E4%BB%B6.PNG