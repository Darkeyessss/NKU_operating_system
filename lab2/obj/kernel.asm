
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	ff650513          	addi	a0,a0,-10 # ffffffffc0206028 <free_area>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	54660613          	addi	a2,a2,1350 # ffffffffc0206580 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	7cc010ef          	jal	ra,ffffffffc0201816 <memset>
    cons_init();  // init the console
ffffffffc020004e:	404000ef          	jal	ra,ffffffffc0200452 <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	7d650513          	addi	a0,a0,2006 # ffffffffc0201828 <etext>
ffffffffc020005a:	098000ef          	jal	ra,ffffffffc02000f2 <cputs>

    print_kerninfo();
ffffffffc020005e:	0e4000ef          	jal	ra,ffffffffc0200142 <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	40a000ef          	jal	ra,ffffffffc020046c <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	5eb000ef          	jal	ra,ffffffffc0200e50 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	402000ef          	jal	ra,ffffffffc020046c <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	3a2000ef          	jal	ra,ffffffffc0200410 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3ee000ef          	jal	ra,ffffffffc0200460 <intr_enable>

    slub_init();
ffffffffc0200076:	106010ef          	jal	ra,ffffffffc020117c <slub_init>
    slub_check();
ffffffffc020007a:	162010ef          	jal	ra,ffffffffc02011dc <slub_check>

    /* do nothing */
    while (1)
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	3cc000ef          	jal	ra,ffffffffc0200454 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	292010ef          	jal	ra,ffffffffc0201340 <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	25c010ef          	jal	ra,ffffffffc0201340 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	a695                	j	ffffffffc0200454 <cons_putc>

ffffffffc02000f2 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000f2:	1101                	addi	sp,sp,-32
ffffffffc02000f4:	e822                	sd	s0,16(sp)
ffffffffc02000f6:	ec06                	sd	ra,24(sp)
ffffffffc02000f8:	e426                	sd	s1,8(sp)
ffffffffc02000fa:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000fc:	00054503          	lbu	a0,0(a0)
ffffffffc0200100:	c51d                	beqz	a0,ffffffffc020012e <cputs+0x3c>
ffffffffc0200102:	0405                	addi	s0,s0,1
ffffffffc0200104:	4485                	li	s1,1
ffffffffc0200106:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200108:	34c000ef          	jal	ra,ffffffffc0200454 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020010c:	00044503          	lbu	a0,0(s0)
ffffffffc0200110:	008487bb          	addw	a5,s1,s0
ffffffffc0200114:	0405                	addi	s0,s0,1
ffffffffc0200116:	f96d                	bnez	a0,ffffffffc0200108 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200118:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc020011c:	4529                	li	a0,10
ffffffffc020011e:	336000ef          	jal	ra,ffffffffc0200454 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200122:	60e2                	ld	ra,24(sp)
ffffffffc0200124:	8522                	mv	a0,s0
ffffffffc0200126:	6442                	ld	s0,16(sp)
ffffffffc0200128:	64a2                	ld	s1,8(sp)
ffffffffc020012a:	6105                	addi	sp,sp,32
ffffffffc020012c:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc020012e:	4405                	li	s0,1
ffffffffc0200130:	b7f5                	j	ffffffffc020011c <cputs+0x2a>

ffffffffc0200132 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200132:	1141                	addi	sp,sp,-16
ffffffffc0200134:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200136:	326000ef          	jal	ra,ffffffffc020045c <cons_getc>
ffffffffc020013a:	dd75                	beqz	a0,ffffffffc0200136 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020013c:	60a2                	ld	ra,8(sp)
ffffffffc020013e:	0141                	addi	sp,sp,16
ffffffffc0200140:	8082                	ret

ffffffffc0200142 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200142:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200144:	00001517          	auipc	a0,0x1
ffffffffc0200148:	70450513          	addi	a0,a0,1796 # ffffffffc0201848 <etext+0x20>
void print_kerninfo(void) {
ffffffffc020014c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020014e:	f6dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc0200152:	00000597          	auipc	a1,0x0
ffffffffc0200156:	ee058593          	addi	a1,a1,-288 # ffffffffc0200032 <kern_init>
ffffffffc020015a:	00001517          	auipc	a0,0x1
ffffffffc020015e:	70e50513          	addi	a0,a0,1806 # ffffffffc0201868 <etext+0x40>
ffffffffc0200162:	f59ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200166:	00001597          	auipc	a1,0x1
ffffffffc020016a:	6c258593          	addi	a1,a1,1730 # ffffffffc0201828 <etext>
ffffffffc020016e:	00001517          	auipc	a0,0x1
ffffffffc0200172:	71a50513          	addi	a0,a0,1818 # ffffffffc0201888 <etext+0x60>
ffffffffc0200176:	f45ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc020017a:	00006597          	auipc	a1,0x6
ffffffffc020017e:	eae58593          	addi	a1,a1,-338 # ffffffffc0206028 <free_area>
ffffffffc0200182:	00001517          	auipc	a0,0x1
ffffffffc0200186:	72650513          	addi	a0,a0,1830 # ffffffffc02018a8 <etext+0x80>
ffffffffc020018a:	f31ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc020018e:	00006597          	auipc	a1,0x6
ffffffffc0200192:	3f258593          	addi	a1,a1,1010 # ffffffffc0206580 <end>
ffffffffc0200196:	00001517          	auipc	a0,0x1
ffffffffc020019a:	73250513          	addi	a0,a0,1842 # ffffffffc02018c8 <etext+0xa0>
ffffffffc020019e:	f1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001a2:	00006597          	auipc	a1,0x6
ffffffffc02001a6:	7dd58593          	addi	a1,a1,2013 # ffffffffc020697f <end+0x3ff>
ffffffffc02001aa:	00000797          	auipc	a5,0x0
ffffffffc02001ae:	e8878793          	addi	a5,a5,-376 # ffffffffc0200032 <kern_init>
ffffffffc02001b2:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b6:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001ba:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001bc:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001c0:	95be                	add	a1,a1,a5
ffffffffc02001c2:	85a9                	srai	a1,a1,0xa
ffffffffc02001c4:	00001517          	auipc	a0,0x1
ffffffffc02001c8:	72450513          	addi	a0,a0,1828 # ffffffffc02018e8 <etext+0xc0>
}
ffffffffc02001cc:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ce:	b5f5                	j	ffffffffc02000ba <cprintf>

ffffffffc02001d0 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001d0:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001d2:	00001617          	auipc	a2,0x1
ffffffffc02001d6:	74660613          	addi	a2,a2,1862 # ffffffffc0201918 <etext+0xf0>
ffffffffc02001da:	04e00593          	li	a1,78
ffffffffc02001de:	00001517          	auipc	a0,0x1
ffffffffc02001e2:	75250513          	addi	a0,a0,1874 # ffffffffc0201930 <etext+0x108>
void print_stackframe(void) {
ffffffffc02001e6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e8:	1cc000ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc02001ec <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ec:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ee:	00001617          	auipc	a2,0x1
ffffffffc02001f2:	75a60613          	addi	a2,a2,1882 # ffffffffc0201948 <etext+0x120>
ffffffffc02001f6:	00001597          	auipc	a1,0x1
ffffffffc02001fa:	77258593          	addi	a1,a1,1906 # ffffffffc0201968 <etext+0x140>
ffffffffc02001fe:	00001517          	auipc	a0,0x1
ffffffffc0200202:	77250513          	addi	a0,a0,1906 # ffffffffc0201970 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200206:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200208:	eb3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc020020c:	00001617          	auipc	a2,0x1
ffffffffc0200210:	77460613          	addi	a2,a2,1908 # ffffffffc0201980 <etext+0x158>
ffffffffc0200214:	00001597          	auipc	a1,0x1
ffffffffc0200218:	79458593          	addi	a1,a1,1940 # ffffffffc02019a8 <etext+0x180>
ffffffffc020021c:	00001517          	auipc	a0,0x1
ffffffffc0200220:	75450513          	addi	a0,a0,1876 # ffffffffc0201970 <etext+0x148>
ffffffffc0200224:	e97ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200228:	00001617          	auipc	a2,0x1
ffffffffc020022c:	79060613          	addi	a2,a2,1936 # ffffffffc02019b8 <etext+0x190>
ffffffffc0200230:	00001597          	auipc	a1,0x1
ffffffffc0200234:	7a858593          	addi	a1,a1,1960 # ffffffffc02019d8 <etext+0x1b0>
ffffffffc0200238:	00001517          	auipc	a0,0x1
ffffffffc020023c:	73850513          	addi	a0,a0,1848 # ffffffffc0201970 <etext+0x148>
ffffffffc0200240:	e7bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200244:	60a2                	ld	ra,8(sp)
ffffffffc0200246:	4501                	li	a0,0
ffffffffc0200248:	0141                	addi	sp,sp,16
ffffffffc020024a:	8082                	ret

ffffffffc020024c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020024c:	1141                	addi	sp,sp,-16
ffffffffc020024e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200250:	ef3ff0ef          	jal	ra,ffffffffc0200142 <print_kerninfo>
    return 0;
}
ffffffffc0200254:	60a2                	ld	ra,8(sp)
ffffffffc0200256:	4501                	li	a0,0
ffffffffc0200258:	0141                	addi	sp,sp,16
ffffffffc020025a:	8082                	ret

ffffffffc020025c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020025c:	1141                	addi	sp,sp,-16
ffffffffc020025e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200260:	f71ff0ef          	jal	ra,ffffffffc02001d0 <print_stackframe>
    return 0;
}
ffffffffc0200264:	60a2                	ld	ra,8(sp)
ffffffffc0200266:	4501                	li	a0,0
ffffffffc0200268:	0141                	addi	sp,sp,16
ffffffffc020026a:	8082                	ret

ffffffffc020026c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020026c:	7115                	addi	sp,sp,-224
ffffffffc020026e:	ed5e                	sd	s7,152(sp)
ffffffffc0200270:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200272:	00001517          	auipc	a0,0x1
ffffffffc0200276:	77650513          	addi	a0,a0,1910 # ffffffffc02019e8 <etext+0x1c0>
kmonitor(struct trapframe *tf) {
ffffffffc020027a:	ed86                	sd	ra,216(sp)
ffffffffc020027c:	e9a2                	sd	s0,208(sp)
ffffffffc020027e:	e5a6                	sd	s1,200(sp)
ffffffffc0200280:	e1ca                	sd	s2,192(sp)
ffffffffc0200282:	fd4e                	sd	s3,184(sp)
ffffffffc0200284:	f952                	sd	s4,176(sp)
ffffffffc0200286:	f556                	sd	s5,168(sp)
ffffffffc0200288:	f15a                	sd	s6,160(sp)
ffffffffc020028a:	e962                	sd	s8,144(sp)
ffffffffc020028c:	e566                	sd	s9,136(sp)
ffffffffc020028e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200290:	e2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200294:	00001517          	auipc	a0,0x1
ffffffffc0200298:	77c50513          	addi	a0,a0,1916 # ffffffffc0201a10 <etext+0x1e8>
ffffffffc020029c:	e1fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc02002a0:	000b8563          	beqz	s7,ffffffffc02002aa <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc02002a4:	855e                	mv	a0,s7
ffffffffc02002a6:	3a4000ef          	jal	ra,ffffffffc020064a <print_trapframe>
ffffffffc02002aa:	00001c17          	auipc	s8,0x1
ffffffffc02002ae:	7d6c0c13          	addi	s8,s8,2006 # ffffffffc0201a80 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002b2:	00001917          	auipc	s2,0x1
ffffffffc02002b6:	78690913          	addi	s2,s2,1926 # ffffffffc0201a38 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ba:	00001497          	auipc	s1,0x1
ffffffffc02002be:	78648493          	addi	s1,s1,1926 # ffffffffc0201a40 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002c2:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002c4:	00001b17          	auipc	s6,0x1
ffffffffc02002c8:	784b0b13          	addi	s6,s6,1924 # ffffffffc0201a48 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002cc:	00001a17          	auipc	s4,0x1
ffffffffc02002d0:	69ca0a13          	addi	s4,s4,1692 # ffffffffc0201968 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d4:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d6:	854a                	mv	a0,s2
ffffffffc02002d8:	3ea010ef          	jal	ra,ffffffffc02016c2 <readline>
ffffffffc02002dc:	842a                	mv	s0,a0
ffffffffc02002de:	dd65                	beqz	a0,ffffffffc02002d6 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002e4:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e6:	e1bd                	bnez	a1,ffffffffc020034c <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e8:	fe0c87e3          	beqz	s9,ffffffffc02002d6 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ec:	6582                	ld	a1,0(sp)
ffffffffc02002ee:	00001d17          	auipc	s10,0x1
ffffffffc02002f2:	792d0d13          	addi	s10,s10,1938 # ffffffffc0201a80 <commands>
        argv[argc ++] = buf;
ffffffffc02002f6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f8:	4401                	li	s0,0
ffffffffc02002fa:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002fc:	4e6010ef          	jal	ra,ffffffffc02017e2 <strcmp>
ffffffffc0200300:	c919                	beqz	a0,ffffffffc0200316 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200302:	2405                	addiw	s0,s0,1
ffffffffc0200304:	0b540063          	beq	s0,s5,ffffffffc02003a4 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	000d3503          	ld	a0,0(s10)
ffffffffc020030c:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020030e:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200310:	4d2010ef          	jal	ra,ffffffffc02017e2 <strcmp>
ffffffffc0200314:	f57d                	bnez	a0,ffffffffc0200302 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200316:	00141793          	slli	a5,s0,0x1
ffffffffc020031a:	97a2                	add	a5,a5,s0
ffffffffc020031c:	078e                	slli	a5,a5,0x3
ffffffffc020031e:	97e2                	add	a5,a5,s8
ffffffffc0200320:	6b9c                	ld	a5,16(a5)
ffffffffc0200322:	865e                	mv	a2,s7
ffffffffc0200324:	002c                	addi	a1,sp,8
ffffffffc0200326:	fffc851b          	addiw	a0,s9,-1
ffffffffc020032a:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc020032c:	fa0555e3          	bgez	a0,ffffffffc02002d6 <kmonitor+0x6a>
}
ffffffffc0200330:	60ee                	ld	ra,216(sp)
ffffffffc0200332:	644e                	ld	s0,208(sp)
ffffffffc0200334:	64ae                	ld	s1,200(sp)
ffffffffc0200336:	690e                	ld	s2,192(sp)
ffffffffc0200338:	79ea                	ld	s3,184(sp)
ffffffffc020033a:	7a4a                	ld	s4,176(sp)
ffffffffc020033c:	7aaa                	ld	s5,168(sp)
ffffffffc020033e:	7b0a                	ld	s6,160(sp)
ffffffffc0200340:	6bea                	ld	s7,152(sp)
ffffffffc0200342:	6c4a                	ld	s8,144(sp)
ffffffffc0200344:	6caa                	ld	s9,136(sp)
ffffffffc0200346:	6d0a                	ld	s10,128(sp)
ffffffffc0200348:	612d                	addi	sp,sp,224
ffffffffc020034a:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020034c:	8526                	mv	a0,s1
ffffffffc020034e:	4b2010ef          	jal	ra,ffffffffc0201800 <strchr>
ffffffffc0200352:	c901                	beqz	a0,ffffffffc0200362 <kmonitor+0xf6>
ffffffffc0200354:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200358:	00040023          	sb	zero,0(s0)
ffffffffc020035c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020035e:	d5c9                	beqz	a1,ffffffffc02002e8 <kmonitor+0x7c>
ffffffffc0200360:	b7f5                	j	ffffffffc020034c <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200362:	00044783          	lbu	a5,0(s0)
ffffffffc0200366:	d3c9                	beqz	a5,ffffffffc02002e8 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200368:	033c8963          	beq	s9,s3,ffffffffc020039a <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc020036c:	003c9793          	slli	a5,s9,0x3
ffffffffc0200370:	0118                	addi	a4,sp,128
ffffffffc0200372:	97ba                	add	a5,a5,a4
ffffffffc0200374:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200378:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020037c:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037e:	e591                	bnez	a1,ffffffffc020038a <kmonitor+0x11e>
ffffffffc0200380:	b7b5                	j	ffffffffc02002ec <kmonitor+0x80>
ffffffffc0200382:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200386:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200388:	d1a5                	beqz	a1,ffffffffc02002e8 <kmonitor+0x7c>
ffffffffc020038a:	8526                	mv	a0,s1
ffffffffc020038c:	474010ef          	jal	ra,ffffffffc0201800 <strchr>
ffffffffc0200390:	d96d                	beqz	a0,ffffffffc0200382 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200392:	00044583          	lbu	a1,0(s0)
ffffffffc0200396:	d9a9                	beqz	a1,ffffffffc02002e8 <kmonitor+0x7c>
ffffffffc0200398:	bf55                	j	ffffffffc020034c <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020039a:	45c1                	li	a1,16
ffffffffc020039c:	855a                	mv	a0,s6
ffffffffc020039e:	d1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02003a2:	b7e9                	j	ffffffffc020036c <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003a4:	6582                	ld	a1,0(sp)
ffffffffc02003a6:	00001517          	auipc	a0,0x1
ffffffffc02003aa:	6c250513          	addi	a0,a0,1730 # ffffffffc0201a68 <etext+0x240>
ffffffffc02003ae:	d0dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc02003b2:	b715                	j	ffffffffc02002d6 <kmonitor+0x6a>

ffffffffc02003b4 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003b4:	00006317          	auipc	t1,0x6
ffffffffc02003b8:	17c30313          	addi	t1,t1,380 # ffffffffc0206530 <is_panic>
ffffffffc02003bc:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003c0:	715d                	addi	sp,sp,-80
ffffffffc02003c2:	ec06                	sd	ra,24(sp)
ffffffffc02003c4:	e822                	sd	s0,16(sp)
ffffffffc02003c6:	f436                	sd	a3,40(sp)
ffffffffc02003c8:	f83a                	sd	a4,48(sp)
ffffffffc02003ca:	fc3e                	sd	a5,56(sp)
ffffffffc02003cc:	e0c2                	sd	a6,64(sp)
ffffffffc02003ce:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003d0:	020e1a63          	bnez	t3,ffffffffc0200404 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003d4:	4785                	li	a5,1
ffffffffc02003d6:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003da:	8432                	mv	s0,a2
ffffffffc02003dc:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003de:	862e                	mv	a2,a1
ffffffffc02003e0:	85aa                	mv	a1,a0
ffffffffc02003e2:	00001517          	auipc	a0,0x1
ffffffffc02003e6:	6e650513          	addi	a0,a0,1766 # ffffffffc0201ac8 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003ea:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ec:	ccfff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003f0:	65a2                	ld	a1,8(sp)
ffffffffc02003f2:	8522                	mv	a0,s0
ffffffffc02003f4:	ca7ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003f8:	00001517          	auipc	a0,0x1
ffffffffc02003fc:	51850513          	addi	a0,a0,1304 # ffffffffc0201910 <etext+0xe8>
ffffffffc0200400:	cbbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200404:	062000ef          	jal	ra,ffffffffc0200466 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200408:	4501                	li	a0,0
ffffffffc020040a:	e63ff0ef          	jal	ra,ffffffffc020026c <kmonitor>
    while (1) {
ffffffffc020040e:	bfed                	j	ffffffffc0200408 <__panic+0x54>

ffffffffc0200410 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200410:	1141                	addi	sp,sp,-16
ffffffffc0200412:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200414:	02000793          	li	a5,32
ffffffffc0200418:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020041c:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200420:	67e1                	lui	a5,0x18
ffffffffc0200422:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200426:	953e                	add	a0,a0,a5
ffffffffc0200428:	368010ef          	jal	ra,ffffffffc0201790 <sbi_set_timer>
}
ffffffffc020042c:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020042e:	00006797          	auipc	a5,0x6
ffffffffc0200432:	1007b523          	sd	zero,266(a5) # ffffffffc0206538 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200436:	00001517          	auipc	a0,0x1
ffffffffc020043a:	6b250513          	addi	a0,a0,1714 # ffffffffc0201ae8 <commands+0x68>
}
ffffffffc020043e:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200440:	b9ad                	j	ffffffffc02000ba <cprintf>

ffffffffc0200442 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200442:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200446:	67e1                	lui	a5,0x18
ffffffffc0200448:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020044c:	953e                	add	a0,a0,a5
ffffffffc020044e:	3420106f          	j	ffffffffc0201790 <sbi_set_timer>

ffffffffc0200452 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200452:	8082                	ret

ffffffffc0200454 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200454:	0ff57513          	zext.b	a0,a0
ffffffffc0200458:	31e0106f          	j	ffffffffc0201776 <sbi_console_putchar>

ffffffffc020045c <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc020045c:	34e0106f          	j	ffffffffc02017aa <sbi_console_getchar>

ffffffffc0200460 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200460:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200464:	8082                	ret

ffffffffc0200466 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200466:	100177f3          	csrrci	a5,sstatus,2
ffffffffc020046a:	8082                	ret

ffffffffc020046c <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020046c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200470:	00000797          	auipc	a5,0x0
ffffffffc0200474:	2e478793          	addi	a5,a5,740 # ffffffffc0200754 <__alltraps>
ffffffffc0200478:	10579073          	csrw	stvec,a5
}
ffffffffc020047c:	8082                	ret

ffffffffc020047e <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200480:	1141                	addi	sp,sp,-16
ffffffffc0200482:	e022                	sd	s0,0(sp)
ffffffffc0200484:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200486:	00001517          	auipc	a0,0x1
ffffffffc020048a:	68250513          	addi	a0,a0,1666 # ffffffffc0201b08 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc020048e:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200490:	c2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200494:	640c                	ld	a1,8(s0)
ffffffffc0200496:	00001517          	auipc	a0,0x1
ffffffffc020049a:	68a50513          	addi	a0,a0,1674 # ffffffffc0201b20 <commands+0xa0>
ffffffffc020049e:	c1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02004a2:	680c                	ld	a1,16(s0)
ffffffffc02004a4:	00001517          	auipc	a0,0x1
ffffffffc02004a8:	69450513          	addi	a0,a0,1684 # ffffffffc0201b38 <commands+0xb8>
ffffffffc02004ac:	c0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004b0:	6c0c                	ld	a1,24(s0)
ffffffffc02004b2:	00001517          	auipc	a0,0x1
ffffffffc02004b6:	69e50513          	addi	a0,a0,1694 # ffffffffc0201b50 <commands+0xd0>
ffffffffc02004ba:	c01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004be:	700c                	ld	a1,32(s0)
ffffffffc02004c0:	00001517          	auipc	a0,0x1
ffffffffc02004c4:	6a850513          	addi	a0,a0,1704 # ffffffffc0201b68 <commands+0xe8>
ffffffffc02004c8:	bf3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004cc:	740c                	ld	a1,40(s0)
ffffffffc02004ce:	00001517          	auipc	a0,0x1
ffffffffc02004d2:	6b250513          	addi	a0,a0,1714 # ffffffffc0201b80 <commands+0x100>
ffffffffc02004d6:	be5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004da:	780c                	ld	a1,48(s0)
ffffffffc02004dc:	00001517          	auipc	a0,0x1
ffffffffc02004e0:	6bc50513          	addi	a0,a0,1724 # ffffffffc0201b98 <commands+0x118>
ffffffffc02004e4:	bd7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e8:	7c0c                	ld	a1,56(s0)
ffffffffc02004ea:	00001517          	auipc	a0,0x1
ffffffffc02004ee:	6c650513          	addi	a0,a0,1734 # ffffffffc0201bb0 <commands+0x130>
ffffffffc02004f2:	bc9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004f6:	602c                	ld	a1,64(s0)
ffffffffc02004f8:	00001517          	auipc	a0,0x1
ffffffffc02004fc:	6d050513          	addi	a0,a0,1744 # ffffffffc0201bc8 <commands+0x148>
ffffffffc0200500:	bbbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200504:	642c                	ld	a1,72(s0)
ffffffffc0200506:	00001517          	auipc	a0,0x1
ffffffffc020050a:	6da50513          	addi	a0,a0,1754 # ffffffffc0201be0 <commands+0x160>
ffffffffc020050e:	badff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200512:	682c                	ld	a1,80(s0)
ffffffffc0200514:	00001517          	auipc	a0,0x1
ffffffffc0200518:	6e450513          	addi	a0,a0,1764 # ffffffffc0201bf8 <commands+0x178>
ffffffffc020051c:	b9fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200520:	6c2c                	ld	a1,88(s0)
ffffffffc0200522:	00001517          	auipc	a0,0x1
ffffffffc0200526:	6ee50513          	addi	a0,a0,1774 # ffffffffc0201c10 <commands+0x190>
ffffffffc020052a:	b91ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc020052e:	702c                	ld	a1,96(s0)
ffffffffc0200530:	00001517          	auipc	a0,0x1
ffffffffc0200534:	6f850513          	addi	a0,a0,1784 # ffffffffc0201c28 <commands+0x1a8>
ffffffffc0200538:	b83ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020053c:	742c                	ld	a1,104(s0)
ffffffffc020053e:	00001517          	auipc	a0,0x1
ffffffffc0200542:	70250513          	addi	a0,a0,1794 # ffffffffc0201c40 <commands+0x1c0>
ffffffffc0200546:	b75ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020054a:	782c                	ld	a1,112(s0)
ffffffffc020054c:	00001517          	auipc	a0,0x1
ffffffffc0200550:	70c50513          	addi	a0,a0,1804 # ffffffffc0201c58 <commands+0x1d8>
ffffffffc0200554:	b67ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200558:	7c2c                	ld	a1,120(s0)
ffffffffc020055a:	00001517          	auipc	a0,0x1
ffffffffc020055e:	71650513          	addi	a0,a0,1814 # ffffffffc0201c70 <commands+0x1f0>
ffffffffc0200562:	b59ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200566:	604c                	ld	a1,128(s0)
ffffffffc0200568:	00001517          	auipc	a0,0x1
ffffffffc020056c:	72050513          	addi	a0,a0,1824 # ffffffffc0201c88 <commands+0x208>
ffffffffc0200570:	b4bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200574:	644c                	ld	a1,136(s0)
ffffffffc0200576:	00001517          	auipc	a0,0x1
ffffffffc020057a:	72a50513          	addi	a0,a0,1834 # ffffffffc0201ca0 <commands+0x220>
ffffffffc020057e:	b3dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200582:	684c                	ld	a1,144(s0)
ffffffffc0200584:	00001517          	auipc	a0,0x1
ffffffffc0200588:	73450513          	addi	a0,a0,1844 # ffffffffc0201cb8 <commands+0x238>
ffffffffc020058c:	b2fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200590:	6c4c                	ld	a1,152(s0)
ffffffffc0200592:	00001517          	auipc	a0,0x1
ffffffffc0200596:	73e50513          	addi	a0,a0,1854 # ffffffffc0201cd0 <commands+0x250>
ffffffffc020059a:	b21ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc020059e:	704c                	ld	a1,160(s0)
ffffffffc02005a0:	00001517          	auipc	a0,0x1
ffffffffc02005a4:	74850513          	addi	a0,a0,1864 # ffffffffc0201ce8 <commands+0x268>
ffffffffc02005a8:	b13ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005ac:	744c                	ld	a1,168(s0)
ffffffffc02005ae:	00001517          	auipc	a0,0x1
ffffffffc02005b2:	75250513          	addi	a0,a0,1874 # ffffffffc0201d00 <commands+0x280>
ffffffffc02005b6:	b05ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005ba:	784c                	ld	a1,176(s0)
ffffffffc02005bc:	00001517          	auipc	a0,0x1
ffffffffc02005c0:	75c50513          	addi	a0,a0,1884 # ffffffffc0201d18 <commands+0x298>
ffffffffc02005c4:	af7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c8:	7c4c                	ld	a1,184(s0)
ffffffffc02005ca:	00001517          	auipc	a0,0x1
ffffffffc02005ce:	76650513          	addi	a0,a0,1894 # ffffffffc0201d30 <commands+0x2b0>
ffffffffc02005d2:	ae9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005d6:	606c                	ld	a1,192(s0)
ffffffffc02005d8:	00001517          	auipc	a0,0x1
ffffffffc02005dc:	77050513          	addi	a0,a0,1904 # ffffffffc0201d48 <commands+0x2c8>
ffffffffc02005e0:	adbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005e4:	646c                	ld	a1,200(s0)
ffffffffc02005e6:	00001517          	auipc	a0,0x1
ffffffffc02005ea:	77a50513          	addi	a0,a0,1914 # ffffffffc0201d60 <commands+0x2e0>
ffffffffc02005ee:	acdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005f2:	686c                	ld	a1,208(s0)
ffffffffc02005f4:	00001517          	auipc	a0,0x1
ffffffffc02005f8:	78450513          	addi	a0,a0,1924 # ffffffffc0201d78 <commands+0x2f8>
ffffffffc02005fc:	abfff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200600:	6c6c                	ld	a1,216(s0)
ffffffffc0200602:	00001517          	auipc	a0,0x1
ffffffffc0200606:	78e50513          	addi	a0,a0,1934 # ffffffffc0201d90 <commands+0x310>
ffffffffc020060a:	ab1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc020060e:	706c                	ld	a1,224(s0)
ffffffffc0200610:	00001517          	auipc	a0,0x1
ffffffffc0200614:	79850513          	addi	a0,a0,1944 # ffffffffc0201da8 <commands+0x328>
ffffffffc0200618:	aa3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020061c:	746c                	ld	a1,232(s0)
ffffffffc020061e:	00001517          	auipc	a0,0x1
ffffffffc0200622:	7a250513          	addi	a0,a0,1954 # ffffffffc0201dc0 <commands+0x340>
ffffffffc0200626:	a95ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020062a:	786c                	ld	a1,240(s0)
ffffffffc020062c:	00001517          	auipc	a0,0x1
ffffffffc0200630:	7ac50513          	addi	a0,a0,1964 # ffffffffc0201dd8 <commands+0x358>
ffffffffc0200634:	a87ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200638:	7c6c                	ld	a1,248(s0)
}
ffffffffc020063a:	6402                	ld	s0,0(sp)
ffffffffc020063c:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020063e:	00001517          	auipc	a0,0x1
ffffffffc0200642:	7b250513          	addi	a0,a0,1970 # ffffffffc0201df0 <commands+0x370>
}
ffffffffc0200646:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200648:	bc8d                	j	ffffffffc02000ba <cprintf>

ffffffffc020064a <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020064a:	1141                	addi	sp,sp,-16
ffffffffc020064c:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020064e:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200650:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200652:	00001517          	auipc	a0,0x1
ffffffffc0200656:	7b650513          	addi	a0,a0,1974 # ffffffffc0201e08 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc020065a:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc020065c:	a5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200660:	8522                	mv	a0,s0
ffffffffc0200662:	e1dff0ef          	jal	ra,ffffffffc020047e <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200666:	10043583          	ld	a1,256(s0)
ffffffffc020066a:	00001517          	auipc	a0,0x1
ffffffffc020066e:	7b650513          	addi	a0,a0,1974 # ffffffffc0201e20 <commands+0x3a0>
ffffffffc0200672:	a49ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200676:	10843583          	ld	a1,264(s0)
ffffffffc020067a:	00001517          	auipc	a0,0x1
ffffffffc020067e:	7be50513          	addi	a0,a0,1982 # ffffffffc0201e38 <commands+0x3b8>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200686:	11043583          	ld	a1,272(s0)
ffffffffc020068a:	00001517          	auipc	a0,0x1
ffffffffc020068e:	7c650513          	addi	a0,a0,1990 # ffffffffc0201e50 <commands+0x3d0>
ffffffffc0200692:	a29ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	11843583          	ld	a1,280(s0)
}
ffffffffc020069a:	6402                	ld	s0,0(sp)
ffffffffc020069c:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020069e:	00001517          	auipc	a0,0x1
ffffffffc02006a2:	7ca50513          	addi	a0,a0,1994 # ffffffffc0201e68 <commands+0x3e8>
}
ffffffffc02006a6:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a8:	bc09                	j	ffffffffc02000ba <cprintf>

ffffffffc02006aa <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006aa:	11853783          	ld	a5,280(a0)
ffffffffc02006ae:	472d                	li	a4,11
ffffffffc02006b0:	0786                	slli	a5,a5,0x1
ffffffffc02006b2:	8385                	srli	a5,a5,0x1
ffffffffc02006b4:	06f76d63          	bltu	a4,a5,ffffffffc020072e <interrupt_handler+0x84>
ffffffffc02006b8:	00002717          	auipc	a4,0x2
ffffffffc02006bc:	89070713          	addi	a4,a4,-1904 # ffffffffc0201f48 <commands+0x4c8>
ffffffffc02006c0:	078a                	slli	a5,a5,0x2
ffffffffc02006c2:	97ba                	add	a5,a5,a4
ffffffffc02006c4:	439c                	lw	a5,0(a5)
ffffffffc02006c6:	97ba                	add	a5,a5,a4
ffffffffc02006c8:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006ca:	00002517          	auipc	a0,0x2
ffffffffc02006ce:	81650513          	addi	a0,a0,-2026 # ffffffffc0201ee0 <commands+0x460>
ffffffffc02006d2:	b2e5                	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006d4:	00001517          	auipc	a0,0x1
ffffffffc02006d8:	7ec50513          	addi	a0,a0,2028 # ffffffffc0201ec0 <commands+0x440>
ffffffffc02006dc:	baf9                	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006de:	00001517          	auipc	a0,0x1
ffffffffc02006e2:	7a250513          	addi	a0,a0,1954 # ffffffffc0201e80 <commands+0x400>
ffffffffc02006e6:	bad1                	j	ffffffffc02000ba <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e8:	00002517          	auipc	a0,0x2
ffffffffc02006ec:	81850513          	addi	a0,a0,-2024 # ffffffffc0201f00 <commands+0x480>
ffffffffc02006f0:	b2e9                	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006f2:	1141                	addi	sp,sp,-16
ffffffffc02006f4:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006f6:	d4dff0ef          	jal	ra,ffffffffc0200442 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006fa:	00006717          	auipc	a4,0x6
ffffffffc02006fe:	e3e70713          	addi	a4,a4,-450 # ffffffffc0206538 <ticks>
ffffffffc0200702:	631c                	ld	a5,0(a4)
ffffffffc0200704:	6589                	lui	a1,0x2
ffffffffc0200706:	71058593          	addi	a1,a1,1808 # 2710 <kern_entry-0xffffffffc01fd8f0>
ffffffffc020070a:	0785                	addi	a5,a5,1
ffffffffc020070c:	02b7f6b3          	remu	a3,a5,a1
ffffffffc0200710:	e31c                	sd	a5,0(a4)
ffffffffc0200712:	ce99                	beqz	a3,ffffffffc0200730 <interrupt_handler+0x86>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200714:	60a2                	ld	ra,8(sp)
ffffffffc0200716:	0141                	addi	sp,sp,16
ffffffffc0200718:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc020071a:	00002517          	auipc	a0,0x2
ffffffffc020071e:	80e50513          	addi	a0,a0,-2034 # ffffffffc0201f28 <commands+0x4a8>
ffffffffc0200722:	ba61                	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200724:	00001517          	auipc	a0,0x1
ffffffffc0200728:	77c50513          	addi	a0,a0,1916 # ffffffffc0201ea0 <commands+0x420>
ffffffffc020072c:	b279                	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc020072e:	bf31                	j	ffffffffc020064a <print_trapframe>
}
ffffffffc0200730:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200732:	00001517          	auipc	a0,0x1
ffffffffc0200736:	7e650513          	addi	a0,a0,2022 # ffffffffc0201f18 <commands+0x498>
}
ffffffffc020073a:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020073c:	babd                	j	ffffffffc02000ba <cprintf>

ffffffffc020073e <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020073e:	11853783          	ld	a5,280(a0)
ffffffffc0200742:	0007c763          	bltz	a5,ffffffffc0200750 <trap+0x12>
    switch (tf->cause) {
ffffffffc0200746:	472d                	li	a4,11
ffffffffc0200748:	00f76363          	bltu	a4,a5,ffffffffc020074e <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc020074c:	8082                	ret
            print_trapframe(tf);
ffffffffc020074e:	bdf5                	j	ffffffffc020064a <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200750:	bfa9                	j	ffffffffc02006aa <interrupt_handler>
	...

ffffffffc0200754 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200754:	14011073          	csrw	sscratch,sp
ffffffffc0200758:	712d                	addi	sp,sp,-288
ffffffffc020075a:	e002                	sd	zero,0(sp)
ffffffffc020075c:	e406                	sd	ra,8(sp)
ffffffffc020075e:	ec0e                	sd	gp,24(sp)
ffffffffc0200760:	f012                	sd	tp,32(sp)
ffffffffc0200762:	f416                	sd	t0,40(sp)
ffffffffc0200764:	f81a                	sd	t1,48(sp)
ffffffffc0200766:	fc1e                	sd	t2,56(sp)
ffffffffc0200768:	e0a2                	sd	s0,64(sp)
ffffffffc020076a:	e4a6                	sd	s1,72(sp)
ffffffffc020076c:	e8aa                	sd	a0,80(sp)
ffffffffc020076e:	ecae                	sd	a1,88(sp)
ffffffffc0200770:	f0b2                	sd	a2,96(sp)
ffffffffc0200772:	f4b6                	sd	a3,104(sp)
ffffffffc0200774:	f8ba                	sd	a4,112(sp)
ffffffffc0200776:	fcbe                	sd	a5,120(sp)
ffffffffc0200778:	e142                	sd	a6,128(sp)
ffffffffc020077a:	e546                	sd	a7,136(sp)
ffffffffc020077c:	e94a                	sd	s2,144(sp)
ffffffffc020077e:	ed4e                	sd	s3,152(sp)
ffffffffc0200780:	f152                	sd	s4,160(sp)
ffffffffc0200782:	f556                	sd	s5,168(sp)
ffffffffc0200784:	f95a                	sd	s6,176(sp)
ffffffffc0200786:	fd5e                	sd	s7,184(sp)
ffffffffc0200788:	e1e2                	sd	s8,192(sp)
ffffffffc020078a:	e5e6                	sd	s9,200(sp)
ffffffffc020078c:	e9ea                	sd	s10,208(sp)
ffffffffc020078e:	edee                	sd	s11,216(sp)
ffffffffc0200790:	f1f2                	sd	t3,224(sp)
ffffffffc0200792:	f5f6                	sd	t4,232(sp)
ffffffffc0200794:	f9fa                	sd	t5,240(sp)
ffffffffc0200796:	fdfe                	sd	t6,248(sp)
ffffffffc0200798:	14001473          	csrrw	s0,sscratch,zero
ffffffffc020079c:	100024f3          	csrr	s1,sstatus
ffffffffc02007a0:	14102973          	csrr	s2,sepc
ffffffffc02007a4:	143029f3          	csrr	s3,stval
ffffffffc02007a8:	14202a73          	csrr	s4,scause
ffffffffc02007ac:	e822                	sd	s0,16(sp)
ffffffffc02007ae:	e226                	sd	s1,256(sp)
ffffffffc02007b0:	e64a                	sd	s2,264(sp)
ffffffffc02007b2:	ea4e                	sd	s3,272(sp)
ffffffffc02007b4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007b6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b8:	f87ff0ef          	jal	ra,ffffffffc020073e <trap>

ffffffffc02007bc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007bc:	6492                	ld	s1,256(sp)
ffffffffc02007be:	6932                	ld	s2,264(sp)
ffffffffc02007c0:	10049073          	csrw	sstatus,s1
ffffffffc02007c4:	14191073          	csrw	sepc,s2
ffffffffc02007c8:	60a2                	ld	ra,8(sp)
ffffffffc02007ca:	61e2                	ld	gp,24(sp)
ffffffffc02007cc:	7202                	ld	tp,32(sp)
ffffffffc02007ce:	72a2                	ld	t0,40(sp)
ffffffffc02007d0:	7342                	ld	t1,48(sp)
ffffffffc02007d2:	73e2                	ld	t2,56(sp)
ffffffffc02007d4:	6406                	ld	s0,64(sp)
ffffffffc02007d6:	64a6                	ld	s1,72(sp)
ffffffffc02007d8:	6546                	ld	a0,80(sp)
ffffffffc02007da:	65e6                	ld	a1,88(sp)
ffffffffc02007dc:	7606                	ld	a2,96(sp)
ffffffffc02007de:	76a6                	ld	a3,104(sp)
ffffffffc02007e0:	7746                	ld	a4,112(sp)
ffffffffc02007e2:	77e6                	ld	a5,120(sp)
ffffffffc02007e4:	680a                	ld	a6,128(sp)
ffffffffc02007e6:	68aa                	ld	a7,136(sp)
ffffffffc02007e8:	694a                	ld	s2,144(sp)
ffffffffc02007ea:	69ea                	ld	s3,152(sp)
ffffffffc02007ec:	7a0a                	ld	s4,160(sp)
ffffffffc02007ee:	7aaa                	ld	s5,168(sp)
ffffffffc02007f0:	7b4a                	ld	s6,176(sp)
ffffffffc02007f2:	7bea                	ld	s7,184(sp)
ffffffffc02007f4:	6c0e                	ld	s8,192(sp)
ffffffffc02007f6:	6cae                	ld	s9,200(sp)
ffffffffc02007f8:	6d4e                	ld	s10,208(sp)
ffffffffc02007fa:	6dee                	ld	s11,216(sp)
ffffffffc02007fc:	7e0e                	ld	t3,224(sp)
ffffffffc02007fe:	7eae                	ld	t4,232(sp)
ffffffffc0200800:	7f4e                	ld	t5,240(sp)
ffffffffc0200802:	7fee                	ld	t6,248(sp)
ffffffffc0200804:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200806:	10200073          	sret

ffffffffc020080a <buddy_system_init>:
#define IS_POWER_OF_2(x) (!((x) & ((x) - 1)))

static void
buddy_system_init(void)
{
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc020080a:	00006797          	auipc	a5,0x6
ffffffffc020080e:	81e78793          	addi	a5,a5,-2018 # ffffffffc0206028 <free_area>
ffffffffc0200812:	00006717          	auipc	a4,0x6
ffffffffc0200816:	91e70713          	addi	a4,a4,-1762 # ffffffffc0206130 <buf>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020081a:	e79c                	sd	a5,8(a5)
ffffffffc020081c:	e39c                	sd	a5,0(a5)
    {
        list_init(&(free_area[i].free_list));
        free_area[i].nr_free = 0;
ffffffffc020081e:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc0200822:	07e1                	addi	a5,a5,24
ffffffffc0200824:	fee79be3          	bne	a5,a4,ffffffffc020081a <buddy_system_init+0x10>
    }
}
ffffffffc0200828:	8082                	ret

ffffffffc020082a <split_page>:
    }
}

// 取出高一级的空闲链表中的一个块，将其分为两个较小的快，大小是order-1，加入到较低一级的链表中，注意nr_free数量的变化
static void split_page(int order)
{
ffffffffc020082a:	7179                	addi	sp,sp,-48
ffffffffc020082c:	e84a                	sd	s2,16(sp)
ffffffffc020082e:	00151913          	slli	s2,a0,0x1
ffffffffc0200832:	e052                	sd	s4,0(sp)
ffffffffc0200834:	00a90a33          	add	s4,s2,a0
ffffffffc0200838:	e44e                	sd	s3,8(sp)
ffffffffc020083a:	0a0e                	slli	s4,s4,0x3
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc020083c:	00005997          	auipc	s3,0x5
ffffffffc0200840:	7ec98993          	addi	s3,s3,2028 # ffffffffc0206028 <free_area>
ffffffffc0200844:	014987b3          	add	a5,s3,s4
ffffffffc0200848:	ec26                	sd	s1,24(sp)
ffffffffc020084a:	6784                	ld	s1,8(a5)
ffffffffc020084c:	f022                	sd	s0,32(sp)
ffffffffc020084e:	f406                	sd	ra,40(sp)
ffffffffc0200850:	842a                	mv	s0,a0
    if (list_empty(&(free_list(order))))
ffffffffc0200852:	08f48063          	beq	s1,a5,ffffffffc02008d2 <split_page+0xa8>
        split_page(order + 1);
    }
    list_entry_t *le = list_next(&(free_list(order)));
    struct Page *page = le2page(le, page_link);
    list_del(&(page->page_link));
    nr_free(order) -= 1;
ffffffffc0200856:	9922                	add	s2,s2,s0
    uint32_t n = 1 << (order - 1);
ffffffffc0200858:	4705                	li	a4,1
ffffffffc020085a:	347d                	addiw	s0,s0,-1
ffffffffc020085c:	0087173b          	sllw	a4,a4,s0
    nr_free(order) -= 1;
ffffffffc0200860:	090e                	slli	s2,s2,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200862:	608c                	ld	a1,0(s1)
ffffffffc0200864:	6490                	ld	a2,8(s1)
ffffffffc0200866:	994e                	add	s2,s2,s3
    struct Page *p = page + n;
ffffffffc0200868:	02071513          	slli	a0,a4,0x20
    nr_free(order) -= 1;
ffffffffc020086c:	01092683          	lw	a3,16(s2)
    struct Page *p = page + n;
ffffffffc0200870:	9101                	srli	a0,a0,0x20
ffffffffc0200872:	00251793          	slli	a5,a0,0x2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200876:	e590                	sd	a2,8(a1)
ffffffffc0200878:	97aa                	add	a5,a5,a0
    next->prev = prev;
ffffffffc020087a:	e20c                	sd	a1,0(a2)
    nr_free(order) -= 1;
ffffffffc020087c:	36fd                	addiw	a3,a3,-1
    struct Page *p = page + n;
ffffffffc020087e:	078e                	slli	a5,a5,0x3
    nr_free(order) -= 1;
ffffffffc0200880:	00d92823          	sw	a3,16(s2)
    struct Page *p = page + n;
ffffffffc0200884:	17a1                	addi	a5,a5,-24
ffffffffc0200886:	97a6                	add	a5,a5,s1
    page->property = n;
ffffffffc0200888:	fee4ac23          	sw	a4,-8(s1)
    p->property = n;
ffffffffc020088c:	cb98                	sw	a4,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020088e:	00878693          	addi	a3,a5,8
ffffffffc0200892:	4709                	li	a4,2
ffffffffc0200894:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200898:	00141513          	slli	a0,s0,0x1
ffffffffc020089c:	942a                	add	s0,s0,a0
ffffffffc020089e:	040e                	slli	s0,s0,0x3
ffffffffc02008a0:	944e                	add	s0,s0,s3
ffffffffc02008a2:	6414                	ld	a3,8(s0)
    SetPageProperty(p);
    list_add(&(free_list(order - 1)), &(page->page_link));
ffffffffc02008a4:	1a21                	addi	s4,s4,-24
    prev->next = next->prev = elm;
ffffffffc02008a6:	e404                	sd	s1,8(s0)
ffffffffc02008a8:	99d2                	add	s3,s3,s4
    list_add(&(page->page_link), &(p->page_link));
    nr_free(order - 1) += 2;
ffffffffc02008aa:	4818                	lw	a4,16(s0)
    elm->prev = prev;
ffffffffc02008ac:	0134b023          	sd	s3,0(s1)
    list_add(&(page->page_link), &(p->page_link));
ffffffffc02008b0:	01878613          	addi	a2,a5,24
    prev->next = next->prev = elm;
ffffffffc02008b4:	e290                	sd	a2,0(a3)
ffffffffc02008b6:	e490                	sd	a2,8(s1)
    elm->prev = prev;
ffffffffc02008b8:	ef84                	sd	s1,24(a5)
    elm->next = next;
ffffffffc02008ba:	f394                	sd	a3,32(a5)
    nr_free(order - 1) += 2;
ffffffffc02008bc:	0027079b          	addiw	a5,a4,2
    return;
}
ffffffffc02008c0:	70a2                	ld	ra,40(sp)
    nr_free(order - 1) += 2;
ffffffffc02008c2:	c81c                	sw	a5,16(s0)
}
ffffffffc02008c4:	7402                	ld	s0,32(sp)
ffffffffc02008c6:	64e2                	ld	s1,24(sp)
ffffffffc02008c8:	6942                	ld	s2,16(sp)
ffffffffc02008ca:	69a2                	ld	s3,8(sp)
ffffffffc02008cc:	6a02                	ld	s4,0(sp)
ffffffffc02008ce:	6145                	addi	sp,sp,48
ffffffffc02008d0:	8082                	ret
        split_page(order + 1);
ffffffffc02008d2:	2505                	addiw	a0,a0,1
ffffffffc02008d4:	f57ff0ef          	jal	ra,ffffffffc020082a <split_page>
    return listelm->next;
ffffffffc02008d8:	6484                	ld	s1,8(s1)
ffffffffc02008da:	bfb5                	j	ffffffffc0200856 <split_page+0x2c>

ffffffffc02008dc <add_page>:
}

// 先将块按照地址从小到大的顺序加入到指定序号的链表当中
static void add_page(uint32_t order, struct Page *base)
{
    if (list_empty(&(free_list(order))))
ffffffffc02008dc:	02051793          	slli	a5,a0,0x20
ffffffffc02008e0:	9381                	srli	a5,a5,0x20
ffffffffc02008e2:	00179693          	slli	a3,a5,0x1
ffffffffc02008e6:	96be                	add	a3,a3,a5
ffffffffc02008e8:	00369793          	slli	a5,a3,0x3
ffffffffc02008ec:	00005697          	auipc	a3,0x5
ffffffffc02008f0:	73c68693          	addi	a3,a3,1852 # ffffffffc0206028 <free_area>
ffffffffc02008f4:	96be                	add	a3,a3,a5
    return list->next == list;
ffffffffc02008f6:	669c                	ld	a5,8(a3)
        while ((le = list_next(le)) != &(free_list(order)))
        {
            struct Page *page = le2page(le, page_link);
            if (base < page)
            {
                list_add_before(le, &(base->page_link));
ffffffffc02008f8:	01858613          	addi	a2,a1,24
    if (list_empty(&(free_list(order))))
ffffffffc02008fc:	02f68c63          	beq	a3,a5,ffffffffc0200934 <add_page+0x58>
            struct Page *page = le2page(le, page_link);
ffffffffc0200900:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0200904:	00e5ea63          	bltu	a1,a4,ffffffffc0200918 <add_page+0x3c>
    return listelm->next;
ffffffffc0200908:	6798                	ld	a4,8(a5)
                break;
            }
            else if (list_next(le) == &(free_list(order)))
ffffffffc020090a:	00e68d63          	beq	a3,a4,ffffffffc0200924 <add_page+0x48>
{
ffffffffc020090e:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0200910:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0200914:	fee5fae3          	bgeu	a1,a4,ffffffffc0200908 <add_page+0x2c>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200918:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc020091a:	e390                	sd	a2,0(a5)
ffffffffc020091c:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc020091e:	f19c                	sd	a5,32(a1)
    elm->prev = prev;
ffffffffc0200920:	ed98                	sd	a4,24(a1)
}
ffffffffc0200922:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200924:	e290                	sd	a2,0(a3)
ffffffffc0200926:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0200928:	f194                	sd	a3,32(a1)
    return listelm->next;
ffffffffc020092a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020092c:	ed9c                	sd	a5,24(a1)
        while ((le = list_next(le)) != &(free_list(order)))
ffffffffc020092e:	fee690e3          	bne	a3,a4,ffffffffc020090e <add_page+0x32>
            {
                list_add(le, &(base->page_link));
            }
        }
    }
}
ffffffffc0200932:	8082                	ret
        list_add(&(free_list(order)), &(base->page_link));
ffffffffc0200934:	01858793          	addi	a5,a1,24
    prev->next = next->prev = elm;
ffffffffc0200938:	e29c                	sd	a5,0(a3)
ffffffffc020093a:	e69c                	sd	a5,8(a3)
    elm->next = next;
ffffffffc020093c:	f194                	sd	a3,32(a1)
    elm->prev = prev;
ffffffffc020093e:	ed94                	sd	a3,24(a1)
}
ffffffffc0200940:	8082                	ret

ffffffffc0200942 <buddy_system_nr_free_pages>:

static size_t
buddy_system_nr_free_pages(void)
{ // 计算空闲页面的数量，空闲块*块大小（与链表序号有关）
    size_t num = 0;
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc0200942:	00005697          	auipc	a3,0x5
ffffffffc0200946:	6f668693          	addi	a3,a3,1782 # ffffffffc0206038 <free_area+0x10>
ffffffffc020094a:	4701                	li	a4,0
    size_t num = 0;
ffffffffc020094c:	4501                	li	a0,0
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc020094e:	462d                	li	a2,11
    {
        num += nr_free(i) << i;
ffffffffc0200950:	429c                	lw	a5,0(a3)
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc0200952:	06e1                	addi	a3,a3,24
        num += nr_free(i) << i;
ffffffffc0200954:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200958:	1782                	slli	a5,a5,0x20
ffffffffc020095a:	9381                	srli	a5,a5,0x20
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc020095c:	2705                	addiw	a4,a4,1
        num += nr_free(i) << i;
ffffffffc020095e:	953e                	add	a0,a0,a5
    for (int i = 0; i < MAX_ORDER; i++)
ffffffffc0200960:	fec718e3          	bne	a4,a2,ffffffffc0200950 <buddy_system_nr_free_pages+0xe>
    }
    return num;
}
ffffffffc0200964:	8082                	ret

ffffffffc0200966 <buddy_system_free_pages>:
{
ffffffffc0200966:	7139                	addi	sp,sp,-64
ffffffffc0200968:	fc06                	sd	ra,56(sp)
ffffffffc020096a:	f822                	sd	s0,48(sp)
ffffffffc020096c:	f426                	sd	s1,40(sp)
ffffffffc020096e:	f04a                	sd	s2,32(sp)
ffffffffc0200970:	ec4e                	sd	s3,24(sp)
ffffffffc0200972:	e852                	sd	s4,16(sp)
ffffffffc0200974:	e456                	sd	s5,8(sp)
    assert(n > 0);
ffffffffc0200976:	18058c63          	beqz	a1,ffffffffc0200b0e <buddy_system_free_pages+0x1a8>
    assert(IS_POWER_OF_2(n));
ffffffffc020097a:	fff58793          	addi	a5,a1,-1
ffffffffc020097e:	8fed                	and	a5,a5,a1
ffffffffc0200980:	16079763          	bnez	a5,ffffffffc0200aee <buddy_system_free_pages+0x188>
    assert(n < (1 << (MAX_ORDER - 1)));
ffffffffc0200984:	3ff00793          	li	a5,1023
ffffffffc0200988:	1ab7e363          	bltu	a5,a1,ffffffffc0200b2e <buddy_system_free_pages+0x1c8>
    for (; p != base + n; p++)
ffffffffc020098c:	00259693          	slli	a3,a1,0x2
ffffffffc0200990:	96ae                	add	a3,a3,a1
ffffffffc0200992:	068e                	slli	a3,a3,0x3
ffffffffc0200994:	892a                	mv	s2,a0
ffffffffc0200996:	96aa                	add	a3,a3,a0
ffffffffc0200998:	87aa                	mv	a5,a0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020099a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面没有被保留且没有属性标志
ffffffffc020099c:	8b05                	andi	a4,a4,1
ffffffffc020099e:	12071863          	bnez	a4,ffffffffc0200ace <buddy_system_free_pages+0x168>
ffffffffc02009a2:	6798                	ld	a4,8(a5)
ffffffffc02009a4:	8b09                	andi	a4,a4,2
ffffffffc02009a6:	12071463          	bnez	a4,ffffffffc0200ace <buddy_system_free_pages+0x168>
        p->flags = 0;
ffffffffc02009aa:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02009ae:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02009b2:	02878793          	addi	a5,a5,40
ffffffffc02009b6:	fed792e3          	bne	a5,a3,ffffffffc020099a <buddy_system_free_pages+0x34>
    base->property = n;
ffffffffc02009ba:	00b92823          	sw	a1,16(s2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02009be:	4789                	li	a5,2
ffffffffc02009c0:	00890713          	addi	a4,s2,8
ffffffffc02009c4:	40f7302f          	amoor.d	zero,a5,(a4)
    while (temp != 1)
ffffffffc02009c8:	4785                	li	a5,1
ffffffffc02009ca:	0ef58c63          	beq	a1,a5,ffffffffc0200ac2 <buddy_system_free_pages+0x15c>
    uint32_t order = 0;
ffffffffc02009ce:	4481                	li	s1,0
        temp >>= 1;
ffffffffc02009d0:	8185                	srli	a1,a1,0x1
        order++;
ffffffffc02009d2:	2485                	addiw	s1,s1,1
    while (temp != 1)
ffffffffc02009d4:	fef59ee3          	bne	a1,a5,ffffffffc02009d0 <buddy_system_free_pages+0x6a>
    add_page(order, base);
ffffffffc02009d8:	85ca                	mv	a1,s2
ffffffffc02009da:	8526                	mv	a0,s1
ffffffffc02009dc:	f01ff0ef          	jal	ra,ffffffffc02008dc <add_page>
    if (order == MAX_ORDER - 1)
ffffffffc02009e0:	47a9                	li	a5,10
ffffffffc02009e2:	06f48763          	beq	s1,a5,ffffffffc0200a50 <buddy_system_free_pages+0xea>
ffffffffc02009e6:	00005a97          	auipc	s5,0x5
ffffffffc02009ea:	642a8a93          	addi	s5,s5,1602 # ffffffffc0206028 <free_area>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02009ee:	59f5                	li	s3,-3
ffffffffc02009f0:	4a29                	li	s4,10
    if (le != &(free_list(order)))
ffffffffc02009f2:	02049793          	slli	a5,s1,0x20
ffffffffc02009f6:	9381                	srli	a5,a5,0x20
ffffffffc02009f8:	00179413          	slli	s0,a5,0x1
ffffffffc02009fc:	943e                	add	s0,s0,a5
    return listelm->prev;
ffffffffc02009fe:	01893703          	ld	a4,24(s2)
ffffffffc0200a02:	040e                	slli	s0,s0,0x3
ffffffffc0200a04:	9456                	add	s0,s0,s5
                add_page(order + 1, base);
ffffffffc0200a06:	2485                	addiw	s1,s1,1
    if (le != &(free_list(order)))
ffffffffc0200a08:	02870063          	beq	a4,s0,ffffffffc0200a28 <buddy_system_free_pages+0xc2>
        if (p + p->property == base)
ffffffffc0200a0c:	ff872603          	lw	a2,-8(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0200a10:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base)
ffffffffc0200a14:	02061693          	slli	a3,a2,0x20
ffffffffc0200a18:	9281                	srli	a3,a3,0x20
ffffffffc0200a1a:	00269793          	slli	a5,a3,0x2
ffffffffc0200a1e:	97b6                	add	a5,a5,a3
ffffffffc0200a20:	078e                	slli	a5,a5,0x3
ffffffffc0200a22:	97ae                	add	a5,a5,a1
ffffffffc0200a24:	06f90963          	beq	s2,a5,ffffffffc0200a96 <buddy_system_free_pages+0x130>
    return listelm->next;
ffffffffc0200a28:	02093703          	ld	a4,32(s2)
    if (le != &(free_list(order)))
ffffffffc0200a2c:	02e40063          	beq	s0,a4,ffffffffc0200a4c <buddy_system_free_pages+0xe6>
        if (base + base->property == p)
ffffffffc0200a30:	01092583          	lw	a1,16(s2)
        struct Page *p = le2page(le, page_link);
ffffffffc0200a34:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p)
ffffffffc0200a38:	02059613          	slli	a2,a1,0x20
ffffffffc0200a3c:	9201                	srli	a2,a2,0x20
ffffffffc0200a3e:	00261793          	slli	a5,a2,0x2
ffffffffc0200a42:	97b2                	add	a5,a5,a2
ffffffffc0200a44:	078e                	slli	a5,a5,0x3
ffffffffc0200a46:	97ca                	add	a5,a5,s2
ffffffffc0200a48:	00f68d63          	beq	a3,a5,ffffffffc0200a62 <buddy_system_free_pages+0xfc>
    if (order == MAX_ORDER - 1)
ffffffffc0200a4c:	fb4493e3          	bne	s1,s4,ffffffffc02009f2 <buddy_system_free_pages+0x8c>
}
ffffffffc0200a50:	70e2                	ld	ra,56(sp)
ffffffffc0200a52:	7442                	ld	s0,48(sp)
ffffffffc0200a54:	74a2                	ld	s1,40(sp)
ffffffffc0200a56:	7902                	ld	s2,32(sp)
ffffffffc0200a58:	69e2                	ld	s3,24(sp)
ffffffffc0200a5a:	6a42                	ld	s4,16(sp)
ffffffffc0200a5c:	6aa2                	ld	s5,8(sp)
ffffffffc0200a5e:	6121                	addi	sp,sp,64
ffffffffc0200a60:	8082                	ret
            base->property += p->property;
ffffffffc0200a62:	ff872783          	lw	a5,-8(a4)
ffffffffc0200a66:	9dbd                	addw	a1,a1,a5
ffffffffc0200a68:	00b92823          	sw	a1,16(s2)
ffffffffc0200a6c:	ff070793          	addi	a5,a4,-16
ffffffffc0200a70:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a74:	671c                	ld	a5,8(a4)
ffffffffc0200a76:	6314                	ld	a3,0(a4)
                add_page(order + 1, base);
ffffffffc0200a78:	85ca                	mv	a1,s2
ffffffffc0200a7a:	8526                	mv	a0,s1
    prev->next = next;
ffffffffc0200a7c:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200a7e:	e394                	sd	a3,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a80:	01893703          	ld	a4,24(s2)
ffffffffc0200a84:	02093783          	ld	a5,32(s2)
    prev->next = next;
ffffffffc0200a88:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200a8a:	e398                	sd	a4,0(a5)
ffffffffc0200a8c:	e51ff0ef          	jal	ra,ffffffffc02008dc <add_page>
    if (order == MAX_ORDER - 1)
ffffffffc0200a90:	f74491e3          	bne	s1,s4,ffffffffc02009f2 <buddy_system_free_pages+0x8c>
ffffffffc0200a94:	bf75                	j	ffffffffc0200a50 <buddy_system_free_pages+0xea>
            p->property += base->property;
ffffffffc0200a96:	01092783          	lw	a5,16(s2)
ffffffffc0200a9a:	9e3d                	addw	a2,a2,a5
ffffffffc0200a9c:	fec72c23          	sw	a2,-8(a4)
ffffffffc0200aa0:	00890793          	addi	a5,s2,8
ffffffffc0200aa4:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200aa8:	02093783          	ld	a5,32(s2)
                add_page(order + 1, base);
ffffffffc0200aac:	8526                	mv	a0,s1
            base = p;
ffffffffc0200aae:	892e                	mv	s2,a1
    prev->next = next;
ffffffffc0200ab0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200ab2:	e398                	sd	a4,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200ab4:	6314                	ld	a3,0(a4)
ffffffffc0200ab6:	671c                	ld	a5,8(a4)
    prev->next = next;
ffffffffc0200ab8:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200aba:	e394                	sd	a3,0(a5)
                add_page(order + 1, base);
ffffffffc0200abc:	e21ff0ef          	jal	ra,ffffffffc02008dc <add_page>
ffffffffc0200ac0:	b7a5                	j	ffffffffc0200a28 <buddy_system_free_pages+0xc2>
    add_page(order, base);
ffffffffc0200ac2:	85ca                	mv	a1,s2
ffffffffc0200ac4:	4501                	li	a0,0
ffffffffc0200ac6:	e17ff0ef          	jal	ra,ffffffffc02008dc <add_page>
    uint32_t order = 0;
ffffffffc0200aca:	4481                	li	s1,0
ffffffffc0200acc:	bf29                	j	ffffffffc02009e6 <buddy_system_free_pages+0x80>
        assert(!PageReserved(p) && !PageProperty(p)); // 确保页面没有被保留且没有属性标志
ffffffffc0200ace:	00001697          	auipc	a3,0x1
ffffffffc0200ad2:	52268693          	addi	a3,a3,1314 # ffffffffc0201ff0 <commands+0x570>
ffffffffc0200ad6:	00001617          	auipc	a2,0x1
ffffffffc0200ada:	4aa60613          	addi	a2,a2,1194 # ffffffffc0201f80 <commands+0x500>
ffffffffc0200ade:	0bf00593          	li	a1,191
ffffffffc0200ae2:	00001517          	auipc	a0,0x1
ffffffffc0200ae6:	4b650513          	addi	a0,a0,1206 # ffffffffc0201f98 <commands+0x518>
ffffffffc0200aea:	8cbff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(IS_POWER_OF_2(n));
ffffffffc0200aee:	00001697          	auipc	a3,0x1
ffffffffc0200af2:	4ca68693          	addi	a3,a3,1226 # ffffffffc0201fb8 <commands+0x538>
ffffffffc0200af6:	00001617          	auipc	a2,0x1
ffffffffc0200afa:	48a60613          	addi	a2,a2,1162 # ffffffffc0201f80 <commands+0x500>
ffffffffc0200afe:	0ba00593          	li	a1,186
ffffffffc0200b02:	00001517          	auipc	a0,0x1
ffffffffc0200b06:	49650513          	addi	a0,a0,1174 # ffffffffc0201f98 <commands+0x518>
ffffffffc0200b0a:	8abff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(n > 0);
ffffffffc0200b0e:	00001697          	auipc	a3,0x1
ffffffffc0200b12:	46a68693          	addi	a3,a3,1130 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200b16:	00001617          	auipc	a2,0x1
ffffffffc0200b1a:	46a60613          	addi	a2,a2,1130 # ffffffffc0201f80 <commands+0x500>
ffffffffc0200b1e:	0b900593          	li	a1,185
ffffffffc0200b22:	00001517          	auipc	a0,0x1
ffffffffc0200b26:	47650513          	addi	a0,a0,1142 # ffffffffc0201f98 <commands+0x518>
ffffffffc0200b2a:	88bff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(n < (1 << (MAX_ORDER - 1)));
ffffffffc0200b2e:	00001697          	auipc	a3,0x1
ffffffffc0200b32:	4a268693          	addi	a3,a3,1186 # ffffffffc0201fd0 <commands+0x550>
ffffffffc0200b36:	00001617          	auipc	a2,0x1
ffffffffc0200b3a:	44a60613          	addi	a2,a2,1098 # ffffffffc0201f80 <commands+0x500>
ffffffffc0200b3e:	0bb00593          	li	a1,187
ffffffffc0200b42:	00001517          	auipc	a0,0x1
ffffffffc0200b46:	45650513          	addi	a0,a0,1110 # ffffffffc0201f98 <commands+0x518>
ffffffffc0200b4a:	86bff0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc0200b4e <buddy_system_alloc_pages.part.0>:
    while (n < (1 << order))
ffffffffc0200b4e:	3ff00713          	li	a4,1023
ffffffffc0200b52:	47a9                	li	a5,10
ffffffffc0200b54:	4685                	li	a3,1
ffffffffc0200b56:	0aa76963          	bltu	a4,a0,ffffffffc0200c08 <buddy_system_alloc_pages.part.0+0xba>
        order -= 1;
ffffffffc0200b5a:	0007859b          	sext.w	a1,a5
ffffffffc0200b5e:	37fd                	addiw	a5,a5,-1
    while (n < (1 << order))
ffffffffc0200b60:	00f6973b          	sllw	a4,a3,a5
ffffffffc0200b64:	fee56be3          	bltu	a0,a4,ffffffffc0200b5a <buddy_system_alloc_pages.part.0+0xc>
    for (int i = order; i < MAX_ORDER; i++)
ffffffffc0200b68:	47a9                	li	a5,10
ffffffffc0200b6a:	0005869b          	sext.w	a3,a1
ffffffffc0200b6e:	08b7cd63          	blt	a5,a1,ffffffffc0200c08 <buddy_system_alloc_pages.part.0+0xba>
ffffffffc0200b72:	4629                	li	a2,10
ffffffffc0200b74:	9e0d                	subw	a2,a2,a1
ffffffffc0200b76:	1602                	slli	a2,a2,0x20
ffffffffc0200b78:	9201                	srli	a2,a2,0x20
ffffffffc0200b7a:	00d60733          	add	a4,a2,a3
ffffffffc0200b7e:	00171613          	slli	a2,a4,0x1
ffffffffc0200b82:	00169793          	slli	a5,a3,0x1
buddy_system_alloc_pages(size_t n)
ffffffffc0200b86:	1101                	addi	sp,sp,-32
ffffffffc0200b88:	963a                	add	a2,a2,a4
ffffffffc0200b8a:	97b6                	add	a5,a5,a3
ffffffffc0200b8c:	00005717          	auipc	a4,0x5
ffffffffc0200b90:	4b470713          	addi	a4,a4,1204 # ffffffffc0206040 <free_area+0x18>
ffffffffc0200b94:	e426                	sd	s1,8(sp)
ffffffffc0200b96:	078e                	slli	a5,a5,0x3
ffffffffc0200b98:	00005497          	auipc	s1,0x5
ffffffffc0200b9c:	49048493          	addi	s1,s1,1168 # ffffffffc0206028 <free_area>
ffffffffc0200ba0:	060e                	slli	a2,a2,0x3
ffffffffc0200ba2:	963a                	add	a2,a2,a4
ffffffffc0200ba4:	ec06                	sd	ra,24(sp)
ffffffffc0200ba6:	e822                	sd	s0,16(sp)
ffffffffc0200ba8:	97a6                	add	a5,a5,s1
    uint32_t flag = 0;
ffffffffc0200baa:	4701                	li	a4,0
        flag += nr_free(i);
ffffffffc0200bac:	4b94                	lw	a3,16(a5)
    for (int i = order; i < MAX_ORDER; i++)
ffffffffc0200bae:	07e1                	addi	a5,a5,24
        flag += nr_free(i);
ffffffffc0200bb0:	9f35                	addw	a4,a4,a3
    for (int i = order; i < MAX_ORDER; i++)
ffffffffc0200bb2:	fec79de3          	bne	a5,a2,ffffffffc0200bac <buddy_system_alloc_pages.part.0+0x5e>
    if (flag == 0)
ffffffffc0200bb6:	c339                	beqz	a4,ffffffffc0200bfc <buddy_system_alloc_pages.part.0+0xae>
    if (list_empty(&(free_list(order))))
ffffffffc0200bb8:	02059713          	slli	a4,a1,0x20
ffffffffc0200bbc:	9301                	srli	a4,a4,0x20
ffffffffc0200bbe:	00171793          	slli	a5,a4,0x1
ffffffffc0200bc2:	97ba                	add	a5,a5,a4
ffffffffc0200bc4:	078e                	slli	a5,a5,0x3
ffffffffc0200bc6:	94be                	add	s1,s1,a5
    return list->next == list;
ffffffffc0200bc8:	6480                	ld	s0,8(s1)
ffffffffc0200bca:	02848263          	beq	s1,s0,ffffffffc0200bee <buddy_system_alloc_pages.part.0+0xa0>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200bce:	6018                	ld	a4,0(s0)
ffffffffc0200bd0:	641c                	ld	a5,8(s0)
    page = le2page(le, page_link);
ffffffffc0200bd2:	fe840513          	addi	a0,s0,-24
    prev->next = next;
ffffffffc0200bd6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200bd8:	e398                	sd	a4,0(a5)
ffffffffc0200bda:	57f5                	li	a5,-3
ffffffffc0200bdc:	ff040713          	addi	a4,s0,-16
ffffffffc0200be0:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200be4:	60e2                	ld	ra,24(sp)
ffffffffc0200be6:	6442                	ld	s0,16(sp)
ffffffffc0200be8:	64a2                	ld	s1,8(sp)
ffffffffc0200bea:	6105                	addi	sp,sp,32
ffffffffc0200bec:	8082                	ret
        split_page(order + 1);
ffffffffc0200bee:	0015851b          	addiw	a0,a1,1
ffffffffc0200bf2:	c39ff0ef          	jal	ra,ffffffffc020082a <split_page>
    return list->next == list;
ffffffffc0200bf6:	6400                	ld	s0,8(s0)
    if (list_empty(&(free_list(order))))
ffffffffc0200bf8:	fc849be3          	bne	s1,s0,ffffffffc0200bce <buddy_system_alloc_pages.part.0+0x80>
}
ffffffffc0200bfc:	60e2                	ld	ra,24(sp)
ffffffffc0200bfe:	6442                	ld	s0,16(sp)
ffffffffc0200c00:	64a2                	ld	s1,8(sp)
        return NULL;
ffffffffc0200c02:	4501                	li	a0,0
}
ffffffffc0200c04:	6105                	addi	sp,sp,32
ffffffffc0200c06:	8082                	ret
        return NULL;
ffffffffc0200c08:	4501                	li	a0,0
}
ffffffffc0200c0a:	8082                	ret

ffffffffc0200c0c <buddy_system_alloc_pages>:
    assert(n > 0);
ffffffffc0200c0c:	c901                	beqz	a0,ffffffffc0200c1c <buddy_system_alloc_pages+0x10>
    if (n > (1 << (MAX_ORDER - 1)))
ffffffffc0200c0e:	40000713          	li	a4,1024
ffffffffc0200c12:	00a76363          	bltu	a4,a0,ffffffffc0200c18 <buddy_system_alloc_pages+0xc>
ffffffffc0200c16:	bf25                	j	ffffffffc0200b4e <buddy_system_alloc_pages.part.0>
}
ffffffffc0200c18:	4501                	li	a0,0
ffffffffc0200c1a:	8082                	ret
{
ffffffffc0200c1c:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0200c1e:	00001697          	auipc	a3,0x1
ffffffffc0200c22:	35a68693          	addi	a3,a3,858 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200c26:	00001617          	auipc	a2,0x1
ffffffffc0200c2a:	35a60613          	addi	a2,a2,858 # ffffffffc0201f80 <commands+0x500>
ffffffffc0200c2e:	05100593          	li	a1,81
ffffffffc0200c32:	00001517          	auipc	a0,0x1
ffffffffc0200c36:	36650513          	addi	a0,a0,870 # ffffffffc0201f98 <commands+0x518>
{
ffffffffc0200c3a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200c3c:	f78ff0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc0200c40 <buddy_system_check>:
// buddy_system_check(){
//     cprintf("buddy system tests passed.\n");
// }

static void buddy_system_check(void)
{
ffffffffc0200c40:	1141                	addi	sp,sp,-16
ffffffffc0200c42:	4505                	li	a0,1
ffffffffc0200c44:	e406                	sd	ra,8(sp)
ffffffffc0200c46:	e022                	sd	s0,0(sp)
ffffffffc0200c48:	f07ff0ef          	jal	ra,ffffffffc0200b4e <buddy_system_alloc_pages.part.0>
    struct Page *p0, *p1, *p2, *p3;

    // 测试 1 页的分配和释放
    p0 = buddy_system_alloc_pages(1);
    assert(p0 != NULL);
ffffffffc0200c4c:	c125                	beqz	a0,ffffffffc0200cac <buddy_system_check+0x6c>
    buddy_system_free_pages(p0, 1);
ffffffffc0200c4e:	4585                	li	a1,1
ffffffffc0200c50:	d17ff0ef          	jal	ra,ffffffffc0200966 <buddy_system_free_pages>
    if (n > (1 << (MAX_ORDER - 1)))
ffffffffc0200c54:	4509                	li	a0,2
ffffffffc0200c56:	ef9ff0ef          	jal	ra,ffffffffc0200b4e <buddy_system_alloc_pages.part.0>
ffffffffc0200c5a:	842a                	mv	s0,a0
ffffffffc0200c5c:	4511                	li	a0,4
ffffffffc0200c5e:	ef1ff0ef          	jal	ra,ffffffffc0200b4e <buddy_system_alloc_pages.part.0>

    // 测试 2 页和 4 页的分配
    p1 = buddy_system_alloc_pages(2);
    p2 = buddy_system_alloc_pages(4);
    assert(p1 != NULL && p2 != NULL);
ffffffffc0200c62:	c40d                	beqz	s0,ffffffffc0200c8c <buddy_system_check+0x4c>
ffffffffc0200c64:	c505                	beqz	a0,ffffffffc0200c8c <buddy_system_check+0x4c>

    // 测试释放并合并
    buddy_system_free_pages(p2, 4);
ffffffffc0200c66:	4591                	li	a1,4
ffffffffc0200c68:	cffff0ef          	jal	ra,ffffffffc0200966 <buddy_system_free_pages>
    if (n > (1 << (MAX_ORDER - 1)))
ffffffffc0200c6c:	4521                	li	a0,8
ffffffffc0200c6e:	ee1ff0ef          	jal	ra,ffffffffc0200b4e <buddy_system_alloc_pages.part.0>

    // 测试 8 页分配
    p3 = buddy_system_alloc_pages(8);
    assert(p3 != NULL);
ffffffffc0200c72:	cd29                	beqz	a0,ffffffffc0200ccc <buddy_system_check+0x8c>
    buddy_system_free_pages(p3, 8);
ffffffffc0200c74:	45a1                	li	a1,8
ffffffffc0200c76:	cf1ff0ef          	jal	ra,ffffffffc0200966 <buddy_system_free_pages>

    cprintf("buddy system tests passed.\n");
}
ffffffffc0200c7a:	6402                	ld	s0,0(sp)
ffffffffc0200c7c:	60a2                	ld	ra,8(sp)
    cprintf("buddy system tests passed.\n");
ffffffffc0200c7e:	00001517          	auipc	a0,0x1
ffffffffc0200c82:	3da50513          	addi	a0,a0,986 # ffffffffc0202058 <commands+0x5d8>
}
ffffffffc0200c86:	0141                	addi	sp,sp,16
    cprintf("buddy system tests passed.\n");
ffffffffc0200c88:	c32ff06f          	j	ffffffffc02000ba <cprintf>
    assert(p1 != NULL && p2 != NULL);
ffffffffc0200c8c:	00001697          	auipc	a3,0x1
ffffffffc0200c90:	39c68693          	addi	a3,a3,924 # ffffffffc0202028 <commands+0x5a8>
ffffffffc0200c94:	00001617          	auipc	a2,0x1
ffffffffc0200c98:	2ec60613          	addi	a2,a2,748 # ffffffffc0201f80 <commands+0x500>
ffffffffc0200c9c:	12600593          	li	a1,294
ffffffffc0200ca0:	00001517          	auipc	a0,0x1
ffffffffc0200ca4:	2f850513          	addi	a0,a0,760 # ffffffffc0201f98 <commands+0x518>
ffffffffc0200ca8:	f0cff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(p0 != NULL);
ffffffffc0200cac:	00001697          	auipc	a3,0x1
ffffffffc0200cb0:	36c68693          	addi	a3,a3,876 # ffffffffc0202018 <commands+0x598>
ffffffffc0200cb4:	00001617          	auipc	a2,0x1
ffffffffc0200cb8:	2cc60613          	addi	a2,a2,716 # ffffffffc0201f80 <commands+0x500>
ffffffffc0200cbc:	12000593          	li	a1,288
ffffffffc0200cc0:	00001517          	auipc	a0,0x1
ffffffffc0200cc4:	2d850513          	addi	a0,a0,728 # ffffffffc0201f98 <commands+0x518>
ffffffffc0200cc8:	eecff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(p3 != NULL);
ffffffffc0200ccc:	00001697          	auipc	a3,0x1
ffffffffc0200cd0:	37c68693          	addi	a3,a3,892 # ffffffffc0202048 <commands+0x5c8>
ffffffffc0200cd4:	00001617          	auipc	a2,0x1
ffffffffc0200cd8:	2ac60613          	addi	a2,a2,684 # ffffffffc0201f80 <commands+0x500>
ffffffffc0200cdc:	12d00593          	li	a1,301
ffffffffc0200ce0:	00001517          	auipc	a0,0x1
ffffffffc0200ce4:	2b850513          	addi	a0,a0,696 # ffffffffc0201f98 <commands+0x518>
ffffffffc0200ce8:	eccff0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc0200cec <buddy_system_init_memmap>:
{
ffffffffc0200cec:	1141                	addi	sp,sp,-16
ffffffffc0200cee:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200cf0:	c1f1                	beqz	a1,ffffffffc0200db4 <buddy_system_init_memmap+0xc8>
    for (; p != base + n; p++)
ffffffffc0200cf2:	00259693          	slli	a3,a1,0x2
ffffffffc0200cf6:	96ae                	add	a3,a3,a1
ffffffffc0200cf8:	068e                	slli	a3,a3,0x3
ffffffffc0200cfa:	96aa                	add	a3,a3,a0
ffffffffc0200cfc:	87aa                	mv	a5,a0
ffffffffc0200cfe:	00d50f63          	beq	a0,a3,ffffffffc0200d1c <buddy_system_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200d02:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0200d04:	8b05                	andi	a4,a4,1
ffffffffc0200d06:	c759                	beqz	a4,ffffffffc0200d94 <buddy_system_init_memmap+0xa8>
        p->flags = p->property = 0;
ffffffffc0200d08:	0007a823          	sw	zero,16(a5)
ffffffffc0200d0c:	0007b423          	sd	zero,8(a5)
ffffffffc0200d10:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0200d14:	02878793          	addi	a5,a5,40
ffffffffc0200d18:	fed795e3          	bne	a5,a3,ffffffffc0200d02 <buddy_system_init_memmap+0x16>
    uint32_t order = MAX_ORDER - 1;
ffffffffc0200d1c:	4729                	li	a4,10
    uint32_t order_size = 1 << order;
ffffffffc0200d1e:	40000693          	li	a3,1024
ffffffffc0200d22:	00005e17          	auipc	t3,0x5
ffffffffc0200d26:	306e0e13          	addi	t3,t3,774 # ffffffffc0206028 <free_area>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200d2a:	4309                	li	t1,2
        p->property = order_size;
ffffffffc0200d2c:	c914                	sw	a3,16(a0)
ffffffffc0200d2e:	00850793          	addi	a5,a0,8
ffffffffc0200d32:	4067b02f          	amoor.d	zero,t1,(a5)
        nr_free(order) += 1;
ffffffffc0200d36:	02071613          	slli	a2,a4,0x20
ffffffffc0200d3a:	9201                	srli	a2,a2,0x20
ffffffffc0200d3c:	00161793          	slli	a5,a2,0x1
ffffffffc0200d40:	97b2                	add	a5,a5,a2
ffffffffc0200d42:	078e                	slli	a5,a5,0x3
ffffffffc0200d44:	97f2                	add	a5,a5,t3
ffffffffc0200d46:	0107a803          	lw	a6,16(a5)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200d4a:	0007b883          	ld	a7,0(a5)
        list_add_before(&(free_list(order)), &(p->page_link));
ffffffffc0200d4e:	01850613          	addi	a2,a0,24
        nr_free(order) += 1;
ffffffffc0200d52:	2805                	addiw	a6,a6,1
ffffffffc0200d54:	0107a823          	sw	a6,16(a5)
    prev->next = next->prev = elm;
ffffffffc0200d58:	e390                	sd	a2,0(a5)
ffffffffc0200d5a:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0200d5e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200d60:	01153c23          	sd	a7,24(a0)
        curr_size -= order_size;
ffffffffc0200d64:	02069793          	slli	a5,a3,0x20
ffffffffc0200d68:	9381                	srli	a5,a5,0x20
ffffffffc0200d6a:	8d95                	sub	a1,a1,a3
        while (order > 0 && curr_size < order_size)
ffffffffc0200d6c:	cb19                	beqz	a4,ffffffffc0200d82 <buddy_system_init_memmap+0x96>
ffffffffc0200d6e:	00f5fa63          	bgeu	a1,a5,ffffffffc0200d82 <buddy_system_init_memmap+0x96>
            order_size >>= 1;
ffffffffc0200d72:	0016d79b          	srliw	a5,a3,0x1
ffffffffc0200d76:	0007869b          	sext.w	a3,a5
            order -= 1;
ffffffffc0200d7a:	377d                	addiw	a4,a4,-1
        while (order > 0 && curr_size < order_size)
ffffffffc0200d7c:	1782                	slli	a5,a5,0x20
ffffffffc0200d7e:	9381                	srli	a5,a5,0x20
ffffffffc0200d80:	f77d                	bnez	a4,ffffffffc0200d6e <buddy_system_init_memmap+0x82>
        p += order_size;
ffffffffc0200d82:	00279613          	slli	a2,a5,0x2
ffffffffc0200d86:	97b2                	add	a5,a5,a2
ffffffffc0200d88:	078e                	slli	a5,a5,0x3
ffffffffc0200d8a:	953e                	add	a0,a0,a5
    while (curr_size != 0)
ffffffffc0200d8c:	f1c5                	bnez	a1,ffffffffc0200d2c <buddy_system_init_memmap+0x40>
}
ffffffffc0200d8e:	60a2                	ld	ra,8(sp)
ffffffffc0200d90:	0141                	addi	sp,sp,16
ffffffffc0200d92:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200d94:	00001697          	auipc	a3,0x1
ffffffffc0200d98:	2e468693          	addi	a3,a3,740 # ffffffffc0202078 <commands+0x5f8>
ffffffffc0200d9c:	00001617          	auipc	a2,0x1
ffffffffc0200da0:	1e460613          	addi	a2,a2,484 # ffffffffc0201f80 <commands+0x500>
ffffffffc0200da4:	02000593          	li	a1,32
ffffffffc0200da8:	00001517          	auipc	a0,0x1
ffffffffc0200dac:	1f050513          	addi	a0,a0,496 # ffffffffc0201f98 <commands+0x518>
ffffffffc0200db0:	e04ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    assert(n > 0);
ffffffffc0200db4:	00001697          	auipc	a3,0x1
ffffffffc0200db8:	1c468693          	addi	a3,a3,452 # ffffffffc0201f78 <commands+0x4f8>
ffffffffc0200dbc:	00001617          	auipc	a2,0x1
ffffffffc0200dc0:	1c460613          	addi	a2,a2,452 # ffffffffc0201f80 <commands+0x500>
ffffffffc0200dc4:	45f1                	li	a1,28
ffffffffc0200dc6:	00001517          	auipc	a0,0x1
ffffffffc0200dca:	1d250513          	addi	a0,a0,466 # ffffffffc0201f98 <commands+0x518>
ffffffffc0200dce:	de6ff0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc0200dd2 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200dd2:	100027f3          	csrr	a5,sstatus
ffffffffc0200dd6:	8b89                	andi	a5,a5,2
ffffffffc0200dd8:	e799                	bnez	a5,ffffffffc0200de6 <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0200dda:	00005797          	auipc	a5,0x5
ffffffffc0200dde:	7767b783          	ld	a5,1910(a5) # ffffffffc0206550 <pmm_manager>
ffffffffc0200de2:	6f9c                	ld	a5,24(a5)
ffffffffc0200de4:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc0200de6:	1141                	addi	sp,sp,-16
ffffffffc0200de8:	e406                	sd	ra,8(sp)
ffffffffc0200dea:	e022                	sd	s0,0(sp)
ffffffffc0200dec:	842a                	mv	s0,a0
        intr_disable();
ffffffffc0200dee:	e78ff0ef          	jal	ra,ffffffffc0200466 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0200df2:	00005797          	auipc	a5,0x5
ffffffffc0200df6:	75e7b783          	ld	a5,1886(a5) # ffffffffc0206550 <pmm_manager>
ffffffffc0200dfa:	6f9c                	ld	a5,24(a5)
ffffffffc0200dfc:	8522                	mv	a0,s0
ffffffffc0200dfe:	9782                	jalr	a5
ffffffffc0200e00:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0200e02:	e5eff0ef          	jal	ra,ffffffffc0200460 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0200e06:	60a2                	ld	ra,8(sp)
ffffffffc0200e08:	8522                	mv	a0,s0
ffffffffc0200e0a:	6402                	ld	s0,0(sp)
ffffffffc0200e0c:	0141                	addi	sp,sp,16
ffffffffc0200e0e:	8082                	ret

ffffffffc0200e10 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200e10:	100027f3          	csrr	a5,sstatus
ffffffffc0200e14:	8b89                	andi	a5,a5,2
ffffffffc0200e16:	e799                	bnez	a5,ffffffffc0200e24 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0200e18:	00005797          	auipc	a5,0x5
ffffffffc0200e1c:	7387b783          	ld	a5,1848(a5) # ffffffffc0206550 <pmm_manager>
ffffffffc0200e20:	739c                	ld	a5,32(a5)
ffffffffc0200e22:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0200e24:	1101                	addi	sp,sp,-32
ffffffffc0200e26:	ec06                	sd	ra,24(sp)
ffffffffc0200e28:	e822                	sd	s0,16(sp)
ffffffffc0200e2a:	e426                	sd	s1,8(sp)
ffffffffc0200e2c:	842a                	mv	s0,a0
ffffffffc0200e2e:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0200e30:	e36ff0ef          	jal	ra,ffffffffc0200466 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0200e34:	00005797          	auipc	a5,0x5
ffffffffc0200e38:	71c7b783          	ld	a5,1820(a5) # ffffffffc0206550 <pmm_manager>
ffffffffc0200e3c:	739c                	ld	a5,32(a5)
ffffffffc0200e3e:	85a6                	mv	a1,s1
ffffffffc0200e40:	8522                	mv	a0,s0
ffffffffc0200e42:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200e44:	6442                	ld	s0,16(sp)
ffffffffc0200e46:	60e2                	ld	ra,24(sp)
ffffffffc0200e48:	64a2                	ld	s1,8(sp)
ffffffffc0200e4a:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200e4c:	e14ff06f          	j	ffffffffc0200460 <intr_enable>

ffffffffc0200e50 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager; //////////////////
ffffffffc0200e50:	00001797          	auipc	a5,0x1
ffffffffc0200e54:	25878793          	addi	a5,a5,600 # ffffffffc02020a8 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e58:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200e5a:	1101                	addi	sp,sp,-32
ffffffffc0200e5c:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e5e:	00001517          	auipc	a0,0x1
ffffffffc0200e62:	28250513          	addi	a0,a0,642 # ffffffffc02020e0 <buddy_system_pmm_manager+0x38>
    pmm_manager = &buddy_system_pmm_manager; //////////////////
ffffffffc0200e66:	00005497          	auipc	s1,0x5
ffffffffc0200e6a:	6ea48493          	addi	s1,s1,1770 # ffffffffc0206550 <pmm_manager>
void pmm_init(void) {
ffffffffc0200e6e:	ec06                	sd	ra,24(sp)
ffffffffc0200e70:	e822                	sd	s0,16(sp)
    pmm_manager = &buddy_system_pmm_manager; //////////////////
ffffffffc0200e72:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200e74:	a46ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0200e78:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e7a:	00005417          	auipc	s0,0x5
ffffffffc0200e7e:	6ee40413          	addi	s0,s0,1774 # ffffffffc0206568 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200e82:	679c                	ld	a5,8(a5)
ffffffffc0200e84:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e86:	57f5                	li	a5,-3
ffffffffc0200e88:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200e8a:	00001517          	auipc	a0,0x1
ffffffffc0200e8e:	26e50513          	addi	a0,a0,622 # ffffffffc02020f8 <buddy_system_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200e92:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200e94:	a26ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200e98:	46c5                	li	a3,17
ffffffffc0200e9a:	06ee                	slli	a3,a3,0x1b
ffffffffc0200e9c:	40100613          	li	a2,1025
ffffffffc0200ea0:	16fd                	addi	a3,a3,-1
ffffffffc0200ea2:	07e005b7          	lui	a1,0x7e00
ffffffffc0200ea6:	0656                	slli	a2,a2,0x15
ffffffffc0200ea8:	00001517          	auipc	a0,0x1
ffffffffc0200eac:	26850513          	addi	a0,a0,616 # ffffffffc0202110 <buddy_system_pmm_manager+0x68>
ffffffffc0200eb0:	a0aff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200eb4:	777d                	lui	a4,0xfffff
ffffffffc0200eb6:	00006797          	auipc	a5,0x6
ffffffffc0200eba:	6c978793          	addi	a5,a5,1737 # ffffffffc020757f <end+0xfff>
ffffffffc0200ebe:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200ec0:	00005517          	auipc	a0,0x5
ffffffffc0200ec4:	68050513          	addi	a0,a0,1664 # ffffffffc0206540 <npage>
ffffffffc0200ec8:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ecc:	00005597          	auipc	a1,0x5
ffffffffc0200ed0:	67c58593          	addi	a1,a1,1660 # ffffffffc0206548 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200ed4:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200ed6:	e19c                	sd	a5,0(a1)
ffffffffc0200ed8:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200eda:	4701                	li	a4,0
ffffffffc0200edc:	4885                	li	a7,1
ffffffffc0200ede:	fff80837          	lui	a6,0xfff80
ffffffffc0200ee2:	a011                	j	ffffffffc0200ee6 <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200ee4:	619c                	ld	a5,0(a1)
ffffffffc0200ee6:	97b6                	add	a5,a5,a3
ffffffffc0200ee8:	07a1                	addi	a5,a5,8
ffffffffc0200eea:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200eee:	611c                	ld	a5,0(a0)
ffffffffc0200ef0:	0705                	addi	a4,a4,1
ffffffffc0200ef2:	02868693          	addi	a3,a3,40
ffffffffc0200ef6:	01078633          	add	a2,a5,a6
ffffffffc0200efa:	fec765e3          	bltu	a4,a2,ffffffffc0200ee4 <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200efe:	6190                	ld	a2,0(a1)
ffffffffc0200f00:	00279713          	slli	a4,a5,0x2
ffffffffc0200f04:	973e                	add	a4,a4,a5
ffffffffc0200f06:	fec006b7          	lui	a3,0xfec00
ffffffffc0200f0a:	070e                	slli	a4,a4,0x3
ffffffffc0200f0c:	96b2                	add	a3,a3,a2
ffffffffc0200f0e:	96ba                	add	a3,a3,a4
ffffffffc0200f10:	c0200737          	lui	a4,0xc0200
ffffffffc0200f14:	08e6ef63          	bltu	a3,a4,ffffffffc0200fb2 <pmm_init+0x162>
ffffffffc0200f18:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200f1a:	45c5                	li	a1,17
ffffffffc0200f1c:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200f1e:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200f20:	04b6e863          	bltu	a3,a1,ffffffffc0200f70 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200f24:	609c                	ld	a5,0(s1)
ffffffffc0200f26:	7b9c                	ld	a5,48(a5)
ffffffffc0200f28:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200f2a:	00001517          	auipc	a0,0x1
ffffffffc0200f2e:	27e50513          	addi	a0,a0,638 # ffffffffc02021a8 <buddy_system_pmm_manager+0x100>
ffffffffc0200f32:	988ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200f36:	00004597          	auipc	a1,0x4
ffffffffc0200f3a:	0ca58593          	addi	a1,a1,202 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200f3e:	00005797          	auipc	a5,0x5
ffffffffc0200f42:	62b7b123          	sd	a1,1570(a5) # ffffffffc0206560 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f46:	c02007b7          	lui	a5,0xc0200
ffffffffc0200f4a:	08f5e063          	bltu	a1,a5,ffffffffc0200fca <pmm_init+0x17a>
ffffffffc0200f4e:	6010                	ld	a2,0(s0)
}
ffffffffc0200f50:	6442                	ld	s0,16(sp)
ffffffffc0200f52:	60e2                	ld	ra,24(sp)
ffffffffc0200f54:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200f56:	40c58633          	sub	a2,a1,a2
ffffffffc0200f5a:	00005797          	auipc	a5,0x5
ffffffffc0200f5e:	5ec7bf23          	sd	a2,1534(a5) # ffffffffc0206558 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f62:	00001517          	auipc	a0,0x1
ffffffffc0200f66:	26650513          	addi	a0,a0,614 # ffffffffc02021c8 <buddy_system_pmm_manager+0x120>
}
ffffffffc0200f6a:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200f6c:	94eff06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200f70:	6705                	lui	a4,0x1
ffffffffc0200f72:	177d                	addi	a4,a4,-1
ffffffffc0200f74:	96ba                	add	a3,a3,a4
ffffffffc0200f76:	777d                	lui	a4,0xfffff
ffffffffc0200f78:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200f7a:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200f7e:	00f57e63          	bgeu	a0,a5,ffffffffc0200f9a <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200f82:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200f84:	982a                	add	a6,a6,a0
ffffffffc0200f86:	00281513          	slli	a0,a6,0x2
ffffffffc0200f8a:	9542                	add	a0,a0,a6
ffffffffc0200f8c:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200f8e:	8d95                	sub	a1,a1,a3
ffffffffc0200f90:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200f92:	81b1                	srli	a1,a1,0xc
ffffffffc0200f94:	9532                	add	a0,a0,a2
ffffffffc0200f96:	9782                	jalr	a5
}
ffffffffc0200f98:	b771                	j	ffffffffc0200f24 <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200f9a:	00001617          	auipc	a2,0x1
ffffffffc0200f9e:	1de60613          	addi	a2,a2,478 # ffffffffc0202178 <buddy_system_pmm_manager+0xd0>
ffffffffc0200fa2:	06b00593          	li	a1,107
ffffffffc0200fa6:	00001517          	auipc	a0,0x1
ffffffffc0200faa:	1f250513          	addi	a0,a0,498 # ffffffffc0202198 <buddy_system_pmm_manager+0xf0>
ffffffffc0200fae:	c06ff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200fb2:	00001617          	auipc	a2,0x1
ffffffffc0200fb6:	18e60613          	addi	a2,a2,398 # ffffffffc0202140 <buddy_system_pmm_manager+0x98>
ffffffffc0200fba:	07000593          	li	a1,112
ffffffffc0200fbe:	00001517          	auipc	a0,0x1
ffffffffc0200fc2:	1aa50513          	addi	a0,a0,426 # ffffffffc0202168 <buddy_system_pmm_manager+0xc0>
ffffffffc0200fc6:	beeff0ef          	jal	ra,ffffffffc02003b4 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200fca:	86ae                	mv	a3,a1
ffffffffc0200fcc:	00001617          	auipc	a2,0x1
ffffffffc0200fd0:	17460613          	addi	a2,a2,372 # ffffffffc0202140 <buddy_system_pmm_manager+0x98>
ffffffffc0200fd4:	08b00593          	li	a1,139
ffffffffc0200fd8:	00001517          	auipc	a0,0x1
ffffffffc0200fdc:	19050513          	addi	a0,a0,400 # ffffffffc0202168 <buddy_system_pmm_manager+0xc0>
ffffffffc0200fe0:	bd4ff0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc0200fe4 <slob_free>:
}

static void slob_free(void *block, int size)
{
    slob_t *cur, *b = (slob_t *)block;
    if (!block)
ffffffffc0200fe4:	cd1d                	beqz	a0,ffffffffc0201022 <slob_free+0x3e>
        return;
    if (size)
ffffffffc0200fe6:	ed9d                	bnez	a1,ffffffffc0201024 <slob_free+0x40>

    for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
        if (cur >= cur->next && (b > cur || b < cur->next))
            break;

    if (b + b->units == cur->next)
ffffffffc0200fe8:	4114                	lw	a3,0(a0)
    for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0200fea:	00005597          	auipc	a1,0x5
ffffffffc0200fee:	02658593          	addi	a1,a1,38 # ffffffffc0206010 <slobfree>
ffffffffc0200ff2:	619c                	ld	a5,0(a1)
        if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0200ff4:	873e                	mv	a4,a5
    for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0200ff6:	679c                	ld	a5,8(a5)
ffffffffc0200ff8:	02a77b63          	bgeu	a4,a0,ffffffffc020102e <slob_free+0x4a>
ffffffffc0200ffc:	00f56463          	bltu	a0,a5,ffffffffc0201004 <slob_free+0x20>
        if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201000:	fef76ae3          	bltu	a4,a5,ffffffffc0200ff4 <slob_free+0x10>
    if (b + b->units == cur->next)
ffffffffc0201004:	00469613          	slli	a2,a3,0x4
ffffffffc0201008:	962a                	add	a2,a2,a0
ffffffffc020100a:	02c78b63          	beq	a5,a2,ffffffffc0201040 <slob_free+0x5c>
        b->next = cur->next->next;
    }
    else
        b->next = cur->next;

    if (cur + cur->units == b)
ffffffffc020100e:	4314                	lw	a3,0(a4)
        b->next = cur->next;
ffffffffc0201010:	e51c                	sd	a5,8(a0)
    if (cur + cur->units == b)
ffffffffc0201012:	00469793          	slli	a5,a3,0x4
ffffffffc0201016:	97ba                	add	a5,a5,a4
ffffffffc0201018:	02f50f63          	beq	a0,a5,ffffffffc0201056 <slob_free+0x72>
    {
        cur->units += b->units;
        cur->next = b->next;
    }
    else
        cur->next = b;
ffffffffc020101c:	e708                	sd	a0,8(a4)

    slobfree = cur;
ffffffffc020101e:	e198                	sd	a4,0(a1)
ffffffffc0201020:	8082                	ret
}
ffffffffc0201022:	8082                	ret
        b->units = SLOB_UNITS(size);
ffffffffc0201024:	00f5869b          	addiw	a3,a1,15
ffffffffc0201028:	8691                	srai	a3,a3,0x4
ffffffffc020102a:	c114                	sw	a3,0(a0)
ffffffffc020102c:	bf7d                	j	ffffffffc0200fea <slob_free+0x6>
        if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020102e:	fcf763e3          	bltu	a4,a5,ffffffffc0200ff4 <slob_free+0x10>
ffffffffc0201032:	fcf571e3          	bgeu	a0,a5,ffffffffc0200ff4 <slob_free+0x10>
    if (b + b->units == cur->next)
ffffffffc0201036:	00469613          	slli	a2,a3,0x4
ffffffffc020103a:	962a                	add	a2,a2,a0
ffffffffc020103c:	fcc799e3          	bne	a5,a2,ffffffffc020100e <slob_free+0x2a>
        b->units += cur->next->units;
ffffffffc0201040:	4390                	lw	a2,0(a5)
        b->next = cur->next->next;
ffffffffc0201042:	679c                	ld	a5,8(a5)
        b->units += cur->next->units;
ffffffffc0201044:	9eb1                	addw	a3,a3,a2
ffffffffc0201046:	c114                	sw	a3,0(a0)
    if (cur + cur->units == b)
ffffffffc0201048:	4314                	lw	a3,0(a4)
        b->next = cur->next->next;
ffffffffc020104a:	e51c                	sd	a5,8(a0)
    if (cur + cur->units == b)
ffffffffc020104c:	00469793          	slli	a5,a3,0x4
ffffffffc0201050:	97ba                	add	a5,a5,a4
ffffffffc0201052:	fcf515e3          	bne	a0,a5,ffffffffc020101c <slob_free+0x38>
        cur->units += b->units;
ffffffffc0201056:	411c                	lw	a5,0(a0)
        cur->next = b->next;
ffffffffc0201058:	6510                	ld	a2,8(a0)
    slobfree = cur;
ffffffffc020105a:	e198                	sd	a4,0(a1)
        cur->units += b->units;
ffffffffc020105c:	9ebd                	addw	a3,a3,a5
ffffffffc020105e:	c314                	sw	a3,0(a4)
        cur->next = b->next;
ffffffffc0201060:	e710                	sd	a2,8(a4)
    slobfree = cur;
ffffffffc0201062:	8082                	ret

ffffffffc0201064 <slob_alloc>:
{
ffffffffc0201064:	1101                	addi	sp,sp,-32
ffffffffc0201066:	ec06                	sd	ra,24(sp)
ffffffffc0201068:	e822                	sd	s0,16(sp)
ffffffffc020106a:	e426                	sd	s1,8(sp)
ffffffffc020106c:	e04a                	sd	s2,0(sp)
    assert(size < PGSIZE);
ffffffffc020106e:	6785                	lui	a5,0x1
ffffffffc0201070:	08f57363          	bgeu	a0,a5,ffffffffc02010f6 <slob_alloc+0x92>
    prev = slobfree;
ffffffffc0201074:	00005417          	auipc	s0,0x5
ffffffffc0201078:	f9c40413          	addi	s0,s0,-100 # ffffffffc0206010 <slobfree>
ffffffffc020107c:	6010                	ld	a2,0(s0)
    int units = SLOB_UNITS(size);
ffffffffc020107e:	053d                	addi	a0,a0,15
ffffffffc0201080:	00455913          	srli	s2,a0,0x4
    for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201084:	6618                	ld	a4,8(a2)
    int units = SLOB_UNITS(size);
ffffffffc0201086:	0009049b          	sext.w	s1,s2
        if (cur->units >= units)
ffffffffc020108a:	4314                	lw	a3,0(a4)
ffffffffc020108c:	0696d263          	bge	a3,s1,ffffffffc02010f0 <slob_alloc+0x8c>
        if (cur == slobfree)
ffffffffc0201090:	00e60a63          	beq	a2,a4,ffffffffc02010a4 <slob_alloc+0x40>
    for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201094:	671c                	ld	a5,8(a4)
        if (cur->units >= units)
ffffffffc0201096:	4394                	lw	a3,0(a5)
ffffffffc0201098:	0296d363          	bge	a3,s1,ffffffffc02010be <slob_alloc+0x5a>
        if (cur == slobfree)
ffffffffc020109c:	6010                	ld	a2,0(s0)
ffffffffc020109e:	873e                	mv	a4,a5
ffffffffc02010a0:	fee61ae3          	bne	a2,a4,ffffffffc0201094 <slob_alloc+0x30>
            cur = (slob_t *)alloc_pages(1);
ffffffffc02010a4:	4505                	li	a0,1
ffffffffc02010a6:	d2dff0ef          	jal	ra,ffffffffc0200dd2 <alloc_pages>
ffffffffc02010aa:	87aa                	mv	a5,a0
            if (!cur)
ffffffffc02010ac:	c51d                	beqz	a0,ffffffffc02010da <slob_alloc+0x76>
            slob_free(cur, PGSIZE);
ffffffffc02010ae:	6585                	lui	a1,0x1
ffffffffc02010b0:	f35ff0ef          	jal	ra,ffffffffc0200fe4 <slob_free>
            cur = slobfree;
ffffffffc02010b4:	6018                	ld	a4,0(s0)
    for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc02010b6:	671c                	ld	a5,8(a4)
        if (cur->units >= units)
ffffffffc02010b8:	4394                	lw	a3,0(a5)
ffffffffc02010ba:	fe96c1e3          	blt	a3,s1,ffffffffc020109c <slob_alloc+0x38>
            if (cur->units == units)
ffffffffc02010be:	02d48563          	beq	s1,a3,ffffffffc02010e8 <slob_alloc+0x84>
                prev->next = cur + units;
ffffffffc02010c2:	0912                	slli	s2,s2,0x4
ffffffffc02010c4:	993e                	add	s2,s2,a5
ffffffffc02010c6:	01273423          	sd	s2,8(a4) # fffffffffffff008 <end+0x3fdf8a88>
                prev->next->next = cur->next;
ffffffffc02010ca:	6790                	ld	a2,8(a5)
                prev->next->units = cur->units - units;
ffffffffc02010cc:	9e85                	subw	a3,a3,s1
ffffffffc02010ce:	00d92023          	sw	a3,0(s2)
                prev->next->next = cur->next;
ffffffffc02010d2:	00c93423          	sd	a2,8(s2)
                cur->units = units;
ffffffffc02010d6:	c384                	sw	s1,0(a5)
            slobfree = prev;
ffffffffc02010d8:	e018                	sd	a4,0(s0)
}
ffffffffc02010da:	60e2                	ld	ra,24(sp)
ffffffffc02010dc:	6442                	ld	s0,16(sp)
ffffffffc02010de:	64a2                	ld	s1,8(sp)
ffffffffc02010e0:	6902                	ld	s2,0(sp)
ffffffffc02010e2:	853e                	mv	a0,a5
ffffffffc02010e4:	6105                	addi	sp,sp,32
ffffffffc02010e6:	8082                	ret
                prev->next = cur->next;
ffffffffc02010e8:	6794                	ld	a3,8(a5)
            slobfree = prev;
ffffffffc02010ea:	e018                	sd	a4,0(s0)
                prev->next = cur->next;
ffffffffc02010ec:	e714                	sd	a3,8(a4)
            return cur;
ffffffffc02010ee:	b7f5                	j	ffffffffc02010da <slob_alloc+0x76>
        if (cur->units >= units)
ffffffffc02010f0:	87ba                	mv	a5,a4
ffffffffc02010f2:	8732                	mv	a4,a2
ffffffffc02010f4:	b7e9                	j	ffffffffc02010be <slob_alloc+0x5a>
    assert(size < PGSIZE);
ffffffffc02010f6:	00001697          	auipc	a3,0x1
ffffffffc02010fa:	11268693          	addi	a3,a3,274 # ffffffffc0202208 <buddy_system_pmm_manager+0x160>
ffffffffc02010fe:	00001617          	auipc	a2,0x1
ffffffffc0201102:	e8260613          	addi	a2,a2,-382 # ffffffffc0201f80 <commands+0x500>
ffffffffc0201106:	02300593          	li	a1,35
ffffffffc020110a:	00001517          	auipc	a0,0x1
ffffffffc020110e:	10e50513          	addi	a0,a0,270 # ffffffffc0202218 <buddy_system_pmm_manager+0x170>
ffffffffc0201112:	aa2ff0ef          	jal	ra,ffffffffc02003b4 <__panic>

ffffffffc0201116 <slub_alloc.part.0>:
void slub_init(void)
{
    cprintf("slub_init() succeeded!\n");
}

void *slub_alloc(size_t size)
ffffffffc0201116:	1101                	addi	sp,sp,-32
ffffffffc0201118:	e822                	sd	s0,16(sp)
ffffffffc020111a:	842a                	mv	s0,a0
    {
        m = slob_alloc(size + SLOB_UNIT);
        return m ? (void *)(m + 1) : 0;
    }

    bb = slob_alloc(sizeof(bigblock_t));
ffffffffc020111c:	4561                	li	a0,24
void *slub_alloc(size_t size)
ffffffffc020111e:	ec06                	sd	ra,24(sp)
ffffffffc0201120:	e426                	sd	s1,8(sp)
    bb = slob_alloc(sizeof(bigblock_t));
ffffffffc0201122:	f43ff0ef          	jal	ra,ffffffffc0201064 <slob_alloc>
    if (!bb)
ffffffffc0201126:	c915                	beqz	a0,ffffffffc020115a <slub_alloc.part.0+0x44>
        return 0;

    bb->order = ((size - 1) >> PGSHIFT) + 1;
ffffffffc0201128:	fff40793          	addi	a5,s0,-1
ffffffffc020112c:	83b1                	srli	a5,a5,0xc
ffffffffc020112e:	84aa                	mv	s1,a0
ffffffffc0201130:	0017851b          	addiw	a0,a5,1
ffffffffc0201134:	c088                	sw	a0,0(s1)
    bb->pages = (void *)alloc_pages(bb->order);
ffffffffc0201136:	c9dff0ef          	jal	ra,ffffffffc0200dd2 <alloc_pages>
ffffffffc020113a:	e488                	sd	a0,8(s1)
ffffffffc020113c:	842a                	mv	s0,a0

    if (bb->pages)
ffffffffc020113e:	c50d                	beqz	a0,ffffffffc0201168 <slub_alloc.part.0+0x52>
    {
        bb->next = bigblocks;
ffffffffc0201140:	00005797          	auipc	a5,0x5
ffffffffc0201144:	43078793          	addi	a5,a5,1072 # ffffffffc0206570 <bigblocks>
ffffffffc0201148:	6398                	ld	a4,0(a5)
        return bb->pages;
    }

    slob_free(bb, sizeof(bigblock_t));
    return 0;
}
ffffffffc020114a:	60e2                	ld	ra,24(sp)
ffffffffc020114c:	8522                	mv	a0,s0
ffffffffc020114e:	6442                	ld	s0,16(sp)
        bigblocks = bb;
ffffffffc0201150:	e384                	sd	s1,0(a5)
        bb->next = bigblocks;
ffffffffc0201152:	e898                	sd	a4,16(s1)
}
ffffffffc0201154:	64a2                	ld	s1,8(sp)
ffffffffc0201156:	6105                	addi	sp,sp,32
ffffffffc0201158:	8082                	ret
        return 0;
ffffffffc020115a:	4401                	li	s0,0
}
ffffffffc020115c:	60e2                	ld	ra,24(sp)
ffffffffc020115e:	8522                	mv	a0,s0
ffffffffc0201160:	6442                	ld	s0,16(sp)
ffffffffc0201162:	64a2                	ld	s1,8(sp)
ffffffffc0201164:	6105                	addi	sp,sp,32
ffffffffc0201166:	8082                	ret
    slob_free(bb, sizeof(bigblock_t));
ffffffffc0201168:	8526                	mv	a0,s1
ffffffffc020116a:	45e1                	li	a1,24
ffffffffc020116c:	e79ff0ef          	jal	ra,ffffffffc0200fe4 <slob_free>
}
ffffffffc0201170:	60e2                	ld	ra,24(sp)
ffffffffc0201172:	8522                	mv	a0,s0
ffffffffc0201174:	6442                	ld	s0,16(sp)
ffffffffc0201176:	64a2                	ld	s1,8(sp)
ffffffffc0201178:	6105                	addi	sp,sp,32
ffffffffc020117a:	8082                	ret

ffffffffc020117c <slub_init>:
    cprintf("slub_init() succeeded!\n");
ffffffffc020117c:	00001517          	auipc	a0,0x1
ffffffffc0201180:	0b450513          	addi	a0,a0,180 # ffffffffc0202230 <buddy_system_pmm_manager+0x188>
ffffffffc0201184:	f37fe06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0201188 <slub_free>:

void slub_free(void *block)
{
    bigblock_t *bb, **last = &bigblocks;

    if (!block)
ffffffffc0201188:	c531                	beqz	a0,ffffffffc02011d4 <slub_free+0x4c>
        return;

    if (!((unsigned long)block & (PGSIZE - 1)))
ffffffffc020118a:	03451793          	slli	a5,a0,0x34
ffffffffc020118e:	e7a1                	bnez	a5,ffffffffc02011d6 <slub_free+0x4e>
    {
        for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201190:	00005697          	auipc	a3,0x5
ffffffffc0201194:	3e068693          	addi	a3,a3,992 # ffffffffc0206570 <bigblocks>
ffffffffc0201198:	629c                	ld	a5,0(a3)
ffffffffc020119a:	cf95                	beqz	a5,ffffffffc02011d6 <slub_free+0x4e>
{
ffffffffc020119c:	1141                	addi	sp,sp,-16
ffffffffc020119e:	e406                	sd	ra,8(sp)
ffffffffc02011a0:	e022                	sd	s0,0(sp)
ffffffffc02011a2:	a021                	j	ffffffffc02011aa <slub_free+0x22>
        for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc02011a4:	01040693          	addi	a3,s0,16
ffffffffc02011a8:	c385                	beqz	a5,ffffffffc02011c8 <slub_free+0x40>
        {
            if (bb->pages == block)
ffffffffc02011aa:	6798                	ld	a4,8(a5)
ffffffffc02011ac:	843e                	mv	s0,a5
            {
                *last = bb->next;
ffffffffc02011ae:	6b9c                	ld	a5,16(a5)
            if (bb->pages == block)
ffffffffc02011b0:	fea71ae3          	bne	a4,a0,ffffffffc02011a4 <slub_free+0x1c>
                free_pages((struct Page *)block, bb->order);
ffffffffc02011b4:	400c                	lw	a1,0(s0)
                *last = bb->next;
ffffffffc02011b6:	e29c                	sd	a5,0(a3)
                free_pages((struct Page *)block, bb->order);
ffffffffc02011b8:	c59ff0ef          	jal	ra,ffffffffc0200e10 <free_pages>
                slob_free(bb, sizeof(bigblock_t));
ffffffffc02011bc:	8522                	mv	a0,s0
        }
    }

    slob_free((slob_t *)block - 1, 0);
    return;
}
ffffffffc02011be:	6402                	ld	s0,0(sp)
ffffffffc02011c0:	60a2                	ld	ra,8(sp)
                slob_free(bb, sizeof(bigblock_t));
ffffffffc02011c2:	45e1                	li	a1,24
}
ffffffffc02011c4:	0141                	addi	sp,sp,16
    slob_free((slob_t *)block - 1, 0);
ffffffffc02011c6:	bd39                	j	ffffffffc0200fe4 <slob_free>
}
ffffffffc02011c8:	6402                	ld	s0,0(sp)
ffffffffc02011ca:	60a2                	ld	ra,8(sp)
    slob_free((slob_t *)block - 1, 0);
ffffffffc02011cc:	4581                	li	a1,0
ffffffffc02011ce:	1541                	addi	a0,a0,-16
}
ffffffffc02011d0:	0141                	addi	sp,sp,16
    slob_free((slob_t *)block - 1, 0);
ffffffffc02011d2:	bd09                	j	ffffffffc0200fe4 <slob_free>
ffffffffc02011d4:	8082                	ret
ffffffffc02011d6:	4581                	li	a1,0
ffffffffc02011d8:	1541                	addi	a0,a0,-16
ffffffffc02011da:	b529                	j	ffffffffc0200fe4 <slob_free>

ffffffffc02011dc <slub_check>:
        len++;
    return len;
}

void slub_check()
{
ffffffffc02011dc:	1101                	addi	sp,sp,-32
    cprintf("slub check begin\n");
ffffffffc02011de:	00001517          	auipc	a0,0x1
ffffffffc02011e2:	06a50513          	addi	a0,a0,106 # ffffffffc0202248 <buddy_system_pmm_manager+0x1a0>
{
ffffffffc02011e6:	e822                	sd	s0,16(sp)
ffffffffc02011e8:	ec06                	sd	ra,24(sp)
ffffffffc02011ea:	e426                	sd	s1,8(sp)
ffffffffc02011ec:	e04a                	sd	s2,0(sp)
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02011ee:	00005417          	auipc	s0,0x5
ffffffffc02011f2:	e2240413          	addi	s0,s0,-478 # ffffffffc0206010 <slobfree>
    cprintf("slub check begin\n");
ffffffffc02011f6:	ec5fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02011fa:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc02011fc:	4581                	li	a1,0
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02011fe:	671c                	ld	a5,8(a4)
ffffffffc0201200:	00f70663          	beq	a4,a5,ffffffffc020120c <slub_check+0x30>
ffffffffc0201204:	679c                	ld	a5,8(a5)
        len++;
ffffffffc0201206:	2585                	addiw	a1,a1,1
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201208:	fef71ee3          	bne	a4,a5,ffffffffc0201204 <slub_check+0x28>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc020120c:	00001517          	auipc	a0,0x1
ffffffffc0201210:	05450513          	addi	a0,a0,84 # ffffffffc0202260 <buddy_system_pmm_manager+0x1b8>
ffffffffc0201214:	ea7fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (size < PGSIZE - SLOB_UNIT)
ffffffffc0201218:	6505                	lui	a0,0x1
ffffffffc020121a:	efdff0ef          	jal	ra,ffffffffc0201116 <slub_alloc.part.0>
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020121e:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc0201220:	4581                	li	a1,0
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201222:	671c                	ld	a5,8(a4)
ffffffffc0201224:	00f70663          	beq	a4,a5,ffffffffc0201230 <slub_check+0x54>
ffffffffc0201228:	679c                	ld	a5,8(a5)
        len++;
ffffffffc020122a:	2585                	addiw	a1,a1,1
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020122c:	fef71ee3          	bne	a4,a5,ffffffffc0201228 <slub_check+0x4c>
    void *p1 = slub_alloc(4096);
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc0201230:	00001517          	auipc	a0,0x1
ffffffffc0201234:	03050513          	addi	a0,a0,48 # ffffffffc0202260 <buddy_system_pmm_manager+0x1b8>
ffffffffc0201238:	e83fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
        m = slob_alloc(size + SLOB_UNIT);
ffffffffc020123c:	4549                	li	a0,18
ffffffffc020123e:	e27ff0ef          	jal	ra,ffffffffc0201064 <slob_alloc>
ffffffffc0201242:	892a                	mv	s2,a0
        return m ? (void *)(m + 1) : 0;
ffffffffc0201244:	c119                	beqz	a0,ffffffffc020124a <slub_check+0x6e>
ffffffffc0201246:	01050913          	addi	s2,a0,16
        m = slob_alloc(size + SLOB_UNIT);
ffffffffc020124a:	4549                	li	a0,18
ffffffffc020124c:	e19ff0ef          	jal	ra,ffffffffc0201064 <slob_alloc>
ffffffffc0201250:	84aa                	mv	s1,a0
        return m ? (void *)(m + 1) : 0;
ffffffffc0201252:	c119                	beqz	a0,ffffffffc0201258 <slub_check+0x7c>
ffffffffc0201254:	01050493          	addi	s1,a0,16
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201258:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc020125a:	4581                	li	a1,0
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020125c:	671c                	ld	a5,8(a4)
ffffffffc020125e:	00f70663          	beq	a4,a5,ffffffffc020126a <slub_check+0x8e>
ffffffffc0201262:	679c                	ld	a5,8(a5)
        len++;
ffffffffc0201264:	2585                	addiw	a1,a1,1
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201266:	fef71ee3          	bne	a4,a5,ffffffffc0201262 <slub_check+0x86>
    void *p2 = slub_alloc(2);
    void *p3 = slub_alloc(2);
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc020126a:	00001517          	auipc	a0,0x1
ffffffffc020126e:	ff650513          	addi	a0,a0,-10 # ffffffffc0202260 <buddy_system_pmm_manager+0x1b8>
ffffffffc0201272:	e49fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    slub_free(p2);
ffffffffc0201276:	854a                	mv	a0,s2
ffffffffc0201278:	f11ff0ef          	jal	ra,ffffffffc0201188 <slub_free>
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020127c:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc020127e:	4581                	li	a1,0
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc0201280:	671c                	ld	a5,8(a4)
ffffffffc0201282:	00f70663          	beq	a4,a5,ffffffffc020128e <slub_check+0xb2>
ffffffffc0201286:	679c                	ld	a5,8(a5)
        len++;
ffffffffc0201288:	2585                	addiw	a1,a1,1
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc020128a:	fef71ee3          	bne	a4,a5,ffffffffc0201286 <slub_check+0xaa>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc020128e:	00001517          	auipc	a0,0x1
ffffffffc0201292:	fd250513          	addi	a0,a0,-46 # ffffffffc0202260 <buddy_system_pmm_manager+0x1b8>
ffffffffc0201296:	e25fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    slub_free(p3);
ffffffffc020129a:	8526                	mv	a0,s1
ffffffffc020129c:	eedff0ef          	jal	ra,ffffffffc0201188 <slub_free>
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02012a0:	6018                	ld	a4,0(s0)
    int len = 0;
ffffffffc02012a2:	4581                	li	a1,0
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02012a4:	671c                	ld	a5,8(a4)
ffffffffc02012a6:	00e78663          	beq	a5,a4,ffffffffc02012b2 <slub_check+0xd6>
ffffffffc02012aa:	679c                	ld	a5,8(a5)
        len++;
ffffffffc02012ac:	2585                	addiw	a1,a1,1
    for (slob_t *curr = slobfree->next; curr != slobfree; curr = curr->next)
ffffffffc02012ae:	fef71ee3          	bne	a4,a5,ffffffffc02012aa <slub_check+0xce>
    cprintf("slobfree len: %d\n", slobfree_len());
ffffffffc02012b2:	00001517          	auipc	a0,0x1
ffffffffc02012b6:	fae50513          	addi	a0,a0,-82 # ffffffffc0202260 <buddy_system_pmm_manager+0x1b8>
ffffffffc02012ba:	e01fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("slub check end\n");
ffffffffc02012be:	6442                	ld	s0,16(sp)
ffffffffc02012c0:	60e2                	ld	ra,24(sp)
ffffffffc02012c2:	64a2                	ld	s1,8(sp)
ffffffffc02012c4:	6902                	ld	s2,0(sp)
    cprintf("slub check end\n");
ffffffffc02012c6:	00001517          	auipc	a0,0x1
ffffffffc02012ca:	fb250513          	addi	a0,a0,-78 # ffffffffc0202278 <buddy_system_pmm_manager+0x1d0>
ffffffffc02012ce:	6105                	addi	sp,sp,32
    cprintf("slub check end\n");
ffffffffc02012d0:	debfe06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02012d4 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02012d4:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012d8:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc02012da:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012de:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02012e0:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012e4:	f022                	sd	s0,32(sp)
ffffffffc02012e6:	ec26                	sd	s1,24(sp)
ffffffffc02012e8:	e84a                	sd	s2,16(sp)
ffffffffc02012ea:	f406                	sd	ra,40(sp)
ffffffffc02012ec:	e44e                	sd	s3,8(sp)
ffffffffc02012ee:	84aa                	mv	s1,a0
ffffffffc02012f0:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02012f2:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc02012f6:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc02012f8:	03067e63          	bgeu	a2,a6,ffffffffc0201334 <printnum+0x60>
ffffffffc02012fc:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02012fe:	00805763          	blez	s0,ffffffffc020130c <printnum+0x38>
ffffffffc0201302:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201304:	85ca                	mv	a1,s2
ffffffffc0201306:	854e                	mv	a0,s3
ffffffffc0201308:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020130a:	fc65                	bnez	s0,ffffffffc0201302 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020130c:	1a02                	slli	s4,s4,0x20
ffffffffc020130e:	00001797          	auipc	a5,0x1
ffffffffc0201312:	f7a78793          	addi	a5,a5,-134 # ffffffffc0202288 <buddy_system_pmm_manager+0x1e0>
ffffffffc0201316:	020a5a13          	srli	s4,s4,0x20
ffffffffc020131a:	9a3e                	add	s4,s4,a5
}
ffffffffc020131c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020131e:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201322:	70a2                	ld	ra,40(sp)
ffffffffc0201324:	69a2                	ld	s3,8(sp)
ffffffffc0201326:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201328:	85ca                	mv	a1,s2
ffffffffc020132a:	87a6                	mv	a5,s1
}
ffffffffc020132c:	6942                	ld	s2,16(sp)
ffffffffc020132e:	64e2                	ld	s1,24(sp)
ffffffffc0201330:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201332:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201334:	03065633          	divu	a2,a2,a6
ffffffffc0201338:	8722                	mv	a4,s0
ffffffffc020133a:	f9bff0ef          	jal	ra,ffffffffc02012d4 <printnum>
ffffffffc020133e:	b7f9                	j	ffffffffc020130c <printnum+0x38>

ffffffffc0201340 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201340:	7119                	addi	sp,sp,-128
ffffffffc0201342:	f4a6                	sd	s1,104(sp)
ffffffffc0201344:	f0ca                	sd	s2,96(sp)
ffffffffc0201346:	ecce                	sd	s3,88(sp)
ffffffffc0201348:	e8d2                	sd	s4,80(sp)
ffffffffc020134a:	e4d6                	sd	s5,72(sp)
ffffffffc020134c:	e0da                	sd	s6,64(sp)
ffffffffc020134e:	fc5e                	sd	s7,56(sp)
ffffffffc0201350:	f06a                	sd	s10,32(sp)
ffffffffc0201352:	fc86                	sd	ra,120(sp)
ffffffffc0201354:	f8a2                	sd	s0,112(sp)
ffffffffc0201356:	f862                	sd	s8,48(sp)
ffffffffc0201358:	f466                	sd	s9,40(sp)
ffffffffc020135a:	ec6e                	sd	s11,24(sp)
ffffffffc020135c:	892a                	mv	s2,a0
ffffffffc020135e:	84ae                	mv	s1,a1
ffffffffc0201360:	8d32                	mv	s10,a2
ffffffffc0201362:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201364:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0201368:	5b7d                	li	s6,-1
ffffffffc020136a:	00001a97          	auipc	s5,0x1
ffffffffc020136e:	f52a8a93          	addi	s5,s5,-174 # ffffffffc02022bc <buddy_system_pmm_manager+0x214>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201372:	00001b97          	auipc	s7,0x1
ffffffffc0201376:	126b8b93          	addi	s7,s7,294 # ffffffffc0202498 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020137a:	000d4503          	lbu	a0,0(s10)
ffffffffc020137e:	001d0413          	addi	s0,s10,1
ffffffffc0201382:	01350a63          	beq	a0,s3,ffffffffc0201396 <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0201386:	c121                	beqz	a0,ffffffffc02013c6 <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0201388:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020138a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc020138c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020138e:	fff44503          	lbu	a0,-1(s0)
ffffffffc0201392:	ff351ae3          	bne	a0,s3,ffffffffc0201386 <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201396:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020139a:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc020139e:	4c81                	li	s9,0
ffffffffc02013a0:	4881                	li	a7,0
        width = precision = -1;
ffffffffc02013a2:	5c7d                	li	s8,-1
ffffffffc02013a4:	5dfd                	li	s11,-1
ffffffffc02013a6:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc02013aa:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013ac:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02013b0:	0ff5f593          	zext.b	a1,a1
ffffffffc02013b4:	00140d13          	addi	s10,s0,1
ffffffffc02013b8:	04b56263          	bltu	a0,a1,ffffffffc02013fc <vprintfmt+0xbc>
ffffffffc02013bc:	058a                	slli	a1,a1,0x2
ffffffffc02013be:	95d6                	add	a1,a1,s5
ffffffffc02013c0:	4194                	lw	a3,0(a1)
ffffffffc02013c2:	96d6                	add	a3,a3,s5
ffffffffc02013c4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02013c6:	70e6                	ld	ra,120(sp)
ffffffffc02013c8:	7446                	ld	s0,112(sp)
ffffffffc02013ca:	74a6                	ld	s1,104(sp)
ffffffffc02013cc:	7906                	ld	s2,96(sp)
ffffffffc02013ce:	69e6                	ld	s3,88(sp)
ffffffffc02013d0:	6a46                	ld	s4,80(sp)
ffffffffc02013d2:	6aa6                	ld	s5,72(sp)
ffffffffc02013d4:	6b06                	ld	s6,64(sp)
ffffffffc02013d6:	7be2                	ld	s7,56(sp)
ffffffffc02013d8:	7c42                	ld	s8,48(sp)
ffffffffc02013da:	7ca2                	ld	s9,40(sp)
ffffffffc02013dc:	7d02                	ld	s10,32(sp)
ffffffffc02013de:	6de2                	ld	s11,24(sp)
ffffffffc02013e0:	6109                	addi	sp,sp,128
ffffffffc02013e2:	8082                	ret
            padc = '0';
ffffffffc02013e4:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02013e6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013ea:	846a                	mv	s0,s10
ffffffffc02013ec:	00140d13          	addi	s10,s0,1
ffffffffc02013f0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02013f4:	0ff5f593          	zext.b	a1,a1
ffffffffc02013f8:	fcb572e3          	bgeu	a0,a1,ffffffffc02013bc <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02013fc:	85a6                	mv	a1,s1
ffffffffc02013fe:	02500513          	li	a0,37
ffffffffc0201402:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201404:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201408:	8d22                	mv	s10,s0
ffffffffc020140a:	f73788e3          	beq	a5,s3,ffffffffc020137a <vprintfmt+0x3a>
ffffffffc020140e:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0201412:	1d7d                	addi	s10,s10,-1
ffffffffc0201414:	ff379de3          	bne	a5,s3,ffffffffc020140e <vprintfmt+0xce>
ffffffffc0201418:	b78d                	j	ffffffffc020137a <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020141a:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc020141e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201422:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201424:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201428:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc020142c:	02d86463          	bltu	a6,a3,ffffffffc0201454 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0201430:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201434:	002c169b          	slliw	a3,s8,0x2
ffffffffc0201438:	0186873b          	addw	a4,a3,s8
ffffffffc020143c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201440:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0201442:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201446:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201448:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc020144c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201450:	fed870e3          	bgeu	a6,a3,ffffffffc0201430 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0201454:	f40ddce3          	bgez	s11,ffffffffc02013ac <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0201458:	8de2                	mv	s11,s8
ffffffffc020145a:	5c7d                	li	s8,-1
ffffffffc020145c:	bf81                	j	ffffffffc02013ac <vprintfmt+0x6c>
            if (width < 0)
ffffffffc020145e:	fffdc693          	not	a3,s11
ffffffffc0201462:	96fd                	srai	a3,a3,0x3f
ffffffffc0201464:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201468:	00144603          	lbu	a2,1(s0)
ffffffffc020146c:	2d81                	sext.w	s11,s11
ffffffffc020146e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0201470:	bf35                	j	ffffffffc02013ac <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0201472:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201476:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020147a:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020147c:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc020147e:	bfd9                	j	ffffffffc0201454 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0201480:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201482:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201486:	01174463          	blt	a4,a7,ffffffffc020148e <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020148a:	1a088e63          	beqz	a7,ffffffffc0201646 <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc020148e:	000a3603          	ld	a2,0(s4)
ffffffffc0201492:	46c1                	li	a3,16
ffffffffc0201494:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201496:	2781                	sext.w	a5,a5
ffffffffc0201498:	876e                	mv	a4,s11
ffffffffc020149a:	85a6                	mv	a1,s1
ffffffffc020149c:	854a                	mv	a0,s2
ffffffffc020149e:	e37ff0ef          	jal	ra,ffffffffc02012d4 <printnum>
            break;
ffffffffc02014a2:	bde1                	j	ffffffffc020137a <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc02014a4:	000a2503          	lw	a0,0(s4)
ffffffffc02014a8:	85a6                	mv	a1,s1
ffffffffc02014aa:	0a21                	addi	s4,s4,8
ffffffffc02014ac:	9902                	jalr	s2
            break;
ffffffffc02014ae:	b5f1                	j	ffffffffc020137a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02014b0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02014b2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02014b6:	01174463          	blt	a4,a7,ffffffffc02014be <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02014ba:	18088163          	beqz	a7,ffffffffc020163c <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02014be:	000a3603          	ld	a2,0(s4)
ffffffffc02014c2:	46a9                	li	a3,10
ffffffffc02014c4:	8a2e                	mv	s4,a1
ffffffffc02014c6:	bfc1                	j	ffffffffc0201496 <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014c8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02014cc:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014ce:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014d0:	bdf1                	j	ffffffffc02013ac <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02014d2:	85a6                	mv	a1,s1
ffffffffc02014d4:	02500513          	li	a0,37
ffffffffc02014d8:	9902                	jalr	s2
            break;
ffffffffc02014da:	b545                	j	ffffffffc020137a <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014dc:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02014e0:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014e2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02014e4:	b5e1                	j	ffffffffc02013ac <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02014e6:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02014e8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02014ec:	01174463          	blt	a4,a7,ffffffffc02014f4 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02014f0:	14088163          	beqz	a7,ffffffffc0201632 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02014f4:	000a3603          	ld	a2,0(s4)
ffffffffc02014f8:	46a1                	li	a3,8
ffffffffc02014fa:	8a2e                	mv	s4,a1
ffffffffc02014fc:	bf69                	j	ffffffffc0201496 <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02014fe:	03000513          	li	a0,48
ffffffffc0201502:	85a6                	mv	a1,s1
ffffffffc0201504:	e03e                	sd	a5,0(sp)
ffffffffc0201506:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201508:	85a6                	mv	a1,s1
ffffffffc020150a:	07800513          	li	a0,120
ffffffffc020150e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201510:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201512:	6782                	ld	a5,0(sp)
ffffffffc0201514:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201516:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020151a:	bfb5                	j	ffffffffc0201496 <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020151c:	000a3403          	ld	s0,0(s4)
ffffffffc0201520:	008a0713          	addi	a4,s4,8
ffffffffc0201524:	e03a                	sd	a4,0(sp)
ffffffffc0201526:	14040263          	beqz	s0,ffffffffc020166a <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020152a:	0fb05763          	blez	s11,ffffffffc0201618 <vprintfmt+0x2d8>
ffffffffc020152e:	02d00693          	li	a3,45
ffffffffc0201532:	0cd79163          	bne	a5,a3,ffffffffc02015f4 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201536:	00044783          	lbu	a5,0(s0)
ffffffffc020153a:	0007851b          	sext.w	a0,a5
ffffffffc020153e:	cf85                	beqz	a5,ffffffffc0201576 <vprintfmt+0x236>
ffffffffc0201540:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201544:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201548:	000c4563          	bltz	s8,ffffffffc0201552 <vprintfmt+0x212>
ffffffffc020154c:	3c7d                	addiw	s8,s8,-1
ffffffffc020154e:	036c0263          	beq	s8,s6,ffffffffc0201572 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0201552:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201554:	0e0c8e63          	beqz	s9,ffffffffc0201650 <vprintfmt+0x310>
ffffffffc0201558:	3781                	addiw	a5,a5,-32
ffffffffc020155a:	0ef47b63          	bgeu	s0,a5,ffffffffc0201650 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc020155e:	03f00513          	li	a0,63
ffffffffc0201562:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201564:	000a4783          	lbu	a5,0(s4)
ffffffffc0201568:	3dfd                	addiw	s11,s11,-1
ffffffffc020156a:	0a05                	addi	s4,s4,1
ffffffffc020156c:	0007851b          	sext.w	a0,a5
ffffffffc0201570:	ffe1                	bnez	a5,ffffffffc0201548 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0201572:	01b05963          	blez	s11,ffffffffc0201584 <vprintfmt+0x244>
ffffffffc0201576:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201578:	85a6                	mv	a1,s1
ffffffffc020157a:	02000513          	li	a0,32
ffffffffc020157e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201580:	fe0d9be3          	bnez	s11,ffffffffc0201576 <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201584:	6a02                	ld	s4,0(sp)
ffffffffc0201586:	bbd5                	j	ffffffffc020137a <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201588:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020158a:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc020158e:	01174463          	blt	a4,a7,ffffffffc0201596 <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0201592:	08088d63          	beqz	a7,ffffffffc020162c <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc0201596:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020159a:	0a044d63          	bltz	s0,ffffffffc0201654 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc020159e:	8622                	mv	a2,s0
ffffffffc02015a0:	8a66                	mv	s4,s9
ffffffffc02015a2:	46a9                	li	a3,10
ffffffffc02015a4:	bdcd                	j	ffffffffc0201496 <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc02015a6:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015aa:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02015ac:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02015ae:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02015b2:	8fb5                	xor	a5,a5,a3
ffffffffc02015b4:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015b8:	02d74163          	blt	a4,a3,ffffffffc02015da <vprintfmt+0x29a>
ffffffffc02015bc:	00369793          	slli	a5,a3,0x3
ffffffffc02015c0:	97de                	add	a5,a5,s7
ffffffffc02015c2:	639c                	ld	a5,0(a5)
ffffffffc02015c4:	cb99                	beqz	a5,ffffffffc02015da <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02015c6:	86be                	mv	a3,a5
ffffffffc02015c8:	00001617          	auipc	a2,0x1
ffffffffc02015cc:	cf060613          	addi	a2,a2,-784 # ffffffffc02022b8 <buddy_system_pmm_manager+0x210>
ffffffffc02015d0:	85a6                	mv	a1,s1
ffffffffc02015d2:	854a                	mv	a0,s2
ffffffffc02015d4:	0ce000ef          	jal	ra,ffffffffc02016a2 <printfmt>
ffffffffc02015d8:	b34d                	j	ffffffffc020137a <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02015da:	00001617          	auipc	a2,0x1
ffffffffc02015de:	cce60613          	addi	a2,a2,-818 # ffffffffc02022a8 <buddy_system_pmm_manager+0x200>
ffffffffc02015e2:	85a6                	mv	a1,s1
ffffffffc02015e4:	854a                	mv	a0,s2
ffffffffc02015e6:	0bc000ef          	jal	ra,ffffffffc02016a2 <printfmt>
ffffffffc02015ea:	bb41                	j	ffffffffc020137a <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02015ec:	00001417          	auipc	s0,0x1
ffffffffc02015f0:	cb440413          	addi	s0,s0,-844 # ffffffffc02022a0 <buddy_system_pmm_manager+0x1f8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02015f4:	85e2                	mv	a1,s8
ffffffffc02015f6:	8522                	mv	a0,s0
ffffffffc02015f8:	e43e                	sd	a5,8(sp)
ffffffffc02015fa:	1cc000ef          	jal	ra,ffffffffc02017c6 <strnlen>
ffffffffc02015fe:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201602:	01b05b63          	blez	s11,ffffffffc0201618 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc0201606:	67a2                	ld	a5,8(sp)
ffffffffc0201608:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020160c:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020160e:	85a6                	mv	a1,s1
ffffffffc0201610:	8552                	mv	a0,s4
ffffffffc0201612:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201614:	fe0d9ce3          	bnez	s11,ffffffffc020160c <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201618:	00044783          	lbu	a5,0(s0)
ffffffffc020161c:	00140a13          	addi	s4,s0,1
ffffffffc0201620:	0007851b          	sext.w	a0,a5
ffffffffc0201624:	d3a5                	beqz	a5,ffffffffc0201584 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201626:	05e00413          	li	s0,94
ffffffffc020162a:	bf39                	j	ffffffffc0201548 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc020162c:	000a2403          	lw	s0,0(s4)
ffffffffc0201630:	b7ad                	j	ffffffffc020159a <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0201632:	000a6603          	lwu	a2,0(s4)
ffffffffc0201636:	46a1                	li	a3,8
ffffffffc0201638:	8a2e                	mv	s4,a1
ffffffffc020163a:	bdb1                	j	ffffffffc0201496 <vprintfmt+0x156>
ffffffffc020163c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201640:	46a9                	li	a3,10
ffffffffc0201642:	8a2e                	mv	s4,a1
ffffffffc0201644:	bd89                	j	ffffffffc0201496 <vprintfmt+0x156>
ffffffffc0201646:	000a6603          	lwu	a2,0(s4)
ffffffffc020164a:	46c1                	li	a3,16
ffffffffc020164c:	8a2e                	mv	s4,a1
ffffffffc020164e:	b5a1                	j	ffffffffc0201496 <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0201650:	9902                	jalr	s2
ffffffffc0201652:	bf09                	j	ffffffffc0201564 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0201654:	85a6                	mv	a1,s1
ffffffffc0201656:	02d00513          	li	a0,45
ffffffffc020165a:	e03e                	sd	a5,0(sp)
ffffffffc020165c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020165e:	6782                	ld	a5,0(sp)
ffffffffc0201660:	8a66                	mv	s4,s9
ffffffffc0201662:	40800633          	neg	a2,s0
ffffffffc0201666:	46a9                	li	a3,10
ffffffffc0201668:	b53d                	j	ffffffffc0201496 <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020166a:	03b05163          	blez	s11,ffffffffc020168c <vprintfmt+0x34c>
ffffffffc020166e:	02d00693          	li	a3,45
ffffffffc0201672:	f6d79de3          	bne	a5,a3,ffffffffc02015ec <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc0201676:	00001417          	auipc	s0,0x1
ffffffffc020167a:	c2a40413          	addi	s0,s0,-982 # ffffffffc02022a0 <buddy_system_pmm_manager+0x1f8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020167e:	02800793          	li	a5,40
ffffffffc0201682:	02800513          	li	a0,40
ffffffffc0201686:	00140a13          	addi	s4,s0,1
ffffffffc020168a:	bd6d                	j	ffffffffc0201544 <vprintfmt+0x204>
ffffffffc020168c:	00001a17          	auipc	s4,0x1
ffffffffc0201690:	c15a0a13          	addi	s4,s4,-1003 # ffffffffc02022a1 <buddy_system_pmm_manager+0x1f9>
ffffffffc0201694:	02800513          	li	a0,40
ffffffffc0201698:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020169c:	05e00413          	li	s0,94
ffffffffc02016a0:	b565                	j	ffffffffc0201548 <vprintfmt+0x208>

ffffffffc02016a2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016a2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02016a4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016a8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02016aa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02016ac:	ec06                	sd	ra,24(sp)
ffffffffc02016ae:	f83a                	sd	a4,48(sp)
ffffffffc02016b0:	fc3e                	sd	a5,56(sp)
ffffffffc02016b2:	e0c2                	sd	a6,64(sp)
ffffffffc02016b4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02016b6:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02016b8:	c89ff0ef          	jal	ra,ffffffffc0201340 <vprintfmt>
}
ffffffffc02016bc:	60e2                	ld	ra,24(sp)
ffffffffc02016be:	6161                	addi	sp,sp,80
ffffffffc02016c0:	8082                	ret

ffffffffc02016c2 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02016c2:	715d                	addi	sp,sp,-80
ffffffffc02016c4:	e486                	sd	ra,72(sp)
ffffffffc02016c6:	e0a6                	sd	s1,64(sp)
ffffffffc02016c8:	fc4a                	sd	s2,56(sp)
ffffffffc02016ca:	f84e                	sd	s3,48(sp)
ffffffffc02016cc:	f452                	sd	s4,40(sp)
ffffffffc02016ce:	f056                	sd	s5,32(sp)
ffffffffc02016d0:	ec5a                	sd	s6,24(sp)
ffffffffc02016d2:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02016d4:	c901                	beqz	a0,ffffffffc02016e4 <readline+0x22>
ffffffffc02016d6:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02016d8:	00001517          	auipc	a0,0x1
ffffffffc02016dc:	be050513          	addi	a0,a0,-1056 # ffffffffc02022b8 <buddy_system_pmm_manager+0x210>
ffffffffc02016e0:	9dbfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc02016e4:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016e6:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02016e8:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02016ea:	4aa9                	li	s5,10
ffffffffc02016ec:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02016ee:	00005b97          	auipc	s7,0x5
ffffffffc02016f2:	a42b8b93          	addi	s7,s7,-1470 # ffffffffc0206130 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02016f6:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02016fa:	a39fe0ef          	jal	ra,ffffffffc0200132 <getchar>
        if (c < 0) {
ffffffffc02016fe:	00054a63          	bltz	a0,ffffffffc0201712 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201702:	00a95a63          	bge	s2,a0,ffffffffc0201716 <readline+0x54>
ffffffffc0201706:	029a5263          	bge	s4,s1,ffffffffc020172a <readline+0x68>
        c = getchar();
ffffffffc020170a:	a29fe0ef          	jal	ra,ffffffffc0200132 <getchar>
        if (c < 0) {
ffffffffc020170e:	fe055ae3          	bgez	a0,ffffffffc0201702 <readline+0x40>
            return NULL;
ffffffffc0201712:	4501                	li	a0,0
ffffffffc0201714:	a091                	j	ffffffffc0201758 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc0201716:	03351463          	bne	a0,s3,ffffffffc020173e <readline+0x7c>
ffffffffc020171a:	e8a9                	bnez	s1,ffffffffc020176c <readline+0xaa>
        c = getchar();
ffffffffc020171c:	a17fe0ef          	jal	ra,ffffffffc0200132 <getchar>
        if (c < 0) {
ffffffffc0201720:	fe0549e3          	bltz	a0,ffffffffc0201712 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201724:	fea959e3          	bge	s2,a0,ffffffffc0201716 <readline+0x54>
ffffffffc0201728:	4481                	li	s1,0
            cputchar(c);
ffffffffc020172a:	e42a                	sd	a0,8(sp)
ffffffffc020172c:	9c5fe0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc0201730:	6522                	ld	a0,8(sp)
ffffffffc0201732:	009b87b3          	add	a5,s7,s1
ffffffffc0201736:	2485                	addiw	s1,s1,1
ffffffffc0201738:	00a78023          	sb	a0,0(a5)
ffffffffc020173c:	bf7d                	j	ffffffffc02016fa <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc020173e:	01550463          	beq	a0,s5,ffffffffc0201746 <readline+0x84>
ffffffffc0201742:	fb651ce3          	bne	a0,s6,ffffffffc02016fa <readline+0x38>
            cputchar(c);
ffffffffc0201746:	9abfe0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc020174a:	00005517          	auipc	a0,0x5
ffffffffc020174e:	9e650513          	addi	a0,a0,-1562 # ffffffffc0206130 <buf>
ffffffffc0201752:	94aa                	add	s1,s1,a0
ffffffffc0201754:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0201758:	60a6                	ld	ra,72(sp)
ffffffffc020175a:	6486                	ld	s1,64(sp)
ffffffffc020175c:	7962                	ld	s2,56(sp)
ffffffffc020175e:	79c2                	ld	s3,48(sp)
ffffffffc0201760:	7a22                	ld	s4,40(sp)
ffffffffc0201762:	7a82                	ld	s5,32(sp)
ffffffffc0201764:	6b62                	ld	s6,24(sp)
ffffffffc0201766:	6bc2                	ld	s7,16(sp)
ffffffffc0201768:	6161                	addi	sp,sp,80
ffffffffc020176a:	8082                	ret
            cputchar(c);
ffffffffc020176c:	4521                	li	a0,8
ffffffffc020176e:	983fe0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc0201772:	34fd                	addiw	s1,s1,-1
ffffffffc0201774:	b759                	j	ffffffffc02016fa <readline+0x38>

ffffffffc0201776 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201776:	4781                	li	a5,0
ffffffffc0201778:	00005717          	auipc	a4,0x5
ffffffffc020177c:	8a873703          	ld	a4,-1880(a4) # ffffffffc0206020 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201780:	88ba                	mv	a7,a4
ffffffffc0201782:	852a                	mv	a0,a0
ffffffffc0201784:	85be                	mv	a1,a5
ffffffffc0201786:	863e                	mv	a2,a5
ffffffffc0201788:	00000073          	ecall
ffffffffc020178c:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc020178e:	8082                	ret

ffffffffc0201790 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201790:	4781                	li	a5,0
ffffffffc0201792:	00005717          	auipc	a4,0x5
ffffffffc0201796:	de673703          	ld	a4,-538(a4) # ffffffffc0206578 <SBI_SET_TIMER>
ffffffffc020179a:	88ba                	mv	a7,a4
ffffffffc020179c:	852a                	mv	a0,a0
ffffffffc020179e:	85be                	mv	a1,a5
ffffffffc02017a0:	863e                	mv	a2,a5
ffffffffc02017a2:	00000073          	ecall
ffffffffc02017a6:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc02017a8:	8082                	ret

ffffffffc02017aa <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc02017aa:	4501                	li	a0,0
ffffffffc02017ac:	00005797          	auipc	a5,0x5
ffffffffc02017b0:	86c7b783          	ld	a5,-1940(a5) # ffffffffc0206018 <SBI_CONSOLE_GETCHAR>
ffffffffc02017b4:	88be                	mv	a7,a5
ffffffffc02017b6:	852a                	mv	a0,a0
ffffffffc02017b8:	85aa                	mv	a1,a0
ffffffffc02017ba:	862a                	mv	a2,a0
ffffffffc02017bc:	00000073          	ecall
ffffffffc02017c0:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02017c2:	2501                	sext.w	a0,a0
ffffffffc02017c4:	8082                	ret

ffffffffc02017c6 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02017c6:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02017c8:	e589                	bnez	a1,ffffffffc02017d2 <strnlen+0xc>
ffffffffc02017ca:	a811                	j	ffffffffc02017de <strnlen+0x18>
        cnt ++;
ffffffffc02017cc:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02017ce:	00f58863          	beq	a1,a5,ffffffffc02017de <strnlen+0x18>
ffffffffc02017d2:	00f50733          	add	a4,a0,a5
ffffffffc02017d6:	00074703          	lbu	a4,0(a4)
ffffffffc02017da:	fb6d                	bnez	a4,ffffffffc02017cc <strnlen+0x6>
ffffffffc02017dc:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02017de:	852e                	mv	a0,a1
ffffffffc02017e0:	8082                	ret

ffffffffc02017e2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02017e2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02017e6:	0005c703          	lbu	a4,0(a1) # 1000 <kern_entry-0xffffffffc01ff000>
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02017ea:	cb89                	beqz	a5,ffffffffc02017fc <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02017ec:	0505                	addi	a0,a0,1
ffffffffc02017ee:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02017f0:	fee789e3          	beq	a5,a4,ffffffffc02017e2 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02017f4:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02017f8:	9d19                	subw	a0,a0,a4
ffffffffc02017fa:	8082                	ret
ffffffffc02017fc:	4501                	li	a0,0
ffffffffc02017fe:	bfed                	j	ffffffffc02017f8 <strcmp+0x16>

ffffffffc0201800 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201800:	00054783          	lbu	a5,0(a0)
ffffffffc0201804:	c799                	beqz	a5,ffffffffc0201812 <strchr+0x12>
        if (*s == c) {
ffffffffc0201806:	00f58763          	beq	a1,a5,ffffffffc0201814 <strchr+0x14>
    while (*s != '\0') {
ffffffffc020180a:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc020180e:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201810:	fbfd                	bnez	a5,ffffffffc0201806 <strchr+0x6>
    }
    return NULL;
ffffffffc0201812:	4501                	li	a0,0
}
ffffffffc0201814:	8082                	ret

ffffffffc0201816 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201816:	ca01                	beqz	a2,ffffffffc0201826 <memset+0x10>
ffffffffc0201818:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020181a:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020181c:	0785                	addi	a5,a5,1
ffffffffc020181e:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201822:	fec79de3          	bne	a5,a2,ffffffffc020181c <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201826:	8082                	ret
