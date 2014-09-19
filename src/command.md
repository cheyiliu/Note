## xargs
在android/external目录执行：find . -name "config.h" |xargs git add  -f 添加被.gitignore忽略的该文件

cat  A20-galaxy.tar.bz2.a*  | tar xj 

cat xx*  > xx

split lichee.tgz -b 1073741824 当前目录生成 xab xac ...

pkg-config

readelf -A 显示architecture信息

cat xx.bin /dev/zero | dd bs=1 count=64k > xx_64k.bin 将uldr.bin后面填充0，扩展到64k

cat /dev/zero >test.bin  迅速生成几百M test.bin 文件 内容全为0

dd if=/dev/zero bs=512 count=10  of=dd.bin  拷贝512x10个字节0到dd.bin
bs=512 不写即：
dd if=/dev/zero count=10  of=dd.bin 默认是512，此例拷贝51200字节
如果
dd if=/dev/zero bs=0 conout=100M of=dd.bin 执行得会很慢，因为一次读写1个字节
dd if=/dev/zero conout=1M of=dd.bin 可迅速生成512M文件


给每个空目录里面添加一个.tmp文件
find ./ -type d -empty | grep -v \.git | xargs -i touch {}/.tmp

tar 一个目录总是失败，原因是里面有个 root权限的文件

vim -b 以二进制形式打开 :%!xxd -g 1  切换到十六进制模式显示。
vim -bd base.ko base2.ko 二进制文件比较
