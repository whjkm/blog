---
title: Hexo中Next主题的简单个性化
date: 2018-04-22 23:46:08
tags: hexo
categories: hexo
---
差不多有一年多没有折腾博客了，最近想着还是要重拾写博客的这一习惯，所以就动手将hexo重新折腾了一番。
## 1.评论系统
本来Next主题中是默认支持多说和Disqus的，但是多说已经关闭了，而且Disqus也被墙了，其他的一些评论系统用户量又不是很大，碰巧在github上看到了两个基于issue的评论系统[gitment][1]和[comment][2],就想着在Next中也给配置一下，开始还在两个系统中纠结了一番，最后还是选择了gitment。配置过程其实还算挺简单的，直接按照官方文档的步骤来就可以了。[中文文档][3]
### 1. 在github中注册 OAuth App
这里调用了github中的API，所以需要注册一个 OAuth application![注册][4]
将相关信息填写完整，`Authorization callback URL` 填要应用的站点地址。 （如：https://whjkm.github.io/）
完成注册后，会得到两个值：`client id `和`client_secret`,这两个值后面在页面中需要用到。
### 2.获取 Gitment代码
开始对Next的结构不熟悉，不知道应该将这段代码插到哪个文件中去，将范围缩小到`themes/next/layout/`这个文件夹，最先尝试是将代码插入到了`themes/next/layout/page.swig`文件，发现在每个页面中都有评论框了。我这里只想实现在post页面能够显示评论框，所以最终是将代码插入`themes/next/layout/post.swig`图示代码之后。本来还想about页面也实现这个功能，但是Next没有默认的about页面，这个功能就留到以后自己折腾吧。![获取gitment][5]
```js
<div id="container"></div>
<link rel="stylesheet" href="https://imsun.github.io/gitment/style/default.css">
<script src="https://imsun.github.io/gitment/dist/gitment.browser.js"></script>
<script>
var gitment = new Gitment({
  id: '页面 ID', // 可选。默认为 location.href
  owner: '你的 GitHub ID',
  repo: '存储评论的 repo',
  oauth: {
    client_id: '你的 client ID',
    client_secret: '你的 client secret',
  },
})
gitment.render('container')
</script>
```
### 3. 初始化
将页面发布之后，第一次使用需要使用Github账号登陆，确保和第二步所填 repo 的 owner保持一致，然后点击初始化就可以尽情使用啦。
## 2.添加 README.md
之前提交到github上就发现了这个问题，提交之后就发现没有`README.md`文件了，一时也没有想到解决办法，恰巧看到一篇博客介绍了这个问题；使用hexo配置文件`config.yml`中的`skip_render`参数，`skip_render`参数是用来跳过那些不用hexo渲染的文件。将参数设置为`README.md`，更新重新发布就可以了。
```
skip_render: README.md
```
![skip_render][6]
## 3.添加小图标
Next主题支持自定义`social link`,默认的选项有Github，weibo，twitter，这里在侧边栏自定义添加了douban和csdn，也可以自定义添加其他链接。Next中使用的是[fontawesome][7]图标库，在其中选择喜欢的图标，将图标的名字复制到Next的配置文件`config.yml`中的`social_icons`部分。
![social_icons][8]
## 4.添加访问量
Next中默认使用了不蒜子统计访问量，只需要在配置文件中修改就行了，有总访问量、总访问人数还有每篇文章的访问量。
![busuanzi][9]
直接修改Next的配置文件`config.yml`，将`enable`参数修改为`true`,后面的`site_uv_header`表示的是CSS图标，这个也可以进行自定义。

## 参考的文章
> https://blog.csdn.net/qq_33699981/article/details/72716951
> http://www.hahack.com/codes/comment-js/
> https://imsun.net/posts/gitment-introduction/


  [1]: https://github.com/imsun/gitment
  [2]: https://github.com/wzpan/comment.js
  [3]: https://imsun.net/posts/gitment-introduction/
  [4]: http://p7f8vq3cr.bkt.clouddn.com/%E6%B3%A8%E5%86%8COauth%20app.PNG
  [5]: http://p7f8vq3cr.bkt.clouddn.com/%E8%8E%B7%E5%8F%96gitment.PNG
  [6]: http://p7f8vq3cr.bkt.clouddn.com/ship_render.PNG
  [7]: https://fontawesome.com/icons?from=io
  [8]: http://p7f8vq3cr.bkt.clouddn.com/social_icons.PNG
  [9]: http://p7f8vq3cr.bkt.clouddn.com/busuanzi.PNG
