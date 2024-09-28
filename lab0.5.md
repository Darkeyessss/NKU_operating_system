<h1><center>lab0.5实验报告</center></h1>

## 练习1: 使用GDB验证启动流程
#### 文件：entry.S init.c

为了熟悉使用qemu和gdb进行调试工作,使用gdb调试QEMU模拟的RISC-V计算机加电开始运行到执行应用程序的第一条指令（即跳转到0x80200000）这个阶段的执行过程，说明RISC-V硬件加电后的几条指令在哪里？完成了哪些功能？要求在报告中简要写出练习过程和回答。

lab0我们需要两个中断，其中一个在lab0目录下使用`make debug`进行调试，另一个使用`make gdb`调试。

输入指令`x/10i $pc `查看即将执行的10条汇编指令：

```assembly
(gdb) x/10i $pc
=> 0x1000:      auipc   t0,0x0
   0x1004:      addi    a1,t0,32
   0x1008:      csrr    a0,mhartid
   0x100c:      ld      t0,24(t0)
   0x1010:      jr      t0
   0x1014:      unimp
   0x1016:      unimp
   0x1018:      unimp
   0x101a:      0x8000
   0x101c:      unimp
```

其中`0x1010: jr t0`这个指令会将程序跳转到地址`0x80000000`，
接下来我们输入x/10i 0x80000000，显示0x80000000处的10条数据。0x80000000是bootloader的地址，用于加载操作系统内核并启动操作系统的执行。代码如下：

接着输入指令`break 0x80200000`，0x80200000是函数`kern_entry`的第一条指令的地址，`kern_entry`是操作系统第一个程序的入口点，我们在此处设置断点，输出如下：

```assembly
Breakpoint 1 at 0x80200000: file kern/init/entry.S, line 7.
```

`kernel_entry`只执行两条指令，如下所示：

+  `la sp, bootstacktop`：将`bootstacktop`的地址赋给`sp`，作为栈
+ `tail kern_init`：尾调用，调用函数`kern_init`

`bootstacktop`是赋给操作系统的栈顶标签，`kernel_entry`会初始化操作系统的栈。分配完操作系统的栈后，程序会进入`kern_init`

将程序执行完毕后，debug的中断会有输出如下：

```
OpenSBI v0.4 (Jul  2 2019 11:53:53)
   ____                    _____ ____ _____
  / __ \                  / ____|  _ \_   _|
 | |  | |_ __   ___ _ __ | (___ | |_) || |
 | |  | | '_ \ / _ \ '_ \ \___ \|  _ < | |
 | |__| | |_) |  __/ | | |____) | |_) || |_
  \____/| .__/ \___|_| |_|_____/|____/_____|
        | |
        |_|

Platform Name          : QEMU Virt Machine
Platform HART Features : RV64ACDFIMSU
Platform Max HARTs     : 8
Current Hart           : 0
Firmware Base          : 0x80000000
Firmware Size          : 112 KB
Runtime SBI Version    : 0.1

PMP0: 0x0000000080000000-0x000000008001ffff (A)
PMP1: 0x0000000000000000-0xffffffffffffffff (A,R,W,X)
```

输入`continue`，debug窗口出现以下输出：

```
(THU.CST) os is loading ...

```

#### 实验知识点
+ 程序执行流程：加电，从`0x1000`开始执行->跳转到`0x80000000`，启动`OpenSBI`->跳转到`0x80200000`，运行`kern_entry`(`kern/init/entry.S`)->进入`kern_init()`函数(`kern_init/init.c`)->调用`cprintf()`输出一行信息->进入循环
+ `kernel.ld`的链接
+ `entry.S`的含义（内存布局）
