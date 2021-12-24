# Linux 学习笔记

## 前言

主要参考视频教程：https://www.bilibili.com/video/BV16Q4y1y7xS

本项目的一些参考文档（refs 目录）也是从该视频教程获取得到的。

## 软件安装

- VMare 5
- CentOS 7.6 - 64
- Xshell 5.x
- Xftp



---

*以下是续写 `./refs/01Linux.pdf` 之后的笔记。*

## Shell编程

### Shell编程概述

#### Shell名词解释

- Kernel（内核）

  - Linux 内核主要是为了和硬件打交道

- Shell（外壳）

  - 命令解释器（Command Interpreter）
  - Shell 是一个用 C语言编写的程序，它是用户使用 Linux 的桥梁。Shell 既是一种命令语言，又是一种程序设计语言。
  - Shell 是指一种应用程序，这个应用程序提供了一个界面，用户通过这个界面访问操作系统内核的服务。

- Shell 两大主流

  - sh
    - Bourne Shell（sh），Solaris，hpux 默认 Shell
    - Bourne Again Shell（Bash），Linux 系统默认 Shell
  - csh
    - C Shell（csh）
    - TC Shell（tcsh）

- `#!` 声明

  - 告诉系统其后路径所指定的程序即是解释此脚本文件的 Shell 程序

  - ```shell
    #! /bin/bash
    echo "Hello World!"
    ```

#### Shell脚本的执行

Shell 脚本的执行有以下三种方式：

1. 输入脚本的绝对路径或相对路径
   - `/root/test.sh`
   - `./test.sh`
   - **注意：使用该方法执行的文件必须是可执行文件，可通过 `chmod ugo+x test.sh` 这种方式添加执行权限。**
2. `bash` 或 `sh` 加上脚本路径
   - `sh test.sh` 或者 `bash test.sh`
   - 当脚本没有执行权限时，root 和文件拥有者可以通过该方式正常执行脚本。
3. `source` 或 `.` 加上脚本路径
   - `source test.sh` 或 `. test.sh`

**三种方式的区别**

- 第一种和第二种方式会新开一个 bash 进程，不同 bash 进程中的变量无法共享；
- 第三种方式是在同一个 bash 进程里执行，所以可以使用原来进程的变量。

例如，创建一个 `hello.sh`，写入：

```shell
#! /bin/bash
echo "hello world"
echo $test
ping www.baidu.com >> baidu.log
```

之后，在 Shell 中声明一个变量：`test=test_information`。

然后，分别使用以上三种方式执行脚本：

![](https://gitee.com/gainmore/imglib/raw/master/img/20211224135951.png)

![](https://gitee.com/gainmore/imglib/raw/master/img/20211224140029.png)

![](https://gitee.com/gainmore/imglib/raw/master/img/20211224140047.png)

可以发现，只有第三种方式获取到了声明的变量 `$test`。

然后，我们分别查看这三种方式下的进程信息：`ps -ef`：

![](https://gitee.com/gainmore/imglib/raw/master/img/20211224140312.png)

![](https://gitee.com/gainmore/imglib/raw/master/img/20211224140339.png)

![](https://gitee.com/gainmore/imglib/raw/master/img/20211224140959.png)

画出进程关系图：

![](https://gitee.com/gainmore/imglib/raw/master/img/20211224141905.png)

可以发现，由于前两种方式创建了一个 bash 进程，所以无法将原来进程声明的 `test` 变量传递给 `ping` 进程，而第三种方式由于没有新建进程，所以脚本里可以获取到 `test` 变量。

为了解决以上问题，可以使用 `export` 语句：

- 如：`export $test`；
- 它可以将当前进程的变量传递给子进程区去使用；
- 将来配置 `profile` 时，所有变量前必须加上 `export` ，以适配这三种执行脚本的方式。



### Shell基础入门

#### Shell变量

**命名规范**

- 定义变量时，变量名不加美元符号；
- 命名时只能使用英文字符、数字和下划线，首个字符不能以数字开头；
- 中间不能有空格，可以使用下划线；
- 不能使用标点符号；
- 不能使用 bash 里面的关键字（可用 help 命令查看保留关键字）。

**变量类型**

- 局部变量
  - 局部变量在脚本或命令中定义，仅在当前 Shell 实例中有效，其他 Shell 启动的程序不能访问局部变量。
- 环境变量
  - 所有程序（包括 Shell 启动的程序）都能访问环境变量，有些程序需要环境变量来保证其正常运行。
- Shell 变量
  - Shell 变量是由 Shell 程序设置的特殊变量，Shell 变量中有一部分是环境变量，有一部分是局部变量。

```shell
#! /bin/bash

# 变量的声明
name="zhangsan"

# 变量的调用
echo $name
echo ${name}

# 声明只读变量
url="https://www.baidu.com"
readonly url

# 删除变量
unset name
```

#### Shell字符串

字符串是 Shell 编程中最常用最有用的数据类型，字符串可用单引号，也可用双引号，也可以不用引号。

- 单引号
  - 单引号里的任何字符都会原样输出，单引号字符串中的变量是无效的；
  - 单引号字符串不能出现单独一个的单引号，但可以成对出现，作为字符串拼接使用。
- 双引号
  - 双引号里可以有变量；
  - 双引号里可以出现转义字符；

```shell
# 声明字符串
str1="111"
str2='222'

# 字符串拼接（双引号）
name="word"
name1="hello, $name !"
name2="hello, ${name} !"

# 字符串拼接（单引号）
pwd='1234'
pwd1='hello, $pwd !'
pwd2='hello, ${pwd} !'

# 字符串的长度
email="test@qq.com"
echo ${#email} # 11
echo ${email:1:4} # est@
```

#### Shell数组

- bash 支持一维数组（不支持多维数组），并且没有限定数组的大小；

- 数组元素的下标由 0 开始编号。获取数组中的元素要利用下标，下标可以是整数或算数表达式，其值应大于或等于 0；

- ```shell
  # 定义数组，括号表示数组，数组元素用空格分隔开
  arr=("aaa" "bbb" "ccc")
  
  # 读取数组
  echo ${arr[1]} # bbb
  
  # 使用 @ 或 * 可以获取数组中的所有元素
  echo ${arr[@]} # aaa bbb ccc
  echo ${arr[*]} # aaa bbb ccc
  
  # 获取数组的长度
  len1=${#arr[@]} # 3
  len2=${#arr[*]} # 3
  ```

#### Shell注释

- 以 # 开头的行就是注释，会被解释器忽略；

- 通过每一行加一个 # 设置多行注释；

- ```shell
  # ---------
  # author:
  # site:
  # ---------
  #### start #####
  #
  #
  #
  #### end   ####
  
  
  # 特殊的多行注释（EOF可以代替为任意字符）
  :<<EOF
  content...
  content...
  content...
  EOF
  
  :<<!
  content...
  content...
  content...
  !
  ```

#### Shell参数传递

- 执行 Shell 脚本时，向脚本传递参数，脚本内获取参数的格式为：$n。n 代表一个数字。

- | 参数处理 | 参数说明                                                     |
  | -------- | ------------------------------------------------------------ |
  | $#       | 传递到脚本的参数个数                                         |
  | $*       | 以一个单字符串显示向脚本传递的所有参数                       |
  | $$       | 脚本运行的当前进程ID号                                       |
  | $?       | 显示最后命令的退出状态。0 表示没有错误，其他任何值表示有错误。 |
  | $0       | 执行的文件名                                                 |

- ![](https://gitee.com/gainmore/imglib/raw/master/img/20211224153600.png)

- ![](https://gitee.com/gainmore/imglib/raw/master/img/20211224153625.png)

### Shell高级进阶

#### Shell运算符

**算术运算符**

| 算术运算符 | 说明 | 举例                  |
| ---------- | ---- | --------------------- |
| +          | 加法 | `expr $a + $b` = 30   |
| -          | 减法 | `expr $a - $b` = -10  |
| *          | 乘法 | `expr $a \* $b` = 200 |
| /          | 除法 | `expr $b / $a` = 2    |
| %          | 取余 | `expr $b %a` = 0      |
| =          | 赋值 | `a=$b`                |

**关系运算符**

关系运算符只支持数字，不支持字符串，除非字符串的值是数字。

| 关系运算符 | 说明                             |
| ---------- | -------------------------------- |
| `-eq`      | 等于，equal                      |
| `-ne`      | 不等于，not equal                |
| `-gt`      | 大于，greater than               |
| `-lt`      | 小于，less than                  |
| `-ge`      | 大于等于，greater than and equal |
| `-le`      | 小于等于，less than and equal    |

**布尔运算符**

| 布尔运算符 | 说明   |
| ---------- | ------ |
| `==`       | 相等   |
| `!=`       | 不相等 |

**逻辑运算符**

| 逻辑运算符 | 说明   |
| ---------- | ------ |
| `&&`       | 短路与 |
| `||`       | 短路非 |

**字符串运算符**

| 字符串运算符 | 说明                     |
| ------------ | ------------------------ |
| `=`          | 判断两个字符串是否相等   |
| `!=`         | 判断两个字符串是否不相等 |
| `-z`         | 判断字符串长度是否为 0   |
| `-n`         | 判断字符串长度是否不为 0 |
| `$var`       | 判断字符串是否不为空     |

**文件测试运算符**

| 文件测试运算符 | 说明                   |
| -------------- | ---------------------- |
| `-r`           | 判断文件是否可读       |
| `-w`           | 判断文件是否可写       |
| `-x`           | 判断文件是否可执行     |
| `-f`           | 判断文件是否为普通文件 |
| `-d`           | 判断文件是否为目录     |
| `-s`           | 判读文件是否不为空     |
| `-e`           | 判断文件是否存在       |

```shell
#! /bin/bash

a=40
b=20

# ``里的字符串会被视为命令去执行
sum=`expr $a + $b`
echo $sum # 60

if [ $a -eq $b ]
then
  echo "a 等于 b"
else
  echo " a 不等于 b "
fi # 判断结束需要有 finish
```

#### echo命令

Shell 的 echo 命令用于字符串的输出。

```shell
# 显示普通字符串
echo "Hello World"
# 显示转义字符
echo "\"Hello World\""
# 显示变量
name="zhangsan"
echo "$name Hello World"
# 显示换行
echo -e "OK! \n"
echo "Hello World"
# 显示不换行
echo -e "OK! \c"
echo "Hello World"
# 显示结果覆盖文件
echo "Hello World" > file.txt
# 显示结果追加至文件
echo "Hello World" >> file.txt
# 原样显示字符串
echo '$name\'
# 显示命令执行结果
echo `date`
```

#### test命令

Shell 中的 test 命令用于检查某个条件是否成立，它可以进行数值、字符和文件三方面的测试。

- 数字

  | 参数  | 说明           |
  | ----- | -------------- |
  | `-eq` | 等于时为真     |
  | `-ne` | 不等于时为真   |
  | `-gt` | 大于时为真     |
  | `-ge` | 大于等于时为真 |
  | `-lt` | 小于时为真     |
  | `-le` | 小于等于时为真 |

- 字符串

  | 参数        | 说明                   |
  | ----------- | ---------------------- |
  | `=`         | 等于时为真             |
  | `!=`        | 不等于时为真           |
  | `-z String` | 字符串长度为零时为真   |
  | `-n String` | 字符串长度不为零时为真 |

- 文件测试

  | 参数      | 说明                             |
  | --------- | -------------------------------- |
  | `-e File` | 文件存在时为真                   |
  | `-r File` | 文件存在且可读时为真             |
  | `-w File` | 文件存在且可写时为真             |
  | `-x File` | 文件存在且可执行时为真           |
  | `-s File` | 文件存在且至少有一个字符时为真   |
  | `-d File` | 文件存在且为目录时为真           |
  | `-f File` | 文件存在且为普通文件时为真       |
  | `-c File` | 文件存在且为字符型特殊文件时为真 |
  | `-b File` | 文件存在且为块特殊文件时为真     |

```shell
#! /bin/bash
n1=100
n2=100

if test $[n1] -eq $[n2]
then
  echo "n1 == n2"
else
  echo "n1 !== n2"
fi
```

#### Shell流程控制

**if**

```shell
if [ condition1 ]
then
  command1
elif [ condition2 ]
then
  command2
elif [ condition3 ]
then
  command3
...
else
  commandN
fi
```

**case**

Shell 中的 case 语句为多选择语句，可以用 case 语句匹配一个值于一个模式，如果匹配成功，执行相匹配的命令。

```shell
#! /bin/bash

echo "输入 1 ~ 4 之间的数字："
echo "你输入的数字为："
read num
case $num in
  1) echo "你输入了 1"
  ;;
  2) echo "你输入了 2"
  ;;
  3) echo "你输入了 3"
  ;;
  4) echo "你输入了 4"
  ;;
  *) echo "你没有输入 1 ~ 4 之间的数字"
  ;;
esac
```

**for**

- 当变量在列表里，for 循环即执行一次所有命令，使用变量名获取列表中的当前取值；

- 命令可为任何有效的 Shell 命令和语句，in 列表可以包含替换、字符串和文件名；

- in 列表是可选的，如果不用它，for 循环使用命令行的位置参数；

- ```shell
  for loop in 1 2 3 4 5
  do
    echo "The value is $loop"
  done
  
  for char in "This is a string."
  do
    echo $char
  done
  ```

**while**

- while 循环用于不断执行一系列命令，也用于从输入文件中读取数据，命令通常为测试条件；

- ```shell
  while condition
  do
    command
  done
  ```

- ```shell
  init=1
  while ( $init<=5 )
  do
    echo $init
    let "init++"
  done
  
  # 无限循环
  while true
  do
    command
  done
  ```

**break**

break 命令允许跳出所有循环（终止执行后面的所有循环）。

```shell
while :
do
  echo -n "输入 1 ~ 5 之间的数字："
  read num
  case $num in
    1 | 2 | 3 | 4 | 5) echo "你输入的数字为 $num"
    ;;
    *) echo "你输入的数字不在 1 ~ 5 之间，游戏结束！"
       break
    ;;
  esac
done
```

**continue**

continue 命令不会跳出所有循环，仅仅跳出当前循环。

```shell
while :
do
  echo -n "输入 1 ~ 5 之间的数字："
  read num
  case $num in
    1 | 2 | 3 | 4 | 5) echo "你输入的数字为 $num"
    ;;
    *) echo "你输入的数字不在 1 ~ 5 之间"
       continue
       echo "游戏结束"
    ;;
  esac
done
```

#### Shell函数

- Shell 中用户可以自定义函数，然后在 Shell 脚本中可以随便调用；
- 可以带 function fun() 定义，也可以直接 fun() 定义，不带任何参数；
- 参数返回，可以显示加：return 返回，如果不加， 将以最后一条命令运行结果作为返回值返回。

```shell
demoFun() {
  echo "Hello World!"
}
echo "函数开始执行"
demoFun
echo "函数执行完毕"

# 函数带返回值
fun1() {
  echo "两数相加"
  echo "输入第一个数字："
  read a
  echo "输入第二个数字："
  read b
  return $(($a + $b))
}
fun1

# 函数传参
fun2() {
  echo "param1: $1"
  echo "param2: $2"
  echo "param10: $10"
  echo "param11: ${11}"
  echo "count: $#"
  echo "all params: $*"
}
fun2 1 2 3 4 5
```



### 系统任务设置

#### 系统启动流程

- 启动计算机的硬件（BIOS）

  - 读取时间（BIOS 中有电池，可以存储时间）
  - 选择对应的启动模式（USB / HDD / EFI）

- 如果是 linux 系统，找到 `/boot` 目录，引导这个系统启动

- 计算机系统开始启动，读取初始化配置文件

  - `vim /etc/inittab`

  - 启动时控制着计算机的运行级别 `runlevel`

  - | runlevel | 说明                                                         |
    | -------- | ------------------------------------------------------------ |
    | 0        | halt（关机）                                                 |
    | 1        | Single user mode（单用户模式）                               |
    | 2        | Multiuser，without NFS（多用户模式，但是无网络状态）NFS：NetworkFileSystem |
    | 3        | Full multiuser mode（多用户完整版模式）                      |
    | 4        | unused（保留模式）                                           |
    | 5        | X11（用户界面模式）                                          |
    | 6        | reboot（重启模式）                                           |

  - `id:3:initdefault`：默认 runlevel 为 3（有图形界面默认为 5，无图形界面默认为 3）

  - 以 runlevel=3 开始启动对应的服务和组件

- 开始默认引导公共的组件或者服务

  - `ll /etc/rc.d/`

  - ![](https://gitee.com/gainmore/imglib/raw/master/img/20211224193359.png)

    > 设置开机自启动脚本时，通常有两种方式：1. 借助 rc3.d （这种方法只能在对应的 runlevel 下生效，比如 CentOS7 只能修改 rc3.d）；2. rc.local （这种方式理论上可以在任意的 runlevel 下生效）。

- 开始加载对应 runlevel 的服务

  - `ll /etc/rc3.d`
    - ![](https://gitee.com/gainmore/imglib/raw/master/img/20211224193531.png)
    - K (Kill)：关机时需要关闭的服务；
    - S (Start)：启动时需要开启的服务；
    - 数字代表了开启或关闭的顺序；
    - 所有的文件都是软连接，链接的地址为 `/etc/init.d`

- 当启动完毕后，所有的服务也被加载完成。

流程图：

![](https://gitee.com/gainmore/imglib/raw/master/img/20211224201941.png)

#### 系统服务

- 我们可以使用 `chkconfig` 命令查看当前虚拟机的服务；
- 通过查看可以得知不同的级别对应到每一个服务确定本次开机自动启动；
- 开机结束后，我们需要使用 `service(CentOS6) / systemctl(CentOS7)` 命令控制服务的开启或者关闭。

#### 开机自启动服务

添加开机自启动脚本有以下两种方式：

1. `rc.local`

     - 首先创建脚本存放的文件夹

       - `mkdir -p /usr/local/scripts`


     - 在文件夹中创建脚本文件

       - `vi test.sh`

       - ```shell
         # test.sh
         #! /bin/bash
         
         yum info ntp && ntpdate cn.ntp.org.cn
         ```

       - 给予执行权限：`chmod u+x test.ch`


     - 给予 `rc.local` 执行权限

       - `chmod a+x /etc/rc.d/rc.local`


     - 去 `/etc/rc.d/rc.local` 文件中添加脚本的绝对路径

       - `vi /etc/rc.d/rc.local`
       - 末行添加：`/usr/local/scripts/test.sh`


     - 测试

       - 修改本地时间：`date -s "11:11:11"`
       - 重启：`reboot`
       - 重启后检查时间：`date`


2. `chkconfig`

   - 创建开机自启动脚本文件

   - `vi initDate.sh`

   - ```shell
     #! /bin/bash
     # chkconfig 2345 88 99
     # description: auto_run
     
     # 开机自启动同步时间
     yum info ntp && ntpdate cn.ntp.org.cn
     ```

   - 给文件设置执行权限

     - `chmod u+x initDate.sh`

   - 将脚本拷贝到 `/etc/init.d` 目录下

     - `cp initDate.sh /etc/init.d/`

   - 添加服务

     - `chkconfig --add /etc/init.d/initDate.sh`
     - ![](https://gitee.com/gainmore/imglib/raw/master/img/20211224201001.png)

   - 重启服务器

     - `reboot`

   - 测试

#### 定时任务

- 在系统服务中心，`crond` 负责周期任务；

  - `systemctl status crond.service`

- 添加任务，编辑当前用户的任务列表；

  - `crontab -e`

- 编辑任务

  - `* * * * * command`  ==  `分 时 日 月 周 命令`

    第一列表示分钟 0 ~ 59，每分钟用 * 或者 */1 表示；

    第二列表示小时 0 ~ 23（0 表示 0 点）；

    第三列表示日期 1 ~ 31；

    第四列表示月份 1 ~ 12；

    第五列表示星期 0 ~ 6（0 表示星期天）；

    第六列表示要运行的命令。

  - `*`：表示任意时间都，实际上就是 “每” 的意思，可以代表 00~23 时或者 01~12 月 或者 00~59 分；

    `-`：表示区间，它是一个范围；

    `,`：表示多个时间，实际上就是 “或” 的意思；

    `/n`：表示每隔 n 的时间。

  - ```shell
    # 表示每月 1、10、22 号的 4:45 重启 apache
    45 4 1,10,22 * * /usr/local/etc/rc.d/lightpd restart
    
    # 表示每周六、周日的 1:10 重启 apache
    10 1 * * 6,0 /usr/local/etc/rc.d/lightpd restart
    
    # 表示每天 18:00 至 23:00 之间每隔 30 分钟重启 apache
    0,30 18-23 * * * /usr/local/etc/rc.d/lightpd restart
    
    # 表示每周六的 23:00 重启 apache
    0 23 * * 6 /usr/local/etc/rc.d/lightpd restart
    
    # 表示每隔两小时重启 apache
    * */2 * * * /usr/local/etc/rc.d/lightpd restart
    
    # 表示每天晚上 11 点到早上 7 点之间，每隔一小时重启 apache
    * 23-7/1 * * * /usr/local/etc/rc.d/lightpd restart
    
    # 表示每月的 4 号和每周一到周三的 11 点重启 apache
    0 11 4 * mon-wed /usr/local/etc/rc.d/lightpd restart
    
    # 表示每年 1 月 1 号的 4:00 重启 apache
    0 4 1 jan * /usr/local/etc/rc.d/lightpd restart
    
    # 显示年月日时分秒
    date "+%Y%m%d%H%M%S"
    ```

- 重启 `crontab`，使配置生效

  - `systemctl restart crond.service`

- 查看当前的定时任务

  - `crontab -l`

- 查看任务的历史

  - `vi /var/spool/mail/root`

- 清除任务

  - `crontab -r`

#### 虚拟机初始化脚本

initEnv.sh

```shell
#! /bin/bash
# 执行文件报错：-bash: ./initEnv.sh: /bin/bash^M: bad interpreter: No such file or directory
# 原因：Windows 和 Linux 系统换行符不一致导致的问题；
# 解决方法1：vi 或 vim 命令下，输入 set fileformat=unix 解决换行问题；
# 解决方法2：sed -i "s/\r//" init.sh
echo -e "========== 在 opt 和 var 创建 initEnv 文件夹 =========="
sleep 1
mkdir -p /opt/initEnv
mkdir -p /var/initEnv
mkdir -p /usr/local/scripts

echo -e "========== 禁用防火墙 =========="
sleep 1
systemctl stop firewalld
systemctl disable firewalld
systemctl status firewalld

echo -e "========== 修改 selinux =========="
sleep 1
sed -i "/^SELINUX=/c SELINUX=disabled" /etc/selinux/config

echo -e "========== 安装 wget =========="
sleep 1
yum install wget -y

echo -e "========== 修改 yum 源 =========="
sleep 1
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache

echo -e "========== 安装 man =========="
yum install man -y

echo -e "========== 安装 man-pages =========="
yum install man-pages -y

echo -e "========== 安装 ntp =========="
yum install ntp -y

echo -e "========== 安装 vim =========="
yum install vim -y

echo -e "========== 安装 lrzsz =========="
yum install lrzsz -y

echo -e "========== 安装 zip =========="
yum install zip -y

echo -e "========== 安装 unzip =========="
yum install unzip -y

echo -e "========== 安装 net-tools =========="
yum install net-tools -y

echo -e "========== 安装 telnet =========="
yum install telnet -y

echo -e "========== 安装 perl =========="
yum install perl -y

echo -e "========== 同步系统时间 =========="
yum info ntp && ntpdate cn.ntp.org.cn

echo -e "========== DNS 域名配置 =========="
sleep 1
echo "192.168.20.100 CentOS-7.6-64" >> /etc/hosts
echo "192.168.20.101 clone01" >> /etc/hosts
echo "192.168.20.102 clone02" >> /etc/hosts
echo "192.168.20.103 clone03" >> /etc/hosts

echo -e "========== 安装 JDK =========="
sleep 1
rpm -ivh jdk-8u231-linux-x64.rpm
echo "export JAVA_HOME=/usr/java/jdk1.8.0_231-amd64" >> /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
source /etc/profile

echo -e "========== 安装 Tomcat =========="
sleep 1
tar -zxf apache-tomcat-8.5.47.tar.gz
mv apache-tomcat-8.5.47 /opt/initEnv/

echo -e "========== 安装 Mysql =========="
sleep 1
rpm -e --nodeps `rpm -qa | grep mariadb`
tar -xvf mysql-5.7.28-1.e17.x86_64.rpm-bundle.tar
rpm -ivh mysql-community-common-5.7.28-1.e17.x86_64.rpm
rpm -ivh mysql-community-libs-5.7.28-1.e17.x86_64.rpm
rpm -ivh mysql-community-client-5.7.28-1.e17.x86_64.rpm
rpm -ivh mysql-community-server-5.7.28-1.e17.x86_64.rpm

systemctl start mysqld
systemctl enable mysqld

tempPasswd=`grep "A temporary password" /var/log/mysqld.log | awk '{ print $NF }'`

mysql -uroot -p $tempPasswd --connect-expired-password << EOF
set global validate_password_policy=low;
set global validate_password_length=6;
alter user root@localhost identified by '123456';

use mysql;
update user set host='%' where user='root';
commit;
quit
EOF

systemctl restart mysqld

echo -e "========== 设置开机启动项 =========="
sleep 1
touch /usr/local/scripts/auto_ntpdate.sh
echo "#! /bin/bash" >> /usr/local/scripts/auto_ntpdate.sh
echo "yum info ntp && ntpdate cn.ntp.org.cn" >> /usr/local/scripts/auto_ntpdate.sh
chmod u+x /usr/local/scripts/auto_ntpdate.sh
echo "/usr/local/scripts/auto_ntpdate.sh" >> /etc/rc.local
chmod u+x /etc/rc.local

echo -e "========== 设置定时任务自动更新时间 =========="
sleep 1

echo -e "========== 删除文件 =========="
sleep 1
rm -rf apache-tomcat-8.5.47.tar.gz
rm -rf jdk-8u231-linux-x64.rpm
rm -rf mysql*
rm -rf *.sh

echo -e "========== 关闭系统，拍摄快照 =========="
sleep 1
shutdown -h now
```

#### 虚拟机相互免密钥

```shell
# 三台主机分别生成秘钥
【123】ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

# host 验证
【123】vim /etc/ssh/ssh_config 在最后添加

StrictHostKeyChecking no
UserKnownHostsFile /dev/null

# 将秘钥分别拷贝给自己和其他主机
【123】 ssh-copy-id -i ~/.ssh/id_rsa.pub root@xxx01
【123】 ssh-copy-id -i ~/.ssh/id_rsa.pub root@xxx02
【123】 ssh-copy-id -i ~/.ssh/id_rsa.pub root@xxx03


# 关闭主机拍摄快照
poweroff
```

