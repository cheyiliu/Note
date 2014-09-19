## Progit编译
原作者在fedora16系统下编译，我在ubuntu下安装
ruby 12.9M
calibre 132M
rubygems ruby-devel rubygem-ruby-debug rubygem-rdiscount (这行都安装不上)
编译不过去

pdf 
Creator:LaTeX with hyperref package
Producer:xdvipdfmx (0.6)

查到ubuntu编译方法：
安装： 
ruby
安装 pandoc 36.7M 这个工具能将 markdown 格式转换成 latex 格式

接下来安装 xetex (200M  这都是干什么用的)
sudo apt-get install texlive-xetex

到这里若制作 pdf 的话会报错
! LaTeX Error: File `url.sty’ not found.
可安装 latex-extra 来解决这个问题

sudo apt-get install texlive-latex-extra (靠！700M)


firefox默认字符集gb2312，需要：
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

android源码里有很多.md文件

1.
1.
1.
可以显示1. 2. 3.

android源码doc目录是很好的参考，可以追加头


http://daringfireball.net/projects/markdown/syntax



