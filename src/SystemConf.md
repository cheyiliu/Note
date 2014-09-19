## Ubuntu系统常见软件包安装 ##
* 常用软件包安装：sudo apt-get install apache2 nautilus-open-terminal minicom vim wireshark vlc virtualbox
* apache: apache2
* 目录打开终端:nautilus-open-terminal
* 串口: ckermit(u-boot开发者推荐) 或 putty 或 minicom
* 飞鸽:iptux
* svn工具:subversion subversion-tools
* vim (系统默认的vi不好用)
* 64位系统运行32位程序提示找不到这个文件或目录，安装ia32库 apt-get install ia32-libs
* openjdk6:openjdk-6-jdk(ubuntu默认不包含任何jdk)
* gnome桌面:gnome-session-fallback 或 gnome-panel
* 命令行url工具:curl
* ts分析工具:tstools
* 使用SIMD的jpeg库:libjpeg-turbo(软件中心) 普通jpeg库：libjpeg-dev(开发版)
* synaptic 新立得包管理器
* wireshark 抓包工具
* python-numpy opencv需要
* python-markdown 用Python实现的Markdown(轻文本标记语言，把简单文本转换为HTML)
* openssh-server 若不装，scp推送提示：ssh: connect to host x.x.x.x port 22: Connection refused
* unrar rar 解压
* 注：没有的命令直接执行，会给出安装包名的提示。

## APT ##
### Debian/Ubuntu采用deb软件包,通常用dpkg（package manager for Debian）或 apt（Advanced Package Tool）工具进行管理。
		对应RHEL/CentOS/Fedora中的使用yum管理系统中的rpm（Redhat Package Management）。
### apt-get install
		Suggested packages:默认不安装。若要安装，需建立配置文件：/etc/apt/apt.conf：
		APT::Install-Recommends "true";
		APT::Install-Suggests "true";
		如果不希望apt-get下载suggested的包：
		apt-get --no-install-recommends install package
		实例说明1：
		apt-get install gcc-4.4
		The following extra packages will be installed:
	  	cpp-4.4 gcc-4.4-base(这2个是本体的朋友)
		Suggested packages:(不安装)
		gcc-4.4-locales gcc-4.4-multilib(这个建议安装，所以后面要手动安装才能用gcc) 
		libmudflap0-4.4-dev gcc-4.4-doc libgcc1-dbg libgomp1-dbg libmudflap0-dbg libcloog-ppl0 libppl-c2 libppl7
		The following NEW packages will be installed:
		  cpp-4.4 gcc-4.4(这是本体) gcc-4.4-base （本体+朋友共3个）
		0 upgraded, 3 newly installed, 0 to remove and 0 not upgraded.

		实例说明2：
		apt-get instal lib32z1-dev 显示安装3个包：lib32z1 lib32z1-dev zlib1g-dev
		若先执行：
		apt-get instal lib32z1则安装1个包：lib32z1
		再次执行：
		apt-get instal lib32z1-dev 显示安装2个包：lib32z1-dev zlib1g-dev

		apt-get -f install  可卸载依赖错误的软件包

### apt-get clean or autoclean 清除缓存，比如install一个包又remove此包再次install不会真正下载而是使用缓存包，若执行clean，install会再次下载。
	3) 包只下载不安装如：apt-get -d install vim (前提是这个包尚未安装否则提示已经最新)。
		实测执行后立即打印：Download complete and in download only mode，并没有真正下载包数据。
	4) apt-get下载的包在/var/cache/apt/archives，可在/etc/apt/source.list中修改存放位置。apt-get autoclean 命令可删除这些软件包。
	   实测执行后，仅删除了个别包，没有全部删除，强制删除可能会有问题。
	5) apt-get remove删除包，apt-get autoremove 自动删除没用的依赖包。
	6) apt-get update 这个命令什么作用？
		有2次系统装完无法apt-get install，软件中心能搜到但不显示install
	7) 加源 add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ hardy multiverse" ;sudo apt-get update
	8) 如何降低软件包版本？
	9) PPA是Personal Package Archives
		

## virtual Box相关 ##
	1) 在device菜单中执行“安装增强功能”鼠标可自由切换且可全屏显示 
	2) 共享文件夹设置后需重启
	3) File->Preference->General->Default Machine Folder 可选择非home/user(在这里觉得不爽)
	4) 网络设置选择桥接 ，就可以与win7 组成局域网，
		选择 桥接 后，虚拟机地址变为192.168.0.103 这个地址是由路由器的DHCP分配的
		[在DHCP服务器->DHCP列表与绑定 中看到]
		localhost 192.168.0.103 08:00:27:43:2B:B2 
		gaojie-desktop 192.168.0.104 08:00:27:94:EE:B3 
		这2个是虚拟机。通过真实机器的1根网线，路由器认出3个机器，此为桥接。
 	5) 4.1.12版安装系统有错误提示，在命令行运行虚拟机，提示需要安装virtualbox-ose-dkms和linux-headers-generic包
	   	The character device /dev/vboxdrv does not exist，按照提示运行：
		/etc/init.d/vboxdrv setup 提示找不到vboxdrv命令。No suitable module for running kernel found，反复安装卸载都不行。
		从virtualbox官网下载64位deb包，dpdg -i安装， /etc/init.d/vboxdrv 命令有了，但是setup失败：
		Starting VirtualBox kernel modules ...failed!
  		(modprobe vboxdrv failed. Please use 'dmesg' to find out why)
		sudo modprobe vboxdrv
		FATAL: Error inserting vboxdrv (/lib/modules/3.13.0-33-generic/misc/vboxdrv.ko): 
		Unknown symbol in module, or unknown parameter (see dmesg)
		查看dmesg：有 vboxdrv: Unknown symbol mcount。（找不到mcount符号）
		开始以为kernel版本问题，显示grub(见grub专题)，选择老版本kernel，还是不行
		最后查明，编译android的时候把gcc切换到4.4了，而这里需要4.6才能成功执行 /etc/init.d/vboxdrv setup(百度 Unknown symbol mcount）
		(都是12.04升级惹的祸，以后不要升级ubuntu，装完啥样就啥样，升级带来风险，但同时也学到了不少)
		20140819又升级了内核，又遇到这个问题，sudo /etc/init.d/vboxdrv setup搞定。
	6) 设置共享文件夹自动mount，文件系统类型vboxsf，默认不支持symbolic link，官网说处于安全考虑。
		ln: creating symbolic link `xx': Read-only file system,拷贝带软链接的目录提示：Read-only file system,执行：
		VBoxManage setextradata VM_NAME VBoxInternal2/SharedFoldersEnableSymlinksCreate/SHARE_NAME 1
		VM_NAME是虚拟机名，SHARE_NAME是共享文件夹名，重启即可。
	7) 访问U盘需安装VirtualBox Extension Pack，并Add the user name to the vboxusers group. 
		groups显示当前用户所在的组，没有vboxusers,执行adduser gaojie vboxusers，再groups显示了vboxusers
		在虚拟机菜单->Devices->USB Devices看到U盘，选择之即可在xp中访问。
	8) 个别程序需将文件拷至虚拟机目录，在共享ubuntu目录执行异常。已知的：winrar直接提示错误，Phoenixcard，uboot部分烧不进入。

## 包 ##
	1) dpkg

		-l List packages matching given pattern
		-i xx.deb Install the package
		-r xxx Remove the package
	
		u11.04执行：
		dpkg -i libpcap0.8_1.0.0-6_amd64.deb
		dpkg：警告：即将把 libpcap0.8 从 1.1.1-8 降级到 1.0.0-6
		(libpcap0.8 (1.0.0-6) 这纠结，到底是0.8 还是1.0.0-6啊)

		gtk-2.0和gtk-3.0 能共存但u11.04执行：
		dpkg -i libgtk2.0-0_2.20.0-0ubuntu4_amd64.debk
		dpkg：警告：即将把 libgtk2.0-0 从 2.24.6-0ubuntu5 降级到 2.20.0-0ubuntu4
		#可能不同的大版本可共存，小版本不能共存。
		libgtk2.0-0:amd64 2.20.0-0ubuntu4 (Multi-Arch: no) is not co-installable with 
		libgtk2.0-0:i386 2.24.6-0ubuntu5 (Multi-Arch: same) which is currently installed ??
		尝试卸载libgtk2.0 会删除近500M数据显然不行。
		
		deb包格式：
		DEBIAN/control文件
		Version: 2.20.0-0ubuntu4
		Architecture: amd64 (Multi-Arch: same  这里怎么写？)
		
	2) 包管理站
		http://pkgs.org/
		http://packages.ubuntu.com/  (11.04/11.10版本不维护)
		https://launchpad.net/ubuntu/
	3) libxx-dev包除.so还有.h和.a用于编译和静态链接。
	4) 依赖:包解压后 /DEBIAN/control 描述依赖包

	5) 包源：
		1) 格式
			deb http://xxx.com/ubuntu oneiric main
			deb-src http://xxx.com/ubuntu oneiric main
			deb-src指的是源码下载？
		 
		2) http://cn.archive.ubuntu.com
			采用apache服务器维护， Northeastern University Networking Center(美国东北大学)
			http://hk.archive.ubuntu.com/ubuntu/ (u12.04-server)
			http://cn.archive.ubuntu.com/ubuntu/dists/precise/main (u12.04)
			main目录下有Packages.gz 文本描述各种包，这些包都是Ubuntu Developers维护，比如：
				Package: libjpeg-turbo8
				Maintainer: Ubuntu Developers
				Architecture: amd64
				Source: libjpeg-turbo
				Version: 1.1.90+svn733-0ubuntu4
				Replaces: libjpeg8 (<< 8c-2ubuntu5)
				Depends: libc6 (>= 2.7)
				Pre-Depends: multiarch-support
				Filename: pool/main/libj/libjpeg-turbo/libjpeg-turbo8_1.1.90-0ubuntu4_amd64.deb

			Filename目录在：
				http://cn.archive.ubuntu.com/ubuntu/pool/main/(这个包都在这个目录)
			此目录有 liba/  libb/  ... libj/ 将库按字母排列
			而像wireshark这类的软件在：
				http://cn.archive.ubuntu.com/ubuntu/pool/universe/w/wireshark/wireshark-common_1.6.2-1_amd64.deb

			Get:1 http://hk.archive.ubuntu.com/ubuntu/ precise/main libatasmart4 amd64 0.18-3 [26.9 kB]
			非LTS版本弊端：20140901误删了wireshark1.6.2就安装不上了，因原路径ubuntu.com/.../universe/w/wireshark/下删除了这个版本
			打印看
			http://cn.archive.ubuntu.com/ubuntu/ oneiric/universe wireshark amd64 1.6.2-1         404  Not Found
			http://cn.archive.ubuntu.com/ubuntu/pool/universe/w/wireshark/wireshark_1.6.2-1_amd64.deb  404  Not Found
			现在(140901)wireshark在/ubuntu/dists/precise/universe/binary-amd64/Packages.gz中有描述
			用尽各种办法没找到1.6.2，还有源码编译这一出吧。
			
			修改源从11.10到10.04，update时看到：
			“获取：http://cn.archive.ubuntu.com lucid/universe amd64 Packages [5,430 kB]” 明白了
			apt-get install wireshark 成功安装1.2.7，点击详情死机（与u12.04退到1.2.7现象一样）
			非lts版过了维护期，安装的软件也就安装了，如果卸载就无法再安装(vlc/wireshark)
			

		3) http://archive.canonical.com (Apache/2.2.22 Ubuntu Server) 这个源内容很少,没有wireshark等
		4) http://mirrors.163.com/ubuntu/   ubuntu.com的镜像站(nginx)，速度快。因为是镜像站，某文件ubuntu主站没有了他也就没有了

	6) u14.04 remove openjdk-6-jre-headless 时候为啥会自动安装openjdk-7-jre-headless 也是依赖文件描述的？ 然后再remove openjdk-7-jre-headless jre才彻底删除



		

## grub ##
	1) 单ubuntu系统不显示grub菜单,可一直按住shift键显示
    打开/etc/default/grub文件，找到
        GRUB_HIDDEN_TIMEOUT=0 注释掉
    保存后，执行命令
        sudo update-grub
	可以选择旧版本的kernel

	sudo grub-install /dev/sdb
	系统正常启动

	出现grub rescue后 执行ls 会罗列出磁盘信息，然后
	ls (hd0,x)/boot/grub 依次执行，找到 /boot/grub所在目录，（所在目录会显示此目录下的文件）

	假设找到 (hd1,6) 调用如下命令：
	set root=(hd1,6)
	set prefex=(hd1,6/boot/grub
	insmod /boot/grub/normal.mod
	注意 = 前后没有空格

	然后调用如下命令，就可以显示丢失的grub菜单了
	grub rescue>normal

	进入linux，对gurb进行修复

	sudo grub-install /dev/sda (注意，这里要指定 mbr 坐在磁盘 不要指定分区号 开始我以为是/boot坐在磁盘，结果不对)

	整理老机器 80G盘+160G盘  80G盘上有多个分区并且安装了windows系统（是以前一直用的）有主分区，扩展分区等。
	在ubuntu上除windows系统分区外，全部删除。
	然后执行
	sudo grub-install /dev/sda
	重启成功 ，依次成功的尝试
	但是下一步，如果我把windows分区也删除了，会怎样呢？只有一个系统就不许要grub了
	进而把windows删除 然后把mbr写到sdb上试试

	开机后仍然有grub菜单（常磊直接新机器安装ubuntu 就没有grub菜单了）
	sudo grub-install /dev/sdb  （sdb执行成功了，不知道是不是真的安装到了sdb上，因为此时sda上也有）

## 32/64位库 ##

	i386  i686 都是32位  x86_64 代表64位
	/lib  64位库
	/lib/x86_64-linux-gnu 64位库
	/lib/i386-linux-gnu 32位库
	/usr/lib 64位库
	/usr/lib/i386-linux-gnu 32位库
	/usr/lib/x86_64-linux-gnu 64位库
	/usr/lib32  32位库

	/lib32  32位库
	以lib32ncurses5_5.7_amd64.deb 为例子，解压缩后：
	/usr/lib32/libmenu.so.5
	...
	/usr/lib32/libform.so.5
	/lib32/libncurses.so.5
	...
	/lib32/libtic.so.5
	#dpkg --add-architecture i386  ？？
	#apt-get update
	#apt-get install ia32-libs

## 系统安装 ##
	1) LTS版本：
		Hardy Heron (8.04LTS) 停止
		Lucid Lynx (10.04.4LTS) 2013.5
		Precise Pangolin (12.04.5LTS) 2017.4
		Trusty Tahr (14.04LTS)  2019.4
		不用lts版，过了维护期会有很多问题
	   其他:
		maverick (10.10)
		natty (11.04)  2012.10
		oneiric (11.10) 2013.5
		quantal (12.10) 2014.5
		saucy (13.10)   2014.7
		Utopic (14.10)		

	2) 用UltraISO制作的系统盘是FAT32格式。Ubuntu自带的Startup Disk Creator 制作的启动盘，运行系统正常，
		但安装中弹出提示框显示几个问号而不能继续。
	3) sudo passwd root；su root 进root用户,禁用root：sudo passwd -l root
	4) 2块硬盘组raid0，安装win7+ubuntu双系统时，出现麻烦：1 raid0，2 win7。这跟原来单盘，winxp的情形不同。
		主要原因是grub引导程序不支持raid0。
		方案1：另外安装一块笔记本硬盘用于ubuntu，安装时候把raid0双盘拔掉。独立安装，启动时候靠bios选择引导盘切换系统。
		问题：这块盘性能差，系统运行缓慢。
		方案2：再安装2块160G硬盘，组成raid0（实验可行，2组raid0，主板还是挺强的）。安装ubuntu12.04时候，选择boot程序装在sda上
		(此时应该是u盘)实测不行
		ubuntu无法启动。并且，160G raid0 两块盘工作时非常热。并且他们是sata2.0 3.0G  性能肯定不如我的sata3.0 6G双盘好。
		后来考虑，我安装一块320G 笔记本小盘。安装ubuntu12.04 时候可以选择启动程序安装位置，grub不是不支持raid嘛，我把boot
		程序安装在非raid的单盘上，然后把系统安装在raid0上，安装倒是成功了，但是无法启动，没有出现启动菜单，选择320G单盘为
		启动盘，提示grub错误，丢失文件。
		方案3：使用EasyBCD引导，不使用grub，折腾一个晚上，没有成功，能出现grub菜单，也可以选，但是停止在启动页面，无法进入ubuntu系统。
		方案4：raid0 独立安装ubuntu，虚拟机安装winxp。
	5) /home单独分出较好，重装系统时不用备份数据。
	6) .bashrc
	7) https://wiki.ubuntu.com/

	7) u12.04 (20140903安装，维护到2019年4月)
		1) 采用了更为合理的独立/home分区，如果系统需要重装不用拷贝home区的数据。
		2) /分区预留200G，新系统装完使用3.9G。安装必要软件并使用一段时间后使用？？G
		3) 浏览器变黑体：sudo apt-get remove fonts-arphic-ukai fonts-arphic-uming(删除楷体)
	8) 重装系统需备份：
		1) iBus拼音输入法自定义词典 Preference - Dictionary
		2) 邮件通讯录
	9) 在线升级
		公司的u11.10每次升级提示都选“否”，事实证明3年工作良好。
		家里的u14.04升级几次变得不稳定，经常死机。vlc也不好用。所以也采用不升级补丁策略。
		升级后，不可预见的事情很多。目前看最稳定经典的版本仍然是10.04，11.10也不错。
		新版本功能增加以及架构调整需要很长时间才能稳定。

	10) 删除unity
		apt-get -y --auto-remove purge unity
		apt-get -y --auto-remove purge unity-common
		apt-get -y --auto-remove purge unity-lens*
		apt-get -y --auto-remove purge unity-services
		apt-get -y --auto-remove purge unity-asset-pool

	11) Server版
		Software selection:
		OpenSSH Server
		LAMP server (linux apache mysql php?)
		PostgreSQL database
		Virtual Machine host(?)
		Manual package selection：进入一个怪异界面，q退出即可
		--aptitude??
		Configuring mysql-server-5.5
		设置 root 密码 123456
		命令行设置ip地址子网掩码网关：
		ifconfig eth0 192.168.4.1 netmask 255.255.255.0 up
		route add default gw IP
		echo "nameserver 211.98.1.28">> /etc/resolv.conf
		重启会消失

		正确方法：编辑 /etc/network/interfaces 文件：

		auto eth0 
		iface eth0 inet static （原来是dhcp）
		address 192.168.200.99 
		netmask 255.255.255.0 
		gateway 192.168.200.100 
		dns-nameservers 202.106.0.20 （/etc/resolv.conf 自动添加:nameserver 202.106.0.20）

		添加root用户：
		sudo passwd root （yinjiezoule）
		su
		安装完成后  apache mysql php都ok
		装完后，tomcat 也默认都装好了  端口8080

	12) bug list
		1) u14.04+unity
			1) ctrl+space切换中英文有时不灵敏（u11.10+gnome很灵敏）
			2) 文件浏览卡有时字体突然变粗，进退几次恢复正常
			3) 使用过程多次出现死机

	13) 如何方便跟踪某个库在系统自带还是后安装的？


## 软件配置 ##
	1) apache配置
		1 /etc/init.d/apache2 restart 
		2 网页地址在 /var/www 默认有index.html内容：It works! 如果无index文件显示目录和文件列表。
		3 /etc/apache2/httpd.conf
		4 /etc/apache2/sites-available/default 设置网站地址
		/etc/init.d/apache2  restart
		<Directory /var/www>   <Directory /home/rimke/www>
		apache 服务终止，导致wiki,mantis,testlink无法工作。
		vcs:/home/vca/git# /etc/init.d/apache2 restart
		Restarting web server: apache2apache2: Syntax error on line 185 of /etc/apache2/apache2.conf: 
		Syntax error on line 1 of /etc/apache2/mods-enabled/php5.load: Cannot load /usr/lib/apache2/modules/libphp5.so 
		into server: /usr/lib/apache2/modules/libphp5.so: cannot open shared object file: No such file or directory failed!
		ubuntu服务器  /usr/lib/apache2/modules/ 下面有一个libphp5.so 但是debian同目录变成了libphp5filter.so
		copy libphp5filter.so 为libphp5.so 这样做完，ldap 又能安装了.

	2) samba
		a 安装samba 
		sudo apt-get install samba
		sudo apt-get install smbfs
		b 配置samba sudo vi /etc/samba/smb.conf
		c 重启samba服务器
		#/etc/init.d/samba restart
		1  samba
		每个用户开一个samba连接。在 /etc/init.d 中有一个samba程序
		/etc/samba/smb.conf 这个是配置文件。配置每个用户的读写权限等。
		修改权限后，要执行 /etc/init.d/samb restart 重启动samba服务。
		建立samba服务 我在 ubuntu 上直接打开网络 就可以访问


	3) Nginx配置


	4) ssh服务
		如果配置了端口，登录命令是 ssh xxx@x.x.x.x -p xxx 而不是 ssh xxx@x.x.x.x:xxx

	5) tftp
		apt-get install tftpd-hpa (RFC 783)

		tftp-hpa 的配置文件为 /etc/default/tftpd-hpa 
		TFTP_USERNAME="tftp"
		TFTP_DIRECTORY="/your/tftp/path/"
		TFTP_ADDRESS="0.0.0.0:69"
		TFTP_OPTIONS="-l -c -s"
		-c为可创建新文件，若无此参数，put命令则可能出现错误提示，此时只能覆盖原有文件不能创建新文件； 
		$sudo  /etc/init.d/tftpd-hpa start
		$sudo /etc/init.d/tftpd-hpa stop
		$sudo /etc/init.d/tftpd-hpa restart


		apt-get install xinetd
		vi /etc/xinetd.d/tftp
		service tftp
		{
				socket_type = dgram
				protocol = udp
				wait = yes
				user = root
				server = /usr/sbin/in.tftpd   //tftpd 的可执行程序
				server_args = -s /home/username/tftpboot  路径
				disable = no
				per_source = 11
				cps = 100 2
				flags =IPv4
		}
		
		然后 /etc/init.d/xinetd restart

		This program is run from a terminal: in.tftpd
		TFTP mainly to serve boot images over the network to other machines(PXE网络启动)
		tftp-hpa is an enhanced version of the BSD TFTP server.
		最终的可执行程序为 in.tftpd

		xinetd : replacement for inetd with many enhancements 
		(eXtended InterNET services daemon)
		这个是用来管理 tftp服务以及其他服务的

	6) nfs
		$sudo apt-get install nfs-common  客户端
		$sudo aptitude install nfs-kernel-server 服务端
		The NFS kernel server is currently the recommended NFS serer for use with Linux,
		featuring features such as NFSv3 and NFSv4,

		配置 /etc/exports 文件
		man exports：
		exports - NFS server export table
		比如：
		/home/username/NFS/fawn    *(rw,sync,no_subtree_check,no_root_squash)

	7) wiki
		wiki导出pdf做过很多尝试，始终没有配置成功

	8) minicom
		-s   -w
		进入 Serial port setup 设置ttyUSB0 软硬件流控为No
		进入 Modem and dialing parameter setup 依次输入A B K 将后面的字符删除
		ctrl+a +l 将串口接受到的所有数据保存到文件中,如果没有指定文件路径,那么文件将默认保存到
		打开minicom时所在的当时目录下,比如shell当前在/home/目录下,这是执行minicom命令打开,
		然后ctrl+a+l打开文件捕获,随后串口上来的所有数据将被捕获存储到/home/目录下minicom.cap的文件中
		ctrl+a +w 打开自动换行功能,如果arm上传来的数据很长而且没有回车换行符号,那么如果不开
		启自动换行功能,尬觉后边传上来的数据就看不到了.minicom中上下左右按键不能用

	9) OpenSSH
		配置文件“/etc/ssh/sshd_config”
		HostKey /etc/ssh/ssh_host_rsa_key

		ssh-keygen -f "/home/username/.ssh/known_hosts" -R [192.168.1.52]:29418  删除
		ssh-keygen -t rsa -C "username@cyclecentury.com" 同一机器2次运行文件内容完全不同
		ssh把访问过的计算机的公钥记录在~/.ssh/known_hosts，known_hosts以纯文本存放。如果帐号被人入侵，就可以由
		known_hosts得知你访过的计算机列表。OpenSSH4.0引入Hash Known Hosts功能，known_hosts内容以hash方式存
		放。此功能默认关闭，需手动在ssh_config加上"HashKnownHosts yes"开启。

		OpenSSH工具ssh-keygen协助管理hash了的known_hosts
		ssh-keygen -F 计算机名称"找出相关的公钥：
		ssh-keygen -F www.example.net
		若要更新计算机公钥，可以先打"ssh-keygen -R 计算机名称"删除该计算机的公钥，然
		后再"ssh 计算机名称"再进入该计算机，ssh自然会重新下载新的公钥。
		ssh-keygen -H





## 错误报告 ##
	1) 装完显卡驱动，声卡驱动不工作了。安装一个3D桌面的东西，桌面显示不正常了。
	2) ubuntu12.04+wireshark1.6.7，看视频抓包卡死，cpu占用100%。xp+wireshark1.11,或ubuntu11.10+wireshark1.6.2_1没有问题。网上讨论但没找到解决办法。有人说按抓1.2.x解决。
能否在12.04上安装wireshark1.12.0呢？
看http://packages.ubuntu.com/search?suite=all&searchon=names&keywords=wireshark


## 错误报告 ##
	1) 装完显卡驱动，声卡驱动不工作了。安装一个3D桌面的东西，桌面显示不正常了。
	3) 由11.04升级到11.10成功(以前这样升级都是失败的，进不了桌面)
	4) ubuntu 11.10  evolution 的目录不在  ~/.evolution 了 而是 ~/.local/share/evolution 
	5) unity 问题挺多，新产品出来需要很多时间磨合


## 技巧 ##
	~目录建立Work保存所有工作内容，可能误删。可将其改为root权限，在内部再建立分类目录。这样在work下建立新目录较麻烦，有助于强制规范此目录。


## other ##
	1) u12.04损坏了libncurses库，导致man xx无法使用：libncurses.so.5: No such file or directory。u10.04 在/lib下有此库64位版本，
	而u12.04 /lib/x86_64-linux-gnu下只有libncursesw.so.5没有 libncurses.so.5。apt-get install 显示版本已最新，apt-get remove失败
	下载libncursesw5_5.9-4_amd64.deb，dpkg -i安装后/lib/x86_64-linux-gnu下出现此库，解决。

	2) 解决u12.04+wireshark1.6.7 卡死问题：手工下载包及多级依赖包成功降低版本至1.2.7，抓视频包不死机了但点击详情死机。
	升级到u14.04用的1.10.6较难很多依赖包版本不对需重装，开始的都能装，最后所需gtk3.0与系统冲突无法安装。ubuntu版和winxp版不同，
	前者包只有2M，许多依赖包靠系统提供，后者25M，应该包含了所需全部。u11.10之1.6.2
	
	3) ubuntu server12.04 apt-get install openjdk-7-jre 安装jre7成功，并自动配置了update-alternatives

	
## gcc ##
	编译android4.0需要gcc4.4

	u10.04 gcc4.4.3 
	u11.04 gcc4.5
	u11.10 gcc4.6.1
	u12.04 gcc4.6.3
	u14.04 gcc4.8.2 可成功编译ics

    ubuntu-desktop默认有gcc没有g++。u14.04新系统安装g++-multilib包，自动安装依赖包：g++-4.8 g++-4.8-multilib gcc-4.8-multilib。这也合理，g++-multilib库不能脱离g++独立存在
	ubuntu-server默认无gcc编译器需安装 gcc make


## 输入法 ##
	u14.04安装完就已经支持ibus输入法，直接选择汉语拼音。如果输入sh显示sang，说明是双拼，改成全拼即可。

## 做死 ##
	引发系统崩溃的2个手贱命令
	apt-get remove unity* (想删除unity桌面)
	apt-get remove python (想更换python版本)


## CPU信息 ##
	公司i5-2400 3.10GHz × 4 Sandybridge 
	

## 环境变量
~/.profile 当前用户
/etc/profile 全局用户
~/.bashrc
/etc/bash.bashrc

## Notification Area ##

u11.10以后通知区域使用白名单，只有位于白名单的程序才可以显示在该区域，iptux不显示解决办法
安装： dconf-tools: is a low-level key/value datrabase degigned for storing desktop environment settings.
命令行输入 dconf-editor 找到 desktop>unity>panel 把systray-whitelist 的值改为 all

或者不安装dconf程序：
gsettings set com.cononical.Unity.Panel systray-whitelist "[....]" 与UI方式一样的

以上方法在u14.04不灵




build-essential除了gcc multilib 等还包含其他相关库





首选项-system-上面两行改为gb18030 panel font 改为文泉驿
u11.04 unity chromium最小化就关闭,iptux关闭无法再打开来消息不闪烁


使用pci卡的串口，
lspci -v 可以看到
03:01.0 Communication controller: NetMos Technology PCI 9835 Multi-I/O Controller (rev 01)
	Subsystem: LSI Logic / Symbios Logic Device 0012
	Flags: medium devsel, IRQ 16
	I/O ports at ec00 [size=8]
	Kernel driver in use: parport_serial
	Kernel modules: parport_serial

需要先安装 sudo apt-get install setserial 然后执行

/dev/ttyS1 port 0xec00 UART 16550A irq 16 Baud_base 115200
注意这里irq的值是上面打印出来的那个。 ttys1 的地址只有靠蒙了 肯定是上面列出来的那几个
很幸运可以用了，不用安装额外的驱动

/dev下面有很多tty是被  minicom打开后也是默认tty  而串口是ttySx


backspace按键的设置 ctrl+a+t B- backspace key sends ：DEL /  BS  选择 DEL  工作正常

17 在上面板上选择了“新建面板” 结果左右出现了空白  网上解决办法 删除username目录下的一堆 .
开头的文件夹
删除后,所有的设置都回复初始状态. 令我痛心的是  邮件也需要重新配置
Evolution 首次运行时会在您的主目录内创建 .evolution  目录，并使用它储存本地数据。接
下来首次运行助手会协助您设置电子邮件帐户和位于  .gconf/apps/evolution 的其他用户设置。
我恰恰把这些东西都删除了 真是防不胜防
邮件全部都存放在  .evolution 目录下
还好  配置完成后 邮件都还在 因为目录没有变


20系统有一个recovery 模式，可以在紧急情况下进入shell 进行必要的操作。
 比如今天 我对系统的bash 做了一个  chmod u+s 的操作，导致系统无法启动。进入recovery
（注意，有很多选项，有一种进去后没有写权限只能读） 执行 chmod u-s 就好了


22 ubuntu中使用usb串口线，设备为 /dev/ttyUSB0  在11.10 中，板子上电会导致putty推出
只用minicom 就没有问题，但是minicom怎么保存数据呢？


24 ubuntu修改MAC地址

sudo ifconfig eth0 down
sudo ifconfig eth0 hw ether AA:BB:CC:DD:EE:FF
sudo ifconfig eth0 up

此法重启无效，可以写在 /etc/init.d/rc.local 里面，但是偶尔不灵，启动后需要停止网络
再开始。就没有像windows那样直接改网卡ROM的方法？


29 20111229 U盘安装ubuntu 10.04.3 server 无法挂在光驱的问题：
先将 ubuntu server 的 iso 放到优盘上，然后在提示无法找到光驱时，按 alt+f2 打开一个新
的 console 窗口，将 iso mount 上，具体操作如下：

mkdir /mnt/usb /mnt/iso
mount -t vfat /dev/sdc1 /mnt/usb
mount -t iso9660 -o loop /mnt/usb/ubuntu-10.10-server-amd64.iso /mnt/iso
【这个方法没有解决此问题，原文是针对10.10的】

首先重启电脑，还是进入那个引导选择菜单，选择最下面的帮助 也就是Help，然后会提示你按
什么F1 F2的你直接按F6按了以后会提示一堆英文不用管。
下面让输入命令，输入 install cdrom-detect/try-usb=true 回车可以进入安装界面了，一路
GoGoGo就不会出现上次的问题。


显示安装 gevent 库的时候出错

下载libevent 库 configure make make install 然后 gevent可以安装了，最后 rehash命令
没有  【 freeBSD的rehash命令】
libevent 同步事件通知库
但是还是不行！

输入 passphrase 与否，文件生成的格式不同。写了passphrase应该是对密钥又加了一次密码。

公钥中包含邮箱信息


For more information about SSH key passphrases
Enter passphrase (empty for no passphrase): usernamexxx

还有，review的时候确实要都看一遍才可以 merge成功 

Server Host Key
Fingerprint:
08:7b:ca:a4:b7:31:87:3b:81:93:f6:b5:c2:d9:9c:61

Entry for ~/.ssh/known_hosts:
[192.168.1.52]:29418 ssh-rsa AAAAB3NzaC1yc2EA...M8OxZQ==

重新注册了rsa key 第一次连接gerrit2 账户的时候

The authenticity of host '192.168.1.52 (192.168.1.52)' can't be established.
RSA key fingerprint is 25:01:09:08:39:b5:9b:22:93:fe:ee:62:2c:23:d6:35.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.1.52' (RSA) to the list of known hosts.

这时在.ssh目录下生成 known_hosts 文件 内容：


但是这个跟gerrit Setting SSH Public Keys 显示的并不一样啊！
这里显示的是 etc/ssh_host_rsa_key.pub 文件内容  （另外一个是dss 是另外一种加密算法，
我用的是rsa 2.4.2就只有一个rsa没有dss了）

所以 known_hosts 里面的内容并不是gerrit把那个pub key 直接发过来的。
删除known_hosts 再次生成，内容一样！




从提示信息上看，应该是qtss用户未能创建造成的，查看了一下Install脚本，发现创建用户的脚本是这样的：
if [ $INSTALL_OS = "Linux" ]; then
/usr/sbin/useradd -M qtss > /dev/null 2>&1
else
/usr/sbin/useradd qtss > /dev/null 2>&1
fi
但是useradd并没有-M的命令行参数，应该为-m，将-M修改成-m后，再执行Install脚本，
安装成功。此时服务已经启动，
可以使用如下命令确定服务是否已经启动：

Couldn't find the en language messages file
/usr/local/sbin/streamingadminserver.pl line 2168.

Of course this happened because the AdminHtml dir didn't exist.

-----------
20121219 关于dell服务器 R810  安装ubuntu10.04 server  android环境
1 原来192.168.1.52地址给我的一个台式机用，现在给dell服务器用，ssh时候提示：
WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY
然后按照提示处理即可


DNS服务器的设置(不要设置这个，这是自动生成的)
#/etc/resolv.conf
nameserver 202.96.128.143

设置网关
route add default gw 10.65.1.2


R810 配了RAID5 拷贝android out目录 16177M 用时6分钟，折合44M/s。改成4盘 RAID0，硬盘
写入速度大幅提升，但是编译仍然需16分钟。（原raid5 16-17分钟）。现在还有一个内存的主频
只工作在937M。

R710 4盘raid0 拷贝19465M 用时150s 折合130M/s 读写，性能不高啊。

hdparm  -Tt /dev/sdb2

/dev/sdb2:
 Timing cached reads:   13898 MB in  2.00 seconds = 6954.88 MB/sec
 Timing buffered disk reads: 1232 MB in  3.00 seconds = 410.15 MB/sec （纯粹读 410M/s）



hdparm -tT /dev/sdb1  测试硬盘性能
time cp test1 test2  测试拷贝速度

磁盘阵列gfs文件系统
hdparm 只得到300M

-----------------
time cp -rf xntg-1/ xntg-2   
real	2m27.405s  （表示用时2分27s）
user	0m0.232s
sys	0m34.930s
------------

iostat（apt-get install sysstat）


R810 远程开关机：
IPMI OVER LAN

20130327
-----------------------------
red hat 系统用rpm格式，Debian系列（比如ubuntu）用deb格式。Ubuntu安装rpm需先用alien
转换软件转换成deb格式。

---MySQL-----------

mysql被orcal收购www.mysql.com 
默认端口3306
ubuntu12.04自带mysql 安装时设置mysql root用户密码

192.168.1.52 /192.168.7.95  mysql root 密码：123456

sudo /etc/init.d/mysql restart


ubuntu上默认不允许远程连接 mysql，需要：

grant all PRIVILEGES on discuz.*（数据库名称） to ted（用户名）@'123.123.123.123' identified by '123456';（密码）

但是有错误
mysql -h 192.168.7.32 -P 3306 -ugaowei -p123456
ERROR 2003 (HY000): Can't connect to MySQL server on '192.168.7.32' (111)


-------------
vim /etc/mysql/my.cnf

# Instead of skip-networking the default is now to listen only on
# localhost which is more compatible and is not less secure.
#bind-address           = 127.0.0.1  <---注释掉这一行就可以远程登录了 （管用！）
-------------------------------

errno 111 is ECONNREFUSED
----------------

配置过程中检测到某些文件/目录不可写，在服务器上 对这些文件的其他用户加写权限即可。

配置信息：
数据库主机 localhost
端口号  3306
用户名 xxx
密码  xxx
数据库名 testdb
数据库类型 选 MySQL
管理员姓名： username
登录密码：test


更新到ubuntu12.04后，显示 “图像处理库 不支持”
【网】“同时支持GD和ImageMagick 6两种图像处理库选择”
运行
apt-get update
apt-get install php5-gd


mysql 使用root：123456 账户登录，搜出来2个db :performance_schema   test 
我创建一个新的，显示不能成功，选择test，安装成功了！
账户username:test

可以系统帐号 root@'192.168.1.4' 密码 vcrootpass  能查到11个db（用skyuc的配置页面）
user = debian-sys-maint
password = TgaAWxNqnEsF1tlo 能查到2个db  一个my_wiki  一个testdb 


---------------------------------------------------
DNS服务安装
12.04server 已有 bind9 套件
sudo /etc/init.d/bind9 start  没成功


重启网络
sudo /etc/init.d/networking restart


---20130605--------
关于磁盘阵列
Dell MD3600F  SAN解决方案，可以支持直连4-8台server
server安装HBA-FC卡，在/dev下看到 sdb/sdb1/sdb2   dm/dm-1/dm-2
需要去mount  dm-2  对系统来说，跟外接一块硬盘一样。

-----------------------

find . -name "*.c" -print0 | xargs -0 sed -i 's/x_cnt/x_counter/g'

fuser -m -v 查看谁在用某个文件描述符

两种方法：
echo 3 > /proc/sys/vm/drop_caches
umount /dev/sdx

配置eth1 

sudo netstat -anp|grep 80 

开始/结束 防火墙
ufw enable|disable

2013虚拟化技术 反馈
vmware 技术

ubuntu nginx 路径
/usr/share/nginx/www


Ubuntu Server 12.04 网口
/etc/init.d/networking restart 经常出现eth0 无法重启，只能


lamp
http://192.168.1.235/lam/templates/login.php

centos
网口自动连接，在网络配置里选 connection atuo 

如何确定服务器是ubuntu server？
cat /proc/version 
cat /etc/issue 
lsb_release -a


----------Wiki-----------------

20131205 下载 MediaWiki 1.21.3
ubuntu server 配置 mediawiki过程简单，安装server版ubuntu（选择LAMP），将mediawiki
解压到 var/www/mediawiki,访问192.168.x.x/mediawiki,然后next next 安装mediawiki 
最后生成一个 LocalSettings.php  把它拷贝到服务器上index.php 所在目录 再刷新浏览器就可以了

安装了最新的mediawiki 编辑的时候也没有advanced 功能（比如插入表格）看来这是一个类似
插件的东西，要额外安装
mediawiki.org/特殊页/version里面看到 Installed extensions

20131205 安装1.21.3 没法运行，经查，系统没有安装php和mysql。注意安装系统的时候一定要
选择LAMP选项
apt-get install libapache2-mod-php5 php5
结果提示下载这个文件，而不是打开一个网页。在网上查，说apache没有成功加载php模块


新安装的ubuntu server  
apt-get install git-core 找不到
此时需要update 但是
apt-get update 错误
Failed to fetch gzip:/var/lib/apt/lists/partial/hk.archive.ubuntu.com_ubuntu
Hash Sum mismatch
E: Some index files failed to download. They have been ignored, or old ones used instead.
需要删除
ubuntu@ubuntu:/var/lib$ sudo rm -rf apt/lists/partial/
ubuntu@ubuntu:/var/lib$ sudo rm -rf apt/mirrors/partial/
再update


---------
20140114 早晨开机分辨率变成了1024*768。重启2次，各种设置无效，不认显示器。乱点了一通。
突然就又好了，不知何故。
20140117 问题重现

由于LInux原始的防火墙工具iptables过于繁琐，所以ubuntu默认提供了一个基于iptable之上的防火墙工具ufw。

我在调试 mysql 外网访问时候，执行了 ufw enable  结果导致所有web服务无法使用：apache wiki  gerrit ssh 等




-----------------------
20140717
给马龙安装12.04，安装gnome-session-fallback的时候装不上，源有问题。需要搞搞清楚，“源”到底是个什么原理。

记录源的文件是：


----
20140718
思考一个问题，同样是10.04系统，执行apt-get install git-core  王贺超，侯生勇的git版本就是1.7.5  1.9.2
而马龙的就是1.7.0 导致版本低无法正常使用 repo sync，错误： 什么 gc错误。
源不同吗？   原因是马龙装的10.04 选的中文版，结果 /etc/apt/source.list 里面的源都是 http://cn.xxx.xx  都是cn开头的
重安装10.04，选择英文版，apt-get install git-core  找到的版本还是 1.7.0
后来实在没有办法，把我的  /usr/bin/git 拷贝给他，竟然就能用了，  git是个“绿色软件”啊


-------
1 ubuntu14.04 拼音输入法总是不爽
在软件中心搜索 IBus Pinyin Setup
重启电脑，我在ubuntu11.10上熟悉的输入法终于回来了（一个蓝色的“拼”字那个）

3 安装ubuntu12.04 server ：  mysql  root:12345


对于可视化的网页编辑器，部份网页制作者选择Adobe Dreamweaver，
一部分人使用更图形化的Adobe Golive。而一部分人则纯粹用代码编辑器，

2 每个用户可以设置别人访问自己的权限。比如是否可以写和删除。
3 关于权限设置  Operation not permitted (1) 没有解决


System->Preferences->ATI Catalyst Control Center
找到 Display Manager 下面显示一个DTV(2) 当然前提是HDMI上连接我的这个AMOI大电视。
右侧选项卡里面有一个“HDTV”进入后 下面列表里面有 1080P50的选项。
选中后选择 Apply  完美实现了1080P！！！

但是保存不住，重启后又恢复成原来老样子了。






cat /proc/asound/card0$/codec#0 |grep Codec   
Codec:VIA ID 397
cat /proc/asound/card0$/codec#0 |grep Codec  
Codec:ATI ATI RS690/780 HDMI


4 注意一个错误
 sudoers is owned by uid 1000, should be 0 

解决办法：
chown root:root /etc/sudoers 
chmod 440 /etc/sudoers 

5 关于ubuntu里面的网络。很多时候，直接在控制台里面通过网络下载。
aplay -l alsa声卡命令
如果成功显示类似内容：
card 0: IXP [ATI IXP], device 0: ATI IXP AC97 [ATI IXP AC97]
Subdevices: 1/1
Subdevice #0: subdevice #0
card 0: IXP [ATI IXP], device 1: ATI IXP IEC958 [ATI IXP IEC958 (AC97)]
Subdevices: 1/1
Subdevice #0: subdevice #0
不成功显示：
aplay: device_list:221: no soundcard found...
不成功的话，往下看。
去除系统自带声音模块
sudo apt-get --purge remove linux-sound-base alsa-base alsa-utils
重新安装，并安装最新模块：
sudo apt-get install linux-sound-base alsa-base alsa-utils
重启后可能不能进入gdm图型登录窗口。
ubuntu 的用户输入
sudo apt-get install gdm ubuntu-desktop
Xubuntu的用户输入：
sudo apt-get install gdm xubuntu-desktop
重启一下。

并且重新下载了一个 图形之类的登录工具（在装声卡的过程中的一个过程） 导致这个登录界面无法登陆root用户了。

Ubuntu 有是有 root无法登陆X的问题啊！  之前是可以的，现在鼓捣鼓捣就不行了。
ubuntu好像默认是root无法登录X的，

其实我个人认为这没有多大必要，因为当你需要 root 的权限时，使用 sudo 便可以了。如果你实在需要在 Ubuntu 中启用 root 帐号的话，那么不妨执行下面的操作：

sudo passwd root

ubuntu默认情况下是不允许用root用户直接登录桌面系统的，这也是出于安全方面的考虑

ubuntu默认情况下是不允许用root用户直接登录桌面系统的，这也是出于安全方面的考虑，因为在非root用户的模式下每个特权操作都要输入密码，这就大大减少了危险的动作。下面是获取root登录的方法。
Gnome环境：
打开System(系统)->Administration(系统管理)->Login Window（登录窗口）点击security(安全)页，选择Allow root login(允许本地系统管理员登陆)。
可能因为版本更新，allow后的文字不一样，但意思都是一样的。   
【我这个8.1 是allow  administration 什么什么的】

你说的很对。我在刚开始用ubuntu的时候对不能登录root很恼火，因为之前在RHEL中对权限的控制欲很强。用久了之后，越发觉得这个设计非常好。


在ccdt用户下 如果想安装包，需要输入Administration 密码 ：123456


5 系统更新方法
sudo apt-get upgrade

6 系统安装完事没有smb服务的，需要另外安装。

7 在ubuntu上 测试gstreamer 的开发 20100511  64位的那个不知道怎么搞的 没有声音了，好像是声卡驱动给搞坏了。现在在32位环境下测试。


2 ubuntu 8.1 升级到9.10  升级方法：
System->Administration->Update Manager  
题外：Alt+F2 是 Run Application 

怎样看目前的ubuntu版本？
cat /etc/issue 

好像不能从8.10直接升级到9.10  只能升级到9.04   难道要从9.04 再升级到9.10？？
20100525 10:50
升级到9.04后，无法启动了，进入不了图形界面，但是SSH还能连上（有条件）
开机有4个选项2.6.28  2.6.27  选后者能连SSH  前者SSH都连不上

在2.6.27启动 虽然进入不了桌面但是能进入ctrl+alt+f1 能进入命令行
/boot/grub下面的menu.lst 开始显示的信息
糟了，升级到9.04后起不来了。
命令行升级
apt-get install update-manager-core
do-release-upgrade
在ssh中尝试，打印
This session appears to be running under ssh. It is not recommended
to perform a upgrade over ssh currently because in case of failure it
is harder to recover. 
能检测到时在ssh中运行的。

后来我在 ctrl+alt+f1字符模式下做了一次升级 do-release-upgrade 这次升级到了9.10
各种打印信息跟在图形模式下，下面的detail中显示的一摸一样。有体会到了linux本来就是字符模式的真谛。

这次倒是起来了 但是显示一个极其怪异的界面
然后我安装ATI的那个显卡驱动（字符模式），期待中...
然后启动后 要我选择一个用户。 界面出来了但是没有鼠标
图形界面无法登陆 root 


xx-dev 包是头文件和静态库

增加ppa 
sudo apt-add-repository ppa:git-core/ppa 
sudo apt-get update 
sudo apt-get install git 
如果本地已经安装过Git，可以使用升级命令： 
sudo apt-get dist-upgrade

尝试(ubuntu 11.10)：
$ sudo apt-add-repository ppa:git-core/ppa
You are about to add the following PPA to your system:
 Git stable releases
 The most current stable version of Git for Ubuntu.

For release candidates, go to https://launchpad.net/~git-core/+archive/candidate .
 More info: https://launchpad.net/~git-core/+archive/ubuntu/ppa
Press [ENTER] to continue or ctrl-c to cancel adding it

gpg: keyring `/tmp/tmpebKVye/secring.gpg' created
gpg: keyring `/tmp/tmpebKVye/pubring.gpg' created
gpg: requesting key E1DF1F24 from hkp server keyserver.ubuntu.com
gpg: /tmp/tmpebKVye/trustdb.gpg: trustdb created
gpg: key E1DF1F24: public key "Launchpad PPA for Ubuntu Git Maintainers" imported
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)
OK


---
ubuntu12.04  gnome 想删除不用的应用，在软件中心选择 "intalled" 逐个删除即可。


/usr/bin/ld: cannot find -lncurses
collect2: ld 返回 1

首先到usr/lib/目录下寻找libncurses开头的文件
1.如果没有那就是缺少库文件
解决方法：
$ sudo apt-cache search ncurses-
有这样一个结果：
libncurses5-dev - developer's libraries and docs for ncurses

安装libncurses
sudo apt-get install libncurses5-dev


/usr/lib/x86_64-linux-gnu/libncurses.so 打开是 INPUT(libncurses.so.5 -ltinfo)
/lib/x86_64-linux-gnu$ 有 libncurses.so.5



下载的 ia32-libs 是个 transitional package 这个包本身只有几k，
里面是一些控制脚本，检查系统的64位库，然后配上32位库下载之。

/lib 都是64位库
/lib32 都是32位库

我把 /lib32 目录下
libncurses.so.5 -> libncurses.so.5.9
这个链接关系删除，即删除软连接libncurses.so.5 。执行sudo ldconfig，会自动再建立这个链接。

/lib32/libncurses.so.5.9 名字改了，再执行adb提示：
adb: error while loading shared libraries: libncurses.so.5: wrong ELF class: ELFCLASS64


问题解决：
1 20140812
12.04 不知道怎么弄的，virtualbox无法启动，提示libncursesw.so.5找不到。软件中心检查，libncursesw库以及libncursesw:i386库都是安装的，但是在系统中找不到64位版的libncursesw.so.5
找到这个库，文件列表：
/lib/x86_64-linux-gnu/libncursesw.so.5   （检查，发现我的12.04根本没有这个文件，那为什么包管理器显示这个库已经安装了呢？bug？）
/lib/x86_64-linux-gnu/libncursesw.so.5.9
/usr/lib/x86_64-linux-gnu/libformw.so.5
/usr/lib/x86_64-linux-gnu/libformw.so.5.9
/usr/lib/x86_64-linux-gnu/libmenuw.so.5
/usr/lib/x86_64-linux-gnu/libmenuw.so.5.9
/usr/lib/x86_64-linux-gnu/libpanelw.so.5
/usr/lib/x86_64-linux-gnu/libpanelw.so.5.9
/usr/share/doc/libncursesw5/changelog.Debian.gz
/usr/share/doc/libncursesw5/copyright
然后执行：
dpkg -i libncursesw5_5.9-4_amd64.deb
ldconfig

然后virtualbox就起来了


系统已经通过软件中心安装了 低版本 virtualbox时候：
$ sudo dpkg -i virtualbox-4.3_4.3.14-95030~Ubuntu~precise_amd64.deb 
dpkg: considering removing virtualbox in favour of virtualbox-4.3 ...
dpkg: no, cannot proceed with removal of virtualbox (--auto-deconfigure will help):
 virtualbox-qt depends on virtualbox (= 4.1.12-dfsg-2ubuntu0.6)
  virtualbox is to be removed.
dpkg: regarding virtualbox-4.3_4.3.14-95030~Ubuntu~precise_amd64.deb containing virtualbox-4.3:
 virtualbox-4.3 conflicts with virtualbox
  virtualbox (version 4.1.12-dfsg-2ubuntu0.6) is present and installed.
dpkg: error processing virtualbox-4.3_4.3.14-95030~Ubuntu~precise_amd64.deb (--install):
 conflicting packages - not installing virtualbox-4.3
Errors were encountered while processing:
 virtualbox-4.3_4.3.14-95030~Ubuntu~precise_amd64.deb

需要先删除旧版本


ubuntu 直接pppoe拨号：sudo pppoeconf
设来设去，状态条eth的配置菜单消失了。在application菜单中能找到network connections，窗口出来了但都灰掉不能设置了
sudo service network-manager restart 设置图标出来了，也能设置但还是连接不上局域网。查看connection information：
No valid active connections found!
查看/etc/network/interfaces，发现增加了：
auto dsl-provider
iface dsl-provider inet ppp
pre-up /sbin/ifconfig eth0 up # line maintained by pppoeconf
provider dsl-provider
重启后可以正常上网了网络连接也可以打开但是无法设置无法正常配置使用

如果主機上所有的網路介面設備都列在 network/interfaces 設定的話，桌面上的 NetworkManager 小圖示就會顯示紅色錯誤圖示，提示沒有設備可以管理 (No valid active connections found!)。這是正常的。
如果我們想由 NetworkManager 管理 eth0 的設定，那就要刪掉 network/interfaces 內關於 eth0的設定內容。注意， network/interfaces 內關於 lo 的那兩行設定是必要的，請勿刪除。
重启电脑查看connection information正常（logout restart network都不行）

---------
动态库：
主版本号表明程序库版本之间的潜在不兼容性。
次要版本号表明只是修正了缺陷。

https://help.ubuntu.com/community/UpgradeNotes

删除gnome panel里的图标。10.04版本有删除菜单，11.10 以后没有，需要进入
~/.config/gnome-panel/launchers  直接删除相应文件。

ext3/4 文件系统 lost+found 目录存储删除的数据（垃圾箱）。如果是外部挂载，umount时会提示是否清除垃圾箱

在我的电脑上12.04 ：lspci显示：
00:02.0 VGA compatible controller: Intel Corporation Xeon E3-1200 v2/3rd Gen Core processor Graphics Controller (rev 09)
应该是没有正常识别显卡。电脑13年购买，12.04应该不含其驱动。 我的CPU i53470 集显HD2500
intel官网有14.04版的的显卡驱动，没有12.04的。不能轻易尝试，弄不好系统起不来了。

在软件中心搜索库的时候需要加上libxxx，比如libsdlxxx

geidt 搜索框右击选择区分大小写

系统完全死掉时，可以ctrl+alt+f3 去kill某个进程。


超微 转码器  每个节目的组播端口号必须不同，否则ipqam搜不到节目


显卡问题：已经很久忽略了显卡问题。早在2009年，在一台带有独立显卡的机器上安装federo，然后安装显卡驱动得以支持1080p和双屏。后来安装ubuntu一直是忽略此问题的，因为默认就能用，直到在i53470上运行12.04，个别地方（gedit最小化 和firefox）出现黑框和白色线条，也可能是gnome的bug。
公司的i5 2400 hd2000 也是公版驱动。


配置docbook 编译环境
apt-get install docbook-xml docbook-xsl xsltproc fop

解决打开winmail.dat 附件问题的方法： 使用 tnef

sudo apt-get install tnef
tnef winmail.dat 
你也可以先用tnef -t winmail.dat 来看看包含的文件。
windows附件用convmv转一下文件名的编码：
代码:
convmv -f gbk -t utf8 –notest *

google 地图  支持坐标输入
39.6600805,-105.353731 (Wowza Media Systems, LLC)



vlc中文字幕：
中文字幕：
设置－选项－video--subtitle/osd字体渲染里面选择中文字体。
在打开视频的时候字幕编码选择gb18030就可以了。


----
还可以这样制作启动盘？
installing the image on to a USB stick with GNU/Linux
Insert the drive (any data it contains will be erased!)
Run dmesg in a terminal: this will give you the location of the stick in square brackets, such as sdb
To write the image, run sudo dd if=gnome-3.12.iso of=/dev/DRIVE bs=8M conv=fsync, replacing DRIVE with the location (e.g., /dev/sdb but not e.g., /dev/sdb1)
Once the write operation has finished, you can reboot with the USB drive inserted (you may have to specify the boot device on startup)

右键菜单
Restore missing files...
u14.04系统软件更新几次后，restart，此菜单项消失。


Ubuntu Kylin ›
Created specifically for the needs of Chinese users, Ubuntu Kylin 14.04.1 LTS includes many unique features and five years support from Canonical.
对方的


火狐浏览器的默认编码是GB2312，怎么把它修改为utf8或者其他的


系统更新：
"Software&Update"   Notify me of new ubuntu version: For long-term support versions

u14.04
问题：1 中英文切换没有公司原u11.10 灵敏,有时候按了ctrl+space切换不过去。
2 删除自带的Browser程序（一个浏览器，地址栏在下方，很奇葩）

