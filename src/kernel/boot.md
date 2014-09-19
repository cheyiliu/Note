nfs

kernel配置：
打开 Networking support -> Networking options -> TCP/IP networking -> IP: kernel level autoconfiguration 然后
File systems -> Network File Systems -> Root file system on NFS 选项才会出现。逻辑是：支持nfs，但不一定作为root


General setup -> Initial RAM filesystem and RAM disk (initramfs/initrd) support
若.config里没有配置CONFIG_INITRAMFS_SOURCE，就需在编译参数里指定。



因为海思发布的SDK里面setting.apk写入了默认IP地址，将导致nfs断开，所以将setting.apk删除，有上网需求的同事可以按照如下方式设置网络：
设置网关：route add default gw 192.168.88.1  设置DNS：setprop net.dns1 202.106.0.20


22 要想支持NFS root 需要修改启动行：
   root=/dev/nfs nfsroot=192.168.1.52:/home/gaojie/nfsroot rw ip=192.168.1.203
   menuconfig 里面已经配置好了 支持nfs root


3 打了有线网络设置后，就不能用nfs调试了吗？

bcm7231
设置nfs启动的命令 ip里面有一项是server ip
setenv -p STARTUP "boot -z -elf flash0.kernel: 'root=/dev/nfs nfsroot=192.168.1.87:/home/gaojie/Work-1/BCM7231-Rootfs rw, ip=192.168.11.39:192.168.1.87:192.168.88.1:255.255.0.0:ccdt-stb:eth0:on init=/init bmem=192M@64M bmem=256M@512M'"

setenv -p STARTUP "boot -z -elf flash0.kernel: 'root=/dev/nfs nfsroot=192.168.1.87:/home/gaojie/Work-1/BCM7231-Rootfs rw, ip=192.168.11.29:192.168.1.87:192.168.88.1:255.255.0.0:ccdt-stb:eth0:on init=/init bmem=192M@64M bmem=256M@512M'"

mlc 分区
nfs 启动：
setenv -p STARTUP "boot -z -elf  nandflash0.kernel: 'ubi.mtd=rootfs rootfstype=ubifs root=ubi0:rootfs mtdparts=brcmnand.0:10M(kernel),30M(recovery)ro,20M(splash),30M(rootfs),260M(system),1680M(userdata)   bmem=192M@64M bmem=256M@512M,rw, nolock init=/init'"
flash 启动：
setenv -p STARTUP "boot -z -elf  nandflash0.kernel: 'ubi.mtd=4 ubi.mtd=5 ubi.mtd=6 ubi.mtd=7 rootfstype=ubifs root=ubi0_0 mtdparts=brcmnand.0:10M(kernel),30M(recovery)ro,20M(splash),30M(rootfs),260M(system),1550M(userdata),100M(cache) bmem=192M@64M bmem=402M@512M,rw, nolock init=/init'"


setenv -p STARTUP "boot -z -elf nandflash0.kernel: 'root=/dev/nfs nfsroot=192.168.1.87:/home/gaojie/Work-1/BCM7231-Rootfs rw, ip=192.168.11.29:192.168.1.87:192.168.88.1:255.255.0.0:ccdt-stb:eth0:on init=/init bmem=192M@64M bmem=256M@512M'"

--测试内存启动流程用
setenv -p STARTUP "boot -z -elf nandflash0.kernel: 'root=/dev/nfs nfsroot=192.168.1.87:/home/gaojie/Work-1/BCM7231-Rootfs rw, ip=192.168.11.29:192.168.1.87:192.168.88.1:255.255.0.0:ccdt-stb:eth0:on init=/init bmem=192M@64M bmem=256M@512M mtdparts=brcmnand.0:10M(kernel),300M(system)'"


------------------

bmem = 这个参数完全是博通搞出来的！

改回flash启动：
setenv -p STARTUP "boot -z -elf flash0.kernel: 'ubiroot, bmem=192M@64M bmem=256M@512M,rw, nolock init=/init'"

setenv -p STARTUP "boot -z -elf flash0.kernel: 'ubiroot, bmem=192M@64M bmem=403M@512M,rw, nolock init=/init'"

./arch/mips/brcmstb/memory.c:early_param("bmem", bmem_setup);
只在这里检测bmem参数。（这样看，好像是博通加的不像是kernel标准的了？）
BMEM (reserved A/V buffer memory) support


-----------------------------
mtdparts= 由 cmdlinepart.c 解析
Read flash partition table from command line

 * The format for the command line is as follows:
 *
 * mtdparts=<mtddef>[;<mtddef]
 * <mtddef>  := <mtd-id>:<partdef>[,<partdef>]
 *              where <mtd-id> is the name from the "cat /proc/mtd" command
 * <partdef> := <size>[@offset][<name>][ro][lk]
 * <mtd-id>  := unique name used in mapping driver/device (mtd->name)
 * <size>    := standard linux memsize OR "-" to denote all remaining space
 * <name>    := '(' NAME ')'
 *
 * Examples:
 *
 * 1 NOR Flash, with 1 single writable partition:
 * edb7312-nor:-
 *
 * 1 NOR Flash with 2 partitions, 1 NAND with one
 * edb7312-nor:256k(ARMboot)ro,-(root);edb7312-nand:-(home)
 */






