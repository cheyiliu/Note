# 开发环境搭建以及编译问题

## 编译android环境：
1. u14.04编译4.2.x必需软件包：sun-jdk1.6 bison flex libxml2-utils xsltproc g++-multilib(会自动以来g++ gcc-multilib等) gperf libswitch-perl(Switch.pm, u14.04以前无须安装)。
1. bison flex类似yacc的语法解释器，用于aidl；
1. gnupg (GNU Privacy Guard:加密或签名软件，用于从google下载代码，如已下载好不用)
1. build-essential  主要是gcc g++ 以及相应库。
1. lib32z1-dev  32位版zlib开发库，用于编译32位版主机工具(gcc -m32)
1. gperf： generate a perfect hash function from a key set. (makeprop.pl调用)
1. ia32-libs(包本身很小，却依赖数百兆，u14.04没必要下载这个)
1. lib32ncurses-dev (32位new curses) 编译 ./system/core/adb时使用此库32位版(因-m32参数，1.0.31版(android4.2.2)adb以后不需要此库)。
1. libncurses-dev (u10.04可能自带，u14.04被摒弃) 编译kernel menuconfig使用
1. ubuntu是与时俱进的，14.04提供了android-tools-adb包

## jdk
1. open版：openjdk-6-jdk/openjdk-7-jdk(包59.9MB安装106 MB，自动安装依赖包openjdk-6-jre-headless)。安装位置：'/usr/lib/jvm/java-6-openjdk-amd64'
   所有可执行程序(java,javac,jar,jmap and so on)作链接如'/usr/bin/javac -> /etc/alternatives/javac -> /usr/lib/jvm/java-6-openjdk-amd64/bin/javac'(update-alternative)
openjdk-6-jdk(1.6.0_31或_32 与安装时间有关)，4.0.4不可用，提示：Your version is: java version "1.6.0_31". The correct version is: Java SE 1.6.

1. sun版需oracal官网注册下载bin文件，如jdk-6u35-linux-x64.bin(jdk1.6第35个版本)
	执行./jdk-6u35-linux-x64.bin
	生成jdk1.6.0_35 目录，拷贝到合适位置如/usr/lib/jvm(与openjdk并列)并在~/.bashrc中添加 export PATH=$PATH:/usr/lib/jdk1.6.0_35/bin

	或使用：update-alternatives: --install <link> <name> <path> <priority>

	执行：
	update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.6.0_35/jre/bin/java" 1
	update-alternatives --install "/usr/bin/javac" "java" "/usr/lib/jvm/jdk1.6.0_35/bin/javac" 1
	javadoc，jar 等视情况添加，java/javac 2个程序切换到sun，其他仍然使用open就可以编译ics。


3 gcc (and his friends)
	12.04默认4.6，需要降版本（4.5,4.6编译都会失败。小版本没关系 ubuntu10.04是4.4.3）:
	apt-get install gcc-4.4 g++-4.4 g++-4.4-multilib gcc-4.4-multilib(最终装的是4.4.7，并且随安装时间不同而变化，那怎么控制小版本呢？)

	路径/usr/bin下原有 gcc 指向gcc-4.6，安装完gcc-4.4套件后，多了gcc-4.4，但是gcc链接仍指向gcc-4.6。可执行：

	update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.4 100 (优先级高于4.6)
	update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.6 50(12.04默认没有安装g++-4.6)
	update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.4 100
	update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.6 50

	//12.04 实测4.0.4  不注册cpp也可
	update-alternatives --install /usr/bin/cpp cpp-bin /usr/bin/cpp-4.4 100

	删除	
	update-alternatives --remove gcc /usr/bin/gcc-4.5

	install gcc-4.4安装3个新包： cpp-4.4 gcc-4.4 gcc-4.4-base
	install gcc-4.4-multilib 安装8个新包：gcc-4.4-multilib gcc-4.6-multilib(闹那样) gcc-multilib lib32gcc1 lib32gomp1 lib32quadmath0 libc6-dev-i386 libc6-i386

	android4.0 中要clang llvm 干什么用啊！ 难道不用gcc编译而是用clang了？
	主机工具都用-m32参数编译32位版本，需要相应的32位库


实测发现编译m3平台4.0.4基本成功，仅在做ota zip包时出现boot_img变量的一个错误。在a20平台4.2.2中成功。

u14.04 gcc4.8.x 编译4.2.2成功

4 提示找不到某某库的原因
	1 确实没有安装
	2 有-m32选项需要32位版但系统只有64位版(readelf -h可查看)


## Build系统
  1) . envsetup.sh help会出现命令提示
	- croot:   Changes directory to the top of the tree.
	- m:       Makes from the top of the tree.
	- mm:      Builds all of the modules in the current directory.【当前目录】
	- mmm:     Builds all of the modules in the supplied directories.【指定目录参数】
	- cgrep:   Greps on all local C/C++ files.【grep检索目标行命令】
	- jgrep:   Greps on all local Java files.
	- resgrep: Greps on all local res/*.xml files.
	- godir:   Go to the directory containing a file.
	tapas是envsetup产生的shell环境函数,执行完evnsetup之后就在当前shell下有了.
  2) showcommands显示命令详情
  3) 顶层目录有Makefile文件,其他的每个component都使用统一标准的 Android.mk
  4) $(info xxx） 输出信息
  5) 改变编译器之方法。android提供2套编译器，在linux-arm.mk文件中
	# You can set TARGET_TOOLS_PREFIX to get gcc from somewhere else
	ifeq ($(strip $($(combo_target)TOOLS_PREFIX)),)
	$(combo_target)TOOLS_PREFIX := \
		prebuilt/$(HOST_PREBUILT_TAG)/toolchain/arm-eabi-4.4.0/bin/arm-eabi-
	endif

  6) froyo的build/core/combo/arch/arm有:
	armv7-a.mk	(for ARMv7-a and higher)
	armv7a-neon.mk (for ARMv7-a and higher with NEON)


	
	同时在这个文件里会include armv5te.mk ,下面还会判断armv5te.mk中的宏定义
	TARGET_ARCH_VARIANT应该可以设定在你的 product.mk中	
	make TARGET_ARCH_VARIANT=armv7-a 也行！
	那么 product.mk这个文件怎么使用呢？ ？
	直接修改 TARGET_linux-arm.mk 文件是最方便的



. /build/envsetup.sh 
	
2 make命令
	1) make update-api




lsusb 查PID VID
编辑/etc/udev/rules.d/51-android.rules(udev配置文件)添加：
SUBSYSTEM=="usb", ATTR{idVendor}=="17ef", ATTR{idProduct}=="7435", MODE="0600" OWNER="gaojie"
或MODE="0666"
重新加载udev规则：
$ sudo udevadm control --reload



怀疑是python版本问题，公司11.10上的版本是2.7.2+（官网找不到这个版本），12.04 是2.7.3。从官网下载2.7.2编译安装。出现新问题：
AttributeError: 'NoneType' object has no attribute 'decompressobj'
再下载2.7.3编译安装，还是有这个问题，并且m3 a20 都不行了。想再恢复到之前的2.7.3 已经不行。执行apt-get install python 提示已经最新。这时犯了一个巨大错误：
我想先把python2.7 卸载，再安装，结果apt-get remove python 提示要删除400M+空间，仔细看，他把所有与python相关的都卸载了，执行一会感觉不对，停止。但为时已晚，系统已经严重不正常，包括vim gedit  拼音输入法等 都不正常了。
这两天在ubuntu12.04上编译HI3716c android包，发现的如下错误。（可我在公司为啥没有这个错误呢？）

错误打印如下：

host C++: obbtool <= frameworks/base/tools/obbtool/Main.cpp
<command-line>:0:0: error: "_FORTIFY_SOURCE" redefined [-Werror]
<built-in>:0:0: note: this is the location of the previous definition
cc1plus: all warnings being treated as errors

注意gcc4.4.3  安装的时候是gcc-4.4
不能指定小版本号

4）host C: acp <= build/tools/acp/acp.c
<command-line>:0:0: warning: "_FORTIFY_SOURCE" redefined [enabled by default]
<built-in>:0:0: note: this is the location of the previous definition
In file included from /usr/include/stdlib.h:25:0,
                 from build/tools/acp/acp.c:11:
/usr/include/features.h:324:26: fatal error: bits/predefs.h: No such file or directory
compilation terminated.

“bits/predefs.h: No such file or directory”  需要安装: g++-multilib


6）空out目录，直接 make systemimage 
make: *** No rule to make target `device/amlogic/f16ref/initlogo-robot-1920x1080.rle', needed by `out/target/product/f16ref/root/initlogo.1080p.rle'.  Stop.




 
7）No private recovery resources for TARGET_DEVICE f16ref
host C++: llvm-rs-cc <= frameworks/compile/slang/llvm-rs-cc.cpp
<command-line>:0:0: error: "_FORTIFY_SOURCE" redefined [-Werror]




-------------------
需要安装的全部包：
sudo apt-get install       zip  zlib1g-dev libc6-dev   x11proto-core-dev libx11-dev lib32readline-gplv2-dev lib32z1-dev   libgl1-mesa-dev gcc-multilib g++-multilib mingw32 tofrodos    libxml2-utils  xsltproc


sudo apt-get install
  zip  libc6-dev  x11proto-core-dev \
  libx11-dev:i386 libreadline6-dev:i386 libgl1-mesa-glx:i386 \
  libgl1-mesa-dev  mingw32 tofrodos \
  libxml2-utils xsltproc zlib1g-dev:i386 lib32z1-dev

$ sudo apt-get install 
zip  zlib1g-dev libc6-dev 
x11proto-core-dev libx11-dev lib32readline5-dev lib32z-dev \
libgl1-mesa-dev  mingw32 tofrodos


接着安装
uestc@uestc-ThinkPad-T43:~/tools$ sudo apt-get install u-boot-tools texinfo texlive ccache gawk gettext uuid-dev

u-boot_tools ???

lib32readline5-dev

 The GNU readline library aids in the consistency of user interface across discrete programs that need to provide a command line interface.

The GNU history library provides a consistent user interface for recalling lines of previously typed input. 


------------------
开机logo：
RLE全称（run-length encoding），翻译为游程编码
rle文件

利用Linux的convert命令将11.jpg转化为11.raw：
convert -depth 8 11.jpg rgb:11.raw

将11.raw文件转换为initlogo.rle。在raw图片文件所在目录下执行：/out/host/linux-x86/bin/rgb2565 -rle <11.raw> initlogo.rle

在device/.../f16ref.mk中：
PRODUCT_COPY_FILES += \
       $(LOCAL_PATH)/init.factorytest.rc:init.factorytest.rc \
       $(LOCAL_PATH)/initlogo-robot-1280x720.rle:root/initlogo.720p.rle \

意思是把 initlogo-robot-1280x720.rle 拷贝到 root/initlogo.720p.rle 中
phostshop 可以打开，但是gimp打不开。 ubuntu上可以用 golly程序打开（软件中心下载），不行，打不开。


make systemimage 和 make -j4  有什么区别呢？

在makefile里面用 shell 命令的方法：
LIBPLAYER_BUILD_TIME=" $(shell date)"



3 
LOCAL_MODULE_TAGS := optional  这个到底要怎么控制编译？
LOCAL_PROGUARD_ENABLED := disabled


make: *** No rule to make target `out/target/common/obj/JAVA_LIBRARIES/com.android.phone.common_intermediates/javalib.jar',
 needed by `out/target/common/obj/APPS/Contacts_intermediates/classes-full-debug.jar'. Stop.


system.img 是一个包含了文件系统的映像。类型是yaffs。android提供工具：yaffs和unyaffs，可以将文件夹变成
映像，或者将映像还原为文件夹。

system.img 没有经过任何的压缩，只是把文件夹转换为yaffs映像。



2 关于EABI
  In computer software, an application binary interface (ABI) describes the low-level
  interface between an application program and the operating system or another application.
  GNU EABI is a new application binary interface (ABI) for Linux.
  EABI规定：
  1)应用程序如何发出系统调用来trap到内核态.
  2)如何使用机器的寄存器,RISC处理器的ABI就要规定用那个通用寄存器来作stack pointer和frame pointer.
  3)规定如何进行procedure call.
  EABI is the new "Embedded" ABI by ARM ltd
  The effective changes for users are:
    * Floating point performance, with or without an FPU is very much faster, 
      and mixing soft and hardfloat code is possible
    * Structure packing is not as painful as it used to be (曾经是)
    * More compatibility with various tools (in future - currently linux-elf is well supported)
    * A more efficient syscall convention
    * At present (with gcc-4.1.1) it works with ARMv4t, ARMv5t processors and above, 
      but supporting ARMv4 (e.g., StrongARM) requires toolchain modifications.

3 Android性能测试软件 nbench、benchmark、smartphone bench
  benchmark 有详细的报告，不过我认为图形测试的数据不准确，和分辨率相关，CPU和memory值得参考


4 Python（[KK] , [DJ] ），是一种面向对象、直译式计算机程序设计语言，也是一种功能强大而完善的通用型语言，已经具有十多年的发展历史，成熟且稳定
其中cURL是一个利用URL语法在命令行下工作的文件传输工具

如果想拿某个branch而不是主线上的代码，我们需要用-b参数制定branch名字，比如：
repo init -u git://android.git.kernel.org/platform/manifest.git -b cupcake

另一种情况是，我们只需要某一个project的代码，比如kernel/common，就不需要repo了，直接用Git即可。
git clone git://android.git.kernel.org/kernel/common.git



----------------------------------------------------------
已经不是froyo编译了 注意整理 要整理

1 . build/envsetup.sh 
  including device/htc/dream/vendorsetup.sh
  including device/htc/passion/vendorsetup.sh
  including device/htc/sapphire/vendorsetup.sh

# Execute the contents of any vendorsetup.sh files we can find.
for f in `/bin/ls vendor/*/vendorsetup.sh vendor/*/build/vendorsetup.sh device/*/*/vendorsetup.sh 2> /dev/null`
do
    echo "including $f"
    . $f
done



2 不要执行tapas 否则编译不过去
prune        1. 修剪(树木等)2. 精简某事物; 除去某事物多余的部分 [英] [pru:n] 

define first-makefiles-under
$(shell build/tools/findleaves.py --prune=out --prune=.repo --prune=.git \
        --mindepth=2 $(1) Android.mk)
endef

LOCAL_PATH := $(my-dir)

###########################################################
## Retrieve the directory of the current makefile
###########################################################

# Figure out where we are.
define my-dir


/**
 * Every hardware module must have a data structure named HAL_MODULE_INFO_SYM
 * and the fields of this data structure must begin with hw_module_t
 * followed by module specific information.
 */
有的模块就只有 hw_module_t  后面没有跟任何其他的 specific information

/**
 * Every device data structure must begin with hw_device_t
 * followed by module specific public methods and attributes.
 */

typedef struct hw_module_methods_t {
    /** Open a specific device */
    int (*open)(const struct hw_module_t* module, const char* id,
            struct hw_device_t** device);

} hw_module_methods_t;

方法就只有一个 open？？！！


其符號名稱須取名為 HAL_MODULE_INFO_SYM，不可更改。任何的 Stub 主類別名稱都須命名為 HAL_MODULE_INFO_SYM。

Android 中实现调用HAL 是通过 hw_get_module 实现的

int hw_get_module(const char *id, const struct hw_module_t **module) 
{
    int status;
    int i;
    const struct hw_module_t *hmi = NULL;
    char prop[PATH_MAX];
    char path[PATH_MAX];

    /*
     * Here we rely on the fact that calling dlopen multiple times on
     * the same .so will simply increment a refcount (and not load
     * a new copy of the library).
     * We also assume that dlopen() is thread-safe.
     */

    /* Loop through the configuration variants looking for a module */
    for (i=0 ; i<HAL_VARIANT_KEYS_COUNT+1 ; i++) {
        if (i < HAL_VARIANT_KEYS_COUNT) {
            if (property_get(variant_keys[i], prop, NULL) == 0) {
                continue;
            }
            snprintf(path, sizeof(path), "%s/%s.%s.so",
                    HAL_LIBRARY_PATH, id, prop);
        } else {
            snprintf(path, sizeof(path), "%s/%s.default.so",
                    HAL_LIBRARY_PATH, id);
        }
        if (access(path, R_OK)) {
            continue;
        }
        /* we found a library matching this id/variant */
        break;
    }

    status = -ENOENT;
    if (i < HAL_VARIANT_KEYS_COUNT+1) {
        /* load the module, if this fails, we're doomed, and we should not try
         * to load a different variant. */
        status = load(id, path, module);
    }

    return status;
}


/**
 * Load the file defined by the variant and if successful
 * return the dlopen handle and the hmi.
 * @return 0 = success, !0 = failure.
 */
static int load(const char *id,
        const char *path,
        const struct hw_module_t **pHmi)
{
    int status;
    void *handle;
    struct hw_module_t *hmi;

    /*
     * load the symbols resolving undefined symbols before
     * dlopen returns. Since RTLD_GLOBAL is not or'd in with
     * RTLD_NOW the external symbols will not be global
     */
    handle = dlopen(path, RTLD_NOW);  //打开动态库  
    if (handle == NULL) {
        char const *err_str = dlerror();
        LOGE("load: module=%s\n%s", path, err_str?err_str:"unknown");
        status = -EINVAL;
        goto done;
    }

    /* Get the address of the struct hal_module_info. */
    const char *sym = HAL_MODULE_INFO_SYM_AS_STR;  //被定义成“HMI”
    hmi = (struct hw_module_t *)dlsym(handle, sym); //查找HMI这个导出符号并获取其地址
    if (hmi == NULL) {
        LOGE("load: couldn't find symbol %s", sym);
        status = -EINVAL;
        goto done;
    }

    /* Check that the id matches */
//找到了 hw_module_t 结构
    if (strcmp(id, hmi->id) != 0) {
        LOGE("load: id=%s != hmi->id=%s", id, hmi->id);
        status = -EINVAL;
        goto done;
    }

    hmi->dso = handle;

    /* success */
    status = 0;

    done:
    if (status != 0) {
        hmi = NULL;
        if (handle != NULL) {
            dlclose(handle);
            handle = NULL;
        }
    } else {
        LOGV("loaded HAL id=%s path=%s hmi=%p handle=%p",
                id, path, *pHmi, handle);
    }

//凯旋而归
    *pHmi = hmi;

    return status;
}

调用模块的奥秘就在load中

为什么用HMI 字符串就能查到 hw_module_t结构体呢？
readelf xx.so -s

HAL模块的入口就是 HAL_MODULE_INFO_SYM变量


static inline int framebuffer_open(const struct hw_module_t* module, 
        struct framebuffer_device_t** device) {
    return module->methods->open(module, 
            GRALLOC_HARDWARE_FB0, (struct hw_device_t**)device);
}


gralloc 是一个模块 Stub 

operation 的 open 函数是 gralloc_device_open


FramebufferNativeWindow 

Reference counting可以节省程序的运行成本，大量的构造、析构、分配、释放和拷贝的代价被省略。 


高通MSM在做硬件blit操作时传入的结构体buffer_handle_t handle

这个buffer_handle_t可以向前追溯至 native_handle_t。

typedef const native_handle* buffer_handle_t;

typedef native_handle_t native_handle;

typedef struct
{
    int version;        /* sizeof(native_handle_t) */
    int numFds;         /* number of file-descriptors at &data[0] */
    int numInts;        /* number of ints at &data[numFds] */
    int data[0];        /* numFds + numInts ints */
} native_handle_t;

更重要的一个结构体是继承native_handle_t的 private_handle_t，系统常将buffer_handle_t和private_handle_t进行转换。

2）判断是申请FB还是申请显存空间


ASHMEM 和 PMEM ？？！！！


static int mapFrameBuffer(struct private_module_t* module)
{
    pthread_mutex_lock(&module->lock);
    int err = mapFrameBufferLocked(module);
    pthread_mutex_unlock(&module->lock);
    return err;
}


fb = open ("/dev/fb0", O_RDWR);
fb_mem = mmap (NULL, 1024*768, PROT_READ|PROT_WRITE,MAP_SHARED,fb,0);
memset (fb_mem, 0, 1024*768); //这个命令应该只有在root可以执行


include/linux/fb.h中的一些重要的数据结构

#define request_mem_region(start,n,name) __request_region(&iomem_resource, (start), (n), (name))


/**
 * kzalloc - allocate memory. The memory is set to zero.
 * @size: how many bytes of memory are required.
 * @flags: the type of memory to allocate (see kmalloc).
 */
static inline void *kzalloc(size_t size, gfp_t flags)
{
	return kmalloc(size, flags | __GFP_ZERO);
}


./src/sd/platform/lnxKAL/comps/lnxKKAL/src/linkkal_mem.c


-----------
Android 4.0用Android浏览器而不是Chrome。Google称Chrome将是 Android以后的浏览器，
但4.0还不是时候

Android 4.0 合并了智能手机和平板电脑两个版本，因此智能手机直接从 2.3 版本跳到 4.0 ，
因此也就包含了 3.x 中浏览器的特性：
    SVG
    运动传感器 API (加速度计和陀螺仪)
    CSS3 的三维转换效果
    XHR2&CORS
    File API
    HTML 媒体捕获 API，用于摄像头和麦克风
    二进制数组 (Int16Array, Float32Array, etc.)

Android 4.0 依然缺失的特性:Android 还是缺失了在Chrome和iOS5上已有的特性，包括：

    No Server-sent events (BTW, does anybody use it?)
    No WebSockets
    No WebWorkers
    No IndexedDB
    No Web Notifications (that is a real shame for this platform – Firefox on Android is doing it-)
    No WebGL
    No History Management API
    No rich input controls!

性能

Android 浏览器问题多多，特别是在性能方面。而 Google 在其官方文档中强调 4.0 的浏览器
使用更新的 V8 JavaScript 引擎，因此速度快多了，新引擎将有 35-550%的性能提升。

4.0没有内置Adobe Flash Player，Android Market中也没提供4.0版本的Adobe Flash Player
下载，谷歌表示Android 4.0将暂不支持Flash。只有等待Adobe为Andr​​oid 4.0推出Flash Player。
Galaxy NEXUS用户无法加旧版本或者新版本Flash Player到Andr​​oid 4.0当中，除非Adobe推出
和Andr​​oid 4.0兼容的最新版本Flash Player。 
----------------------------
模拟器 Ctrl+F11 可以切换横平。


要尽最大努力不修改framework里面的代码，而是按照android的规则在外部修改。先以遥控器处理为例。

TF101 平板升级到4.1.1 可以在settting 开发者选项 中打开adb调试，可以 adb shell
不过这时候进入的是 shell 用户，权限很低。

打开 “终端模拟器” 程序 ps 发现
user：

shell     4666  1     4480   208   ffffffff 00000000 R /sbin/adbd           父进程 init
shell     4672  4666  852    476   c004938c 40012500 S /system/bin/sh       父进程 adbd

u0_a37    4789  106   479568 30260 ffffffff 00000000 S jackpal.androidterm  父进程 zygoze
u0_a37    4803  4789  848    460   ffffffff 00000000 S /system/bin/sh       父进程 jackpal.androidterm

这个系统是被root过的，有/system/xbin/su程序，执行了这个 su 后切换到了root权限，再 ps 多出来

root      4818  4803  848    464   ffffffff 00000000 S sh                   父进程/system/bin/sh
以后就用这个进程执行， 执行sleep 200  ps发现：
root      4905  4818  1044   364   ffffffff 00000000 S sleep                父进程 4818 可以证明  

开发terminal程序多个窗口：

u0_a37    4953  4789  848    460   ffffffff 00000000 S /system/bin/sh       父进程都是 jackpal.androidterm
u0_a37    4962  4789  848    460   ffffffff 00000000 S /system/bin/sh


这个应用在左下角任务管理器中滑动删除，ps发现还有（一般应用在这里删除，ps 就没了）


terminal 为什么常规方法不能kill掉？ 需要在任务信息里面 “强行停止”


Novo 7 开机后，跟360一样，显示了一个开机使用时间，怎么做的呢？


u11.10编译ics
<command-line>:0:0: warning: "_FORTIFY_SOURCE" redefined [enabled by default]
原因:gcc-4.6 g++-4.6不行


实践证明还需要修改 cpp（预处理器）

android提供了预制程序升级机制。可以在system/app 和 data/app 2个地方同时存在2分apk，运行后者，删除程序，提示apk会 恢复到初始版本。
/data/data/com.android.providers.settings/database 存储的是电商ip地址信息。电商存储信息用的是 setting的provider


android的编译器可以编译内核，编译busybox时提示一个路径错误

修改：os/oslinux/...../busybox-1.4.0/script/gcc-version.sh

编译android的时候  LOCAL_ARM_MODE 是没有定义的 所以
arm_objects_mode = arm
normal_objects_mode = thumb

MAKECMDGOALS

This is a gziped cpio archive

File System support
     • Ubi filesystem


USB adb debug  ????


cat cpu  时候 显示htc手机 Hardware: bravo
我的平台 hardware : NXP BL-STB platform
./arch/arm/mach-apollo/apollo.c:MACHINE_START(APOLLO, "NXP BL-STB platform")

3 关于如何更改 android的编译器
./tools/adbs:  prefix = "./prebuilt/" + uname + "/toolchain/arm-eabi-4.4.0/bin/"
./tools/adbs:               "/toolchain/arm-eabi-4.4.0/bin/"
./envsetup.sh:    export ANDROID_EABI_TOOLCHAIN=$prebuiltdir/toolchain/arm-eabi-4.4.0/bin
./core/envsetup.mk:	ABP:=$(ABP):$(PWD)/prebuilt/$(HOST_PREBUILT_TAG)/toolchain/arm-eabi-4.4.0/bin
./core/combo/linux-arm.mk:	prebuilt/$(HOST_PREBUILT_TAG)/toolchain/arm-eabi-4.4.0/bin/arm-eabi-
[注]20140630 4.0.4以后，只有./envsetup.sh出现一次arm-eabi-，其他地方都优化掉了。

关于shell的进一步理解
Apollo的bin文件 开始 #!/bin/bash
而 codesourcery 网站的编译器下载下来后看到#!/bin/sh
而我看到 在bin下面已经有一个 sh-》dash的链接
注意一个是bash  一个是 dash

执行 sudo dpkg-reconfigure -plow dash 选择no 
然后再看bin下面 sh 就链接到 bash了

然后就可以安装codesourcery的编译器了

3.1.6. Thread Local Storage

“No.  TLS is only in ARMv6K (MPCORE) and ARMv7 (Cortex).”

注意这个网址！！
http://android.git.kernel.org/?p=platform/hardware/ti/omap3.git;a=summary

-mcpu=cortex-a9

kernel :Makefile:# conficting options:	-mcpu=cortex-a9


# Add the Thumb2 build capabilities for ARM targets
ifdef CONFIG_THUMB2_COMPILATION
KBUILD_CFLAGS += -D__thumb2__ -mthumb
# conficting options:   -mcpu=cortex-a9  这里被注释了  并且这个宏也没有放开  
//在menuconfig中配置
endif




1 LOCAL_SRC_FILES := bar.c.arm 告诉系统总是将bar.c 以arm的模式编译
2 LOCAL_ARM_MODE = arm 也可以设置模式


对于浮点运行会预设硬浮点运算FPA(Float Point Architecture)，而没有FPA的CPU会用FPE
(Float Point Emulation 软浮点)，速度上就会遇到限制，使用EABI(Embedded Application
 Binary Interface)可以对此改善，ARM EABI有许多革新之处，其中最突出的改进就是Float 
Point Performance，它使用Vector Float Point(矢量浮点)，
因此可以提高涉及到浮点运算的程序

+++++++++++++++++++++++++++
oabi eabi 都是针对arm的cpu来说的
eabi 有时候也叫做gnu eabi
eabi的好处： 1 支持软件浮点合硬件浮点 实现浮点功能的混用
	     2 系统调用的效率更高 ？？
             3 软件浮点的情况下，EABI的软件浮点的效率要比oabi高很多
eabi 和 oabi 的区别
	 1 调用规则 包括参数传递以及如何获得返回值
         2 应用程序如何去做系统调用
         3 结构体中的填充和对其 （ padding packing ）


2  Android并没有采用glibc作为C库，而是采用了Google自己开发的Bionic Libc
它的官方Toolchain也是基于Bionic Libc而并非glibc的 这使得使用或移植其他Toolchain来用于Android要比较麻烦
在Google公布用于Android的官方Toolchain之前，多数的Android爱好者使用的Toolchain是在http://www.codesourcery.com/gnu_toolchains/arm/download.html  
下载的一个通用的Toolchain  它用来编译和移植Android 的Linux内核是可行的，因为内核并不需要C库， 但是开发Android的应用程序时，直接采用或者移植其他的Toolchain都比较麻烦，其他Toolchain编译的应用程序只能采用静态编译的方式才能运行于Android模拟器中，这显然是实际开发中所不能接受的方式。目前尚没有看到说明成功移植其他交叉编译器来编译 Android应用程序的资料。 

3  android 的启动过程
Android 启动过程详解

Android从Linux系统启动有4个步骤；

(1) init进程启动
(2) Native服务启动
(3) System Server，Android服务启动
(4) Home启动

总体启动框架图如：

第一步：initial进程(system\core\init)

  init进程，它是一个由内核启动的用户级进程。内核自行启动（已经被载入内存，开始运行，并已初始化所有的设备驱动程序和数据结构等）之后，就通过启动一个用户级程序init的方式，完成引导进程。init始终是第一个进程.

Init.rc
Init.marvell.rc
Init进程一起来就根据init.rc和init.xxx.rc脚本文件建立了几个基本的服务：
 servicemanamger
 zygote
 。。。

最后Init并不退出，而是担当起property service的功能。

1.1脚本文件
init@System/Core/Init

Init.c： parse_config_file(Init.rc)
    @parse_config_file(Init.marvel.rc)
解析脚本文件：Init.rc和Init.xxxx.rc(硬件平台相关)

Init.rc是Android自己规定的初始化脚本(Android Init Language, System/Core/Init/readme.txt)

该脚本包含四个类型的声明：

Actions
Commands
Services
Options.
1.2 服务启动机制

我们来看看Init是这样解析.rc文件开启服务的。

（1）打开.rc文件，解析文件内容@ system\core\init\init.c
将service信息放置到service_list中。@ system\core\init parser.c
（2）restart_service()@ system\core\init\init.c
 service_start
 execve(…).建立service进程。

第二步 Zygote
 Servicemanager和zygote进程就奠定了Android的基础。Zygote这个进程起来才会建立起真正的Android运行空间，初始化建立的Service都是Navtive service.在.rc脚本文件中zygote的描述：
service zygote /system/bin/app_process -Xzygote /system/bin --zygote --start-system-server
所以Zygote从main(…)@frameworks\base\cmds\app_main.cpp开始。

(1) main(…)@frameworks\base\cmds\app_main.cpp
建立Java Runtime
runtime.start("com.android.internal.os.ZygoteInit", startSystemServer);
(2) runtime.start@AndroidRuntime.cpp

建立虚拟机
运行：com.android.internal.os.ZygoteInit：main函数。
（3）main()@com.android.internal.os.ZygoteInit//正真的Zygote。

registerZygoteSocket();//登记Listen端口
startSystemServer();
进入 Zygote服务框架。
经过这几个步骤，Zygote就建立好了，利用Socket通讯，接收ActivityManangerService 的请求，Fork应用程序。

第三步 System Server

startSystemServer@com.android.internal.os.ZygoteInit在 Zygote上fork了一个进程: com.android.server.SystemServer.于是SystemServer@(SystemServer.java）就建立了。Android的所有服务循环框架都是建立SystemServer@(SystemServer.java）上。在SystemServer.java中看不到循环结构，只是可以看到建立了init2的实现函数，建立了一大堆服务，并AddService到 service Manager。

main() @ com/android/server/SystemServer
{
 init1();
}

Init1()是在Native空间实现的（com_andoird_server_systemServer.cpp）。我们一看这个函数就知道了，init1->system_init() @System_init.cpp
在system_init()我们看到了循环闭合管理框架。
{
 Call "com/android/server/SystemServer", "init2"

 ProcessState::self()->startThreadPool();
     IPCThreadState::self()->joinThreadPool();
}
init2()@SystemServer.java中建立了Android中所有要用到的服务。
这个init2（）建立了一个线程，来New Service和AddService来建立服务

第三步 Home启动
在ServerThread@SystemServer.java后半段，我们可以看到系统在启动完所有的Android服务后，做了这样一些动作：

（1） 使用xxx.systemReady()通知各个服务，系统已经就绪。
 (2)  特别对于ActivityManagerService.systemReady(回调)
  Widget.wallpaper,imm(输入法)等ready通知。
Home就是在ActivityManagerService.systemReady()通知的过程中建立的。下面是 ActivityManagerService.systemReady()的伪代码：
systemReady()@ActivityManagerService.java
 resumeTopActivityLocked()
  startHomeActivityLocked();//如果是第一个则启动HomeActivity。
   startActivityLocked（。。。）CATEGORY_HOME



4 Android的编译系统

QEMU是一套由Fabrice Bellard]所编写的模拟处理器的自由软件

Qemu是一个开源的Linux虚拟机,主要用于模拟轻量级的应用，如Android手机模拟器.另外还以自由软体QEMU为基础提供了Android平台专属的Emulator
Android中提供了一个模拟器来模拟ARM核的移动设备。Android的模拟器是基于QEMU开发的，QEMU是一个有名的开源虚拟机项目
SDK的模拟器是支持Android的开源QEMu

要知道，IDE和makefile代表了两种不同的思想：IDE根据强调的是简化计算机与用户的交互；而makefile体现的是自动化。
这个先引用一下百度百科对makefile的一些描述：

一个工程中的源文件不计数，其按类型、功能、模块分别放在若干个目录中，makefile定义了一系列的规则来指定，哪些文件需要先编译，哪些文件需要后编译，哪些文件需要重新编译，甚至于进行更复杂的功能操作，因为 makefile就像一个Shell脚本一样，其中也可以执行操作系统的命令。 </div>
makefile带来的好处就是——“自动化编译”，一旦写好，只需要一个make命令，整个工程完全自动编译，极大的提高了软件开发的效率。make是一个命令工具，是一个解释makefile中指令的命令工具，一般来说，大多数的IDE都有这个命令，比如：Delphi的make，Visual C++的nmake，Linux下GNU的make。可见，makefile都成为了一种在工程方面的编译方法。 </div>
Make工具最主要也是最基本的功能就是通过makefile文件来描述源程序之间的相互关系并自动维护编译工作。而makefile 文件需要按照某种语法进行编写，文件中需要说明如何编译各个源文件并连接生成可执行文件，并要求定义源文件之间的依赖关系。makefile 文件是许多编译器--包括 Windows NT 下的编译器--维护编译信息的常用方法，只是在集成开发环境中，用户通过友好的界面修改 makefile 文件而已。

About
From QEMU
(Redirected from Index.html)


QEMU is a generic and open source machine emulator and virtualizer.

When used as a machine emulator, QEMU can run OSes and programs made for one machine (e.g. an ARM board) on a different machine (e.g. your own PC). By using dynamic translation, it achieves very good performance.

When used as a virtualizer, QEMU achieves near native performances by executing the guest code directly on the host CPU. QEMU supports virtualization when executing under the Xen hypervisor or using the KVM kernel module in Linux. When using KVM, QEMU can virtualize x86, server and embedded PowerPC, and S390 guests. 

“使用QEMU仿真ARM Linux系统”

5 Android的 make系统

我把android的目录中的toolchain 名字改掉  结果：
prebuilt/linux-x86/toolchain/arm-eabi-4.4.0/bin/arm-eabi-gcc -mthumb-interwork -o out/target/product/generic/obj/lib/crtbegin_dynamic.o -c bionic/libc/arch-arm/bionic/crtbegin_dynamic.S 
然后有
./core/envsetup.mk:	ABP:=$(ABP):$(PWD)/prebuilt/$(HOST_PREBUILT_TAG)/toolchain/arm-eabi-4.4.0/bin


build目录下有一个 envsetup.sh 

在根目录 make  打印出来的
$(info ============================================)
$(info   PLATFORM_VERSION_CODENAME=$(PLATFORM_VERSION_CODENAME))
$(info   PLATFORM_VERSION=$(PLATFORM_VERSION))
$(info   TARGET_PRODUCT=$(TARGET_PRODUCT))
$(info   TARGET_BUILD_VARIANT=$(TARGET_BUILD_VARIANT))
$(info   TARGET_SIMULATOR=$(TARGET_SIMULATOR))
$(info   TARGET_BUILD_TYPE=$(TARGET_BUILD_TYPE))
$(info   TARGET_ARCH=$(TARGET_ARCH))
$(info   HOST_ARCH=$(HOST_ARCH))
$(info   HOST_OS=$(HOST_OS))
$(info   HOST_BUILD_TYPE=$(HOST_BUILD_TYPE))
$(info   BUILD_ID=$(BUILD_ID))
$(info ============================================)
在build/core/envsetup.mk 中定义的

# ---------------------------------------------------------------
# The product defaults to generic on hardware and sim on sim
# NOTE: This will be overridden in product_config.mk if make
# was invoked with a PRODUCT-xxx-yyy goal.
ifeq ($(TARGET_PRODUCT),)
ifeq ($(TARGET_SIMULATOR),true)
TARGET_PRODUCT := sim  可以改成 ifneq  走这里
else
$(info hahahah)   这里会打印出来 说明走这里了  
TARGET_PRODUCT := generic
endif
endif


模拟器上运行的时候 编译的是arm的指令还是x86的指令呢？【】
============================================
PLATFORM_VERSION_CODENAME=REL
PLATFORM_VERSION=2.1-update1
TARGET_PRODUCT=sim
TARGET_BUILD_VARIANT=eng
TARGET_SIMULATOR=true
TARGET_BUILD_TYPE=release
TARGET_ARCH=x86   ******
HOST_ARCH=x86     ******注意这里 sim的时候编译的是x86代码！！！！
HOST_OS=linux
HOST_BUILD_TYPE=release
BUILD_ID=ECLAIR
============================================


============================================
PLATFORM_VERSION_CODENAME=REL
PLATFORM_VERSION=2.1-update1
TARGET_PRODUCT=generic
TARGET_BUILD_VARIANT=eng
TARGET_SIMULATOR=
TARGET_BUILD_TYPE=release
TARGET_ARCH=arm
HOST_ARCH=x86
HOST_OS=linux
HOST_BUILD_TYPE=release
BUILD_ID=ECLAIR
============================================


所以 qemu 模拟器并没有去模拟 arm指令  那goldfish 有是怎么一回事呢？
在bionic/libc/Android.mk中有
ifeq ($(TARGET_ARCH),arm)
   arch-arm/xxx
else
   arch-x86/xxx


所以说：qemu模拟器只是模拟了一个x86的cpu  而不是模拟了一个arm的cpu

那为什么有 prebuild/android-arm/kernel/kernel-qemu kernel-qemu-armv7这几个文件呢？  从文件名字来看 应该是qemu可以模拟armv7

build目录下面有一个 buildspec.mk.default 文件 里面有注释：
######################################################################
# This is a do-nothing template file.  To use it, copy it to a file
# named "buildspec.mk" in the root directory, and uncomment or change
# the variables necessary for your desired configuration.  The file
# "buildspec.mk" should never be checked in to source control.
######################################################################

在 build/core/config.mk中有一段：

# ---------------------------------------------------------------
# Try to include buildspec.mk, which will try to set stuff up.
# If this file doesn't exist, the environemnt variables will
# be used, and if that doesn't work, then the default is an
# arm build
-include $(TOPDIR)buildspec.mk


把这个文件拷贝到 top目录 把simulator = true 放开

编译x86的时候 host C++  的打印 在 ./core/definitions.mk中
###########################################################
## Commands for running gcc to compile a host C++ file
###########################################################
@echo "host C++: 


关于armv7 的内容
./core/combo/arch/arm/armv7-a.mk


一、什么是Android？

Android作为Google公司推出的一款手机开发平台，其本身是基于linux内核的。Google提供的内核源代码中除了linux部分外，有很大一部分是与虚拟处理器Qemu和模拟硬件平台Goldfish相关的。所以如果想将Android移植到实际的硬件平台上需要将这部分代码剥离出来。
二、搭建开发环境
2.1在Vmware中的安装和设置Ubuntu Server 8.10

       本文选择在Win XP下的Vmware中安装Ubuntu Server 8.10作为编译开发服务器。

安装: 略。

设置：

1. 为网卡配置静态IP地址

       虚拟机和XP连接用的虚拟网卡设置IP，gateway和DNS都为192.168.0.1。

       在Vmware虚拟机中执行：

sudo vi /etc/network/interfaces 加入：

auto eth0

iface eth0 inet static

address 192.168.0.2

gateway 192.168.0.1

netmask 255.255.255.0

 

2. 配置DNS

sudo vi /etc/resolv.conf

nameserver 192.168.0.1

 


 

4. 清理系统

sudo apt-get clean

 
2.2 建立Android内核开发环境

1、工作环境及所需软件包

1）系统环境：Ubuntu 8.10 server

2）交叉编译器：GNU Toolchain for ARM Processors

(http://www.codesourcery.com/gnu_toolchains/arm/download.html)

本文用：arm-2008q3-66-arm-none-eabi-i686-pc-linux-gnu.tar.bz2

3）Android内核源代码：linux-2.6.23-android-m5-rc14.tar.gz

（http://code.google.com/p/android/downloads/list）本文用：linux-2.6.25-android-1.0_r1.tar.gz

4）Android SDK

（http://code.google.com/android/download_list.html）

SDK中带有Android Emulator仿真器等工具，本文用：android-sdk-linux_x86-1.0_r2.zip

2、搭建交叉编译环境

       安装好系统后，把下载的Android kernel，交叉编译器和Android SDK都放在/home/xxx目录，xxx是安装系统时的普通用户的用户名。

1) 安装交叉编译器

$cd ~

$mkdir tools

$cp arm-2008q3-66-arm-none-eabi-i686-pc-linux-gnu.tar.bz2  tools

$cd tools

$tar jxvf arm-2008q3-66-arm-none-eabi-i686-pc-linux-gnu.tar.bz2

 

2) 解压Android SDK

$cp ~/android-sdk-linux_x86-1.0_r2.zip ~/tools

$cd ~/tools/

$unzip android-sdk-linux_x86-1.0_r2.zip

 

3) 解压缩内核源代码

       $mkdir sources

       $cp linux-2.6.25-android-1.0_r1.tar.gz sources

       $cd sources

       $tar zxvf linux-2.6.25-android-1.0_r1.tar.gz

       $mv kernel.git  linux-2.6.25-android-1.0_r1

 

 
三、编译和运行Android Kernel

1）  获取Android官方的默认内核配置文件.config

这个.config文件可以从SDK中得到。启动android模拟器，然后用adb从模拟器中提出内核配置文件：

$~/tools/android-sdk-linux_x86-1.0_r2/tools/emulator &

$adb pull /proc/config.gz  ~/

$mv ~/  ~/sources/linux-2.6.25-android-1.0_r1

$cd ~/sources/linux-2.6.25-android-1.0_r1

$ gunzip config.gz
$ mv config .config

2）编译

$~/mk-kernel.sh sources/linux-2.6.25-android-1.0_r1/

其中mk-kernel.sh脚本如下：

#!/bin/sh

#Simple script for Android Kernel compiling.

#By Neil Chiao, Mar.14,2009

export PATH=$PATH:/home/neil/tools/arm-2008q3/bin

export CROSS_COMPILE=arm-none-eabi-

cd $1||exit 1

make menuconfig

make

3）运行该镜像

$cd ~/tools/android-sdk-linux_x86-1.0_r2/tools/

$./emulator -kernel ~/sources/linux-2.6.25-android-1.0_r1/arch/arm/boot/zImage

Android中提供了一個模擬器來模擬ARM核的移動設備。Android的模擬器是基於QEMU開發的，QEMU是一個有名的開源虛擬機項目（詳見http://bellard.org/qemu/），它可以提供一個虛擬的ARM移動設備。Android模擬器被命名為goldfish，用來模擬包括下面一些功能的ARM SoC:

Android模擬器所對應的源代碼主要在external/qemu目錄下。如果你想將Android移植到其他設備上，熟悉它目前所針對的模擬器環境可以提供一些參考。

對於應用程序的開發者，模擬器提供了很多開發和測試時的便利。無論在Windows下還是Linux下，Android模擬器都可以順利運行，並且Google提供了Eclipse插件，可將模擬器集成到Eclipse的IDE環境。當然，你也可以從命令行啟動Android模擬器。


Android 1.0移置到华硕P535 [历史存档]
Android, 华硕, 历史
LCD、键盘及触摸屏都已正常工作。

演示视频见此：
http://www.youtube.com/watch?v=0GZwguPJCmI

运行文件下载地址：
http://www.rayfile.com/files/603 ... -b77a-0014221b798a/
下载后打开readme文件查看如何运行。
1. 首先我们大家都知道Android是基于Linux之上的一个软件平台，Android移植的大部分工作其实是 Linux到P535的移植。所以，我们首先需要完成Linux的移植。

2. P535原本是Windows Mobile系统（以下简称WM），因此需要解决如何从WM引导进入Linux的问题。烧boot是不可能了，我只有一台P535，可不想把3000多大洋换成砖头。幸好有HaRET这个好工具，它运行在WM下，可以直接读取linux的zImage文件实现内核加载。所以，欲练神功，必先...
学习HaRET，主页地址： http://www.handhelds.org/moin/moin.cgi/HaRET

3. 接下来要编译一个能在P535上跑起来的linux内核文件zImage。从www.kernel.org下载下来的linux源代码编译生成的 zImage是无法直接跑起来的，因为缺了对P535硬件设备的驱动支持。最好有一套能直接支持P535设备的Linux源代码，有吗？没有。如果有的话这移植工作就太没劲了。不过，我们可以找到一个好的起点。请访问链接：
http://www.handhelds.org/moin/moin.cgi/GettingHandheldKernels
handhelds 是一个组织，他们的工作就是移植linux到各种PDA上面，包括HP、HTC、DELL等等，还有Asus，不过都是一些老的型号，不包括P535。这个组织似乎有一两年没什么动静了，他们的Familiar项目最后版本v0.84发布日期是06年8月20日。所以指望他们去更新支持P535是不可能了，我还尝试过发邮件想加入他们的队伍，结果没人理我：（ 。

看来只能自力更生了。他们虽然不更新了，但是他们的网站依然屹立。从上面的链接，我们可以下载到他们维护的最近的linux源代码版本2.6.21。这个版本就是我们的出发点。

4. 载下来的这套源代码我们称为handheld linux2.6.21，它与官方linux2.6.21的区别在于增加了对很多 PDA设备的驱动支持。虽然不包括P535，但我们可以参考其他类似设备完成对我们设备的驱动支持。我当时参考的其它设备主要有：Asus A730, Asus 696, HTC magician等。因为P535的很多硬件部件的芯片型号与这几款设备相同。

那如何知道P535使用的都是什么芯片呢？这得下点狠功夫了，拆机！而且是很彻底的那种。不狠一点怎么能体会到干底层工作的乐趣？！心肠不够狠的弟兄可以参考我拆机后拍的照片。
http://sites.google.com/site/siteofhx/Home/android/p535-hardware
我这台已经被我肢解过好几十次了，之前换触摸屏、升级内存都是大手术，能幸存下来真是顽强。

5. 知道了硬件芯片型号，可又不知道管脚连接，又不可能向Asus要电路图，怎么办？认真学习并操练过前面几个步骤的弟兄可能已经有答案了。HaRET这个工具再次出马，所以要不我怎么说欲练神功，必先....

通过HaRET这个工具，我们可以知道P535中各个部件对应的GPIO，最重要的是搞清楚键盘、LCD、触摸屏，这三个硬件驱动的成功移植是我们的首要目标，这样才能体验到Android Touch操作的快感！

6. OK，这几项准备工作完成后，您就可以开始埋头苦干了，写代码、编译、调试、拷贝、粘贴，快的话几天，慢的话几周，最后炮制出一个能在自己的机器上跑起来的zImage文件。

对了，得用这个交叉编译器：
http://www.codesourcery.com/gnu_ ... c-linux-gnu.tar.bz2

7. 光有zImage最多只能进入黑漆漆的命令行界面，无法验证键盘、液晶和触摸屏是否工作正常，解决这个问题，您可以到这里：
http://familiar.handhelds.org/re ... /files/ipaq-pxa270/
下载一个rootfs系统，准备一张空闲的SD卡，将下载的文件解到卡中，然后通过HaRET引导您炮制好的linux kernel，启来后执行rootfs中的初始化脚本，进入GPE或者OPIE的图形界面，这时您就可以验证您的键盘、LCD和触摸屏驱动是否正常工作了。

如果还不正常，那再埋头苦干吧，这关必须过了才能继续往下走。

8. 过了上一关，Linux的移植已经被你踩在了脚下，您一定有一点兴奋感和成就感了。别急，让我们继续往上爬。

Android SDK 1.0使用的linux版本是2.6.25，而我们刚刚完成移植的版本是2.6.21，要知道他们之间有什么不同吗？在此推荐一个非常棒的工具，Meld Diff Viewer，有了它，后面的工作将变得易如反掌。
从Kernel.org下载一份官方的2.6.25，同您刚完成的handheld 2.6.21比较一下，不比不知道，一比吓一跳！改动的地方是不是很多？不要怕，让我们一步一步搞定。

我们之前的移植是基于handheld的版本完成的，多少有点让我们感觉是踩在了别人的肩膀上爬上来的。没关系，至少我们学会了爬。现在让我们回到地上，自己爬上来。
从 Kernel.org再下载一份官方的2.6.21，用Meld同前面的handheld 2.6.21比较一下，将官方版本缺少的驱动合并过来，不要一股脑全部合并过来，看看您的P535缺少什么才合并什么，这样子您就非常清楚从官方下载的 linux需要增加哪些驱动才能在您的机器上跑起来。

合并完成后，编译和调试您的官方2.6.21版本，让它也能顺利的跑起来，进入GPE和OPIE图形界面。

9. 把移植成功的官方2.6.21，同前面下载的官方2.6.25进行比较，官方比官方，差别是不是没那么恐怖了？同样，将2.6.25缺少的驱动文件从 2.6.21合并过来，编译调试，让2.6.25也跑起来。

10. OK，下面我们要真正开始同Android打交道了。
先下载 Android 使用的linux版本，地址在此：http://code.google.com/p/android/downloads/list
再下载Android SDK 1.0：http://code.google.com/android/download.html
照此教程从SDK中提取Android的rootfs：http://discuz-android.blogspot.c ... id-file-system.html

现在就差Android的linux zImage了。

11. 将Android linux2.6.25同前面移植完成的官方linux2.6.25比较，找出其中的异同，将官方2.6.25缺少的东东从Android linux2.6.25合并过来，注意不要搞错方向了。其中，凡是涉及QEMU、Goldfish及yaffs2的内容没有用处，不要合并过来。您会发现其实Android对linux的改动很小。
这一步的详细操作请参考这个链接：http://elinux.org/Android_on_OMAP

然后编译，又得到一个zImage. 调试它，让它能顺利引导进入Android rootfs中的初始化脚本。

12. 引导进入Android的图形界面不像进入GPE和OPIE那么顺利，因为Android对LCD驱动有特殊的要求，需要Frame Buffer驱动支持double buffering 和 pan function。您需要参考这个帖子：http://androidzaurus.seesaa.net/article/105551643.html 或者 http://www.androidrd.com/thread-9-1-1.html 完成对2.6.25自带的Frame Buffer驱动的修改。


此外，触摸驱动发出的X坐标是对的，Y坐标是倒过来的，您需要修改驱动纠正一下姿势。参考：http://androidzaurus.seesaa.net

5 android里面的编译起 arm-eabi-gcc  和 arm-eabi-gcc-4.4.0 内容一模一样
编译好的文件在：
./out/host/linux-x86/pr/sim/obj/SHARED_LIBRARIES/libsqlite_intermediates/sqlite3.o

请先参考我的另一篇文章如何取得Android源代码，确保正确地拿到了Android kernel/common 项目的Goldfish分支（该分支用于构建运行在emulator上的系统内核，而主线则是用于构建运行在实际设备上的内核代码）

Android对Linux Kernel做了不少的改进，比如添加对yaffs2文件系统的支持，改进蓝牙的支持，改进电源管理机制，以及为模拟器版本添加的Goldfish平台等等，不过内核的编译方式和标准的kernel并没有区别。

Android代码树中有一个prebuilt项目，包含了我们编译内核所需的交叉编译工具，如果你拿了完整的Android 1.5代码树，它就会在prebuilt目录下。

3、设定环境变量
把刚才下载的prebuilt中的arm-eabi编译器加入$PATH
$export PATH=$PATH:/home/william/android-source/prebuilt/linux-x86/toolchain/arm-eabi-4.2.1/bin

设定目标arch为arm
$export ARCH=arm

4、设定交叉编译参数
打开kernel目录下的Makefile文件，把CROSS_COMPILE指向刚才下载的prebuilt中的arm-eabi编译器
CROSS_COMPILE ?= arm-eabi-

把
LDFLAGS_BUILD_ID = $(patsubst -Wl$(comma)%,%,\
$(call ld-option, -Wl$(comma)–build-id,))
这一行注释掉，并且添加一个空的LDFLAGS_BUILD_ID定义，如下:
LDFLAGS_BUILD_ID =
下面的这段解释来自陈罡的blog

把它注释掉的原因是目前android的内核还不支持这个选项。–build-id选项，主要是用于在生成的elf可执行文件中加入一个内置的id，这样在core dump，
或者debuginfo的时候就可以很快定位这个模块是哪次build的时候弄出来的。这样就可以避免，每次都把整个文件做一遍效验，然后才能得到该文件的是由哪次
build产生的。对于内核开发者来说，这是很不错的想法，可以节约定位模块版本和其影响的时间。目前，该功能还出于early stage的状态，未来的android
或许会支持，但至少目前的版本是不支持的。
对这个–build-id选项感兴趣的朋友，可以访问下面的网址，它的作者已经解释得非常明白了：
http://fedoraproject.org/wiki/Releases/FeatureBuildId

5 关于ADB
android-sdk-linux_86 目录中的 tools 下面有adb 文件
android-sdk-linux_86/tools$ ./adb shell
就可以进入shell了

进入后在 /proc下面有一个 config.gz 还真有！！！

，然后通过adb pull命令（该命令用于从设备上复制文件到本地）即可完成

emulator 需要一个 avd文件，elips可以创建avd文件   路径在
/home/gaojie/.android/avd/下面

invalid command-line parameter: /home/gaojie/.android/avd/Test.avd.
Hint: use '@foo' to launch a virtual device named 'foo'.

gaojie@gaojie:~/Nxp_prj/android-sdk-linux_86/tools$ ./emulator @Test
这个格式才是正确的，那么 他是怎么找到这个路径的啊！！！


gaojie@gaojie:~/Nxp_prj/android-sdk-linux_86/tools$ ./android list avd
Available Android Virtual Devices:
    Name: hj
    Path: /home/gaojie/.android/avd/hj.avd
  Target: Android 2.1-update1 (API level 7)
    Skin: 800x600
  Sdcard: 2000M
---------
    Name: Test
    Path: /home/gaojie/.android/avd/Test.avd
  Target: Android 2.1-update1 (API level 7)
    Skin: QVGA
  Sdcard: 2000M
gaojie@gaojie:~/Nxp_prj/android-sdk-linux_86/tools$ 


7 Android根目录的结构
init.rc init.goldfish.rc  

Android的程序文件为APK格式，APK文件是Android最终的运行程序，是Android Package的全称，类似于Symbian操作系统中sis文件，APK文件其实ZIP文件格式，但后缀名被修改为APK，通过UnZip解压后

apk文件扩展名改为.zip 
就可以解压缩（UI界面中可以 但是用gunzip不能解）
解压缩后：xx.dex xx.xml  res目录等等
resources.arsc 编译后的二进制资源文件

emulator @Test -show-kernel

请加上-show-kernel参数。

模拟器的kernel路径在 android-sdk-linux_86/platforms/android-7/images/kernel-qemu
这个文件跟 android2.1目录下的 prebuild中的同名文件一样

zImage bzImage 都是用gzip压缩的 
它们不仅是一个压缩文件，而且在这两个文件的开头部分内嵌有gzip解压缩代码
所以你不能用gunzip解压

vmlinux是未压缩的内核  

./target/src/project/project_include.mk:_SDE_PROC_DEFINES = -mcpu=cortex-a9 -mfpu=vfpv3-d16 -mfloat-abi=softfp
./target/src/project/project_include.mk:_SDE_EXTRA_CFLAGS += -DCPU=CORTEX_A9 -D__LINUX_ARM_ARCH__=7 -mcpu=cortex-a9 -mfpu=vfpv3-d16 -mfloat-abi=softfp


修改了init.c后 make

target thumb C: init <= system/core/init/init.c

combo_target

linux-arm.mk 中 有-g参数 可以改成 -ggdb



1 LOCAL_ARM_MODE  从android源码看 这个是加到每个Android.mk文件中的 那么怎么变成全局的呢？
LOCAL_ARM_MODE := arm
注意你同样可以在编译的时候告诉系统编译特定的类型，比如
LOCAL_SRC_FILES := foo.c bar.c.arm
./core/binary.mk:LOCAL_ARM_MODE := $(strip $(LOCAL_ARM_MODE))
./core/binary.mk:arm_objects_mode := $(if $(LOCAL_ARM_MODE),$(LOCAL_ARM_MODE),arm)
./core/binary.mk:normal_objects_mode := $(if $(LOCAL_ARM_MODE),$(LOCAL_ARM_MODE),thumb)
./core/clear_vars.mk:LOCAL_ARM_MODE:=

在external/zlib/Android.mk 里面
# measurements show that the ARM version of ZLib is about x1.17 faster
# than the thumb one...
LOCAL_ARM_MODE := arm

我在./core/clear_vars.mk:LOCAL_ARM_MODE:= 写上arm
结果整个项目都是 target arm c/c++ 了
当编译到opengl的时候，出错，看来这个目录的egl.c要用thumb编译
我就在这个目录中的Android.mk中加上  LOCAL_ARM_MODE:= 空
那么这个目录就用thumb编译了 target thumb c

最终编译出来的init 148k 果然变大了！  但是仍然不能运行 还是segmentation fault
readelf -A 后
  Tag_CPU_name: "7-A"
  Tag_CPU_arch: v7
  Tag_CPU_arch_profile: Application
  Tag_ARM_ISA_use: Yes
  Tag_VFP_arch: VFPv3
  Tag_Advanced_SIMD_arch: NEONv1
  Tag_ABI_PCS_wchar_t: 4
  Tag_ABI_FP_denormal: Needed
  Tag_ABI_FP_exceptions: Needed
  Tag_ABI_FP_number_model: IEEE 754
  Tag_ABI_align8_needed: Yes
  Tag_ABI_align8_preserved: Yes, except leaf SP
  Tag_ABI_enum_size: int
  Tag_ABI_HardFP_use: SP and DP

跟可以运行的busybox相比：
  Tag_CPU_name: "7-A"
  Tag_CPU_arch: v7
  Tag_CPU_arch_profile: Application
  Tag_ARM_ISA_use: Yes
  Tag_ABI_PCS_wchar_t: 4
  Tag_ABI_FP_denormal: Needed
  Tag_ABI_FP_exceptions: Needed
  Tag_ABI_FP_number_model: IEEE 754
  Tag_ABI_align8_needed: Yes
  Tag_ABI_align8_preserved: Yes, except leaf SP
  Tag_ABI_enum_size: int
多了：
  Tag_VFP_arch: VFPv3
  Tag_Advanced_SIMD_arch: NEONv1
和
 Tag_ABI_HardFP_use: SP and DP ？？？这个是什么东西呢？


Tag_ABI_HardFP_use, (=27), uleb128 
 0  The user intended that VFP use should be implied by Tag_FP_arch 
 1  The user permitted this entity to use only SP VFP instructions 
 2  The user permitted this entity to use only DP VFP instructions 
 3  The user permitted this entity to use both SP and DP VFP instructions 
    (Note: This is effectively an explicit version of the default encoded by 0)


1 eclipse 使用的是 Helios版本
Windows->Preferences->Android 选择SDK位置 下面可以看到 Android2.1 Android2.2版本 API level 分别为7，8 
Windows->Android SDK and AVD Manager 可以看到android 虚拟设备 
eclipse 可以使用自己喜欢的版本 建议3.4 以上

./adb install ApiDemos.apk 可以安装一个apk
虚拟机目录 ~/.android/avd 

搞清楚 sdk 和 ndk 的区别

下载android sdk 后，里面有SDK Readme.txt 说 “The Android SDK archive now only contains the tools”
说明只有 tools目录 没有 platforms 
use the SDK Manager to install or update SDK components such as platforms,
tools, add-ons, and documentation.

SDK Manager 是什么？ Eclipes 里面的？

To start the SDK Manager, please execute the program "tools/android".  （无法直接执行）

安装2个开发包
eclipse-java-helios-linux-gtk.tar.gz
解压缩即可使用，纯绿色！ 但是原来下载的这个好像是32bit的，在64bit系统上不工作
去http://www.eclipse.org/downloads 下载，这里有很多类型：
Eclipse IDE for Java Developers
Eclipse IDE for Java EE Developers等等  选择第一个
下载了 eclipse-java-indigo-SR1-linux-gtk-x86_64.tar.gz
helios 是3.6   indigo是3.7


android-sdk_r06-linux_86.tgz
解压缩后只有tools目录有东西：
若干elf文件 + lib目录里面是若干.jar文件
这里面没有任何android系统的文件！

然后安装 ADT-plugin
打开eclipse  Help->Install New Software...->Add
Name:android
URL:http://dl-ssl.google.com/android/eclipse/
选择Developr Tools 下面 android DDMS android Developer Tools等等 然后开始安装

使用SDK Manager安装sdk （前面的sdk只是一个外壳）
打开 Android SDK and AVD Manager 找到 Available packages
我原来下载的SDK Tools 是revision6
在Available packages可以看到有 Android SDK Tools revision 13 (20111013 安装之)
还有Documentation for android sdk api13
SDK platform安装3.2（api 13） 2.3.3（api 10） 2.2（api 8）

SDK Tools 和 SDK Platform-tools 有什么区别？
用android sdk and avd manager 下载android2.2 提示需要sdk tools v13 （之前下载的是v6） 安装v13 又需要 sdk platform-tools v7
不知为什么直接下载非常慢

奇怪： 我的Ubuntu 两台机器使用同样的IP和Mac地址，用Switch连接，竟然能够同时上网 什么道理 为什么不IP冲突，为什么上网互不干扰


sdk Tools 是各个版本都可以通用的工具比如emulator等 sdk platform-tools 是版本有区别的工具文件夹 比如adb aapt等 
sdk tools 版本v6的时候 部分platform-tools（2.3.3以后才有 这个东西）
ADT android development tools 在eclipse->help中安装的


下载android4.0后，提示ADT需要最新版本，更新到v15 发现SDK manager和 AVD manager 菜单项分开管理了
创建AVD时候提示找不到 userdata.img什么的，需要在SDK manager里面更新 ARM EABI v7a System Image


3. 将下载的压缩包放入temp文件夹下
例如：D:\ProgramFiles\android-sdk-windows\temp
 
4. 点击SDK Manaer.exe，让其自动解压缩。  (linux版本怎么办？ 实践证明，解压缩拷贝到android-sdk目录下即可)
5.配置环境变量 PATH = D:\ProgramFiles\android-sdk-windows\tools 
    SDK安装完成

在sdk r13 中 执行 ./android (一个脚本) 会打开Android SDK and AVD Manager 但是 跟从eclipse 中打开的不一样


6 Fawn源码中的参考代码在 /development/samples 这个目录就是eclipse中可以单独下载的sample.tgz包
WXGA：全称Wide Extended Graphics Array，按的16：10比例加宽了笔记本屏幕


8 关于ndk  用r6 实验
 Native Development Kit
 不用ndk开发的话，就不能开发 java +c 的代码吗？用 android源码总可以吧
对了：android 源码里面自带的那几个应用程序 都是用到jni方式的吗？  

但是，自从ndk r5发布以后（7月13日，ndk r6发布），已经允许你完全用 C/C++ 来开发应用或者游戏，而不再需要编写任何 Java 的代码。
？？  什么意思？  还可以用纯C开发 android 程序？！

ndk r6 支持x86开发 也就是在toolchains目录下有 arm-linux-4.4.3 和 x86-4.4.3

本次ndk升级中，个人认为比较有用的是ndk-stack工具。在ndk开发中，最令人头疼的是native代码崩溃，但是logcat只显示一些地址信息，无从查找代码崩溃的位置，有了ndk-stack工具，相信会给ndk开发带来很大的帮助。


ndk-stack 工具


ndk智能编译C C++ 代码 不能编译java   java还是要用 eclipse编译  

奥！在sdk 的sample里面 也就是eclipse里面下载的sample包 里面 没有任何 c  c++ 代码！

但是android源码里面自带的应用程序 是可以用 jni 开发的

------------------------------------------------------
Checking API: checkapi-current
target Symbolic: libcutils (out/target/product/bcm7231/symbols/system/lib/libcutils.so)
target Strip: libcrypto (out/target/product/bcm7231/obj/lib/libcrypto.so)
target Symbolic: libicui18n (out/target/product/bcm7231/symbols/system/lib/libicui18n.so)
target SharedLib: libssl (out/target/product/bcm7231/obj/SHARED_LIBRARIES/libssl_intermediates/LINKED/libssl.so)
out/target/common/obj/PACKAGING/public_api.txt:11979: error 4: Added public method android.net.ethernet.IEthernetManager.getEthernetMacAddr
out/target/common/obj/PACKAGING/public_api.txt:15262: error 3: Added class SystemUpdateJni to package android.os
out/target/common/obj/PACKAGING/public_api.txt:18729: error 2: Added package android.settings

******************************
You have tried to change the API from what has been previously approved.

To make these errors go away, you have two choices:
   1) You can add "@hide" javadoc comments to the methods, etc. listed in the
      errors above.

   2) You can update current.txt by executing the following command:
         make update-api

      To submit the revised current.txt to the main Android repository,
      you will need approval.
******************************

make: *** [out/target/common/obj/PACKAGING/checkapi-current-timestamp] Error 38

-----------------------------------------
./frameworks/base/api/current.txt



20130502
lunch g18ref-eng
make过程中需要arm-none-linux-gnueabi-gcc（编译内核用）
kernel在common目录，编译参数：
ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- meson6_g18_jbmr1_defconfig

2 root
买的开发平台没有root。 在sbin下预制了busybox。使用之前下载的

3 nand 使用的是ext4

4 目录管理：
  /mnt/sdcard 是flash模拟的分区，sdcard和usb分别挂载到：
  /storage/external_storage/sdcard0
  /storage/external_storage/sda0
----------------------------------


5 vendor/amlogic/prebuilt/  DLNA.apk 是 “媒体中心” 这个跟eHomeMediaCentor界面相同
但里面只有dex文件无jar包库。
RC_Client.apk  RC_Server.apk 实现手机遥控器
MiracastSink.apk 实现miracast功能

packages/amlogic/下面有些可用apk资源。

6 kernel中的 common/drivers/amlogic/display 是fb驱动

frameworks/base/cmds/screenshot

7 20140319
源码里面有pppoe的代码。
输入法有源码，做一下修改。
latinime.apk是手机自带的文字输入法,如果你安装有其他输入法,可以删除
但是如果没有的话，还是最好不要删掉了

20140320 
编译完成 out 目录22.3G

生成增量包的python代码：build/tools/releasetools/ota_from_target_files

键盘的kl文件在 system/usr/keylayout里面



-------------------------------------
编译kernel的地方：
device/amlogic/g18ref/BoardConfig.mk  中的
include device/amlogic/$(TARGET_PRODUCT)/Kernel.mk注释掉
这里不用改，用下面的方法

要不编译kernle 需要使用
TARGET_NO_KERNEL

device/amlogic/g18ref/BoardConfig.mk:TARGET_NO_KERNEL := false
需要这里改成 true
----------------------

20140424
在system/app下的apk包里不能包含.so,需要把so拷贝出来放到 /system/lib 目录下


系统生成 system.img 的方法：
在build/core/Makefile 中

# $(1): output file
define build-systemimage-target
  @echo "Target system fs image: $(1)"
  @mkdir -p $(dir $(1)) $(systemimage_intermediates) && rm -rf $(systemimage_intermediates)/system_image_info.txt
  $(call generate-userimage-prop-dictionary, $(systemimage_intermediates)/system_image_info.txt)
  $(hide) PATH=$(foreach p,$(INTERNAL_USERIMAGES_BINARY_PATHS),$(p):)$$PATH \
      ./build/tools/releasetools/build_image.py \
      $(TARGET_OUT) $(systemimage_intermediates)/system_image_info.txt $(1)
endef


./amlogic/g18ref/BoardConfig.mk
TARGET_USERIMAGES_USE_EXT4 := true  决定使用 ext4 文件系统



---------------------
20140429 整理好的 git仓库编译
build/core/java.mk:37: *** cts/apps/CtsVerifier: Invalid LOCAL_SDK_VERSION 'current' Choices are: . Stop.
原因是 prebuilt目录没有建立


telephony-common
mms-common 
这些模块应该不要编译


libgabi++ 这个库在 abi目录编译


external 有一个 libelf工具 干啥的？
external 有一个 perf工具

ffmpeg的目录
packages/amlogic/LibPlayer/amffmpeg/libavcodec/pgssubdec.c


make otapackage 这是原生android就提供的


x509.pem 是什么？？？
X.509是一种非常通用的证书格式


-----------
生成ota升级包

Package OTA: out/target/product/g18ref/g18ref-ota-20140430.V0801.zip
./build/tools/releasetools/ota_from_target_files 
-vn 
-p out/host/linux-x86 
-k build/target/product/security/testkey 
out/target/product/g18ref/obj/PACKAGING/target_files_intermediates/g18ref-target_files-20140430.V0801.zip 
out/target/product/g18ref/g18ref-ota-20140430.V0801.zip


Package target files: out/target/product/g18ref/obj/PACKAGING/target_files_intermediates/g18ref-target_files-20140430.V0801.zip



我整理完的android工程 怎么没有编译recovery呢？ 难道是因为没有kernel？！ 我把common目录下的kernle删除了


----------
现在的逻辑：不编译内核 就不编译recovery，没有recovery就读取不到fstab文件 就不知道 fs_type就没有办法做
otapackage 怎么办？

所以想把kernel完全独立出来，不好弄！

androd


-------------------------
m3  home :
Traceback (most recent call last):
  File "./build/tools/releasetools/ota_from_target_files", line 953, in <module>
    main(sys.argv[1:])
  File "./build/tools/releasetools/ota_from_target_files", line 921, in main
    WriteFullOTAPackage(input_zip, output_zip)
  File "./build/tools/releasetools/ota_from_target_files", line 517, in WriteFullOTAPackage
    common.CheckSize(boot_img.data, "boot.img", OPTIONS.info_dict)
UnboundLocalError: local variable 'boot_img' referenced before assignment [python变量问题，与版本有关？]


公司11.10 python 2.7.2+ (从新立德中看是 2.7.2-7)
家12.04   python 2.7.3

可以在python官网下载2.7.2 源码编译

-------------
打包：
ota_from_target_files -v --amlogic -n -p out/host/linux-x86 -k build/target/product/security/testkey out/target/product/f16ref/obj/PACKAGING/target_files_intermediates/f16ref-target_files-1.0.31.20140729121932.bestv.zip out/target/product/f16ref/f16ref-ota-1.0.31.20140729121932.bestv.zip




---
公司 11.10
lrwxrwxrwx 1 root root       9 2011-11-10 16:46 python -> python2.7
-rwxr-xr-x 1 root root 2735256 2011-10-05 05:26 python2.7
-rwxr-xr-x 1 root root    1652 2011-10-05 05:24 python2.7-config
lrwxrwxrwx 1 root root      11 2011-09-06 05:31 python3.2 -> python3.2mu
-rwxr-xr-x 1 root root 3024320 2011-09-06 05:31 python3.2mu
lrwxrwxrwx 1 root root      16 2011-10-09 00:50 python-config -> python2.7-config

#sudo apt-get install python
Reading package lists... Done
Building dependency tree       
Reading state information... Done
python 已经是最新的版本了。
升级了 0 个软件包，新安装了 0 个软件包，要卸载 0 个软件包，有 530 个软件包未被升级。

$ sudo apt-get install python2.7
Reading package lists... Done
Building dependency tree       
Reading state information... Done
将会安装下列额外的软件包：
  libpython2.7 python2.7-dev python2.7-minimal
建议安装的软件包：
  python2.7-doc
下列软件包将被升级：
  libpython2.7 python2.7 python2.7-dev python2.7-minimal
升级了 4 个软件包，新安装了 0 个软件包，要卸载 0 个软件包，有 526 个软件包未被升级。
需要下载 10.6 MB 的软件包。
解压缩后将会空出 213 kB 的空间。
您希望继续执行吗？[Y/n]


用adb install 安装的应用在data里面。安装完后，就不是那个文件名了（如果直接拷贝到system/app就是原始文件名），而是包名.apk(为啥在m3平台上 是com.joysee.stb.tv-2.apk 前面是包名 -2 是什么意思)

am start -n com.joysee.stb.tv/com.joysee.stb.tv.HomepageActivity  在m3上没有成功


com.joysee.stb.tv-2.apk
com.luxtone.launcher-2.apk


---
hou 可以直接在eclipse中截取stb画面。

adb install 错误：
Failure [INSTALL_PARSE_FAILED_INCONSISTENT_CERTIFICATES] 之前安装了不同人编译的包名相同的apk
可以先删除了。 但是直接在/data/app下面删除，再安装，提示：
Failure [INSTALL_FAILED_UPDATE_INCOMPATIBLE] 因为apk删除不彻底。把/data/data/相应包名/ 目录 还有 ./dalvik-cache 目录还是不行
只能卸载或者恢复出厂设置



./docs/source.android.com/src/source/initializing.md:      zip curl zlib1g-dev libc6-dev lib32ncurses5-dev


mmm -B system/core/adb/ 编译出2个东西：
/root/sbin/adbd 运行在盒子上
system/bin/adb  盒子上为啥还需要adb程序：# adb host tool for device-as-host
out/host/linux-x86/bin/adb 运行在主机


将aapt 和 adb 拷贝到/usr/bin目录

adb uninstall com.joysee.stb.tv 成功删除


在虚拟机的新10.04上编译m3 4.0.4，提示：
/bin/bash: prebuilt/linux-x86/toolchain/arm-linux-androideabi-4.4.x/bin/arm-linux-androideabi-gcc: No such file or directory
这个文件当然是有的，但readelf发现是32位的。
直接执行：
# ./arm-linux-androideabi-gcc
bash: ./arm-linux-androideabi-gcc: No such file or directory

readelf -d 发现依赖：libc.so.6  这时安装ia32-libs后，立即就能执行了。


host C: acp <= build/tools/acp/acp.c
/usr/include/gnu/stubs.h:7:27: error: gnu/stubs-32.h: No such file or directory
原因：apt-get install g++-multilib

在虚拟机中  cp -r sbin/  sbin-back
cp: cannot create symbolic link `sbin-back/ueventd': Read-only file system

编译frameworks/base/tools/aapt/Android.mk时候要用到libpng，所以有 host C: libpng

standalone模式，打印：

--
全新apk强制拷贝到/system/app目录可以运行，如果此目录原有apk，再用一个同名（同包名）替换，会因签名问题不能运行，需要把它
放到prebuilt目录“编译”一下重新签名，再从out目录拷贝到system/app 即可。


20120823
android的build系统很复杂强大，甚至有继承功能，体现了OO思想，比如inherit-product函数
有一些字段的值，如果子文件赋值了，就用子文件的，如果没有赋值，就用父文件的。


ndk
1 ndk9 安装成standalone模式:
/build/tools/make-standalone-toolchain.sh --platform=android-14 --install-dir=/tmp/jpegturbo

4 华硕应用偶尔闪烁红色边框：
I can confirm that changing the build type from "eng" 
(=engineering) to "user" (=end user) does remove the red border issue.

4.0.3只要把 开发人员选项-严格模式已启用  选项去掉，重启即可消失。
应用程序在主线程上执行长时间操作时闪烁屏幕。

5 华硕 terminal的logcat setting应用操作时看到
intent.action.HDMI_PLUGGED  


ndk里面没有pthread库？
通过查看源码，pthread函数在libc.so里，所以不用包含-lpthread  -lrc


3.rootfs的使用
（1）在原来的bcm7241-rootfs上切换到HaiWaiFta分支上
（2）更换kernel
进入cfe，更新kernel为bcm7241-rootfs/cfe_kernel/vmlinuz
（3）修改启动参数
进入cfe的命令行模式，按如下命令修改启动参数：
setenv -p STARTUP "boot -z -elf nandflash0.kernel: 'root=/dev/nfs nfsroot=192.168.5.72:/home/lonely/bcm/723x/bcm7241-rootfs rw, ip=192.168.11.87:192.168.5.72:192.168.88.1:255.255.0.0:ccdt-stb:eth0:on  mtdparts=spi0.0:1M(cfe),64K(macadr),64K(nvram),64K(stbid),64K(disp_format),64K(encryption),-(others);brcmnand.0:10M(kernel),20M(recovery),10M(splash),10M(misc),300M(ubi_fs),3000M(ubi_data),400M(ubi_cache),100M(ubi_dvb) init=/init bmem=192M@64M bmem=440M@512M'"

注:ip地址和nfs路径按照自己的电脑来配置。



uu说haisi文档说u10.04是开发android最好用的系统




---------
编译系统原理及相关
## make
make otapackage
单独编译 system.img的方法

make update-api 会触发重新编译？
HOST_OS_EXTRA=Linux-3.13.0-35-generic-x86_64-with-Ubuntu-14.04-trusty 这个是怎么读出来的？

## Prelink
1. 比如对于prelink的libc.so  如果libc.so 修改了 但是某个库还是基于老的libc.so编译的，那么到新的libc.so上能否运行呢？ 如果不是prelink的肯定没有问题，那么使用prelink的呢？
1. prelink被删除的原因
		build: remove prelinker build build system
		This patch removes support for prelinking from the build system.  By now, the
		prelinker has outlived its usefulness for several reasons.  Firstly, the
		speedup that it afforded in the early days of Android is now nullified by the
		speed of hardware, as well as by the presence of Zygote.  Secondly, the space
		savings that come with prelinking (measued at 17MB on a recent honeycomb
		stingray build) are no longer important either.  Thirdly, prelinking reduces
		the effectiveness of Address-Space-Layout Randomization.  Finally, since it is
		not part of the gcc suite, the prelinker needs to be maintained separately.

		The patch deletes apriori, soslim, lsd, isprelinked, and iself from the source
		tree.  It also removes the prelink map.

		LOCAL_PRELINK_MODULE becomes a no-op.  Individual Android.mk will get cleaned
		separately.  Support for prelinking will have to be removed from the recovery
		code and from the dynamic loader as well.
		Change-Id: I5839c9c25f7772d5183eedfe20ab924f2a7cd411
		SHA:b375e71d306f2fd356b9b356b636e568c4581fa1
1. 2.3之前
		system/core/下面新建一个
		LOCAL_PATH:= $(call my-dir)
		include $(CLEAR_VARS)
		LOCAL_MODULE:= libtest1
		LOCAL_SRC_FILES := test.c
		LOCAL_SHARED_LIBRARIES := libctest
		include $(BUILD_SHARED_LIBRARY)

		这样一个简单的makefile 用mmm编译竟然提示：
		target Prelink: libtest1 (out/target/product/Hi3716C/symbols/system/lib/libtest1.so)
		build/tools/apriori/prelinkmap.c(168): library 'libtest1.so' not in prelink map
		不过system/core/libctest 里面也没有表明prelink 实际上是prelink的
		有的库里面有 LOCAL_PRELINK_MODULE := false  可能默认是prelink
1. 4.0的prelink怎么实现的？
		Prior to Android 4.0 (ICS), the Android system also used prelinking. Prelinking is a valuable performance enhancement,
		but it also has the effect of inhibiting ASLR. In Android 4.0, for a number of different reasons, we decided to remove 
		prelinking from the Android system.


## bionic特点：
	200k大小，比glibc小一半，且比glibc快；
	实现了一个更小、更快的pthread；
	提供了一些Android所需要的重要函数，如”getprop”, “LOGI”等；
	不完全支持POSIX标准，比如C++ exceptions，wide chars等；
	不提供libthread_db 和 libm的实现 

加载动态库使用/system/bin/linker而不是常用的/lib/ld.so;
prelink工具不是常用的prelink而是apriori，源码/build/tools/apriori”
strip不是/prebuilt/linux-x86/toolchain /arm-eabi-4.2.1/bin/arm-eabi-strip，而是/out/host /linux-x86/bin/soslim


	Cortex-A9：Optional NEON media and/or floating point processing engine

	-mfpu=vfpv3-d16
	-mfpu=neon (neon提供FPU所具有的性能和功能)

	那么如何决定使用哪个文件呢？
	core/combo/TARGET_linux-arm.mk中有：

	ifeq ($(strip $(TARGET_ARCH_VARIANT)),)
	TARGET_ARCH_VARIANT := armv5te
	endif
	TARGET_ARCH_SPECIFIC_MAKEFILE := $(BUILD_COMBOS)/arch/$(TARGET_ARCH)/$(TARGET_ARCH_VARIANT).mk
	所以我要去设置 TARGET_ARCH_VARIANT 变量，注意这个文件的注释：
	# Configuration for Linux on ARM.
	# Included by combo/select.mk
	# You can set TARGET_ARCH_VARIANT to use an arch version other
	# than ARMv5TE. Each value should correspond to a file named
	# $(BUILD_COMBOS)/arch/<name>.mk which must contain
	# makefile variable definitions similar to the preprocessor
	# defines in system/core/include/arch/<combo>/AndroidConfig.h. Their
	# 跟AndroidConfig.h有屁关系?!
	# purpose is to allow module Android.mk files to selectively compile
	# different versions of code based upon the funtionality and
	# instructions available in a given architecture version.
	#
	# The blocks also define specific arch_variant_cflags, which
	# include defines, and compiler settings for the given architecture
	# version.
	#




1 framework/base 目录下的 Android.mk 引用 FRAMEWORKS_BASE_SUBDIRS
生成 framework.jar 包含了 framework/base 目录下的所有java文件
2 build/core/pathmap.mk 

FRAMEWORKS_BASE_SUBDIRS := \
        $(addsuffix /java, core graphics location media media/mca/effect \
            media/mca/filterfw media/mca/filterpacks drm opengl sax telephony \
            wifi keystore icu4j voip)

3 apk的class.dex可分离出.odex文件（Optimized DEX）做预处理可加快运行速度，ICS 默认 LOCAL_DEX_PREOPT 为 true
改为false生成完整apk。如果编译某个apk，可在其android.mk里： LOCAL_DEX_PREOPT := false 生成完整apk

错误提示
external/bluetooth/bluedroid/Android.mk:8: NO BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR, using only generic configuration

frameworks/base/core/java/android/os/display/DisplayManager.java:58: warning: unmappable character for encoding UTF8
原来是gb2312有汉字，另存为UTF8即可

能否有1个命令或一个脚本把所有非utf8编码文件修正。并修改windows为linux编码

编译 framework/base/ethernet


在out/.../common/R  or  common/obj目录下有大量java文件（应该是生成的）

out/target/common/obj/JAVA_LIBRARIES/framework_intermediates
framework目录编译的中间目录。把这里的 class.jar 解压缩可以查到
EthernetManager.class


注意，编译靠这个文件
java-source-list


修改了framework目录下的某个文件的编译过程(技巧：故意将java源码改错助于露出端倪)：
以下路径前缀默认： out/target/common/obj/JAVA_LIBRARIES

mkdir -p ./framework_intermediates/
mkdir -p ./framework_intermediates/classe

unzip framework_intermediates/classes
rm    framework_intermediates/classes/META-INF

if [ -d "./framework_intermediates/src" ]; then 
	find ./framework_intermediates/src -name '*.java' >> ./framework_intermediates/classes/java-source-list; 
fi

tr ' ' '\n' < ./framework_intermediates/classes/java-source-list | sort -u > ./framework_intermediates/classes/java-source-list-uniq


如果framework_intermediates/classes/java-source-list-uniq存在且非0，则 
javac 
-J-Xmx512M 
-target 1.5 
-Xmaxerrs 9999999 
-encoding UTF-8 
-g  
-bootclasspath 
out/target/common/obj/JAVA_LIBRARIES/core_intermediates/classes.jar 
-classpath out/target/common/obj/JAVA_LIBRARIES/bouncycastle_intermediates/classes.jar:out/target/common/obj/JAVA_LIBRARIES/core_intermediates/classes.jar:out/target/common/obj/JAVA_LIBRARIES/core-junit_intermediates/classes.jar:out/target/common/obj/JAVA_LIBRARIES/ext_intermediates/classes.jar  
-extdirs "" 
-d ./framework_intermediates/classes
@./framework_intermediates/classes/java-source-list-uniq
#不论javac命令是否成功，都会删除classes目录
|| ( rm -rf out/target/common/obj/JAVA_LIBRARIES/framework_intermediates/classes ; exit 41 )


target Dex: framework
out/host/linux-x86/bin/dx  靠这个命令

java-source-list这个文件是如何生成的？
framework_intermediates/classes 这个目录的内容会变化，我修改了framework下的某个文件，然后编译make systemimage
然后盯着framework_intermediates这个目录，classes一出现就立即复制，捕捉到了java-source-list这个文件
这个文件包含了framework目录下2100多个java文件，怎么生成的？
仅仅解压class.jar 并没有这个文件啊。 后面的部分是靠：
find ./framework_intermediates/src -name '*.java' >> ./framework_intermediates/classes/java-source-list; 
追加的，那么前面的呢？
在./core/definitions.mk 这里处理
找到根源了：# Common definition to invoke javac on the host and target.
看定义：

define compile-java
$(hide) rm -f $@
$(hide) rm -rf $(PRIVATE_CLASS_INTERMEDIATES_DIR)
$(hide) mkdir -p $(dir $@)
$(hide) mkdir -p $(PRIVATE_CLASS_INTERMEDIATES_DIR)
$(call unzip-jar-files,$(PRIVATE_STATIC_JAVA_LIBRARIES),$(PRIVATE_CLASS_INTERMEDIATES_DIR))
$(call dump-words-to-file,$(PRIVATE_JAVA_SOURCES),$(PRIVATE_CLASS_INTERMEDIATES_DIR)/java-source-list)
$(hide) if [ -d "$(PRIVATE_SOURCE_INTERMEDIATES_DIR)" ]; then \
	    find $(PRIVATE_SOURCE_INTERMEDIATES_DIR) -name '*.java' >> $(PRIVATE_CLASS_INTERMEDIATES_DIR)/java-source-list; \
fi
$(hide) tr ' ' '\n' < $(PRIVATE_CLASS_INTERMEDIATES_DIR)/java-source-list \
    | sort -u > $(PRIVATE_CLASS_INTERMEDIATES_DIR)/java-source-list-uniq
$(hide) if [ -s $(PRIVATE_CLASS_INTERMEDIATES_DIR)/java-source-list-uniq ] ; then \
    $(1) -encoding UTF-8 \
    $(strip $(PRIVATE_JAVAC_DEBUG_FLAGS)) \
    $(if $(findstring true,$(LOCAL_WARNINGS_ENABLE)),$(xlint_unchecked),) \
    $(2) \
    $(addprefix -classpath ,$(strip \
        $(call normalize-path-list,$(PRIVATE_ALL_JAVA_LIBRARIES)))) \
    $(if $(findstring true,$(LOCAL_WARNINGS_ENABLE)),$(xlint_unchecked),) \
    -extdirs "" -d $(PRIVATE_CLASS_INTERMEDIATES_DIR) \
    $(PRIVATE_JAVACFLAGS) \
    \@$(PRIVATE_CLASS_INTERMEDIATES_DIR)/java-source-list-uniq \
    || ( rm -rf $(PRIVATE_CLASS_INTERMEDIATES_DIR) ; exit 41 ) \
fi
$(hide) rm -f $(PRIVATE_CLASS_INTERMEDIATES_DIR)/java-source-list
$(hide) rm -f $(PRIVATE_CLASS_INTERMEDIATES_DIR)/java-source-list-uniq
$(if $(PRIVATE_JAR_EXCLUDE_FILES), $(hide) find $(PRIVATE_CLASS_INTERMEDIATES_DIR) \
    -name $(word 1, $(PRIVATE_JAR_EXCLUDE_FILES)) \
    $(addprefix -o -name , $(wordlist 2, 999, $(PRIVATE_JAR_EXCLUDE_FILES))) \
    | xargs rm -rf)
$(hide) jar $(if $(strip $(PRIVATE_JAR_MANIFEST)),-cfm,-cf) \
    $@ $(PRIVATE_JAR_MANIFEST) -C $(PRIVATE_CLASS_INTERMEDIATES_DIR) .
endef
注释：$(PRIVATE_JAVA_SOURCES) 是framework/base(或其他编译目录) 目录下的所有java文件
可用 $(info $(PRIVATE_JAVA_SOURCES)) 打印
define dump-words-to-file
        @rm -f $(2)
        @$(call emit-line,$(wordlist 1,200,$(1)),$(2))
        @$(call emit-line,$(wordlist 201,400,$(1)),$(2))
....
这里为啥分多次写入，一次写入不行吗？

靠dump-words-to-file 生成 java-source-list



framework/base 删除里面的api.xml 测试用的视频，真正代码部分就50M 左右。没有那么的庞大。
4.1编译完，out有17G之多

4 4.1的编译器目录比较混乱
prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.6/bin:
prebuilts/gcc/linux-x86/arm/arm-eabi-4.6/bin:
通过showcommands发现最终用的是前者。那么prebuilt目录是干什么的呢？


build/envsetup.sh
including device/asus/grouper/vendorsetup.sh
including device/generic/armv7-a-neon/vendorsetup.sh
including device/generic/armv7-a/vendorsetup.sh
including device/moto/wingray/vendorsetup.sh
including device/samsung/crespo/vendorsetup.sh
including device/samsung/maguro/vendorsetup.sh
including device/ti/panda/vendorsetup.sh
including sdk/bash_completion/adb.bash

显示配备了这些device 最后的sdk/bash 是什么？


prebuilt 和 prebuilts 两个目录都需要，删除prebuilt 系统编译不过去
在这2个目录中删除了一些不用的编译器，比如过时的arm版本，x86编译器等。

c++的server都是由init启动
关于权限问题，xml可以制定 shared uid

system权限 1000 有权访问 apk目录吗？


1 设置环境变量：
  a. 普通(用于发布)  ：
	source pnx8400_a9_env.sh newbox retail singlehd_license_free
  b. 带打印(用于调试)：
	source pnx8400_a9_env.sh newbox retail singlehd_license_free_trace
  c. 编译SDK之外app，比如测试程序等
        source android_env.sh newbox retail singlehd_license_free ; export _TMTGTCOPYAPP=1
         文件生成在 bin/armgnu_linux_static_el_cortex-a9_flo_linux_mp_ 目录下
  d. 编译SDK之外的库，比如dd，dm
        source android_env.sh newbox retail singlehd_license_free ; export _TMTGTCOPYLIB=1
         文件生成在 lib/armgnu_linux_static_el_cortex-a9_flo_linux_mp_ 目录下
  在以上配置中加 export _TMECHO=1 (分号隔离) 可以显示编译参数详情

2 编译
  a. sdk全部编译： 执行 make （sdk根目录）
  b. 只编译sdk用户空间部分： 执行 make change_toolchain 或者执行 make app （sdk根目录）
  c. 编译自己的库或者测试程序： 进入自己的makefile所在目录，执行 make

3 gnu linux的rootfs编译
  在当前目录
  全部编译： 执行 make -f makefile-gnu
  只编译用户空间部分： 执行 make -f makefile-gnu app


frameworks/base/libs/utils/Android.mk  生成 libutils.so
ndk编译的时候
prebuiltLib/libutils.so: undefined reference to `__aeabi_f2ulz'  这个函数在libgcc.a中
什么样的c语言描述会调用这个函数呢？ 貌似是浮点运算,换成ndk-r4 就没有这个打印


configuration::
ifeq ($(_SDE_BUILD_TARGET),LIB)
ifeq ($(SDE_IN_SDE),.)
ifeq ($(_$(notdir $(DIR_LOCAL))_DIR),)
        @$(ECHO) 'SDE2 can not find definition of _$(notdir $(DIR_LOCAL))_DIR. Update your prjlist.txt or loc_list.* files !!!'
else
ifeq ($(wildcard $(_$(notdir $(DIR_LOCAL))_DIR)),)
$(LOC_LIST_MKFILENAME) $(LOC_LIST_FILENAME)::                   \
                $(_SDE_PRJLIST_FILENAME)                        \
                $(_SDE_DEP_MAKEFILES)                           \
                $(DIR_SDE)/awk/generate_loc_list.awk                    \
                $(_SDE_REQPRJ_DIRS)
        @$(_SDE_ECHO)$(RM) $(LOC_LIST_MKFILENAME) $(LOC_LIST_FILENAME);
        @$(MKDIR) $(_SDE_TMTGTBUILDROOT)/project
        @$(ECHO) \# $(LOC_LIST_MKFILENAME) > $(LOC_LIST_MKFILENAME)
        @$(ECHO) \# DO NOT EDIT. This file has been generated automatically. >> $(LOC_LIST_MKFILENAME)
        @$(ECHO) $(LOC_LIST_FILENAME) $(LOC_LIST_MKFILENAME) $(LOC_LIST_TMPFILENAME) $(_SDE_REQPRJ) \
        |$(GAWK) -f $(DIR_SDE)/awk/generate_loc_list.awk
-include                $(LOC_LIST_MKFILENAME)
endif
endif
endif
endif

这个文件里果然有2个
configuration::
因为后面有2个冒号，否则会提示错误的



系统编译完成后，再次执行：
 make systemimage showcommands 会发现什么


1  packages/amlogic/LibPlayer/amplayer/player/version.c  里面有取系统时间或者git版本号的操作，导致每次编译都变化，很烦人，关闭之。
2 编译一个.c 使用prebuilt/linux-x86/toolchain/arm-linux-androideabi-4.4.x/bin/arm-linux-androideabi-gcc 这个编译器
3 image文件是靠mkyaffs2image 程序生成的，他是external目录的yaffs2 目录生成的HOST程序。
4 我mmm external/yaffs2
先调用cc（cc就是gcc，系统中是/usr/bin/cc是链接）编译如下文件：
LOCAL_SRC_FILES := \
	yaffs2/utils/mkyaffs2image.c \
	yaffs2/yaffs_packedtags2.c \
	yaffs2/yaffs_ecc.c \
	yaffs2/yaffs_tagsvalidity.c
然后调用 g++ 链接4个.o 成  mkyaffs2image 并安装到 out/host/linux-x86/bin
$(call dist-for-goals, dist_files, $(LOCAL_BUILT_MODULE)) 这句话干啥用的？

那么 mkyaffsimage4K.dat 是怎么生成的？

host Prebuilt: mkyaffsimage4K.dat (out/host/linux-x86/obj/EXECUTABLES/mkyaffsimage4K.dat_intermediates/mkyaffsimage4K.dat)
out/host/linux-x86/bin/acp -fp device/amlogic/common/tools/mkyaffsimage4K.dat out/host/linux-x86/obj/EXECUTABLES/mkyaffsimage4K.dat_intermediates/mkyaffsimage4K.dat
Install: out/host/linux-x86/bin/mkyaffsimage4K.dat
out/host/linux-x86/bin/acp -fp out/host/linux-x86/obj/EXECUTABLES/mkyaffsimage4K.dat_intermediates/mkyaffsimage4K.dat out/host/linux-x86/bin/mkyaffsimage4K.dat

使用的是  device/amlogic/common/tools 目录下的 mkyaffsimage4k.dat

LOCAL_MODULE := $(TARGET_AMLOGIC_MKYAFFSIMG_TOOL)
BoardConfig.mk 中定义：
TARGET_AMLOGIC_MKYAFFSIMG_TOOL := mkyaffsimage4K.dat


每次编译，这个文件device/amlogic/f16ref/f16ref.mk 自动生成？！！！
./build/env_bestv.sh:cp -f $PWD/amlogic/$PRJNAME/conf/f16ref.mk   $PWD/device/amlogic/f16ref/   ！！！

./amlogic/bestv/conf/f16ref.mk

2 
./core/definitions.mk
ifeq ($(strip $(SHOW_COMMANDS)),)
define pretty
@echo $1
endef
hide := @
else
define pretty
endef
hide :=
endif

make showcommands xxx  显示详细信息

main.mk 中的伪目标：
.PHONY: showcommands
showcommands:
        @echo >/dev/null


目录精简：
1. qemu-kernel不能删除
No rule to make target `prebuilts/qemu-kernel/arm/LINUX_KERNEL_COPYING', needed by `out/target/product/A20_B133/obj/NOTICE_FILES/src/kernel.txt'.  Stop.

1. 



libEGL.so 每次编译为何不同？

