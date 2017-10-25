Termux在Android上的一个Linux环境终端的模拟器，无需root而且有自己包管理系统。

Termux非常强大，有很多可以想象的空间，本文也将基于Termux实现在Android中运行C++程序。

<!--more-->

## 前提准备

### Android SDK (SDK-Tools)

本文将会应用adb与手机进行通信，所以需要在PC端配置好Android SDK环境，如果你不需要和手机有复杂的操作，只安装adb即可。

安装和使用过程，可以参考[adb官方文档](https://developer.android.com/studio/command-line/adb.html)

并将sdk-tools添加到环境变量中。

### Android NDK

NDK用来将你的C++代码编译成在Android可执行程序，建议使用最新版本的NDK环境。

Android NDK独立的[下载地址](https://developer.android.google.cn/ndk/downloads/index.html)。

并将ndk的环境添加到环境变量中。

虽然本文只需要上述两个工具链即可完成，还是**建议你搭建完整的SDK & NDK环境**，参考[NDK环境搭建](https://developer.android.com/ndk/guides/index.html)。

### 技能

你需要有C++的编码能力，和Android NDK相关的知识，但不需要Android App的开发能力。



## 配置Termux环境

[Termux](https://termux.com/)是运行Android上的一个Linux环境终端的模拟器，无需root而且有自己包管理系统。

Termux非常强大，有很多可以想象的空间，本文也将基于Termux运行实现在Android中运行C++程序。

首先，需要配置Termux环境，建立PC端和Android端的链接。

### 1. 安装Termux

- 通过[GooglePlay](https://play.google.com/store/apps/details?id=com.termux)直接下载安装
- 通过[f-driod](https://f-droid.org/packages/com.termux/)下载Apk后，在pc端通过命令行进行安装
	
```
adb install ~/yourpath/com.termux_xx.apk
```

### 2. 在Termux上安装ssh 

在Android手机上运行Termux，输入一下命令来更新包管理系统及安装openssh。  
如果发生crash，请先到系统设置->权限管理中，检查下Termux需要的读写文件权限是否已被授予。

```
apt update
apt upgrade
apt install openssh
```

### 3. 建立PC端和Termux的信任

#### PC端

- 进入PC端rsa文件公钥所在的文件夹。（unix中默认在~/.ssh/）。
- 将PC端公钥导入手机的存储卡中，并命名为authorized_keys

```
adb push id_rsa.pub /sdcard/authorized_keys
```
#### Termux端

- 创建.ssh文件夹，用来存放公钥，输入

```
mkdir .ssh
```

- 将authorized_keys移动到.ssh文件夹下

```
mv /sdcard/authorized_keys .ssh/
```

- 更改authorized_keys的权限

```
chmod 400 authorized_keys
```

#### 建立连接

- 打开sshd

```
sshd
```

参考[sshd说明](https://termux.com/ssh.html)。  
  
  

- 建立tcp连接

```
adb forward tcp:8022 tcp:8022
ssh localhost -p 8022
```

这样就可以通过PC上就可以共享Termux的终端了。如图为连接成功的界面。

![termux2](http://owav9p2fv.bkt.clouddn.com/termux2.png)

 

## 运行C++工程

搭建好Termux的环境后，就需要用NDK正确的build出你的C++程序，然后将可执行程序copy到Termux的环境中，设置好相应环境变量就可以运行了。
 
### 编译C++工程

- 创建jni文件夹，在jni文件夹中创建Application.mk和Android.mk。  
- 编辑**Application.mk**，可以参考下面的代码。

```
APP_PLATFORM := android-14
APP_STL := c++_static
APP_ABI := armeabi-v7a arm64-v8a
APP_PIE := true

```

- 编辑**Android.mk**，需要注意的是要build出一个可执行文件。

```
include $(BUILD_EXECUTABLE)
```
参考[Android makefile的用法](http://android.mk/)。

### 上传到Termux环境

经过ndk-build后，如果编译成功，将会默认生成一个libs文件夹，在libs文件夹中有各个编译平台的子文件夹，将相应平台的可执行文件copy到Termux中。

```
scp -P 8022 ../libs/armeabi-v7a/your_sample_name localhost:~
```

如果在有对其他的库有依赖，需要把相关的文件都copy到Termux中，并在Termux中加入环境变量。

- 创建脚本addenv.sh，在Termux中添加环境变量

```
export LD_LIBRARY_PATH=armeabi-v7a/
```

- 把相应的库依赖、头文件和addenv.sh copy到Termux中

```
scp -r -P 8022 ../lib/armeabi-v7a/ localhost:~
scp -P 8022 addenv.sh localhost:~
```

### 运行

上传后，通过在Termux终端可以看到上传的文件。

![termux终端](http://owav9p2fv.bkt.clouddn.com/ls_mutex2.png)

运行bianry文件。

```
./your_simple_name
```

![termux_result](http://owav9p2fv.bkt.clouddn.com/termux_result.png)