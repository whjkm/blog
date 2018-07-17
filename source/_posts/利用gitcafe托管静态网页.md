title: "利用gitcafe托管静态网页"
date: 2014-11-29 19:32:20
tags: [gitcafe, git]
categories: hexo
---
折腾网页，用gitcafe托管静态网页
<!--more-->

由于[我的博客系统hexo][1]就是托管在gitcafe上面,所以对于gitcafe和github就有着比较浓厚的兴趣，前段时间又把git学习了一下，算是刚好入了个门吧；在gitcafe上有一个gitcefe-pages分支，可以用于展示我们的一个页面，给我们提供了一个免费的空间，也可以使用它的二级域名，但是项目名称和****.gitcafe.com一样（二级域名）；而且一个账号只能有一个这样的页面.
如果我们要想搭建一个页面，首先我们要申请一个gitcafe的账号（github也有这个功能，但是速度没有这么快）[我的gitcafe主页][2] 一看gitcafe这个名字，肯定是和git有关系，所以我们还要在电脑上安装git（本人用的是windows系统）在我之前的博客里有详细的介绍怎么安装[初探hexo博客][3]，第一次注册的时候，要添加在gitcafe上添加ssh密匙，ssh好像是一种加密协议，就相当于是验证我们的身份，因为我们的自己的电脑是在本地，而服务器端是在远端，所以我们就需要一种安全的传输协议，第一次添加这个的时候我也搞了很久，不知道怎么搞；多弄几次就清楚了；
如果我们是第一次用gitcafe的话就需要创建一个新的ssh密匙；
在自己的电脑上，需要提交托管的位置，进行git bash 然后进入一个窗口界面，输入下面的命令：
```
    cd ~/.ssh  
```
进入ssh的目录；如果没有这个目录的话，可以自己手动创建一个；也可以输入命令创建：
```
mkdir ~/.ssh  
```
接下来我们就要创建一个新的密匙：
```
ssh-keygen -t rsa -C "YOUR_EMAIL@YOUREMAIL.COM"  
```
把其中的邮箱地址换成自己的；
然后就会提示下面的信息；
```
$ ssh-keygen -t rsa -C "YOUR_EMAIL@YOUREMAIL.COM"  
Generating public/private rsa key pair.  
Enter passphrase (empty for no passphrase):  
Enter same passphrase again:  
Your identification has been saved in /c/Users/USERNAME/.ssh/id_rsa.  
Your public key has been saved in /c/Users/USERNAME/.ssh/id_rsa.pub.  
The key fingerprint is:  
15:81:d2:7a:c6:6c:0f:ec:b0:b6:d4:18:b8:d1:41:48 YOUR_EMAIL@YOUREMAIL.COM  
```
其中就需要我们输入passphrase ，这个就是我们以后提交需要输入的密码；
然后，我们的ssh密匙就生成啦，我们就可以去用户目录 (~/.ssh/) 下看到私钥 id_rsa 和公钥 id_rsa.pub 这两个文件，id_rsa是存储我们的个人信息的，千万不要把id_rsa的信息告诉别人；
然后我们就可以把我们的ssh密匙添加到gitcafe上；
进入 GitCafe -->账户设置-->SSH 公钥管理设置项，点击添加新公钥 按钮，在 Title 文本框中输入任意字符，在 Key 文本框粘贴刚才复制的公钥字符串，按保存按钮完成操作。
添加完成后，我们就要进行连接测试，看我们是否能够连接上gitcafe；
在git bash 里面输入：
```
ssh -T git@gitcafe.com  
```
如果是第一次连接的话，会出现下面的提示信息：
```
The authenticity of host 'gitcafe.com (50.116.2.223)' can't be established.  
#RSA key fingerprint is 84:9e:c9:8e:7f:36:28:08:7e:13:bf:43:12:74:11:4e.  
#Are you sure you want to continue connecting (yes/no)?  
```
我们就核对上面的信息和我们生成的是否一致，如果一致我们就输入 yes；
然后中间会提示要我们输入passphrse口令；
```
Enter passphrase for key '/c/Users/USERNAME/.ssh/id_rsa': 
```
连接成功会出现下面的提示信息：
```
Hi USERNAME! You've successfully authenticated, but GitCafe does not provide shell access.  
```
用户名就是我们gitcafe的用户名。

这是我们第一次使用ssh的步骤，像我开始用了一个账号搭建了我的博客，然后在github上还有密匙，然后我又注册了一个账号准备搭建一个页面；这怎么办呢？开始我搞的时候用的密匙总是会混乱；昨天我就找到了一个不是很好的解决办法；还是解决了这个问题；
第一步还是生成另一个密匙：
```
ssh-keygen -t rsa -C "YOUR_EMAIL@YOUREMAIL.COM" -f ~/.ssh/gitcafe 
```
这里的步骤和前面的基本上差不多；
第二步和前面的第二步一样，我就不重复了；
第三步这里就是关键的一步：在 SSH 用户配置文件 ~/.ssh/config 中指定对应服务所使用的公秘钥名称，如果没有 config 文件的话就新建一个，并输入以下内容：
```
Host gitcafe.com www.gitcafe.com  
  IdentityFile ~/.ssh/gitcafe  
```
后面的那个名字就是你密匙的名字；前面我在github上创建的密匙，我也是通过这种方式添加的，只不过把网址换成了github；
后面这里又有了一个问题，因为我是有两个账号，我的gitcafe密匙就是有两个，所以，我在里面就添加了两个密匙，第一个密匙就是我当前要用的密匙，当我们需要用哪个就把哪个放到第一位，虽然有点麻烦，但是还是可以存在两个一起用了；（可能这里还会有更好的方法，也希望大家有更好的方法可以告诉我啊）
后面的步骤就和前面的一样了，添加到gitcafe和测试连接；
我们可以连接在gitcafe之后，这下我们就可以搭建我们的页面了，也可以搭建一个博客系统，我搭建的博客系统是hexo（静态页面的博客）；
这里就需要利用我们的git工具了，首先我们在gitcafe上面创建一个公开项目（因为我们用的是免费的托管，私有项目是要花钱的），开始我们就可以填好我们的项目名，项目名要和我们的用户名一样，这样我们才能使用二级域名；前面填好之后，在项目主页那里应该就会自动生成我们的二级域名；
然后我们点击完成，下面就应该会出现一些代码：
```
1全局设置:  
git config --global user.name ''  
git config --global user.email ' 你的邮箱'  
2接下来:  
• 在本地创建新的 Git 仓库  
mkdir 1  
cd 1  
git init  
touch README.md  
git add README.md  
git commit -m 'first commit'  
git remote add origin 'git@gitcafe.com:你的那个项目地址'  
git push -u origin master  
或  
• 在本地已有 Git 仓库  
cd existing_git_repo  
git remote add origin 'git@gitcafe.com:项目地址'  
git push -u origin master
```
然后我们就可以直接再gitcafe里面添加文件了，也可以在本机创建一个新的文件夹然后再提交到gitcafe，也可以把一个已有的文件夹，git Init然后再把这个文件夹提交到gitcafe上，按照上面的代码就行了；
这里是第一次提交的代码；后面的提交更新就可以不用加上-u了，这些内容可以去学习一下git；
然后这里我们默认在git里面创建的是master 分支；而我们gitcafe上面可以展示的页面是gitcafe-pages分支，首先我们可以创建一个新的分支:
```
git checkout -b gitcafe-pages
```
其他的那些代码可以不变，这样我们提交的东西就会生成在gitcafe-pages分支里面，我们提交的时候就和前面有点不同了；
```
git remote add origin 'git@gitcafe.com:项目地址'  
git push -u origin gitcafe-pages  
```
因为我们是要提交到gitcafe-pages的这个分支上；所以需要把master分支改成gitcafe-pages分支；然后我们就可以提交我们的页面代码了；主要是html，里面可以含有css和js；搭建好了之后，不会马上就可以在二级域名上显示，要等一会；还有的就是，那个HTML文件名最好叫做index.html,我昨天开始不是这个名字，提交之后没有显示，改了之后，就可以显示了。然后我们就可以自定义我们的页面啦，做了一次小小的搬运工，祝大家折腾愉快~~


  [1]: http://whjkm.gitcafe.com/
  [2]: https://gitcafe.com/whjkm
  [3]: http://blog.csdn.net/whjkm/article/details/24264905
