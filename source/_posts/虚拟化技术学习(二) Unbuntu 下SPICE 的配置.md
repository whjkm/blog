title: "虚拟化技术学习：Unbuntu 下SPICE 的配置"
date: 2015-01-15 21:30:30
tags: SPICE
categories: 虚拟化技术
---
在Unbuntu 下SPICE 的配置的步骤
<!--more-->
最近一直搞spice,安装了就费了我好久时间,在网上看别人的一些教程都是说参看[官方教程][1]但是进教程一看,发现内容已经被删除了,经过我的不懈努力还是找到了一篇应该是从官方教程翻译出来的[教程][2]。然后我就按着教程一步一步的安装,但是在中间总是出现了一些错误,最后总是没能全部安装好，我也来做一次搬运工吧，搬运一些官方教程上面的步骤。
SPICE主要包括三部分：SPICE protocol （协议）、SPICE Client（客户端） 、SPICE Server（服务端）

协议是服务端与客户端通信的基础，
客户端是享受服务的终端机器，
服务端是提供服务的后台机器。

0.  安装前预备工作：
由于要从git 服务器下载源码安装，所以需要安转git工具
```
sudo apt-get install build-essential autoconf git-core
```
当然，还有编译安装包使用的工具也要安装：
```
sudo apt-get install libtool liblog4cpp5-dev libavcodec-dev libssl-dev xlibmesa-glu-dev libasound-dev libpng12-dev libfreetype6-dev \
libfontconfig1-dev libogg-dev libxrandr-dev kvm libgcrypt-dev libsdl-dev libnss3-dev libpixman-1-dev libxfixes-dev libjpeg8-dev \
libsasl2-dev python-pyparsing 
```

最后准备，创建一个文件夹，用来存放下载的安装包（如果你对下载安装位置很清楚，当然也可以不用新建这个文件夹）
```
cd
mkdir spice-sources
cd spice-sources 
```
1.  SPICE安装依赖包：

1.1  libcacard
This library is what SPICE uses to emulate smart cards and smart card readers.
```
git clone git://people.freedesktop.org/~alon/libcacard
cd libcacard
./autogen.sh
make
sudo make install
cd ..
```

1.2.  安装协议（SPICE protocol headers）
The first dependency to install is the spice protocol headers.
```
wget http://spice-space.org/download/releases/spice-protocol-0.8.0.tar.bz2
tar xjvf spice-protocol-0.8.0.tar.bz2
cd spice-protocol-0.8.0
mkdir m4
./configure
make
sudo make install
cd ..
```
1.3.安装celt
SPICE requires a specific version of the celt low-latency audio codec (0.5.1.3). Since it is unavailable in the Ubuntu repositories, it must also be compiled.
```
wget http://downloads.us.xiph.org/releases/celt/celt-0.5.1.3.tar.gz
tar xvzf celt-0.5.1.3.tar.gz
cd celt-0.5.1.3/
./configure
make
sudo make install
cd ..
```
2.  安装客户端（SPICE client）
This gives us spicec, the spice client. It's used to connect to SPICE guests.
客户端用来链接服务端的。
```
wget http://spice-space.org/download/releases/spice-0.8.1.tar.bz2
tar xjvf spice-0.8.1.tar.bz2
cd spice-0.8.1
./configure --enable-smartcard
make
sudo make install
cd ..
```
This step is possible to perform on a 32-bit host; it's only installing the SPICE client.
值得注意的是：32位系统只能安装SPICE 的客户端，下面的服务端是无法安装的！
3.  安装SPICE server
Now, it's time to build the SPICE server itself. SPICE has been rolled into QEMU now, so this step amounts to installing a recent version of QEMU. In fact, we will be pulling the latest QEMU source code for version 0.14. Oddly enough, QEMU 0.14 is available in the Ubuntu repositories, but SPICE support is not included in the build.
以上的意思是说QEMU已经包含 SPICE服务，
First, we need to change an environment variable so that ./configure can find the spice protocol libraries we installed. You will need to set this variable anytime you want to use qemu with SPICE, so it's easiest to put it in your .bashrc.
修改环境变量以至于让configure找到我们安装spice协议的函数库。
```
 echo "export LD_LIBRARY_PATH=/usr/local/lib:${LD_LIBRARY_PATH}" >> ~/.bashrc
source ~/.bashrc
```
Now, we can continue with the installation. Note that if you require a specific softmmu target, you can add a list of them with the --target argument. By default, QEMU only builds with support for 32-bit x86 guests.
继续安装，（PS：如果在之前已经安装过QEMU的话，这一步可以省略）
```
wget http://download.savannah.gnu.org/releases/qemu/qemu-0.14.0.tar.gz
tar xzvf qemu-0.14.0.tar.gz
cd qemu-0.14.0
./configure --enable-spice --enable-kvm --enable-io-thread --audio-drv-list=alsa,oss --enable-system
make
sudo make install
```
Now, we need to copy over some BIOS files that qemu will need to start SPICE VMs. We just need to put them in a location that QEMU expects them to be.
拷贝相关文件到QEMU 目录下让qemu启动虚拟机。（PS：如果之前已经安装QEMU，此步只需确认在/usr/share/qemu/目录下有以下两个文件即可，如果没有，那就得手动拷贝过去）
```
sudo cp pc-bios/vgabios-qxl.bin /usr/share/qemu/
sudo cp pc-bios/pxe-e1000.bin /usr/share/qemu/
cd ..
```
Now, qemu with SPICE support is installed in /usr/local/bin, and the ordinary system qemu is installed in/usr/bin. We'll make a shortcut command called 'qemu-spice' that you can invoke separately from the system qemu (which doesn't have SPICE support).
以上将含有SPICE 服务的QEMU安装到usr/local/bin（PS：也可能在usr/bin下），普通 QEMU 系统安装在/usr/bin下。以下是创建一个名字叫做qemu-spice的工具，其实是qemu的一个拷贝。
```
cd /usr/local/bin
sudo mv qemu qemu-spice
```
至此，server安装完毕。

4.使用SPICE
4.1使用Client
To invoke the spice client, use the command：调用客户端，使用如下命令
注意：<server hostname> 是服务器的地址，如果你的电脑同时安装客户服务端，那么你可以使用127.0.0.1来自己测试，<port number> 是服务端制定的端口号
```
spicec -h <server hostname> -p <port number>
```
4.2 使用Server
Invoking the spice server is rather more complex than the client, since you have to set the parameters of the virtualized guest. For example,
调用Server要比客户端麻烦得多。
```
qemu-spice -spice port=5930,disable-ticketing -drive file=/path/to/image -vga qxl -device AC97 -usbdevice tablet -m 1024 -enable-kvm -net nic -net user
```
 
注意：file=/path/to/image 要替换为系统的镜像文件，比如我的file=/kvm/vdisk.img

这样就启动了SPICE 服务端，然后在客户机上使用客户端命令
spicec -h <server hostname> -p <port number>
就可以在SPICE客户端启动服务机上的虚拟机系统了。
文件，比如我的file=/kvm/vdisk.img

以上是教程里面的安装过程.
经过以上的安装过程之后.我们来查看一下已经安装了哪些和spice有关的packages.
我们输入
```
dpkg --get-selections | grep spice 
```
可能会有一些内容没安装好,下面是全部安装好的截图.
![此处输入图片的描述][3]

我第一次安装的时候,发现里面很多东西都没有安装好,然后我就直接用 sudo apt-get install 这个命令,安装里面没有的packages.

然后我们就可以在kvm中安装虚拟机了,可以参看之前的博客 http://blog.csdn.net/whjkm/article/details/40587955

在kvm中安装spice请参看下一篇博客~


  [1]: http://docs.cslabs.clarkson.edu/wiki/SPICE
  [2]: http://www.verydemo.com/cj.jsp?c=59&u=ubuntu-xia-spice-de-an-zhuang-yu-pei-zhi
  [3]: http://img.blog.csdn.net/20141124190502963?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvd2hqa20=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/Center