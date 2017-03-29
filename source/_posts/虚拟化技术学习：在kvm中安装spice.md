title: "虚拟化技术学习：在kvm中安装spice"
date: 2015-01-16 19:29:37
tags: SPICE
categories: 虚拟化技术
---
在KVM中安装SPICE的步骤
<!--more-->
前几篇博客已经学习了spice的搭建和kvm环境的配置.这里就直接可以在kvm中安装spcie了.

首先,我们打开安装的qemu-kvm(我这里用的是虚拟系统管理器)
![图片1][1]

然后我们点击左上角,创建一个新的虚拟机.
![图片2][2]

按照上面的提示,找到系统镜像的位置.这里我安装的就是xp系统.
![图片3][3]
按照提示进行下一步:
![图片4][4]

然后进行磁盘的分配.
![图片5][5]

然后这里我们要选择自定义配置:
![图片6][6]


选择其中的显示选项,修改为 spice 
![图片7][7]


然后就会提示我们添加代理通道.把video default 修改为QXL
![图片8][8]
然后我们就可以开始进行安装了.按照提示一步一步进行安装.安装好了之后我们就可以来测试一下spice了.
安装好的xp虚拟机
![图片9][9]

然后我们通过spice客户端来测试一下

spicec -h <server hostname> -p <port number>
我这里就是在本机上测试 地址就是127.0.0.1  端口号为 5900 
![图片10][10]

然后我们就在 spice客户端中打开了刚刚创建的虚拟机啦.
这里还只是简单的实现了一下,还有很多操作等着自己慢慢的去摸索.


  [1]: http://img.blog.csdn.net/20141124191616962?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2hqa20=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center
  [2]: http://img.blog.csdn.net/20141124191735477?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2hqa20=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center
  [3]: http://img.blog.csdn.net/20141124192006485?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2hqa20=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center
  [4]: http://img.blog.csdn.net/20141124192056514?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2hqa20=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center
  [5]: http://img.blog.csdn.net/20141124192149757?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2hqa20=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center
  [6]: http://img.blog.csdn.net/20141124192250317?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2hqa20=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center
  [7]: http://img.blog.csdn.net/20141124192418004?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2hqa20=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center
  [8]: http://img.blog.csdn.net/20141124192611463?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2hqa20=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center
  [9]: http://img.blog.csdn.net/20141124192950906?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2hqa20=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center
  [10]: http://img.blog.csdn.net/20141124193334208?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2hqa20=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center