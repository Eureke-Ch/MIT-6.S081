
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	83010113          	addi	sp,sp,-2000 # 80009830 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	c7478793          	addi	a5,a5,-908 # 80005cd0 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e4e78793          	addi	a5,a5,-434 # 80000ef4 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	b3e080e7          	jalr	-1218(ra) # 80000c4a <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305c63          	blez	s3,8000016c <consolewrite+0x80>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	3bc080e7          	jalr	956(ra) # 800024e2 <either_copyin>
    8000012e:	01550d63          	beq	a0,s5,80000148 <consolewrite+0x5c>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	79a080e7          	jalr	1946(ra) # 800008d0 <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
    80000146:	894e                	mv	s2,s3
  }
  release(&cons.lock);
    80000148:	00011517          	auipc	a0,0x11
    8000014c:	6e850513          	addi	a0,a0,1768 # 80011830 <cons>
    80000150:	00001097          	auipc	ra,0x1
    80000154:	bae080e7          	jalr	-1106(ra) # 80000cfe <release>

  return i;
}
    80000158:	854a                	mv	a0,s2
    8000015a:	60a6                	ld	ra,72(sp)
    8000015c:	6406                	ld	s0,64(sp)
    8000015e:	74e2                	ld	s1,56(sp)
    80000160:	7942                	ld	s2,48(sp)
    80000162:	79a2                	ld	s3,40(sp)
    80000164:	7a02                	ld	s4,32(sp)
    80000166:	6ae2                	ld	s5,24(sp)
    80000168:	6161                	addi	sp,sp,80
    8000016a:	8082                	ret
  for(i = 0; i < n; i++){
    8000016c:	4901                	li	s2,0
    8000016e:	bfe9                	j	80000148 <consolewrite+0x5c>

0000000080000170 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000170:	7159                	addi	sp,sp,-112
    80000172:	f486                	sd	ra,104(sp)
    80000174:	f0a2                	sd	s0,96(sp)
    80000176:	eca6                	sd	s1,88(sp)
    80000178:	e8ca                	sd	s2,80(sp)
    8000017a:	e4ce                	sd	s3,72(sp)
    8000017c:	e0d2                	sd	s4,64(sp)
    8000017e:	fc56                	sd	s5,56(sp)
    80000180:	f85a                	sd	s6,48(sp)
    80000182:	f45e                	sd	s7,40(sp)
    80000184:	f062                	sd	s8,32(sp)
    80000186:	ec66                	sd	s9,24(sp)
    80000188:	e86a                	sd	s10,16(sp)
    8000018a:	1880                	addi	s0,sp,112
    8000018c:	8aaa                	mv	s5,a0
    8000018e:	8a2e                	mv	s4,a1
    80000190:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000196:	00011517          	auipc	a0,0x11
    8000019a:	69a50513          	addi	a0,a0,1690 # 80011830 <cons>
    8000019e:	00001097          	auipc	ra,0x1
    800001a2:	aac080e7          	jalr	-1364(ra) # 80000c4a <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a6:	00011497          	auipc	s1,0x11
    800001aa:	68a48493          	addi	s1,s1,1674 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ae:	00011917          	auipc	s2,0x11
    800001b2:	71a90913          	addi	s2,s2,1818 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b6:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b8:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ba:	4ca9                	li	s9,10
  while(n > 0){
    800001bc:	07305863          	blez	s3,8000022c <consoleread+0xbc>
    while(cons.r == cons.w){
    800001c0:	0984a783          	lw	a5,152(s1)
    800001c4:	09c4a703          	lw	a4,156(s1)
    800001c8:	02f71463          	bne	a4,a5,800001f0 <consoleread+0x80>
      if(myproc()->killed){
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	84a080e7          	jalr	-1974(ra) # 80001a16 <myproc>
    800001d4:	591c                	lw	a5,48(a0)
    800001d6:	e7b5                	bnez	a5,80000242 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001d8:	85a6                	mv	a1,s1
    800001da:	854a                	mv	a0,s2
    800001dc:	00002097          	auipc	ra,0x2
    800001e0:	056080e7          	jalr	86(ra) # 80002232 <sleep>
    while(cons.r == cons.w){
    800001e4:	0984a783          	lw	a5,152(s1)
    800001e8:	09c4a703          	lw	a4,156(s1)
    800001ec:	fef700e3          	beq	a4,a5,800001cc <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f0:	0017871b          	addiw	a4,a5,1
    800001f4:	08e4ac23          	sw	a4,152(s1)
    800001f8:	07f7f713          	andi	a4,a5,127
    800001fc:	9726                	add	a4,a4,s1
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000206:	077d0563          	beq	s10,s7,80000270 <consoleread+0x100>
    cbuf = c;
    8000020a:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020e:	4685                	li	a3,1
    80000210:	f9f40613          	addi	a2,s0,-97
    80000214:	85d2                	mv	a1,s4
    80000216:	8556                	mv	a0,s5
    80000218:	00002097          	auipc	ra,0x2
    8000021c:	274080e7          	jalr	628(ra) # 8000248c <either_copyout>
    80000220:	01850663          	beq	a0,s8,8000022c <consoleread+0xbc>
    dst++;
    80000224:	0a05                	addi	s4,s4,1
    --n;
    80000226:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000228:	f99d1ae3          	bne	s10,s9,800001bc <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022c:	00011517          	auipc	a0,0x11
    80000230:	60450513          	addi	a0,a0,1540 # 80011830 <cons>
    80000234:	00001097          	auipc	ra,0x1
    80000238:	aca080e7          	jalr	-1334(ra) # 80000cfe <release>

  return target - n;
    8000023c:	413b053b          	subw	a0,s6,s3
    80000240:	a811                	j	80000254 <consoleread+0xe4>
        release(&cons.lock);
    80000242:	00011517          	auipc	a0,0x11
    80000246:	5ee50513          	addi	a0,a0,1518 # 80011830 <cons>
    8000024a:	00001097          	auipc	ra,0x1
    8000024e:	ab4080e7          	jalr	-1356(ra) # 80000cfe <release>
        return -1;
    80000252:	557d                	li	a0,-1
}
    80000254:	70a6                	ld	ra,104(sp)
    80000256:	7406                	ld	s0,96(sp)
    80000258:	64e6                	ld	s1,88(sp)
    8000025a:	6946                	ld	s2,80(sp)
    8000025c:	69a6                	ld	s3,72(sp)
    8000025e:	6a06                	ld	s4,64(sp)
    80000260:	7ae2                	ld	s5,56(sp)
    80000262:	7b42                	ld	s6,48(sp)
    80000264:	7ba2                	ld	s7,40(sp)
    80000266:	7c02                	ld	s8,32(sp)
    80000268:	6ce2                	ld	s9,24(sp)
    8000026a:	6d42                	ld	s10,16(sp)
    8000026c:	6165                	addi	sp,sp,112
    8000026e:	8082                	ret
      if(n < target){
    80000270:	0009871b          	sext.w	a4,s3
    80000274:	fb677ce3          	bgeu	a4,s6,8000022c <consoleread+0xbc>
        cons.r--;
    80000278:	00011717          	auipc	a4,0x11
    8000027c:	64f72823          	sw	a5,1616(a4) # 800118c8 <cons+0x98>
    80000280:	b775                	j	8000022c <consoleread+0xbc>

0000000080000282 <consputc>:
{
    80000282:	1141                	addi	sp,sp,-16
    80000284:	e406                	sd	ra,8(sp)
    80000286:	e022                	sd	s0,0(sp)
    80000288:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028a:	10000793          	li	a5,256
    8000028e:	00f50a63          	beq	a0,a5,800002a2 <consputc+0x20>
    uartputc_sync(c);
    80000292:	00000097          	auipc	ra,0x0
    80000296:	560080e7          	jalr	1376(ra) # 800007f2 <uartputc_sync>
}
    8000029a:	60a2                	ld	ra,8(sp)
    8000029c:	6402                	ld	s0,0(sp)
    8000029e:	0141                	addi	sp,sp,16
    800002a0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a2:	4521                	li	a0,8
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	54e080e7          	jalr	1358(ra) # 800007f2 <uartputc_sync>
    800002ac:	02000513          	li	a0,32
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	542080e7          	jalr	1346(ra) # 800007f2 <uartputc_sync>
    800002b8:	4521                	li	a0,8
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	538080e7          	jalr	1336(ra) # 800007f2 <uartputc_sync>
    800002c2:	bfe1                	j	8000029a <consputc+0x18>

00000000800002c4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c4:	1101                	addi	sp,sp,-32
    800002c6:	ec06                	sd	ra,24(sp)
    800002c8:	e822                	sd	s0,16(sp)
    800002ca:	e426                	sd	s1,8(sp)
    800002cc:	e04a                	sd	s2,0(sp)
    800002ce:	1000                	addi	s0,sp,32
    800002d0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d2:	00011517          	auipc	a0,0x11
    800002d6:	55e50513          	addi	a0,a0,1374 # 80011830 <cons>
    800002da:	00001097          	auipc	ra,0x1
    800002de:	970080e7          	jalr	-1680(ra) # 80000c4a <acquire>

  switch(c){
    800002e2:	47d5                	li	a5,21
    800002e4:	0af48663          	beq	s1,a5,80000390 <consoleintr+0xcc>
    800002e8:	0297ca63          	blt	a5,s1,8000031c <consoleintr+0x58>
    800002ec:	47a1                	li	a5,8
    800002ee:	0ef48763          	beq	s1,a5,800003dc <consoleintr+0x118>
    800002f2:	47c1                	li	a5,16
    800002f4:	10f49a63          	bne	s1,a5,80000408 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f8:	00002097          	auipc	ra,0x2
    800002fc:	240080e7          	jalr	576(ra) # 80002538 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	53050513          	addi	a0,a0,1328 # 80011830 <cons>
    80000308:	00001097          	auipc	ra,0x1
    8000030c:	9f6080e7          	jalr	-1546(ra) # 80000cfe <release>
}
    80000310:	60e2                	ld	ra,24(sp)
    80000312:	6442                	ld	s0,16(sp)
    80000314:	64a2                	ld	s1,8(sp)
    80000316:	6902                	ld	s2,0(sp)
    80000318:	6105                	addi	sp,sp,32
    8000031a:	8082                	ret
  switch(c){
    8000031c:	07f00793          	li	a5,127
    80000320:	0af48e63          	beq	s1,a5,800003dc <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000324:	00011717          	auipc	a4,0x11
    80000328:	50c70713          	addi	a4,a4,1292 # 80011830 <cons>
    8000032c:	0a072783          	lw	a5,160(a4)
    80000330:	09872703          	lw	a4,152(a4)
    80000334:	9f99                	subw	a5,a5,a4
    80000336:	07f00713          	li	a4,127
    8000033a:	fcf763e3          	bltu	a4,a5,80000300 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033e:	47b5                	li	a5,13
    80000340:	0cf48763          	beq	s1,a5,8000040e <consoleintr+0x14a>
      consputc(c);
    80000344:	8526                	mv	a0,s1
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	f3c080e7          	jalr	-196(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000034e:	00011797          	auipc	a5,0x11
    80000352:	4e278793          	addi	a5,a5,1250 # 80011830 <cons>
    80000356:	0a07a703          	lw	a4,160(a5)
    8000035a:	0017069b          	addiw	a3,a4,1
    8000035e:	0006861b          	sext.w	a2,a3
    80000362:	0ad7a023          	sw	a3,160(a5)
    80000366:	07f77713          	andi	a4,a4,127
    8000036a:	97ba                	add	a5,a5,a4
    8000036c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000370:	47a9                	li	a5,10
    80000372:	0cf48563          	beq	s1,a5,8000043c <consoleintr+0x178>
    80000376:	4791                	li	a5,4
    80000378:	0cf48263          	beq	s1,a5,8000043c <consoleintr+0x178>
    8000037c:	00011797          	auipc	a5,0x11
    80000380:	54c7a783          	lw	a5,1356(a5) # 800118c8 <cons+0x98>
    80000384:	0807879b          	addiw	a5,a5,128
    80000388:	f6f61ce3          	bne	a2,a5,80000300 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000038c:	863e                	mv	a2,a5
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	4a070713          	addi	a4,a4,1184 # 80011830 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	49048493          	addi	s1,s1,1168 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003a8:	4929                	li	s2,10
    800003aa:	f4f70be3          	beq	a4,a5,80000300 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ae:	37fd                	addiw	a5,a5,-1
    800003b0:	07f7f713          	andi	a4,a5,127
    800003b4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b6:	01874703          	lbu	a4,24(a4)
    800003ba:	f52703e3          	beq	a4,s2,80000300 <consoleintr+0x3c>
      cons.e--;
    800003be:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c2:	10000513          	li	a0,256
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	ebc080e7          	jalr	-324(ra) # 80000282 <consputc>
    while(cons.e != cons.w &&
    800003ce:	0a04a783          	lw	a5,160(s1)
    800003d2:	09c4a703          	lw	a4,156(s1)
    800003d6:	fcf71ce3          	bne	a4,a5,800003ae <consoleintr+0xea>
    800003da:	b71d                	j	80000300 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003dc:	00011717          	auipc	a4,0x11
    800003e0:	45470713          	addi	a4,a4,1108 # 80011830 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	4cf72f23          	sw	a5,1246(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fa:	10000513          	li	a0,256
    800003fe:	00000097          	auipc	ra,0x0
    80000402:	e84080e7          	jalr	-380(ra) # 80000282 <consputc>
    80000406:	bded                	j	80000300 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000408:	ee048ce3          	beqz	s1,80000300 <consoleintr+0x3c>
    8000040c:	bf21                	j	80000324 <consoleintr+0x60>
      consputc(c);
    8000040e:	4529                	li	a0,10
    80000410:	00000097          	auipc	ra,0x0
    80000414:	e72080e7          	jalr	-398(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000418:	00011797          	auipc	a5,0x11
    8000041c:	41878793          	addi	a5,a5,1048 # 80011830 <cons>
    80000420:	0a07a703          	lw	a4,160(a5)
    80000424:	0017069b          	addiw	a3,a4,1
    80000428:	0006861b          	sext.w	a2,a3
    8000042c:	0ad7a023          	sw	a3,160(a5)
    80000430:	07f77713          	andi	a4,a4,127
    80000434:	97ba                	add	a5,a5,a4
    80000436:	4729                	li	a4,10
    80000438:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043c:	00011797          	auipc	a5,0x11
    80000440:	48c7a823          	sw	a2,1168(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	48450513          	addi	a0,a0,1156 # 800118c8 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	f66080e7          	jalr	-154(ra) # 800023b2 <wakeup>
    80000454:	b575                	j	80000300 <consoleintr+0x3c>

0000000080000456 <consoleinit>:

void
consoleinit(void)
{
    80000456:	1141                	addi	sp,sp,-16
    80000458:	e406                	sd	ra,8(sp)
    8000045a:	e022                	sd	s0,0(sp)
    8000045c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <etext+0x10>
    80000466:	00011517          	auipc	a0,0x11
    8000046a:	3ca50513          	addi	a0,a0,970 # 80011830 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	74c080e7          	jalr	1868(ra) # 80000bba <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	32c080e7          	jalr	812(ra) # 800007a2 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00021797          	auipc	a5,0x21
    80000482:	53278793          	addi	a5,a5,1330 # 800219b0 <devsw>
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	cea70713          	addi	a4,a4,-790 # 80000170 <consoleread>
    8000048e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000490:	00000717          	auipc	a4,0x0
    80000494:	c5c70713          	addi	a4,a4,-932 # 800000ec <consolewrite>
    80000498:	ef98                	sd	a4,24(a5)
}
    8000049a:	60a2                	ld	ra,8(sp)
    8000049c:	6402                	ld	s0,0(sp)
    8000049e:	0141                	addi	sp,sp,16
    800004a0:	8082                	ret

00000000800004a2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a2:	7179                	addi	sp,sp,-48
    800004a4:	f406                	sd	ra,40(sp)
    800004a6:	f022                	sd	s0,32(sp)
    800004a8:	ec26                	sd	s1,24(sp)
    800004aa:	e84a                	sd	s2,16(sp)
    800004ac:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ae:	c219                	beqz	a2,800004b4 <printint+0x12>
    800004b0:	08054763          	bltz	a0,8000053e <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004b4:	2501                	sext.w	a0,a0
    800004b6:	4881                	li	a7,0
    800004b8:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004bc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004be:	2581                	sext.w	a1,a1
    800004c0:	00008617          	auipc	a2,0x8
    800004c4:	b8060613          	addi	a2,a2,-1152 # 80008040 <digits>
    800004c8:	883a                	mv	a6,a4
    800004ca:	2705                	addiw	a4,a4,1
    800004cc:	02b577bb          	remuw	a5,a0,a1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	97b2                	add	a5,a5,a2
    800004d6:	0007c783          	lbu	a5,0(a5)
    800004da:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004de:	0005079b          	sext.w	a5,a0
    800004e2:	02b5553b          	divuw	a0,a0,a1
    800004e6:	0685                	addi	a3,a3,1
    800004e8:	feb7f0e3          	bgeu	a5,a1,800004c8 <printint+0x26>

  if(sign)
    800004ec:	00088c63          	beqz	a7,80000504 <printint+0x62>
    buf[i++] = '-';
    800004f0:	fe070793          	addi	a5,a4,-32
    800004f4:	00878733          	add	a4,a5,s0
    800004f8:	02d00793          	li	a5,45
    800004fc:	fef70823          	sb	a5,-16(a4)
    80000500:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000504:	02e05763          	blez	a4,80000532 <printint+0x90>
    80000508:	fd040793          	addi	a5,s0,-48
    8000050c:	00e784b3          	add	s1,a5,a4
    80000510:	fff78913          	addi	s2,a5,-1
    80000514:	993a                	add	s2,s2,a4
    80000516:	377d                	addiw	a4,a4,-1
    80000518:	1702                	slli	a4,a4,0x20
    8000051a:	9301                	srli	a4,a4,0x20
    8000051c:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000520:	fff4c503          	lbu	a0,-1(s1)
    80000524:	00000097          	auipc	ra,0x0
    80000528:	d5e080e7          	jalr	-674(ra) # 80000282 <consputc>
  while(--i >= 0)
    8000052c:	14fd                	addi	s1,s1,-1
    8000052e:	ff2499e3          	bne	s1,s2,80000520 <printint+0x7e>
}
    80000532:	70a2                	ld	ra,40(sp)
    80000534:	7402                	ld	s0,32(sp)
    80000536:	64e2                	ld	s1,24(sp)
    80000538:	6942                	ld	s2,16(sp)
    8000053a:	6145                	addi	sp,sp,48
    8000053c:	8082                	ret
    x = -xx;
    8000053e:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000542:	4885                	li	a7,1
    x = -xx;
    80000544:	bf95                	j	800004b8 <printint+0x16>

0000000080000546 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000546:	1101                	addi	sp,sp,-32
    80000548:	ec06                	sd	ra,24(sp)
    8000054a:	e822                	sd	s0,16(sp)
    8000054c:	e426                	sd	s1,8(sp)
    8000054e:	1000                	addi	s0,sp,32
    80000550:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000552:	00011797          	auipc	a5,0x11
    80000556:	3807af23          	sw	zero,926(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    8000055a:	00008517          	auipc	a0,0x8
    8000055e:	abe50513          	addi	a0,a0,-1346 # 80008018 <etext+0x18>
    80000562:	00000097          	auipc	ra,0x0
    80000566:	02e080e7          	jalr	46(ra) # 80000590 <printf>
  printf(s);
    8000056a:	8526                	mv	a0,s1
    8000056c:	00000097          	auipc	ra,0x0
    80000570:	024080e7          	jalr	36(ra) # 80000590 <printf>
  printf("\n");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	b5450513          	addi	a0,a0,-1196 # 800080c8 <digits+0x88>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	014080e7          	jalr	20(ra) # 80000590 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000584:	4785                	li	a5,1
    80000586:	00009717          	auipc	a4,0x9
    8000058a:	a6f72d23          	sw	a5,-1414(a4) # 80009000 <panicked>
  for(;;)
    8000058e:	a001                	j	8000058e <panic+0x48>

0000000080000590 <printf>:
{
    80000590:	7131                	addi	sp,sp,-192
    80000592:	fc86                	sd	ra,120(sp)
    80000594:	f8a2                	sd	s0,112(sp)
    80000596:	f4a6                	sd	s1,104(sp)
    80000598:	f0ca                	sd	s2,96(sp)
    8000059a:	ecce                	sd	s3,88(sp)
    8000059c:	e8d2                	sd	s4,80(sp)
    8000059e:	e4d6                	sd	s5,72(sp)
    800005a0:	e0da                	sd	s6,64(sp)
    800005a2:	fc5e                	sd	s7,56(sp)
    800005a4:	f862                	sd	s8,48(sp)
    800005a6:	f466                	sd	s9,40(sp)
    800005a8:	f06a                	sd	s10,32(sp)
    800005aa:	ec6e                	sd	s11,24(sp)
    800005ac:	0100                	addi	s0,sp,128
    800005ae:	8a2a                	mv	s4,a0
    800005b0:	e40c                	sd	a1,8(s0)
    800005b2:	e810                	sd	a2,16(s0)
    800005b4:	ec14                	sd	a3,24(s0)
    800005b6:	f018                	sd	a4,32(s0)
    800005b8:	f41c                	sd	a5,40(s0)
    800005ba:	03043823          	sd	a6,48(s0)
    800005be:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c2:	00011d97          	auipc	s11,0x11
    800005c6:	32edad83          	lw	s11,814(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005ca:	020d9b63          	bnez	s11,80000600 <printf+0x70>
  if (fmt == 0)
    800005ce:	040a0263          	beqz	s4,80000612 <printf+0x82>
  va_start(ap, fmt);
    800005d2:	00840793          	addi	a5,s0,8
    800005d6:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005da:	000a4503          	lbu	a0,0(s4)
    800005de:	14050f63          	beqz	a0,8000073c <printf+0x1ac>
    800005e2:	4981                	li	s3,0
    if(c != '%'){
    800005e4:	02500a93          	li	s5,37
    switch(c){
    800005e8:	07000b93          	li	s7,112
  consputc('x');
    800005ec:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ee:	00008b17          	auipc	s6,0x8
    800005f2:	a52b0b13          	addi	s6,s6,-1454 # 80008040 <digits>
    switch(c){
    800005f6:	07300c93          	li	s9,115
    800005fa:	06400c13          	li	s8,100
    800005fe:	a82d                	j	80000638 <printf+0xa8>
    acquire(&pr.lock);
    80000600:	00011517          	auipc	a0,0x11
    80000604:	2d850513          	addi	a0,a0,728 # 800118d8 <pr>
    80000608:	00000097          	auipc	ra,0x0
    8000060c:	642080e7          	jalr	1602(ra) # 80000c4a <acquire>
    80000610:	bf7d                	j	800005ce <printf+0x3e>
    panic("null fmt");
    80000612:	00008517          	auipc	a0,0x8
    80000616:	a1650513          	addi	a0,a0,-1514 # 80008028 <etext+0x28>
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	f2c080e7          	jalr	-212(ra) # 80000546 <panic>
      consputc(c);
    80000622:	00000097          	auipc	ra,0x0
    80000626:	c60080e7          	jalr	-928(ra) # 80000282 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062a:	2985                	addiw	s3,s3,1
    8000062c:	013a07b3          	add	a5,s4,s3
    80000630:	0007c503          	lbu	a0,0(a5)
    80000634:	10050463          	beqz	a0,8000073c <printf+0x1ac>
    if(c != '%'){
    80000638:	ff5515e3          	bne	a0,s5,80000622 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063c:	2985                	addiw	s3,s3,1
    8000063e:	013a07b3          	add	a5,s4,s3
    80000642:	0007c783          	lbu	a5,0(a5)
    80000646:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000064a:	cbed                	beqz	a5,8000073c <printf+0x1ac>
    switch(c){
    8000064c:	05778a63          	beq	a5,s7,800006a0 <printf+0x110>
    80000650:	02fbf663          	bgeu	s7,a5,8000067c <printf+0xec>
    80000654:	09978863          	beq	a5,s9,800006e4 <printf+0x154>
    80000658:	07800713          	li	a4,120
    8000065c:	0ce79563          	bne	a5,a4,80000726 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	85ea                	mv	a1,s10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	00000097          	auipc	ra,0x0
    80000676:	e30080e7          	jalr	-464(ra) # 800004a2 <printint>
      break;
    8000067a:	bf45                	j	8000062a <printf+0x9a>
    switch(c){
    8000067c:	09578f63          	beq	a5,s5,8000071a <printf+0x18a>
    80000680:	0b879363          	bne	a5,s8,80000726 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	4605                	li	a2,1
    80000692:	45a9                	li	a1,10
    80000694:	4388                	lw	a0,0(a5)
    80000696:	00000097          	auipc	ra,0x0
    8000069a:	e0c080e7          	jalr	-500(ra) # 800004a2 <printint>
      break;
    8000069e:	b771                	j	8000062a <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a0:	f8843783          	ld	a5,-120(s0)
    800006a4:	00878713          	addi	a4,a5,8
    800006a8:	f8e43423          	sd	a4,-120(s0)
    800006ac:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006b0:	03000513          	li	a0,48
    800006b4:	00000097          	auipc	ra,0x0
    800006b8:	bce080e7          	jalr	-1074(ra) # 80000282 <consputc>
  consputc('x');
    800006bc:	07800513          	li	a0,120
    800006c0:	00000097          	auipc	ra,0x0
    800006c4:	bc2080e7          	jalr	-1086(ra) # 80000282 <consputc>
    800006c8:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ca:	03c95793          	srli	a5,s2,0x3c
    800006ce:	97da                	add	a5,a5,s6
    800006d0:	0007c503          	lbu	a0,0(a5)
    800006d4:	00000097          	auipc	ra,0x0
    800006d8:	bae080e7          	jalr	-1106(ra) # 80000282 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006dc:	0912                	slli	s2,s2,0x4
    800006de:	34fd                	addiw	s1,s1,-1
    800006e0:	f4ed                	bnez	s1,800006ca <printf+0x13a>
    800006e2:	b7a1                	j	8000062a <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e4:	f8843783          	ld	a5,-120(s0)
    800006e8:	00878713          	addi	a4,a5,8
    800006ec:	f8e43423          	sd	a4,-120(s0)
    800006f0:	6384                	ld	s1,0(a5)
    800006f2:	cc89                	beqz	s1,8000070c <printf+0x17c>
      for(; *s; s++)
    800006f4:	0004c503          	lbu	a0,0(s1)
    800006f8:	d90d                	beqz	a0,8000062a <printf+0x9a>
        consputc(*s);
    800006fa:	00000097          	auipc	ra,0x0
    800006fe:	b88080e7          	jalr	-1144(ra) # 80000282 <consputc>
      for(; *s; s++)
    80000702:	0485                	addi	s1,s1,1
    80000704:	0004c503          	lbu	a0,0(s1)
    80000708:	f96d                	bnez	a0,800006fa <printf+0x16a>
    8000070a:	b705                	j	8000062a <printf+0x9a>
        s = "(null)";
    8000070c:	00008497          	auipc	s1,0x8
    80000710:	91448493          	addi	s1,s1,-1772 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000714:	02800513          	li	a0,40
    80000718:	b7cd                	j	800006fa <printf+0x16a>
      consputc('%');
    8000071a:	8556                	mv	a0,s5
    8000071c:	00000097          	auipc	ra,0x0
    80000720:	b66080e7          	jalr	-1178(ra) # 80000282 <consputc>
      break;
    80000724:	b719                	j	8000062a <printf+0x9a>
      consputc('%');
    80000726:	8556                	mv	a0,s5
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b5a080e7          	jalr	-1190(ra) # 80000282 <consputc>
      consputc(c);
    80000730:	8526                	mv	a0,s1
    80000732:	00000097          	auipc	ra,0x0
    80000736:	b50080e7          	jalr	-1200(ra) # 80000282 <consputc>
      break;
    8000073a:	bdc5                	j	8000062a <printf+0x9a>
  if(locking)
    8000073c:	020d9163          	bnez	s11,8000075e <printf+0x1ce>
}
    80000740:	70e6                	ld	ra,120(sp)
    80000742:	7446                	ld	s0,112(sp)
    80000744:	74a6                	ld	s1,104(sp)
    80000746:	7906                	ld	s2,96(sp)
    80000748:	69e6                	ld	s3,88(sp)
    8000074a:	6a46                	ld	s4,80(sp)
    8000074c:	6aa6                	ld	s5,72(sp)
    8000074e:	6b06                	ld	s6,64(sp)
    80000750:	7be2                	ld	s7,56(sp)
    80000752:	7c42                	ld	s8,48(sp)
    80000754:	7ca2                	ld	s9,40(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    8000075a:	6129                	addi	sp,sp,192
    8000075c:	8082                	ret
    release(&pr.lock);
    8000075e:	00011517          	auipc	a0,0x11
    80000762:	17a50513          	addi	a0,a0,378 # 800118d8 <pr>
    80000766:	00000097          	auipc	ra,0x0
    8000076a:	598080e7          	jalr	1432(ra) # 80000cfe <release>
}
    8000076e:	bfc9                	j	80000740 <printf+0x1b0>

0000000080000770 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000770:	1101                	addi	sp,sp,-32
    80000772:	ec06                	sd	ra,24(sp)
    80000774:	e822                	sd	s0,16(sp)
    80000776:	e426                	sd	s1,8(sp)
    80000778:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077a:	00011497          	auipc	s1,0x11
    8000077e:	15e48493          	addi	s1,s1,350 # 800118d8 <pr>
    80000782:	00008597          	auipc	a1,0x8
    80000786:	8b658593          	addi	a1,a1,-1866 # 80008038 <etext+0x38>
    8000078a:	8526                	mv	a0,s1
    8000078c:	00000097          	auipc	ra,0x0
    80000790:	42e080e7          	jalr	1070(ra) # 80000bba <initlock>
  pr.locking = 1;
    80000794:	4785                	li	a5,1
    80000796:	cc9c                	sw	a5,24(s1)
}
    80000798:	60e2                	ld	ra,24(sp)
    8000079a:	6442                	ld	s0,16(sp)
    8000079c:	64a2                	ld	s1,8(sp)
    8000079e:	6105                	addi	sp,sp,32
    800007a0:	8082                	ret

00000000800007a2 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007a2:	1141                	addi	sp,sp,-16
    800007a4:	e406                	sd	ra,8(sp)
    800007a6:	e022                	sd	s0,0(sp)
    800007a8:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007aa:	100007b7          	lui	a5,0x10000
    800007ae:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007b2:	f8000713          	li	a4,-128
    800007b6:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007ba:	470d                	li	a4,3
    800007bc:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007c0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c4:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c8:	469d                	li	a3,7
    800007ca:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007ce:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007d2:	00008597          	auipc	a1,0x8
    800007d6:	88658593          	addi	a1,a1,-1914 # 80008058 <digits+0x18>
    800007da:	00011517          	auipc	a0,0x11
    800007de:	11e50513          	addi	a0,a0,286 # 800118f8 <uart_tx_lock>
    800007e2:	00000097          	auipc	ra,0x0
    800007e6:	3d8080e7          	jalr	984(ra) # 80000bba <initlock>
}
    800007ea:	60a2                	ld	ra,8(sp)
    800007ec:	6402                	ld	s0,0(sp)
    800007ee:	0141                	addi	sp,sp,16
    800007f0:	8082                	ret

00000000800007f2 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007f2:	1101                	addi	sp,sp,-32
    800007f4:	ec06                	sd	ra,24(sp)
    800007f6:	e822                	sd	s0,16(sp)
    800007f8:	e426                	sd	s1,8(sp)
    800007fa:	1000                	addi	s0,sp,32
    800007fc:	84aa                	mv	s1,a0
  push_off();
    800007fe:	00000097          	auipc	ra,0x0
    80000802:	400080e7          	jalr	1024(ra) # 80000bfe <push_off>

  if(panicked){
    80000806:	00008797          	auipc	a5,0x8
    8000080a:	7fa7a783          	lw	a5,2042(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080e:	10000737          	lui	a4,0x10000
  if(panicked){
    80000812:	c391                	beqz	a5,80000816 <uartputc_sync+0x24>
    for(;;)
    80000814:	a001                	j	80000814 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000816:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000081a:	0207f793          	andi	a5,a5,32
    8000081e:	dfe5                	beqz	a5,80000816 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000820:	0ff4f513          	zext.b	a0,s1
    80000824:	100007b7          	lui	a5,0x10000
    80000828:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000082c:	00000097          	auipc	ra,0x0
    80000830:	472080e7          	jalr	1138(ra) # 80000c9e <pop_off>
}
    80000834:	60e2                	ld	ra,24(sp)
    80000836:	6442                	ld	s0,16(sp)
    80000838:	64a2                	ld	s1,8(sp)
    8000083a:	6105                	addi	sp,sp,32
    8000083c:	8082                	ret

000000008000083e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000083e:	00008797          	auipc	a5,0x8
    80000842:	7c67a783          	lw	a5,1990(a5) # 80009004 <uart_tx_r>
    80000846:	00008717          	auipc	a4,0x8
    8000084a:	7c272703          	lw	a4,1986(a4) # 80009008 <uart_tx_w>
    8000084e:	08f70063          	beq	a4,a5,800008ce <uartstart+0x90>
{
    80000852:	7139                	addi	sp,sp,-64
    80000854:	fc06                	sd	ra,56(sp)
    80000856:	f822                	sd	s0,48(sp)
    80000858:	f426                	sd	s1,40(sp)
    8000085a:	f04a                	sd	s2,32(sp)
    8000085c:	ec4e                	sd	s3,24(sp)
    8000085e:	e852                	sd	s4,16(sp)
    80000860:	e456                	sd	s5,8(sp)
    80000862:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000864:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000868:	00011a97          	auipc	s5,0x11
    8000086c:	090a8a93          	addi	s5,s5,144 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000870:	00008497          	auipc	s1,0x8
    80000874:	79448493          	addi	s1,s1,1940 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000878:	00008a17          	auipc	s4,0x8
    8000087c:	790a0a13          	addi	s4,s4,1936 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000880:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000884:	02077713          	andi	a4,a4,32
    80000888:	cb15                	beqz	a4,800008bc <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r];
    8000088a:	00fa8733          	add	a4,s5,a5
    8000088e:	01874983          	lbu	s3,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    80000892:	2785                	addiw	a5,a5,1
    80000894:	41f7d71b          	sraiw	a4,a5,0x1f
    80000898:	01b7571b          	srliw	a4,a4,0x1b
    8000089c:	9fb9                	addw	a5,a5,a4
    8000089e:	8bfd                	andi	a5,a5,31
    800008a0:	9f99                	subw	a5,a5,a4
    800008a2:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	b0c080e7          	jalr	-1268(ra) # 800023b2 <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01390023          	sb	s3,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	409c                	lw	a5,0(s1)
    800008b4:	000a2703          	lw	a4,0(s4)
    800008b8:	fcf714e3          	bne	a4,a5,80000880 <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	84aa                	mv	s1,a0
  acquire(&uart_tx_lock);
    800008e2:	00011517          	auipc	a0,0x11
    800008e6:	01650513          	addi	a0,a0,22 # 800118f8 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	360080e7          	jalr	864(ra) # 80000c4a <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	70e7a783          	lw	a5,1806(a5) # 80009000 <panicked>
    800008fa:	c391                	beqz	a5,800008fe <uartputc+0x2e>
    for(;;)
    800008fc:	a001                	j	800008fc <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800008fe:	00008697          	auipc	a3,0x8
    80000902:	70a6a683          	lw	a3,1802(a3) # 80009008 <uart_tx_w>
    80000906:	0016879b          	addiw	a5,a3,1
    8000090a:	41f7d71b          	sraiw	a4,a5,0x1f
    8000090e:	01b7571b          	srliw	a4,a4,0x1b
    80000912:	9fb9                	addw	a5,a5,a4
    80000914:	8bfd                	andi	a5,a5,31
    80000916:	9f99                	subw	a5,a5,a4
    80000918:	00008717          	auipc	a4,0x8
    8000091c:	6ec72703          	lw	a4,1772(a4) # 80009004 <uart_tx_r>
    80000920:	04f71363          	bne	a4,a5,80000966 <uartputc+0x96>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000924:	00011a17          	auipc	s4,0x11
    80000928:	fd4a0a13          	addi	s4,s4,-44 # 800118f8 <uart_tx_lock>
    8000092c:	00008917          	auipc	s2,0x8
    80000930:	6d890913          	addi	s2,s2,1752 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000934:	00008997          	auipc	s3,0x8
    80000938:	6d498993          	addi	s3,s3,1748 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000093c:	85d2                	mv	a1,s4
    8000093e:	854a                	mv	a0,s2
    80000940:	00002097          	auipc	ra,0x2
    80000944:	8f2080e7          	jalr	-1806(ra) # 80002232 <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000948:	0009a683          	lw	a3,0(s3)
    8000094c:	0016879b          	addiw	a5,a3,1
    80000950:	41f7d71b          	sraiw	a4,a5,0x1f
    80000954:	01b7571b          	srliw	a4,a4,0x1b
    80000958:	9fb9                	addw	a5,a5,a4
    8000095a:	8bfd                	andi	a5,a5,31
    8000095c:	9f99                	subw	a5,a5,a4
    8000095e:	00092703          	lw	a4,0(s2)
    80000962:	fcf70de3          	beq	a4,a5,8000093c <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000966:	00011917          	auipc	s2,0x11
    8000096a:	f9290913          	addi	s2,s2,-110 # 800118f8 <uart_tx_lock>
    8000096e:	96ca                	add	a3,a3,s2
    80000970:	00968c23          	sb	s1,24(a3)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000974:	00008717          	auipc	a4,0x8
    80000978:	68f72a23          	sw	a5,1684(a4) # 80009008 <uart_tx_w>
      uartstart();
    8000097c:	00000097          	auipc	ra,0x0
    80000980:	ec2080e7          	jalr	-318(ra) # 8000083e <uartstart>
      release(&uart_tx_lock);
    80000984:	854a                	mv	a0,s2
    80000986:	00000097          	auipc	ra,0x0
    8000098a:	378080e7          	jalr	888(ra) # 80000cfe <release>
}
    8000098e:	70a2                	ld	ra,40(sp)
    80000990:	7402                	ld	s0,32(sp)
    80000992:	64e2                	ld	s1,24(sp)
    80000994:	6942                	ld	s2,16(sp)
    80000996:	69a2                	ld	s3,8(sp)
    80000998:	6a02                	ld	s4,0(sp)
    8000099a:	6145                	addi	sp,sp,48
    8000099c:	8082                	ret

000000008000099e <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000099e:	1141                	addi	sp,sp,-16
    800009a0:	e422                	sd	s0,8(sp)
    800009a2:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009a4:	100007b7          	lui	a5,0x10000
    800009a8:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009ac:	8b85                	andi	a5,a5,1
    800009ae:	cb81                	beqz	a5,800009be <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    800009b0:	100007b7          	lui	a5,0x10000
    800009b4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009b8:	6422                	ld	s0,8(sp)
    800009ba:	0141                	addi	sp,sp,16
    800009bc:	8082                	ret
    return -1;
    800009be:	557d                	li	a0,-1
    800009c0:	bfe5                	j	800009b8 <uartgetc+0x1a>

00000000800009c2 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009c2:	1101                	addi	sp,sp,-32
    800009c4:	ec06                	sd	ra,24(sp)
    800009c6:	e822                	sd	s0,16(sp)
    800009c8:	e426                	sd	s1,8(sp)
    800009ca:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009cc:	54fd                	li	s1,-1
    800009ce:	a029                	j	800009d8 <uartintr+0x16>
      break;
    consoleintr(c);
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	8f4080e7          	jalr	-1804(ra) # 800002c4 <consoleintr>
    int c = uartgetc();
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	fc6080e7          	jalr	-58(ra) # 8000099e <uartgetc>
    if(c == -1)
    800009e0:	fe9518e3          	bne	a0,s1,800009d0 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009e4:	00011497          	auipc	s1,0x11
    800009e8:	f1448493          	addi	s1,s1,-236 # 800118f8 <uart_tx_lock>
    800009ec:	8526                	mv	a0,s1
    800009ee:	00000097          	auipc	ra,0x0
    800009f2:	25c080e7          	jalr	604(ra) # 80000c4a <acquire>
  uartstart();
    800009f6:	00000097          	auipc	ra,0x0
    800009fa:	e48080e7          	jalr	-440(ra) # 8000083e <uartstart>
  release(&uart_tx_lock);
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	2fe080e7          	jalr	766(ra) # 80000cfe <release>
}
    80000a08:	60e2                	ld	ra,24(sp)
    80000a0a:	6442                	ld	s0,16(sp)
    80000a0c:	64a2                	ld	s1,8(sp)
    80000a0e:	6105                	addi	sp,sp,32
    80000a10:	8082                	ret

0000000080000a12 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a12:	1101                	addi	sp,sp,-32
    80000a14:	ec06                	sd	ra,24(sp)
    80000a16:	e822                	sd	s0,16(sp)
    80000a18:	e426                	sd	s1,8(sp)
    80000a1a:	e04a                	sd	s2,0(sp)
    80000a1c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a1e:	03451793          	slli	a5,a0,0x34
    80000a22:	ebb9                	bnez	a5,80000a78 <kfree+0x66>
    80000a24:	84aa                	mv	s1,a0
    80000a26:	00025797          	auipc	a5,0x25
    80000a2a:	5da78793          	addi	a5,a5,1498 # 80026000 <end>
    80000a2e:	04f56563          	bltu	a0,a5,80000a78 <kfree+0x66>
    80000a32:	47c5                	li	a5,17
    80000a34:	07ee                	slli	a5,a5,0x1b
    80000a36:	04f57163          	bgeu	a0,a5,80000a78 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a3a:	6605                	lui	a2,0x1
    80000a3c:	4585                	li	a1,1
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	308080e7          	jalr	776(ra) # 80000d46 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a46:	00011917          	auipc	s2,0x11
    80000a4a:	eea90913          	addi	s2,s2,-278 # 80011930 <kmem>
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	1fa080e7          	jalr	506(ra) # 80000c4a <acquire>
  r->next = kmem.freelist;
    80000a58:	01893783          	ld	a5,24(s2)
    80000a5c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a5e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a62:	854a                	mv	a0,s2
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	29a080e7          	jalr	666(ra) # 80000cfe <release>
}
    80000a6c:	60e2                	ld	ra,24(sp)
    80000a6e:	6442                	ld	s0,16(sp)
    80000a70:	64a2                	ld	s1,8(sp)
    80000a72:	6902                	ld	s2,0(sp)
    80000a74:	6105                	addi	sp,sp,32
    80000a76:	8082                	ret
    panic("kfree");
    80000a78:	00007517          	auipc	a0,0x7
    80000a7c:	5e850513          	addi	a0,a0,1512 # 80008060 <digits+0x20>
    80000a80:	00000097          	auipc	ra,0x0
    80000a84:	ac6080e7          	jalr	-1338(ra) # 80000546 <panic>

0000000080000a88 <freerange>:
{
    80000a88:	7179                	addi	sp,sp,-48
    80000a8a:	f406                	sd	ra,40(sp)
    80000a8c:	f022                	sd	s0,32(sp)
    80000a8e:	ec26                	sd	s1,24(sp)
    80000a90:	e84a                	sd	s2,16(sp)
    80000a92:	e44e                	sd	s3,8(sp)
    80000a94:	e052                	sd	s4,0(sp)
    80000a96:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a98:	6785                	lui	a5,0x1
    80000a9a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a9e:	00e504b3          	add	s1,a0,a4
    80000aa2:	777d                	lui	a4,0xfffff
    80000aa4:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa6:	94be                	add	s1,s1,a5
    80000aa8:	0095ee63          	bltu	a1,s1,80000ac4 <freerange+0x3c>
    80000aac:	892e                	mv	s2,a1
    kfree(p);
    80000aae:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ab0:	6985                	lui	s3,0x1
    kfree(p);
    80000ab2:	01448533          	add	a0,s1,s4
    80000ab6:	00000097          	auipc	ra,0x0
    80000aba:	f5c080e7          	jalr	-164(ra) # 80000a12 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000abe:	94ce                	add	s1,s1,s3
    80000ac0:	fe9979e3          	bgeu	s2,s1,80000ab2 <freerange+0x2a>
}
    80000ac4:	70a2                	ld	ra,40(sp)
    80000ac6:	7402                	ld	s0,32(sp)
    80000ac8:	64e2                	ld	s1,24(sp)
    80000aca:	6942                	ld	s2,16(sp)
    80000acc:	69a2                	ld	s3,8(sp)
    80000ace:	6a02                	ld	s4,0(sp)
    80000ad0:	6145                	addi	sp,sp,48
    80000ad2:	8082                	ret

0000000080000ad4 <kinit>:
{
    80000ad4:	1141                	addi	sp,sp,-16
    80000ad6:	e406                	sd	ra,8(sp)
    80000ad8:	e022                	sd	s0,0(sp)
    80000ada:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000adc:	00007597          	auipc	a1,0x7
    80000ae0:	58c58593          	addi	a1,a1,1420 # 80008068 <digits+0x28>
    80000ae4:	00011517          	auipc	a0,0x11
    80000ae8:	e4c50513          	addi	a0,a0,-436 # 80011930 <kmem>
    80000aec:	00000097          	auipc	ra,0x0
    80000af0:	0ce080e7          	jalr	206(ra) # 80000bba <initlock>
  freerange(end, (void*)PHYSTOP);
    80000af4:	45c5                	li	a1,17
    80000af6:	05ee                	slli	a1,a1,0x1b
    80000af8:	00025517          	auipc	a0,0x25
    80000afc:	50850513          	addi	a0,a0,1288 # 80026000 <end>
    80000b00:	00000097          	auipc	ra,0x0
    80000b04:	f88080e7          	jalr	-120(ra) # 80000a88 <freerange>
}
    80000b08:	60a2                	ld	ra,8(sp)
    80000b0a:	6402                	ld	s0,0(sp)
    80000b0c:	0141                	addi	sp,sp,16
    80000b0e:	8082                	ret

0000000080000b10 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b10:	1101                	addi	sp,sp,-32
    80000b12:	ec06                	sd	ra,24(sp)
    80000b14:	e822                	sd	s0,16(sp)
    80000b16:	e426                	sd	s1,8(sp)
    80000b18:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b1a:	00011497          	auipc	s1,0x11
    80000b1e:	e1648493          	addi	s1,s1,-490 # 80011930 <kmem>
    80000b22:	8526                	mv	a0,s1
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	126080e7          	jalr	294(ra) # 80000c4a <acquire>
  r = kmem.freelist;
    80000b2c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b2e:	c885                	beqz	s1,80000b5e <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b30:	609c                	ld	a5,0(s1)
    80000b32:	00011517          	auipc	a0,0x11
    80000b36:	dfe50513          	addi	a0,a0,-514 # 80011930 <kmem>
    80000b3a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	1c2080e7          	jalr	450(ra) # 80000cfe <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b44:	6605                	lui	a2,0x1
    80000b46:	4595                	li	a1,5
    80000b48:	8526                	mv	a0,s1
    80000b4a:	00000097          	auipc	ra,0x0
    80000b4e:	1fc080e7          	jalr	508(ra) # 80000d46 <memset>
  return (void*)r;
}
    80000b52:	8526                	mv	a0,s1
    80000b54:	60e2                	ld	ra,24(sp)
    80000b56:	6442                	ld	s0,16(sp)
    80000b58:	64a2                	ld	s1,8(sp)
    80000b5a:	6105                	addi	sp,sp,32
    80000b5c:	8082                	ret
  release(&kmem.lock);
    80000b5e:	00011517          	auipc	a0,0x11
    80000b62:	dd250513          	addi	a0,a0,-558 # 80011930 <kmem>
    80000b66:	00000097          	auipc	ra,0x0
    80000b6a:	198080e7          	jalr	408(ra) # 80000cfe <release>
  if(r)
    80000b6e:	b7d5                	j	80000b52 <kalloc+0x42>

0000000080000b70 <getfreemem>:

uint64
getfreemem(void)
{
    80000b70:	1101                	addi	sp,sp,-32
    80000b72:	ec06                	sd	ra,24(sp)
    80000b74:	e822                	sd	s0,16(sp)
    80000b76:	e426                	sd	s1,8(sp)
    80000b78:	1000                	addi	s0,sp,32
  struct run *r;
  uint64 n = 0;

  acquire(&kmem.lock);
    80000b7a:	00011497          	auipc	s1,0x11
    80000b7e:	db648493          	addi	s1,s1,-586 # 80011930 <kmem>
    80000b82:	8526                	mv	a0,s1
    80000b84:	00000097          	auipc	ra,0x0
    80000b88:	0c6080e7          	jalr	198(ra) # 80000c4a <acquire>
  r = kmem.freelist;
    80000b8c:	6c9c                	ld	a5,24(s1)
  while (r) {
    80000b8e:	c785                	beqz	a5,80000bb6 <getfreemem+0x46>
  uint64 n = 0;
    80000b90:	4481                	li	s1,0
    ++n;
    80000b92:	0485                	addi	s1,s1,1
    r = r->next;
    80000b94:	639c                	ld	a5,0(a5)
  while (r) {
    80000b96:	fff5                	bnez	a5,80000b92 <getfreemem+0x22>
  }
  release(&kmem.lock);
    80000b98:	00011517          	auipc	a0,0x11
    80000b9c:	d9850513          	addi	a0,a0,-616 # 80011930 <kmem>
    80000ba0:	00000097          	auipc	ra,0x0
    80000ba4:	15e080e7          	jalr	350(ra) # 80000cfe <release>

  return n * PGSIZE;
}
    80000ba8:	00c49513          	slli	a0,s1,0xc
    80000bac:	60e2                	ld	ra,24(sp)
    80000bae:	6442                	ld	s0,16(sp)
    80000bb0:	64a2                	ld	s1,8(sp)
    80000bb2:	6105                	addi	sp,sp,32
    80000bb4:	8082                	ret
  uint64 n = 0;
    80000bb6:	4481                	li	s1,0
    80000bb8:	b7c5                	j	80000b98 <getfreemem+0x28>

0000000080000bba <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bba:	1141                	addi	sp,sp,-16
    80000bbc:	e422                	sd	s0,8(sp)
    80000bbe:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bc0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bc2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bc6:	00053823          	sd	zero,16(a0)
}
    80000bca:	6422                	ld	s0,8(sp)
    80000bcc:	0141                	addi	sp,sp,16
    80000bce:	8082                	ret

0000000080000bd0 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bd0:	411c                	lw	a5,0(a0)
    80000bd2:	e399                	bnez	a5,80000bd8 <holding+0x8>
    80000bd4:	4501                	li	a0,0
  return r;
}
    80000bd6:	8082                	ret
{
    80000bd8:	1101                	addi	sp,sp,-32
    80000bda:	ec06                	sd	ra,24(sp)
    80000bdc:	e822                	sd	s0,16(sp)
    80000bde:	e426                	sd	s1,8(sp)
    80000be0:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000be2:	6904                	ld	s1,16(a0)
    80000be4:	00001097          	auipc	ra,0x1
    80000be8:	e16080e7          	jalr	-490(ra) # 800019fa <mycpu>
    80000bec:	40a48533          	sub	a0,s1,a0
    80000bf0:	00153513          	seqz	a0,a0
}
    80000bf4:	60e2                	ld	ra,24(sp)
    80000bf6:	6442                	ld	s0,16(sp)
    80000bf8:	64a2                	ld	s1,8(sp)
    80000bfa:	6105                	addi	sp,sp,32
    80000bfc:	8082                	ret

0000000080000bfe <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bfe:	1101                	addi	sp,sp,-32
    80000c00:	ec06                	sd	ra,24(sp)
    80000c02:	e822                	sd	s0,16(sp)
    80000c04:	e426                	sd	s1,8(sp)
    80000c06:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c08:	100024f3          	csrr	s1,sstatus
    80000c0c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c10:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c12:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c16:	00001097          	auipc	ra,0x1
    80000c1a:	de4080e7          	jalr	-540(ra) # 800019fa <mycpu>
    80000c1e:	5d3c                	lw	a5,120(a0)
    80000c20:	cf89                	beqz	a5,80000c3a <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c22:	00001097          	auipc	ra,0x1
    80000c26:	dd8080e7          	jalr	-552(ra) # 800019fa <mycpu>
    80000c2a:	5d3c                	lw	a5,120(a0)
    80000c2c:	2785                	addiw	a5,a5,1
    80000c2e:	dd3c                	sw	a5,120(a0)
}
    80000c30:	60e2                	ld	ra,24(sp)
    80000c32:	6442                	ld	s0,16(sp)
    80000c34:	64a2                	ld	s1,8(sp)
    80000c36:	6105                	addi	sp,sp,32
    80000c38:	8082                	ret
    mycpu()->intena = old;
    80000c3a:	00001097          	auipc	ra,0x1
    80000c3e:	dc0080e7          	jalr	-576(ra) # 800019fa <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c42:	8085                	srli	s1,s1,0x1
    80000c44:	8885                	andi	s1,s1,1
    80000c46:	dd64                	sw	s1,124(a0)
    80000c48:	bfe9                	j	80000c22 <push_off+0x24>

0000000080000c4a <acquire>:
{
    80000c4a:	1101                	addi	sp,sp,-32
    80000c4c:	ec06                	sd	ra,24(sp)
    80000c4e:	e822                	sd	s0,16(sp)
    80000c50:	e426                	sd	s1,8(sp)
    80000c52:	1000                	addi	s0,sp,32
    80000c54:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c56:	00000097          	auipc	ra,0x0
    80000c5a:	fa8080e7          	jalr	-88(ra) # 80000bfe <push_off>
  if(holding(lk))
    80000c5e:	8526                	mv	a0,s1
    80000c60:	00000097          	auipc	ra,0x0
    80000c64:	f70080e7          	jalr	-144(ra) # 80000bd0 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c68:	4705                	li	a4,1
  if(holding(lk))
    80000c6a:	e115                	bnez	a0,80000c8e <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c6c:	87ba                	mv	a5,a4
    80000c6e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c72:	2781                	sext.w	a5,a5
    80000c74:	ffe5                	bnez	a5,80000c6c <acquire+0x22>
  __sync_synchronize();
    80000c76:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c7a:	00001097          	auipc	ra,0x1
    80000c7e:	d80080e7          	jalr	-640(ra) # 800019fa <mycpu>
    80000c82:	e888                	sd	a0,16(s1)
}
    80000c84:	60e2                	ld	ra,24(sp)
    80000c86:	6442                	ld	s0,16(sp)
    80000c88:	64a2                	ld	s1,8(sp)
    80000c8a:	6105                	addi	sp,sp,32
    80000c8c:	8082                	ret
    panic("acquire");
    80000c8e:	00007517          	auipc	a0,0x7
    80000c92:	3e250513          	addi	a0,a0,994 # 80008070 <digits+0x30>
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	8b0080e7          	jalr	-1872(ra) # 80000546 <panic>

0000000080000c9e <pop_off>:

void
pop_off(void)
{
    80000c9e:	1141                	addi	sp,sp,-16
    80000ca0:	e406                	sd	ra,8(sp)
    80000ca2:	e022                	sd	s0,0(sp)
    80000ca4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000ca6:	00001097          	auipc	ra,0x1
    80000caa:	d54080e7          	jalr	-684(ra) # 800019fa <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cae:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cb2:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cb4:	e78d                	bnez	a5,80000cde <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cb6:	5d3c                	lw	a5,120(a0)
    80000cb8:	02f05b63          	blez	a5,80000cee <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000cbc:	37fd                	addiw	a5,a5,-1
    80000cbe:	0007871b          	sext.w	a4,a5
    80000cc2:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cc4:	eb09                	bnez	a4,80000cd6 <pop_off+0x38>
    80000cc6:	5d7c                	lw	a5,124(a0)
    80000cc8:	c799                	beqz	a5,80000cd6 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cca:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cce:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cd2:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cd6:	60a2                	ld	ra,8(sp)
    80000cd8:	6402                	ld	s0,0(sp)
    80000cda:	0141                	addi	sp,sp,16
    80000cdc:	8082                	ret
    panic("pop_off - interruptible");
    80000cde:	00007517          	auipc	a0,0x7
    80000ce2:	39a50513          	addi	a0,a0,922 # 80008078 <digits+0x38>
    80000ce6:	00000097          	auipc	ra,0x0
    80000cea:	860080e7          	jalr	-1952(ra) # 80000546 <panic>
    panic("pop_off");
    80000cee:	00007517          	auipc	a0,0x7
    80000cf2:	3a250513          	addi	a0,a0,930 # 80008090 <digits+0x50>
    80000cf6:	00000097          	auipc	ra,0x0
    80000cfa:	850080e7          	jalr	-1968(ra) # 80000546 <panic>

0000000080000cfe <release>:
{
    80000cfe:	1101                	addi	sp,sp,-32
    80000d00:	ec06                	sd	ra,24(sp)
    80000d02:	e822                	sd	s0,16(sp)
    80000d04:	e426                	sd	s1,8(sp)
    80000d06:	1000                	addi	s0,sp,32
    80000d08:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d0a:	00000097          	auipc	ra,0x0
    80000d0e:	ec6080e7          	jalr	-314(ra) # 80000bd0 <holding>
    80000d12:	c115                	beqz	a0,80000d36 <release+0x38>
  lk->cpu = 0;
    80000d14:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d18:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d1c:	0f50000f          	fence	iorw,ow
    80000d20:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d24:	00000097          	auipc	ra,0x0
    80000d28:	f7a080e7          	jalr	-134(ra) # 80000c9e <pop_off>
}
    80000d2c:	60e2                	ld	ra,24(sp)
    80000d2e:	6442                	ld	s0,16(sp)
    80000d30:	64a2                	ld	s1,8(sp)
    80000d32:	6105                	addi	sp,sp,32
    80000d34:	8082                	ret
    panic("release");
    80000d36:	00007517          	auipc	a0,0x7
    80000d3a:	36250513          	addi	a0,a0,866 # 80008098 <digits+0x58>
    80000d3e:	00000097          	auipc	ra,0x0
    80000d42:	808080e7          	jalr	-2040(ra) # 80000546 <panic>

0000000080000d46 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d46:	1141                	addi	sp,sp,-16
    80000d48:	e422                	sd	s0,8(sp)
    80000d4a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d4c:	ca19                	beqz	a2,80000d62 <memset+0x1c>
    80000d4e:	87aa                	mv	a5,a0
    80000d50:	1602                	slli	a2,a2,0x20
    80000d52:	9201                	srli	a2,a2,0x20
    80000d54:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d58:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d5c:	0785                	addi	a5,a5,1
    80000d5e:	fee79de3          	bne	a5,a4,80000d58 <memset+0x12>
  }
  return dst;
}
    80000d62:	6422                	ld	s0,8(sp)
    80000d64:	0141                	addi	sp,sp,16
    80000d66:	8082                	ret

0000000080000d68 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d68:	1141                	addi	sp,sp,-16
    80000d6a:	e422                	sd	s0,8(sp)
    80000d6c:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d6e:	ca05                	beqz	a2,80000d9e <memcmp+0x36>
    80000d70:	fff6069b          	addiw	a3,a2,-1
    80000d74:	1682                	slli	a3,a3,0x20
    80000d76:	9281                	srli	a3,a3,0x20
    80000d78:	0685                	addi	a3,a3,1
    80000d7a:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d7c:	00054783          	lbu	a5,0(a0)
    80000d80:	0005c703          	lbu	a4,0(a1)
    80000d84:	00e79863          	bne	a5,a4,80000d94 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d88:	0505                	addi	a0,a0,1
    80000d8a:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d8c:	fed518e3          	bne	a0,a3,80000d7c <memcmp+0x14>
  }

  return 0;
    80000d90:	4501                	li	a0,0
    80000d92:	a019                	j	80000d98 <memcmp+0x30>
      return *s1 - *s2;
    80000d94:	40e7853b          	subw	a0,a5,a4
}
    80000d98:	6422                	ld	s0,8(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret
  return 0;
    80000d9e:	4501                	li	a0,0
    80000da0:	bfe5                	j	80000d98 <memcmp+0x30>

0000000080000da2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000da8:	02a5e563          	bltu	a1,a0,80000dd2 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dac:	fff6069b          	addiw	a3,a2,-1
    80000db0:	ce11                	beqz	a2,80000dcc <memmove+0x2a>
    80000db2:	1682                	slli	a3,a3,0x20
    80000db4:	9281                	srli	a3,a3,0x20
    80000db6:	0685                	addi	a3,a3,1
    80000db8:	96ae                	add	a3,a3,a1
    80000dba:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000dbc:	0585                	addi	a1,a1,1
    80000dbe:	0785                	addi	a5,a5,1
    80000dc0:	fff5c703          	lbu	a4,-1(a1)
    80000dc4:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000dc8:	fed59ae3          	bne	a1,a3,80000dbc <memmove+0x1a>

  return dst;
}
    80000dcc:	6422                	ld	s0,8(sp)
    80000dce:	0141                	addi	sp,sp,16
    80000dd0:	8082                	ret
  if(s < d && s + n > d){
    80000dd2:	02061713          	slli	a4,a2,0x20
    80000dd6:	9301                	srli	a4,a4,0x20
    80000dd8:	00e587b3          	add	a5,a1,a4
    80000ddc:	fcf578e3          	bgeu	a0,a5,80000dac <memmove+0xa>
    d += n;
    80000de0:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000de2:	fff6069b          	addiw	a3,a2,-1
    80000de6:	d27d                	beqz	a2,80000dcc <memmove+0x2a>
    80000de8:	02069613          	slli	a2,a3,0x20
    80000dec:	9201                	srli	a2,a2,0x20
    80000dee:	fff64613          	not	a2,a2
    80000df2:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000df4:	17fd                	addi	a5,a5,-1
    80000df6:	177d                	addi	a4,a4,-1
    80000df8:	0007c683          	lbu	a3,0(a5)
    80000dfc:	00d70023          	sb	a3,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    while(n-- > 0)
    80000e00:	fef61ae3          	bne	a2,a5,80000df4 <memmove+0x52>
    80000e04:	b7e1                	j	80000dcc <memmove+0x2a>

0000000080000e06 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e406                	sd	ra,8(sp)
    80000e0a:	e022                	sd	s0,0(sp)
    80000e0c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e0e:	00000097          	auipc	ra,0x0
    80000e12:	f94080e7          	jalr	-108(ra) # 80000da2 <memmove>
}
    80000e16:	60a2                	ld	ra,8(sp)
    80000e18:	6402                	ld	s0,0(sp)
    80000e1a:	0141                	addi	sp,sp,16
    80000e1c:	8082                	ret

0000000080000e1e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e1e:	1141                	addi	sp,sp,-16
    80000e20:	e422                	sd	s0,8(sp)
    80000e22:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e24:	ce11                	beqz	a2,80000e40 <strncmp+0x22>
    80000e26:	00054783          	lbu	a5,0(a0)
    80000e2a:	cf89                	beqz	a5,80000e44 <strncmp+0x26>
    80000e2c:	0005c703          	lbu	a4,0(a1)
    80000e30:	00f71a63          	bne	a4,a5,80000e44 <strncmp+0x26>
    n--, p++, q++;
    80000e34:	367d                	addiw	a2,a2,-1
    80000e36:	0505                	addi	a0,a0,1
    80000e38:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e3a:	f675                	bnez	a2,80000e26 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e3c:	4501                	li	a0,0
    80000e3e:	a809                	j	80000e50 <strncmp+0x32>
    80000e40:	4501                	li	a0,0
    80000e42:	a039                	j	80000e50 <strncmp+0x32>
  if(n == 0)
    80000e44:	ca09                	beqz	a2,80000e56 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e46:	00054503          	lbu	a0,0(a0)
    80000e4a:	0005c783          	lbu	a5,0(a1)
    80000e4e:	9d1d                	subw	a0,a0,a5
}
    80000e50:	6422                	ld	s0,8(sp)
    80000e52:	0141                	addi	sp,sp,16
    80000e54:	8082                	ret
    return 0;
    80000e56:	4501                	li	a0,0
    80000e58:	bfe5                	j	80000e50 <strncmp+0x32>

0000000080000e5a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e5a:	1141                	addi	sp,sp,-16
    80000e5c:	e422                	sd	s0,8(sp)
    80000e5e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e60:	872a                	mv	a4,a0
    80000e62:	8832                	mv	a6,a2
    80000e64:	367d                	addiw	a2,a2,-1
    80000e66:	01005963          	blez	a6,80000e78 <strncpy+0x1e>
    80000e6a:	0705                	addi	a4,a4,1
    80000e6c:	0005c783          	lbu	a5,0(a1)
    80000e70:	fef70fa3          	sb	a5,-1(a4)
    80000e74:	0585                	addi	a1,a1,1
    80000e76:	f7f5                	bnez	a5,80000e62 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e78:	86ba                	mv	a3,a4
    80000e7a:	00c05c63          	blez	a2,80000e92 <strncpy+0x38>
    *s++ = 0;
    80000e7e:	0685                	addi	a3,a3,1
    80000e80:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e84:	40d707bb          	subw	a5,a4,a3
    80000e88:	37fd                	addiw	a5,a5,-1
    80000e8a:	010787bb          	addw	a5,a5,a6
    80000e8e:	fef048e3          	bgtz	a5,80000e7e <strncpy+0x24>
  return os;
}
    80000e92:	6422                	ld	s0,8(sp)
    80000e94:	0141                	addi	sp,sp,16
    80000e96:	8082                	ret

0000000080000e98 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e98:	1141                	addi	sp,sp,-16
    80000e9a:	e422                	sd	s0,8(sp)
    80000e9c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e9e:	02c05363          	blez	a2,80000ec4 <safestrcpy+0x2c>
    80000ea2:	fff6069b          	addiw	a3,a2,-1
    80000ea6:	1682                	slli	a3,a3,0x20
    80000ea8:	9281                	srli	a3,a3,0x20
    80000eaa:	96ae                	add	a3,a3,a1
    80000eac:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000eae:	00d58963          	beq	a1,a3,80000ec0 <safestrcpy+0x28>
    80000eb2:	0585                	addi	a1,a1,1
    80000eb4:	0785                	addi	a5,a5,1
    80000eb6:	fff5c703          	lbu	a4,-1(a1)
    80000eba:	fee78fa3          	sb	a4,-1(a5)
    80000ebe:	fb65                	bnez	a4,80000eae <safestrcpy+0x16>
    ;
  *s = 0;
    80000ec0:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ec4:	6422                	ld	s0,8(sp)
    80000ec6:	0141                	addi	sp,sp,16
    80000ec8:	8082                	ret

0000000080000eca <strlen>:

int
strlen(const char *s)
{
    80000eca:	1141                	addi	sp,sp,-16
    80000ecc:	e422                	sd	s0,8(sp)
    80000ece:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ed0:	00054783          	lbu	a5,0(a0)
    80000ed4:	cf91                	beqz	a5,80000ef0 <strlen+0x26>
    80000ed6:	0505                	addi	a0,a0,1
    80000ed8:	87aa                	mv	a5,a0
    80000eda:	4685                	li	a3,1
    80000edc:	9e89                	subw	a3,a3,a0
    80000ede:	00f6853b          	addw	a0,a3,a5
    80000ee2:	0785                	addi	a5,a5,1
    80000ee4:	fff7c703          	lbu	a4,-1(a5)
    80000ee8:	fb7d                	bnez	a4,80000ede <strlen+0x14>
    ;
  return n;
}
    80000eea:	6422                	ld	s0,8(sp)
    80000eec:	0141                	addi	sp,sp,16
    80000eee:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ef0:	4501                	li	a0,0
    80000ef2:	bfe5                	j	80000eea <strlen+0x20>

0000000080000ef4 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ef4:	1141                	addi	sp,sp,-16
    80000ef6:	e406                	sd	ra,8(sp)
    80000ef8:	e022                	sd	s0,0(sp)
    80000efa:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000efc:	00001097          	auipc	ra,0x1
    80000f00:	aee080e7          	jalr	-1298(ra) # 800019ea <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f04:	00008717          	auipc	a4,0x8
    80000f08:	10870713          	addi	a4,a4,264 # 8000900c <started>
  if(cpuid() == 0){
    80000f0c:	c139                	beqz	a0,80000f52 <main+0x5e>
    while(started == 0)
    80000f0e:	431c                	lw	a5,0(a4)
    80000f10:	2781                	sext.w	a5,a5
    80000f12:	dff5                	beqz	a5,80000f0e <main+0x1a>
      ;
    __sync_synchronize();
    80000f14:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f18:	00001097          	auipc	ra,0x1
    80000f1c:	ad2080e7          	jalr	-1326(ra) # 800019ea <cpuid>
    80000f20:	85aa                	mv	a1,a0
    80000f22:	00007517          	auipc	a0,0x7
    80000f26:	19650513          	addi	a0,a0,406 # 800080b8 <digits+0x78>
    80000f2a:	fffff097          	auipc	ra,0xfffff
    80000f2e:	666080e7          	jalr	1638(ra) # 80000590 <printf>
    kvminithart();    // turn on paging
    80000f32:	00000097          	auipc	ra,0x0
    80000f36:	0d8080e7          	jalr	216(ra) # 8000100a <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f3a:	00001097          	auipc	ra,0x1
    80000f3e:	76e080e7          	jalr	1902(ra) # 800026a8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f42:	00005097          	auipc	ra,0x5
    80000f46:	dce080e7          	jalr	-562(ra) # 80005d10 <plicinithart>
  }

  scheduler();        
    80000f4a:	00001097          	auipc	ra,0x1
    80000f4e:	00c080e7          	jalr	12(ra) # 80001f56 <scheduler>
    consoleinit();
    80000f52:	fffff097          	auipc	ra,0xfffff
    80000f56:	504080e7          	jalr	1284(ra) # 80000456 <consoleinit>
    printfinit();
    80000f5a:	00000097          	auipc	ra,0x0
    80000f5e:	816080e7          	jalr	-2026(ra) # 80000770 <printfinit>
    printf("\n");
    80000f62:	00007517          	auipc	a0,0x7
    80000f66:	16650513          	addi	a0,a0,358 # 800080c8 <digits+0x88>
    80000f6a:	fffff097          	auipc	ra,0xfffff
    80000f6e:	626080e7          	jalr	1574(ra) # 80000590 <printf>
    printf("xv6 kernel is booting\n");
    80000f72:	00007517          	auipc	a0,0x7
    80000f76:	12e50513          	addi	a0,a0,302 # 800080a0 <digits+0x60>
    80000f7a:	fffff097          	auipc	ra,0xfffff
    80000f7e:	616080e7          	jalr	1558(ra) # 80000590 <printf>
    printf("\n");
    80000f82:	00007517          	auipc	a0,0x7
    80000f86:	14650513          	addi	a0,a0,326 # 800080c8 <digits+0x88>
    80000f8a:	fffff097          	auipc	ra,0xfffff
    80000f8e:	606080e7          	jalr	1542(ra) # 80000590 <printf>
    kinit();         // physical page allocator
    80000f92:	00000097          	auipc	ra,0x0
    80000f96:	b42080e7          	jalr	-1214(ra) # 80000ad4 <kinit>
    kvminit();       // create kernel page table
    80000f9a:	00000097          	auipc	ra,0x0
    80000f9e:	2a0080e7          	jalr	672(ra) # 8000123a <kvminit>
    kvminithart();   // turn on paging
    80000fa2:	00000097          	auipc	ra,0x0
    80000fa6:	068080e7          	jalr	104(ra) # 8000100a <kvminithart>
    procinit();      // process table
    80000faa:	00001097          	auipc	ra,0x1
    80000fae:	970080e7          	jalr	-1680(ra) # 8000191a <procinit>
    trapinit();      // trap vectors
    80000fb2:	00001097          	auipc	ra,0x1
    80000fb6:	6ce080e7          	jalr	1742(ra) # 80002680 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fba:	00001097          	auipc	ra,0x1
    80000fbe:	6ee080e7          	jalr	1774(ra) # 800026a8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fc2:	00005097          	auipc	ra,0x5
    80000fc6:	d38080e7          	jalr	-712(ra) # 80005cfa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fca:	00005097          	auipc	ra,0x5
    80000fce:	d46080e7          	jalr	-698(ra) # 80005d10 <plicinithart>
    binit();         // buffer cache
    80000fd2:	00002097          	auipc	ra,0x2
    80000fd6:	ee4080e7          	jalr	-284(ra) # 80002eb6 <binit>
    iinit();         // inode cache
    80000fda:	00002097          	auipc	ra,0x2
    80000fde:	572080e7          	jalr	1394(ra) # 8000354c <iinit>
    fileinit();      // file table
    80000fe2:	00003097          	auipc	ra,0x3
    80000fe6:	514080e7          	jalr	1300(ra) # 800044f6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fea:	00005097          	auipc	ra,0x5
    80000fee:	e2c080e7          	jalr	-468(ra) # 80005e16 <virtio_disk_init>
    userinit();      // first user process
    80000ff2:	00001097          	auipc	ra,0x1
    80000ff6:	cee080e7          	jalr	-786(ra) # 80001ce0 <userinit>
    __sync_synchronize();
    80000ffa:	0ff0000f          	fence
    started = 1;
    80000ffe:	4785                	li	a5,1
    80001000:	00008717          	auipc	a4,0x8
    80001004:	00f72623          	sw	a5,12(a4) # 8000900c <started>
    80001008:	b789                	j	80000f4a <main+0x56>

000000008000100a <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000100a:	1141                	addi	sp,sp,-16
    8000100c:	e422                	sd	s0,8(sp)
    8000100e:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001010:	00008797          	auipc	a5,0x8
    80001014:	0007b783          	ld	a5,0(a5) # 80009010 <kernel_pagetable>
    80001018:	83b1                	srli	a5,a5,0xc
    8000101a:	577d                	li	a4,-1
    8000101c:	177e                	slli	a4,a4,0x3f
    8000101e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001020:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001024:	12000073          	sfence.vma
  sfence_vma();
}
    80001028:	6422                	ld	s0,8(sp)
    8000102a:	0141                	addi	sp,sp,16
    8000102c:	8082                	ret

000000008000102e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000102e:	7139                	addi	sp,sp,-64
    80001030:	fc06                	sd	ra,56(sp)
    80001032:	f822                	sd	s0,48(sp)
    80001034:	f426                	sd	s1,40(sp)
    80001036:	f04a                	sd	s2,32(sp)
    80001038:	ec4e                	sd	s3,24(sp)
    8000103a:	e852                	sd	s4,16(sp)
    8000103c:	e456                	sd	s5,8(sp)
    8000103e:	e05a                	sd	s6,0(sp)
    80001040:	0080                	addi	s0,sp,64
    80001042:	84aa                	mv	s1,a0
    80001044:	89ae                	mv	s3,a1
    80001046:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001048:	57fd                	li	a5,-1
    8000104a:	83e9                	srli	a5,a5,0x1a
    8000104c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000104e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001050:	04b7f263          	bgeu	a5,a1,80001094 <walk+0x66>
    panic("walk");
    80001054:	00007517          	auipc	a0,0x7
    80001058:	07c50513          	addi	a0,a0,124 # 800080d0 <digits+0x90>
    8000105c:	fffff097          	auipc	ra,0xfffff
    80001060:	4ea080e7          	jalr	1258(ra) # 80000546 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001064:	060a8663          	beqz	s5,800010d0 <walk+0xa2>
    80001068:	00000097          	auipc	ra,0x0
    8000106c:	aa8080e7          	jalr	-1368(ra) # 80000b10 <kalloc>
    80001070:	84aa                	mv	s1,a0
    80001072:	c529                	beqz	a0,800010bc <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001074:	6605                	lui	a2,0x1
    80001076:	4581                	li	a1,0
    80001078:	00000097          	auipc	ra,0x0
    8000107c:	cce080e7          	jalr	-818(ra) # 80000d46 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001080:	00c4d793          	srli	a5,s1,0xc
    80001084:	07aa                	slli	a5,a5,0xa
    80001086:	0017e793          	ori	a5,a5,1
    8000108a:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000108e:	3a5d                	addiw	s4,s4,-9
    80001090:	036a0063          	beq	s4,s6,800010b0 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001094:	0149d933          	srl	s2,s3,s4
    80001098:	1ff97913          	andi	s2,s2,511
    8000109c:	090e                	slli	s2,s2,0x3
    8000109e:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010a0:	00093483          	ld	s1,0(s2)
    800010a4:	0014f793          	andi	a5,s1,1
    800010a8:	dfd5                	beqz	a5,80001064 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010aa:	80a9                	srli	s1,s1,0xa
    800010ac:	04b2                	slli	s1,s1,0xc
    800010ae:	b7c5                	j	8000108e <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010b0:	00c9d513          	srli	a0,s3,0xc
    800010b4:	1ff57513          	andi	a0,a0,511
    800010b8:	050e                	slli	a0,a0,0x3
    800010ba:	9526                	add	a0,a0,s1
}
    800010bc:	70e2                	ld	ra,56(sp)
    800010be:	7442                	ld	s0,48(sp)
    800010c0:	74a2                	ld	s1,40(sp)
    800010c2:	7902                	ld	s2,32(sp)
    800010c4:	69e2                	ld	s3,24(sp)
    800010c6:	6a42                	ld	s4,16(sp)
    800010c8:	6aa2                	ld	s5,8(sp)
    800010ca:	6b02                	ld	s6,0(sp)
    800010cc:	6121                	addi	sp,sp,64
    800010ce:	8082                	ret
        return 0;
    800010d0:	4501                	li	a0,0
    800010d2:	b7ed                	j	800010bc <walk+0x8e>

00000000800010d4 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010d4:	57fd                	li	a5,-1
    800010d6:	83e9                	srli	a5,a5,0x1a
    800010d8:	00b7f463          	bgeu	a5,a1,800010e0 <walkaddr+0xc>
    return 0;
    800010dc:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010de:	8082                	ret
{
    800010e0:	1141                	addi	sp,sp,-16
    800010e2:	e406                	sd	ra,8(sp)
    800010e4:	e022                	sd	s0,0(sp)
    800010e6:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010e8:	4601                	li	a2,0
    800010ea:	00000097          	auipc	ra,0x0
    800010ee:	f44080e7          	jalr	-188(ra) # 8000102e <walk>
  if(pte == 0)
    800010f2:	c105                	beqz	a0,80001112 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010f4:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010f6:	0117f693          	andi	a3,a5,17
    800010fa:	4745                	li	a4,17
    return 0;
    800010fc:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010fe:	00e68663          	beq	a3,a4,8000110a <walkaddr+0x36>
}
    80001102:	60a2                	ld	ra,8(sp)
    80001104:	6402                	ld	s0,0(sp)
    80001106:	0141                	addi	sp,sp,16
    80001108:	8082                	ret
  pa = PTE2PA(*pte);
    8000110a:	83a9                	srli	a5,a5,0xa
    8000110c:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001110:	bfcd                	j	80001102 <walkaddr+0x2e>
    return 0;
    80001112:	4501                	li	a0,0
    80001114:	b7fd                	j	80001102 <walkaddr+0x2e>

0000000080001116 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    80001116:	1101                	addi	sp,sp,-32
    80001118:	ec06                	sd	ra,24(sp)
    8000111a:	e822                	sd	s0,16(sp)
    8000111c:	e426                	sd	s1,8(sp)
    8000111e:	1000                	addi	s0,sp,32
    80001120:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001122:	1552                	slli	a0,a0,0x34
    80001124:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    80001128:	4601                	li	a2,0
    8000112a:	00008517          	auipc	a0,0x8
    8000112e:	ee653503          	ld	a0,-282(a0) # 80009010 <kernel_pagetable>
    80001132:	00000097          	auipc	ra,0x0
    80001136:	efc080e7          	jalr	-260(ra) # 8000102e <walk>
  if(pte == 0)
    8000113a:	cd09                	beqz	a0,80001154 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    8000113c:	6108                	ld	a0,0(a0)
    8000113e:	00157793          	andi	a5,a0,1
    80001142:	c38d                	beqz	a5,80001164 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001144:	8129                	srli	a0,a0,0xa
    80001146:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    80001148:	9526                	add	a0,a0,s1
    8000114a:	60e2                	ld	ra,24(sp)
    8000114c:	6442                	ld	s0,16(sp)
    8000114e:	64a2                	ld	s1,8(sp)
    80001150:	6105                	addi	sp,sp,32
    80001152:	8082                	ret
    panic("kvmpa");
    80001154:	00007517          	auipc	a0,0x7
    80001158:	f8450513          	addi	a0,a0,-124 # 800080d8 <digits+0x98>
    8000115c:	fffff097          	auipc	ra,0xfffff
    80001160:	3ea080e7          	jalr	1002(ra) # 80000546 <panic>
    panic("kvmpa");
    80001164:	00007517          	auipc	a0,0x7
    80001168:	f7450513          	addi	a0,a0,-140 # 800080d8 <digits+0x98>
    8000116c:	fffff097          	auipc	ra,0xfffff
    80001170:	3da080e7          	jalr	986(ra) # 80000546 <panic>

0000000080001174 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001174:	715d                	addi	sp,sp,-80
    80001176:	e486                	sd	ra,72(sp)
    80001178:	e0a2                	sd	s0,64(sp)
    8000117a:	fc26                	sd	s1,56(sp)
    8000117c:	f84a                	sd	s2,48(sp)
    8000117e:	f44e                	sd	s3,40(sp)
    80001180:	f052                	sd	s4,32(sp)
    80001182:	ec56                	sd	s5,24(sp)
    80001184:	e85a                	sd	s6,16(sp)
    80001186:	e45e                	sd	s7,8(sp)
    80001188:	0880                	addi	s0,sp,80
    8000118a:	8aaa                	mv	s5,a0
    8000118c:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    8000118e:	777d                	lui	a4,0xfffff
    80001190:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80001194:	fff60993          	addi	s3,a2,-1 # fff <_entry-0x7ffff001>
    80001198:	99ae                	add	s3,s3,a1
    8000119a:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    8000119e:	893e                	mv	s2,a5
    800011a0:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011a4:	6b85                	lui	s7,0x1
    800011a6:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011aa:	4605                	li	a2,1
    800011ac:	85ca                	mv	a1,s2
    800011ae:	8556                	mv	a0,s5
    800011b0:	00000097          	auipc	ra,0x0
    800011b4:	e7e080e7          	jalr	-386(ra) # 8000102e <walk>
    800011b8:	c51d                	beqz	a0,800011e6 <mappages+0x72>
    if(*pte & PTE_V)
    800011ba:	611c                	ld	a5,0(a0)
    800011bc:	8b85                	andi	a5,a5,1
    800011be:	ef81                	bnez	a5,800011d6 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011c0:	80b1                	srli	s1,s1,0xc
    800011c2:	04aa                	slli	s1,s1,0xa
    800011c4:	0164e4b3          	or	s1,s1,s6
    800011c8:	0014e493          	ori	s1,s1,1
    800011cc:	e104                	sd	s1,0(a0)
    if(a == last)
    800011ce:	03390863          	beq	s2,s3,800011fe <mappages+0x8a>
    a += PGSIZE;
    800011d2:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011d4:	bfc9                	j	800011a6 <mappages+0x32>
      panic("remap");
    800011d6:	00007517          	auipc	a0,0x7
    800011da:	f0a50513          	addi	a0,a0,-246 # 800080e0 <digits+0xa0>
    800011de:	fffff097          	auipc	ra,0xfffff
    800011e2:	368080e7          	jalr	872(ra) # 80000546 <panic>
      return -1;
    800011e6:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011e8:	60a6                	ld	ra,72(sp)
    800011ea:	6406                	ld	s0,64(sp)
    800011ec:	74e2                	ld	s1,56(sp)
    800011ee:	7942                	ld	s2,48(sp)
    800011f0:	79a2                	ld	s3,40(sp)
    800011f2:	7a02                	ld	s4,32(sp)
    800011f4:	6ae2                	ld	s5,24(sp)
    800011f6:	6b42                	ld	s6,16(sp)
    800011f8:	6ba2                	ld	s7,8(sp)
    800011fa:	6161                	addi	sp,sp,80
    800011fc:	8082                	ret
  return 0;
    800011fe:	4501                	li	a0,0
    80001200:	b7e5                	j	800011e8 <mappages+0x74>

0000000080001202 <kvmmap>:
{
    80001202:	1141                	addi	sp,sp,-16
    80001204:	e406                	sd	ra,8(sp)
    80001206:	e022                	sd	s0,0(sp)
    80001208:	0800                	addi	s0,sp,16
    8000120a:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000120c:	86ae                	mv	a3,a1
    8000120e:	85aa                	mv	a1,a0
    80001210:	00008517          	auipc	a0,0x8
    80001214:	e0053503          	ld	a0,-512(a0) # 80009010 <kernel_pagetable>
    80001218:	00000097          	auipc	ra,0x0
    8000121c:	f5c080e7          	jalr	-164(ra) # 80001174 <mappages>
    80001220:	e509                	bnez	a0,8000122a <kvmmap+0x28>
}
    80001222:	60a2                	ld	ra,8(sp)
    80001224:	6402                	ld	s0,0(sp)
    80001226:	0141                	addi	sp,sp,16
    80001228:	8082                	ret
    panic("kvmmap");
    8000122a:	00007517          	auipc	a0,0x7
    8000122e:	ebe50513          	addi	a0,a0,-322 # 800080e8 <digits+0xa8>
    80001232:	fffff097          	auipc	ra,0xfffff
    80001236:	314080e7          	jalr	788(ra) # 80000546 <panic>

000000008000123a <kvminit>:
{
    8000123a:	1101                	addi	sp,sp,-32
    8000123c:	ec06                	sd	ra,24(sp)
    8000123e:	e822                	sd	s0,16(sp)
    80001240:	e426                	sd	s1,8(sp)
    80001242:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001244:	00000097          	auipc	ra,0x0
    80001248:	8cc080e7          	jalr	-1844(ra) # 80000b10 <kalloc>
    8000124c:	00008717          	auipc	a4,0x8
    80001250:	dca73223          	sd	a0,-572(a4) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001254:	6605                	lui	a2,0x1
    80001256:	4581                	li	a1,0
    80001258:	00000097          	auipc	ra,0x0
    8000125c:	aee080e7          	jalr	-1298(ra) # 80000d46 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001260:	4699                	li	a3,6
    80001262:	6605                	lui	a2,0x1
    80001264:	100005b7          	lui	a1,0x10000
    80001268:	10000537          	lui	a0,0x10000
    8000126c:	00000097          	auipc	ra,0x0
    80001270:	f96080e7          	jalr	-106(ra) # 80001202 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001274:	4699                	li	a3,6
    80001276:	6605                	lui	a2,0x1
    80001278:	100015b7          	lui	a1,0x10001
    8000127c:	10001537          	lui	a0,0x10001
    80001280:	00000097          	auipc	ra,0x0
    80001284:	f82080e7          	jalr	-126(ra) # 80001202 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    80001288:	4699                	li	a3,6
    8000128a:	6641                	lui	a2,0x10
    8000128c:	020005b7          	lui	a1,0x2000
    80001290:	02000537          	lui	a0,0x2000
    80001294:	00000097          	auipc	ra,0x0
    80001298:	f6e080e7          	jalr	-146(ra) # 80001202 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000129c:	4699                	li	a3,6
    8000129e:	00400637          	lui	a2,0x400
    800012a2:	0c0005b7          	lui	a1,0xc000
    800012a6:	0c000537          	lui	a0,0xc000
    800012aa:	00000097          	auipc	ra,0x0
    800012ae:	f58080e7          	jalr	-168(ra) # 80001202 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012b2:	00007497          	auipc	s1,0x7
    800012b6:	d4e48493          	addi	s1,s1,-690 # 80008000 <etext>
    800012ba:	46a9                	li	a3,10
    800012bc:	80007617          	auipc	a2,0x80007
    800012c0:	d4460613          	addi	a2,a2,-700 # 8000 <_entry-0x7fff8000>
    800012c4:	4585                	li	a1,1
    800012c6:	05fe                	slli	a1,a1,0x1f
    800012c8:	852e                	mv	a0,a1
    800012ca:	00000097          	auipc	ra,0x0
    800012ce:	f38080e7          	jalr	-200(ra) # 80001202 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012d2:	4699                	li	a3,6
    800012d4:	4645                	li	a2,17
    800012d6:	066e                	slli	a2,a2,0x1b
    800012d8:	8e05                	sub	a2,a2,s1
    800012da:	85a6                	mv	a1,s1
    800012dc:	8526                	mv	a0,s1
    800012de:	00000097          	auipc	ra,0x0
    800012e2:	f24080e7          	jalr	-220(ra) # 80001202 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012e6:	46a9                	li	a3,10
    800012e8:	6605                	lui	a2,0x1
    800012ea:	00006597          	auipc	a1,0x6
    800012ee:	d1658593          	addi	a1,a1,-746 # 80007000 <_trampoline>
    800012f2:	04000537          	lui	a0,0x4000
    800012f6:	157d                	addi	a0,a0,-1
    800012f8:	0532                	slli	a0,a0,0xc
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	f08080e7          	jalr	-248(ra) # 80001202 <kvmmap>
}
    80001302:	60e2                	ld	ra,24(sp)
    80001304:	6442                	ld	s0,16(sp)
    80001306:	64a2                	ld	s1,8(sp)
    80001308:	6105                	addi	sp,sp,32
    8000130a:	8082                	ret

000000008000130c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000130c:	715d                	addi	sp,sp,-80
    8000130e:	e486                	sd	ra,72(sp)
    80001310:	e0a2                	sd	s0,64(sp)
    80001312:	fc26                	sd	s1,56(sp)
    80001314:	f84a                	sd	s2,48(sp)
    80001316:	f44e                	sd	s3,40(sp)
    80001318:	f052                	sd	s4,32(sp)
    8000131a:	ec56                	sd	s5,24(sp)
    8000131c:	e85a                	sd	s6,16(sp)
    8000131e:	e45e                	sd	s7,8(sp)
    80001320:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001322:	03459793          	slli	a5,a1,0x34
    80001326:	e795                	bnez	a5,80001352 <uvmunmap+0x46>
    80001328:	8a2a                	mv	s4,a0
    8000132a:	892e                	mv	s2,a1
    8000132c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000132e:	0632                	slli	a2,a2,0xc
    80001330:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001334:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001336:	6b05                	lui	s6,0x1
    80001338:	0735e263          	bltu	a1,s3,8000139c <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000133c:	60a6                	ld	ra,72(sp)
    8000133e:	6406                	ld	s0,64(sp)
    80001340:	74e2                	ld	s1,56(sp)
    80001342:	7942                	ld	s2,48(sp)
    80001344:	79a2                	ld	s3,40(sp)
    80001346:	7a02                	ld	s4,32(sp)
    80001348:	6ae2                	ld	s5,24(sp)
    8000134a:	6b42                	ld	s6,16(sp)
    8000134c:	6ba2                	ld	s7,8(sp)
    8000134e:	6161                	addi	sp,sp,80
    80001350:	8082                	ret
    panic("uvmunmap: not aligned");
    80001352:	00007517          	auipc	a0,0x7
    80001356:	d9e50513          	addi	a0,a0,-610 # 800080f0 <digits+0xb0>
    8000135a:	fffff097          	auipc	ra,0xfffff
    8000135e:	1ec080e7          	jalr	492(ra) # 80000546 <panic>
      panic("uvmunmap: walk");
    80001362:	00007517          	auipc	a0,0x7
    80001366:	da650513          	addi	a0,a0,-602 # 80008108 <digits+0xc8>
    8000136a:	fffff097          	auipc	ra,0xfffff
    8000136e:	1dc080e7          	jalr	476(ra) # 80000546 <panic>
      panic("uvmunmap: not mapped");
    80001372:	00007517          	auipc	a0,0x7
    80001376:	da650513          	addi	a0,a0,-602 # 80008118 <digits+0xd8>
    8000137a:	fffff097          	auipc	ra,0xfffff
    8000137e:	1cc080e7          	jalr	460(ra) # 80000546 <panic>
      panic("uvmunmap: not a leaf");
    80001382:	00007517          	auipc	a0,0x7
    80001386:	dae50513          	addi	a0,a0,-594 # 80008130 <digits+0xf0>
    8000138a:	fffff097          	auipc	ra,0xfffff
    8000138e:	1bc080e7          	jalr	444(ra) # 80000546 <panic>
    *pte = 0;
    80001392:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001396:	995a                	add	s2,s2,s6
    80001398:	fb3972e3          	bgeu	s2,s3,8000133c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000139c:	4601                	li	a2,0
    8000139e:	85ca                	mv	a1,s2
    800013a0:	8552                	mv	a0,s4
    800013a2:	00000097          	auipc	ra,0x0
    800013a6:	c8c080e7          	jalr	-884(ra) # 8000102e <walk>
    800013aa:	84aa                	mv	s1,a0
    800013ac:	d95d                	beqz	a0,80001362 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013ae:	6108                	ld	a0,0(a0)
    800013b0:	00157793          	andi	a5,a0,1
    800013b4:	dfdd                	beqz	a5,80001372 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013b6:	3ff57793          	andi	a5,a0,1023
    800013ba:	fd7784e3          	beq	a5,s7,80001382 <uvmunmap+0x76>
    if(do_free){
    800013be:	fc0a8ae3          	beqz	s5,80001392 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800013c2:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013c4:	0532                	slli	a0,a0,0xc
    800013c6:	fffff097          	auipc	ra,0xfffff
    800013ca:	64c080e7          	jalr	1612(ra) # 80000a12 <kfree>
    800013ce:	b7d1                	j	80001392 <uvmunmap+0x86>

00000000800013d0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013d0:	1101                	addi	sp,sp,-32
    800013d2:	ec06                	sd	ra,24(sp)
    800013d4:	e822                	sd	s0,16(sp)
    800013d6:	e426                	sd	s1,8(sp)
    800013d8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013da:	fffff097          	auipc	ra,0xfffff
    800013de:	736080e7          	jalr	1846(ra) # 80000b10 <kalloc>
    800013e2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013e4:	c519                	beqz	a0,800013f2 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013e6:	6605                	lui	a2,0x1
    800013e8:	4581                	li	a1,0
    800013ea:	00000097          	auipc	ra,0x0
    800013ee:	95c080e7          	jalr	-1700(ra) # 80000d46 <memset>
  return pagetable;
}
    800013f2:	8526                	mv	a0,s1
    800013f4:	60e2                	ld	ra,24(sp)
    800013f6:	6442                	ld	s0,16(sp)
    800013f8:	64a2                	ld	s1,8(sp)
    800013fa:	6105                	addi	sp,sp,32
    800013fc:	8082                	ret

00000000800013fe <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    800013fe:	7179                	addi	sp,sp,-48
    80001400:	f406                	sd	ra,40(sp)
    80001402:	f022                	sd	s0,32(sp)
    80001404:	ec26                	sd	s1,24(sp)
    80001406:	e84a                	sd	s2,16(sp)
    80001408:	e44e                	sd	s3,8(sp)
    8000140a:	e052                	sd	s4,0(sp)
    8000140c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000140e:	6785                	lui	a5,0x1
    80001410:	04f67863          	bgeu	a2,a5,80001460 <uvminit+0x62>
    80001414:	8a2a                	mv	s4,a0
    80001416:	89ae                	mv	s3,a1
    80001418:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	6f6080e7          	jalr	1782(ra) # 80000b10 <kalloc>
    80001422:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001424:	6605                	lui	a2,0x1
    80001426:	4581                	li	a1,0
    80001428:	00000097          	auipc	ra,0x0
    8000142c:	91e080e7          	jalr	-1762(ra) # 80000d46 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001430:	4779                	li	a4,30
    80001432:	86ca                	mv	a3,s2
    80001434:	6605                	lui	a2,0x1
    80001436:	4581                	li	a1,0
    80001438:	8552                	mv	a0,s4
    8000143a:	00000097          	auipc	ra,0x0
    8000143e:	d3a080e7          	jalr	-710(ra) # 80001174 <mappages>
  memmove(mem, src, sz);
    80001442:	8626                	mv	a2,s1
    80001444:	85ce                	mv	a1,s3
    80001446:	854a                	mv	a0,s2
    80001448:	00000097          	auipc	ra,0x0
    8000144c:	95a080e7          	jalr	-1702(ra) # 80000da2 <memmove>
}
    80001450:	70a2                	ld	ra,40(sp)
    80001452:	7402                	ld	s0,32(sp)
    80001454:	64e2                	ld	s1,24(sp)
    80001456:	6942                	ld	s2,16(sp)
    80001458:	69a2                	ld	s3,8(sp)
    8000145a:	6a02                	ld	s4,0(sp)
    8000145c:	6145                	addi	sp,sp,48
    8000145e:	8082                	ret
    panic("inituvm: more than a page");
    80001460:	00007517          	auipc	a0,0x7
    80001464:	ce850513          	addi	a0,a0,-792 # 80008148 <digits+0x108>
    80001468:	fffff097          	auipc	ra,0xfffff
    8000146c:	0de080e7          	jalr	222(ra) # 80000546 <panic>

0000000080001470 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001470:	1101                	addi	sp,sp,-32
    80001472:	ec06                	sd	ra,24(sp)
    80001474:	e822                	sd	s0,16(sp)
    80001476:	e426                	sd	s1,8(sp)
    80001478:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000147a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000147c:	00b67d63          	bgeu	a2,a1,80001496 <uvmdealloc+0x26>
    80001480:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001482:	6785                	lui	a5,0x1
    80001484:	17fd                	addi	a5,a5,-1
    80001486:	00f60733          	add	a4,a2,a5
    8000148a:	76fd                	lui	a3,0xfffff
    8000148c:	8f75                	and	a4,a4,a3
    8000148e:	97ae                	add	a5,a5,a1
    80001490:	8ff5                	and	a5,a5,a3
    80001492:	00f76863          	bltu	a4,a5,800014a2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001496:	8526                	mv	a0,s1
    80001498:	60e2                	ld	ra,24(sp)
    8000149a:	6442                	ld	s0,16(sp)
    8000149c:	64a2                	ld	s1,8(sp)
    8000149e:	6105                	addi	sp,sp,32
    800014a0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014a2:	8f99                	sub	a5,a5,a4
    800014a4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014a6:	4685                	li	a3,1
    800014a8:	0007861b          	sext.w	a2,a5
    800014ac:	85ba                	mv	a1,a4
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	e5e080e7          	jalr	-418(ra) # 8000130c <uvmunmap>
    800014b6:	b7c5                	j	80001496 <uvmdealloc+0x26>

00000000800014b8 <uvmalloc>:
  if(newsz < oldsz)
    800014b8:	0ab66163          	bltu	a2,a1,8000155a <uvmalloc+0xa2>
{
    800014bc:	7139                	addi	sp,sp,-64
    800014be:	fc06                	sd	ra,56(sp)
    800014c0:	f822                	sd	s0,48(sp)
    800014c2:	f426                	sd	s1,40(sp)
    800014c4:	f04a                	sd	s2,32(sp)
    800014c6:	ec4e                	sd	s3,24(sp)
    800014c8:	e852                	sd	s4,16(sp)
    800014ca:	e456                	sd	s5,8(sp)
    800014cc:	0080                	addi	s0,sp,64
    800014ce:	8aaa                	mv	s5,a0
    800014d0:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014d2:	6785                	lui	a5,0x1
    800014d4:	17fd                	addi	a5,a5,-1
    800014d6:	95be                	add	a1,a1,a5
    800014d8:	77fd                	lui	a5,0xfffff
    800014da:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014de:	08c9f063          	bgeu	s3,a2,8000155e <uvmalloc+0xa6>
    800014e2:	894e                	mv	s2,s3
    mem = kalloc();
    800014e4:	fffff097          	auipc	ra,0xfffff
    800014e8:	62c080e7          	jalr	1580(ra) # 80000b10 <kalloc>
    800014ec:	84aa                	mv	s1,a0
    if(mem == 0){
    800014ee:	c51d                	beqz	a0,8000151c <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014f0:	6605                	lui	a2,0x1
    800014f2:	4581                	li	a1,0
    800014f4:	00000097          	auipc	ra,0x0
    800014f8:	852080e7          	jalr	-1966(ra) # 80000d46 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    800014fc:	4779                	li	a4,30
    800014fe:	86a6                	mv	a3,s1
    80001500:	6605                	lui	a2,0x1
    80001502:	85ca                	mv	a1,s2
    80001504:	8556                	mv	a0,s5
    80001506:	00000097          	auipc	ra,0x0
    8000150a:	c6e080e7          	jalr	-914(ra) # 80001174 <mappages>
    8000150e:	e905                	bnez	a0,8000153e <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001510:	6785                	lui	a5,0x1
    80001512:	993e                	add	s2,s2,a5
    80001514:	fd4968e3          	bltu	s2,s4,800014e4 <uvmalloc+0x2c>
  return newsz;
    80001518:	8552                	mv	a0,s4
    8000151a:	a809                	j	8000152c <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000151c:	864e                	mv	a2,s3
    8000151e:	85ca                	mv	a1,s2
    80001520:	8556                	mv	a0,s5
    80001522:	00000097          	auipc	ra,0x0
    80001526:	f4e080e7          	jalr	-178(ra) # 80001470 <uvmdealloc>
      return 0;
    8000152a:	4501                	li	a0,0
}
    8000152c:	70e2                	ld	ra,56(sp)
    8000152e:	7442                	ld	s0,48(sp)
    80001530:	74a2                	ld	s1,40(sp)
    80001532:	7902                	ld	s2,32(sp)
    80001534:	69e2                	ld	s3,24(sp)
    80001536:	6a42                	ld	s4,16(sp)
    80001538:	6aa2                	ld	s5,8(sp)
    8000153a:	6121                	addi	sp,sp,64
    8000153c:	8082                	ret
      kfree(mem);
    8000153e:	8526                	mv	a0,s1
    80001540:	fffff097          	auipc	ra,0xfffff
    80001544:	4d2080e7          	jalr	1234(ra) # 80000a12 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001548:	864e                	mv	a2,s3
    8000154a:	85ca                	mv	a1,s2
    8000154c:	8556                	mv	a0,s5
    8000154e:	00000097          	auipc	ra,0x0
    80001552:	f22080e7          	jalr	-222(ra) # 80001470 <uvmdealloc>
      return 0;
    80001556:	4501                	li	a0,0
    80001558:	bfd1                	j	8000152c <uvmalloc+0x74>
    return oldsz;
    8000155a:	852e                	mv	a0,a1
}
    8000155c:	8082                	ret
  return newsz;
    8000155e:	8532                	mv	a0,a2
    80001560:	b7f1                	j	8000152c <uvmalloc+0x74>

0000000080001562 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001562:	7179                	addi	sp,sp,-48
    80001564:	f406                	sd	ra,40(sp)
    80001566:	f022                	sd	s0,32(sp)
    80001568:	ec26                	sd	s1,24(sp)
    8000156a:	e84a                	sd	s2,16(sp)
    8000156c:	e44e                	sd	s3,8(sp)
    8000156e:	e052                	sd	s4,0(sp)
    80001570:	1800                	addi	s0,sp,48
    80001572:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001574:	84aa                	mv	s1,a0
    80001576:	6905                	lui	s2,0x1
    80001578:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000157a:	4985                	li	s3,1
    8000157c:	a829                	j	80001596 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000157e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001580:	00c79513          	slli	a0,a5,0xc
    80001584:	00000097          	auipc	ra,0x0
    80001588:	fde080e7          	jalr	-34(ra) # 80001562 <freewalk>
      pagetable[i] = 0;
    8000158c:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001590:	04a1                	addi	s1,s1,8
    80001592:	03248163          	beq	s1,s2,800015b4 <freewalk+0x52>
    pte_t pte = pagetable[i];
    80001596:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001598:	00f7f713          	andi	a4,a5,15
    8000159c:	ff3701e3          	beq	a4,s3,8000157e <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015a0:	8b85                	andi	a5,a5,1
    800015a2:	d7fd                	beqz	a5,80001590 <freewalk+0x2e>
      panic("freewalk: leaf");
    800015a4:	00007517          	auipc	a0,0x7
    800015a8:	bc450513          	addi	a0,a0,-1084 # 80008168 <digits+0x128>
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	f9a080e7          	jalr	-102(ra) # 80000546 <panic>
    }
  }
  kfree((void*)pagetable);
    800015b4:	8552                	mv	a0,s4
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	45c080e7          	jalr	1116(ra) # 80000a12 <kfree>
}
    800015be:	70a2                	ld	ra,40(sp)
    800015c0:	7402                	ld	s0,32(sp)
    800015c2:	64e2                	ld	s1,24(sp)
    800015c4:	6942                	ld	s2,16(sp)
    800015c6:	69a2                	ld	s3,8(sp)
    800015c8:	6a02                	ld	s4,0(sp)
    800015ca:	6145                	addi	sp,sp,48
    800015cc:	8082                	ret

00000000800015ce <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015ce:	1101                	addi	sp,sp,-32
    800015d0:	ec06                	sd	ra,24(sp)
    800015d2:	e822                	sd	s0,16(sp)
    800015d4:	e426                	sd	s1,8(sp)
    800015d6:	1000                	addi	s0,sp,32
    800015d8:	84aa                	mv	s1,a0
  if(sz > 0)
    800015da:	e999                	bnez	a1,800015f0 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015dc:	8526                	mv	a0,s1
    800015de:	00000097          	auipc	ra,0x0
    800015e2:	f84080e7          	jalr	-124(ra) # 80001562 <freewalk>
}
    800015e6:	60e2                	ld	ra,24(sp)
    800015e8:	6442                	ld	s0,16(sp)
    800015ea:	64a2                	ld	s1,8(sp)
    800015ec:	6105                	addi	sp,sp,32
    800015ee:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015f0:	6785                	lui	a5,0x1
    800015f2:	17fd                	addi	a5,a5,-1
    800015f4:	95be                	add	a1,a1,a5
    800015f6:	4685                	li	a3,1
    800015f8:	00c5d613          	srli	a2,a1,0xc
    800015fc:	4581                	li	a1,0
    800015fe:	00000097          	auipc	ra,0x0
    80001602:	d0e080e7          	jalr	-754(ra) # 8000130c <uvmunmap>
    80001606:	bfd9                	j	800015dc <uvmfree+0xe>

0000000080001608 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001608:	c679                	beqz	a2,800016d6 <uvmcopy+0xce>
{
    8000160a:	715d                	addi	sp,sp,-80
    8000160c:	e486                	sd	ra,72(sp)
    8000160e:	e0a2                	sd	s0,64(sp)
    80001610:	fc26                	sd	s1,56(sp)
    80001612:	f84a                	sd	s2,48(sp)
    80001614:	f44e                	sd	s3,40(sp)
    80001616:	f052                	sd	s4,32(sp)
    80001618:	ec56                	sd	s5,24(sp)
    8000161a:	e85a                	sd	s6,16(sp)
    8000161c:	e45e                	sd	s7,8(sp)
    8000161e:	0880                	addi	s0,sp,80
    80001620:	8b2a                	mv	s6,a0
    80001622:	8aae                	mv	s5,a1
    80001624:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001626:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001628:	4601                	li	a2,0
    8000162a:	85ce                	mv	a1,s3
    8000162c:	855a                	mv	a0,s6
    8000162e:	00000097          	auipc	ra,0x0
    80001632:	a00080e7          	jalr	-1536(ra) # 8000102e <walk>
    80001636:	c531                	beqz	a0,80001682 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001638:	6118                	ld	a4,0(a0)
    8000163a:	00177793          	andi	a5,a4,1
    8000163e:	cbb1                	beqz	a5,80001692 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001640:	00a75593          	srli	a1,a4,0xa
    80001644:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001648:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000164c:	fffff097          	auipc	ra,0xfffff
    80001650:	4c4080e7          	jalr	1220(ra) # 80000b10 <kalloc>
    80001654:	892a                	mv	s2,a0
    80001656:	c939                	beqz	a0,800016ac <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001658:	6605                	lui	a2,0x1
    8000165a:	85de                	mv	a1,s7
    8000165c:	fffff097          	auipc	ra,0xfffff
    80001660:	746080e7          	jalr	1862(ra) # 80000da2 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001664:	8726                	mv	a4,s1
    80001666:	86ca                	mv	a3,s2
    80001668:	6605                	lui	a2,0x1
    8000166a:	85ce                	mv	a1,s3
    8000166c:	8556                	mv	a0,s5
    8000166e:	00000097          	auipc	ra,0x0
    80001672:	b06080e7          	jalr	-1274(ra) # 80001174 <mappages>
    80001676:	e515                	bnez	a0,800016a2 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80001678:	6785                	lui	a5,0x1
    8000167a:	99be                	add	s3,s3,a5
    8000167c:	fb49e6e3          	bltu	s3,s4,80001628 <uvmcopy+0x20>
    80001680:	a081                	j	800016c0 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001682:	00007517          	auipc	a0,0x7
    80001686:	af650513          	addi	a0,a0,-1290 # 80008178 <digits+0x138>
    8000168a:	fffff097          	auipc	ra,0xfffff
    8000168e:	ebc080e7          	jalr	-324(ra) # 80000546 <panic>
      panic("uvmcopy: page not present");
    80001692:	00007517          	auipc	a0,0x7
    80001696:	b0650513          	addi	a0,a0,-1274 # 80008198 <digits+0x158>
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	eac080e7          	jalr	-340(ra) # 80000546 <panic>
      kfree(mem);
    800016a2:	854a                	mv	a0,s2
    800016a4:	fffff097          	auipc	ra,0xfffff
    800016a8:	36e080e7          	jalr	878(ra) # 80000a12 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016ac:	4685                	li	a3,1
    800016ae:	00c9d613          	srli	a2,s3,0xc
    800016b2:	4581                	li	a1,0
    800016b4:	8556                	mv	a0,s5
    800016b6:	00000097          	auipc	ra,0x0
    800016ba:	c56080e7          	jalr	-938(ra) # 8000130c <uvmunmap>
  return -1;
    800016be:	557d                	li	a0,-1
}
    800016c0:	60a6                	ld	ra,72(sp)
    800016c2:	6406                	ld	s0,64(sp)
    800016c4:	74e2                	ld	s1,56(sp)
    800016c6:	7942                	ld	s2,48(sp)
    800016c8:	79a2                	ld	s3,40(sp)
    800016ca:	7a02                	ld	s4,32(sp)
    800016cc:	6ae2                	ld	s5,24(sp)
    800016ce:	6b42                	ld	s6,16(sp)
    800016d0:	6ba2                	ld	s7,8(sp)
    800016d2:	6161                	addi	sp,sp,80
    800016d4:	8082                	ret
  return 0;
    800016d6:	4501                	li	a0,0
}
    800016d8:	8082                	ret

00000000800016da <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016da:	1141                	addi	sp,sp,-16
    800016dc:	e406                	sd	ra,8(sp)
    800016de:	e022                	sd	s0,0(sp)
    800016e0:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016e2:	4601                	li	a2,0
    800016e4:	00000097          	auipc	ra,0x0
    800016e8:	94a080e7          	jalr	-1718(ra) # 8000102e <walk>
  if(pte == 0)
    800016ec:	c901                	beqz	a0,800016fc <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016ee:	611c                	ld	a5,0(a0)
    800016f0:	9bbd                	andi	a5,a5,-17
    800016f2:	e11c                	sd	a5,0(a0)
}
    800016f4:	60a2                	ld	ra,8(sp)
    800016f6:	6402                	ld	s0,0(sp)
    800016f8:	0141                	addi	sp,sp,16
    800016fa:	8082                	ret
    panic("uvmclear");
    800016fc:	00007517          	auipc	a0,0x7
    80001700:	abc50513          	addi	a0,a0,-1348 # 800081b8 <digits+0x178>
    80001704:	fffff097          	auipc	ra,0xfffff
    80001708:	e42080e7          	jalr	-446(ra) # 80000546 <panic>

000000008000170c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000170c:	c6bd                	beqz	a3,8000177a <copyout+0x6e>
{
    8000170e:	715d                	addi	sp,sp,-80
    80001710:	e486                	sd	ra,72(sp)
    80001712:	e0a2                	sd	s0,64(sp)
    80001714:	fc26                	sd	s1,56(sp)
    80001716:	f84a                	sd	s2,48(sp)
    80001718:	f44e                	sd	s3,40(sp)
    8000171a:	f052                	sd	s4,32(sp)
    8000171c:	ec56                	sd	s5,24(sp)
    8000171e:	e85a                	sd	s6,16(sp)
    80001720:	e45e                	sd	s7,8(sp)
    80001722:	e062                	sd	s8,0(sp)
    80001724:	0880                	addi	s0,sp,80
    80001726:	8b2a                	mv	s6,a0
    80001728:	8c2e                	mv	s8,a1
    8000172a:	8a32                	mv	s4,a2
    8000172c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000172e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001730:	6a85                	lui	s5,0x1
    80001732:	a015                	j	80001756 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001734:	9562                	add	a0,a0,s8
    80001736:	0004861b          	sext.w	a2,s1
    8000173a:	85d2                	mv	a1,s4
    8000173c:	41250533          	sub	a0,a0,s2
    80001740:	fffff097          	auipc	ra,0xfffff
    80001744:	662080e7          	jalr	1634(ra) # 80000da2 <memmove>

    len -= n;
    80001748:	409989b3          	sub	s3,s3,s1
    src += n;
    8000174c:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    8000174e:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001752:	02098263          	beqz	s3,80001776 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001756:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000175a:	85ca                	mv	a1,s2
    8000175c:	855a                	mv	a0,s6
    8000175e:	00000097          	auipc	ra,0x0
    80001762:	976080e7          	jalr	-1674(ra) # 800010d4 <walkaddr>
    if(pa0 == 0)
    80001766:	cd01                	beqz	a0,8000177e <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001768:	418904b3          	sub	s1,s2,s8
    8000176c:	94d6                	add	s1,s1,s5
    8000176e:	fc99f3e3          	bgeu	s3,s1,80001734 <copyout+0x28>
    80001772:	84ce                	mv	s1,s3
    80001774:	b7c1                	j	80001734 <copyout+0x28>
  }
  return 0;
    80001776:	4501                	li	a0,0
    80001778:	a021                	j	80001780 <copyout+0x74>
    8000177a:	4501                	li	a0,0
}
    8000177c:	8082                	ret
      return -1;
    8000177e:	557d                	li	a0,-1
}
    80001780:	60a6                	ld	ra,72(sp)
    80001782:	6406                	ld	s0,64(sp)
    80001784:	74e2                	ld	s1,56(sp)
    80001786:	7942                	ld	s2,48(sp)
    80001788:	79a2                	ld	s3,40(sp)
    8000178a:	7a02                	ld	s4,32(sp)
    8000178c:	6ae2                	ld	s5,24(sp)
    8000178e:	6b42                	ld	s6,16(sp)
    80001790:	6ba2                	ld	s7,8(sp)
    80001792:	6c02                	ld	s8,0(sp)
    80001794:	6161                	addi	sp,sp,80
    80001796:	8082                	ret

0000000080001798 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001798:	caa5                	beqz	a3,80001808 <copyin+0x70>
{
    8000179a:	715d                	addi	sp,sp,-80
    8000179c:	e486                	sd	ra,72(sp)
    8000179e:	e0a2                	sd	s0,64(sp)
    800017a0:	fc26                	sd	s1,56(sp)
    800017a2:	f84a                	sd	s2,48(sp)
    800017a4:	f44e                	sd	s3,40(sp)
    800017a6:	f052                	sd	s4,32(sp)
    800017a8:	ec56                	sd	s5,24(sp)
    800017aa:	e85a                	sd	s6,16(sp)
    800017ac:	e45e                	sd	s7,8(sp)
    800017ae:	e062                	sd	s8,0(sp)
    800017b0:	0880                	addi	s0,sp,80
    800017b2:	8b2a                	mv	s6,a0
    800017b4:	8a2e                	mv	s4,a1
    800017b6:	8c32                	mv	s8,a2
    800017b8:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017ba:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017bc:	6a85                	lui	s5,0x1
    800017be:	a01d                	j	800017e4 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017c0:	018505b3          	add	a1,a0,s8
    800017c4:	0004861b          	sext.w	a2,s1
    800017c8:	412585b3          	sub	a1,a1,s2
    800017cc:	8552                	mv	a0,s4
    800017ce:	fffff097          	auipc	ra,0xfffff
    800017d2:	5d4080e7          	jalr	1492(ra) # 80000da2 <memmove>

    len -= n;
    800017d6:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017da:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017dc:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017e0:	02098263          	beqz	s3,80001804 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017e4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017e8:	85ca                	mv	a1,s2
    800017ea:	855a                	mv	a0,s6
    800017ec:	00000097          	auipc	ra,0x0
    800017f0:	8e8080e7          	jalr	-1816(ra) # 800010d4 <walkaddr>
    if(pa0 == 0)
    800017f4:	cd01                	beqz	a0,8000180c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017f6:	418904b3          	sub	s1,s2,s8
    800017fa:	94d6                	add	s1,s1,s5
    800017fc:	fc99f2e3          	bgeu	s3,s1,800017c0 <copyin+0x28>
    80001800:	84ce                	mv	s1,s3
    80001802:	bf7d                	j	800017c0 <copyin+0x28>
  }
  return 0;
    80001804:	4501                	li	a0,0
    80001806:	a021                	j	8000180e <copyin+0x76>
    80001808:	4501                	li	a0,0
}
    8000180a:	8082                	ret
      return -1;
    8000180c:	557d                	li	a0,-1
}
    8000180e:	60a6                	ld	ra,72(sp)
    80001810:	6406                	ld	s0,64(sp)
    80001812:	74e2                	ld	s1,56(sp)
    80001814:	7942                	ld	s2,48(sp)
    80001816:	79a2                	ld	s3,40(sp)
    80001818:	7a02                	ld	s4,32(sp)
    8000181a:	6ae2                	ld	s5,24(sp)
    8000181c:	6b42                	ld	s6,16(sp)
    8000181e:	6ba2                	ld	s7,8(sp)
    80001820:	6c02                	ld	s8,0(sp)
    80001822:	6161                	addi	sp,sp,80
    80001824:	8082                	ret

0000000080001826 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001826:	c2dd                	beqz	a3,800018cc <copyinstr+0xa6>
{
    80001828:	715d                	addi	sp,sp,-80
    8000182a:	e486                	sd	ra,72(sp)
    8000182c:	e0a2                	sd	s0,64(sp)
    8000182e:	fc26                	sd	s1,56(sp)
    80001830:	f84a                	sd	s2,48(sp)
    80001832:	f44e                	sd	s3,40(sp)
    80001834:	f052                	sd	s4,32(sp)
    80001836:	ec56                	sd	s5,24(sp)
    80001838:	e85a                	sd	s6,16(sp)
    8000183a:	e45e                	sd	s7,8(sp)
    8000183c:	0880                	addi	s0,sp,80
    8000183e:	8a2a                	mv	s4,a0
    80001840:	8b2e                	mv	s6,a1
    80001842:	8bb2                	mv	s7,a2
    80001844:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001846:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001848:	6985                	lui	s3,0x1
    8000184a:	a02d                	j	80001874 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000184c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001850:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001852:	37fd                	addiw	a5,a5,-1
    80001854:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001858:	60a6                	ld	ra,72(sp)
    8000185a:	6406                	ld	s0,64(sp)
    8000185c:	74e2                	ld	s1,56(sp)
    8000185e:	7942                	ld	s2,48(sp)
    80001860:	79a2                	ld	s3,40(sp)
    80001862:	7a02                	ld	s4,32(sp)
    80001864:	6ae2                	ld	s5,24(sp)
    80001866:	6b42                	ld	s6,16(sp)
    80001868:	6ba2                	ld	s7,8(sp)
    8000186a:	6161                	addi	sp,sp,80
    8000186c:	8082                	ret
    srcva = va0 + PGSIZE;
    8000186e:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001872:	c8a9                	beqz	s1,800018c4 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80001874:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001878:	85ca                	mv	a1,s2
    8000187a:	8552                	mv	a0,s4
    8000187c:	00000097          	auipc	ra,0x0
    80001880:	858080e7          	jalr	-1960(ra) # 800010d4 <walkaddr>
    if(pa0 == 0)
    80001884:	c131                	beqz	a0,800018c8 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001886:	417906b3          	sub	a3,s2,s7
    8000188a:	96ce                	add	a3,a3,s3
    8000188c:	00d4f363          	bgeu	s1,a3,80001892 <copyinstr+0x6c>
    80001890:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001892:	955e                	add	a0,a0,s7
    80001894:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001898:	daf9                	beqz	a3,8000186e <copyinstr+0x48>
    8000189a:	87da                	mv	a5,s6
      if(*p == '\0'){
    8000189c:	41650633          	sub	a2,a0,s6
    800018a0:	fff48593          	addi	a1,s1,-1
    800018a4:	95da                	add	a1,a1,s6
    while(n > 0){
    800018a6:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800018a8:	00f60733          	add	a4,a2,a5
    800018ac:	00074703          	lbu	a4,0(a4)
    800018b0:	df51                	beqz	a4,8000184c <copyinstr+0x26>
        *dst = *p;
    800018b2:	00e78023          	sb	a4,0(a5)
      --max;
    800018b6:	40f584b3          	sub	s1,a1,a5
      dst++;
    800018ba:	0785                	addi	a5,a5,1
    while(n > 0){
    800018bc:	fed796e3          	bne	a5,a3,800018a8 <copyinstr+0x82>
      dst++;
    800018c0:	8b3e                	mv	s6,a5
    800018c2:	b775                	j	8000186e <copyinstr+0x48>
    800018c4:	4781                	li	a5,0
    800018c6:	b771                	j	80001852 <copyinstr+0x2c>
      return -1;
    800018c8:	557d                	li	a0,-1
    800018ca:	b779                	j	80001858 <copyinstr+0x32>
  int got_null = 0;
    800018cc:	4781                	li	a5,0
  if(got_null){
    800018ce:	37fd                	addiw	a5,a5,-1
    800018d0:	0007851b          	sext.w	a0,a5
}
    800018d4:	8082                	ret

00000000800018d6 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018d6:	1101                	addi	sp,sp,-32
    800018d8:	ec06                	sd	ra,24(sp)
    800018da:	e822                	sd	s0,16(sp)
    800018dc:	e426                	sd	s1,8(sp)
    800018de:	1000                	addi	s0,sp,32
    800018e0:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018e2:	fffff097          	auipc	ra,0xfffff
    800018e6:	2ee080e7          	jalr	750(ra) # 80000bd0 <holding>
    800018ea:	c909                	beqz	a0,800018fc <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018ec:	749c                	ld	a5,40(s1)
    800018ee:	00978f63          	beq	a5,s1,8000190c <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800018f2:	60e2                	ld	ra,24(sp)
    800018f4:	6442                	ld	s0,16(sp)
    800018f6:	64a2                	ld	s1,8(sp)
    800018f8:	6105                	addi	sp,sp,32
    800018fa:	8082                	ret
    panic("wakeup1");
    800018fc:	00007517          	auipc	a0,0x7
    80001900:	8cc50513          	addi	a0,a0,-1844 # 800081c8 <digits+0x188>
    80001904:	fffff097          	auipc	ra,0xfffff
    80001908:	c42080e7          	jalr	-958(ra) # 80000546 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    8000190c:	4c98                	lw	a4,24(s1)
    8000190e:	4785                	li	a5,1
    80001910:	fef711e3          	bne	a4,a5,800018f2 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001914:	4789                	li	a5,2
    80001916:	cc9c                	sw	a5,24(s1)
}
    80001918:	bfe9                	j	800018f2 <wakeup1+0x1c>

000000008000191a <procinit>:
{
    8000191a:	715d                	addi	sp,sp,-80
    8000191c:	e486                	sd	ra,72(sp)
    8000191e:	e0a2                	sd	s0,64(sp)
    80001920:	fc26                	sd	s1,56(sp)
    80001922:	f84a                	sd	s2,48(sp)
    80001924:	f44e                	sd	s3,40(sp)
    80001926:	f052                	sd	s4,32(sp)
    80001928:	ec56                	sd	s5,24(sp)
    8000192a:	e85a                	sd	s6,16(sp)
    8000192c:	e45e                	sd	s7,8(sp)
    8000192e:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001930:	00007597          	auipc	a1,0x7
    80001934:	8a058593          	addi	a1,a1,-1888 # 800081d0 <digits+0x190>
    80001938:	00010517          	auipc	a0,0x10
    8000193c:	01850513          	addi	a0,a0,24 # 80011950 <pid_lock>
    80001940:	fffff097          	auipc	ra,0xfffff
    80001944:	27a080e7          	jalr	634(ra) # 80000bba <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001948:	00010917          	auipc	s2,0x10
    8000194c:	42090913          	addi	s2,s2,1056 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001950:	00007b97          	auipc	s7,0x7
    80001954:	888b8b93          	addi	s7,s7,-1912 # 800081d8 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    80001958:	8b4a                	mv	s6,s2
    8000195a:	00006a97          	auipc	s5,0x6
    8000195e:	6a6a8a93          	addi	s5,s5,1702 # 80008000 <etext>
    80001962:	040009b7          	lui	s3,0x4000
    80001966:	19fd                	addi	s3,s3,-1
    80001968:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000196a:	00016a17          	auipc	s4,0x16
    8000196e:	dfea0a13          	addi	s4,s4,-514 # 80017768 <tickslock>
      initlock(&p->lock, "proc");
    80001972:	85de                	mv	a1,s7
    80001974:	854a                	mv	a0,s2
    80001976:	fffff097          	auipc	ra,0xfffff
    8000197a:	244080e7          	jalr	580(ra) # 80000bba <initlock>
      char *pa = kalloc();
    8000197e:	fffff097          	auipc	ra,0xfffff
    80001982:	192080e7          	jalr	402(ra) # 80000b10 <kalloc>
    80001986:	85aa                	mv	a1,a0
      if(pa == 0)
    80001988:	c929                	beqz	a0,800019da <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    8000198a:	416904b3          	sub	s1,s2,s6
    8000198e:	848d                	srai	s1,s1,0x3
    80001990:	000ab783          	ld	a5,0(s5)
    80001994:	02f484b3          	mul	s1,s1,a5
    80001998:	2485                	addiw	s1,s1,1
    8000199a:	00d4949b          	slliw	s1,s1,0xd
    8000199e:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019a2:	4699                	li	a3,6
    800019a4:	6605                	lui	a2,0x1
    800019a6:	8526                	mv	a0,s1
    800019a8:	00000097          	auipc	ra,0x0
    800019ac:	85a080e7          	jalr	-1958(ra) # 80001202 <kvmmap>
      p->kstack = va;
    800019b0:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019b4:	16890913          	addi	s2,s2,360
    800019b8:	fb491de3          	bne	s2,s4,80001972 <procinit+0x58>
  kvminithart();
    800019bc:	fffff097          	auipc	ra,0xfffff
    800019c0:	64e080e7          	jalr	1614(ra) # 8000100a <kvminithart>
}
    800019c4:	60a6                	ld	ra,72(sp)
    800019c6:	6406                	ld	s0,64(sp)
    800019c8:	74e2                	ld	s1,56(sp)
    800019ca:	7942                	ld	s2,48(sp)
    800019cc:	79a2                	ld	s3,40(sp)
    800019ce:	7a02                	ld	s4,32(sp)
    800019d0:	6ae2                	ld	s5,24(sp)
    800019d2:	6b42                	ld	s6,16(sp)
    800019d4:	6ba2                	ld	s7,8(sp)
    800019d6:	6161                	addi	sp,sp,80
    800019d8:	8082                	ret
        panic("kalloc");
    800019da:	00007517          	auipc	a0,0x7
    800019de:	80650513          	addi	a0,a0,-2042 # 800081e0 <digits+0x1a0>
    800019e2:	fffff097          	auipc	ra,0xfffff
    800019e6:	b64080e7          	jalr	-1180(ra) # 80000546 <panic>

00000000800019ea <cpuid>:
{
    800019ea:	1141                	addi	sp,sp,-16
    800019ec:	e422                	sd	s0,8(sp)
    800019ee:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019f0:	8512                	mv	a0,tp
}
    800019f2:	2501                	sext.w	a0,a0
    800019f4:	6422                	ld	s0,8(sp)
    800019f6:	0141                	addi	sp,sp,16
    800019f8:	8082                	ret

00000000800019fa <mycpu>:
mycpu(void) {
    800019fa:	1141                	addi	sp,sp,-16
    800019fc:	e422                	sd	s0,8(sp)
    800019fe:	0800                	addi	s0,sp,16
    80001a00:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a02:	2781                	sext.w	a5,a5
    80001a04:	079e                	slli	a5,a5,0x7
}
    80001a06:	00010517          	auipc	a0,0x10
    80001a0a:	f6250513          	addi	a0,a0,-158 # 80011968 <cpus>
    80001a0e:	953e                	add	a0,a0,a5
    80001a10:	6422                	ld	s0,8(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret

0000000080001a16 <myproc>:
myproc(void) {
    80001a16:	1101                	addi	sp,sp,-32
    80001a18:	ec06                	sd	ra,24(sp)
    80001a1a:	e822                	sd	s0,16(sp)
    80001a1c:	e426                	sd	s1,8(sp)
    80001a1e:	1000                	addi	s0,sp,32
  push_off();
    80001a20:	fffff097          	auipc	ra,0xfffff
    80001a24:	1de080e7          	jalr	478(ra) # 80000bfe <push_off>
    80001a28:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a2a:	2781                	sext.w	a5,a5
    80001a2c:	079e                	slli	a5,a5,0x7
    80001a2e:	00010717          	auipc	a4,0x10
    80001a32:	f2270713          	addi	a4,a4,-222 # 80011950 <pid_lock>
    80001a36:	97ba                	add	a5,a5,a4
    80001a38:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	264080e7          	jalr	612(ra) # 80000c9e <pop_off>
}
    80001a42:	8526                	mv	a0,s1
    80001a44:	60e2                	ld	ra,24(sp)
    80001a46:	6442                	ld	s0,16(sp)
    80001a48:	64a2                	ld	s1,8(sp)
    80001a4a:	6105                	addi	sp,sp,32
    80001a4c:	8082                	ret

0000000080001a4e <forkret>:
{
    80001a4e:	1141                	addi	sp,sp,-16
    80001a50:	e406                	sd	ra,8(sp)
    80001a52:	e022                	sd	s0,0(sp)
    80001a54:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a56:	00000097          	auipc	ra,0x0
    80001a5a:	fc0080e7          	jalr	-64(ra) # 80001a16 <myproc>
    80001a5e:	fffff097          	auipc	ra,0xfffff
    80001a62:	2a0080e7          	jalr	672(ra) # 80000cfe <release>
  if (first) {
    80001a66:	00007797          	auipc	a5,0x7
    80001a6a:	f3a7a783          	lw	a5,-198(a5) # 800089a0 <first.1>
    80001a6e:	eb89                	bnez	a5,80001a80 <forkret+0x32>
  usertrapret();
    80001a70:	00001097          	auipc	ra,0x1
    80001a74:	c50080e7          	jalr	-944(ra) # 800026c0 <usertrapret>
}
    80001a78:	60a2                	ld	ra,8(sp)
    80001a7a:	6402                	ld	s0,0(sp)
    80001a7c:	0141                	addi	sp,sp,16
    80001a7e:	8082                	ret
    first = 0;
    80001a80:	00007797          	auipc	a5,0x7
    80001a84:	f207a023          	sw	zero,-224(a5) # 800089a0 <first.1>
    fsinit(ROOTDEV);
    80001a88:	4505                	li	a0,1
    80001a8a:	00002097          	auipc	ra,0x2
    80001a8e:	a42080e7          	jalr	-1470(ra) # 800034cc <fsinit>
    80001a92:	bff9                	j	80001a70 <forkret+0x22>

0000000080001a94 <allocpid>:
allocpid() {
    80001a94:	1101                	addi	sp,sp,-32
    80001a96:	ec06                	sd	ra,24(sp)
    80001a98:	e822                	sd	s0,16(sp)
    80001a9a:	e426                	sd	s1,8(sp)
    80001a9c:	e04a                	sd	s2,0(sp)
    80001a9e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001aa0:	00010917          	auipc	s2,0x10
    80001aa4:	eb090913          	addi	s2,s2,-336 # 80011950 <pid_lock>
    80001aa8:	854a                	mv	a0,s2
    80001aaa:	fffff097          	auipc	ra,0xfffff
    80001aae:	1a0080e7          	jalr	416(ra) # 80000c4a <acquire>
  pid = nextpid;
    80001ab2:	00007797          	auipc	a5,0x7
    80001ab6:	ef278793          	addi	a5,a5,-270 # 800089a4 <nextpid>
    80001aba:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001abc:	0014871b          	addiw	a4,s1,1
    80001ac0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ac2:	854a                	mv	a0,s2
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	23a080e7          	jalr	570(ra) # 80000cfe <release>
}
    80001acc:	8526                	mv	a0,s1
    80001ace:	60e2                	ld	ra,24(sp)
    80001ad0:	6442                	ld	s0,16(sp)
    80001ad2:	64a2                	ld	s1,8(sp)
    80001ad4:	6902                	ld	s2,0(sp)
    80001ad6:	6105                	addi	sp,sp,32
    80001ad8:	8082                	ret

0000000080001ada <proc_pagetable>:
{
    80001ada:	1101                	addi	sp,sp,-32
    80001adc:	ec06                	sd	ra,24(sp)
    80001ade:	e822                	sd	s0,16(sp)
    80001ae0:	e426                	sd	s1,8(sp)
    80001ae2:	e04a                	sd	s2,0(sp)
    80001ae4:	1000                	addi	s0,sp,32
    80001ae6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ae8:	00000097          	auipc	ra,0x0
    80001aec:	8e8080e7          	jalr	-1816(ra) # 800013d0 <uvmcreate>
    80001af0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001af2:	c121                	beqz	a0,80001b32 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001af4:	4729                	li	a4,10
    80001af6:	00005697          	auipc	a3,0x5
    80001afa:	50a68693          	addi	a3,a3,1290 # 80007000 <_trampoline>
    80001afe:	6605                	lui	a2,0x1
    80001b00:	040005b7          	lui	a1,0x4000
    80001b04:	15fd                	addi	a1,a1,-1
    80001b06:	05b2                	slli	a1,a1,0xc
    80001b08:	fffff097          	auipc	ra,0xfffff
    80001b0c:	66c080e7          	jalr	1644(ra) # 80001174 <mappages>
    80001b10:	02054863          	bltz	a0,80001b40 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b14:	4719                	li	a4,6
    80001b16:	05893683          	ld	a3,88(s2)
    80001b1a:	6605                	lui	a2,0x1
    80001b1c:	020005b7          	lui	a1,0x2000
    80001b20:	15fd                	addi	a1,a1,-1
    80001b22:	05b6                	slli	a1,a1,0xd
    80001b24:	8526                	mv	a0,s1
    80001b26:	fffff097          	auipc	ra,0xfffff
    80001b2a:	64e080e7          	jalr	1614(ra) # 80001174 <mappages>
    80001b2e:	02054163          	bltz	a0,80001b50 <proc_pagetable+0x76>
}
    80001b32:	8526                	mv	a0,s1
    80001b34:	60e2                	ld	ra,24(sp)
    80001b36:	6442                	ld	s0,16(sp)
    80001b38:	64a2                	ld	s1,8(sp)
    80001b3a:	6902                	ld	s2,0(sp)
    80001b3c:	6105                	addi	sp,sp,32
    80001b3e:	8082                	ret
    uvmfree(pagetable, 0);
    80001b40:	4581                	li	a1,0
    80001b42:	8526                	mv	a0,s1
    80001b44:	00000097          	auipc	ra,0x0
    80001b48:	a8a080e7          	jalr	-1398(ra) # 800015ce <uvmfree>
    return 0;
    80001b4c:	4481                	li	s1,0
    80001b4e:	b7d5                	j	80001b32 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b50:	4681                	li	a3,0
    80001b52:	4605                	li	a2,1
    80001b54:	040005b7          	lui	a1,0x4000
    80001b58:	15fd                	addi	a1,a1,-1
    80001b5a:	05b2                	slli	a1,a1,0xc
    80001b5c:	8526                	mv	a0,s1
    80001b5e:	fffff097          	auipc	ra,0xfffff
    80001b62:	7ae080e7          	jalr	1966(ra) # 8000130c <uvmunmap>
    uvmfree(pagetable, 0);
    80001b66:	4581                	li	a1,0
    80001b68:	8526                	mv	a0,s1
    80001b6a:	00000097          	auipc	ra,0x0
    80001b6e:	a64080e7          	jalr	-1436(ra) # 800015ce <uvmfree>
    return 0;
    80001b72:	4481                	li	s1,0
    80001b74:	bf7d                	j	80001b32 <proc_pagetable+0x58>

0000000080001b76 <proc_freepagetable>:
{
    80001b76:	1101                	addi	sp,sp,-32
    80001b78:	ec06                	sd	ra,24(sp)
    80001b7a:	e822                	sd	s0,16(sp)
    80001b7c:	e426                	sd	s1,8(sp)
    80001b7e:	e04a                	sd	s2,0(sp)
    80001b80:	1000                	addi	s0,sp,32
    80001b82:	84aa                	mv	s1,a0
    80001b84:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b86:	4681                	li	a3,0
    80001b88:	4605                	li	a2,1
    80001b8a:	040005b7          	lui	a1,0x4000
    80001b8e:	15fd                	addi	a1,a1,-1
    80001b90:	05b2                	slli	a1,a1,0xc
    80001b92:	fffff097          	auipc	ra,0xfffff
    80001b96:	77a080e7          	jalr	1914(ra) # 8000130c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b9a:	4681                	li	a3,0
    80001b9c:	4605                	li	a2,1
    80001b9e:	020005b7          	lui	a1,0x2000
    80001ba2:	15fd                	addi	a1,a1,-1
    80001ba4:	05b6                	slli	a1,a1,0xd
    80001ba6:	8526                	mv	a0,s1
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	764080e7          	jalr	1892(ra) # 8000130c <uvmunmap>
  uvmfree(pagetable, sz);
    80001bb0:	85ca                	mv	a1,s2
    80001bb2:	8526                	mv	a0,s1
    80001bb4:	00000097          	auipc	ra,0x0
    80001bb8:	a1a080e7          	jalr	-1510(ra) # 800015ce <uvmfree>
}
    80001bbc:	60e2                	ld	ra,24(sp)
    80001bbe:	6442                	ld	s0,16(sp)
    80001bc0:	64a2                	ld	s1,8(sp)
    80001bc2:	6902                	ld	s2,0(sp)
    80001bc4:	6105                	addi	sp,sp,32
    80001bc6:	8082                	ret

0000000080001bc8 <freeproc>:
{
    80001bc8:	1101                	addi	sp,sp,-32
    80001bca:	ec06                	sd	ra,24(sp)
    80001bcc:	e822                	sd	s0,16(sp)
    80001bce:	e426                	sd	s1,8(sp)
    80001bd0:	1000                	addi	s0,sp,32
    80001bd2:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bd4:	6d28                	ld	a0,88(a0)
    80001bd6:	c509                	beqz	a0,80001be0 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bd8:	fffff097          	auipc	ra,0xfffff
    80001bdc:	e3a080e7          	jalr	-454(ra) # 80000a12 <kfree>
  p->trapframe = 0;
    80001be0:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001be4:	68a8                	ld	a0,80(s1)
    80001be6:	c511                	beqz	a0,80001bf2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001be8:	64ac                	ld	a1,72(s1)
    80001bea:	00000097          	auipc	ra,0x0
    80001bee:	f8c080e7          	jalr	-116(ra) # 80001b76 <proc_freepagetable>
  p->pagetable = 0;
    80001bf2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bf6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bfa:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001bfe:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c02:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c06:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c0a:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c0e:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c12:	0004ac23          	sw	zero,24(s1)
}
    80001c16:	60e2                	ld	ra,24(sp)
    80001c18:	6442                	ld	s0,16(sp)
    80001c1a:	64a2                	ld	s1,8(sp)
    80001c1c:	6105                	addi	sp,sp,32
    80001c1e:	8082                	ret

0000000080001c20 <allocproc>:
{
    80001c20:	1101                	addi	sp,sp,-32
    80001c22:	ec06                	sd	ra,24(sp)
    80001c24:	e822                	sd	s0,16(sp)
    80001c26:	e426                	sd	s1,8(sp)
    80001c28:	e04a                	sd	s2,0(sp)
    80001c2a:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c2c:	00010497          	auipc	s1,0x10
    80001c30:	13c48493          	addi	s1,s1,316 # 80011d68 <proc>
    80001c34:	00016917          	auipc	s2,0x16
    80001c38:	b3490913          	addi	s2,s2,-1228 # 80017768 <tickslock>
    acquire(&p->lock);
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	fffff097          	auipc	ra,0xfffff
    80001c42:	00c080e7          	jalr	12(ra) # 80000c4a <acquire>
    if(p->state == UNUSED) {
    80001c46:	4c9c                	lw	a5,24(s1)
    80001c48:	cf81                	beqz	a5,80001c60 <allocproc+0x40>
      release(&p->lock);
    80001c4a:	8526                	mv	a0,s1
    80001c4c:	fffff097          	auipc	ra,0xfffff
    80001c50:	0b2080e7          	jalr	178(ra) # 80000cfe <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c54:	16848493          	addi	s1,s1,360
    80001c58:	ff2492e3          	bne	s1,s2,80001c3c <allocproc+0x1c>
  return 0;
    80001c5c:	4481                	li	s1,0
    80001c5e:	a0b9                	j	80001cac <allocproc+0x8c>
  p->pid = allocpid();
    80001c60:	00000097          	auipc	ra,0x0
    80001c64:	e34080e7          	jalr	-460(ra) # 80001a94 <allocpid>
    80001c68:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c6a:	fffff097          	auipc	ra,0xfffff
    80001c6e:	ea6080e7          	jalr	-346(ra) # 80000b10 <kalloc>
    80001c72:	892a                	mv	s2,a0
    80001c74:	eca8                	sd	a0,88(s1)
    80001c76:	c131                	beqz	a0,80001cba <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001c78:	8526                	mv	a0,s1
    80001c7a:	00000097          	auipc	ra,0x0
    80001c7e:	e60080e7          	jalr	-416(ra) # 80001ada <proc_pagetable>
    80001c82:	892a                	mv	s2,a0
    80001c84:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c86:	c129                	beqz	a0,80001cc8 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001c88:	07000613          	li	a2,112
    80001c8c:	4581                	li	a1,0
    80001c8e:	06048513          	addi	a0,s1,96
    80001c92:	fffff097          	auipc	ra,0xfffff
    80001c96:	0b4080e7          	jalr	180(ra) # 80000d46 <memset>
  p->context.ra = (uint64)forkret;
    80001c9a:	00000797          	auipc	a5,0x0
    80001c9e:	db478793          	addi	a5,a5,-588 # 80001a4e <forkret>
    80001ca2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ca4:	60bc                	ld	a5,64(s1)
    80001ca6:	6705                	lui	a4,0x1
    80001ca8:	97ba                	add	a5,a5,a4
    80001caa:	f4bc                	sd	a5,104(s1)
}
    80001cac:	8526                	mv	a0,s1
    80001cae:	60e2                	ld	ra,24(sp)
    80001cb0:	6442                	ld	s0,16(sp)
    80001cb2:	64a2                	ld	s1,8(sp)
    80001cb4:	6902                	ld	s2,0(sp)
    80001cb6:	6105                	addi	sp,sp,32
    80001cb8:	8082                	ret
    release(&p->lock);
    80001cba:	8526                	mv	a0,s1
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	042080e7          	jalr	66(ra) # 80000cfe <release>
    return 0;
    80001cc4:	84ca                	mv	s1,s2
    80001cc6:	b7dd                	j	80001cac <allocproc+0x8c>
    freeproc(p);
    80001cc8:	8526                	mv	a0,s1
    80001cca:	00000097          	auipc	ra,0x0
    80001cce:	efe080e7          	jalr	-258(ra) # 80001bc8 <freeproc>
    release(&p->lock);
    80001cd2:	8526                	mv	a0,s1
    80001cd4:	fffff097          	auipc	ra,0xfffff
    80001cd8:	02a080e7          	jalr	42(ra) # 80000cfe <release>
    return 0;
    80001cdc:	84ca                	mv	s1,s2
    80001cde:	b7f9                	j	80001cac <allocproc+0x8c>

0000000080001ce0 <userinit>:
{
    80001ce0:	1101                	addi	sp,sp,-32
    80001ce2:	ec06                	sd	ra,24(sp)
    80001ce4:	e822                	sd	s0,16(sp)
    80001ce6:	e426                	sd	s1,8(sp)
    80001ce8:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cea:	00000097          	auipc	ra,0x0
    80001cee:	f36080e7          	jalr	-202(ra) # 80001c20 <allocproc>
    80001cf2:	84aa                	mv	s1,a0
  initproc = p;
    80001cf4:	00007797          	auipc	a5,0x7
    80001cf8:	32a7b223          	sd	a0,804(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001cfc:	03400613          	li	a2,52
    80001d00:	00007597          	auipc	a1,0x7
    80001d04:	cb058593          	addi	a1,a1,-848 # 800089b0 <initcode>
    80001d08:	6928                	ld	a0,80(a0)
    80001d0a:	fffff097          	auipc	ra,0xfffff
    80001d0e:	6f4080e7          	jalr	1780(ra) # 800013fe <uvminit>
  p->sz = PGSIZE;
    80001d12:	6785                	lui	a5,0x1
    80001d14:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d16:	6cb8                	ld	a4,88(s1)
    80001d18:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d1c:	6cb8                	ld	a4,88(s1)
    80001d1e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d20:	4641                	li	a2,16
    80001d22:	00006597          	auipc	a1,0x6
    80001d26:	4c658593          	addi	a1,a1,1222 # 800081e8 <digits+0x1a8>
    80001d2a:	15848513          	addi	a0,s1,344
    80001d2e:	fffff097          	auipc	ra,0xfffff
    80001d32:	16a080e7          	jalr	362(ra) # 80000e98 <safestrcpy>
  p->cwd = namei("/");
    80001d36:	00006517          	auipc	a0,0x6
    80001d3a:	4c250513          	addi	a0,a0,1218 # 800081f8 <digits+0x1b8>
    80001d3e:	00002097          	auipc	ra,0x2
    80001d42:	1be080e7          	jalr	446(ra) # 80003efc <namei>
    80001d46:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d4a:	4789                	li	a5,2
    80001d4c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d4e:	8526                	mv	a0,s1
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	fae080e7          	jalr	-82(ra) # 80000cfe <release>
}
    80001d58:	60e2                	ld	ra,24(sp)
    80001d5a:	6442                	ld	s0,16(sp)
    80001d5c:	64a2                	ld	s1,8(sp)
    80001d5e:	6105                	addi	sp,sp,32
    80001d60:	8082                	ret

0000000080001d62 <growproc>:
{
    80001d62:	1101                	addi	sp,sp,-32
    80001d64:	ec06                	sd	ra,24(sp)
    80001d66:	e822                	sd	s0,16(sp)
    80001d68:	e426                	sd	s1,8(sp)
    80001d6a:	e04a                	sd	s2,0(sp)
    80001d6c:	1000                	addi	s0,sp,32
    80001d6e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d70:	00000097          	auipc	ra,0x0
    80001d74:	ca6080e7          	jalr	-858(ra) # 80001a16 <myproc>
    80001d78:	892a                	mv	s2,a0
  sz = p->sz;
    80001d7a:	652c                	ld	a1,72(a0)
    80001d7c:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001d80:	00904f63          	bgtz	s1,80001d9e <growproc+0x3c>
  } else if(n < 0){
    80001d84:	0204cd63          	bltz	s1,80001dbe <growproc+0x5c>
  p->sz = sz;
    80001d88:	1782                	slli	a5,a5,0x20
    80001d8a:	9381                	srli	a5,a5,0x20
    80001d8c:	04f93423          	sd	a5,72(s2)
  return 0;
    80001d90:	4501                	li	a0,0
}
    80001d92:	60e2                	ld	ra,24(sp)
    80001d94:	6442                	ld	s0,16(sp)
    80001d96:	64a2                	ld	s1,8(sp)
    80001d98:	6902                	ld	s2,0(sp)
    80001d9a:	6105                	addi	sp,sp,32
    80001d9c:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001d9e:	00f4863b          	addw	a2,s1,a5
    80001da2:	1602                	slli	a2,a2,0x20
    80001da4:	9201                	srli	a2,a2,0x20
    80001da6:	1582                	slli	a1,a1,0x20
    80001da8:	9181                	srli	a1,a1,0x20
    80001daa:	6928                	ld	a0,80(a0)
    80001dac:	fffff097          	auipc	ra,0xfffff
    80001db0:	70c080e7          	jalr	1804(ra) # 800014b8 <uvmalloc>
    80001db4:	0005079b          	sext.w	a5,a0
    80001db8:	fbe1                	bnez	a5,80001d88 <growproc+0x26>
      return -1;
    80001dba:	557d                	li	a0,-1
    80001dbc:	bfd9                	j	80001d92 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dbe:	00f4863b          	addw	a2,s1,a5
    80001dc2:	1602                	slli	a2,a2,0x20
    80001dc4:	9201                	srli	a2,a2,0x20
    80001dc6:	1582                	slli	a1,a1,0x20
    80001dc8:	9181                	srli	a1,a1,0x20
    80001dca:	6928                	ld	a0,80(a0)
    80001dcc:	fffff097          	auipc	ra,0xfffff
    80001dd0:	6a4080e7          	jalr	1700(ra) # 80001470 <uvmdealloc>
    80001dd4:	0005079b          	sext.w	a5,a0
    80001dd8:	bf45                	j	80001d88 <growproc+0x26>

0000000080001dda <fork>:
{
    80001dda:	7139                	addi	sp,sp,-64
    80001ddc:	fc06                	sd	ra,56(sp)
    80001dde:	f822                	sd	s0,48(sp)
    80001de0:	f426                	sd	s1,40(sp)
    80001de2:	f04a                	sd	s2,32(sp)
    80001de4:	ec4e                	sd	s3,24(sp)
    80001de6:	e852                	sd	s4,16(sp)
    80001de8:	e456                	sd	s5,8(sp)
    80001dea:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dec:	00000097          	auipc	ra,0x0
    80001df0:	c2a080e7          	jalr	-982(ra) # 80001a16 <myproc>
    80001df4:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001df6:	00000097          	auipc	ra,0x0
    80001dfa:	e2a080e7          	jalr	-470(ra) # 80001c20 <allocproc>
    80001dfe:	c57d                	beqz	a0,80001eec <fork+0x112>
    80001e00:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e02:	048ab603          	ld	a2,72(s5)
    80001e06:	692c                	ld	a1,80(a0)
    80001e08:	050ab503          	ld	a0,80(s5)
    80001e0c:	fffff097          	auipc	ra,0xfffff
    80001e10:	7fc080e7          	jalr	2044(ra) # 80001608 <uvmcopy>
    80001e14:	04054e63          	bltz	a0,80001e70 <fork+0x96>
  np->sz = p->sz;
    80001e18:	048ab783          	ld	a5,72(s5)
    80001e1c:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001e20:	035a3023          	sd	s5,32(s4)
  np->mask = p->mask;
    80001e24:	03caa783          	lw	a5,60(s5)
    80001e28:	02fa2e23          	sw	a5,60(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e2c:	058ab683          	ld	a3,88(s5)
    80001e30:	87b6                	mv	a5,a3
    80001e32:	058a3703          	ld	a4,88(s4)
    80001e36:	12068693          	addi	a3,a3,288
    80001e3a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e3e:	6788                	ld	a0,8(a5)
    80001e40:	6b8c                	ld	a1,16(a5)
    80001e42:	6f90                	ld	a2,24(a5)
    80001e44:	01073023          	sd	a6,0(a4)
    80001e48:	e708                	sd	a0,8(a4)
    80001e4a:	eb0c                	sd	a1,16(a4)
    80001e4c:	ef10                	sd	a2,24(a4)
    80001e4e:	02078793          	addi	a5,a5,32
    80001e52:	02070713          	addi	a4,a4,32
    80001e56:	fed792e3          	bne	a5,a3,80001e3a <fork+0x60>
  np->trapframe->a0 = 0;
    80001e5a:	058a3783          	ld	a5,88(s4)
    80001e5e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e62:	0d0a8493          	addi	s1,s5,208
    80001e66:	0d0a0913          	addi	s2,s4,208
    80001e6a:	150a8993          	addi	s3,s5,336
    80001e6e:	a00d                	j	80001e90 <fork+0xb6>
    freeproc(np);
    80001e70:	8552                	mv	a0,s4
    80001e72:	00000097          	auipc	ra,0x0
    80001e76:	d56080e7          	jalr	-682(ra) # 80001bc8 <freeproc>
    release(&np->lock);
    80001e7a:	8552                	mv	a0,s4
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	e82080e7          	jalr	-382(ra) # 80000cfe <release>
    return -1;
    80001e84:	54fd                	li	s1,-1
    80001e86:	a889                	j	80001ed8 <fork+0xfe>
  for(i = 0; i < NOFILE; i++)
    80001e88:	04a1                	addi	s1,s1,8
    80001e8a:	0921                	addi	s2,s2,8
    80001e8c:	01348b63          	beq	s1,s3,80001ea2 <fork+0xc8>
    if(p->ofile[i])
    80001e90:	6088                	ld	a0,0(s1)
    80001e92:	d97d                	beqz	a0,80001e88 <fork+0xae>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e94:	00002097          	auipc	ra,0x2
    80001e98:	6f4080e7          	jalr	1780(ra) # 80004588 <filedup>
    80001e9c:	00a93023          	sd	a0,0(s2)
    80001ea0:	b7e5                	j	80001e88 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001ea2:	150ab503          	ld	a0,336(s5)
    80001ea6:	00002097          	auipc	ra,0x2
    80001eaa:	862080e7          	jalr	-1950(ra) # 80003708 <idup>
    80001eae:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eb2:	4641                	li	a2,16
    80001eb4:	158a8593          	addi	a1,s5,344
    80001eb8:	158a0513          	addi	a0,s4,344
    80001ebc:	fffff097          	auipc	ra,0xfffff
    80001ec0:	fdc080e7          	jalr	-36(ra) # 80000e98 <safestrcpy>
  pid = np->pid;
    80001ec4:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001ec8:	4789                	li	a5,2
    80001eca:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001ece:	8552                	mv	a0,s4
    80001ed0:	fffff097          	auipc	ra,0xfffff
    80001ed4:	e2e080e7          	jalr	-466(ra) # 80000cfe <release>
}
    80001ed8:	8526                	mv	a0,s1
    80001eda:	70e2                	ld	ra,56(sp)
    80001edc:	7442                	ld	s0,48(sp)
    80001ede:	74a2                	ld	s1,40(sp)
    80001ee0:	7902                	ld	s2,32(sp)
    80001ee2:	69e2                	ld	s3,24(sp)
    80001ee4:	6a42                	ld	s4,16(sp)
    80001ee6:	6aa2                	ld	s5,8(sp)
    80001ee8:	6121                	addi	sp,sp,64
    80001eea:	8082                	ret
    return -1;
    80001eec:	54fd                	li	s1,-1
    80001eee:	b7ed                	j	80001ed8 <fork+0xfe>

0000000080001ef0 <reparent>:
{
    80001ef0:	7179                	addi	sp,sp,-48
    80001ef2:	f406                	sd	ra,40(sp)
    80001ef4:	f022                	sd	s0,32(sp)
    80001ef6:	ec26                	sd	s1,24(sp)
    80001ef8:	e84a                	sd	s2,16(sp)
    80001efa:	e44e                	sd	s3,8(sp)
    80001efc:	e052                	sd	s4,0(sp)
    80001efe:	1800                	addi	s0,sp,48
    80001f00:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f02:	00010497          	auipc	s1,0x10
    80001f06:	e6648493          	addi	s1,s1,-410 # 80011d68 <proc>
      pp->parent = initproc;
    80001f0a:	00007a17          	auipc	s4,0x7
    80001f0e:	10ea0a13          	addi	s4,s4,270 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f12:	00016997          	auipc	s3,0x16
    80001f16:	85698993          	addi	s3,s3,-1962 # 80017768 <tickslock>
    80001f1a:	a029                	j	80001f24 <reparent+0x34>
    80001f1c:	16848493          	addi	s1,s1,360
    80001f20:	03348363          	beq	s1,s3,80001f46 <reparent+0x56>
    if(pp->parent == p){
    80001f24:	709c                	ld	a5,32(s1)
    80001f26:	ff279be3          	bne	a5,s2,80001f1c <reparent+0x2c>
      acquire(&pp->lock);
    80001f2a:	8526                	mv	a0,s1
    80001f2c:	fffff097          	auipc	ra,0xfffff
    80001f30:	d1e080e7          	jalr	-738(ra) # 80000c4a <acquire>
      pp->parent = initproc;
    80001f34:	000a3783          	ld	a5,0(s4)
    80001f38:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	dc2080e7          	jalr	-574(ra) # 80000cfe <release>
    80001f44:	bfe1                	j	80001f1c <reparent+0x2c>
}
    80001f46:	70a2                	ld	ra,40(sp)
    80001f48:	7402                	ld	s0,32(sp)
    80001f4a:	64e2                	ld	s1,24(sp)
    80001f4c:	6942                	ld	s2,16(sp)
    80001f4e:	69a2                	ld	s3,8(sp)
    80001f50:	6a02                	ld	s4,0(sp)
    80001f52:	6145                	addi	sp,sp,48
    80001f54:	8082                	ret

0000000080001f56 <scheduler>:
{
    80001f56:	715d                	addi	sp,sp,-80
    80001f58:	e486                	sd	ra,72(sp)
    80001f5a:	e0a2                	sd	s0,64(sp)
    80001f5c:	fc26                	sd	s1,56(sp)
    80001f5e:	f84a                	sd	s2,48(sp)
    80001f60:	f44e                	sd	s3,40(sp)
    80001f62:	f052                	sd	s4,32(sp)
    80001f64:	ec56                	sd	s5,24(sp)
    80001f66:	e85a                	sd	s6,16(sp)
    80001f68:	e45e                	sd	s7,8(sp)
    80001f6a:	e062                	sd	s8,0(sp)
    80001f6c:	0880                	addi	s0,sp,80
    80001f6e:	8792                	mv	a5,tp
  int id = r_tp();
    80001f70:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f72:	00779b13          	slli	s6,a5,0x7
    80001f76:	00010717          	auipc	a4,0x10
    80001f7a:	9da70713          	addi	a4,a4,-1574 # 80011950 <pid_lock>
    80001f7e:	975a                	add	a4,a4,s6
    80001f80:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001f84:	00010717          	auipc	a4,0x10
    80001f88:	9ec70713          	addi	a4,a4,-1556 # 80011970 <cpus+0x8>
    80001f8c:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f8e:	4c0d                	li	s8,3
        c->proc = p;
    80001f90:	079e                	slli	a5,a5,0x7
    80001f92:	00010a17          	auipc	s4,0x10
    80001f96:	9bea0a13          	addi	s4,s4,-1602 # 80011950 <pid_lock>
    80001f9a:	9a3e                	add	s4,s4,a5
        found = 1;
    80001f9c:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f9e:	00015997          	auipc	s3,0x15
    80001fa2:	7ca98993          	addi	s3,s3,1994 # 80017768 <tickslock>
    80001fa6:	a899                	j	80001ffc <scheduler+0xa6>
      release(&p->lock);
    80001fa8:	8526                	mv	a0,s1
    80001faa:	fffff097          	auipc	ra,0xfffff
    80001fae:	d54080e7          	jalr	-684(ra) # 80000cfe <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fb2:	16848493          	addi	s1,s1,360
    80001fb6:	03348963          	beq	s1,s3,80001fe8 <scheduler+0x92>
      acquire(&p->lock);
    80001fba:	8526                	mv	a0,s1
    80001fbc:	fffff097          	auipc	ra,0xfffff
    80001fc0:	c8e080e7          	jalr	-882(ra) # 80000c4a <acquire>
      if(p->state == RUNNABLE) {
    80001fc4:	4c9c                	lw	a5,24(s1)
    80001fc6:	ff2791e3          	bne	a5,s2,80001fa8 <scheduler+0x52>
        p->state = RUNNING;
    80001fca:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001fce:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80001fd2:	06048593          	addi	a1,s1,96
    80001fd6:	855a                	mv	a0,s6
    80001fd8:	00000097          	auipc	ra,0x0
    80001fdc:	63e080e7          	jalr	1598(ra) # 80002616 <swtch>
        c->proc = 0;
    80001fe0:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001fe4:	8ade                	mv	s5,s7
    80001fe6:	b7c9                	j	80001fa8 <scheduler+0x52>
    if(found == 0) {
    80001fe8:	000a9a63          	bnez	s5,80001ffc <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ff0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ff4:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001ff8:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ffc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002000:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002004:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002008:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    8000200a:	00010497          	auipc	s1,0x10
    8000200e:	d5e48493          	addi	s1,s1,-674 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    80002012:	4909                	li	s2,2
    80002014:	b75d                	j	80001fba <scheduler+0x64>

0000000080002016 <sched>:
{
    80002016:	7179                	addi	sp,sp,-48
    80002018:	f406                	sd	ra,40(sp)
    8000201a:	f022                	sd	s0,32(sp)
    8000201c:	ec26                	sd	s1,24(sp)
    8000201e:	e84a                	sd	s2,16(sp)
    80002020:	e44e                	sd	s3,8(sp)
    80002022:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002024:	00000097          	auipc	ra,0x0
    80002028:	9f2080e7          	jalr	-1550(ra) # 80001a16 <myproc>
    8000202c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000202e:	fffff097          	auipc	ra,0xfffff
    80002032:	ba2080e7          	jalr	-1118(ra) # 80000bd0 <holding>
    80002036:	c93d                	beqz	a0,800020ac <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002038:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000203a:	2781                	sext.w	a5,a5
    8000203c:	079e                	slli	a5,a5,0x7
    8000203e:	00010717          	auipc	a4,0x10
    80002042:	91270713          	addi	a4,a4,-1774 # 80011950 <pid_lock>
    80002046:	97ba                	add	a5,a5,a4
    80002048:	0907a703          	lw	a4,144(a5)
    8000204c:	4785                	li	a5,1
    8000204e:	06f71763          	bne	a4,a5,800020bc <sched+0xa6>
  if(p->state == RUNNING)
    80002052:	4c98                	lw	a4,24(s1)
    80002054:	478d                	li	a5,3
    80002056:	06f70b63          	beq	a4,a5,800020cc <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000205a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000205e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80002060:	efb5                	bnez	a5,800020dc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002062:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002064:	00010917          	auipc	s2,0x10
    80002068:	8ec90913          	addi	s2,s2,-1812 # 80011950 <pid_lock>
    8000206c:	2781                	sext.w	a5,a5
    8000206e:	079e                	slli	a5,a5,0x7
    80002070:	97ca                	add	a5,a5,s2
    80002072:	0947a983          	lw	s3,148(a5)
    80002076:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002078:	2781                	sext.w	a5,a5
    8000207a:	079e                	slli	a5,a5,0x7
    8000207c:	00010597          	auipc	a1,0x10
    80002080:	8f458593          	addi	a1,a1,-1804 # 80011970 <cpus+0x8>
    80002084:	95be                	add	a1,a1,a5
    80002086:	06048513          	addi	a0,s1,96
    8000208a:	00000097          	auipc	ra,0x0
    8000208e:	58c080e7          	jalr	1420(ra) # 80002616 <swtch>
    80002092:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002094:	2781                	sext.w	a5,a5
    80002096:	079e                	slli	a5,a5,0x7
    80002098:	993e                	add	s2,s2,a5
    8000209a:	09392a23          	sw	s3,148(s2)
}
    8000209e:	70a2                	ld	ra,40(sp)
    800020a0:	7402                	ld	s0,32(sp)
    800020a2:	64e2                	ld	s1,24(sp)
    800020a4:	6942                	ld	s2,16(sp)
    800020a6:	69a2                	ld	s3,8(sp)
    800020a8:	6145                	addi	sp,sp,48
    800020aa:	8082                	ret
    panic("sched p->lock");
    800020ac:	00006517          	auipc	a0,0x6
    800020b0:	15450513          	addi	a0,a0,340 # 80008200 <digits+0x1c0>
    800020b4:	ffffe097          	auipc	ra,0xffffe
    800020b8:	492080e7          	jalr	1170(ra) # 80000546 <panic>
    panic("sched locks");
    800020bc:	00006517          	auipc	a0,0x6
    800020c0:	15450513          	addi	a0,a0,340 # 80008210 <digits+0x1d0>
    800020c4:	ffffe097          	auipc	ra,0xffffe
    800020c8:	482080e7          	jalr	1154(ra) # 80000546 <panic>
    panic("sched running");
    800020cc:	00006517          	auipc	a0,0x6
    800020d0:	15450513          	addi	a0,a0,340 # 80008220 <digits+0x1e0>
    800020d4:	ffffe097          	auipc	ra,0xffffe
    800020d8:	472080e7          	jalr	1138(ra) # 80000546 <panic>
    panic("sched interruptible");
    800020dc:	00006517          	auipc	a0,0x6
    800020e0:	15450513          	addi	a0,a0,340 # 80008230 <digits+0x1f0>
    800020e4:	ffffe097          	auipc	ra,0xffffe
    800020e8:	462080e7          	jalr	1122(ra) # 80000546 <panic>

00000000800020ec <exit>:
{
    800020ec:	7179                	addi	sp,sp,-48
    800020ee:	f406                	sd	ra,40(sp)
    800020f0:	f022                	sd	s0,32(sp)
    800020f2:	ec26                	sd	s1,24(sp)
    800020f4:	e84a                	sd	s2,16(sp)
    800020f6:	e44e                	sd	s3,8(sp)
    800020f8:	e052                	sd	s4,0(sp)
    800020fa:	1800                	addi	s0,sp,48
    800020fc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	918080e7          	jalr	-1768(ra) # 80001a16 <myproc>
    80002106:	89aa                	mv	s3,a0
  if(p == initproc)
    80002108:	00007797          	auipc	a5,0x7
    8000210c:	f107b783          	ld	a5,-240(a5) # 80009018 <initproc>
    80002110:	0d050493          	addi	s1,a0,208
    80002114:	15050913          	addi	s2,a0,336
    80002118:	02a79363          	bne	a5,a0,8000213e <exit+0x52>
    panic("init exiting");
    8000211c:	00006517          	auipc	a0,0x6
    80002120:	12c50513          	addi	a0,a0,300 # 80008248 <digits+0x208>
    80002124:	ffffe097          	auipc	ra,0xffffe
    80002128:	422080e7          	jalr	1058(ra) # 80000546 <panic>
      fileclose(f);
    8000212c:	00002097          	auipc	ra,0x2
    80002130:	4ae080e7          	jalr	1198(ra) # 800045da <fileclose>
      p->ofile[fd] = 0;
    80002134:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002138:	04a1                	addi	s1,s1,8
    8000213a:	01248563          	beq	s1,s2,80002144 <exit+0x58>
    if(p->ofile[fd]){
    8000213e:	6088                	ld	a0,0(s1)
    80002140:	f575                	bnez	a0,8000212c <exit+0x40>
    80002142:	bfdd                	j	80002138 <exit+0x4c>
  begin_op();
    80002144:	00002097          	auipc	ra,0x2
    80002148:	fc8080e7          	jalr	-56(ra) # 8000410c <begin_op>
  iput(p->cwd);
    8000214c:	1509b503          	ld	a0,336(s3)
    80002150:	00001097          	auipc	ra,0x1
    80002154:	7b0080e7          	jalr	1968(ra) # 80003900 <iput>
  end_op();
    80002158:	00002097          	auipc	ra,0x2
    8000215c:	032080e7          	jalr	50(ra) # 8000418a <end_op>
  p->cwd = 0;
    80002160:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    80002164:	00007497          	auipc	s1,0x7
    80002168:	eb448493          	addi	s1,s1,-332 # 80009018 <initproc>
    8000216c:	6088                	ld	a0,0(s1)
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	adc080e7          	jalr	-1316(ra) # 80000c4a <acquire>
  wakeup1(initproc);
    80002176:	6088                	ld	a0,0(s1)
    80002178:	fffff097          	auipc	ra,0xfffff
    8000217c:	75e080e7          	jalr	1886(ra) # 800018d6 <wakeup1>
  release(&initproc->lock);
    80002180:	6088                	ld	a0,0(s1)
    80002182:	fffff097          	auipc	ra,0xfffff
    80002186:	b7c080e7          	jalr	-1156(ra) # 80000cfe <release>
  acquire(&p->lock);
    8000218a:	854e                	mv	a0,s3
    8000218c:	fffff097          	auipc	ra,0xfffff
    80002190:	abe080e7          	jalr	-1346(ra) # 80000c4a <acquire>
  struct proc *original_parent = p->parent;
    80002194:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002198:	854e                	mv	a0,s3
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	b64080e7          	jalr	-1180(ra) # 80000cfe <release>
  acquire(&original_parent->lock);
    800021a2:	8526                	mv	a0,s1
    800021a4:	fffff097          	auipc	ra,0xfffff
    800021a8:	aa6080e7          	jalr	-1370(ra) # 80000c4a <acquire>
  acquire(&p->lock);
    800021ac:	854e                	mv	a0,s3
    800021ae:	fffff097          	auipc	ra,0xfffff
    800021b2:	a9c080e7          	jalr	-1380(ra) # 80000c4a <acquire>
  reparent(p);
    800021b6:	854e                	mv	a0,s3
    800021b8:	00000097          	auipc	ra,0x0
    800021bc:	d38080e7          	jalr	-712(ra) # 80001ef0 <reparent>
  wakeup1(original_parent);
    800021c0:	8526                	mv	a0,s1
    800021c2:	fffff097          	auipc	ra,0xfffff
    800021c6:	714080e7          	jalr	1812(ra) # 800018d6 <wakeup1>
  p->xstate = status;
    800021ca:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800021ce:	4791                	li	a5,4
    800021d0:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800021d4:	8526                	mv	a0,s1
    800021d6:	fffff097          	auipc	ra,0xfffff
    800021da:	b28080e7          	jalr	-1240(ra) # 80000cfe <release>
  sched();
    800021de:	00000097          	auipc	ra,0x0
    800021e2:	e38080e7          	jalr	-456(ra) # 80002016 <sched>
  panic("zombie exit");
    800021e6:	00006517          	auipc	a0,0x6
    800021ea:	07250513          	addi	a0,a0,114 # 80008258 <digits+0x218>
    800021ee:	ffffe097          	auipc	ra,0xffffe
    800021f2:	358080e7          	jalr	856(ra) # 80000546 <panic>

00000000800021f6 <yield>:
{
    800021f6:	1101                	addi	sp,sp,-32
    800021f8:	ec06                	sd	ra,24(sp)
    800021fa:	e822                	sd	s0,16(sp)
    800021fc:	e426                	sd	s1,8(sp)
    800021fe:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002200:	00000097          	auipc	ra,0x0
    80002204:	816080e7          	jalr	-2026(ra) # 80001a16 <myproc>
    80002208:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	a40080e7          	jalr	-1472(ra) # 80000c4a <acquire>
  p->state = RUNNABLE;
    80002212:	4789                	li	a5,2
    80002214:	cc9c                	sw	a5,24(s1)
  sched();
    80002216:	00000097          	auipc	ra,0x0
    8000221a:	e00080e7          	jalr	-512(ra) # 80002016 <sched>
  release(&p->lock);
    8000221e:	8526                	mv	a0,s1
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	ade080e7          	jalr	-1314(ra) # 80000cfe <release>
}
    80002228:	60e2                	ld	ra,24(sp)
    8000222a:	6442                	ld	s0,16(sp)
    8000222c:	64a2                	ld	s1,8(sp)
    8000222e:	6105                	addi	sp,sp,32
    80002230:	8082                	ret

0000000080002232 <sleep>:
{
    80002232:	7179                	addi	sp,sp,-48
    80002234:	f406                	sd	ra,40(sp)
    80002236:	f022                	sd	s0,32(sp)
    80002238:	ec26                	sd	s1,24(sp)
    8000223a:	e84a                	sd	s2,16(sp)
    8000223c:	e44e                	sd	s3,8(sp)
    8000223e:	1800                	addi	s0,sp,48
    80002240:	89aa                	mv	s3,a0
    80002242:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	7d2080e7          	jalr	2002(ra) # 80001a16 <myproc>
    8000224c:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    8000224e:	05250663          	beq	a0,s2,8000229a <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    80002252:	fffff097          	auipc	ra,0xfffff
    80002256:	9f8080e7          	jalr	-1544(ra) # 80000c4a <acquire>
    release(lk);
    8000225a:	854a                	mv	a0,s2
    8000225c:	fffff097          	auipc	ra,0xfffff
    80002260:	aa2080e7          	jalr	-1374(ra) # 80000cfe <release>
  p->chan = chan;
    80002264:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002268:	4785                	li	a5,1
    8000226a:	cc9c                	sw	a5,24(s1)
  sched();
    8000226c:	00000097          	auipc	ra,0x0
    80002270:	daa080e7          	jalr	-598(ra) # 80002016 <sched>
  p->chan = 0;
    80002274:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002278:	8526                	mv	a0,s1
    8000227a:	fffff097          	auipc	ra,0xfffff
    8000227e:	a84080e7          	jalr	-1404(ra) # 80000cfe <release>
    acquire(lk);
    80002282:	854a                	mv	a0,s2
    80002284:	fffff097          	auipc	ra,0xfffff
    80002288:	9c6080e7          	jalr	-1594(ra) # 80000c4a <acquire>
}
    8000228c:	70a2                	ld	ra,40(sp)
    8000228e:	7402                	ld	s0,32(sp)
    80002290:	64e2                	ld	s1,24(sp)
    80002292:	6942                	ld	s2,16(sp)
    80002294:	69a2                	ld	s3,8(sp)
    80002296:	6145                	addi	sp,sp,48
    80002298:	8082                	ret
  p->chan = chan;
    8000229a:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    8000229e:	4785                	li	a5,1
    800022a0:	cd1c                	sw	a5,24(a0)
  sched();
    800022a2:	00000097          	auipc	ra,0x0
    800022a6:	d74080e7          	jalr	-652(ra) # 80002016 <sched>
  p->chan = 0;
    800022aa:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800022ae:	bff9                	j	8000228c <sleep+0x5a>

00000000800022b0 <wait>:
{
    800022b0:	715d                	addi	sp,sp,-80
    800022b2:	e486                	sd	ra,72(sp)
    800022b4:	e0a2                	sd	s0,64(sp)
    800022b6:	fc26                	sd	s1,56(sp)
    800022b8:	f84a                	sd	s2,48(sp)
    800022ba:	f44e                	sd	s3,40(sp)
    800022bc:	f052                	sd	s4,32(sp)
    800022be:	ec56                	sd	s5,24(sp)
    800022c0:	e85a                	sd	s6,16(sp)
    800022c2:	e45e                	sd	s7,8(sp)
    800022c4:	0880                	addi	s0,sp,80
    800022c6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	74e080e7          	jalr	1870(ra) # 80001a16 <myproc>
    800022d0:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022d2:	fffff097          	auipc	ra,0xfffff
    800022d6:	978080e7          	jalr	-1672(ra) # 80000c4a <acquire>
    havekids = 0;
    800022da:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022dc:	4a11                	li	s4,4
        havekids = 1;
    800022de:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800022e0:	00015997          	auipc	s3,0x15
    800022e4:	48898993          	addi	s3,s3,1160 # 80017768 <tickslock>
    havekids = 0;
    800022e8:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022ea:	00010497          	auipc	s1,0x10
    800022ee:	a7e48493          	addi	s1,s1,-1410 # 80011d68 <proc>
    800022f2:	a08d                	j	80002354 <wait+0xa4>
          pid = np->pid;
    800022f4:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022f8:	000b0e63          	beqz	s6,80002314 <wait+0x64>
    800022fc:	4691                	li	a3,4
    800022fe:	03448613          	addi	a2,s1,52
    80002302:	85da                	mv	a1,s6
    80002304:	05093503          	ld	a0,80(s2)
    80002308:	fffff097          	auipc	ra,0xfffff
    8000230c:	404080e7          	jalr	1028(ra) # 8000170c <copyout>
    80002310:	02054263          	bltz	a0,80002334 <wait+0x84>
          freeproc(np);
    80002314:	8526                	mv	a0,s1
    80002316:	00000097          	auipc	ra,0x0
    8000231a:	8b2080e7          	jalr	-1870(ra) # 80001bc8 <freeproc>
          release(&np->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	9de080e7          	jalr	-1570(ra) # 80000cfe <release>
          release(&p->lock);
    80002328:	854a                	mv	a0,s2
    8000232a:	fffff097          	auipc	ra,0xfffff
    8000232e:	9d4080e7          	jalr	-1580(ra) # 80000cfe <release>
          return pid;
    80002332:	a8a9                	j	8000238c <wait+0xdc>
            release(&np->lock);
    80002334:	8526                	mv	a0,s1
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	9c8080e7          	jalr	-1592(ra) # 80000cfe <release>
            release(&p->lock);
    8000233e:	854a                	mv	a0,s2
    80002340:	fffff097          	auipc	ra,0xfffff
    80002344:	9be080e7          	jalr	-1602(ra) # 80000cfe <release>
            return -1;
    80002348:	59fd                	li	s3,-1
    8000234a:	a089                	j	8000238c <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    8000234c:	16848493          	addi	s1,s1,360
    80002350:	03348463          	beq	s1,s3,80002378 <wait+0xc8>
      if(np->parent == p){
    80002354:	709c                	ld	a5,32(s1)
    80002356:	ff279be3          	bne	a5,s2,8000234c <wait+0x9c>
        acquire(&np->lock);
    8000235a:	8526                	mv	a0,s1
    8000235c:	fffff097          	auipc	ra,0xfffff
    80002360:	8ee080e7          	jalr	-1810(ra) # 80000c4a <acquire>
        if(np->state == ZOMBIE){
    80002364:	4c9c                	lw	a5,24(s1)
    80002366:	f94787e3          	beq	a5,s4,800022f4 <wait+0x44>
        release(&np->lock);
    8000236a:	8526                	mv	a0,s1
    8000236c:	fffff097          	auipc	ra,0xfffff
    80002370:	992080e7          	jalr	-1646(ra) # 80000cfe <release>
        havekids = 1;
    80002374:	8756                	mv	a4,s5
    80002376:	bfd9                	j	8000234c <wait+0x9c>
    if(!havekids || p->killed){
    80002378:	c701                	beqz	a4,80002380 <wait+0xd0>
    8000237a:	03092783          	lw	a5,48(s2)
    8000237e:	c39d                	beqz	a5,800023a4 <wait+0xf4>
      release(&p->lock);
    80002380:	854a                	mv	a0,s2
    80002382:	fffff097          	auipc	ra,0xfffff
    80002386:	97c080e7          	jalr	-1668(ra) # 80000cfe <release>
      return -1;
    8000238a:	59fd                	li	s3,-1
}
    8000238c:	854e                	mv	a0,s3
    8000238e:	60a6                	ld	ra,72(sp)
    80002390:	6406                	ld	s0,64(sp)
    80002392:	74e2                	ld	s1,56(sp)
    80002394:	7942                	ld	s2,48(sp)
    80002396:	79a2                	ld	s3,40(sp)
    80002398:	7a02                	ld	s4,32(sp)
    8000239a:	6ae2                	ld	s5,24(sp)
    8000239c:	6b42                	ld	s6,16(sp)
    8000239e:	6ba2                	ld	s7,8(sp)
    800023a0:	6161                	addi	sp,sp,80
    800023a2:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023a4:	85ca                	mv	a1,s2
    800023a6:	854a                	mv	a0,s2
    800023a8:	00000097          	auipc	ra,0x0
    800023ac:	e8a080e7          	jalr	-374(ra) # 80002232 <sleep>
    havekids = 0;
    800023b0:	bf25                	j	800022e8 <wait+0x38>

00000000800023b2 <wakeup>:
{
    800023b2:	7139                	addi	sp,sp,-64
    800023b4:	fc06                	sd	ra,56(sp)
    800023b6:	f822                	sd	s0,48(sp)
    800023b8:	f426                	sd	s1,40(sp)
    800023ba:	f04a                	sd	s2,32(sp)
    800023bc:	ec4e                	sd	s3,24(sp)
    800023be:	e852                	sd	s4,16(sp)
    800023c0:	e456                	sd	s5,8(sp)
    800023c2:	0080                	addi	s0,sp,64
    800023c4:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023c6:	00010497          	auipc	s1,0x10
    800023ca:	9a248493          	addi	s1,s1,-1630 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023ce:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023d0:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023d2:	00015917          	auipc	s2,0x15
    800023d6:	39690913          	addi	s2,s2,918 # 80017768 <tickslock>
    800023da:	a811                	j	800023ee <wakeup+0x3c>
    release(&p->lock);
    800023dc:	8526                	mv	a0,s1
    800023de:	fffff097          	auipc	ra,0xfffff
    800023e2:	920080e7          	jalr	-1760(ra) # 80000cfe <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023e6:	16848493          	addi	s1,s1,360
    800023ea:	03248063          	beq	s1,s2,8000240a <wakeup+0x58>
    acquire(&p->lock);
    800023ee:	8526                	mv	a0,s1
    800023f0:	fffff097          	auipc	ra,0xfffff
    800023f4:	85a080e7          	jalr	-1958(ra) # 80000c4a <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800023f8:	4c9c                	lw	a5,24(s1)
    800023fa:	ff3791e3          	bne	a5,s3,800023dc <wakeup+0x2a>
    800023fe:	749c                	ld	a5,40(s1)
    80002400:	fd479ee3          	bne	a5,s4,800023dc <wakeup+0x2a>
      p->state = RUNNABLE;
    80002404:	0154ac23          	sw	s5,24(s1)
    80002408:	bfd1                	j	800023dc <wakeup+0x2a>
}
    8000240a:	70e2                	ld	ra,56(sp)
    8000240c:	7442                	ld	s0,48(sp)
    8000240e:	74a2                	ld	s1,40(sp)
    80002410:	7902                	ld	s2,32(sp)
    80002412:	69e2                	ld	s3,24(sp)
    80002414:	6a42                	ld	s4,16(sp)
    80002416:	6aa2                	ld	s5,8(sp)
    80002418:	6121                	addi	sp,sp,64
    8000241a:	8082                	ret

000000008000241c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000241c:	7179                	addi	sp,sp,-48
    8000241e:	f406                	sd	ra,40(sp)
    80002420:	f022                	sd	s0,32(sp)
    80002422:	ec26                	sd	s1,24(sp)
    80002424:	e84a                	sd	s2,16(sp)
    80002426:	e44e                	sd	s3,8(sp)
    80002428:	1800                	addi	s0,sp,48
    8000242a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000242c:	00010497          	auipc	s1,0x10
    80002430:	93c48493          	addi	s1,s1,-1732 # 80011d68 <proc>
    80002434:	00015997          	auipc	s3,0x15
    80002438:	33498993          	addi	s3,s3,820 # 80017768 <tickslock>
    acquire(&p->lock);
    8000243c:	8526                	mv	a0,s1
    8000243e:	fffff097          	auipc	ra,0xfffff
    80002442:	80c080e7          	jalr	-2036(ra) # 80000c4a <acquire>
    if(p->pid == pid){
    80002446:	5c9c                	lw	a5,56(s1)
    80002448:	01278d63          	beq	a5,s2,80002462 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000244c:	8526                	mv	a0,s1
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	8b0080e7          	jalr	-1872(ra) # 80000cfe <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002456:	16848493          	addi	s1,s1,360
    8000245a:	ff3491e3          	bne	s1,s3,8000243c <kill+0x20>
  }
  return -1;
    8000245e:	557d                	li	a0,-1
    80002460:	a821                	j	80002478 <kill+0x5c>
      p->killed = 1;
    80002462:	4785                	li	a5,1
    80002464:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002466:	4c98                	lw	a4,24(s1)
    80002468:	00f70f63          	beq	a4,a5,80002486 <kill+0x6a>
      release(&p->lock);
    8000246c:	8526                	mv	a0,s1
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	890080e7          	jalr	-1904(ra) # 80000cfe <release>
      return 0;
    80002476:	4501                	li	a0,0
}
    80002478:	70a2                	ld	ra,40(sp)
    8000247a:	7402                	ld	s0,32(sp)
    8000247c:	64e2                	ld	s1,24(sp)
    8000247e:	6942                	ld	s2,16(sp)
    80002480:	69a2                	ld	s3,8(sp)
    80002482:	6145                	addi	sp,sp,48
    80002484:	8082                	ret
        p->state = RUNNABLE;
    80002486:	4789                	li	a5,2
    80002488:	cc9c                	sw	a5,24(s1)
    8000248a:	b7cd                	j	8000246c <kill+0x50>

000000008000248c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000248c:	7179                	addi	sp,sp,-48
    8000248e:	f406                	sd	ra,40(sp)
    80002490:	f022                	sd	s0,32(sp)
    80002492:	ec26                	sd	s1,24(sp)
    80002494:	e84a                	sd	s2,16(sp)
    80002496:	e44e                	sd	s3,8(sp)
    80002498:	e052                	sd	s4,0(sp)
    8000249a:	1800                	addi	s0,sp,48
    8000249c:	84aa                	mv	s1,a0
    8000249e:	892e                	mv	s2,a1
    800024a0:	89b2                	mv	s3,a2
    800024a2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024a4:	fffff097          	auipc	ra,0xfffff
    800024a8:	572080e7          	jalr	1394(ra) # 80001a16 <myproc>
  if(user_dst){
    800024ac:	c08d                	beqz	s1,800024ce <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024ae:	86d2                	mv	a3,s4
    800024b0:	864e                	mv	a2,s3
    800024b2:	85ca                	mv	a1,s2
    800024b4:	6928                	ld	a0,80(a0)
    800024b6:	fffff097          	auipc	ra,0xfffff
    800024ba:	256080e7          	jalr	598(ra) # 8000170c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024be:	70a2                	ld	ra,40(sp)
    800024c0:	7402                	ld	s0,32(sp)
    800024c2:	64e2                	ld	s1,24(sp)
    800024c4:	6942                	ld	s2,16(sp)
    800024c6:	69a2                	ld	s3,8(sp)
    800024c8:	6a02                	ld	s4,0(sp)
    800024ca:	6145                	addi	sp,sp,48
    800024cc:	8082                	ret
    memmove((char *)dst, src, len);
    800024ce:	000a061b          	sext.w	a2,s4
    800024d2:	85ce                	mv	a1,s3
    800024d4:	854a                	mv	a0,s2
    800024d6:	fffff097          	auipc	ra,0xfffff
    800024da:	8cc080e7          	jalr	-1844(ra) # 80000da2 <memmove>
    return 0;
    800024de:	8526                	mv	a0,s1
    800024e0:	bff9                	j	800024be <either_copyout+0x32>

00000000800024e2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024e2:	7179                	addi	sp,sp,-48
    800024e4:	f406                	sd	ra,40(sp)
    800024e6:	f022                	sd	s0,32(sp)
    800024e8:	ec26                	sd	s1,24(sp)
    800024ea:	e84a                	sd	s2,16(sp)
    800024ec:	e44e                	sd	s3,8(sp)
    800024ee:	e052                	sd	s4,0(sp)
    800024f0:	1800                	addi	s0,sp,48
    800024f2:	892a                	mv	s2,a0
    800024f4:	84ae                	mv	s1,a1
    800024f6:	89b2                	mv	s3,a2
    800024f8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024fa:	fffff097          	auipc	ra,0xfffff
    800024fe:	51c080e7          	jalr	1308(ra) # 80001a16 <myproc>
  if(user_src){
    80002502:	c08d                	beqz	s1,80002524 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002504:	86d2                	mv	a3,s4
    80002506:	864e                	mv	a2,s3
    80002508:	85ca                	mv	a1,s2
    8000250a:	6928                	ld	a0,80(a0)
    8000250c:	fffff097          	auipc	ra,0xfffff
    80002510:	28c080e7          	jalr	652(ra) # 80001798 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002514:	70a2                	ld	ra,40(sp)
    80002516:	7402                	ld	s0,32(sp)
    80002518:	64e2                	ld	s1,24(sp)
    8000251a:	6942                	ld	s2,16(sp)
    8000251c:	69a2                	ld	s3,8(sp)
    8000251e:	6a02                	ld	s4,0(sp)
    80002520:	6145                	addi	sp,sp,48
    80002522:	8082                	ret
    memmove(dst, (char*)src, len);
    80002524:	000a061b          	sext.w	a2,s4
    80002528:	85ce                	mv	a1,s3
    8000252a:	854a                	mv	a0,s2
    8000252c:	fffff097          	auipc	ra,0xfffff
    80002530:	876080e7          	jalr	-1930(ra) # 80000da2 <memmove>
    return 0;
    80002534:	8526                	mv	a0,s1
    80002536:	bff9                	j	80002514 <either_copyin+0x32>

0000000080002538 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002538:	715d                	addi	sp,sp,-80
    8000253a:	e486                	sd	ra,72(sp)
    8000253c:	e0a2                	sd	s0,64(sp)
    8000253e:	fc26                	sd	s1,56(sp)
    80002540:	f84a                	sd	s2,48(sp)
    80002542:	f44e                	sd	s3,40(sp)
    80002544:	f052                	sd	s4,32(sp)
    80002546:	ec56                	sd	s5,24(sp)
    80002548:	e85a                	sd	s6,16(sp)
    8000254a:	e45e                	sd	s7,8(sp)
    8000254c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000254e:	00006517          	auipc	a0,0x6
    80002552:	b7a50513          	addi	a0,a0,-1158 # 800080c8 <digits+0x88>
    80002556:	ffffe097          	auipc	ra,0xffffe
    8000255a:	03a080e7          	jalr	58(ra) # 80000590 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000255e:	00010497          	auipc	s1,0x10
    80002562:	96248493          	addi	s1,s1,-1694 # 80011ec0 <proc+0x158>
    80002566:	00015917          	auipc	s2,0x15
    8000256a:	35a90913          	addi	s2,s2,858 # 800178c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000256e:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80002570:	00006997          	auipc	s3,0x6
    80002574:	cf898993          	addi	s3,s3,-776 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    80002578:	00006a97          	auipc	s5,0x6
    8000257c:	cf8a8a93          	addi	s5,s5,-776 # 80008270 <digits+0x230>
    printf("\n");
    80002580:	00006a17          	auipc	s4,0x6
    80002584:	b48a0a13          	addi	s4,s4,-1208 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002588:	00006b97          	auipc	s7,0x6
    8000258c:	d20b8b93          	addi	s7,s7,-736 # 800082a8 <states.0>
    80002590:	a00d                	j	800025b2 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002592:	ee06a583          	lw	a1,-288(a3)
    80002596:	8556                	mv	a0,s5
    80002598:	ffffe097          	auipc	ra,0xffffe
    8000259c:	ff8080e7          	jalr	-8(ra) # 80000590 <printf>
    printf("\n");
    800025a0:	8552                	mv	a0,s4
    800025a2:	ffffe097          	auipc	ra,0xffffe
    800025a6:	fee080e7          	jalr	-18(ra) # 80000590 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025aa:	16848493          	addi	s1,s1,360
    800025ae:	03248263          	beq	s1,s2,800025d2 <procdump+0x9a>
    if(p->state == UNUSED)
    800025b2:	86a6                	mv	a3,s1
    800025b4:	ec04a783          	lw	a5,-320(s1)
    800025b8:	dbed                	beqz	a5,800025aa <procdump+0x72>
      state = "???";
    800025ba:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025bc:	fcfb6be3          	bltu	s6,a5,80002592 <procdump+0x5a>
    800025c0:	02079713          	slli	a4,a5,0x20
    800025c4:	01d75793          	srli	a5,a4,0x1d
    800025c8:	97de                	add	a5,a5,s7
    800025ca:	6390                	ld	a2,0(a5)
    800025cc:	f279                	bnez	a2,80002592 <procdump+0x5a>
      state = "???";
    800025ce:	864e                	mv	a2,s3
    800025d0:	b7c9                	j	80002592 <procdump+0x5a>
  }
}
    800025d2:	60a6                	ld	ra,72(sp)
    800025d4:	6406                	ld	s0,64(sp)
    800025d6:	74e2                	ld	s1,56(sp)
    800025d8:	7942                	ld	s2,48(sp)
    800025da:	79a2                	ld	s3,40(sp)
    800025dc:	7a02                	ld	s4,32(sp)
    800025de:	6ae2                	ld	s5,24(sp)
    800025e0:	6b42                	ld	s6,16(sp)
    800025e2:	6ba2                	ld	s7,8(sp)
    800025e4:	6161                	addi	sp,sp,80
    800025e6:	8082                	ret

00000000800025e8 <getnproc>:

uint64
getnproc(void)
{
    800025e8:	1141                	addi	sp,sp,-16
    800025ea:	e422                	sd	s0,8(sp)
    800025ec:	0800                	addi	s0,sp,16
  uint64 n = 0;
  struct proc *p;
  for (p = proc; p < &proc[NPROC]; ++p) {
    800025ee:	0000f797          	auipc	a5,0xf
    800025f2:	77a78793          	addi	a5,a5,1914 # 80011d68 <proc>
  uint64 n = 0;
    800025f6:	4501                	li	a0,0
  for (p = proc; p < &proc[NPROC]; ++p) {
    800025f8:	00015697          	auipc	a3,0x15
    800025fc:	17068693          	addi	a3,a3,368 # 80017768 <tickslock>
    if (p->state != UNUSED) ++n;
    80002600:	4f98                	lw	a4,24(a5)
    80002602:	00e03733          	snez	a4,a4
    80002606:	953a                	add	a0,a0,a4
  for (p = proc; p < &proc[NPROC]; ++p) {
    80002608:	16878793          	addi	a5,a5,360
    8000260c:	fed79ae3          	bne	a5,a3,80002600 <getnproc+0x18>
  }
  return n;
}
    80002610:	6422                	ld	s0,8(sp)
    80002612:	0141                	addi	sp,sp,16
    80002614:	8082                	ret

0000000080002616 <swtch>:
    80002616:	00153023          	sd	ra,0(a0)
    8000261a:	00253423          	sd	sp,8(a0)
    8000261e:	e900                	sd	s0,16(a0)
    80002620:	ed04                	sd	s1,24(a0)
    80002622:	03253023          	sd	s2,32(a0)
    80002626:	03353423          	sd	s3,40(a0)
    8000262a:	03453823          	sd	s4,48(a0)
    8000262e:	03553c23          	sd	s5,56(a0)
    80002632:	05653023          	sd	s6,64(a0)
    80002636:	05753423          	sd	s7,72(a0)
    8000263a:	05853823          	sd	s8,80(a0)
    8000263e:	05953c23          	sd	s9,88(a0)
    80002642:	07a53023          	sd	s10,96(a0)
    80002646:	07b53423          	sd	s11,104(a0)
    8000264a:	0005b083          	ld	ra,0(a1)
    8000264e:	0085b103          	ld	sp,8(a1)
    80002652:	6980                	ld	s0,16(a1)
    80002654:	6d84                	ld	s1,24(a1)
    80002656:	0205b903          	ld	s2,32(a1)
    8000265a:	0285b983          	ld	s3,40(a1)
    8000265e:	0305ba03          	ld	s4,48(a1)
    80002662:	0385ba83          	ld	s5,56(a1)
    80002666:	0405bb03          	ld	s6,64(a1)
    8000266a:	0485bb83          	ld	s7,72(a1)
    8000266e:	0505bc03          	ld	s8,80(a1)
    80002672:	0585bc83          	ld	s9,88(a1)
    80002676:	0605bd03          	ld	s10,96(a1)
    8000267a:	0685bd83          	ld	s11,104(a1)
    8000267e:	8082                	ret

0000000080002680 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002680:	1141                	addi	sp,sp,-16
    80002682:	e406                	sd	ra,8(sp)
    80002684:	e022                	sd	s0,0(sp)
    80002686:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002688:	00006597          	auipc	a1,0x6
    8000268c:	c4858593          	addi	a1,a1,-952 # 800082d0 <states.0+0x28>
    80002690:	00015517          	auipc	a0,0x15
    80002694:	0d850513          	addi	a0,a0,216 # 80017768 <tickslock>
    80002698:	ffffe097          	auipc	ra,0xffffe
    8000269c:	522080e7          	jalr	1314(ra) # 80000bba <initlock>
}
    800026a0:	60a2                	ld	ra,8(sp)
    800026a2:	6402                	ld	s0,0(sp)
    800026a4:	0141                	addi	sp,sp,16
    800026a6:	8082                	ret

00000000800026a8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026a8:	1141                	addi	sp,sp,-16
    800026aa:	e422                	sd	s0,8(sp)
    800026ac:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026ae:	00003797          	auipc	a5,0x3
    800026b2:	59278793          	addi	a5,a5,1426 # 80005c40 <kernelvec>
    800026b6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026ba:	6422                	ld	s0,8(sp)
    800026bc:	0141                	addi	sp,sp,16
    800026be:	8082                	ret

00000000800026c0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026c0:	1141                	addi	sp,sp,-16
    800026c2:	e406                	sd	ra,8(sp)
    800026c4:	e022                	sd	s0,0(sp)
    800026c6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026c8:	fffff097          	auipc	ra,0xfffff
    800026cc:	34e080e7          	jalr	846(ra) # 80001a16 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026d0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026d4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026da:	00005697          	auipc	a3,0x5
    800026de:	92668693          	addi	a3,a3,-1754 # 80007000 <_trampoline>
    800026e2:	00005717          	auipc	a4,0x5
    800026e6:	91e70713          	addi	a4,a4,-1762 # 80007000 <_trampoline>
    800026ea:	8f15                	sub	a4,a4,a3
    800026ec:	040007b7          	lui	a5,0x4000
    800026f0:	17fd                	addi	a5,a5,-1
    800026f2:	07b2                	slli	a5,a5,0xc
    800026f4:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026f6:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026fa:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026fc:	18002673          	csrr	a2,satp
    80002700:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002702:	6d30                	ld	a2,88(a0)
    80002704:	6138                	ld	a4,64(a0)
    80002706:	6585                	lui	a1,0x1
    80002708:	972e                	add	a4,a4,a1
    8000270a:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    8000270c:	6d38                	ld	a4,88(a0)
    8000270e:	00000617          	auipc	a2,0x0
    80002712:	13860613          	addi	a2,a2,312 # 80002846 <usertrap>
    80002716:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002718:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000271a:	8612                	mv	a2,tp
    8000271c:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000271e:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002722:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002726:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000272a:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000272e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002730:	6f18                	ld	a4,24(a4)
    80002732:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002736:	692c                	ld	a1,80(a0)
    80002738:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    8000273a:	00005717          	auipc	a4,0x5
    8000273e:	95670713          	addi	a4,a4,-1706 # 80007090 <userret>
    80002742:	8f15                	sub	a4,a4,a3
    80002744:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002746:	577d                	li	a4,-1
    80002748:	177e                	slli	a4,a4,0x3f
    8000274a:	8dd9                	or	a1,a1,a4
    8000274c:	02000537          	lui	a0,0x2000
    80002750:	157d                	addi	a0,a0,-1
    80002752:	0536                	slli	a0,a0,0xd
    80002754:	9782                	jalr	a5
}
    80002756:	60a2                	ld	ra,8(sp)
    80002758:	6402                	ld	s0,0(sp)
    8000275a:	0141                	addi	sp,sp,16
    8000275c:	8082                	ret

000000008000275e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000275e:	1101                	addi	sp,sp,-32
    80002760:	ec06                	sd	ra,24(sp)
    80002762:	e822                	sd	s0,16(sp)
    80002764:	e426                	sd	s1,8(sp)
    80002766:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002768:	00015497          	auipc	s1,0x15
    8000276c:	00048493          	mv	s1,s1
    80002770:	8526                	mv	a0,s1
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	4d8080e7          	jalr	1240(ra) # 80000c4a <acquire>
  ticks++;
    8000277a:	00007517          	auipc	a0,0x7
    8000277e:	8a650513          	addi	a0,a0,-1882 # 80009020 <ticks>
    80002782:	411c                	lw	a5,0(a0)
    80002784:	2785                	addiw	a5,a5,1
    80002786:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002788:	00000097          	auipc	ra,0x0
    8000278c:	c2a080e7          	jalr	-982(ra) # 800023b2 <wakeup>
  release(&tickslock);
    80002790:	8526                	mv	a0,s1
    80002792:	ffffe097          	auipc	ra,0xffffe
    80002796:	56c080e7          	jalr	1388(ra) # 80000cfe <release>
}
    8000279a:	60e2                	ld	ra,24(sp)
    8000279c:	6442                	ld	s0,16(sp)
    8000279e:	64a2                	ld	s1,8(sp)
    800027a0:	6105                	addi	sp,sp,32
    800027a2:	8082                	ret

00000000800027a4 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027a4:	1101                	addi	sp,sp,-32
    800027a6:	ec06                	sd	ra,24(sp)
    800027a8:	e822                	sd	s0,16(sp)
    800027aa:	e426                	sd	s1,8(sp)
    800027ac:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027ae:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027b2:	00074d63          	bltz	a4,800027cc <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027b6:	57fd                	li	a5,-1
    800027b8:	17fe                	slli	a5,a5,0x3f
    800027ba:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027bc:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027be:	06f70363          	beq	a4,a5,80002824 <devintr+0x80>
  }
}
    800027c2:	60e2                	ld	ra,24(sp)
    800027c4:	6442                	ld	s0,16(sp)
    800027c6:	64a2                	ld	s1,8(sp)
    800027c8:	6105                	addi	sp,sp,32
    800027ca:	8082                	ret
     (scause & 0xff) == 9){
    800027cc:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800027d0:	46a5                	li	a3,9
    800027d2:	fed792e3          	bne	a5,a3,800027b6 <devintr+0x12>
    int irq = plic_claim();
    800027d6:	00003097          	auipc	ra,0x3
    800027da:	572080e7          	jalr	1394(ra) # 80005d48 <plic_claim>
    800027de:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027e0:	47a9                	li	a5,10
    800027e2:	02f50763          	beq	a0,a5,80002810 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027e6:	4785                	li	a5,1
    800027e8:	02f50963          	beq	a0,a5,8000281a <devintr+0x76>
    return 1;
    800027ec:	4505                	li	a0,1
    } else if(irq){
    800027ee:	d8f1                	beqz	s1,800027c2 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027f0:	85a6                	mv	a1,s1
    800027f2:	00006517          	auipc	a0,0x6
    800027f6:	ae650513          	addi	a0,a0,-1306 # 800082d8 <states.0+0x30>
    800027fa:	ffffe097          	auipc	ra,0xffffe
    800027fe:	d96080e7          	jalr	-618(ra) # 80000590 <printf>
      plic_complete(irq);
    80002802:	8526                	mv	a0,s1
    80002804:	00003097          	auipc	ra,0x3
    80002808:	568080e7          	jalr	1384(ra) # 80005d6c <plic_complete>
    return 1;
    8000280c:	4505                	li	a0,1
    8000280e:	bf55                	j	800027c2 <devintr+0x1e>
      uartintr();
    80002810:	ffffe097          	auipc	ra,0xffffe
    80002814:	1b2080e7          	jalr	434(ra) # 800009c2 <uartintr>
    80002818:	b7ed                	j	80002802 <devintr+0x5e>
      virtio_disk_intr();
    8000281a:	00004097          	auipc	ra,0x4
    8000281e:	9c6080e7          	jalr	-1594(ra) # 800061e0 <virtio_disk_intr>
    80002822:	b7c5                	j	80002802 <devintr+0x5e>
    if(cpuid() == 0){
    80002824:	fffff097          	auipc	ra,0xfffff
    80002828:	1c6080e7          	jalr	454(ra) # 800019ea <cpuid>
    8000282c:	c901                	beqz	a0,8000283c <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000282e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002832:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002834:	14479073          	csrw	sip,a5
    return 2;
    80002838:	4509                	li	a0,2
    8000283a:	b761                	j	800027c2 <devintr+0x1e>
      clockintr();
    8000283c:	00000097          	auipc	ra,0x0
    80002840:	f22080e7          	jalr	-222(ra) # 8000275e <clockintr>
    80002844:	b7ed                	j	8000282e <devintr+0x8a>

0000000080002846 <usertrap>:
{
    80002846:	1101                	addi	sp,sp,-32
    80002848:	ec06                	sd	ra,24(sp)
    8000284a:	e822                	sd	s0,16(sp)
    8000284c:	e426                	sd	s1,8(sp)
    8000284e:	e04a                	sd	s2,0(sp)
    80002850:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002852:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002856:	1007f793          	andi	a5,a5,256
    8000285a:	e3ad                	bnez	a5,800028bc <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000285c:	00003797          	auipc	a5,0x3
    80002860:	3e478793          	addi	a5,a5,996 # 80005c40 <kernelvec>
    80002864:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002868:	fffff097          	auipc	ra,0xfffff
    8000286c:	1ae080e7          	jalr	430(ra) # 80001a16 <myproc>
    80002870:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002872:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002874:	14102773          	csrr	a4,sepc
    80002878:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000287a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000287e:	47a1                	li	a5,8
    80002880:	04f71c63          	bne	a4,a5,800028d8 <usertrap+0x92>
    if(p->killed)
    80002884:	591c                	lw	a5,48(a0)
    80002886:	e3b9                	bnez	a5,800028cc <usertrap+0x86>
    p->trapframe->epc += 4;
    80002888:	6cb8                	ld	a4,88(s1)
    8000288a:	6f1c                	ld	a5,24(a4)
    8000288c:	0791                	addi	a5,a5,4
    8000288e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002890:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002894:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002898:	10079073          	csrw	sstatus,a5
    syscall();
    8000289c:	00000097          	auipc	ra,0x0
    800028a0:	2e0080e7          	jalr	736(ra) # 80002b7c <syscall>
  if(p->killed)
    800028a4:	589c                	lw	a5,48(s1)
    800028a6:	ebc1                	bnez	a5,80002936 <usertrap+0xf0>
  usertrapret();
    800028a8:	00000097          	auipc	ra,0x0
    800028ac:	e18080e7          	jalr	-488(ra) # 800026c0 <usertrapret>
}
    800028b0:	60e2                	ld	ra,24(sp)
    800028b2:	6442                	ld	s0,16(sp)
    800028b4:	64a2                	ld	s1,8(sp)
    800028b6:	6902                	ld	s2,0(sp)
    800028b8:	6105                	addi	sp,sp,32
    800028ba:	8082                	ret
    panic("usertrap: not from user mode");
    800028bc:	00006517          	auipc	a0,0x6
    800028c0:	a3c50513          	addi	a0,a0,-1476 # 800082f8 <states.0+0x50>
    800028c4:	ffffe097          	auipc	ra,0xffffe
    800028c8:	c82080e7          	jalr	-894(ra) # 80000546 <panic>
      exit(-1);
    800028cc:	557d                	li	a0,-1
    800028ce:	00000097          	auipc	ra,0x0
    800028d2:	81e080e7          	jalr	-2018(ra) # 800020ec <exit>
    800028d6:	bf4d                	j	80002888 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028d8:	00000097          	auipc	ra,0x0
    800028dc:	ecc080e7          	jalr	-308(ra) # 800027a4 <devintr>
    800028e0:	892a                	mv	s2,a0
    800028e2:	c501                	beqz	a0,800028ea <usertrap+0xa4>
  if(p->killed)
    800028e4:	589c                	lw	a5,48(s1)
    800028e6:	c3a1                	beqz	a5,80002926 <usertrap+0xe0>
    800028e8:	a815                	j	8000291c <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028ea:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028ee:	5c90                	lw	a2,56(s1)
    800028f0:	00006517          	auipc	a0,0x6
    800028f4:	a2850513          	addi	a0,a0,-1496 # 80008318 <states.0+0x70>
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	c98080e7          	jalr	-872(ra) # 80000590 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002900:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002904:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002908:	00006517          	auipc	a0,0x6
    8000290c:	a4050513          	addi	a0,a0,-1472 # 80008348 <states.0+0xa0>
    80002910:	ffffe097          	auipc	ra,0xffffe
    80002914:	c80080e7          	jalr	-896(ra) # 80000590 <printf>
    p->killed = 1;
    80002918:	4785                	li	a5,1
    8000291a:	d89c                	sw	a5,48(s1)
    exit(-1);
    8000291c:	557d                	li	a0,-1
    8000291e:	fffff097          	auipc	ra,0xfffff
    80002922:	7ce080e7          	jalr	1998(ra) # 800020ec <exit>
  if(which_dev == 2)
    80002926:	4789                	li	a5,2
    80002928:	f8f910e3          	bne	s2,a5,800028a8 <usertrap+0x62>
    yield();
    8000292c:	00000097          	auipc	ra,0x0
    80002930:	8ca080e7          	jalr	-1846(ra) # 800021f6 <yield>
    80002934:	bf95                	j	800028a8 <usertrap+0x62>
  int which_dev = 0;
    80002936:	4901                	li	s2,0
    80002938:	b7d5                	j	8000291c <usertrap+0xd6>

000000008000293a <kerneltrap>:
{
    8000293a:	7179                	addi	sp,sp,-48
    8000293c:	f406                	sd	ra,40(sp)
    8000293e:	f022                	sd	s0,32(sp)
    80002940:	ec26                	sd	s1,24(sp)
    80002942:	e84a                	sd	s2,16(sp)
    80002944:	e44e                	sd	s3,8(sp)
    80002946:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002948:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000294c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002950:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002954:	1004f793          	andi	a5,s1,256
    80002958:	cb85                	beqz	a5,80002988 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000295a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000295e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002960:	ef85                	bnez	a5,80002998 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002962:	00000097          	auipc	ra,0x0
    80002966:	e42080e7          	jalr	-446(ra) # 800027a4 <devintr>
    8000296a:	cd1d                	beqz	a0,800029a8 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    8000296c:	4789                	li	a5,2
    8000296e:	06f50a63          	beq	a0,a5,800029e2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002972:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002976:	10049073          	csrw	sstatus,s1
}
    8000297a:	70a2                	ld	ra,40(sp)
    8000297c:	7402                	ld	s0,32(sp)
    8000297e:	64e2                	ld	s1,24(sp)
    80002980:	6942                	ld	s2,16(sp)
    80002982:	69a2                	ld	s3,8(sp)
    80002984:	6145                	addi	sp,sp,48
    80002986:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002988:	00006517          	auipc	a0,0x6
    8000298c:	9e050513          	addi	a0,a0,-1568 # 80008368 <states.0+0xc0>
    80002990:	ffffe097          	auipc	ra,0xffffe
    80002994:	bb6080e7          	jalr	-1098(ra) # 80000546 <panic>
    panic("kerneltrap: interrupts enabled");
    80002998:	00006517          	auipc	a0,0x6
    8000299c:	9f850513          	addi	a0,a0,-1544 # 80008390 <states.0+0xe8>
    800029a0:	ffffe097          	auipc	ra,0xffffe
    800029a4:	ba6080e7          	jalr	-1114(ra) # 80000546 <panic>
    printf("scause %p\n", scause);
    800029a8:	85ce                	mv	a1,s3
    800029aa:	00006517          	auipc	a0,0x6
    800029ae:	a0650513          	addi	a0,a0,-1530 # 800083b0 <states.0+0x108>
    800029b2:	ffffe097          	auipc	ra,0xffffe
    800029b6:	bde080e7          	jalr	-1058(ra) # 80000590 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ba:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029be:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029c2:	00006517          	auipc	a0,0x6
    800029c6:	9fe50513          	addi	a0,a0,-1538 # 800083c0 <states.0+0x118>
    800029ca:	ffffe097          	auipc	ra,0xffffe
    800029ce:	bc6080e7          	jalr	-1082(ra) # 80000590 <printf>
    panic("kerneltrap");
    800029d2:	00006517          	auipc	a0,0x6
    800029d6:	a0650513          	addi	a0,a0,-1530 # 800083d8 <states.0+0x130>
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	b6c080e7          	jalr	-1172(ra) # 80000546 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029e2:	fffff097          	auipc	ra,0xfffff
    800029e6:	034080e7          	jalr	52(ra) # 80001a16 <myproc>
    800029ea:	d541                	beqz	a0,80002972 <kerneltrap+0x38>
    800029ec:	fffff097          	auipc	ra,0xfffff
    800029f0:	02a080e7          	jalr	42(ra) # 80001a16 <myproc>
    800029f4:	4d18                	lw	a4,24(a0)
    800029f6:	478d                	li	a5,3
    800029f8:	f6f71de3          	bne	a4,a5,80002972 <kerneltrap+0x38>
    yield();
    800029fc:	fffff097          	auipc	ra,0xfffff
    80002a00:	7fa080e7          	jalr	2042(ra) # 800021f6 <yield>
    80002a04:	b7bd                	j	80002972 <kerneltrap+0x38>

0000000080002a06 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a06:	1101                	addi	sp,sp,-32
    80002a08:	ec06                	sd	ra,24(sp)
    80002a0a:	e822                	sd	s0,16(sp)
    80002a0c:	e426                	sd	s1,8(sp)
    80002a0e:	1000                	addi	s0,sp,32
    80002a10:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a12:	fffff097          	auipc	ra,0xfffff
    80002a16:	004080e7          	jalr	4(ra) # 80001a16 <myproc>
  switch (n) {
    80002a1a:	4795                	li	a5,5
    80002a1c:	0497e163          	bltu	a5,s1,80002a5e <argraw+0x58>
    80002a20:	048a                	slli	s1,s1,0x2
    80002a22:	00006717          	auipc	a4,0x6
    80002a26:	ab670713          	addi	a4,a4,-1354 # 800084d8 <states.0+0x230>
    80002a2a:	94ba                	add	s1,s1,a4
    80002a2c:	409c                	lw	a5,0(s1)
    80002a2e:	97ba                	add	a5,a5,a4
    80002a30:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a32:	6d3c                	ld	a5,88(a0)
    80002a34:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a36:	60e2                	ld	ra,24(sp)
    80002a38:	6442                	ld	s0,16(sp)
    80002a3a:	64a2                	ld	s1,8(sp)
    80002a3c:	6105                	addi	sp,sp,32
    80002a3e:	8082                	ret
    return p->trapframe->a1;
    80002a40:	6d3c                	ld	a5,88(a0)
    80002a42:	7fa8                	ld	a0,120(a5)
    80002a44:	bfcd                	j	80002a36 <argraw+0x30>
    return p->trapframe->a2;
    80002a46:	6d3c                	ld	a5,88(a0)
    80002a48:	63c8                	ld	a0,128(a5)
    80002a4a:	b7f5                	j	80002a36 <argraw+0x30>
    return p->trapframe->a3;
    80002a4c:	6d3c                	ld	a5,88(a0)
    80002a4e:	67c8                	ld	a0,136(a5)
    80002a50:	b7dd                	j	80002a36 <argraw+0x30>
    return p->trapframe->a4;
    80002a52:	6d3c                	ld	a5,88(a0)
    80002a54:	6bc8                	ld	a0,144(a5)
    80002a56:	b7c5                	j	80002a36 <argraw+0x30>
    return p->trapframe->a5;
    80002a58:	6d3c                	ld	a5,88(a0)
    80002a5a:	6fc8                	ld	a0,152(a5)
    80002a5c:	bfe9                	j	80002a36 <argraw+0x30>
  panic("argraw");
    80002a5e:	00006517          	auipc	a0,0x6
    80002a62:	98a50513          	addi	a0,a0,-1654 # 800083e8 <states.0+0x140>
    80002a66:	ffffe097          	auipc	ra,0xffffe
    80002a6a:	ae0080e7          	jalr	-1312(ra) # 80000546 <panic>

0000000080002a6e <fetchaddr>:
{
    80002a6e:	1101                	addi	sp,sp,-32
    80002a70:	ec06                	sd	ra,24(sp)
    80002a72:	e822                	sd	s0,16(sp)
    80002a74:	e426                	sd	s1,8(sp)
    80002a76:	e04a                	sd	s2,0(sp)
    80002a78:	1000                	addi	s0,sp,32
    80002a7a:	84aa                	mv	s1,a0
    80002a7c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a7e:	fffff097          	auipc	ra,0xfffff
    80002a82:	f98080e7          	jalr	-104(ra) # 80001a16 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a86:	653c                	ld	a5,72(a0)
    80002a88:	02f4f863          	bgeu	s1,a5,80002ab8 <fetchaddr+0x4a>
    80002a8c:	00848713          	addi	a4,s1,8 # 80017770 <tickslock+0x8>
    80002a90:	02e7e663          	bltu	a5,a4,80002abc <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a94:	46a1                	li	a3,8
    80002a96:	8626                	mv	a2,s1
    80002a98:	85ca                	mv	a1,s2
    80002a9a:	6928                	ld	a0,80(a0)
    80002a9c:	fffff097          	auipc	ra,0xfffff
    80002aa0:	cfc080e7          	jalr	-772(ra) # 80001798 <copyin>
    80002aa4:	00a03533          	snez	a0,a0
    80002aa8:	40a00533          	neg	a0,a0
}
    80002aac:	60e2                	ld	ra,24(sp)
    80002aae:	6442                	ld	s0,16(sp)
    80002ab0:	64a2                	ld	s1,8(sp)
    80002ab2:	6902                	ld	s2,0(sp)
    80002ab4:	6105                	addi	sp,sp,32
    80002ab6:	8082                	ret
    return -1;
    80002ab8:	557d                	li	a0,-1
    80002aba:	bfcd                	j	80002aac <fetchaddr+0x3e>
    80002abc:	557d                	li	a0,-1
    80002abe:	b7fd                	j	80002aac <fetchaddr+0x3e>

0000000080002ac0 <fetchstr>:
{
    80002ac0:	7179                	addi	sp,sp,-48
    80002ac2:	f406                	sd	ra,40(sp)
    80002ac4:	f022                	sd	s0,32(sp)
    80002ac6:	ec26                	sd	s1,24(sp)
    80002ac8:	e84a                	sd	s2,16(sp)
    80002aca:	e44e                	sd	s3,8(sp)
    80002acc:	1800                	addi	s0,sp,48
    80002ace:	892a                	mv	s2,a0
    80002ad0:	84ae                	mv	s1,a1
    80002ad2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ad4:	fffff097          	auipc	ra,0xfffff
    80002ad8:	f42080e7          	jalr	-190(ra) # 80001a16 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002adc:	86ce                	mv	a3,s3
    80002ade:	864a                	mv	a2,s2
    80002ae0:	85a6                	mv	a1,s1
    80002ae2:	6928                	ld	a0,80(a0)
    80002ae4:	fffff097          	auipc	ra,0xfffff
    80002ae8:	d42080e7          	jalr	-702(ra) # 80001826 <copyinstr>
  if(err < 0)
    80002aec:	00054763          	bltz	a0,80002afa <fetchstr+0x3a>
  return strlen(buf);
    80002af0:	8526                	mv	a0,s1
    80002af2:	ffffe097          	auipc	ra,0xffffe
    80002af6:	3d8080e7          	jalr	984(ra) # 80000eca <strlen>
}
    80002afa:	70a2                	ld	ra,40(sp)
    80002afc:	7402                	ld	s0,32(sp)
    80002afe:	64e2                	ld	s1,24(sp)
    80002b00:	6942                	ld	s2,16(sp)
    80002b02:	69a2                	ld	s3,8(sp)
    80002b04:	6145                	addi	sp,sp,48
    80002b06:	8082                	ret

0000000080002b08 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b08:	1101                	addi	sp,sp,-32
    80002b0a:	ec06                	sd	ra,24(sp)
    80002b0c:	e822                	sd	s0,16(sp)
    80002b0e:	e426                	sd	s1,8(sp)
    80002b10:	1000                	addi	s0,sp,32
    80002b12:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b14:	00000097          	auipc	ra,0x0
    80002b18:	ef2080e7          	jalr	-270(ra) # 80002a06 <argraw>
    80002b1c:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b1e:	4501                	li	a0,0
    80002b20:	60e2                	ld	ra,24(sp)
    80002b22:	6442                	ld	s0,16(sp)
    80002b24:	64a2                	ld	s1,8(sp)
    80002b26:	6105                	addi	sp,sp,32
    80002b28:	8082                	ret

0000000080002b2a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b2a:	1101                	addi	sp,sp,-32
    80002b2c:	ec06                	sd	ra,24(sp)
    80002b2e:	e822                	sd	s0,16(sp)
    80002b30:	e426                	sd	s1,8(sp)
    80002b32:	1000                	addi	s0,sp,32
    80002b34:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b36:	00000097          	auipc	ra,0x0
    80002b3a:	ed0080e7          	jalr	-304(ra) # 80002a06 <argraw>
    80002b3e:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b40:	4501                	li	a0,0
    80002b42:	60e2                	ld	ra,24(sp)
    80002b44:	6442                	ld	s0,16(sp)
    80002b46:	64a2                	ld	s1,8(sp)
    80002b48:	6105                	addi	sp,sp,32
    80002b4a:	8082                	ret

0000000080002b4c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b4c:	1101                	addi	sp,sp,-32
    80002b4e:	ec06                	sd	ra,24(sp)
    80002b50:	e822                	sd	s0,16(sp)
    80002b52:	e426                	sd	s1,8(sp)
    80002b54:	e04a                	sd	s2,0(sp)
    80002b56:	1000                	addi	s0,sp,32
    80002b58:	84ae                	mv	s1,a1
    80002b5a:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b5c:	00000097          	auipc	ra,0x0
    80002b60:	eaa080e7          	jalr	-342(ra) # 80002a06 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b64:	864a                	mv	a2,s2
    80002b66:	85a6                	mv	a1,s1
    80002b68:	00000097          	auipc	ra,0x0
    80002b6c:	f58080e7          	jalr	-168(ra) # 80002ac0 <fetchstr>
}
    80002b70:	60e2                	ld	ra,24(sp)
    80002b72:	6442                	ld	s0,16(sp)
    80002b74:	64a2                	ld	s1,8(sp)
    80002b76:	6902                	ld	s2,0(sp)
    80002b78:	6105                	addi	sp,sp,32
    80002b7a:	8082                	ret

0000000080002b7c <syscall>:
  "write", "mknod", "unlink", "link",   "mkdir", "close", "trace"
};

void
syscall(void)
{
    80002b7c:	7179                	addi	sp,sp,-48
    80002b7e:	f406                	sd	ra,40(sp)
    80002b80:	f022                	sd	s0,32(sp)
    80002b82:	ec26                	sd	s1,24(sp)
    80002b84:	e84a                	sd	s2,16(sp)
    80002b86:	e44e                	sd	s3,8(sp)
    80002b88:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80002b8a:	fffff097          	auipc	ra,0xfffff
    80002b8e:	e8c080e7          	jalr	-372(ra) # 80001a16 <myproc>
    80002b92:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b94:	05853903          	ld	s2,88(a0)
    80002b98:	0a893783          	ld	a5,168(s2)
    80002b9c:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ba0:	37fd                	addiw	a5,a5,-1
    80002ba2:	4759                	li	a4,22
    80002ba4:	04f76663          	bltu	a4,a5,80002bf0 <syscall+0x74>
    80002ba8:	00399713          	slli	a4,s3,0x3
    80002bac:	00006797          	auipc	a5,0x6
    80002bb0:	94478793          	addi	a5,a5,-1724 # 800084f0 <syscalls>
    80002bb4:	97ba                	add	a5,a5,a4
    80002bb6:	639c                	ld	a5,0(a5)
    80002bb8:	cf85                	beqz	a5,80002bf0 <syscall+0x74>
    p->trapframe->a0 = syscalls[num]();
    80002bba:	9782                	jalr	a5
    80002bbc:	06a93823          	sd	a0,112(s2)
    if(p->mask & 1<<num){
    80002bc0:	5cdc                	lw	a5,60(s1)
    80002bc2:	4137d7bb          	sraw	a5,a5,s3
    80002bc6:	8b85                	andi	a5,a5,1
    80002bc8:	c3b9                	beqz	a5,80002c0e <syscall+0x92>
      printf("%d: syscall %s -> %d \n", p->pid, syscall_list[num], p->trapframe->a0);
    80002bca:	6cb8                	ld	a4,88(s1)
    80002bcc:	098e                	slli	s3,s3,0x3
    80002bce:	00006797          	auipc	a5,0x6
    80002bd2:	92278793          	addi	a5,a5,-1758 # 800084f0 <syscalls>
    80002bd6:	97ce                	add	a5,a5,s3
    80002bd8:	7b34                	ld	a3,112(a4)
    80002bda:	63f0                	ld	a2,192(a5)
    80002bdc:	5c8c                	lw	a1,56(s1)
    80002bde:	00006517          	auipc	a0,0x6
    80002be2:	81250513          	addi	a0,a0,-2030 # 800083f0 <states.0+0x148>
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	9aa080e7          	jalr	-1622(ra) # 80000590 <printf>
    80002bee:	a005                	j	80002c0e <syscall+0x92>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bf0:	86ce                	mv	a3,s3
    80002bf2:	15848613          	addi	a2,s1,344
    80002bf6:	5c8c                	lw	a1,56(s1)
    80002bf8:	00006517          	auipc	a0,0x6
    80002bfc:	81050513          	addi	a0,a0,-2032 # 80008408 <states.0+0x160>
    80002c00:	ffffe097          	auipc	ra,0xffffe
    80002c04:	990080e7          	jalr	-1648(ra) # 80000590 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c08:	6cbc                	ld	a5,88(s1)
    80002c0a:	577d                	li	a4,-1
    80002c0c:	fbb8                	sd	a4,112(a5)
  }
}
    80002c0e:	70a2                	ld	ra,40(sp)
    80002c10:	7402                	ld	s0,32(sp)
    80002c12:	64e2                	ld	s1,24(sp)
    80002c14:	6942                	ld	s2,16(sp)
    80002c16:	69a2                	ld	s3,8(sp)
    80002c18:	6145                	addi	sp,sp,48
    80002c1a:	8082                	ret

0000000080002c1c <sys_trace>:
#include "spinlock.h"
#include "proc.h"
#include "sysinfo.h"

uint64
sys_trace(void){
    80002c1c:	1101                	addi	sp,sp,-32
    80002c1e:	ec06                	sd	ra,24(sp)
    80002c20:	e822                	sd	s0,16(sp)
    80002c22:	1000                	addi	s0,sp,32
  int num;
  if(argint(0, &num) < 0){
    80002c24:	fec40593          	addi	a1,s0,-20
    80002c28:	4501                	li	a0,0
    80002c2a:	00000097          	auipc	ra,0x0
    80002c2e:	ede080e7          	jalr	-290(ra) # 80002b08 <argint>
    return -1;
    80002c32:	57fd                	li	a5,-1
  if(argint(0, &num) < 0){
    80002c34:	00054a63          	bltz	a0,80002c48 <sys_trace+0x2c>
  }
  myproc()->mask = num;
    80002c38:	fffff097          	auipc	ra,0xfffff
    80002c3c:	dde080e7          	jalr	-546(ra) # 80001a16 <myproc>
    80002c40:	fec42783          	lw	a5,-20(s0)
    80002c44:	dd5c                	sw	a5,60(a0)
  return 0;
    80002c46:	4781                	li	a5,0
}
    80002c48:	853e                	mv	a0,a5
    80002c4a:	60e2                	ld	ra,24(sp)
    80002c4c:	6442                	ld	s0,16(sp)
    80002c4e:	6105                	addi	sp,sp,32
    80002c50:	8082                	ret

0000000080002c52 <sys_sysinfo>:

uint64
sys_sysinfo(void){
    80002c52:	7139                	addi	sp,sp,-64
    80002c54:	fc06                	sd	ra,56(sp)
    80002c56:	f822                	sd	s0,48(sp)
    80002c58:	f426                	sd	s1,40(sp)
    80002c5a:	0080                	addi	s0,sp,64
  uint64 addr; // user virtual address, pointing to a struct sysinfo.

  if (argaddr(0, &addr) < 0)
    80002c5c:	fd840593          	addi	a1,s0,-40
    80002c60:	4501                	li	a0,0
    80002c62:	00000097          	auipc	ra,0x0
    80002c66:	ec8080e7          	jalr	-312(ra) # 80002b2a <argaddr>
    80002c6a:	87aa                	mv	a5,a0
    return -1;
    80002c6c:	557d                	li	a0,-1
  if (argaddr(0, &addr) < 0)
    80002c6e:	0207ce63          	bltz	a5,80002caa <sys_sysinfo+0x58>

  struct proc *p = myproc();
    80002c72:	fffff097          	auipc	ra,0xfffff
    80002c76:	da4080e7          	jalr	-604(ra) # 80001a16 <myproc>
    80002c7a:	84aa                	mv	s1,a0
  struct sysinfo si;

  si.freemem = getfreemem();
    80002c7c:	ffffe097          	auipc	ra,0xffffe
    80002c80:	ef4080e7          	jalr	-268(ra) # 80000b70 <getfreemem>
    80002c84:	fca43423          	sd	a0,-56(s0)
  si.nproc = getnproc();
    80002c88:	00000097          	auipc	ra,0x0
    80002c8c:	960080e7          	jalr	-1696(ra) # 800025e8 <getnproc>
    80002c90:	fca43823          	sd	a0,-48(s0)

  if (copyout(p->pagetable, addr, (char *)&si, sizeof(si)) < 0)
    80002c94:	46c1                	li	a3,16
    80002c96:	fc840613          	addi	a2,s0,-56
    80002c9a:	fd843583          	ld	a1,-40(s0)
    80002c9e:	68a8                	ld	a0,80(s1)
    80002ca0:	fffff097          	auipc	ra,0xfffff
    80002ca4:	a6c080e7          	jalr	-1428(ra) # 8000170c <copyout>
    80002ca8:	957d                	srai	a0,a0,0x3f
    return -1;

  return 0;
}
    80002caa:	70e2                	ld	ra,56(sp)
    80002cac:	7442                	ld	s0,48(sp)
    80002cae:	74a2                	ld	s1,40(sp)
    80002cb0:	6121                	addi	sp,sp,64
    80002cb2:	8082                	ret

0000000080002cb4 <sys_exit>:

uint64
sys_exit(void)
{
    80002cb4:	1101                	addi	sp,sp,-32
    80002cb6:	ec06                	sd	ra,24(sp)
    80002cb8:	e822                	sd	s0,16(sp)
    80002cba:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002cbc:	fec40593          	addi	a1,s0,-20
    80002cc0:	4501                	li	a0,0
    80002cc2:	00000097          	auipc	ra,0x0
    80002cc6:	e46080e7          	jalr	-442(ra) # 80002b08 <argint>
    return -1;
    80002cca:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002ccc:	00054963          	bltz	a0,80002cde <sys_exit+0x2a>
  exit(n);
    80002cd0:	fec42503          	lw	a0,-20(s0)
    80002cd4:	fffff097          	auipc	ra,0xfffff
    80002cd8:	418080e7          	jalr	1048(ra) # 800020ec <exit>
  return 0;  // not reached
    80002cdc:	4781                	li	a5,0
}
    80002cde:	853e                	mv	a0,a5
    80002ce0:	60e2                	ld	ra,24(sp)
    80002ce2:	6442                	ld	s0,16(sp)
    80002ce4:	6105                	addi	sp,sp,32
    80002ce6:	8082                	ret

0000000080002ce8 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ce8:	1141                	addi	sp,sp,-16
    80002cea:	e406                	sd	ra,8(sp)
    80002cec:	e022                	sd	s0,0(sp)
    80002cee:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002cf0:	fffff097          	auipc	ra,0xfffff
    80002cf4:	d26080e7          	jalr	-730(ra) # 80001a16 <myproc>
}
    80002cf8:	5d08                	lw	a0,56(a0)
    80002cfa:	60a2                	ld	ra,8(sp)
    80002cfc:	6402                	ld	s0,0(sp)
    80002cfe:	0141                	addi	sp,sp,16
    80002d00:	8082                	ret

0000000080002d02 <sys_fork>:

uint64
sys_fork(void)
{
    80002d02:	1141                	addi	sp,sp,-16
    80002d04:	e406                	sd	ra,8(sp)
    80002d06:	e022                	sd	s0,0(sp)
    80002d08:	0800                	addi	s0,sp,16
  return fork();
    80002d0a:	fffff097          	auipc	ra,0xfffff
    80002d0e:	0d0080e7          	jalr	208(ra) # 80001dda <fork>
}
    80002d12:	60a2                	ld	ra,8(sp)
    80002d14:	6402                	ld	s0,0(sp)
    80002d16:	0141                	addi	sp,sp,16
    80002d18:	8082                	ret

0000000080002d1a <sys_wait>:

uint64
sys_wait(void)
{
    80002d1a:	1101                	addi	sp,sp,-32
    80002d1c:	ec06                	sd	ra,24(sp)
    80002d1e:	e822                	sd	s0,16(sp)
    80002d20:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d22:	fe840593          	addi	a1,s0,-24
    80002d26:	4501                	li	a0,0
    80002d28:	00000097          	auipc	ra,0x0
    80002d2c:	e02080e7          	jalr	-510(ra) # 80002b2a <argaddr>
    80002d30:	87aa                	mv	a5,a0
    return -1;
    80002d32:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d34:	0007c863          	bltz	a5,80002d44 <sys_wait+0x2a>
  return wait(p);
    80002d38:	fe843503          	ld	a0,-24(s0)
    80002d3c:	fffff097          	auipc	ra,0xfffff
    80002d40:	574080e7          	jalr	1396(ra) # 800022b0 <wait>
}
    80002d44:	60e2                	ld	ra,24(sp)
    80002d46:	6442                	ld	s0,16(sp)
    80002d48:	6105                	addi	sp,sp,32
    80002d4a:	8082                	ret

0000000080002d4c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d4c:	7179                	addi	sp,sp,-48
    80002d4e:	f406                	sd	ra,40(sp)
    80002d50:	f022                	sd	s0,32(sp)
    80002d52:	ec26                	sd	s1,24(sp)
    80002d54:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d56:	fdc40593          	addi	a1,s0,-36
    80002d5a:	4501                	li	a0,0
    80002d5c:	00000097          	auipc	ra,0x0
    80002d60:	dac080e7          	jalr	-596(ra) # 80002b08 <argint>
    80002d64:	87aa                	mv	a5,a0
    return -1;
    80002d66:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002d68:	0207c063          	bltz	a5,80002d88 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002d6c:	fffff097          	auipc	ra,0xfffff
    80002d70:	caa080e7          	jalr	-854(ra) # 80001a16 <myproc>
    80002d74:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002d76:	fdc42503          	lw	a0,-36(s0)
    80002d7a:	fffff097          	auipc	ra,0xfffff
    80002d7e:	fe8080e7          	jalr	-24(ra) # 80001d62 <growproc>
    80002d82:	00054863          	bltz	a0,80002d92 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002d86:	8526                	mv	a0,s1
}
    80002d88:	70a2                	ld	ra,40(sp)
    80002d8a:	7402                	ld	s0,32(sp)
    80002d8c:	64e2                	ld	s1,24(sp)
    80002d8e:	6145                	addi	sp,sp,48
    80002d90:	8082                	ret
    return -1;
    80002d92:	557d                	li	a0,-1
    80002d94:	bfd5                	j	80002d88 <sys_sbrk+0x3c>

0000000080002d96 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d96:	7139                	addi	sp,sp,-64
    80002d98:	fc06                	sd	ra,56(sp)
    80002d9a:	f822                	sd	s0,48(sp)
    80002d9c:	f426                	sd	s1,40(sp)
    80002d9e:	f04a                	sd	s2,32(sp)
    80002da0:	ec4e                	sd	s3,24(sp)
    80002da2:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002da4:	fcc40593          	addi	a1,s0,-52
    80002da8:	4501                	li	a0,0
    80002daa:	00000097          	auipc	ra,0x0
    80002dae:	d5e080e7          	jalr	-674(ra) # 80002b08 <argint>
    return -1;
    80002db2:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002db4:	06054563          	bltz	a0,80002e1e <sys_sleep+0x88>
  acquire(&tickslock);
    80002db8:	00015517          	auipc	a0,0x15
    80002dbc:	9b050513          	addi	a0,a0,-1616 # 80017768 <tickslock>
    80002dc0:	ffffe097          	auipc	ra,0xffffe
    80002dc4:	e8a080e7          	jalr	-374(ra) # 80000c4a <acquire>
  ticks0 = ticks;
    80002dc8:	00006917          	auipc	s2,0x6
    80002dcc:	25892903          	lw	s2,600(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002dd0:	fcc42783          	lw	a5,-52(s0)
    80002dd4:	cf85                	beqz	a5,80002e0c <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dd6:	00015997          	auipc	s3,0x15
    80002dda:	99298993          	addi	s3,s3,-1646 # 80017768 <tickslock>
    80002dde:	00006497          	auipc	s1,0x6
    80002de2:	24248493          	addi	s1,s1,578 # 80009020 <ticks>
    if(myproc()->killed){
    80002de6:	fffff097          	auipc	ra,0xfffff
    80002dea:	c30080e7          	jalr	-976(ra) # 80001a16 <myproc>
    80002dee:	591c                	lw	a5,48(a0)
    80002df0:	ef9d                	bnez	a5,80002e2e <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002df2:	85ce                	mv	a1,s3
    80002df4:	8526                	mv	a0,s1
    80002df6:	fffff097          	auipc	ra,0xfffff
    80002dfa:	43c080e7          	jalr	1084(ra) # 80002232 <sleep>
  while(ticks - ticks0 < n){
    80002dfe:	409c                	lw	a5,0(s1)
    80002e00:	412787bb          	subw	a5,a5,s2
    80002e04:	fcc42703          	lw	a4,-52(s0)
    80002e08:	fce7efe3          	bltu	a5,a4,80002de6 <sys_sleep+0x50>
  }
  release(&tickslock);
    80002e0c:	00015517          	auipc	a0,0x15
    80002e10:	95c50513          	addi	a0,a0,-1700 # 80017768 <tickslock>
    80002e14:	ffffe097          	auipc	ra,0xffffe
    80002e18:	eea080e7          	jalr	-278(ra) # 80000cfe <release>
  return 0;
    80002e1c:	4781                	li	a5,0
}
    80002e1e:	853e                	mv	a0,a5
    80002e20:	70e2                	ld	ra,56(sp)
    80002e22:	7442                	ld	s0,48(sp)
    80002e24:	74a2                	ld	s1,40(sp)
    80002e26:	7902                	ld	s2,32(sp)
    80002e28:	69e2                	ld	s3,24(sp)
    80002e2a:	6121                	addi	sp,sp,64
    80002e2c:	8082                	ret
      release(&tickslock);
    80002e2e:	00015517          	auipc	a0,0x15
    80002e32:	93a50513          	addi	a0,a0,-1734 # 80017768 <tickslock>
    80002e36:	ffffe097          	auipc	ra,0xffffe
    80002e3a:	ec8080e7          	jalr	-312(ra) # 80000cfe <release>
      return -1;
    80002e3e:	57fd                	li	a5,-1
    80002e40:	bff9                	j	80002e1e <sys_sleep+0x88>

0000000080002e42 <sys_kill>:

uint64
sys_kill(void)
{
    80002e42:	1101                	addi	sp,sp,-32
    80002e44:	ec06                	sd	ra,24(sp)
    80002e46:	e822                	sd	s0,16(sp)
    80002e48:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e4a:	fec40593          	addi	a1,s0,-20
    80002e4e:	4501                	li	a0,0
    80002e50:	00000097          	auipc	ra,0x0
    80002e54:	cb8080e7          	jalr	-840(ra) # 80002b08 <argint>
    80002e58:	87aa                	mv	a5,a0
    return -1;
    80002e5a:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002e5c:	0007c863          	bltz	a5,80002e6c <sys_kill+0x2a>
  return kill(pid);
    80002e60:	fec42503          	lw	a0,-20(s0)
    80002e64:	fffff097          	auipc	ra,0xfffff
    80002e68:	5b8080e7          	jalr	1464(ra) # 8000241c <kill>
}
    80002e6c:	60e2                	ld	ra,24(sp)
    80002e6e:	6442                	ld	s0,16(sp)
    80002e70:	6105                	addi	sp,sp,32
    80002e72:	8082                	ret

0000000080002e74 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e74:	1101                	addi	sp,sp,-32
    80002e76:	ec06                	sd	ra,24(sp)
    80002e78:	e822                	sd	s0,16(sp)
    80002e7a:	e426                	sd	s1,8(sp)
    80002e7c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e7e:	00015517          	auipc	a0,0x15
    80002e82:	8ea50513          	addi	a0,a0,-1814 # 80017768 <tickslock>
    80002e86:	ffffe097          	auipc	ra,0xffffe
    80002e8a:	dc4080e7          	jalr	-572(ra) # 80000c4a <acquire>
  xticks = ticks;
    80002e8e:	00006497          	auipc	s1,0x6
    80002e92:	1924a483          	lw	s1,402(s1) # 80009020 <ticks>
  release(&tickslock);
    80002e96:	00015517          	auipc	a0,0x15
    80002e9a:	8d250513          	addi	a0,a0,-1838 # 80017768 <tickslock>
    80002e9e:	ffffe097          	auipc	ra,0xffffe
    80002ea2:	e60080e7          	jalr	-416(ra) # 80000cfe <release>
  return xticks;
}
    80002ea6:	02049513          	slli	a0,s1,0x20
    80002eaa:	9101                	srli	a0,a0,0x20
    80002eac:	60e2                	ld	ra,24(sp)
    80002eae:	6442                	ld	s0,16(sp)
    80002eb0:	64a2                	ld	s1,8(sp)
    80002eb2:	6105                	addi	sp,sp,32
    80002eb4:	8082                	ret

0000000080002eb6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002eb6:	7179                	addi	sp,sp,-48
    80002eb8:	f406                	sd	ra,40(sp)
    80002eba:	f022                	sd	s0,32(sp)
    80002ebc:	ec26                	sd	s1,24(sp)
    80002ebe:	e84a                	sd	s2,16(sp)
    80002ec0:	e44e                	sd	s3,8(sp)
    80002ec2:	e052                	sd	s4,0(sp)
    80002ec4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ec6:	00005597          	auipc	a1,0x5
    80002eca:	7a258593          	addi	a1,a1,1954 # 80008668 <syscall_list+0xb8>
    80002ece:	00015517          	auipc	a0,0x15
    80002ed2:	8b250513          	addi	a0,a0,-1870 # 80017780 <bcache>
    80002ed6:	ffffe097          	auipc	ra,0xffffe
    80002eda:	ce4080e7          	jalr	-796(ra) # 80000bba <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ede:	0001d797          	auipc	a5,0x1d
    80002ee2:	8a278793          	addi	a5,a5,-1886 # 8001f780 <bcache+0x8000>
    80002ee6:	0001d717          	auipc	a4,0x1d
    80002eea:	b0270713          	addi	a4,a4,-1278 # 8001f9e8 <bcache+0x8268>
    80002eee:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ef2:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ef6:	00015497          	auipc	s1,0x15
    80002efa:	8a248493          	addi	s1,s1,-1886 # 80017798 <bcache+0x18>
    b->next = bcache.head.next;
    80002efe:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f00:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f02:	00005a17          	auipc	s4,0x5
    80002f06:	76ea0a13          	addi	s4,s4,1902 # 80008670 <syscall_list+0xc0>
    b->next = bcache.head.next;
    80002f0a:	2b893783          	ld	a5,696(s2)
    80002f0e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f10:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f14:	85d2                	mv	a1,s4
    80002f16:	01048513          	addi	a0,s1,16
    80002f1a:	00001097          	auipc	ra,0x1
    80002f1e:	4b2080e7          	jalr	1202(ra) # 800043cc <initsleeplock>
    bcache.head.next->prev = b;
    80002f22:	2b893783          	ld	a5,696(s2)
    80002f26:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f28:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f2c:	45848493          	addi	s1,s1,1112
    80002f30:	fd349de3          	bne	s1,s3,80002f0a <binit+0x54>
  }
}
    80002f34:	70a2                	ld	ra,40(sp)
    80002f36:	7402                	ld	s0,32(sp)
    80002f38:	64e2                	ld	s1,24(sp)
    80002f3a:	6942                	ld	s2,16(sp)
    80002f3c:	69a2                	ld	s3,8(sp)
    80002f3e:	6a02                	ld	s4,0(sp)
    80002f40:	6145                	addi	sp,sp,48
    80002f42:	8082                	ret

0000000080002f44 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f44:	7179                	addi	sp,sp,-48
    80002f46:	f406                	sd	ra,40(sp)
    80002f48:	f022                	sd	s0,32(sp)
    80002f4a:	ec26                	sd	s1,24(sp)
    80002f4c:	e84a                	sd	s2,16(sp)
    80002f4e:	e44e                	sd	s3,8(sp)
    80002f50:	1800                	addi	s0,sp,48
    80002f52:	892a                	mv	s2,a0
    80002f54:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f56:	00015517          	auipc	a0,0x15
    80002f5a:	82a50513          	addi	a0,a0,-2006 # 80017780 <bcache>
    80002f5e:	ffffe097          	auipc	ra,0xffffe
    80002f62:	cec080e7          	jalr	-788(ra) # 80000c4a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f66:	0001d497          	auipc	s1,0x1d
    80002f6a:	ad24b483          	ld	s1,-1326(s1) # 8001fa38 <bcache+0x82b8>
    80002f6e:	0001d797          	auipc	a5,0x1d
    80002f72:	a7a78793          	addi	a5,a5,-1414 # 8001f9e8 <bcache+0x8268>
    80002f76:	02f48f63          	beq	s1,a5,80002fb4 <bread+0x70>
    80002f7a:	873e                	mv	a4,a5
    80002f7c:	a021                	j	80002f84 <bread+0x40>
    80002f7e:	68a4                	ld	s1,80(s1)
    80002f80:	02e48a63          	beq	s1,a4,80002fb4 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f84:	449c                	lw	a5,8(s1)
    80002f86:	ff279ce3          	bne	a5,s2,80002f7e <bread+0x3a>
    80002f8a:	44dc                	lw	a5,12(s1)
    80002f8c:	ff3799e3          	bne	a5,s3,80002f7e <bread+0x3a>
      b->refcnt++;
    80002f90:	40bc                	lw	a5,64(s1)
    80002f92:	2785                	addiw	a5,a5,1
    80002f94:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f96:	00014517          	auipc	a0,0x14
    80002f9a:	7ea50513          	addi	a0,a0,2026 # 80017780 <bcache>
    80002f9e:	ffffe097          	auipc	ra,0xffffe
    80002fa2:	d60080e7          	jalr	-672(ra) # 80000cfe <release>
      acquiresleep(&b->lock);
    80002fa6:	01048513          	addi	a0,s1,16
    80002faa:	00001097          	auipc	ra,0x1
    80002fae:	45c080e7          	jalr	1116(ra) # 80004406 <acquiresleep>
      return b;
    80002fb2:	a8b9                	j	80003010 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fb4:	0001d497          	auipc	s1,0x1d
    80002fb8:	a7c4b483          	ld	s1,-1412(s1) # 8001fa30 <bcache+0x82b0>
    80002fbc:	0001d797          	auipc	a5,0x1d
    80002fc0:	a2c78793          	addi	a5,a5,-1492 # 8001f9e8 <bcache+0x8268>
    80002fc4:	00f48863          	beq	s1,a5,80002fd4 <bread+0x90>
    80002fc8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fca:	40bc                	lw	a5,64(s1)
    80002fcc:	cf81                	beqz	a5,80002fe4 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fce:	64a4                	ld	s1,72(s1)
    80002fd0:	fee49de3          	bne	s1,a4,80002fca <bread+0x86>
  panic("bget: no buffers");
    80002fd4:	00005517          	auipc	a0,0x5
    80002fd8:	6a450513          	addi	a0,a0,1700 # 80008678 <syscall_list+0xc8>
    80002fdc:	ffffd097          	auipc	ra,0xffffd
    80002fe0:	56a080e7          	jalr	1386(ra) # 80000546 <panic>
      b->dev = dev;
    80002fe4:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fe8:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002fec:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ff0:	4785                	li	a5,1
    80002ff2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ff4:	00014517          	auipc	a0,0x14
    80002ff8:	78c50513          	addi	a0,a0,1932 # 80017780 <bcache>
    80002ffc:	ffffe097          	auipc	ra,0xffffe
    80003000:	d02080e7          	jalr	-766(ra) # 80000cfe <release>
      acquiresleep(&b->lock);
    80003004:	01048513          	addi	a0,s1,16
    80003008:	00001097          	auipc	ra,0x1
    8000300c:	3fe080e7          	jalr	1022(ra) # 80004406 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003010:	409c                	lw	a5,0(s1)
    80003012:	cb89                	beqz	a5,80003024 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003014:	8526                	mv	a0,s1
    80003016:	70a2                	ld	ra,40(sp)
    80003018:	7402                	ld	s0,32(sp)
    8000301a:	64e2                	ld	s1,24(sp)
    8000301c:	6942                	ld	s2,16(sp)
    8000301e:	69a2                	ld	s3,8(sp)
    80003020:	6145                	addi	sp,sp,48
    80003022:	8082                	ret
    virtio_disk_rw(b, 0);
    80003024:	4581                	li	a1,0
    80003026:	8526                	mv	a0,s1
    80003028:	00003097          	auipc	ra,0x3
    8000302c:	f30080e7          	jalr	-208(ra) # 80005f58 <virtio_disk_rw>
    b->valid = 1;
    80003030:	4785                	li	a5,1
    80003032:	c09c                	sw	a5,0(s1)
  return b;
    80003034:	b7c5                	j	80003014 <bread+0xd0>

0000000080003036 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003036:	1101                	addi	sp,sp,-32
    80003038:	ec06                	sd	ra,24(sp)
    8000303a:	e822                	sd	s0,16(sp)
    8000303c:	e426                	sd	s1,8(sp)
    8000303e:	1000                	addi	s0,sp,32
    80003040:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003042:	0541                	addi	a0,a0,16
    80003044:	00001097          	auipc	ra,0x1
    80003048:	45c080e7          	jalr	1116(ra) # 800044a0 <holdingsleep>
    8000304c:	cd01                	beqz	a0,80003064 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000304e:	4585                	li	a1,1
    80003050:	8526                	mv	a0,s1
    80003052:	00003097          	auipc	ra,0x3
    80003056:	f06080e7          	jalr	-250(ra) # 80005f58 <virtio_disk_rw>
}
    8000305a:	60e2                	ld	ra,24(sp)
    8000305c:	6442                	ld	s0,16(sp)
    8000305e:	64a2                	ld	s1,8(sp)
    80003060:	6105                	addi	sp,sp,32
    80003062:	8082                	ret
    panic("bwrite");
    80003064:	00005517          	auipc	a0,0x5
    80003068:	62c50513          	addi	a0,a0,1580 # 80008690 <syscall_list+0xe0>
    8000306c:	ffffd097          	auipc	ra,0xffffd
    80003070:	4da080e7          	jalr	1242(ra) # 80000546 <panic>

0000000080003074 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003074:	1101                	addi	sp,sp,-32
    80003076:	ec06                	sd	ra,24(sp)
    80003078:	e822                	sd	s0,16(sp)
    8000307a:	e426                	sd	s1,8(sp)
    8000307c:	e04a                	sd	s2,0(sp)
    8000307e:	1000                	addi	s0,sp,32
    80003080:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003082:	01050913          	addi	s2,a0,16
    80003086:	854a                	mv	a0,s2
    80003088:	00001097          	auipc	ra,0x1
    8000308c:	418080e7          	jalr	1048(ra) # 800044a0 <holdingsleep>
    80003090:	c92d                	beqz	a0,80003102 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003092:	854a                	mv	a0,s2
    80003094:	00001097          	auipc	ra,0x1
    80003098:	3c8080e7          	jalr	968(ra) # 8000445c <releasesleep>

  acquire(&bcache.lock);
    8000309c:	00014517          	auipc	a0,0x14
    800030a0:	6e450513          	addi	a0,a0,1764 # 80017780 <bcache>
    800030a4:	ffffe097          	auipc	ra,0xffffe
    800030a8:	ba6080e7          	jalr	-1114(ra) # 80000c4a <acquire>
  b->refcnt--;
    800030ac:	40bc                	lw	a5,64(s1)
    800030ae:	37fd                	addiw	a5,a5,-1
    800030b0:	0007871b          	sext.w	a4,a5
    800030b4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030b6:	eb05                	bnez	a4,800030e6 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030b8:	68bc                	ld	a5,80(s1)
    800030ba:	64b8                	ld	a4,72(s1)
    800030bc:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800030be:	64bc                	ld	a5,72(s1)
    800030c0:	68b8                	ld	a4,80(s1)
    800030c2:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030c4:	0001c797          	auipc	a5,0x1c
    800030c8:	6bc78793          	addi	a5,a5,1724 # 8001f780 <bcache+0x8000>
    800030cc:	2b87b703          	ld	a4,696(a5)
    800030d0:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030d2:	0001d717          	auipc	a4,0x1d
    800030d6:	91670713          	addi	a4,a4,-1770 # 8001f9e8 <bcache+0x8268>
    800030da:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030dc:	2b87b703          	ld	a4,696(a5)
    800030e0:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030e2:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030e6:	00014517          	auipc	a0,0x14
    800030ea:	69a50513          	addi	a0,a0,1690 # 80017780 <bcache>
    800030ee:	ffffe097          	auipc	ra,0xffffe
    800030f2:	c10080e7          	jalr	-1008(ra) # 80000cfe <release>
}
    800030f6:	60e2                	ld	ra,24(sp)
    800030f8:	6442                	ld	s0,16(sp)
    800030fa:	64a2                	ld	s1,8(sp)
    800030fc:	6902                	ld	s2,0(sp)
    800030fe:	6105                	addi	sp,sp,32
    80003100:	8082                	ret
    panic("brelse");
    80003102:	00005517          	auipc	a0,0x5
    80003106:	59650513          	addi	a0,a0,1430 # 80008698 <syscall_list+0xe8>
    8000310a:	ffffd097          	auipc	ra,0xffffd
    8000310e:	43c080e7          	jalr	1084(ra) # 80000546 <panic>

0000000080003112 <bpin>:

void
bpin(struct buf *b) {
    80003112:	1101                	addi	sp,sp,-32
    80003114:	ec06                	sd	ra,24(sp)
    80003116:	e822                	sd	s0,16(sp)
    80003118:	e426                	sd	s1,8(sp)
    8000311a:	1000                	addi	s0,sp,32
    8000311c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000311e:	00014517          	auipc	a0,0x14
    80003122:	66250513          	addi	a0,a0,1634 # 80017780 <bcache>
    80003126:	ffffe097          	auipc	ra,0xffffe
    8000312a:	b24080e7          	jalr	-1244(ra) # 80000c4a <acquire>
  b->refcnt++;
    8000312e:	40bc                	lw	a5,64(s1)
    80003130:	2785                	addiw	a5,a5,1
    80003132:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003134:	00014517          	auipc	a0,0x14
    80003138:	64c50513          	addi	a0,a0,1612 # 80017780 <bcache>
    8000313c:	ffffe097          	auipc	ra,0xffffe
    80003140:	bc2080e7          	jalr	-1086(ra) # 80000cfe <release>
}
    80003144:	60e2                	ld	ra,24(sp)
    80003146:	6442                	ld	s0,16(sp)
    80003148:	64a2                	ld	s1,8(sp)
    8000314a:	6105                	addi	sp,sp,32
    8000314c:	8082                	ret

000000008000314e <bunpin>:

void
bunpin(struct buf *b) {
    8000314e:	1101                	addi	sp,sp,-32
    80003150:	ec06                	sd	ra,24(sp)
    80003152:	e822                	sd	s0,16(sp)
    80003154:	e426                	sd	s1,8(sp)
    80003156:	1000                	addi	s0,sp,32
    80003158:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000315a:	00014517          	auipc	a0,0x14
    8000315e:	62650513          	addi	a0,a0,1574 # 80017780 <bcache>
    80003162:	ffffe097          	auipc	ra,0xffffe
    80003166:	ae8080e7          	jalr	-1304(ra) # 80000c4a <acquire>
  b->refcnt--;
    8000316a:	40bc                	lw	a5,64(s1)
    8000316c:	37fd                	addiw	a5,a5,-1
    8000316e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003170:	00014517          	auipc	a0,0x14
    80003174:	61050513          	addi	a0,a0,1552 # 80017780 <bcache>
    80003178:	ffffe097          	auipc	ra,0xffffe
    8000317c:	b86080e7          	jalr	-1146(ra) # 80000cfe <release>
}
    80003180:	60e2                	ld	ra,24(sp)
    80003182:	6442                	ld	s0,16(sp)
    80003184:	64a2                	ld	s1,8(sp)
    80003186:	6105                	addi	sp,sp,32
    80003188:	8082                	ret

000000008000318a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000318a:	1101                	addi	sp,sp,-32
    8000318c:	ec06                	sd	ra,24(sp)
    8000318e:	e822                	sd	s0,16(sp)
    80003190:	e426                	sd	s1,8(sp)
    80003192:	e04a                	sd	s2,0(sp)
    80003194:	1000                	addi	s0,sp,32
    80003196:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003198:	00d5d59b          	srliw	a1,a1,0xd
    8000319c:	0001d797          	auipc	a5,0x1d
    800031a0:	cc07a783          	lw	a5,-832(a5) # 8001fe5c <sb+0x1c>
    800031a4:	9dbd                	addw	a1,a1,a5
    800031a6:	00000097          	auipc	ra,0x0
    800031aa:	d9e080e7          	jalr	-610(ra) # 80002f44 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031ae:	0074f713          	andi	a4,s1,7
    800031b2:	4785                	li	a5,1
    800031b4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031b8:	14ce                	slli	s1,s1,0x33
    800031ba:	90d9                	srli	s1,s1,0x36
    800031bc:	00950733          	add	a4,a0,s1
    800031c0:	05874703          	lbu	a4,88(a4)
    800031c4:	00e7f6b3          	and	a3,a5,a4
    800031c8:	c69d                	beqz	a3,800031f6 <bfree+0x6c>
    800031ca:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031cc:	94aa                	add	s1,s1,a0
    800031ce:	fff7c793          	not	a5,a5
    800031d2:	8f7d                	and	a4,a4,a5
    800031d4:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800031d8:	00001097          	auipc	ra,0x1
    800031dc:	108080e7          	jalr	264(ra) # 800042e0 <log_write>
  brelse(bp);
    800031e0:	854a                	mv	a0,s2
    800031e2:	00000097          	auipc	ra,0x0
    800031e6:	e92080e7          	jalr	-366(ra) # 80003074 <brelse>
}
    800031ea:	60e2                	ld	ra,24(sp)
    800031ec:	6442                	ld	s0,16(sp)
    800031ee:	64a2                	ld	s1,8(sp)
    800031f0:	6902                	ld	s2,0(sp)
    800031f2:	6105                	addi	sp,sp,32
    800031f4:	8082                	ret
    panic("freeing free block");
    800031f6:	00005517          	auipc	a0,0x5
    800031fa:	4aa50513          	addi	a0,a0,1194 # 800086a0 <syscall_list+0xf0>
    800031fe:	ffffd097          	auipc	ra,0xffffd
    80003202:	348080e7          	jalr	840(ra) # 80000546 <panic>

0000000080003206 <balloc>:
{
    80003206:	711d                	addi	sp,sp,-96
    80003208:	ec86                	sd	ra,88(sp)
    8000320a:	e8a2                	sd	s0,80(sp)
    8000320c:	e4a6                	sd	s1,72(sp)
    8000320e:	e0ca                	sd	s2,64(sp)
    80003210:	fc4e                	sd	s3,56(sp)
    80003212:	f852                	sd	s4,48(sp)
    80003214:	f456                	sd	s5,40(sp)
    80003216:	f05a                	sd	s6,32(sp)
    80003218:	ec5e                	sd	s7,24(sp)
    8000321a:	e862                	sd	s8,16(sp)
    8000321c:	e466                	sd	s9,8(sp)
    8000321e:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003220:	0001d797          	auipc	a5,0x1d
    80003224:	c247a783          	lw	a5,-988(a5) # 8001fe44 <sb+0x4>
    80003228:	cbc1                	beqz	a5,800032b8 <balloc+0xb2>
    8000322a:	8baa                	mv	s7,a0
    8000322c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000322e:	0001db17          	auipc	s6,0x1d
    80003232:	c12b0b13          	addi	s6,s6,-1006 # 8001fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003236:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003238:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000323a:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000323c:	6c89                	lui	s9,0x2
    8000323e:	a831                	j	8000325a <balloc+0x54>
    brelse(bp);
    80003240:	854a                	mv	a0,s2
    80003242:	00000097          	auipc	ra,0x0
    80003246:	e32080e7          	jalr	-462(ra) # 80003074 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000324a:	015c87bb          	addw	a5,s9,s5
    8000324e:	00078a9b          	sext.w	s5,a5
    80003252:	004b2703          	lw	a4,4(s6)
    80003256:	06eaf163          	bgeu	s5,a4,800032b8 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    8000325a:	41fad79b          	sraiw	a5,s5,0x1f
    8000325e:	0137d79b          	srliw	a5,a5,0x13
    80003262:	015787bb          	addw	a5,a5,s5
    80003266:	40d7d79b          	sraiw	a5,a5,0xd
    8000326a:	01cb2583          	lw	a1,28(s6)
    8000326e:	9dbd                	addw	a1,a1,a5
    80003270:	855e                	mv	a0,s7
    80003272:	00000097          	auipc	ra,0x0
    80003276:	cd2080e7          	jalr	-814(ra) # 80002f44 <bread>
    8000327a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000327c:	004b2503          	lw	a0,4(s6)
    80003280:	000a849b          	sext.w	s1,s5
    80003284:	8762                	mv	a4,s8
    80003286:	faa4fde3          	bgeu	s1,a0,80003240 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000328a:	00777693          	andi	a3,a4,7
    8000328e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003292:	41f7579b          	sraiw	a5,a4,0x1f
    80003296:	01d7d79b          	srliw	a5,a5,0x1d
    8000329a:	9fb9                	addw	a5,a5,a4
    8000329c:	4037d79b          	sraiw	a5,a5,0x3
    800032a0:	00f90633          	add	a2,s2,a5
    800032a4:	05864603          	lbu	a2,88(a2)
    800032a8:	00c6f5b3          	and	a1,a3,a2
    800032ac:	cd91                	beqz	a1,800032c8 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032ae:	2705                	addiw	a4,a4,1
    800032b0:	2485                	addiw	s1,s1,1
    800032b2:	fd471ae3          	bne	a4,s4,80003286 <balloc+0x80>
    800032b6:	b769                	j	80003240 <balloc+0x3a>
  panic("balloc: out of blocks");
    800032b8:	00005517          	auipc	a0,0x5
    800032bc:	40050513          	addi	a0,a0,1024 # 800086b8 <syscall_list+0x108>
    800032c0:	ffffd097          	auipc	ra,0xffffd
    800032c4:	286080e7          	jalr	646(ra) # 80000546 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032c8:	97ca                	add	a5,a5,s2
    800032ca:	8e55                	or	a2,a2,a3
    800032cc:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800032d0:	854a                	mv	a0,s2
    800032d2:	00001097          	auipc	ra,0x1
    800032d6:	00e080e7          	jalr	14(ra) # 800042e0 <log_write>
        brelse(bp);
    800032da:	854a                	mv	a0,s2
    800032dc:	00000097          	auipc	ra,0x0
    800032e0:	d98080e7          	jalr	-616(ra) # 80003074 <brelse>
  bp = bread(dev, bno);
    800032e4:	85a6                	mv	a1,s1
    800032e6:	855e                	mv	a0,s7
    800032e8:	00000097          	auipc	ra,0x0
    800032ec:	c5c080e7          	jalr	-932(ra) # 80002f44 <bread>
    800032f0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032f2:	40000613          	li	a2,1024
    800032f6:	4581                	li	a1,0
    800032f8:	05850513          	addi	a0,a0,88
    800032fc:	ffffe097          	auipc	ra,0xffffe
    80003300:	a4a080e7          	jalr	-1462(ra) # 80000d46 <memset>
  log_write(bp);
    80003304:	854a                	mv	a0,s2
    80003306:	00001097          	auipc	ra,0x1
    8000330a:	fda080e7          	jalr	-38(ra) # 800042e0 <log_write>
  brelse(bp);
    8000330e:	854a                	mv	a0,s2
    80003310:	00000097          	auipc	ra,0x0
    80003314:	d64080e7          	jalr	-668(ra) # 80003074 <brelse>
}
    80003318:	8526                	mv	a0,s1
    8000331a:	60e6                	ld	ra,88(sp)
    8000331c:	6446                	ld	s0,80(sp)
    8000331e:	64a6                	ld	s1,72(sp)
    80003320:	6906                	ld	s2,64(sp)
    80003322:	79e2                	ld	s3,56(sp)
    80003324:	7a42                	ld	s4,48(sp)
    80003326:	7aa2                	ld	s5,40(sp)
    80003328:	7b02                	ld	s6,32(sp)
    8000332a:	6be2                	ld	s7,24(sp)
    8000332c:	6c42                	ld	s8,16(sp)
    8000332e:	6ca2                	ld	s9,8(sp)
    80003330:	6125                	addi	sp,sp,96
    80003332:	8082                	ret

0000000080003334 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003334:	7179                	addi	sp,sp,-48
    80003336:	f406                	sd	ra,40(sp)
    80003338:	f022                	sd	s0,32(sp)
    8000333a:	ec26                	sd	s1,24(sp)
    8000333c:	e84a                	sd	s2,16(sp)
    8000333e:	e44e                	sd	s3,8(sp)
    80003340:	e052                	sd	s4,0(sp)
    80003342:	1800                	addi	s0,sp,48
    80003344:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003346:	47ad                	li	a5,11
    80003348:	04b7fe63          	bgeu	a5,a1,800033a4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000334c:	ff45849b          	addiw	s1,a1,-12
    80003350:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003354:	0ff00793          	li	a5,255
    80003358:	0ae7e463          	bltu	a5,a4,80003400 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    8000335c:	08052583          	lw	a1,128(a0)
    80003360:	c5b5                	beqz	a1,800033cc <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    80003362:	00092503          	lw	a0,0(s2)
    80003366:	00000097          	auipc	ra,0x0
    8000336a:	bde080e7          	jalr	-1058(ra) # 80002f44 <bread>
    8000336e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003370:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003374:	02049713          	slli	a4,s1,0x20
    80003378:	01e75593          	srli	a1,a4,0x1e
    8000337c:	00b784b3          	add	s1,a5,a1
    80003380:	0004a983          	lw	s3,0(s1)
    80003384:	04098e63          	beqz	s3,800033e0 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003388:	8552                	mv	a0,s4
    8000338a:	00000097          	auipc	ra,0x0
    8000338e:	cea080e7          	jalr	-790(ra) # 80003074 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003392:	854e                	mv	a0,s3
    80003394:	70a2                	ld	ra,40(sp)
    80003396:	7402                	ld	s0,32(sp)
    80003398:	64e2                	ld	s1,24(sp)
    8000339a:	6942                	ld	s2,16(sp)
    8000339c:	69a2                	ld	s3,8(sp)
    8000339e:	6a02                	ld	s4,0(sp)
    800033a0:	6145                	addi	sp,sp,48
    800033a2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033a4:	02059793          	slli	a5,a1,0x20
    800033a8:	01e7d593          	srli	a1,a5,0x1e
    800033ac:	00b504b3          	add	s1,a0,a1
    800033b0:	0504a983          	lw	s3,80(s1)
    800033b4:	fc099fe3          	bnez	s3,80003392 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    800033b8:	4108                	lw	a0,0(a0)
    800033ba:	00000097          	auipc	ra,0x0
    800033be:	e4c080e7          	jalr	-436(ra) # 80003206 <balloc>
    800033c2:	0005099b          	sext.w	s3,a0
    800033c6:	0534a823          	sw	s3,80(s1)
    800033ca:	b7e1                	j	80003392 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    800033cc:	4108                	lw	a0,0(a0)
    800033ce:	00000097          	auipc	ra,0x0
    800033d2:	e38080e7          	jalr	-456(ra) # 80003206 <balloc>
    800033d6:	0005059b          	sext.w	a1,a0
    800033da:	08b92023          	sw	a1,128(s2)
    800033de:	b751                	j	80003362 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    800033e0:	00092503          	lw	a0,0(s2)
    800033e4:	00000097          	auipc	ra,0x0
    800033e8:	e22080e7          	jalr	-478(ra) # 80003206 <balloc>
    800033ec:	0005099b          	sext.w	s3,a0
    800033f0:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    800033f4:	8552                	mv	a0,s4
    800033f6:	00001097          	auipc	ra,0x1
    800033fa:	eea080e7          	jalr	-278(ra) # 800042e0 <log_write>
    800033fe:	b769                	j	80003388 <bmap+0x54>
  panic("bmap: out of range");
    80003400:	00005517          	auipc	a0,0x5
    80003404:	2d050513          	addi	a0,a0,720 # 800086d0 <syscall_list+0x120>
    80003408:	ffffd097          	auipc	ra,0xffffd
    8000340c:	13e080e7          	jalr	318(ra) # 80000546 <panic>

0000000080003410 <iget>:
{
    80003410:	7179                	addi	sp,sp,-48
    80003412:	f406                	sd	ra,40(sp)
    80003414:	f022                	sd	s0,32(sp)
    80003416:	ec26                	sd	s1,24(sp)
    80003418:	e84a                	sd	s2,16(sp)
    8000341a:	e44e                	sd	s3,8(sp)
    8000341c:	e052                	sd	s4,0(sp)
    8000341e:	1800                	addi	s0,sp,48
    80003420:	89aa                	mv	s3,a0
    80003422:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003424:	0001d517          	auipc	a0,0x1d
    80003428:	a3c50513          	addi	a0,a0,-1476 # 8001fe60 <icache>
    8000342c:	ffffe097          	auipc	ra,0xffffe
    80003430:	81e080e7          	jalr	-2018(ra) # 80000c4a <acquire>
  empty = 0;
    80003434:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003436:	0001d497          	auipc	s1,0x1d
    8000343a:	a4248493          	addi	s1,s1,-1470 # 8001fe78 <icache+0x18>
    8000343e:	0001e697          	auipc	a3,0x1e
    80003442:	4ca68693          	addi	a3,a3,1226 # 80021908 <log>
    80003446:	a039                	j	80003454 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003448:	02090b63          	beqz	s2,8000347e <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000344c:	08848493          	addi	s1,s1,136
    80003450:	02d48a63          	beq	s1,a3,80003484 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003454:	449c                	lw	a5,8(s1)
    80003456:	fef059e3          	blez	a5,80003448 <iget+0x38>
    8000345a:	4098                	lw	a4,0(s1)
    8000345c:	ff3716e3          	bne	a4,s3,80003448 <iget+0x38>
    80003460:	40d8                	lw	a4,4(s1)
    80003462:	ff4713e3          	bne	a4,s4,80003448 <iget+0x38>
      ip->ref++;
    80003466:	2785                	addiw	a5,a5,1
    80003468:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    8000346a:	0001d517          	auipc	a0,0x1d
    8000346e:	9f650513          	addi	a0,a0,-1546 # 8001fe60 <icache>
    80003472:	ffffe097          	auipc	ra,0xffffe
    80003476:	88c080e7          	jalr	-1908(ra) # 80000cfe <release>
      return ip;
    8000347a:	8926                	mv	s2,s1
    8000347c:	a03d                	j	800034aa <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000347e:	f7f9                	bnez	a5,8000344c <iget+0x3c>
    80003480:	8926                	mv	s2,s1
    80003482:	b7e9                	j	8000344c <iget+0x3c>
  if(empty == 0)
    80003484:	02090c63          	beqz	s2,800034bc <iget+0xac>
  ip->dev = dev;
    80003488:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000348c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003490:	4785                	li	a5,1
    80003492:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003496:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    8000349a:	0001d517          	auipc	a0,0x1d
    8000349e:	9c650513          	addi	a0,a0,-1594 # 8001fe60 <icache>
    800034a2:	ffffe097          	auipc	ra,0xffffe
    800034a6:	85c080e7          	jalr	-1956(ra) # 80000cfe <release>
}
    800034aa:	854a                	mv	a0,s2
    800034ac:	70a2                	ld	ra,40(sp)
    800034ae:	7402                	ld	s0,32(sp)
    800034b0:	64e2                	ld	s1,24(sp)
    800034b2:	6942                	ld	s2,16(sp)
    800034b4:	69a2                	ld	s3,8(sp)
    800034b6:	6a02                	ld	s4,0(sp)
    800034b8:	6145                	addi	sp,sp,48
    800034ba:	8082                	ret
    panic("iget: no inodes");
    800034bc:	00005517          	auipc	a0,0x5
    800034c0:	22c50513          	addi	a0,a0,556 # 800086e8 <syscall_list+0x138>
    800034c4:	ffffd097          	auipc	ra,0xffffd
    800034c8:	082080e7          	jalr	130(ra) # 80000546 <panic>

00000000800034cc <fsinit>:
fsinit(int dev) {
    800034cc:	7179                	addi	sp,sp,-48
    800034ce:	f406                	sd	ra,40(sp)
    800034d0:	f022                	sd	s0,32(sp)
    800034d2:	ec26                	sd	s1,24(sp)
    800034d4:	e84a                	sd	s2,16(sp)
    800034d6:	e44e                	sd	s3,8(sp)
    800034d8:	1800                	addi	s0,sp,48
    800034da:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034dc:	4585                	li	a1,1
    800034de:	00000097          	auipc	ra,0x0
    800034e2:	a66080e7          	jalr	-1434(ra) # 80002f44 <bread>
    800034e6:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034e8:	0001d997          	auipc	s3,0x1d
    800034ec:	95898993          	addi	s3,s3,-1704 # 8001fe40 <sb>
    800034f0:	02000613          	li	a2,32
    800034f4:	05850593          	addi	a1,a0,88
    800034f8:	854e                	mv	a0,s3
    800034fa:	ffffe097          	auipc	ra,0xffffe
    800034fe:	8a8080e7          	jalr	-1880(ra) # 80000da2 <memmove>
  brelse(bp);
    80003502:	8526                	mv	a0,s1
    80003504:	00000097          	auipc	ra,0x0
    80003508:	b70080e7          	jalr	-1168(ra) # 80003074 <brelse>
  if(sb.magic != FSMAGIC)
    8000350c:	0009a703          	lw	a4,0(s3)
    80003510:	102037b7          	lui	a5,0x10203
    80003514:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003518:	02f71263          	bne	a4,a5,8000353c <fsinit+0x70>
  initlog(dev, &sb);
    8000351c:	0001d597          	auipc	a1,0x1d
    80003520:	92458593          	addi	a1,a1,-1756 # 8001fe40 <sb>
    80003524:	854a                	mv	a0,s2
    80003526:	00001097          	auipc	ra,0x1
    8000352a:	b42080e7          	jalr	-1214(ra) # 80004068 <initlog>
}
    8000352e:	70a2                	ld	ra,40(sp)
    80003530:	7402                	ld	s0,32(sp)
    80003532:	64e2                	ld	s1,24(sp)
    80003534:	6942                	ld	s2,16(sp)
    80003536:	69a2                	ld	s3,8(sp)
    80003538:	6145                	addi	sp,sp,48
    8000353a:	8082                	ret
    panic("invalid file system");
    8000353c:	00005517          	auipc	a0,0x5
    80003540:	1bc50513          	addi	a0,a0,444 # 800086f8 <syscall_list+0x148>
    80003544:	ffffd097          	auipc	ra,0xffffd
    80003548:	002080e7          	jalr	2(ra) # 80000546 <panic>

000000008000354c <iinit>:
{
    8000354c:	7179                	addi	sp,sp,-48
    8000354e:	f406                	sd	ra,40(sp)
    80003550:	f022                	sd	s0,32(sp)
    80003552:	ec26                	sd	s1,24(sp)
    80003554:	e84a                	sd	s2,16(sp)
    80003556:	e44e                	sd	s3,8(sp)
    80003558:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    8000355a:	00005597          	auipc	a1,0x5
    8000355e:	1b658593          	addi	a1,a1,438 # 80008710 <syscall_list+0x160>
    80003562:	0001d517          	auipc	a0,0x1d
    80003566:	8fe50513          	addi	a0,a0,-1794 # 8001fe60 <icache>
    8000356a:	ffffd097          	auipc	ra,0xffffd
    8000356e:	650080e7          	jalr	1616(ra) # 80000bba <initlock>
  for(i = 0; i < NINODE; i++) {
    80003572:	0001d497          	auipc	s1,0x1d
    80003576:	91648493          	addi	s1,s1,-1770 # 8001fe88 <icache+0x28>
    8000357a:	0001e997          	auipc	s3,0x1e
    8000357e:	39e98993          	addi	s3,s3,926 # 80021918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    80003582:	00005917          	auipc	s2,0x5
    80003586:	19690913          	addi	s2,s2,406 # 80008718 <syscall_list+0x168>
    8000358a:	85ca                	mv	a1,s2
    8000358c:	8526                	mv	a0,s1
    8000358e:	00001097          	auipc	ra,0x1
    80003592:	e3e080e7          	jalr	-450(ra) # 800043cc <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003596:	08848493          	addi	s1,s1,136
    8000359a:	ff3498e3          	bne	s1,s3,8000358a <iinit+0x3e>
}
    8000359e:	70a2                	ld	ra,40(sp)
    800035a0:	7402                	ld	s0,32(sp)
    800035a2:	64e2                	ld	s1,24(sp)
    800035a4:	6942                	ld	s2,16(sp)
    800035a6:	69a2                	ld	s3,8(sp)
    800035a8:	6145                	addi	sp,sp,48
    800035aa:	8082                	ret

00000000800035ac <ialloc>:
{
    800035ac:	715d                	addi	sp,sp,-80
    800035ae:	e486                	sd	ra,72(sp)
    800035b0:	e0a2                	sd	s0,64(sp)
    800035b2:	fc26                	sd	s1,56(sp)
    800035b4:	f84a                	sd	s2,48(sp)
    800035b6:	f44e                	sd	s3,40(sp)
    800035b8:	f052                	sd	s4,32(sp)
    800035ba:	ec56                	sd	s5,24(sp)
    800035bc:	e85a                	sd	s6,16(sp)
    800035be:	e45e                	sd	s7,8(sp)
    800035c0:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800035c2:	0001d717          	auipc	a4,0x1d
    800035c6:	88a72703          	lw	a4,-1910(a4) # 8001fe4c <sb+0xc>
    800035ca:	4785                	li	a5,1
    800035cc:	04e7fa63          	bgeu	a5,a4,80003620 <ialloc+0x74>
    800035d0:	8aaa                	mv	s5,a0
    800035d2:	8bae                	mv	s7,a1
    800035d4:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035d6:	0001da17          	auipc	s4,0x1d
    800035da:	86aa0a13          	addi	s4,s4,-1942 # 8001fe40 <sb>
    800035de:	00048b1b          	sext.w	s6,s1
    800035e2:	0044d593          	srli	a1,s1,0x4
    800035e6:	018a2783          	lw	a5,24(s4)
    800035ea:	9dbd                	addw	a1,a1,a5
    800035ec:	8556                	mv	a0,s5
    800035ee:	00000097          	auipc	ra,0x0
    800035f2:	956080e7          	jalr	-1706(ra) # 80002f44 <bread>
    800035f6:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035f8:	05850993          	addi	s3,a0,88
    800035fc:	00f4f793          	andi	a5,s1,15
    80003600:	079a                	slli	a5,a5,0x6
    80003602:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003604:	00099783          	lh	a5,0(s3)
    80003608:	c785                	beqz	a5,80003630 <ialloc+0x84>
    brelse(bp);
    8000360a:	00000097          	auipc	ra,0x0
    8000360e:	a6a080e7          	jalr	-1430(ra) # 80003074 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003612:	0485                	addi	s1,s1,1
    80003614:	00ca2703          	lw	a4,12(s4)
    80003618:	0004879b          	sext.w	a5,s1
    8000361c:	fce7e1e3          	bltu	a5,a4,800035de <ialloc+0x32>
  panic("ialloc: no inodes");
    80003620:	00005517          	auipc	a0,0x5
    80003624:	10050513          	addi	a0,a0,256 # 80008720 <syscall_list+0x170>
    80003628:	ffffd097          	auipc	ra,0xffffd
    8000362c:	f1e080e7          	jalr	-226(ra) # 80000546 <panic>
      memset(dip, 0, sizeof(*dip));
    80003630:	04000613          	li	a2,64
    80003634:	4581                	li	a1,0
    80003636:	854e                	mv	a0,s3
    80003638:	ffffd097          	auipc	ra,0xffffd
    8000363c:	70e080e7          	jalr	1806(ra) # 80000d46 <memset>
      dip->type = type;
    80003640:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003644:	854a                	mv	a0,s2
    80003646:	00001097          	auipc	ra,0x1
    8000364a:	c9a080e7          	jalr	-870(ra) # 800042e0 <log_write>
      brelse(bp);
    8000364e:	854a                	mv	a0,s2
    80003650:	00000097          	auipc	ra,0x0
    80003654:	a24080e7          	jalr	-1500(ra) # 80003074 <brelse>
      return iget(dev, inum);
    80003658:	85da                	mv	a1,s6
    8000365a:	8556                	mv	a0,s5
    8000365c:	00000097          	auipc	ra,0x0
    80003660:	db4080e7          	jalr	-588(ra) # 80003410 <iget>
}
    80003664:	60a6                	ld	ra,72(sp)
    80003666:	6406                	ld	s0,64(sp)
    80003668:	74e2                	ld	s1,56(sp)
    8000366a:	7942                	ld	s2,48(sp)
    8000366c:	79a2                	ld	s3,40(sp)
    8000366e:	7a02                	ld	s4,32(sp)
    80003670:	6ae2                	ld	s5,24(sp)
    80003672:	6b42                	ld	s6,16(sp)
    80003674:	6ba2                	ld	s7,8(sp)
    80003676:	6161                	addi	sp,sp,80
    80003678:	8082                	ret

000000008000367a <iupdate>:
{
    8000367a:	1101                	addi	sp,sp,-32
    8000367c:	ec06                	sd	ra,24(sp)
    8000367e:	e822                	sd	s0,16(sp)
    80003680:	e426                	sd	s1,8(sp)
    80003682:	e04a                	sd	s2,0(sp)
    80003684:	1000                	addi	s0,sp,32
    80003686:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003688:	415c                	lw	a5,4(a0)
    8000368a:	0047d79b          	srliw	a5,a5,0x4
    8000368e:	0001c597          	auipc	a1,0x1c
    80003692:	7ca5a583          	lw	a1,1994(a1) # 8001fe58 <sb+0x18>
    80003696:	9dbd                	addw	a1,a1,a5
    80003698:	4108                	lw	a0,0(a0)
    8000369a:	00000097          	auipc	ra,0x0
    8000369e:	8aa080e7          	jalr	-1878(ra) # 80002f44 <bread>
    800036a2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036a4:	05850793          	addi	a5,a0,88
    800036a8:	40d8                	lw	a4,4(s1)
    800036aa:	8b3d                	andi	a4,a4,15
    800036ac:	071a                	slli	a4,a4,0x6
    800036ae:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036b0:	04449703          	lh	a4,68(s1)
    800036b4:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036b8:	04649703          	lh	a4,70(s1)
    800036bc:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036c0:	04849703          	lh	a4,72(s1)
    800036c4:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800036c8:	04a49703          	lh	a4,74(s1)
    800036cc:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800036d0:	44f8                	lw	a4,76(s1)
    800036d2:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036d4:	03400613          	li	a2,52
    800036d8:	05048593          	addi	a1,s1,80
    800036dc:	00c78513          	addi	a0,a5,12
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	6c2080e7          	jalr	1730(ra) # 80000da2 <memmove>
  log_write(bp);
    800036e8:	854a                	mv	a0,s2
    800036ea:	00001097          	auipc	ra,0x1
    800036ee:	bf6080e7          	jalr	-1034(ra) # 800042e0 <log_write>
  brelse(bp);
    800036f2:	854a                	mv	a0,s2
    800036f4:	00000097          	auipc	ra,0x0
    800036f8:	980080e7          	jalr	-1664(ra) # 80003074 <brelse>
}
    800036fc:	60e2                	ld	ra,24(sp)
    800036fe:	6442                	ld	s0,16(sp)
    80003700:	64a2                	ld	s1,8(sp)
    80003702:	6902                	ld	s2,0(sp)
    80003704:	6105                	addi	sp,sp,32
    80003706:	8082                	ret

0000000080003708 <idup>:
{
    80003708:	1101                	addi	sp,sp,-32
    8000370a:	ec06                	sd	ra,24(sp)
    8000370c:	e822                	sd	s0,16(sp)
    8000370e:	e426                	sd	s1,8(sp)
    80003710:	1000                	addi	s0,sp,32
    80003712:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003714:	0001c517          	auipc	a0,0x1c
    80003718:	74c50513          	addi	a0,a0,1868 # 8001fe60 <icache>
    8000371c:	ffffd097          	auipc	ra,0xffffd
    80003720:	52e080e7          	jalr	1326(ra) # 80000c4a <acquire>
  ip->ref++;
    80003724:	449c                	lw	a5,8(s1)
    80003726:	2785                	addiw	a5,a5,1
    80003728:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000372a:	0001c517          	auipc	a0,0x1c
    8000372e:	73650513          	addi	a0,a0,1846 # 8001fe60 <icache>
    80003732:	ffffd097          	auipc	ra,0xffffd
    80003736:	5cc080e7          	jalr	1484(ra) # 80000cfe <release>
}
    8000373a:	8526                	mv	a0,s1
    8000373c:	60e2                	ld	ra,24(sp)
    8000373e:	6442                	ld	s0,16(sp)
    80003740:	64a2                	ld	s1,8(sp)
    80003742:	6105                	addi	sp,sp,32
    80003744:	8082                	ret

0000000080003746 <ilock>:
{
    80003746:	1101                	addi	sp,sp,-32
    80003748:	ec06                	sd	ra,24(sp)
    8000374a:	e822                	sd	s0,16(sp)
    8000374c:	e426                	sd	s1,8(sp)
    8000374e:	e04a                	sd	s2,0(sp)
    80003750:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003752:	c115                	beqz	a0,80003776 <ilock+0x30>
    80003754:	84aa                	mv	s1,a0
    80003756:	451c                	lw	a5,8(a0)
    80003758:	00f05f63          	blez	a5,80003776 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000375c:	0541                	addi	a0,a0,16
    8000375e:	00001097          	auipc	ra,0x1
    80003762:	ca8080e7          	jalr	-856(ra) # 80004406 <acquiresleep>
  if(ip->valid == 0){
    80003766:	40bc                	lw	a5,64(s1)
    80003768:	cf99                	beqz	a5,80003786 <ilock+0x40>
}
    8000376a:	60e2                	ld	ra,24(sp)
    8000376c:	6442                	ld	s0,16(sp)
    8000376e:	64a2                	ld	s1,8(sp)
    80003770:	6902                	ld	s2,0(sp)
    80003772:	6105                	addi	sp,sp,32
    80003774:	8082                	ret
    panic("ilock");
    80003776:	00005517          	auipc	a0,0x5
    8000377a:	fc250513          	addi	a0,a0,-62 # 80008738 <syscall_list+0x188>
    8000377e:	ffffd097          	auipc	ra,0xffffd
    80003782:	dc8080e7          	jalr	-568(ra) # 80000546 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003786:	40dc                	lw	a5,4(s1)
    80003788:	0047d79b          	srliw	a5,a5,0x4
    8000378c:	0001c597          	auipc	a1,0x1c
    80003790:	6cc5a583          	lw	a1,1740(a1) # 8001fe58 <sb+0x18>
    80003794:	9dbd                	addw	a1,a1,a5
    80003796:	4088                	lw	a0,0(s1)
    80003798:	fffff097          	auipc	ra,0xfffff
    8000379c:	7ac080e7          	jalr	1964(ra) # 80002f44 <bread>
    800037a0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037a2:	05850593          	addi	a1,a0,88
    800037a6:	40dc                	lw	a5,4(s1)
    800037a8:	8bbd                	andi	a5,a5,15
    800037aa:	079a                	slli	a5,a5,0x6
    800037ac:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037ae:	00059783          	lh	a5,0(a1)
    800037b2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037b6:	00259783          	lh	a5,2(a1)
    800037ba:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037be:	00459783          	lh	a5,4(a1)
    800037c2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037c6:	00659783          	lh	a5,6(a1)
    800037ca:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037ce:	459c                	lw	a5,8(a1)
    800037d0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037d2:	03400613          	li	a2,52
    800037d6:	05b1                	addi	a1,a1,12
    800037d8:	05048513          	addi	a0,s1,80
    800037dc:	ffffd097          	auipc	ra,0xffffd
    800037e0:	5c6080e7          	jalr	1478(ra) # 80000da2 <memmove>
    brelse(bp);
    800037e4:	854a                	mv	a0,s2
    800037e6:	00000097          	auipc	ra,0x0
    800037ea:	88e080e7          	jalr	-1906(ra) # 80003074 <brelse>
    ip->valid = 1;
    800037ee:	4785                	li	a5,1
    800037f0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037f2:	04449783          	lh	a5,68(s1)
    800037f6:	fbb5                	bnez	a5,8000376a <ilock+0x24>
      panic("ilock: no type");
    800037f8:	00005517          	auipc	a0,0x5
    800037fc:	f4850513          	addi	a0,a0,-184 # 80008740 <syscall_list+0x190>
    80003800:	ffffd097          	auipc	ra,0xffffd
    80003804:	d46080e7          	jalr	-698(ra) # 80000546 <panic>

0000000080003808 <iunlock>:
{
    80003808:	1101                	addi	sp,sp,-32
    8000380a:	ec06                	sd	ra,24(sp)
    8000380c:	e822                	sd	s0,16(sp)
    8000380e:	e426                	sd	s1,8(sp)
    80003810:	e04a                	sd	s2,0(sp)
    80003812:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003814:	c905                	beqz	a0,80003844 <iunlock+0x3c>
    80003816:	84aa                	mv	s1,a0
    80003818:	01050913          	addi	s2,a0,16
    8000381c:	854a                	mv	a0,s2
    8000381e:	00001097          	auipc	ra,0x1
    80003822:	c82080e7          	jalr	-894(ra) # 800044a0 <holdingsleep>
    80003826:	cd19                	beqz	a0,80003844 <iunlock+0x3c>
    80003828:	449c                	lw	a5,8(s1)
    8000382a:	00f05d63          	blez	a5,80003844 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000382e:	854a                	mv	a0,s2
    80003830:	00001097          	auipc	ra,0x1
    80003834:	c2c080e7          	jalr	-980(ra) # 8000445c <releasesleep>
}
    80003838:	60e2                	ld	ra,24(sp)
    8000383a:	6442                	ld	s0,16(sp)
    8000383c:	64a2                	ld	s1,8(sp)
    8000383e:	6902                	ld	s2,0(sp)
    80003840:	6105                	addi	sp,sp,32
    80003842:	8082                	ret
    panic("iunlock");
    80003844:	00005517          	auipc	a0,0x5
    80003848:	f0c50513          	addi	a0,a0,-244 # 80008750 <syscall_list+0x1a0>
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	cfa080e7          	jalr	-774(ra) # 80000546 <panic>

0000000080003854 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003854:	7179                	addi	sp,sp,-48
    80003856:	f406                	sd	ra,40(sp)
    80003858:	f022                	sd	s0,32(sp)
    8000385a:	ec26                	sd	s1,24(sp)
    8000385c:	e84a                	sd	s2,16(sp)
    8000385e:	e44e                	sd	s3,8(sp)
    80003860:	e052                	sd	s4,0(sp)
    80003862:	1800                	addi	s0,sp,48
    80003864:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003866:	05050493          	addi	s1,a0,80
    8000386a:	08050913          	addi	s2,a0,128
    8000386e:	a021                	j	80003876 <itrunc+0x22>
    80003870:	0491                	addi	s1,s1,4
    80003872:	01248d63          	beq	s1,s2,8000388c <itrunc+0x38>
    if(ip->addrs[i]){
    80003876:	408c                	lw	a1,0(s1)
    80003878:	dde5                	beqz	a1,80003870 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    8000387a:	0009a503          	lw	a0,0(s3)
    8000387e:	00000097          	auipc	ra,0x0
    80003882:	90c080e7          	jalr	-1780(ra) # 8000318a <bfree>
      ip->addrs[i] = 0;
    80003886:	0004a023          	sw	zero,0(s1)
    8000388a:	b7dd                	j	80003870 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000388c:	0809a583          	lw	a1,128(s3)
    80003890:	e185                	bnez	a1,800038b0 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003892:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003896:	854e                	mv	a0,s3
    80003898:	00000097          	auipc	ra,0x0
    8000389c:	de2080e7          	jalr	-542(ra) # 8000367a <iupdate>
}
    800038a0:	70a2                	ld	ra,40(sp)
    800038a2:	7402                	ld	s0,32(sp)
    800038a4:	64e2                	ld	s1,24(sp)
    800038a6:	6942                	ld	s2,16(sp)
    800038a8:	69a2                	ld	s3,8(sp)
    800038aa:	6a02                	ld	s4,0(sp)
    800038ac:	6145                	addi	sp,sp,48
    800038ae:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038b0:	0009a503          	lw	a0,0(s3)
    800038b4:	fffff097          	auipc	ra,0xfffff
    800038b8:	690080e7          	jalr	1680(ra) # 80002f44 <bread>
    800038bc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038be:	05850493          	addi	s1,a0,88
    800038c2:	45850913          	addi	s2,a0,1112
    800038c6:	a021                	j	800038ce <itrunc+0x7a>
    800038c8:	0491                	addi	s1,s1,4
    800038ca:	01248b63          	beq	s1,s2,800038e0 <itrunc+0x8c>
      if(a[j])
    800038ce:	408c                	lw	a1,0(s1)
    800038d0:	dde5                	beqz	a1,800038c8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800038d2:	0009a503          	lw	a0,0(s3)
    800038d6:	00000097          	auipc	ra,0x0
    800038da:	8b4080e7          	jalr	-1868(ra) # 8000318a <bfree>
    800038de:	b7ed                	j	800038c8 <itrunc+0x74>
    brelse(bp);
    800038e0:	8552                	mv	a0,s4
    800038e2:	fffff097          	auipc	ra,0xfffff
    800038e6:	792080e7          	jalr	1938(ra) # 80003074 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038ea:	0809a583          	lw	a1,128(s3)
    800038ee:	0009a503          	lw	a0,0(s3)
    800038f2:	00000097          	auipc	ra,0x0
    800038f6:	898080e7          	jalr	-1896(ra) # 8000318a <bfree>
    ip->addrs[NDIRECT] = 0;
    800038fa:	0809a023          	sw	zero,128(s3)
    800038fe:	bf51                	j	80003892 <itrunc+0x3e>

0000000080003900 <iput>:
{
    80003900:	1101                	addi	sp,sp,-32
    80003902:	ec06                	sd	ra,24(sp)
    80003904:	e822                	sd	s0,16(sp)
    80003906:	e426                	sd	s1,8(sp)
    80003908:	e04a                	sd	s2,0(sp)
    8000390a:	1000                	addi	s0,sp,32
    8000390c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000390e:	0001c517          	auipc	a0,0x1c
    80003912:	55250513          	addi	a0,a0,1362 # 8001fe60 <icache>
    80003916:	ffffd097          	auipc	ra,0xffffd
    8000391a:	334080e7          	jalr	820(ra) # 80000c4a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000391e:	4498                	lw	a4,8(s1)
    80003920:	4785                	li	a5,1
    80003922:	02f70363          	beq	a4,a5,80003948 <iput+0x48>
  ip->ref--;
    80003926:	449c                	lw	a5,8(s1)
    80003928:	37fd                	addiw	a5,a5,-1
    8000392a:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000392c:	0001c517          	auipc	a0,0x1c
    80003930:	53450513          	addi	a0,a0,1332 # 8001fe60 <icache>
    80003934:	ffffd097          	auipc	ra,0xffffd
    80003938:	3ca080e7          	jalr	970(ra) # 80000cfe <release>
}
    8000393c:	60e2                	ld	ra,24(sp)
    8000393e:	6442                	ld	s0,16(sp)
    80003940:	64a2                	ld	s1,8(sp)
    80003942:	6902                	ld	s2,0(sp)
    80003944:	6105                	addi	sp,sp,32
    80003946:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003948:	40bc                	lw	a5,64(s1)
    8000394a:	dff1                	beqz	a5,80003926 <iput+0x26>
    8000394c:	04a49783          	lh	a5,74(s1)
    80003950:	fbf9                	bnez	a5,80003926 <iput+0x26>
    acquiresleep(&ip->lock);
    80003952:	01048913          	addi	s2,s1,16
    80003956:	854a                	mv	a0,s2
    80003958:	00001097          	auipc	ra,0x1
    8000395c:	aae080e7          	jalr	-1362(ra) # 80004406 <acquiresleep>
    release(&icache.lock);
    80003960:	0001c517          	auipc	a0,0x1c
    80003964:	50050513          	addi	a0,a0,1280 # 8001fe60 <icache>
    80003968:	ffffd097          	auipc	ra,0xffffd
    8000396c:	396080e7          	jalr	918(ra) # 80000cfe <release>
    itrunc(ip);
    80003970:	8526                	mv	a0,s1
    80003972:	00000097          	auipc	ra,0x0
    80003976:	ee2080e7          	jalr	-286(ra) # 80003854 <itrunc>
    ip->type = 0;
    8000397a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000397e:	8526                	mv	a0,s1
    80003980:	00000097          	auipc	ra,0x0
    80003984:	cfa080e7          	jalr	-774(ra) # 8000367a <iupdate>
    ip->valid = 0;
    80003988:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000398c:	854a                	mv	a0,s2
    8000398e:	00001097          	auipc	ra,0x1
    80003992:	ace080e7          	jalr	-1330(ra) # 8000445c <releasesleep>
    acquire(&icache.lock);
    80003996:	0001c517          	auipc	a0,0x1c
    8000399a:	4ca50513          	addi	a0,a0,1226 # 8001fe60 <icache>
    8000399e:	ffffd097          	auipc	ra,0xffffd
    800039a2:	2ac080e7          	jalr	684(ra) # 80000c4a <acquire>
    800039a6:	b741                	j	80003926 <iput+0x26>

00000000800039a8 <iunlockput>:
{
    800039a8:	1101                	addi	sp,sp,-32
    800039aa:	ec06                	sd	ra,24(sp)
    800039ac:	e822                	sd	s0,16(sp)
    800039ae:	e426                	sd	s1,8(sp)
    800039b0:	1000                	addi	s0,sp,32
    800039b2:	84aa                	mv	s1,a0
  iunlock(ip);
    800039b4:	00000097          	auipc	ra,0x0
    800039b8:	e54080e7          	jalr	-428(ra) # 80003808 <iunlock>
  iput(ip);
    800039bc:	8526                	mv	a0,s1
    800039be:	00000097          	auipc	ra,0x0
    800039c2:	f42080e7          	jalr	-190(ra) # 80003900 <iput>
}
    800039c6:	60e2                	ld	ra,24(sp)
    800039c8:	6442                	ld	s0,16(sp)
    800039ca:	64a2                	ld	s1,8(sp)
    800039cc:	6105                	addi	sp,sp,32
    800039ce:	8082                	ret

00000000800039d0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039d0:	1141                	addi	sp,sp,-16
    800039d2:	e422                	sd	s0,8(sp)
    800039d4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800039d6:	411c                	lw	a5,0(a0)
    800039d8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039da:	415c                	lw	a5,4(a0)
    800039dc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039de:	04451783          	lh	a5,68(a0)
    800039e2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039e6:	04a51783          	lh	a5,74(a0)
    800039ea:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039ee:	04c56783          	lwu	a5,76(a0)
    800039f2:	e99c                	sd	a5,16(a1)
}
    800039f4:	6422                	ld	s0,8(sp)
    800039f6:	0141                	addi	sp,sp,16
    800039f8:	8082                	ret

00000000800039fa <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039fa:	457c                	lw	a5,76(a0)
    800039fc:	0ed7e863          	bltu	a5,a3,80003aec <readi+0xf2>
{
    80003a00:	7159                	addi	sp,sp,-112
    80003a02:	f486                	sd	ra,104(sp)
    80003a04:	f0a2                	sd	s0,96(sp)
    80003a06:	eca6                	sd	s1,88(sp)
    80003a08:	e8ca                	sd	s2,80(sp)
    80003a0a:	e4ce                	sd	s3,72(sp)
    80003a0c:	e0d2                	sd	s4,64(sp)
    80003a0e:	fc56                	sd	s5,56(sp)
    80003a10:	f85a                	sd	s6,48(sp)
    80003a12:	f45e                	sd	s7,40(sp)
    80003a14:	f062                	sd	s8,32(sp)
    80003a16:	ec66                	sd	s9,24(sp)
    80003a18:	e86a                	sd	s10,16(sp)
    80003a1a:	e46e                	sd	s11,8(sp)
    80003a1c:	1880                	addi	s0,sp,112
    80003a1e:	8baa                	mv	s7,a0
    80003a20:	8c2e                	mv	s8,a1
    80003a22:	8ab2                	mv	s5,a2
    80003a24:	84b6                	mv	s1,a3
    80003a26:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a28:	9f35                	addw	a4,a4,a3
    return 0;
    80003a2a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a2c:	08d76f63          	bltu	a4,a3,80003aca <readi+0xd0>
  if(off + n > ip->size)
    80003a30:	00e7f463          	bgeu	a5,a4,80003a38 <readi+0x3e>
    n = ip->size - off;
    80003a34:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a38:	0a0b0863          	beqz	s6,80003ae8 <readi+0xee>
    80003a3c:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a3e:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a42:	5cfd                	li	s9,-1
    80003a44:	a82d                	j	80003a7e <readi+0x84>
    80003a46:	020a1d93          	slli	s11,s4,0x20
    80003a4a:	020ddd93          	srli	s11,s11,0x20
    80003a4e:	05890613          	addi	a2,s2,88
    80003a52:	86ee                	mv	a3,s11
    80003a54:	963a                	add	a2,a2,a4
    80003a56:	85d6                	mv	a1,s5
    80003a58:	8562                	mv	a0,s8
    80003a5a:	fffff097          	auipc	ra,0xfffff
    80003a5e:	a32080e7          	jalr	-1486(ra) # 8000248c <either_copyout>
    80003a62:	05950d63          	beq	a0,s9,80003abc <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003a66:	854a                	mv	a0,s2
    80003a68:	fffff097          	auipc	ra,0xfffff
    80003a6c:	60c080e7          	jalr	1548(ra) # 80003074 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a70:	013a09bb          	addw	s3,s4,s3
    80003a74:	009a04bb          	addw	s1,s4,s1
    80003a78:	9aee                	add	s5,s5,s11
    80003a7a:	0569f663          	bgeu	s3,s6,80003ac6 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003a7e:	000ba903          	lw	s2,0(s7)
    80003a82:	00a4d59b          	srliw	a1,s1,0xa
    80003a86:	855e                	mv	a0,s7
    80003a88:	00000097          	auipc	ra,0x0
    80003a8c:	8ac080e7          	jalr	-1876(ra) # 80003334 <bmap>
    80003a90:	0005059b          	sext.w	a1,a0
    80003a94:	854a                	mv	a0,s2
    80003a96:	fffff097          	auipc	ra,0xfffff
    80003a9a:	4ae080e7          	jalr	1198(ra) # 80002f44 <bread>
    80003a9e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aa0:	3ff4f713          	andi	a4,s1,1023
    80003aa4:	40ed07bb          	subw	a5,s10,a4
    80003aa8:	413b06bb          	subw	a3,s6,s3
    80003aac:	8a3e                	mv	s4,a5
    80003aae:	2781                	sext.w	a5,a5
    80003ab0:	0006861b          	sext.w	a2,a3
    80003ab4:	f8f679e3          	bgeu	a2,a5,80003a46 <readi+0x4c>
    80003ab8:	8a36                	mv	s4,a3
    80003aba:	b771                	j	80003a46 <readi+0x4c>
      brelse(bp);
    80003abc:	854a                	mv	a0,s2
    80003abe:	fffff097          	auipc	ra,0xfffff
    80003ac2:	5b6080e7          	jalr	1462(ra) # 80003074 <brelse>
  }
  return tot;
    80003ac6:	0009851b          	sext.w	a0,s3
}
    80003aca:	70a6                	ld	ra,104(sp)
    80003acc:	7406                	ld	s0,96(sp)
    80003ace:	64e6                	ld	s1,88(sp)
    80003ad0:	6946                	ld	s2,80(sp)
    80003ad2:	69a6                	ld	s3,72(sp)
    80003ad4:	6a06                	ld	s4,64(sp)
    80003ad6:	7ae2                	ld	s5,56(sp)
    80003ad8:	7b42                	ld	s6,48(sp)
    80003ada:	7ba2                	ld	s7,40(sp)
    80003adc:	7c02                	ld	s8,32(sp)
    80003ade:	6ce2                	ld	s9,24(sp)
    80003ae0:	6d42                	ld	s10,16(sp)
    80003ae2:	6da2                	ld	s11,8(sp)
    80003ae4:	6165                	addi	sp,sp,112
    80003ae6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ae8:	89da                	mv	s3,s6
    80003aea:	bff1                	j	80003ac6 <readi+0xcc>
    return 0;
    80003aec:	4501                	li	a0,0
}
    80003aee:	8082                	ret

0000000080003af0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003af0:	457c                	lw	a5,76(a0)
    80003af2:	10d7e663          	bltu	a5,a3,80003bfe <writei+0x10e>
{
    80003af6:	7159                	addi	sp,sp,-112
    80003af8:	f486                	sd	ra,104(sp)
    80003afa:	f0a2                	sd	s0,96(sp)
    80003afc:	eca6                	sd	s1,88(sp)
    80003afe:	e8ca                	sd	s2,80(sp)
    80003b00:	e4ce                	sd	s3,72(sp)
    80003b02:	e0d2                	sd	s4,64(sp)
    80003b04:	fc56                	sd	s5,56(sp)
    80003b06:	f85a                	sd	s6,48(sp)
    80003b08:	f45e                	sd	s7,40(sp)
    80003b0a:	f062                	sd	s8,32(sp)
    80003b0c:	ec66                	sd	s9,24(sp)
    80003b0e:	e86a                	sd	s10,16(sp)
    80003b10:	e46e                	sd	s11,8(sp)
    80003b12:	1880                	addi	s0,sp,112
    80003b14:	8baa                	mv	s7,a0
    80003b16:	8c2e                	mv	s8,a1
    80003b18:	8ab2                	mv	s5,a2
    80003b1a:	8936                	mv	s2,a3
    80003b1c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b1e:	00e687bb          	addw	a5,a3,a4
    80003b22:	0ed7e063          	bltu	a5,a3,80003c02 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b26:	00043737          	lui	a4,0x43
    80003b2a:	0cf76e63          	bltu	a4,a5,80003c06 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b2e:	0a0b0763          	beqz	s6,80003bdc <writei+0xec>
    80003b32:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b34:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b38:	5cfd                	li	s9,-1
    80003b3a:	a091                	j	80003b7e <writei+0x8e>
    80003b3c:	02099d93          	slli	s11,s3,0x20
    80003b40:	020ddd93          	srli	s11,s11,0x20
    80003b44:	05848513          	addi	a0,s1,88
    80003b48:	86ee                	mv	a3,s11
    80003b4a:	8656                	mv	a2,s5
    80003b4c:	85e2                	mv	a1,s8
    80003b4e:	953a                	add	a0,a0,a4
    80003b50:	fffff097          	auipc	ra,0xfffff
    80003b54:	992080e7          	jalr	-1646(ra) # 800024e2 <either_copyin>
    80003b58:	07950263          	beq	a0,s9,80003bbc <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b5c:	8526                	mv	a0,s1
    80003b5e:	00000097          	auipc	ra,0x0
    80003b62:	782080e7          	jalr	1922(ra) # 800042e0 <log_write>
    brelse(bp);
    80003b66:	8526                	mv	a0,s1
    80003b68:	fffff097          	auipc	ra,0xfffff
    80003b6c:	50c080e7          	jalr	1292(ra) # 80003074 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b70:	01498a3b          	addw	s4,s3,s4
    80003b74:	0129893b          	addw	s2,s3,s2
    80003b78:	9aee                	add	s5,s5,s11
    80003b7a:	056a7663          	bgeu	s4,s6,80003bc6 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b7e:	000ba483          	lw	s1,0(s7)
    80003b82:	00a9559b          	srliw	a1,s2,0xa
    80003b86:	855e                	mv	a0,s7
    80003b88:	fffff097          	auipc	ra,0xfffff
    80003b8c:	7ac080e7          	jalr	1964(ra) # 80003334 <bmap>
    80003b90:	0005059b          	sext.w	a1,a0
    80003b94:	8526                	mv	a0,s1
    80003b96:	fffff097          	auipc	ra,0xfffff
    80003b9a:	3ae080e7          	jalr	942(ra) # 80002f44 <bread>
    80003b9e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ba0:	3ff97713          	andi	a4,s2,1023
    80003ba4:	40ed07bb          	subw	a5,s10,a4
    80003ba8:	414b06bb          	subw	a3,s6,s4
    80003bac:	89be                	mv	s3,a5
    80003bae:	2781                	sext.w	a5,a5
    80003bb0:	0006861b          	sext.w	a2,a3
    80003bb4:	f8f674e3          	bgeu	a2,a5,80003b3c <writei+0x4c>
    80003bb8:	89b6                	mv	s3,a3
    80003bba:	b749                	j	80003b3c <writei+0x4c>
      brelse(bp);
    80003bbc:	8526                	mv	a0,s1
    80003bbe:	fffff097          	auipc	ra,0xfffff
    80003bc2:	4b6080e7          	jalr	1206(ra) # 80003074 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003bc6:	04cba783          	lw	a5,76(s7)
    80003bca:	0127f463          	bgeu	a5,s2,80003bd2 <writei+0xe2>
      ip->size = off;
    80003bce:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003bd2:	855e                	mv	a0,s7
    80003bd4:	00000097          	auipc	ra,0x0
    80003bd8:	aa6080e7          	jalr	-1370(ra) # 8000367a <iupdate>
  }

  return n;
    80003bdc:	000b051b          	sext.w	a0,s6
}
    80003be0:	70a6                	ld	ra,104(sp)
    80003be2:	7406                	ld	s0,96(sp)
    80003be4:	64e6                	ld	s1,88(sp)
    80003be6:	6946                	ld	s2,80(sp)
    80003be8:	69a6                	ld	s3,72(sp)
    80003bea:	6a06                	ld	s4,64(sp)
    80003bec:	7ae2                	ld	s5,56(sp)
    80003bee:	7b42                	ld	s6,48(sp)
    80003bf0:	7ba2                	ld	s7,40(sp)
    80003bf2:	7c02                	ld	s8,32(sp)
    80003bf4:	6ce2                	ld	s9,24(sp)
    80003bf6:	6d42                	ld	s10,16(sp)
    80003bf8:	6da2                	ld	s11,8(sp)
    80003bfa:	6165                	addi	sp,sp,112
    80003bfc:	8082                	ret
    return -1;
    80003bfe:	557d                	li	a0,-1
}
    80003c00:	8082                	ret
    return -1;
    80003c02:	557d                	li	a0,-1
    80003c04:	bff1                	j	80003be0 <writei+0xf0>
    return -1;
    80003c06:	557d                	li	a0,-1
    80003c08:	bfe1                	j	80003be0 <writei+0xf0>

0000000080003c0a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c0a:	1141                	addi	sp,sp,-16
    80003c0c:	e406                	sd	ra,8(sp)
    80003c0e:	e022                	sd	s0,0(sp)
    80003c10:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c12:	4639                	li	a2,14
    80003c14:	ffffd097          	auipc	ra,0xffffd
    80003c18:	20a080e7          	jalr	522(ra) # 80000e1e <strncmp>
}
    80003c1c:	60a2                	ld	ra,8(sp)
    80003c1e:	6402                	ld	s0,0(sp)
    80003c20:	0141                	addi	sp,sp,16
    80003c22:	8082                	ret

0000000080003c24 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c24:	7139                	addi	sp,sp,-64
    80003c26:	fc06                	sd	ra,56(sp)
    80003c28:	f822                	sd	s0,48(sp)
    80003c2a:	f426                	sd	s1,40(sp)
    80003c2c:	f04a                	sd	s2,32(sp)
    80003c2e:	ec4e                	sd	s3,24(sp)
    80003c30:	e852                	sd	s4,16(sp)
    80003c32:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c34:	04451703          	lh	a4,68(a0)
    80003c38:	4785                	li	a5,1
    80003c3a:	00f71a63          	bne	a4,a5,80003c4e <dirlookup+0x2a>
    80003c3e:	892a                	mv	s2,a0
    80003c40:	89ae                	mv	s3,a1
    80003c42:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c44:	457c                	lw	a5,76(a0)
    80003c46:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c48:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c4a:	e79d                	bnez	a5,80003c78 <dirlookup+0x54>
    80003c4c:	a8a5                	j	80003cc4 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c4e:	00005517          	auipc	a0,0x5
    80003c52:	b0a50513          	addi	a0,a0,-1270 # 80008758 <syscall_list+0x1a8>
    80003c56:	ffffd097          	auipc	ra,0xffffd
    80003c5a:	8f0080e7          	jalr	-1808(ra) # 80000546 <panic>
      panic("dirlookup read");
    80003c5e:	00005517          	auipc	a0,0x5
    80003c62:	b1250513          	addi	a0,a0,-1262 # 80008770 <syscall_list+0x1c0>
    80003c66:	ffffd097          	auipc	ra,0xffffd
    80003c6a:	8e0080e7          	jalr	-1824(ra) # 80000546 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c6e:	24c1                	addiw	s1,s1,16
    80003c70:	04c92783          	lw	a5,76(s2)
    80003c74:	04f4f763          	bgeu	s1,a5,80003cc2 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c78:	4741                	li	a4,16
    80003c7a:	86a6                	mv	a3,s1
    80003c7c:	fc040613          	addi	a2,s0,-64
    80003c80:	4581                	li	a1,0
    80003c82:	854a                	mv	a0,s2
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	d76080e7          	jalr	-650(ra) # 800039fa <readi>
    80003c8c:	47c1                	li	a5,16
    80003c8e:	fcf518e3          	bne	a0,a5,80003c5e <dirlookup+0x3a>
    if(de.inum == 0)
    80003c92:	fc045783          	lhu	a5,-64(s0)
    80003c96:	dfe1                	beqz	a5,80003c6e <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c98:	fc240593          	addi	a1,s0,-62
    80003c9c:	854e                	mv	a0,s3
    80003c9e:	00000097          	auipc	ra,0x0
    80003ca2:	f6c080e7          	jalr	-148(ra) # 80003c0a <namecmp>
    80003ca6:	f561                	bnez	a0,80003c6e <dirlookup+0x4a>
      if(poff)
    80003ca8:	000a0463          	beqz	s4,80003cb0 <dirlookup+0x8c>
        *poff = off;
    80003cac:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cb0:	fc045583          	lhu	a1,-64(s0)
    80003cb4:	00092503          	lw	a0,0(s2)
    80003cb8:	fffff097          	auipc	ra,0xfffff
    80003cbc:	758080e7          	jalr	1880(ra) # 80003410 <iget>
    80003cc0:	a011                	j	80003cc4 <dirlookup+0xa0>
  return 0;
    80003cc2:	4501                	li	a0,0
}
    80003cc4:	70e2                	ld	ra,56(sp)
    80003cc6:	7442                	ld	s0,48(sp)
    80003cc8:	74a2                	ld	s1,40(sp)
    80003cca:	7902                	ld	s2,32(sp)
    80003ccc:	69e2                	ld	s3,24(sp)
    80003cce:	6a42                	ld	s4,16(sp)
    80003cd0:	6121                	addi	sp,sp,64
    80003cd2:	8082                	ret

0000000080003cd4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cd4:	711d                	addi	sp,sp,-96
    80003cd6:	ec86                	sd	ra,88(sp)
    80003cd8:	e8a2                	sd	s0,80(sp)
    80003cda:	e4a6                	sd	s1,72(sp)
    80003cdc:	e0ca                	sd	s2,64(sp)
    80003cde:	fc4e                	sd	s3,56(sp)
    80003ce0:	f852                	sd	s4,48(sp)
    80003ce2:	f456                	sd	s5,40(sp)
    80003ce4:	f05a                	sd	s6,32(sp)
    80003ce6:	ec5e                	sd	s7,24(sp)
    80003ce8:	e862                	sd	s8,16(sp)
    80003cea:	e466                	sd	s9,8(sp)
    80003cec:	e06a                	sd	s10,0(sp)
    80003cee:	1080                	addi	s0,sp,96
    80003cf0:	84aa                	mv	s1,a0
    80003cf2:	8b2e                	mv	s6,a1
    80003cf4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cf6:	00054703          	lbu	a4,0(a0)
    80003cfa:	02f00793          	li	a5,47
    80003cfe:	02f70363          	beq	a4,a5,80003d24 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d02:	ffffe097          	auipc	ra,0xffffe
    80003d06:	d14080e7          	jalr	-748(ra) # 80001a16 <myproc>
    80003d0a:	15053503          	ld	a0,336(a0)
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	9fa080e7          	jalr	-1542(ra) # 80003708 <idup>
    80003d16:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d18:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d1c:	4cb5                	li	s9,13
  len = path - s;
    80003d1e:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d20:	4c05                	li	s8,1
    80003d22:	a87d                	j	80003de0 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003d24:	4585                	li	a1,1
    80003d26:	4505                	li	a0,1
    80003d28:	fffff097          	auipc	ra,0xfffff
    80003d2c:	6e8080e7          	jalr	1768(ra) # 80003410 <iget>
    80003d30:	8a2a                	mv	s4,a0
    80003d32:	b7dd                	j	80003d18 <namex+0x44>
      iunlockput(ip);
    80003d34:	8552                	mv	a0,s4
    80003d36:	00000097          	auipc	ra,0x0
    80003d3a:	c72080e7          	jalr	-910(ra) # 800039a8 <iunlockput>
      return 0;
    80003d3e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d40:	8552                	mv	a0,s4
    80003d42:	60e6                	ld	ra,88(sp)
    80003d44:	6446                	ld	s0,80(sp)
    80003d46:	64a6                	ld	s1,72(sp)
    80003d48:	6906                	ld	s2,64(sp)
    80003d4a:	79e2                	ld	s3,56(sp)
    80003d4c:	7a42                	ld	s4,48(sp)
    80003d4e:	7aa2                	ld	s5,40(sp)
    80003d50:	7b02                	ld	s6,32(sp)
    80003d52:	6be2                	ld	s7,24(sp)
    80003d54:	6c42                	ld	s8,16(sp)
    80003d56:	6ca2                	ld	s9,8(sp)
    80003d58:	6d02                	ld	s10,0(sp)
    80003d5a:	6125                	addi	sp,sp,96
    80003d5c:	8082                	ret
      iunlock(ip);
    80003d5e:	8552                	mv	a0,s4
    80003d60:	00000097          	auipc	ra,0x0
    80003d64:	aa8080e7          	jalr	-1368(ra) # 80003808 <iunlock>
      return ip;
    80003d68:	bfe1                	j	80003d40 <namex+0x6c>
      iunlockput(ip);
    80003d6a:	8552                	mv	a0,s4
    80003d6c:	00000097          	auipc	ra,0x0
    80003d70:	c3c080e7          	jalr	-964(ra) # 800039a8 <iunlockput>
      return 0;
    80003d74:	8a4e                	mv	s4,s3
    80003d76:	b7e9                	j	80003d40 <namex+0x6c>
  len = path - s;
    80003d78:	40998633          	sub	a2,s3,s1
    80003d7c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003d80:	09acd863          	bge	s9,s10,80003e10 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003d84:	4639                	li	a2,14
    80003d86:	85a6                	mv	a1,s1
    80003d88:	8556                	mv	a0,s5
    80003d8a:	ffffd097          	auipc	ra,0xffffd
    80003d8e:	018080e7          	jalr	24(ra) # 80000da2 <memmove>
    80003d92:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d94:	0004c783          	lbu	a5,0(s1)
    80003d98:	01279763          	bne	a5,s2,80003da6 <namex+0xd2>
    path++;
    80003d9c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003d9e:	0004c783          	lbu	a5,0(s1)
    80003da2:	ff278de3          	beq	a5,s2,80003d9c <namex+0xc8>
    ilock(ip);
    80003da6:	8552                	mv	a0,s4
    80003da8:	00000097          	auipc	ra,0x0
    80003dac:	99e080e7          	jalr	-1634(ra) # 80003746 <ilock>
    if(ip->type != T_DIR){
    80003db0:	044a1783          	lh	a5,68(s4)
    80003db4:	f98790e3          	bne	a5,s8,80003d34 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003db8:	000b0563          	beqz	s6,80003dc2 <namex+0xee>
    80003dbc:	0004c783          	lbu	a5,0(s1)
    80003dc0:	dfd9                	beqz	a5,80003d5e <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dc2:	865e                	mv	a2,s7
    80003dc4:	85d6                	mv	a1,s5
    80003dc6:	8552                	mv	a0,s4
    80003dc8:	00000097          	auipc	ra,0x0
    80003dcc:	e5c080e7          	jalr	-420(ra) # 80003c24 <dirlookup>
    80003dd0:	89aa                	mv	s3,a0
    80003dd2:	dd41                	beqz	a0,80003d6a <namex+0x96>
    iunlockput(ip);
    80003dd4:	8552                	mv	a0,s4
    80003dd6:	00000097          	auipc	ra,0x0
    80003dda:	bd2080e7          	jalr	-1070(ra) # 800039a8 <iunlockput>
    ip = next;
    80003dde:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003de0:	0004c783          	lbu	a5,0(s1)
    80003de4:	01279763          	bne	a5,s2,80003df2 <namex+0x11e>
    path++;
    80003de8:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003dea:	0004c783          	lbu	a5,0(s1)
    80003dee:	ff278de3          	beq	a5,s2,80003de8 <namex+0x114>
  if(*path == 0)
    80003df2:	cb9d                	beqz	a5,80003e28 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003df4:	0004c783          	lbu	a5,0(s1)
    80003df8:	89a6                	mv	s3,s1
  len = path - s;
    80003dfa:	8d5e                	mv	s10,s7
    80003dfc:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003dfe:	01278963          	beq	a5,s2,80003e10 <namex+0x13c>
    80003e02:	dbbd                	beqz	a5,80003d78 <namex+0xa4>
    path++;
    80003e04:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e06:	0009c783          	lbu	a5,0(s3)
    80003e0a:	ff279ce3          	bne	a5,s2,80003e02 <namex+0x12e>
    80003e0e:	b7ad                	j	80003d78 <namex+0xa4>
    memmove(name, s, len);
    80003e10:	2601                	sext.w	a2,a2
    80003e12:	85a6                	mv	a1,s1
    80003e14:	8556                	mv	a0,s5
    80003e16:	ffffd097          	auipc	ra,0xffffd
    80003e1a:	f8c080e7          	jalr	-116(ra) # 80000da2 <memmove>
    name[len] = 0;
    80003e1e:	9d56                	add	s10,s10,s5
    80003e20:	000d0023          	sb	zero,0(s10)
    80003e24:	84ce                	mv	s1,s3
    80003e26:	b7bd                	j	80003d94 <namex+0xc0>
  if(nameiparent){
    80003e28:	f00b0ce3          	beqz	s6,80003d40 <namex+0x6c>
    iput(ip);
    80003e2c:	8552                	mv	a0,s4
    80003e2e:	00000097          	auipc	ra,0x0
    80003e32:	ad2080e7          	jalr	-1326(ra) # 80003900 <iput>
    return 0;
    80003e36:	4a01                	li	s4,0
    80003e38:	b721                	j	80003d40 <namex+0x6c>

0000000080003e3a <dirlink>:
{
    80003e3a:	7139                	addi	sp,sp,-64
    80003e3c:	fc06                	sd	ra,56(sp)
    80003e3e:	f822                	sd	s0,48(sp)
    80003e40:	f426                	sd	s1,40(sp)
    80003e42:	f04a                	sd	s2,32(sp)
    80003e44:	ec4e                	sd	s3,24(sp)
    80003e46:	e852                	sd	s4,16(sp)
    80003e48:	0080                	addi	s0,sp,64
    80003e4a:	892a                	mv	s2,a0
    80003e4c:	8a2e                	mv	s4,a1
    80003e4e:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e50:	4601                	li	a2,0
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	dd2080e7          	jalr	-558(ra) # 80003c24 <dirlookup>
    80003e5a:	e93d                	bnez	a0,80003ed0 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e5c:	04c92483          	lw	s1,76(s2)
    80003e60:	c49d                	beqz	s1,80003e8e <dirlink+0x54>
    80003e62:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e64:	4741                	li	a4,16
    80003e66:	86a6                	mv	a3,s1
    80003e68:	fc040613          	addi	a2,s0,-64
    80003e6c:	4581                	li	a1,0
    80003e6e:	854a                	mv	a0,s2
    80003e70:	00000097          	auipc	ra,0x0
    80003e74:	b8a080e7          	jalr	-1142(ra) # 800039fa <readi>
    80003e78:	47c1                	li	a5,16
    80003e7a:	06f51163          	bne	a0,a5,80003edc <dirlink+0xa2>
    if(de.inum == 0)
    80003e7e:	fc045783          	lhu	a5,-64(s0)
    80003e82:	c791                	beqz	a5,80003e8e <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e84:	24c1                	addiw	s1,s1,16
    80003e86:	04c92783          	lw	a5,76(s2)
    80003e8a:	fcf4ede3          	bltu	s1,a5,80003e64 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e8e:	4639                	li	a2,14
    80003e90:	85d2                	mv	a1,s4
    80003e92:	fc240513          	addi	a0,s0,-62
    80003e96:	ffffd097          	auipc	ra,0xffffd
    80003e9a:	fc4080e7          	jalr	-60(ra) # 80000e5a <strncpy>
  de.inum = inum;
    80003e9e:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ea2:	4741                	li	a4,16
    80003ea4:	86a6                	mv	a3,s1
    80003ea6:	fc040613          	addi	a2,s0,-64
    80003eaa:	4581                	li	a1,0
    80003eac:	854a                	mv	a0,s2
    80003eae:	00000097          	auipc	ra,0x0
    80003eb2:	c42080e7          	jalr	-958(ra) # 80003af0 <writei>
    80003eb6:	872a                	mv	a4,a0
    80003eb8:	47c1                	li	a5,16
  return 0;
    80003eba:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ebc:	02f71863          	bne	a4,a5,80003eec <dirlink+0xb2>
}
    80003ec0:	70e2                	ld	ra,56(sp)
    80003ec2:	7442                	ld	s0,48(sp)
    80003ec4:	74a2                	ld	s1,40(sp)
    80003ec6:	7902                	ld	s2,32(sp)
    80003ec8:	69e2                	ld	s3,24(sp)
    80003eca:	6a42                	ld	s4,16(sp)
    80003ecc:	6121                	addi	sp,sp,64
    80003ece:	8082                	ret
    iput(ip);
    80003ed0:	00000097          	auipc	ra,0x0
    80003ed4:	a30080e7          	jalr	-1488(ra) # 80003900 <iput>
    return -1;
    80003ed8:	557d                	li	a0,-1
    80003eda:	b7dd                	j	80003ec0 <dirlink+0x86>
      panic("dirlink read");
    80003edc:	00005517          	auipc	a0,0x5
    80003ee0:	8a450513          	addi	a0,a0,-1884 # 80008780 <syscall_list+0x1d0>
    80003ee4:	ffffc097          	auipc	ra,0xffffc
    80003ee8:	662080e7          	jalr	1634(ra) # 80000546 <panic>
    panic("dirlink");
    80003eec:	00005517          	auipc	a0,0x5
    80003ef0:	9ac50513          	addi	a0,a0,-1620 # 80008898 <syscall_list+0x2e8>
    80003ef4:	ffffc097          	auipc	ra,0xffffc
    80003ef8:	652080e7          	jalr	1618(ra) # 80000546 <panic>

0000000080003efc <namei>:

struct inode*
namei(char *path)
{
    80003efc:	1101                	addi	sp,sp,-32
    80003efe:	ec06                	sd	ra,24(sp)
    80003f00:	e822                	sd	s0,16(sp)
    80003f02:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f04:	fe040613          	addi	a2,s0,-32
    80003f08:	4581                	li	a1,0
    80003f0a:	00000097          	auipc	ra,0x0
    80003f0e:	dca080e7          	jalr	-566(ra) # 80003cd4 <namex>
}
    80003f12:	60e2                	ld	ra,24(sp)
    80003f14:	6442                	ld	s0,16(sp)
    80003f16:	6105                	addi	sp,sp,32
    80003f18:	8082                	ret

0000000080003f1a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f1a:	1141                	addi	sp,sp,-16
    80003f1c:	e406                	sd	ra,8(sp)
    80003f1e:	e022                	sd	s0,0(sp)
    80003f20:	0800                	addi	s0,sp,16
    80003f22:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f24:	4585                	li	a1,1
    80003f26:	00000097          	auipc	ra,0x0
    80003f2a:	dae080e7          	jalr	-594(ra) # 80003cd4 <namex>
}
    80003f2e:	60a2                	ld	ra,8(sp)
    80003f30:	6402                	ld	s0,0(sp)
    80003f32:	0141                	addi	sp,sp,16
    80003f34:	8082                	ret

0000000080003f36 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f36:	1101                	addi	sp,sp,-32
    80003f38:	ec06                	sd	ra,24(sp)
    80003f3a:	e822                	sd	s0,16(sp)
    80003f3c:	e426                	sd	s1,8(sp)
    80003f3e:	e04a                	sd	s2,0(sp)
    80003f40:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f42:	0001e917          	auipc	s2,0x1e
    80003f46:	9c690913          	addi	s2,s2,-1594 # 80021908 <log>
    80003f4a:	01892583          	lw	a1,24(s2)
    80003f4e:	02892503          	lw	a0,40(s2)
    80003f52:	fffff097          	auipc	ra,0xfffff
    80003f56:	ff2080e7          	jalr	-14(ra) # 80002f44 <bread>
    80003f5a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f5c:	02c92683          	lw	a3,44(s2)
    80003f60:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f62:	02d05863          	blez	a3,80003f92 <write_head+0x5c>
    80003f66:	0001e797          	auipc	a5,0x1e
    80003f6a:	9d278793          	addi	a5,a5,-1582 # 80021938 <log+0x30>
    80003f6e:	05c50713          	addi	a4,a0,92
    80003f72:	36fd                	addiw	a3,a3,-1
    80003f74:	02069613          	slli	a2,a3,0x20
    80003f78:	01e65693          	srli	a3,a2,0x1e
    80003f7c:	0001e617          	auipc	a2,0x1e
    80003f80:	9c060613          	addi	a2,a2,-1600 # 8002193c <log+0x34>
    80003f84:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003f86:	4390                	lw	a2,0(a5)
    80003f88:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f8a:	0791                	addi	a5,a5,4
    80003f8c:	0711                	addi	a4,a4,4
    80003f8e:	fed79ce3          	bne	a5,a3,80003f86 <write_head+0x50>
  }
  bwrite(buf);
    80003f92:	8526                	mv	a0,s1
    80003f94:	fffff097          	auipc	ra,0xfffff
    80003f98:	0a2080e7          	jalr	162(ra) # 80003036 <bwrite>
  brelse(buf);
    80003f9c:	8526                	mv	a0,s1
    80003f9e:	fffff097          	auipc	ra,0xfffff
    80003fa2:	0d6080e7          	jalr	214(ra) # 80003074 <brelse>
}
    80003fa6:	60e2                	ld	ra,24(sp)
    80003fa8:	6442                	ld	s0,16(sp)
    80003faa:	64a2                	ld	s1,8(sp)
    80003fac:	6902                	ld	s2,0(sp)
    80003fae:	6105                	addi	sp,sp,32
    80003fb0:	8082                	ret

0000000080003fb2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fb2:	0001e797          	auipc	a5,0x1e
    80003fb6:	9827a783          	lw	a5,-1662(a5) # 80021934 <log+0x2c>
    80003fba:	0af05663          	blez	a5,80004066 <install_trans+0xb4>
{
    80003fbe:	7139                	addi	sp,sp,-64
    80003fc0:	fc06                	sd	ra,56(sp)
    80003fc2:	f822                	sd	s0,48(sp)
    80003fc4:	f426                	sd	s1,40(sp)
    80003fc6:	f04a                	sd	s2,32(sp)
    80003fc8:	ec4e                	sd	s3,24(sp)
    80003fca:	e852                	sd	s4,16(sp)
    80003fcc:	e456                	sd	s5,8(sp)
    80003fce:	0080                	addi	s0,sp,64
    80003fd0:	0001ea97          	auipc	s5,0x1e
    80003fd4:	968a8a93          	addi	s5,s5,-1688 # 80021938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fd8:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fda:	0001e997          	auipc	s3,0x1e
    80003fde:	92e98993          	addi	s3,s3,-1746 # 80021908 <log>
    80003fe2:	0189a583          	lw	a1,24(s3)
    80003fe6:	014585bb          	addw	a1,a1,s4
    80003fea:	2585                	addiw	a1,a1,1
    80003fec:	0289a503          	lw	a0,40(s3)
    80003ff0:	fffff097          	auipc	ra,0xfffff
    80003ff4:	f54080e7          	jalr	-172(ra) # 80002f44 <bread>
    80003ff8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003ffa:	000aa583          	lw	a1,0(s5)
    80003ffe:	0289a503          	lw	a0,40(s3)
    80004002:	fffff097          	auipc	ra,0xfffff
    80004006:	f42080e7          	jalr	-190(ra) # 80002f44 <bread>
    8000400a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000400c:	40000613          	li	a2,1024
    80004010:	05890593          	addi	a1,s2,88
    80004014:	05850513          	addi	a0,a0,88
    80004018:	ffffd097          	auipc	ra,0xffffd
    8000401c:	d8a080e7          	jalr	-630(ra) # 80000da2 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004020:	8526                	mv	a0,s1
    80004022:	fffff097          	auipc	ra,0xfffff
    80004026:	014080e7          	jalr	20(ra) # 80003036 <bwrite>
    bunpin(dbuf);
    8000402a:	8526                	mv	a0,s1
    8000402c:	fffff097          	auipc	ra,0xfffff
    80004030:	122080e7          	jalr	290(ra) # 8000314e <bunpin>
    brelse(lbuf);
    80004034:	854a                	mv	a0,s2
    80004036:	fffff097          	auipc	ra,0xfffff
    8000403a:	03e080e7          	jalr	62(ra) # 80003074 <brelse>
    brelse(dbuf);
    8000403e:	8526                	mv	a0,s1
    80004040:	fffff097          	auipc	ra,0xfffff
    80004044:	034080e7          	jalr	52(ra) # 80003074 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004048:	2a05                	addiw	s4,s4,1
    8000404a:	0a91                	addi	s5,s5,4
    8000404c:	02c9a783          	lw	a5,44(s3)
    80004050:	f8fa49e3          	blt	s4,a5,80003fe2 <install_trans+0x30>
}
    80004054:	70e2                	ld	ra,56(sp)
    80004056:	7442                	ld	s0,48(sp)
    80004058:	74a2                	ld	s1,40(sp)
    8000405a:	7902                	ld	s2,32(sp)
    8000405c:	69e2                	ld	s3,24(sp)
    8000405e:	6a42                	ld	s4,16(sp)
    80004060:	6aa2                	ld	s5,8(sp)
    80004062:	6121                	addi	sp,sp,64
    80004064:	8082                	ret
    80004066:	8082                	ret

0000000080004068 <initlog>:
{
    80004068:	7179                	addi	sp,sp,-48
    8000406a:	f406                	sd	ra,40(sp)
    8000406c:	f022                	sd	s0,32(sp)
    8000406e:	ec26                	sd	s1,24(sp)
    80004070:	e84a                	sd	s2,16(sp)
    80004072:	e44e                	sd	s3,8(sp)
    80004074:	1800                	addi	s0,sp,48
    80004076:	892a                	mv	s2,a0
    80004078:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000407a:	0001e497          	auipc	s1,0x1e
    8000407e:	88e48493          	addi	s1,s1,-1906 # 80021908 <log>
    80004082:	00004597          	auipc	a1,0x4
    80004086:	70e58593          	addi	a1,a1,1806 # 80008790 <syscall_list+0x1e0>
    8000408a:	8526                	mv	a0,s1
    8000408c:	ffffd097          	auipc	ra,0xffffd
    80004090:	b2e080e7          	jalr	-1234(ra) # 80000bba <initlock>
  log.start = sb->logstart;
    80004094:	0149a583          	lw	a1,20(s3)
    80004098:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000409a:	0109a783          	lw	a5,16(s3)
    8000409e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040a0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040a4:	854a                	mv	a0,s2
    800040a6:	fffff097          	auipc	ra,0xfffff
    800040aa:	e9e080e7          	jalr	-354(ra) # 80002f44 <bread>
  log.lh.n = lh->n;
    800040ae:	4d34                	lw	a3,88(a0)
    800040b0:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040b2:	02d05663          	blez	a3,800040de <initlog+0x76>
    800040b6:	05c50793          	addi	a5,a0,92
    800040ba:	0001e717          	auipc	a4,0x1e
    800040be:	87e70713          	addi	a4,a4,-1922 # 80021938 <log+0x30>
    800040c2:	36fd                	addiw	a3,a3,-1
    800040c4:	02069613          	slli	a2,a3,0x20
    800040c8:	01e65693          	srli	a3,a2,0x1e
    800040cc:	06050613          	addi	a2,a0,96
    800040d0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800040d2:	4390                	lw	a2,0(a5)
    800040d4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040d6:	0791                	addi	a5,a5,4
    800040d8:	0711                	addi	a4,a4,4
    800040da:	fed79ce3          	bne	a5,a3,800040d2 <initlog+0x6a>
  brelse(buf);
    800040de:	fffff097          	auipc	ra,0xfffff
    800040e2:	f96080e7          	jalr	-106(ra) # 80003074 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    800040e6:	00000097          	auipc	ra,0x0
    800040ea:	ecc080e7          	jalr	-308(ra) # 80003fb2 <install_trans>
  log.lh.n = 0;
    800040ee:	0001e797          	auipc	a5,0x1e
    800040f2:	8407a323          	sw	zero,-1978(a5) # 80021934 <log+0x2c>
  write_head(); // clear the log
    800040f6:	00000097          	auipc	ra,0x0
    800040fa:	e40080e7          	jalr	-448(ra) # 80003f36 <write_head>
}
    800040fe:	70a2                	ld	ra,40(sp)
    80004100:	7402                	ld	s0,32(sp)
    80004102:	64e2                	ld	s1,24(sp)
    80004104:	6942                	ld	s2,16(sp)
    80004106:	69a2                	ld	s3,8(sp)
    80004108:	6145                	addi	sp,sp,48
    8000410a:	8082                	ret

000000008000410c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000410c:	1101                	addi	sp,sp,-32
    8000410e:	ec06                	sd	ra,24(sp)
    80004110:	e822                	sd	s0,16(sp)
    80004112:	e426                	sd	s1,8(sp)
    80004114:	e04a                	sd	s2,0(sp)
    80004116:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004118:	0001d517          	auipc	a0,0x1d
    8000411c:	7f050513          	addi	a0,a0,2032 # 80021908 <log>
    80004120:	ffffd097          	auipc	ra,0xffffd
    80004124:	b2a080e7          	jalr	-1238(ra) # 80000c4a <acquire>
  while(1){
    if(log.committing){
    80004128:	0001d497          	auipc	s1,0x1d
    8000412c:	7e048493          	addi	s1,s1,2016 # 80021908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004130:	4979                	li	s2,30
    80004132:	a039                	j	80004140 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004134:	85a6                	mv	a1,s1
    80004136:	8526                	mv	a0,s1
    80004138:	ffffe097          	auipc	ra,0xffffe
    8000413c:	0fa080e7          	jalr	250(ra) # 80002232 <sleep>
    if(log.committing){
    80004140:	50dc                	lw	a5,36(s1)
    80004142:	fbed                	bnez	a5,80004134 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004144:	5098                	lw	a4,32(s1)
    80004146:	2705                	addiw	a4,a4,1
    80004148:	0007069b          	sext.w	a3,a4
    8000414c:	0027179b          	slliw	a5,a4,0x2
    80004150:	9fb9                	addw	a5,a5,a4
    80004152:	0017979b          	slliw	a5,a5,0x1
    80004156:	54d8                	lw	a4,44(s1)
    80004158:	9fb9                	addw	a5,a5,a4
    8000415a:	00f95963          	bge	s2,a5,8000416c <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000415e:	85a6                	mv	a1,s1
    80004160:	8526                	mv	a0,s1
    80004162:	ffffe097          	auipc	ra,0xffffe
    80004166:	0d0080e7          	jalr	208(ra) # 80002232 <sleep>
    8000416a:	bfd9                	j	80004140 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000416c:	0001d517          	auipc	a0,0x1d
    80004170:	79c50513          	addi	a0,a0,1948 # 80021908 <log>
    80004174:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004176:	ffffd097          	auipc	ra,0xffffd
    8000417a:	b88080e7          	jalr	-1144(ra) # 80000cfe <release>
      break;
    }
  }
}
    8000417e:	60e2                	ld	ra,24(sp)
    80004180:	6442                	ld	s0,16(sp)
    80004182:	64a2                	ld	s1,8(sp)
    80004184:	6902                	ld	s2,0(sp)
    80004186:	6105                	addi	sp,sp,32
    80004188:	8082                	ret

000000008000418a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000418a:	7139                	addi	sp,sp,-64
    8000418c:	fc06                	sd	ra,56(sp)
    8000418e:	f822                	sd	s0,48(sp)
    80004190:	f426                	sd	s1,40(sp)
    80004192:	f04a                	sd	s2,32(sp)
    80004194:	ec4e                	sd	s3,24(sp)
    80004196:	e852                	sd	s4,16(sp)
    80004198:	e456                	sd	s5,8(sp)
    8000419a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000419c:	0001d497          	auipc	s1,0x1d
    800041a0:	76c48493          	addi	s1,s1,1900 # 80021908 <log>
    800041a4:	8526                	mv	a0,s1
    800041a6:	ffffd097          	auipc	ra,0xffffd
    800041aa:	aa4080e7          	jalr	-1372(ra) # 80000c4a <acquire>
  log.outstanding -= 1;
    800041ae:	509c                	lw	a5,32(s1)
    800041b0:	37fd                	addiw	a5,a5,-1
    800041b2:	0007891b          	sext.w	s2,a5
    800041b6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800041b8:	50dc                	lw	a5,36(s1)
    800041ba:	e7b9                	bnez	a5,80004208 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800041bc:	04091e63          	bnez	s2,80004218 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800041c0:	0001d497          	auipc	s1,0x1d
    800041c4:	74848493          	addi	s1,s1,1864 # 80021908 <log>
    800041c8:	4785                	li	a5,1
    800041ca:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041cc:	8526                	mv	a0,s1
    800041ce:	ffffd097          	auipc	ra,0xffffd
    800041d2:	b30080e7          	jalr	-1232(ra) # 80000cfe <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041d6:	54dc                	lw	a5,44(s1)
    800041d8:	06f04763          	bgtz	a5,80004246 <end_op+0xbc>
    acquire(&log.lock);
    800041dc:	0001d497          	auipc	s1,0x1d
    800041e0:	72c48493          	addi	s1,s1,1836 # 80021908 <log>
    800041e4:	8526                	mv	a0,s1
    800041e6:	ffffd097          	auipc	ra,0xffffd
    800041ea:	a64080e7          	jalr	-1436(ra) # 80000c4a <acquire>
    log.committing = 0;
    800041ee:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041f2:	8526                	mv	a0,s1
    800041f4:	ffffe097          	auipc	ra,0xffffe
    800041f8:	1be080e7          	jalr	446(ra) # 800023b2 <wakeup>
    release(&log.lock);
    800041fc:	8526                	mv	a0,s1
    800041fe:	ffffd097          	auipc	ra,0xffffd
    80004202:	b00080e7          	jalr	-1280(ra) # 80000cfe <release>
}
    80004206:	a03d                	j	80004234 <end_op+0xaa>
    panic("log.committing");
    80004208:	00004517          	auipc	a0,0x4
    8000420c:	59050513          	addi	a0,a0,1424 # 80008798 <syscall_list+0x1e8>
    80004210:	ffffc097          	auipc	ra,0xffffc
    80004214:	336080e7          	jalr	822(ra) # 80000546 <panic>
    wakeup(&log);
    80004218:	0001d497          	auipc	s1,0x1d
    8000421c:	6f048493          	addi	s1,s1,1776 # 80021908 <log>
    80004220:	8526                	mv	a0,s1
    80004222:	ffffe097          	auipc	ra,0xffffe
    80004226:	190080e7          	jalr	400(ra) # 800023b2 <wakeup>
  release(&log.lock);
    8000422a:	8526                	mv	a0,s1
    8000422c:	ffffd097          	auipc	ra,0xffffd
    80004230:	ad2080e7          	jalr	-1326(ra) # 80000cfe <release>
}
    80004234:	70e2                	ld	ra,56(sp)
    80004236:	7442                	ld	s0,48(sp)
    80004238:	74a2                	ld	s1,40(sp)
    8000423a:	7902                	ld	s2,32(sp)
    8000423c:	69e2                	ld	s3,24(sp)
    8000423e:	6a42                	ld	s4,16(sp)
    80004240:	6aa2                	ld	s5,8(sp)
    80004242:	6121                	addi	sp,sp,64
    80004244:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004246:	0001da97          	auipc	s5,0x1d
    8000424a:	6f2a8a93          	addi	s5,s5,1778 # 80021938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000424e:	0001da17          	auipc	s4,0x1d
    80004252:	6baa0a13          	addi	s4,s4,1722 # 80021908 <log>
    80004256:	018a2583          	lw	a1,24(s4)
    8000425a:	012585bb          	addw	a1,a1,s2
    8000425e:	2585                	addiw	a1,a1,1
    80004260:	028a2503          	lw	a0,40(s4)
    80004264:	fffff097          	auipc	ra,0xfffff
    80004268:	ce0080e7          	jalr	-800(ra) # 80002f44 <bread>
    8000426c:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000426e:	000aa583          	lw	a1,0(s5)
    80004272:	028a2503          	lw	a0,40(s4)
    80004276:	fffff097          	auipc	ra,0xfffff
    8000427a:	cce080e7          	jalr	-818(ra) # 80002f44 <bread>
    8000427e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004280:	40000613          	li	a2,1024
    80004284:	05850593          	addi	a1,a0,88
    80004288:	05848513          	addi	a0,s1,88
    8000428c:	ffffd097          	auipc	ra,0xffffd
    80004290:	b16080e7          	jalr	-1258(ra) # 80000da2 <memmove>
    bwrite(to);  // write the log
    80004294:	8526                	mv	a0,s1
    80004296:	fffff097          	auipc	ra,0xfffff
    8000429a:	da0080e7          	jalr	-608(ra) # 80003036 <bwrite>
    brelse(from);
    8000429e:	854e                	mv	a0,s3
    800042a0:	fffff097          	auipc	ra,0xfffff
    800042a4:	dd4080e7          	jalr	-556(ra) # 80003074 <brelse>
    brelse(to);
    800042a8:	8526                	mv	a0,s1
    800042aa:	fffff097          	auipc	ra,0xfffff
    800042ae:	dca080e7          	jalr	-566(ra) # 80003074 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042b2:	2905                	addiw	s2,s2,1
    800042b4:	0a91                	addi	s5,s5,4
    800042b6:	02ca2783          	lw	a5,44(s4)
    800042ba:	f8f94ee3          	blt	s2,a5,80004256 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800042be:	00000097          	auipc	ra,0x0
    800042c2:	c78080e7          	jalr	-904(ra) # 80003f36 <write_head>
    install_trans(); // Now install writes to home locations
    800042c6:	00000097          	auipc	ra,0x0
    800042ca:	cec080e7          	jalr	-788(ra) # 80003fb2 <install_trans>
    log.lh.n = 0;
    800042ce:	0001d797          	auipc	a5,0x1d
    800042d2:	6607a323          	sw	zero,1638(a5) # 80021934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042d6:	00000097          	auipc	ra,0x0
    800042da:	c60080e7          	jalr	-928(ra) # 80003f36 <write_head>
    800042de:	bdfd                	j	800041dc <end_op+0x52>

00000000800042e0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042e0:	1101                	addi	sp,sp,-32
    800042e2:	ec06                	sd	ra,24(sp)
    800042e4:	e822                	sd	s0,16(sp)
    800042e6:	e426                	sd	s1,8(sp)
    800042e8:	e04a                	sd	s2,0(sp)
    800042ea:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042ec:	0001d717          	auipc	a4,0x1d
    800042f0:	64872703          	lw	a4,1608(a4) # 80021934 <log+0x2c>
    800042f4:	47f5                	li	a5,29
    800042f6:	08e7c063          	blt	a5,a4,80004376 <log_write+0x96>
    800042fa:	84aa                	mv	s1,a0
    800042fc:	0001d797          	auipc	a5,0x1d
    80004300:	6287a783          	lw	a5,1576(a5) # 80021924 <log+0x1c>
    80004304:	37fd                	addiw	a5,a5,-1
    80004306:	06f75863          	bge	a4,a5,80004376 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000430a:	0001d797          	auipc	a5,0x1d
    8000430e:	61e7a783          	lw	a5,1566(a5) # 80021928 <log+0x20>
    80004312:	06f05a63          	blez	a5,80004386 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004316:	0001d917          	auipc	s2,0x1d
    8000431a:	5f290913          	addi	s2,s2,1522 # 80021908 <log>
    8000431e:	854a                	mv	a0,s2
    80004320:	ffffd097          	auipc	ra,0xffffd
    80004324:	92a080e7          	jalr	-1750(ra) # 80000c4a <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004328:	02c92603          	lw	a2,44(s2)
    8000432c:	06c05563          	blez	a2,80004396 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004330:	44cc                	lw	a1,12(s1)
    80004332:	0001d717          	auipc	a4,0x1d
    80004336:	60670713          	addi	a4,a4,1542 # 80021938 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000433a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000433c:	4314                	lw	a3,0(a4)
    8000433e:	04b68d63          	beq	a3,a1,80004398 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    80004342:	2785                	addiw	a5,a5,1
    80004344:	0711                	addi	a4,a4,4
    80004346:	fec79be3          	bne	a5,a2,8000433c <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000434a:	0621                	addi	a2,a2,8
    8000434c:	060a                	slli	a2,a2,0x2
    8000434e:	0001d797          	auipc	a5,0x1d
    80004352:	5ba78793          	addi	a5,a5,1466 # 80021908 <log>
    80004356:	97b2                	add	a5,a5,a2
    80004358:	44d8                	lw	a4,12(s1)
    8000435a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000435c:	8526                	mv	a0,s1
    8000435e:	fffff097          	auipc	ra,0xfffff
    80004362:	db4080e7          	jalr	-588(ra) # 80003112 <bpin>
    log.lh.n++;
    80004366:	0001d717          	auipc	a4,0x1d
    8000436a:	5a270713          	addi	a4,a4,1442 # 80021908 <log>
    8000436e:	575c                	lw	a5,44(a4)
    80004370:	2785                	addiw	a5,a5,1
    80004372:	d75c                	sw	a5,44(a4)
    80004374:	a835                	j	800043b0 <log_write+0xd0>
    panic("too big a transaction");
    80004376:	00004517          	auipc	a0,0x4
    8000437a:	43250513          	addi	a0,a0,1074 # 800087a8 <syscall_list+0x1f8>
    8000437e:	ffffc097          	auipc	ra,0xffffc
    80004382:	1c8080e7          	jalr	456(ra) # 80000546 <panic>
    panic("log_write outside of trans");
    80004386:	00004517          	auipc	a0,0x4
    8000438a:	43a50513          	addi	a0,a0,1082 # 800087c0 <syscall_list+0x210>
    8000438e:	ffffc097          	auipc	ra,0xffffc
    80004392:	1b8080e7          	jalr	440(ra) # 80000546 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004396:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004398:	00878693          	addi	a3,a5,8
    8000439c:	068a                	slli	a3,a3,0x2
    8000439e:	0001d717          	auipc	a4,0x1d
    800043a2:	56a70713          	addi	a4,a4,1386 # 80021908 <log>
    800043a6:	9736                	add	a4,a4,a3
    800043a8:	44d4                	lw	a3,12(s1)
    800043aa:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043ac:	faf608e3          	beq	a2,a5,8000435c <log_write+0x7c>
  }
  release(&log.lock);
    800043b0:	0001d517          	auipc	a0,0x1d
    800043b4:	55850513          	addi	a0,a0,1368 # 80021908 <log>
    800043b8:	ffffd097          	auipc	ra,0xffffd
    800043bc:	946080e7          	jalr	-1722(ra) # 80000cfe <release>
}
    800043c0:	60e2                	ld	ra,24(sp)
    800043c2:	6442                	ld	s0,16(sp)
    800043c4:	64a2                	ld	s1,8(sp)
    800043c6:	6902                	ld	s2,0(sp)
    800043c8:	6105                	addi	sp,sp,32
    800043ca:	8082                	ret

00000000800043cc <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800043cc:	1101                	addi	sp,sp,-32
    800043ce:	ec06                	sd	ra,24(sp)
    800043d0:	e822                	sd	s0,16(sp)
    800043d2:	e426                	sd	s1,8(sp)
    800043d4:	e04a                	sd	s2,0(sp)
    800043d6:	1000                	addi	s0,sp,32
    800043d8:	84aa                	mv	s1,a0
    800043da:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043dc:	00004597          	auipc	a1,0x4
    800043e0:	40458593          	addi	a1,a1,1028 # 800087e0 <syscall_list+0x230>
    800043e4:	0521                	addi	a0,a0,8
    800043e6:	ffffc097          	auipc	ra,0xffffc
    800043ea:	7d4080e7          	jalr	2004(ra) # 80000bba <initlock>
  lk->name = name;
    800043ee:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043f2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043f6:	0204a423          	sw	zero,40(s1)
}
    800043fa:	60e2                	ld	ra,24(sp)
    800043fc:	6442                	ld	s0,16(sp)
    800043fe:	64a2                	ld	s1,8(sp)
    80004400:	6902                	ld	s2,0(sp)
    80004402:	6105                	addi	sp,sp,32
    80004404:	8082                	ret

0000000080004406 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004406:	1101                	addi	sp,sp,-32
    80004408:	ec06                	sd	ra,24(sp)
    8000440a:	e822                	sd	s0,16(sp)
    8000440c:	e426                	sd	s1,8(sp)
    8000440e:	e04a                	sd	s2,0(sp)
    80004410:	1000                	addi	s0,sp,32
    80004412:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004414:	00850913          	addi	s2,a0,8
    80004418:	854a                	mv	a0,s2
    8000441a:	ffffd097          	auipc	ra,0xffffd
    8000441e:	830080e7          	jalr	-2000(ra) # 80000c4a <acquire>
  while (lk->locked) {
    80004422:	409c                	lw	a5,0(s1)
    80004424:	cb89                	beqz	a5,80004436 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004426:	85ca                	mv	a1,s2
    80004428:	8526                	mv	a0,s1
    8000442a:	ffffe097          	auipc	ra,0xffffe
    8000442e:	e08080e7          	jalr	-504(ra) # 80002232 <sleep>
  while (lk->locked) {
    80004432:	409c                	lw	a5,0(s1)
    80004434:	fbed                	bnez	a5,80004426 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004436:	4785                	li	a5,1
    80004438:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000443a:	ffffd097          	auipc	ra,0xffffd
    8000443e:	5dc080e7          	jalr	1500(ra) # 80001a16 <myproc>
    80004442:	5d1c                	lw	a5,56(a0)
    80004444:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004446:	854a                	mv	a0,s2
    80004448:	ffffd097          	auipc	ra,0xffffd
    8000444c:	8b6080e7          	jalr	-1866(ra) # 80000cfe <release>
}
    80004450:	60e2                	ld	ra,24(sp)
    80004452:	6442                	ld	s0,16(sp)
    80004454:	64a2                	ld	s1,8(sp)
    80004456:	6902                	ld	s2,0(sp)
    80004458:	6105                	addi	sp,sp,32
    8000445a:	8082                	ret

000000008000445c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000445c:	1101                	addi	sp,sp,-32
    8000445e:	ec06                	sd	ra,24(sp)
    80004460:	e822                	sd	s0,16(sp)
    80004462:	e426                	sd	s1,8(sp)
    80004464:	e04a                	sd	s2,0(sp)
    80004466:	1000                	addi	s0,sp,32
    80004468:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000446a:	00850913          	addi	s2,a0,8
    8000446e:	854a                	mv	a0,s2
    80004470:	ffffc097          	auipc	ra,0xffffc
    80004474:	7da080e7          	jalr	2010(ra) # 80000c4a <acquire>
  lk->locked = 0;
    80004478:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000447c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004480:	8526                	mv	a0,s1
    80004482:	ffffe097          	auipc	ra,0xffffe
    80004486:	f30080e7          	jalr	-208(ra) # 800023b2 <wakeup>
  release(&lk->lk);
    8000448a:	854a                	mv	a0,s2
    8000448c:	ffffd097          	auipc	ra,0xffffd
    80004490:	872080e7          	jalr	-1934(ra) # 80000cfe <release>
}
    80004494:	60e2                	ld	ra,24(sp)
    80004496:	6442                	ld	s0,16(sp)
    80004498:	64a2                	ld	s1,8(sp)
    8000449a:	6902                	ld	s2,0(sp)
    8000449c:	6105                	addi	sp,sp,32
    8000449e:	8082                	ret

00000000800044a0 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044a0:	7179                	addi	sp,sp,-48
    800044a2:	f406                	sd	ra,40(sp)
    800044a4:	f022                	sd	s0,32(sp)
    800044a6:	ec26                	sd	s1,24(sp)
    800044a8:	e84a                	sd	s2,16(sp)
    800044aa:	e44e                	sd	s3,8(sp)
    800044ac:	1800                	addi	s0,sp,48
    800044ae:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044b0:	00850913          	addi	s2,a0,8
    800044b4:	854a                	mv	a0,s2
    800044b6:	ffffc097          	auipc	ra,0xffffc
    800044ba:	794080e7          	jalr	1940(ra) # 80000c4a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044be:	409c                	lw	a5,0(s1)
    800044c0:	ef99                	bnez	a5,800044de <holdingsleep+0x3e>
    800044c2:	4481                	li	s1,0
  release(&lk->lk);
    800044c4:	854a                	mv	a0,s2
    800044c6:	ffffd097          	auipc	ra,0xffffd
    800044ca:	838080e7          	jalr	-1992(ra) # 80000cfe <release>
  return r;
}
    800044ce:	8526                	mv	a0,s1
    800044d0:	70a2                	ld	ra,40(sp)
    800044d2:	7402                	ld	s0,32(sp)
    800044d4:	64e2                	ld	s1,24(sp)
    800044d6:	6942                	ld	s2,16(sp)
    800044d8:	69a2                	ld	s3,8(sp)
    800044da:	6145                	addi	sp,sp,48
    800044dc:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044de:	0284a983          	lw	s3,40(s1)
    800044e2:	ffffd097          	auipc	ra,0xffffd
    800044e6:	534080e7          	jalr	1332(ra) # 80001a16 <myproc>
    800044ea:	5d04                	lw	s1,56(a0)
    800044ec:	413484b3          	sub	s1,s1,s3
    800044f0:	0014b493          	seqz	s1,s1
    800044f4:	bfc1                	j	800044c4 <holdingsleep+0x24>

00000000800044f6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044f6:	1141                	addi	sp,sp,-16
    800044f8:	e406                	sd	ra,8(sp)
    800044fa:	e022                	sd	s0,0(sp)
    800044fc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044fe:	00004597          	auipc	a1,0x4
    80004502:	2f258593          	addi	a1,a1,754 # 800087f0 <syscall_list+0x240>
    80004506:	0001d517          	auipc	a0,0x1d
    8000450a:	54a50513          	addi	a0,a0,1354 # 80021a50 <ftable>
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	6ac080e7          	jalr	1708(ra) # 80000bba <initlock>
}
    80004516:	60a2                	ld	ra,8(sp)
    80004518:	6402                	ld	s0,0(sp)
    8000451a:	0141                	addi	sp,sp,16
    8000451c:	8082                	ret

000000008000451e <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000451e:	1101                	addi	sp,sp,-32
    80004520:	ec06                	sd	ra,24(sp)
    80004522:	e822                	sd	s0,16(sp)
    80004524:	e426                	sd	s1,8(sp)
    80004526:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004528:	0001d517          	auipc	a0,0x1d
    8000452c:	52850513          	addi	a0,a0,1320 # 80021a50 <ftable>
    80004530:	ffffc097          	auipc	ra,0xffffc
    80004534:	71a080e7          	jalr	1818(ra) # 80000c4a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004538:	0001d497          	auipc	s1,0x1d
    8000453c:	53048493          	addi	s1,s1,1328 # 80021a68 <ftable+0x18>
    80004540:	0001e717          	auipc	a4,0x1e
    80004544:	4c870713          	addi	a4,a4,1224 # 80022a08 <ftable+0xfb8>
    if(f->ref == 0){
    80004548:	40dc                	lw	a5,4(s1)
    8000454a:	cf99                	beqz	a5,80004568 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000454c:	02848493          	addi	s1,s1,40
    80004550:	fee49ce3          	bne	s1,a4,80004548 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004554:	0001d517          	auipc	a0,0x1d
    80004558:	4fc50513          	addi	a0,a0,1276 # 80021a50 <ftable>
    8000455c:	ffffc097          	auipc	ra,0xffffc
    80004560:	7a2080e7          	jalr	1954(ra) # 80000cfe <release>
  return 0;
    80004564:	4481                	li	s1,0
    80004566:	a819                	j	8000457c <filealloc+0x5e>
      f->ref = 1;
    80004568:	4785                	li	a5,1
    8000456a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000456c:	0001d517          	auipc	a0,0x1d
    80004570:	4e450513          	addi	a0,a0,1252 # 80021a50 <ftable>
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	78a080e7          	jalr	1930(ra) # 80000cfe <release>
}
    8000457c:	8526                	mv	a0,s1
    8000457e:	60e2                	ld	ra,24(sp)
    80004580:	6442                	ld	s0,16(sp)
    80004582:	64a2                	ld	s1,8(sp)
    80004584:	6105                	addi	sp,sp,32
    80004586:	8082                	ret

0000000080004588 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004588:	1101                	addi	sp,sp,-32
    8000458a:	ec06                	sd	ra,24(sp)
    8000458c:	e822                	sd	s0,16(sp)
    8000458e:	e426                	sd	s1,8(sp)
    80004590:	1000                	addi	s0,sp,32
    80004592:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004594:	0001d517          	auipc	a0,0x1d
    80004598:	4bc50513          	addi	a0,a0,1212 # 80021a50 <ftable>
    8000459c:	ffffc097          	auipc	ra,0xffffc
    800045a0:	6ae080e7          	jalr	1710(ra) # 80000c4a <acquire>
  if(f->ref < 1)
    800045a4:	40dc                	lw	a5,4(s1)
    800045a6:	02f05263          	blez	a5,800045ca <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045aa:	2785                	addiw	a5,a5,1
    800045ac:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045ae:	0001d517          	auipc	a0,0x1d
    800045b2:	4a250513          	addi	a0,a0,1186 # 80021a50 <ftable>
    800045b6:	ffffc097          	auipc	ra,0xffffc
    800045ba:	748080e7          	jalr	1864(ra) # 80000cfe <release>
  return f;
}
    800045be:	8526                	mv	a0,s1
    800045c0:	60e2                	ld	ra,24(sp)
    800045c2:	6442                	ld	s0,16(sp)
    800045c4:	64a2                	ld	s1,8(sp)
    800045c6:	6105                	addi	sp,sp,32
    800045c8:	8082                	ret
    panic("filedup");
    800045ca:	00004517          	auipc	a0,0x4
    800045ce:	22e50513          	addi	a0,a0,558 # 800087f8 <syscall_list+0x248>
    800045d2:	ffffc097          	auipc	ra,0xffffc
    800045d6:	f74080e7          	jalr	-140(ra) # 80000546 <panic>

00000000800045da <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045da:	7139                	addi	sp,sp,-64
    800045dc:	fc06                	sd	ra,56(sp)
    800045de:	f822                	sd	s0,48(sp)
    800045e0:	f426                	sd	s1,40(sp)
    800045e2:	f04a                	sd	s2,32(sp)
    800045e4:	ec4e                	sd	s3,24(sp)
    800045e6:	e852                	sd	s4,16(sp)
    800045e8:	e456                	sd	s5,8(sp)
    800045ea:	0080                	addi	s0,sp,64
    800045ec:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045ee:	0001d517          	auipc	a0,0x1d
    800045f2:	46250513          	addi	a0,a0,1122 # 80021a50 <ftable>
    800045f6:	ffffc097          	auipc	ra,0xffffc
    800045fa:	654080e7          	jalr	1620(ra) # 80000c4a <acquire>
  if(f->ref < 1)
    800045fe:	40dc                	lw	a5,4(s1)
    80004600:	06f05163          	blez	a5,80004662 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004604:	37fd                	addiw	a5,a5,-1
    80004606:	0007871b          	sext.w	a4,a5
    8000460a:	c0dc                	sw	a5,4(s1)
    8000460c:	06e04363          	bgtz	a4,80004672 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004610:	0004a903          	lw	s2,0(s1)
    80004614:	0094ca83          	lbu	s5,9(s1)
    80004618:	0104ba03          	ld	s4,16(s1)
    8000461c:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004620:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004624:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004628:	0001d517          	auipc	a0,0x1d
    8000462c:	42850513          	addi	a0,a0,1064 # 80021a50 <ftable>
    80004630:	ffffc097          	auipc	ra,0xffffc
    80004634:	6ce080e7          	jalr	1742(ra) # 80000cfe <release>

  if(ff.type == FD_PIPE){
    80004638:	4785                	li	a5,1
    8000463a:	04f90d63          	beq	s2,a5,80004694 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000463e:	3979                	addiw	s2,s2,-2
    80004640:	4785                	li	a5,1
    80004642:	0527e063          	bltu	a5,s2,80004682 <fileclose+0xa8>
    begin_op();
    80004646:	00000097          	auipc	ra,0x0
    8000464a:	ac6080e7          	jalr	-1338(ra) # 8000410c <begin_op>
    iput(ff.ip);
    8000464e:	854e                	mv	a0,s3
    80004650:	fffff097          	auipc	ra,0xfffff
    80004654:	2b0080e7          	jalr	688(ra) # 80003900 <iput>
    end_op();
    80004658:	00000097          	auipc	ra,0x0
    8000465c:	b32080e7          	jalr	-1230(ra) # 8000418a <end_op>
    80004660:	a00d                	j	80004682 <fileclose+0xa8>
    panic("fileclose");
    80004662:	00004517          	auipc	a0,0x4
    80004666:	19e50513          	addi	a0,a0,414 # 80008800 <syscall_list+0x250>
    8000466a:	ffffc097          	auipc	ra,0xffffc
    8000466e:	edc080e7          	jalr	-292(ra) # 80000546 <panic>
    release(&ftable.lock);
    80004672:	0001d517          	auipc	a0,0x1d
    80004676:	3de50513          	addi	a0,a0,990 # 80021a50 <ftable>
    8000467a:	ffffc097          	auipc	ra,0xffffc
    8000467e:	684080e7          	jalr	1668(ra) # 80000cfe <release>
  }
}
    80004682:	70e2                	ld	ra,56(sp)
    80004684:	7442                	ld	s0,48(sp)
    80004686:	74a2                	ld	s1,40(sp)
    80004688:	7902                	ld	s2,32(sp)
    8000468a:	69e2                	ld	s3,24(sp)
    8000468c:	6a42                	ld	s4,16(sp)
    8000468e:	6aa2                	ld	s5,8(sp)
    80004690:	6121                	addi	sp,sp,64
    80004692:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004694:	85d6                	mv	a1,s5
    80004696:	8552                	mv	a0,s4
    80004698:	00000097          	auipc	ra,0x0
    8000469c:	372080e7          	jalr	882(ra) # 80004a0a <pipeclose>
    800046a0:	b7cd                	j	80004682 <fileclose+0xa8>

00000000800046a2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046a2:	715d                	addi	sp,sp,-80
    800046a4:	e486                	sd	ra,72(sp)
    800046a6:	e0a2                	sd	s0,64(sp)
    800046a8:	fc26                	sd	s1,56(sp)
    800046aa:	f84a                	sd	s2,48(sp)
    800046ac:	f44e                	sd	s3,40(sp)
    800046ae:	0880                	addi	s0,sp,80
    800046b0:	84aa                	mv	s1,a0
    800046b2:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046b4:	ffffd097          	auipc	ra,0xffffd
    800046b8:	362080e7          	jalr	866(ra) # 80001a16 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800046bc:	409c                	lw	a5,0(s1)
    800046be:	37f9                	addiw	a5,a5,-2
    800046c0:	4705                	li	a4,1
    800046c2:	04f76763          	bltu	a4,a5,80004710 <filestat+0x6e>
    800046c6:	892a                	mv	s2,a0
    ilock(f->ip);
    800046c8:	6c88                	ld	a0,24(s1)
    800046ca:	fffff097          	auipc	ra,0xfffff
    800046ce:	07c080e7          	jalr	124(ra) # 80003746 <ilock>
    stati(f->ip, &st);
    800046d2:	fb840593          	addi	a1,s0,-72
    800046d6:	6c88                	ld	a0,24(s1)
    800046d8:	fffff097          	auipc	ra,0xfffff
    800046dc:	2f8080e7          	jalr	760(ra) # 800039d0 <stati>
    iunlock(f->ip);
    800046e0:	6c88                	ld	a0,24(s1)
    800046e2:	fffff097          	auipc	ra,0xfffff
    800046e6:	126080e7          	jalr	294(ra) # 80003808 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046ea:	46e1                	li	a3,24
    800046ec:	fb840613          	addi	a2,s0,-72
    800046f0:	85ce                	mv	a1,s3
    800046f2:	05093503          	ld	a0,80(s2)
    800046f6:	ffffd097          	auipc	ra,0xffffd
    800046fa:	016080e7          	jalr	22(ra) # 8000170c <copyout>
    800046fe:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004702:	60a6                	ld	ra,72(sp)
    80004704:	6406                	ld	s0,64(sp)
    80004706:	74e2                	ld	s1,56(sp)
    80004708:	7942                	ld	s2,48(sp)
    8000470a:	79a2                	ld	s3,40(sp)
    8000470c:	6161                	addi	sp,sp,80
    8000470e:	8082                	ret
  return -1;
    80004710:	557d                	li	a0,-1
    80004712:	bfc5                	j	80004702 <filestat+0x60>

0000000080004714 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004714:	7179                	addi	sp,sp,-48
    80004716:	f406                	sd	ra,40(sp)
    80004718:	f022                	sd	s0,32(sp)
    8000471a:	ec26                	sd	s1,24(sp)
    8000471c:	e84a                	sd	s2,16(sp)
    8000471e:	e44e                	sd	s3,8(sp)
    80004720:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004722:	00854783          	lbu	a5,8(a0)
    80004726:	c3d5                	beqz	a5,800047ca <fileread+0xb6>
    80004728:	84aa                	mv	s1,a0
    8000472a:	89ae                	mv	s3,a1
    8000472c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000472e:	411c                	lw	a5,0(a0)
    80004730:	4705                	li	a4,1
    80004732:	04e78963          	beq	a5,a4,80004784 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004736:	470d                	li	a4,3
    80004738:	04e78d63          	beq	a5,a4,80004792 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000473c:	4709                	li	a4,2
    8000473e:	06e79e63          	bne	a5,a4,800047ba <fileread+0xa6>
    ilock(f->ip);
    80004742:	6d08                	ld	a0,24(a0)
    80004744:	fffff097          	auipc	ra,0xfffff
    80004748:	002080e7          	jalr	2(ra) # 80003746 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000474c:	874a                	mv	a4,s2
    8000474e:	5094                	lw	a3,32(s1)
    80004750:	864e                	mv	a2,s3
    80004752:	4585                	li	a1,1
    80004754:	6c88                	ld	a0,24(s1)
    80004756:	fffff097          	auipc	ra,0xfffff
    8000475a:	2a4080e7          	jalr	676(ra) # 800039fa <readi>
    8000475e:	892a                	mv	s2,a0
    80004760:	00a05563          	blez	a0,8000476a <fileread+0x56>
      f->off += r;
    80004764:	509c                	lw	a5,32(s1)
    80004766:	9fa9                	addw	a5,a5,a0
    80004768:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000476a:	6c88                	ld	a0,24(s1)
    8000476c:	fffff097          	auipc	ra,0xfffff
    80004770:	09c080e7          	jalr	156(ra) # 80003808 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004774:	854a                	mv	a0,s2
    80004776:	70a2                	ld	ra,40(sp)
    80004778:	7402                	ld	s0,32(sp)
    8000477a:	64e2                	ld	s1,24(sp)
    8000477c:	6942                	ld	s2,16(sp)
    8000477e:	69a2                	ld	s3,8(sp)
    80004780:	6145                	addi	sp,sp,48
    80004782:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004784:	6908                	ld	a0,16(a0)
    80004786:	00000097          	auipc	ra,0x0
    8000478a:	3f6080e7          	jalr	1014(ra) # 80004b7c <piperead>
    8000478e:	892a                	mv	s2,a0
    80004790:	b7d5                	j	80004774 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004792:	02451783          	lh	a5,36(a0)
    80004796:	03079693          	slli	a3,a5,0x30
    8000479a:	92c1                	srli	a3,a3,0x30
    8000479c:	4725                	li	a4,9
    8000479e:	02d76863          	bltu	a4,a3,800047ce <fileread+0xba>
    800047a2:	0792                	slli	a5,a5,0x4
    800047a4:	0001d717          	auipc	a4,0x1d
    800047a8:	20c70713          	addi	a4,a4,524 # 800219b0 <devsw>
    800047ac:	97ba                	add	a5,a5,a4
    800047ae:	639c                	ld	a5,0(a5)
    800047b0:	c38d                	beqz	a5,800047d2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047b2:	4505                	li	a0,1
    800047b4:	9782                	jalr	a5
    800047b6:	892a                	mv	s2,a0
    800047b8:	bf75                	j	80004774 <fileread+0x60>
    panic("fileread");
    800047ba:	00004517          	auipc	a0,0x4
    800047be:	05650513          	addi	a0,a0,86 # 80008810 <syscall_list+0x260>
    800047c2:	ffffc097          	auipc	ra,0xffffc
    800047c6:	d84080e7          	jalr	-636(ra) # 80000546 <panic>
    return -1;
    800047ca:	597d                	li	s2,-1
    800047cc:	b765                	j	80004774 <fileread+0x60>
      return -1;
    800047ce:	597d                	li	s2,-1
    800047d0:	b755                	j	80004774 <fileread+0x60>
    800047d2:	597d                	li	s2,-1
    800047d4:	b745                	j	80004774 <fileread+0x60>

00000000800047d6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047d6:	00954783          	lbu	a5,9(a0)
    800047da:	14078563          	beqz	a5,80004924 <filewrite+0x14e>
{
    800047de:	715d                	addi	sp,sp,-80
    800047e0:	e486                	sd	ra,72(sp)
    800047e2:	e0a2                	sd	s0,64(sp)
    800047e4:	fc26                	sd	s1,56(sp)
    800047e6:	f84a                	sd	s2,48(sp)
    800047e8:	f44e                	sd	s3,40(sp)
    800047ea:	f052                	sd	s4,32(sp)
    800047ec:	ec56                	sd	s5,24(sp)
    800047ee:	e85a                	sd	s6,16(sp)
    800047f0:	e45e                	sd	s7,8(sp)
    800047f2:	e062                	sd	s8,0(sp)
    800047f4:	0880                	addi	s0,sp,80
    800047f6:	892a                	mv	s2,a0
    800047f8:	8b2e                	mv	s6,a1
    800047fa:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047fc:	411c                	lw	a5,0(a0)
    800047fe:	4705                	li	a4,1
    80004800:	02e78263          	beq	a5,a4,80004824 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004804:	470d                	li	a4,3
    80004806:	02e78563          	beq	a5,a4,80004830 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000480a:	4709                	li	a4,2
    8000480c:	10e79463          	bne	a5,a4,80004914 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004810:	0ec05e63          	blez	a2,8000490c <filewrite+0x136>
    int i = 0;
    80004814:	4981                	li	s3,0
    80004816:	6b85                	lui	s7,0x1
    80004818:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000481c:	6c05                	lui	s8,0x1
    8000481e:	c00c0c1b          	addiw	s8,s8,-1024
    80004822:	a851                	j	800048b6 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004824:	6908                	ld	a0,16(a0)
    80004826:	00000097          	auipc	ra,0x0
    8000482a:	254080e7          	jalr	596(ra) # 80004a7a <pipewrite>
    8000482e:	a85d                	j	800048e4 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004830:	02451783          	lh	a5,36(a0)
    80004834:	03079693          	slli	a3,a5,0x30
    80004838:	92c1                	srli	a3,a3,0x30
    8000483a:	4725                	li	a4,9
    8000483c:	0ed76663          	bltu	a4,a3,80004928 <filewrite+0x152>
    80004840:	0792                	slli	a5,a5,0x4
    80004842:	0001d717          	auipc	a4,0x1d
    80004846:	16e70713          	addi	a4,a4,366 # 800219b0 <devsw>
    8000484a:	97ba                	add	a5,a5,a4
    8000484c:	679c                	ld	a5,8(a5)
    8000484e:	cff9                	beqz	a5,8000492c <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    80004850:	4505                	li	a0,1
    80004852:	9782                	jalr	a5
    80004854:	a841                	j	800048e4 <filewrite+0x10e>
    80004856:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    8000485a:	00000097          	auipc	ra,0x0
    8000485e:	8b2080e7          	jalr	-1870(ra) # 8000410c <begin_op>
      ilock(f->ip);
    80004862:	01893503          	ld	a0,24(s2)
    80004866:	fffff097          	auipc	ra,0xfffff
    8000486a:	ee0080e7          	jalr	-288(ra) # 80003746 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000486e:	8756                	mv	a4,s5
    80004870:	02092683          	lw	a3,32(s2)
    80004874:	01698633          	add	a2,s3,s6
    80004878:	4585                	li	a1,1
    8000487a:	01893503          	ld	a0,24(s2)
    8000487e:	fffff097          	auipc	ra,0xfffff
    80004882:	272080e7          	jalr	626(ra) # 80003af0 <writei>
    80004886:	84aa                	mv	s1,a0
    80004888:	02a05f63          	blez	a0,800048c6 <filewrite+0xf0>
        f->off += r;
    8000488c:	02092783          	lw	a5,32(s2)
    80004890:	9fa9                	addw	a5,a5,a0
    80004892:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004896:	01893503          	ld	a0,24(s2)
    8000489a:	fffff097          	auipc	ra,0xfffff
    8000489e:	f6e080e7          	jalr	-146(ra) # 80003808 <iunlock>
      end_op();
    800048a2:	00000097          	auipc	ra,0x0
    800048a6:	8e8080e7          	jalr	-1816(ra) # 8000418a <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800048aa:	049a9963          	bne	s5,s1,800048fc <filewrite+0x126>
        panic("short filewrite");
      i += r;
    800048ae:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048b2:	0349d663          	bge	s3,s4,800048de <filewrite+0x108>
      int n1 = n - i;
    800048b6:	413a04bb          	subw	s1,s4,s3
    800048ba:	0004879b          	sext.w	a5,s1
    800048be:	f8fbdce3          	bge	s7,a5,80004856 <filewrite+0x80>
    800048c2:	84e2                	mv	s1,s8
    800048c4:	bf49                	j	80004856 <filewrite+0x80>
      iunlock(f->ip);
    800048c6:	01893503          	ld	a0,24(s2)
    800048ca:	fffff097          	auipc	ra,0xfffff
    800048ce:	f3e080e7          	jalr	-194(ra) # 80003808 <iunlock>
      end_op();
    800048d2:	00000097          	auipc	ra,0x0
    800048d6:	8b8080e7          	jalr	-1864(ra) # 8000418a <end_op>
      if(r < 0)
    800048da:	fc04d8e3          	bgez	s1,800048aa <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    800048de:	8552                	mv	a0,s4
    800048e0:	033a1863          	bne	s4,s3,80004910 <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800048e4:	60a6                	ld	ra,72(sp)
    800048e6:	6406                	ld	s0,64(sp)
    800048e8:	74e2                	ld	s1,56(sp)
    800048ea:	7942                	ld	s2,48(sp)
    800048ec:	79a2                	ld	s3,40(sp)
    800048ee:	7a02                	ld	s4,32(sp)
    800048f0:	6ae2                	ld	s5,24(sp)
    800048f2:	6b42                	ld	s6,16(sp)
    800048f4:	6ba2                	ld	s7,8(sp)
    800048f6:	6c02                	ld	s8,0(sp)
    800048f8:	6161                	addi	sp,sp,80
    800048fa:	8082                	ret
        panic("short filewrite");
    800048fc:	00004517          	auipc	a0,0x4
    80004900:	f2450513          	addi	a0,a0,-220 # 80008820 <syscall_list+0x270>
    80004904:	ffffc097          	auipc	ra,0xffffc
    80004908:	c42080e7          	jalr	-958(ra) # 80000546 <panic>
    int i = 0;
    8000490c:	4981                	li	s3,0
    8000490e:	bfc1                	j	800048de <filewrite+0x108>
    ret = (i == n ? n : -1);
    80004910:	557d                	li	a0,-1
    80004912:	bfc9                	j	800048e4 <filewrite+0x10e>
    panic("filewrite");
    80004914:	00004517          	auipc	a0,0x4
    80004918:	f1c50513          	addi	a0,a0,-228 # 80008830 <syscall_list+0x280>
    8000491c:	ffffc097          	auipc	ra,0xffffc
    80004920:	c2a080e7          	jalr	-982(ra) # 80000546 <panic>
    return -1;
    80004924:	557d                	li	a0,-1
}
    80004926:	8082                	ret
      return -1;
    80004928:	557d                	li	a0,-1
    8000492a:	bf6d                	j	800048e4 <filewrite+0x10e>
    8000492c:	557d                	li	a0,-1
    8000492e:	bf5d                	j	800048e4 <filewrite+0x10e>

0000000080004930 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004930:	7179                	addi	sp,sp,-48
    80004932:	f406                	sd	ra,40(sp)
    80004934:	f022                	sd	s0,32(sp)
    80004936:	ec26                	sd	s1,24(sp)
    80004938:	e84a                	sd	s2,16(sp)
    8000493a:	e44e                	sd	s3,8(sp)
    8000493c:	e052                	sd	s4,0(sp)
    8000493e:	1800                	addi	s0,sp,48
    80004940:	84aa                	mv	s1,a0
    80004942:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004944:	0005b023          	sd	zero,0(a1)
    80004948:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000494c:	00000097          	auipc	ra,0x0
    80004950:	bd2080e7          	jalr	-1070(ra) # 8000451e <filealloc>
    80004954:	e088                	sd	a0,0(s1)
    80004956:	c551                	beqz	a0,800049e2 <pipealloc+0xb2>
    80004958:	00000097          	auipc	ra,0x0
    8000495c:	bc6080e7          	jalr	-1082(ra) # 8000451e <filealloc>
    80004960:	00aa3023          	sd	a0,0(s4)
    80004964:	c92d                	beqz	a0,800049d6 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004966:	ffffc097          	auipc	ra,0xffffc
    8000496a:	1aa080e7          	jalr	426(ra) # 80000b10 <kalloc>
    8000496e:	892a                	mv	s2,a0
    80004970:	c125                	beqz	a0,800049d0 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004972:	4985                	li	s3,1
    80004974:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004978:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000497c:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004980:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004984:	00004597          	auipc	a1,0x4
    80004988:	ac458593          	addi	a1,a1,-1340 # 80008448 <states.0+0x1a0>
    8000498c:	ffffc097          	auipc	ra,0xffffc
    80004990:	22e080e7          	jalr	558(ra) # 80000bba <initlock>
  (*f0)->type = FD_PIPE;
    80004994:	609c                	ld	a5,0(s1)
    80004996:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000499a:	609c                	ld	a5,0(s1)
    8000499c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049a0:	609c                	ld	a5,0(s1)
    800049a2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049a6:	609c                	ld	a5,0(s1)
    800049a8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049ac:	000a3783          	ld	a5,0(s4)
    800049b0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049b4:	000a3783          	ld	a5,0(s4)
    800049b8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049bc:	000a3783          	ld	a5,0(s4)
    800049c0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049c4:	000a3783          	ld	a5,0(s4)
    800049c8:	0127b823          	sd	s2,16(a5)
  return 0;
    800049cc:	4501                	li	a0,0
    800049ce:	a025                	j	800049f6 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049d0:	6088                	ld	a0,0(s1)
    800049d2:	e501                	bnez	a0,800049da <pipealloc+0xaa>
    800049d4:	a039                	j	800049e2 <pipealloc+0xb2>
    800049d6:	6088                	ld	a0,0(s1)
    800049d8:	c51d                	beqz	a0,80004a06 <pipealloc+0xd6>
    fileclose(*f0);
    800049da:	00000097          	auipc	ra,0x0
    800049de:	c00080e7          	jalr	-1024(ra) # 800045da <fileclose>
  if(*f1)
    800049e2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049e6:	557d                	li	a0,-1
  if(*f1)
    800049e8:	c799                	beqz	a5,800049f6 <pipealloc+0xc6>
    fileclose(*f1);
    800049ea:	853e                	mv	a0,a5
    800049ec:	00000097          	auipc	ra,0x0
    800049f0:	bee080e7          	jalr	-1042(ra) # 800045da <fileclose>
  return -1;
    800049f4:	557d                	li	a0,-1
}
    800049f6:	70a2                	ld	ra,40(sp)
    800049f8:	7402                	ld	s0,32(sp)
    800049fa:	64e2                	ld	s1,24(sp)
    800049fc:	6942                	ld	s2,16(sp)
    800049fe:	69a2                	ld	s3,8(sp)
    80004a00:	6a02                	ld	s4,0(sp)
    80004a02:	6145                	addi	sp,sp,48
    80004a04:	8082                	ret
  return -1;
    80004a06:	557d                	li	a0,-1
    80004a08:	b7fd                	j	800049f6 <pipealloc+0xc6>

0000000080004a0a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a0a:	1101                	addi	sp,sp,-32
    80004a0c:	ec06                	sd	ra,24(sp)
    80004a0e:	e822                	sd	s0,16(sp)
    80004a10:	e426                	sd	s1,8(sp)
    80004a12:	e04a                	sd	s2,0(sp)
    80004a14:	1000                	addi	s0,sp,32
    80004a16:	84aa                	mv	s1,a0
    80004a18:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a1a:	ffffc097          	auipc	ra,0xffffc
    80004a1e:	230080e7          	jalr	560(ra) # 80000c4a <acquire>
  if(writable){
    80004a22:	02090d63          	beqz	s2,80004a5c <pipeclose+0x52>
    pi->writeopen = 0;
    80004a26:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a2a:	21848513          	addi	a0,s1,536
    80004a2e:	ffffe097          	auipc	ra,0xffffe
    80004a32:	984080e7          	jalr	-1660(ra) # 800023b2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a36:	2204b783          	ld	a5,544(s1)
    80004a3a:	eb95                	bnez	a5,80004a6e <pipeclose+0x64>
    release(&pi->lock);
    80004a3c:	8526                	mv	a0,s1
    80004a3e:	ffffc097          	auipc	ra,0xffffc
    80004a42:	2c0080e7          	jalr	704(ra) # 80000cfe <release>
    kfree((char*)pi);
    80004a46:	8526                	mv	a0,s1
    80004a48:	ffffc097          	auipc	ra,0xffffc
    80004a4c:	fca080e7          	jalr	-54(ra) # 80000a12 <kfree>
  } else
    release(&pi->lock);
}
    80004a50:	60e2                	ld	ra,24(sp)
    80004a52:	6442                	ld	s0,16(sp)
    80004a54:	64a2                	ld	s1,8(sp)
    80004a56:	6902                	ld	s2,0(sp)
    80004a58:	6105                	addi	sp,sp,32
    80004a5a:	8082                	ret
    pi->readopen = 0;
    80004a5c:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a60:	21c48513          	addi	a0,s1,540
    80004a64:	ffffe097          	auipc	ra,0xffffe
    80004a68:	94e080e7          	jalr	-1714(ra) # 800023b2 <wakeup>
    80004a6c:	b7e9                	j	80004a36 <pipeclose+0x2c>
    release(&pi->lock);
    80004a6e:	8526                	mv	a0,s1
    80004a70:	ffffc097          	auipc	ra,0xffffc
    80004a74:	28e080e7          	jalr	654(ra) # 80000cfe <release>
}
    80004a78:	bfe1                	j	80004a50 <pipeclose+0x46>

0000000080004a7a <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a7a:	711d                	addi	sp,sp,-96
    80004a7c:	ec86                	sd	ra,88(sp)
    80004a7e:	e8a2                	sd	s0,80(sp)
    80004a80:	e4a6                	sd	s1,72(sp)
    80004a82:	e0ca                	sd	s2,64(sp)
    80004a84:	fc4e                	sd	s3,56(sp)
    80004a86:	f852                	sd	s4,48(sp)
    80004a88:	f456                	sd	s5,40(sp)
    80004a8a:	f05a                	sd	s6,32(sp)
    80004a8c:	ec5e                	sd	s7,24(sp)
    80004a8e:	e862                	sd	s8,16(sp)
    80004a90:	1080                	addi	s0,sp,96
    80004a92:	84aa                	mv	s1,a0
    80004a94:	8b2e                	mv	s6,a1
    80004a96:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004a98:	ffffd097          	auipc	ra,0xffffd
    80004a9c:	f7e080e7          	jalr	-130(ra) # 80001a16 <myproc>
    80004aa0:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004aa2:	8526                	mv	a0,s1
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	1a6080e7          	jalr	422(ra) # 80000c4a <acquire>
  for(i = 0; i < n; i++){
    80004aac:	09505863          	blez	s5,80004b3c <pipewrite+0xc2>
    80004ab0:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004ab2:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ab6:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004aba:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004abc:	2184a783          	lw	a5,536(s1)
    80004ac0:	21c4a703          	lw	a4,540(s1)
    80004ac4:	2007879b          	addiw	a5,a5,512
    80004ac8:	02f71b63          	bne	a4,a5,80004afe <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004acc:	2204a783          	lw	a5,544(s1)
    80004ad0:	c3d9                	beqz	a5,80004b56 <pipewrite+0xdc>
    80004ad2:	03092783          	lw	a5,48(s2)
    80004ad6:	e3c1                	bnez	a5,80004b56 <pipewrite+0xdc>
      wakeup(&pi->nread);
    80004ad8:	8552                	mv	a0,s4
    80004ada:	ffffe097          	auipc	ra,0xffffe
    80004ade:	8d8080e7          	jalr	-1832(ra) # 800023b2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ae2:	85a6                	mv	a1,s1
    80004ae4:	854e                	mv	a0,s3
    80004ae6:	ffffd097          	auipc	ra,0xffffd
    80004aea:	74c080e7          	jalr	1868(ra) # 80002232 <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004aee:	2184a783          	lw	a5,536(s1)
    80004af2:	21c4a703          	lw	a4,540(s1)
    80004af6:	2007879b          	addiw	a5,a5,512
    80004afa:	fcf709e3          	beq	a4,a5,80004acc <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004afe:	4685                	li	a3,1
    80004b00:	865a                	mv	a2,s6
    80004b02:	faf40593          	addi	a1,s0,-81
    80004b06:	05093503          	ld	a0,80(s2)
    80004b0a:	ffffd097          	auipc	ra,0xffffd
    80004b0e:	c8e080e7          	jalr	-882(ra) # 80001798 <copyin>
    80004b12:	03850663          	beq	a0,s8,80004b3e <pipewrite+0xc4>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b16:	21c4a783          	lw	a5,540(s1)
    80004b1a:	0017871b          	addiw	a4,a5,1
    80004b1e:	20e4ae23          	sw	a4,540(s1)
    80004b22:	1ff7f793          	andi	a5,a5,511
    80004b26:	97a6                	add	a5,a5,s1
    80004b28:	faf44703          	lbu	a4,-81(s0)
    80004b2c:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004b30:	2b85                	addiw	s7,s7,1
    80004b32:	0b05                	addi	s6,s6,1
    80004b34:	f97a94e3          	bne	s5,s7,80004abc <pipewrite+0x42>
    80004b38:	8bd6                	mv	s7,s5
    80004b3a:	a011                	j	80004b3e <pipewrite+0xc4>
    80004b3c:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    80004b3e:	21848513          	addi	a0,s1,536
    80004b42:	ffffe097          	auipc	ra,0xffffe
    80004b46:	870080e7          	jalr	-1936(ra) # 800023b2 <wakeup>
  release(&pi->lock);
    80004b4a:	8526                	mv	a0,s1
    80004b4c:	ffffc097          	auipc	ra,0xffffc
    80004b50:	1b2080e7          	jalr	434(ra) # 80000cfe <release>
  return i;
    80004b54:	a039                	j	80004b62 <pipewrite+0xe8>
        release(&pi->lock);
    80004b56:	8526                	mv	a0,s1
    80004b58:	ffffc097          	auipc	ra,0xffffc
    80004b5c:	1a6080e7          	jalr	422(ra) # 80000cfe <release>
        return -1;
    80004b60:	5bfd                	li	s7,-1
}
    80004b62:	855e                	mv	a0,s7
    80004b64:	60e6                	ld	ra,88(sp)
    80004b66:	6446                	ld	s0,80(sp)
    80004b68:	64a6                	ld	s1,72(sp)
    80004b6a:	6906                	ld	s2,64(sp)
    80004b6c:	79e2                	ld	s3,56(sp)
    80004b6e:	7a42                	ld	s4,48(sp)
    80004b70:	7aa2                	ld	s5,40(sp)
    80004b72:	7b02                	ld	s6,32(sp)
    80004b74:	6be2                	ld	s7,24(sp)
    80004b76:	6c42                	ld	s8,16(sp)
    80004b78:	6125                	addi	sp,sp,96
    80004b7a:	8082                	ret

0000000080004b7c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b7c:	715d                	addi	sp,sp,-80
    80004b7e:	e486                	sd	ra,72(sp)
    80004b80:	e0a2                	sd	s0,64(sp)
    80004b82:	fc26                	sd	s1,56(sp)
    80004b84:	f84a                	sd	s2,48(sp)
    80004b86:	f44e                	sd	s3,40(sp)
    80004b88:	f052                	sd	s4,32(sp)
    80004b8a:	ec56                	sd	s5,24(sp)
    80004b8c:	e85a                	sd	s6,16(sp)
    80004b8e:	0880                	addi	s0,sp,80
    80004b90:	84aa                	mv	s1,a0
    80004b92:	892e                	mv	s2,a1
    80004b94:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b96:	ffffd097          	auipc	ra,0xffffd
    80004b9a:	e80080e7          	jalr	-384(ra) # 80001a16 <myproc>
    80004b9e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	0a8080e7          	jalr	168(ra) # 80000c4a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004baa:	2184a703          	lw	a4,536(s1)
    80004bae:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bb2:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bb6:	02f71463          	bne	a4,a5,80004bde <piperead+0x62>
    80004bba:	2244a783          	lw	a5,548(s1)
    80004bbe:	c385                	beqz	a5,80004bde <piperead+0x62>
    if(pr->killed){
    80004bc0:	030a2783          	lw	a5,48(s4)
    80004bc4:	ebc9                	bnez	a5,80004c56 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bc6:	85a6                	mv	a1,s1
    80004bc8:	854e                	mv	a0,s3
    80004bca:	ffffd097          	auipc	ra,0xffffd
    80004bce:	668080e7          	jalr	1640(ra) # 80002232 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bd2:	2184a703          	lw	a4,536(s1)
    80004bd6:	21c4a783          	lw	a5,540(s1)
    80004bda:	fef700e3          	beq	a4,a5,80004bba <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bde:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004be0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004be2:	05505463          	blez	s5,80004c2a <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004be6:	2184a783          	lw	a5,536(s1)
    80004bea:	21c4a703          	lw	a4,540(s1)
    80004bee:	02f70e63          	beq	a4,a5,80004c2a <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004bf2:	0017871b          	addiw	a4,a5,1
    80004bf6:	20e4ac23          	sw	a4,536(s1)
    80004bfa:	1ff7f793          	andi	a5,a5,511
    80004bfe:	97a6                	add	a5,a5,s1
    80004c00:	0187c783          	lbu	a5,24(a5)
    80004c04:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c08:	4685                	li	a3,1
    80004c0a:	fbf40613          	addi	a2,s0,-65
    80004c0e:	85ca                	mv	a1,s2
    80004c10:	050a3503          	ld	a0,80(s4)
    80004c14:	ffffd097          	auipc	ra,0xffffd
    80004c18:	af8080e7          	jalr	-1288(ra) # 8000170c <copyout>
    80004c1c:	01650763          	beq	a0,s6,80004c2a <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c20:	2985                	addiw	s3,s3,1
    80004c22:	0905                	addi	s2,s2,1
    80004c24:	fd3a91e3          	bne	s5,s3,80004be6 <piperead+0x6a>
    80004c28:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c2a:	21c48513          	addi	a0,s1,540
    80004c2e:	ffffd097          	auipc	ra,0xffffd
    80004c32:	784080e7          	jalr	1924(ra) # 800023b2 <wakeup>
  release(&pi->lock);
    80004c36:	8526                	mv	a0,s1
    80004c38:	ffffc097          	auipc	ra,0xffffc
    80004c3c:	0c6080e7          	jalr	198(ra) # 80000cfe <release>
  return i;
}
    80004c40:	854e                	mv	a0,s3
    80004c42:	60a6                	ld	ra,72(sp)
    80004c44:	6406                	ld	s0,64(sp)
    80004c46:	74e2                	ld	s1,56(sp)
    80004c48:	7942                	ld	s2,48(sp)
    80004c4a:	79a2                	ld	s3,40(sp)
    80004c4c:	7a02                	ld	s4,32(sp)
    80004c4e:	6ae2                	ld	s5,24(sp)
    80004c50:	6b42                	ld	s6,16(sp)
    80004c52:	6161                	addi	sp,sp,80
    80004c54:	8082                	ret
      release(&pi->lock);
    80004c56:	8526                	mv	a0,s1
    80004c58:	ffffc097          	auipc	ra,0xffffc
    80004c5c:	0a6080e7          	jalr	166(ra) # 80000cfe <release>
      return -1;
    80004c60:	59fd                	li	s3,-1
    80004c62:	bff9                	j	80004c40 <piperead+0xc4>

0000000080004c64 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004c64:	de010113          	addi	sp,sp,-544
    80004c68:	20113c23          	sd	ra,536(sp)
    80004c6c:	20813823          	sd	s0,528(sp)
    80004c70:	20913423          	sd	s1,520(sp)
    80004c74:	21213023          	sd	s2,512(sp)
    80004c78:	ffce                	sd	s3,504(sp)
    80004c7a:	fbd2                	sd	s4,496(sp)
    80004c7c:	f7d6                	sd	s5,488(sp)
    80004c7e:	f3da                	sd	s6,480(sp)
    80004c80:	efde                	sd	s7,472(sp)
    80004c82:	ebe2                	sd	s8,464(sp)
    80004c84:	e7e6                	sd	s9,456(sp)
    80004c86:	e3ea                	sd	s10,448(sp)
    80004c88:	ff6e                	sd	s11,440(sp)
    80004c8a:	1400                	addi	s0,sp,544
    80004c8c:	892a                	mv	s2,a0
    80004c8e:	dea43423          	sd	a0,-536(s0)
    80004c92:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c96:	ffffd097          	auipc	ra,0xffffd
    80004c9a:	d80080e7          	jalr	-640(ra) # 80001a16 <myproc>
    80004c9e:	84aa                	mv	s1,a0

  begin_op();
    80004ca0:	fffff097          	auipc	ra,0xfffff
    80004ca4:	46c080e7          	jalr	1132(ra) # 8000410c <begin_op>

  if((ip = namei(path)) == 0){
    80004ca8:	854a                	mv	a0,s2
    80004caa:	fffff097          	auipc	ra,0xfffff
    80004cae:	252080e7          	jalr	594(ra) # 80003efc <namei>
    80004cb2:	c93d                	beqz	a0,80004d28 <exec+0xc4>
    80004cb4:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004cb6:	fffff097          	auipc	ra,0xfffff
    80004cba:	a90080e7          	jalr	-1392(ra) # 80003746 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cbe:	04000713          	li	a4,64
    80004cc2:	4681                	li	a3,0
    80004cc4:	e4840613          	addi	a2,s0,-440
    80004cc8:	4581                	li	a1,0
    80004cca:	8556                	mv	a0,s5
    80004ccc:	fffff097          	auipc	ra,0xfffff
    80004cd0:	d2e080e7          	jalr	-722(ra) # 800039fa <readi>
    80004cd4:	04000793          	li	a5,64
    80004cd8:	00f51a63          	bne	a0,a5,80004cec <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004cdc:	e4842703          	lw	a4,-440(s0)
    80004ce0:	464c47b7          	lui	a5,0x464c4
    80004ce4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004ce8:	04f70663          	beq	a4,a5,80004d34 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cec:	8556                	mv	a0,s5
    80004cee:	fffff097          	auipc	ra,0xfffff
    80004cf2:	cba080e7          	jalr	-838(ra) # 800039a8 <iunlockput>
    end_op();
    80004cf6:	fffff097          	auipc	ra,0xfffff
    80004cfa:	494080e7          	jalr	1172(ra) # 8000418a <end_op>
  }
  return -1;
    80004cfe:	557d                	li	a0,-1
}
    80004d00:	21813083          	ld	ra,536(sp)
    80004d04:	21013403          	ld	s0,528(sp)
    80004d08:	20813483          	ld	s1,520(sp)
    80004d0c:	20013903          	ld	s2,512(sp)
    80004d10:	79fe                	ld	s3,504(sp)
    80004d12:	7a5e                	ld	s4,496(sp)
    80004d14:	7abe                	ld	s5,488(sp)
    80004d16:	7b1e                	ld	s6,480(sp)
    80004d18:	6bfe                	ld	s7,472(sp)
    80004d1a:	6c5e                	ld	s8,464(sp)
    80004d1c:	6cbe                	ld	s9,456(sp)
    80004d1e:	6d1e                	ld	s10,448(sp)
    80004d20:	7dfa                	ld	s11,440(sp)
    80004d22:	22010113          	addi	sp,sp,544
    80004d26:	8082                	ret
    end_op();
    80004d28:	fffff097          	auipc	ra,0xfffff
    80004d2c:	462080e7          	jalr	1122(ra) # 8000418a <end_op>
    return -1;
    80004d30:	557d                	li	a0,-1
    80004d32:	b7f9                	j	80004d00 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d34:	8526                	mv	a0,s1
    80004d36:	ffffd097          	auipc	ra,0xffffd
    80004d3a:	da4080e7          	jalr	-604(ra) # 80001ada <proc_pagetable>
    80004d3e:	8b2a                	mv	s6,a0
    80004d40:	d555                	beqz	a0,80004cec <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d42:	e6842783          	lw	a5,-408(s0)
    80004d46:	e8045703          	lhu	a4,-384(s0)
    80004d4a:	c735                	beqz	a4,80004db6 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d4c:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d4e:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004d52:	6a05                	lui	s4,0x1
    80004d54:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004d58:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004d5c:	6d85                	lui	s11,0x1
    80004d5e:	7d7d                	lui	s10,0xfffff
    80004d60:	ac1d                	j	80004f96 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004d62:	00004517          	auipc	a0,0x4
    80004d66:	ade50513          	addi	a0,a0,-1314 # 80008840 <syscall_list+0x290>
    80004d6a:	ffffb097          	auipc	ra,0xffffb
    80004d6e:	7dc080e7          	jalr	2012(ra) # 80000546 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d72:	874a                	mv	a4,s2
    80004d74:	009c86bb          	addw	a3,s9,s1
    80004d78:	4581                	li	a1,0
    80004d7a:	8556                	mv	a0,s5
    80004d7c:	fffff097          	auipc	ra,0xfffff
    80004d80:	c7e080e7          	jalr	-898(ra) # 800039fa <readi>
    80004d84:	2501                	sext.w	a0,a0
    80004d86:	1aa91863          	bne	s2,a0,80004f36 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004d8a:	009d84bb          	addw	s1,s11,s1
    80004d8e:	013d09bb          	addw	s3,s10,s3
    80004d92:	1f74f263          	bgeu	s1,s7,80004f76 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004d96:	02049593          	slli	a1,s1,0x20
    80004d9a:	9181                	srli	a1,a1,0x20
    80004d9c:	95e2                	add	a1,a1,s8
    80004d9e:	855a                	mv	a0,s6
    80004da0:	ffffc097          	auipc	ra,0xffffc
    80004da4:	334080e7          	jalr	820(ra) # 800010d4 <walkaddr>
    80004da8:	862a                	mv	a2,a0
    if(pa == 0)
    80004daa:	dd45                	beqz	a0,80004d62 <exec+0xfe>
      n = PGSIZE;
    80004dac:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004dae:	fd49f2e3          	bgeu	s3,s4,80004d72 <exec+0x10e>
      n = sz - i;
    80004db2:	894e                	mv	s2,s3
    80004db4:	bf7d                	j	80004d72 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004db6:	4481                	li	s1,0
  iunlockput(ip);
    80004db8:	8556                	mv	a0,s5
    80004dba:	fffff097          	auipc	ra,0xfffff
    80004dbe:	bee080e7          	jalr	-1042(ra) # 800039a8 <iunlockput>
  end_op();
    80004dc2:	fffff097          	auipc	ra,0xfffff
    80004dc6:	3c8080e7          	jalr	968(ra) # 8000418a <end_op>
  p = myproc();
    80004dca:	ffffd097          	auipc	ra,0xffffd
    80004dce:	c4c080e7          	jalr	-948(ra) # 80001a16 <myproc>
    80004dd2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004dd4:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004dd8:	6785                	lui	a5,0x1
    80004dda:	17fd                	addi	a5,a5,-1
    80004ddc:	97a6                	add	a5,a5,s1
    80004dde:	777d                	lui	a4,0xfffff
    80004de0:	8ff9                	and	a5,a5,a4
    80004de2:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004de6:	6609                	lui	a2,0x2
    80004de8:	963e                	add	a2,a2,a5
    80004dea:	85be                	mv	a1,a5
    80004dec:	855a                	mv	a0,s6
    80004dee:	ffffc097          	auipc	ra,0xffffc
    80004df2:	6ca080e7          	jalr	1738(ra) # 800014b8 <uvmalloc>
    80004df6:	8c2a                	mv	s8,a0
  ip = 0;
    80004df8:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004dfa:	12050e63          	beqz	a0,80004f36 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004dfe:	75f9                	lui	a1,0xffffe
    80004e00:	95aa                	add	a1,a1,a0
    80004e02:	855a                	mv	a0,s6
    80004e04:	ffffd097          	auipc	ra,0xffffd
    80004e08:	8d6080e7          	jalr	-1834(ra) # 800016da <uvmclear>
  stackbase = sp - PGSIZE;
    80004e0c:	7afd                	lui	s5,0xfffff
    80004e0e:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e10:	df043783          	ld	a5,-528(s0)
    80004e14:	6388                	ld	a0,0(a5)
    80004e16:	c925                	beqz	a0,80004e86 <exec+0x222>
    80004e18:	e8840993          	addi	s3,s0,-376
    80004e1c:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004e20:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e22:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004e24:	ffffc097          	auipc	ra,0xffffc
    80004e28:	0a6080e7          	jalr	166(ra) # 80000eca <strlen>
    80004e2c:	0015079b          	addiw	a5,a0,1
    80004e30:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e34:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004e38:	13596363          	bltu	s2,s5,80004f5e <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e3c:	df043d83          	ld	s11,-528(s0)
    80004e40:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004e44:	8552                	mv	a0,s4
    80004e46:	ffffc097          	auipc	ra,0xffffc
    80004e4a:	084080e7          	jalr	132(ra) # 80000eca <strlen>
    80004e4e:	0015069b          	addiw	a3,a0,1
    80004e52:	8652                	mv	a2,s4
    80004e54:	85ca                	mv	a1,s2
    80004e56:	855a                	mv	a0,s6
    80004e58:	ffffd097          	auipc	ra,0xffffd
    80004e5c:	8b4080e7          	jalr	-1868(ra) # 8000170c <copyout>
    80004e60:	10054363          	bltz	a0,80004f66 <exec+0x302>
    ustack[argc] = sp;
    80004e64:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e68:	0485                	addi	s1,s1,1
    80004e6a:	008d8793          	addi	a5,s11,8
    80004e6e:	def43823          	sd	a5,-528(s0)
    80004e72:	008db503          	ld	a0,8(s11)
    80004e76:	c911                	beqz	a0,80004e8a <exec+0x226>
    if(argc >= MAXARG)
    80004e78:	09a1                	addi	s3,s3,8
    80004e7a:	fb3c95e3          	bne	s9,s3,80004e24 <exec+0x1c0>
  sz = sz1;
    80004e7e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004e82:	4a81                	li	s5,0
    80004e84:	a84d                	j	80004f36 <exec+0x2d2>
  sp = sz;
    80004e86:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e88:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e8a:	00349793          	slli	a5,s1,0x3
    80004e8e:	f9078793          	addi	a5,a5,-112 # f90 <_entry-0x7ffff070>
    80004e92:	97a2                	add	a5,a5,s0
    80004e94:	ee07bc23          	sd	zero,-264(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e98:	00148693          	addi	a3,s1,1
    80004e9c:	068e                	slli	a3,a3,0x3
    80004e9e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004ea2:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004ea6:	01597663          	bgeu	s2,s5,80004eb2 <exec+0x24e>
  sz = sz1;
    80004eaa:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eae:	4a81                	li	s5,0
    80004eb0:	a059                	j	80004f36 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004eb2:	e8840613          	addi	a2,s0,-376
    80004eb6:	85ca                	mv	a1,s2
    80004eb8:	855a                	mv	a0,s6
    80004eba:	ffffd097          	auipc	ra,0xffffd
    80004ebe:	852080e7          	jalr	-1966(ra) # 8000170c <copyout>
    80004ec2:	0a054663          	bltz	a0,80004f6e <exec+0x30a>
  p->trapframe->a1 = sp;
    80004ec6:	058bb783          	ld	a5,88(s7)
    80004eca:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004ece:	de843783          	ld	a5,-536(s0)
    80004ed2:	0007c703          	lbu	a4,0(a5)
    80004ed6:	cf11                	beqz	a4,80004ef2 <exec+0x28e>
    80004ed8:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004eda:	02f00693          	li	a3,47
    80004ede:	a039                	j	80004eec <exec+0x288>
      last = s+1;
    80004ee0:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004ee4:	0785                	addi	a5,a5,1
    80004ee6:	fff7c703          	lbu	a4,-1(a5)
    80004eea:	c701                	beqz	a4,80004ef2 <exec+0x28e>
    if(*s == '/')
    80004eec:	fed71ce3          	bne	a4,a3,80004ee4 <exec+0x280>
    80004ef0:	bfc5                	j	80004ee0 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004ef2:	4641                	li	a2,16
    80004ef4:	de843583          	ld	a1,-536(s0)
    80004ef8:	158b8513          	addi	a0,s7,344
    80004efc:	ffffc097          	auipc	ra,0xffffc
    80004f00:	f9c080e7          	jalr	-100(ra) # 80000e98 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f04:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004f08:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004f0c:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f10:	058bb783          	ld	a5,88(s7)
    80004f14:	e6043703          	ld	a4,-416(s0)
    80004f18:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f1a:	058bb783          	ld	a5,88(s7)
    80004f1e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f22:	85ea                	mv	a1,s10
    80004f24:	ffffd097          	auipc	ra,0xffffd
    80004f28:	c52080e7          	jalr	-942(ra) # 80001b76 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f2c:	0004851b          	sext.w	a0,s1
    80004f30:	bbc1                	j	80004d00 <exec+0x9c>
    80004f32:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004f36:	df843583          	ld	a1,-520(s0)
    80004f3a:	855a                	mv	a0,s6
    80004f3c:	ffffd097          	auipc	ra,0xffffd
    80004f40:	c3a080e7          	jalr	-966(ra) # 80001b76 <proc_freepagetable>
  if(ip){
    80004f44:	da0a94e3          	bnez	s5,80004cec <exec+0x88>
  return -1;
    80004f48:	557d                	li	a0,-1
    80004f4a:	bb5d                	j	80004d00 <exec+0x9c>
    80004f4c:	de943c23          	sd	s1,-520(s0)
    80004f50:	b7dd                	j	80004f36 <exec+0x2d2>
    80004f52:	de943c23          	sd	s1,-520(s0)
    80004f56:	b7c5                	j	80004f36 <exec+0x2d2>
    80004f58:	de943c23          	sd	s1,-520(s0)
    80004f5c:	bfe9                	j	80004f36 <exec+0x2d2>
  sz = sz1;
    80004f5e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f62:	4a81                	li	s5,0
    80004f64:	bfc9                	j	80004f36 <exec+0x2d2>
  sz = sz1;
    80004f66:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f6a:	4a81                	li	s5,0
    80004f6c:	b7e9                	j	80004f36 <exec+0x2d2>
  sz = sz1;
    80004f6e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f72:	4a81                	li	s5,0
    80004f74:	b7c9                	j	80004f36 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004f76:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f7a:	e0843783          	ld	a5,-504(s0)
    80004f7e:	0017869b          	addiw	a3,a5,1
    80004f82:	e0d43423          	sd	a3,-504(s0)
    80004f86:	e0043783          	ld	a5,-512(s0)
    80004f8a:	0387879b          	addiw	a5,a5,56
    80004f8e:	e8045703          	lhu	a4,-384(s0)
    80004f92:	e2e6d3e3          	bge	a3,a4,80004db8 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f96:	2781                	sext.w	a5,a5
    80004f98:	e0f43023          	sd	a5,-512(s0)
    80004f9c:	03800713          	li	a4,56
    80004fa0:	86be                	mv	a3,a5
    80004fa2:	e1040613          	addi	a2,s0,-496
    80004fa6:	4581                	li	a1,0
    80004fa8:	8556                	mv	a0,s5
    80004faa:	fffff097          	auipc	ra,0xfffff
    80004fae:	a50080e7          	jalr	-1456(ra) # 800039fa <readi>
    80004fb2:	03800793          	li	a5,56
    80004fb6:	f6f51ee3          	bne	a0,a5,80004f32 <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80004fba:	e1042783          	lw	a5,-496(s0)
    80004fbe:	4705                	li	a4,1
    80004fc0:	fae79de3          	bne	a5,a4,80004f7a <exec+0x316>
    if(ph.memsz < ph.filesz)
    80004fc4:	e3843603          	ld	a2,-456(s0)
    80004fc8:	e3043783          	ld	a5,-464(s0)
    80004fcc:	f8f660e3          	bltu	a2,a5,80004f4c <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fd0:	e2043783          	ld	a5,-480(s0)
    80004fd4:	963e                	add	a2,a2,a5
    80004fd6:	f6f66ee3          	bltu	a2,a5,80004f52 <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fda:	85a6                	mv	a1,s1
    80004fdc:	855a                	mv	a0,s6
    80004fde:	ffffc097          	auipc	ra,0xffffc
    80004fe2:	4da080e7          	jalr	1242(ra) # 800014b8 <uvmalloc>
    80004fe6:	dea43c23          	sd	a0,-520(s0)
    80004fea:	d53d                	beqz	a0,80004f58 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80004fec:	e2043c03          	ld	s8,-480(s0)
    80004ff0:	de043783          	ld	a5,-544(s0)
    80004ff4:	00fc77b3          	and	a5,s8,a5
    80004ff8:	ff9d                	bnez	a5,80004f36 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ffa:	e1842c83          	lw	s9,-488(s0)
    80004ffe:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005002:	f60b8ae3          	beqz	s7,80004f76 <exec+0x312>
    80005006:	89de                	mv	s3,s7
    80005008:	4481                	li	s1,0
    8000500a:	b371                	j	80004d96 <exec+0x132>

000000008000500c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000500c:	7179                	addi	sp,sp,-48
    8000500e:	f406                	sd	ra,40(sp)
    80005010:	f022                	sd	s0,32(sp)
    80005012:	ec26                	sd	s1,24(sp)
    80005014:	e84a                	sd	s2,16(sp)
    80005016:	1800                	addi	s0,sp,48
    80005018:	892e                	mv	s2,a1
    8000501a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    8000501c:	fdc40593          	addi	a1,s0,-36
    80005020:	ffffe097          	auipc	ra,0xffffe
    80005024:	ae8080e7          	jalr	-1304(ra) # 80002b08 <argint>
    80005028:	04054063          	bltz	a0,80005068 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000502c:	fdc42703          	lw	a4,-36(s0)
    80005030:	47bd                	li	a5,15
    80005032:	02e7ed63          	bltu	a5,a4,8000506c <argfd+0x60>
    80005036:	ffffd097          	auipc	ra,0xffffd
    8000503a:	9e0080e7          	jalr	-1568(ra) # 80001a16 <myproc>
    8000503e:	fdc42703          	lw	a4,-36(s0)
    80005042:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd901a>
    80005046:	078e                	slli	a5,a5,0x3
    80005048:	953e                	add	a0,a0,a5
    8000504a:	611c                	ld	a5,0(a0)
    8000504c:	c395                	beqz	a5,80005070 <argfd+0x64>
    return -1;
  if(pfd)
    8000504e:	00090463          	beqz	s2,80005056 <argfd+0x4a>
    *pfd = fd;
    80005052:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005056:	4501                	li	a0,0
  if(pf)
    80005058:	c091                	beqz	s1,8000505c <argfd+0x50>
    *pf = f;
    8000505a:	e09c                	sd	a5,0(s1)
}
    8000505c:	70a2                	ld	ra,40(sp)
    8000505e:	7402                	ld	s0,32(sp)
    80005060:	64e2                	ld	s1,24(sp)
    80005062:	6942                	ld	s2,16(sp)
    80005064:	6145                	addi	sp,sp,48
    80005066:	8082                	ret
    return -1;
    80005068:	557d                	li	a0,-1
    8000506a:	bfcd                	j	8000505c <argfd+0x50>
    return -1;
    8000506c:	557d                	li	a0,-1
    8000506e:	b7fd                	j	8000505c <argfd+0x50>
    80005070:	557d                	li	a0,-1
    80005072:	b7ed                	j	8000505c <argfd+0x50>

0000000080005074 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005074:	1101                	addi	sp,sp,-32
    80005076:	ec06                	sd	ra,24(sp)
    80005078:	e822                	sd	s0,16(sp)
    8000507a:	e426                	sd	s1,8(sp)
    8000507c:	1000                	addi	s0,sp,32
    8000507e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005080:	ffffd097          	auipc	ra,0xffffd
    80005084:	996080e7          	jalr	-1642(ra) # 80001a16 <myproc>
    80005088:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000508a:	0d050793          	addi	a5,a0,208
    8000508e:	4501                	li	a0,0
    80005090:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005092:	6398                	ld	a4,0(a5)
    80005094:	cb19                	beqz	a4,800050aa <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005096:	2505                	addiw	a0,a0,1
    80005098:	07a1                	addi	a5,a5,8
    8000509a:	fed51ce3          	bne	a0,a3,80005092 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000509e:	557d                	li	a0,-1
}
    800050a0:	60e2                	ld	ra,24(sp)
    800050a2:	6442                	ld	s0,16(sp)
    800050a4:	64a2                	ld	s1,8(sp)
    800050a6:	6105                	addi	sp,sp,32
    800050a8:	8082                	ret
      p->ofile[fd] = f;
    800050aa:	01a50793          	addi	a5,a0,26
    800050ae:	078e                	slli	a5,a5,0x3
    800050b0:	963e                	add	a2,a2,a5
    800050b2:	e204                	sd	s1,0(a2)
      return fd;
    800050b4:	b7f5                	j	800050a0 <fdalloc+0x2c>

00000000800050b6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050b6:	715d                	addi	sp,sp,-80
    800050b8:	e486                	sd	ra,72(sp)
    800050ba:	e0a2                	sd	s0,64(sp)
    800050bc:	fc26                	sd	s1,56(sp)
    800050be:	f84a                	sd	s2,48(sp)
    800050c0:	f44e                	sd	s3,40(sp)
    800050c2:	f052                	sd	s4,32(sp)
    800050c4:	ec56                	sd	s5,24(sp)
    800050c6:	0880                	addi	s0,sp,80
    800050c8:	89ae                	mv	s3,a1
    800050ca:	8ab2                	mv	s5,a2
    800050cc:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050ce:	fb040593          	addi	a1,s0,-80
    800050d2:	fffff097          	auipc	ra,0xfffff
    800050d6:	e48080e7          	jalr	-440(ra) # 80003f1a <nameiparent>
    800050da:	892a                	mv	s2,a0
    800050dc:	12050e63          	beqz	a0,80005218 <create+0x162>
    return 0;

  ilock(dp);
    800050e0:	ffffe097          	auipc	ra,0xffffe
    800050e4:	666080e7          	jalr	1638(ra) # 80003746 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050e8:	4601                	li	a2,0
    800050ea:	fb040593          	addi	a1,s0,-80
    800050ee:	854a                	mv	a0,s2
    800050f0:	fffff097          	auipc	ra,0xfffff
    800050f4:	b34080e7          	jalr	-1228(ra) # 80003c24 <dirlookup>
    800050f8:	84aa                	mv	s1,a0
    800050fa:	c921                	beqz	a0,8000514a <create+0x94>
    iunlockput(dp);
    800050fc:	854a                	mv	a0,s2
    800050fe:	fffff097          	auipc	ra,0xfffff
    80005102:	8aa080e7          	jalr	-1878(ra) # 800039a8 <iunlockput>
    ilock(ip);
    80005106:	8526                	mv	a0,s1
    80005108:	ffffe097          	auipc	ra,0xffffe
    8000510c:	63e080e7          	jalr	1598(ra) # 80003746 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005110:	2981                	sext.w	s3,s3
    80005112:	4789                	li	a5,2
    80005114:	02f99463          	bne	s3,a5,8000513c <create+0x86>
    80005118:	0444d783          	lhu	a5,68(s1)
    8000511c:	37f9                	addiw	a5,a5,-2
    8000511e:	17c2                	slli	a5,a5,0x30
    80005120:	93c1                	srli	a5,a5,0x30
    80005122:	4705                	li	a4,1
    80005124:	00f76c63          	bltu	a4,a5,8000513c <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005128:	8526                	mv	a0,s1
    8000512a:	60a6                	ld	ra,72(sp)
    8000512c:	6406                	ld	s0,64(sp)
    8000512e:	74e2                	ld	s1,56(sp)
    80005130:	7942                	ld	s2,48(sp)
    80005132:	79a2                	ld	s3,40(sp)
    80005134:	7a02                	ld	s4,32(sp)
    80005136:	6ae2                	ld	s5,24(sp)
    80005138:	6161                	addi	sp,sp,80
    8000513a:	8082                	ret
    iunlockput(ip);
    8000513c:	8526                	mv	a0,s1
    8000513e:	fffff097          	auipc	ra,0xfffff
    80005142:	86a080e7          	jalr	-1942(ra) # 800039a8 <iunlockput>
    return 0;
    80005146:	4481                	li	s1,0
    80005148:	b7c5                	j	80005128 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000514a:	85ce                	mv	a1,s3
    8000514c:	00092503          	lw	a0,0(s2)
    80005150:	ffffe097          	auipc	ra,0xffffe
    80005154:	45c080e7          	jalr	1116(ra) # 800035ac <ialloc>
    80005158:	84aa                	mv	s1,a0
    8000515a:	c521                	beqz	a0,800051a2 <create+0xec>
  ilock(ip);
    8000515c:	ffffe097          	auipc	ra,0xffffe
    80005160:	5ea080e7          	jalr	1514(ra) # 80003746 <ilock>
  ip->major = major;
    80005164:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005168:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000516c:	4a05                	li	s4,1
    8000516e:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    80005172:	8526                	mv	a0,s1
    80005174:	ffffe097          	auipc	ra,0xffffe
    80005178:	506080e7          	jalr	1286(ra) # 8000367a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000517c:	2981                	sext.w	s3,s3
    8000517e:	03498a63          	beq	s3,s4,800051b2 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005182:	40d0                	lw	a2,4(s1)
    80005184:	fb040593          	addi	a1,s0,-80
    80005188:	854a                	mv	a0,s2
    8000518a:	fffff097          	auipc	ra,0xfffff
    8000518e:	cb0080e7          	jalr	-848(ra) # 80003e3a <dirlink>
    80005192:	06054b63          	bltz	a0,80005208 <create+0x152>
  iunlockput(dp);
    80005196:	854a                	mv	a0,s2
    80005198:	fffff097          	auipc	ra,0xfffff
    8000519c:	810080e7          	jalr	-2032(ra) # 800039a8 <iunlockput>
  return ip;
    800051a0:	b761                	j	80005128 <create+0x72>
    panic("create: ialloc");
    800051a2:	00003517          	auipc	a0,0x3
    800051a6:	6be50513          	addi	a0,a0,1726 # 80008860 <syscall_list+0x2b0>
    800051aa:	ffffb097          	auipc	ra,0xffffb
    800051ae:	39c080e7          	jalr	924(ra) # 80000546 <panic>
    dp->nlink++;  // for ".."
    800051b2:	04a95783          	lhu	a5,74(s2)
    800051b6:	2785                	addiw	a5,a5,1
    800051b8:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800051bc:	854a                	mv	a0,s2
    800051be:	ffffe097          	auipc	ra,0xffffe
    800051c2:	4bc080e7          	jalr	1212(ra) # 8000367a <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051c6:	40d0                	lw	a2,4(s1)
    800051c8:	00003597          	auipc	a1,0x3
    800051cc:	6a858593          	addi	a1,a1,1704 # 80008870 <syscall_list+0x2c0>
    800051d0:	8526                	mv	a0,s1
    800051d2:	fffff097          	auipc	ra,0xfffff
    800051d6:	c68080e7          	jalr	-920(ra) # 80003e3a <dirlink>
    800051da:	00054f63          	bltz	a0,800051f8 <create+0x142>
    800051de:	00492603          	lw	a2,4(s2)
    800051e2:	00003597          	auipc	a1,0x3
    800051e6:	69658593          	addi	a1,a1,1686 # 80008878 <syscall_list+0x2c8>
    800051ea:	8526                	mv	a0,s1
    800051ec:	fffff097          	auipc	ra,0xfffff
    800051f0:	c4e080e7          	jalr	-946(ra) # 80003e3a <dirlink>
    800051f4:	f80557e3          	bgez	a0,80005182 <create+0xcc>
      panic("create dots");
    800051f8:	00003517          	auipc	a0,0x3
    800051fc:	68850513          	addi	a0,a0,1672 # 80008880 <syscall_list+0x2d0>
    80005200:	ffffb097          	auipc	ra,0xffffb
    80005204:	346080e7          	jalr	838(ra) # 80000546 <panic>
    panic("create: dirlink");
    80005208:	00003517          	auipc	a0,0x3
    8000520c:	68850513          	addi	a0,a0,1672 # 80008890 <syscall_list+0x2e0>
    80005210:	ffffb097          	auipc	ra,0xffffb
    80005214:	336080e7          	jalr	822(ra) # 80000546 <panic>
    return 0;
    80005218:	84aa                	mv	s1,a0
    8000521a:	b739                	j	80005128 <create+0x72>

000000008000521c <sys_dup>:
{
    8000521c:	7179                	addi	sp,sp,-48
    8000521e:	f406                	sd	ra,40(sp)
    80005220:	f022                	sd	s0,32(sp)
    80005222:	ec26                	sd	s1,24(sp)
    80005224:	e84a                	sd	s2,16(sp)
    80005226:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005228:	fd840613          	addi	a2,s0,-40
    8000522c:	4581                	li	a1,0
    8000522e:	4501                	li	a0,0
    80005230:	00000097          	auipc	ra,0x0
    80005234:	ddc080e7          	jalr	-548(ra) # 8000500c <argfd>
    return -1;
    80005238:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000523a:	02054363          	bltz	a0,80005260 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000523e:	fd843903          	ld	s2,-40(s0)
    80005242:	854a                	mv	a0,s2
    80005244:	00000097          	auipc	ra,0x0
    80005248:	e30080e7          	jalr	-464(ra) # 80005074 <fdalloc>
    8000524c:	84aa                	mv	s1,a0
    return -1;
    8000524e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005250:	00054863          	bltz	a0,80005260 <sys_dup+0x44>
  filedup(f);
    80005254:	854a                	mv	a0,s2
    80005256:	fffff097          	auipc	ra,0xfffff
    8000525a:	332080e7          	jalr	818(ra) # 80004588 <filedup>
  return fd;
    8000525e:	87a6                	mv	a5,s1
}
    80005260:	853e                	mv	a0,a5
    80005262:	70a2                	ld	ra,40(sp)
    80005264:	7402                	ld	s0,32(sp)
    80005266:	64e2                	ld	s1,24(sp)
    80005268:	6942                	ld	s2,16(sp)
    8000526a:	6145                	addi	sp,sp,48
    8000526c:	8082                	ret

000000008000526e <sys_read>:
{
    8000526e:	7179                	addi	sp,sp,-48
    80005270:	f406                	sd	ra,40(sp)
    80005272:	f022                	sd	s0,32(sp)
    80005274:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005276:	fe840613          	addi	a2,s0,-24
    8000527a:	4581                	li	a1,0
    8000527c:	4501                	li	a0,0
    8000527e:	00000097          	auipc	ra,0x0
    80005282:	d8e080e7          	jalr	-626(ra) # 8000500c <argfd>
    return -1;
    80005286:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005288:	04054163          	bltz	a0,800052ca <sys_read+0x5c>
    8000528c:	fe440593          	addi	a1,s0,-28
    80005290:	4509                	li	a0,2
    80005292:	ffffe097          	auipc	ra,0xffffe
    80005296:	876080e7          	jalr	-1930(ra) # 80002b08 <argint>
    return -1;
    8000529a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000529c:	02054763          	bltz	a0,800052ca <sys_read+0x5c>
    800052a0:	fd840593          	addi	a1,s0,-40
    800052a4:	4505                	li	a0,1
    800052a6:	ffffe097          	auipc	ra,0xffffe
    800052aa:	884080e7          	jalr	-1916(ra) # 80002b2a <argaddr>
    return -1;
    800052ae:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052b0:	00054d63          	bltz	a0,800052ca <sys_read+0x5c>
  return fileread(f, p, n);
    800052b4:	fe442603          	lw	a2,-28(s0)
    800052b8:	fd843583          	ld	a1,-40(s0)
    800052bc:	fe843503          	ld	a0,-24(s0)
    800052c0:	fffff097          	auipc	ra,0xfffff
    800052c4:	454080e7          	jalr	1108(ra) # 80004714 <fileread>
    800052c8:	87aa                	mv	a5,a0
}
    800052ca:	853e                	mv	a0,a5
    800052cc:	70a2                	ld	ra,40(sp)
    800052ce:	7402                	ld	s0,32(sp)
    800052d0:	6145                	addi	sp,sp,48
    800052d2:	8082                	ret

00000000800052d4 <sys_write>:
{
    800052d4:	7179                	addi	sp,sp,-48
    800052d6:	f406                	sd	ra,40(sp)
    800052d8:	f022                	sd	s0,32(sp)
    800052da:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052dc:	fe840613          	addi	a2,s0,-24
    800052e0:	4581                	li	a1,0
    800052e2:	4501                	li	a0,0
    800052e4:	00000097          	auipc	ra,0x0
    800052e8:	d28080e7          	jalr	-728(ra) # 8000500c <argfd>
    return -1;
    800052ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052ee:	04054163          	bltz	a0,80005330 <sys_write+0x5c>
    800052f2:	fe440593          	addi	a1,s0,-28
    800052f6:	4509                	li	a0,2
    800052f8:	ffffe097          	auipc	ra,0xffffe
    800052fc:	810080e7          	jalr	-2032(ra) # 80002b08 <argint>
    return -1;
    80005300:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005302:	02054763          	bltz	a0,80005330 <sys_write+0x5c>
    80005306:	fd840593          	addi	a1,s0,-40
    8000530a:	4505                	li	a0,1
    8000530c:	ffffe097          	auipc	ra,0xffffe
    80005310:	81e080e7          	jalr	-2018(ra) # 80002b2a <argaddr>
    return -1;
    80005314:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005316:	00054d63          	bltz	a0,80005330 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000531a:	fe442603          	lw	a2,-28(s0)
    8000531e:	fd843583          	ld	a1,-40(s0)
    80005322:	fe843503          	ld	a0,-24(s0)
    80005326:	fffff097          	auipc	ra,0xfffff
    8000532a:	4b0080e7          	jalr	1200(ra) # 800047d6 <filewrite>
    8000532e:	87aa                	mv	a5,a0
}
    80005330:	853e                	mv	a0,a5
    80005332:	70a2                	ld	ra,40(sp)
    80005334:	7402                	ld	s0,32(sp)
    80005336:	6145                	addi	sp,sp,48
    80005338:	8082                	ret

000000008000533a <sys_close>:
{
    8000533a:	1101                	addi	sp,sp,-32
    8000533c:	ec06                	sd	ra,24(sp)
    8000533e:	e822                	sd	s0,16(sp)
    80005340:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005342:	fe040613          	addi	a2,s0,-32
    80005346:	fec40593          	addi	a1,s0,-20
    8000534a:	4501                	li	a0,0
    8000534c:	00000097          	auipc	ra,0x0
    80005350:	cc0080e7          	jalr	-832(ra) # 8000500c <argfd>
    return -1;
    80005354:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005356:	02054463          	bltz	a0,8000537e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000535a:	ffffc097          	auipc	ra,0xffffc
    8000535e:	6bc080e7          	jalr	1724(ra) # 80001a16 <myproc>
    80005362:	fec42783          	lw	a5,-20(s0)
    80005366:	07e9                	addi	a5,a5,26
    80005368:	078e                	slli	a5,a5,0x3
    8000536a:	953e                	add	a0,a0,a5
    8000536c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005370:	fe043503          	ld	a0,-32(s0)
    80005374:	fffff097          	auipc	ra,0xfffff
    80005378:	266080e7          	jalr	614(ra) # 800045da <fileclose>
  return 0;
    8000537c:	4781                	li	a5,0
}
    8000537e:	853e                	mv	a0,a5
    80005380:	60e2                	ld	ra,24(sp)
    80005382:	6442                	ld	s0,16(sp)
    80005384:	6105                	addi	sp,sp,32
    80005386:	8082                	ret

0000000080005388 <sys_fstat>:
{
    80005388:	1101                	addi	sp,sp,-32
    8000538a:	ec06                	sd	ra,24(sp)
    8000538c:	e822                	sd	s0,16(sp)
    8000538e:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005390:	fe840613          	addi	a2,s0,-24
    80005394:	4581                	li	a1,0
    80005396:	4501                	li	a0,0
    80005398:	00000097          	auipc	ra,0x0
    8000539c:	c74080e7          	jalr	-908(ra) # 8000500c <argfd>
    return -1;
    800053a0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053a2:	02054563          	bltz	a0,800053cc <sys_fstat+0x44>
    800053a6:	fe040593          	addi	a1,s0,-32
    800053aa:	4505                	li	a0,1
    800053ac:	ffffd097          	auipc	ra,0xffffd
    800053b0:	77e080e7          	jalr	1918(ra) # 80002b2a <argaddr>
    return -1;
    800053b4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053b6:	00054b63          	bltz	a0,800053cc <sys_fstat+0x44>
  return filestat(f, st);
    800053ba:	fe043583          	ld	a1,-32(s0)
    800053be:	fe843503          	ld	a0,-24(s0)
    800053c2:	fffff097          	auipc	ra,0xfffff
    800053c6:	2e0080e7          	jalr	736(ra) # 800046a2 <filestat>
    800053ca:	87aa                	mv	a5,a0
}
    800053cc:	853e                	mv	a0,a5
    800053ce:	60e2                	ld	ra,24(sp)
    800053d0:	6442                	ld	s0,16(sp)
    800053d2:	6105                	addi	sp,sp,32
    800053d4:	8082                	ret

00000000800053d6 <sys_link>:
{
    800053d6:	7169                	addi	sp,sp,-304
    800053d8:	f606                	sd	ra,296(sp)
    800053da:	f222                	sd	s0,288(sp)
    800053dc:	ee26                	sd	s1,280(sp)
    800053de:	ea4a                	sd	s2,272(sp)
    800053e0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053e2:	08000613          	li	a2,128
    800053e6:	ed040593          	addi	a1,s0,-304
    800053ea:	4501                	li	a0,0
    800053ec:	ffffd097          	auipc	ra,0xffffd
    800053f0:	760080e7          	jalr	1888(ra) # 80002b4c <argstr>
    return -1;
    800053f4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053f6:	10054e63          	bltz	a0,80005512 <sys_link+0x13c>
    800053fa:	08000613          	li	a2,128
    800053fe:	f5040593          	addi	a1,s0,-176
    80005402:	4505                	li	a0,1
    80005404:	ffffd097          	auipc	ra,0xffffd
    80005408:	748080e7          	jalr	1864(ra) # 80002b4c <argstr>
    return -1;
    8000540c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000540e:	10054263          	bltz	a0,80005512 <sys_link+0x13c>
  begin_op();
    80005412:	fffff097          	auipc	ra,0xfffff
    80005416:	cfa080e7          	jalr	-774(ra) # 8000410c <begin_op>
  if((ip = namei(old)) == 0){
    8000541a:	ed040513          	addi	a0,s0,-304
    8000541e:	fffff097          	auipc	ra,0xfffff
    80005422:	ade080e7          	jalr	-1314(ra) # 80003efc <namei>
    80005426:	84aa                	mv	s1,a0
    80005428:	c551                	beqz	a0,800054b4 <sys_link+0xde>
  ilock(ip);
    8000542a:	ffffe097          	auipc	ra,0xffffe
    8000542e:	31c080e7          	jalr	796(ra) # 80003746 <ilock>
  if(ip->type == T_DIR){
    80005432:	04449703          	lh	a4,68(s1)
    80005436:	4785                	li	a5,1
    80005438:	08f70463          	beq	a4,a5,800054c0 <sys_link+0xea>
  ip->nlink++;
    8000543c:	04a4d783          	lhu	a5,74(s1)
    80005440:	2785                	addiw	a5,a5,1
    80005442:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005446:	8526                	mv	a0,s1
    80005448:	ffffe097          	auipc	ra,0xffffe
    8000544c:	232080e7          	jalr	562(ra) # 8000367a <iupdate>
  iunlock(ip);
    80005450:	8526                	mv	a0,s1
    80005452:	ffffe097          	auipc	ra,0xffffe
    80005456:	3b6080e7          	jalr	950(ra) # 80003808 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000545a:	fd040593          	addi	a1,s0,-48
    8000545e:	f5040513          	addi	a0,s0,-176
    80005462:	fffff097          	auipc	ra,0xfffff
    80005466:	ab8080e7          	jalr	-1352(ra) # 80003f1a <nameiparent>
    8000546a:	892a                	mv	s2,a0
    8000546c:	c935                	beqz	a0,800054e0 <sys_link+0x10a>
  ilock(dp);
    8000546e:	ffffe097          	auipc	ra,0xffffe
    80005472:	2d8080e7          	jalr	728(ra) # 80003746 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005476:	00092703          	lw	a4,0(s2)
    8000547a:	409c                	lw	a5,0(s1)
    8000547c:	04f71d63          	bne	a4,a5,800054d6 <sys_link+0x100>
    80005480:	40d0                	lw	a2,4(s1)
    80005482:	fd040593          	addi	a1,s0,-48
    80005486:	854a                	mv	a0,s2
    80005488:	fffff097          	auipc	ra,0xfffff
    8000548c:	9b2080e7          	jalr	-1614(ra) # 80003e3a <dirlink>
    80005490:	04054363          	bltz	a0,800054d6 <sys_link+0x100>
  iunlockput(dp);
    80005494:	854a                	mv	a0,s2
    80005496:	ffffe097          	auipc	ra,0xffffe
    8000549a:	512080e7          	jalr	1298(ra) # 800039a8 <iunlockput>
  iput(ip);
    8000549e:	8526                	mv	a0,s1
    800054a0:	ffffe097          	auipc	ra,0xffffe
    800054a4:	460080e7          	jalr	1120(ra) # 80003900 <iput>
  end_op();
    800054a8:	fffff097          	auipc	ra,0xfffff
    800054ac:	ce2080e7          	jalr	-798(ra) # 8000418a <end_op>
  return 0;
    800054b0:	4781                	li	a5,0
    800054b2:	a085                	j	80005512 <sys_link+0x13c>
    end_op();
    800054b4:	fffff097          	auipc	ra,0xfffff
    800054b8:	cd6080e7          	jalr	-810(ra) # 8000418a <end_op>
    return -1;
    800054bc:	57fd                	li	a5,-1
    800054be:	a891                	j	80005512 <sys_link+0x13c>
    iunlockput(ip);
    800054c0:	8526                	mv	a0,s1
    800054c2:	ffffe097          	auipc	ra,0xffffe
    800054c6:	4e6080e7          	jalr	1254(ra) # 800039a8 <iunlockput>
    end_op();
    800054ca:	fffff097          	auipc	ra,0xfffff
    800054ce:	cc0080e7          	jalr	-832(ra) # 8000418a <end_op>
    return -1;
    800054d2:	57fd                	li	a5,-1
    800054d4:	a83d                	j	80005512 <sys_link+0x13c>
    iunlockput(dp);
    800054d6:	854a                	mv	a0,s2
    800054d8:	ffffe097          	auipc	ra,0xffffe
    800054dc:	4d0080e7          	jalr	1232(ra) # 800039a8 <iunlockput>
  ilock(ip);
    800054e0:	8526                	mv	a0,s1
    800054e2:	ffffe097          	auipc	ra,0xffffe
    800054e6:	264080e7          	jalr	612(ra) # 80003746 <ilock>
  ip->nlink--;
    800054ea:	04a4d783          	lhu	a5,74(s1)
    800054ee:	37fd                	addiw	a5,a5,-1
    800054f0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054f4:	8526                	mv	a0,s1
    800054f6:	ffffe097          	auipc	ra,0xffffe
    800054fa:	184080e7          	jalr	388(ra) # 8000367a <iupdate>
  iunlockput(ip);
    800054fe:	8526                	mv	a0,s1
    80005500:	ffffe097          	auipc	ra,0xffffe
    80005504:	4a8080e7          	jalr	1192(ra) # 800039a8 <iunlockput>
  end_op();
    80005508:	fffff097          	auipc	ra,0xfffff
    8000550c:	c82080e7          	jalr	-894(ra) # 8000418a <end_op>
  return -1;
    80005510:	57fd                	li	a5,-1
}
    80005512:	853e                	mv	a0,a5
    80005514:	70b2                	ld	ra,296(sp)
    80005516:	7412                	ld	s0,288(sp)
    80005518:	64f2                	ld	s1,280(sp)
    8000551a:	6952                	ld	s2,272(sp)
    8000551c:	6155                	addi	sp,sp,304
    8000551e:	8082                	ret

0000000080005520 <sys_unlink>:
{
    80005520:	7151                	addi	sp,sp,-240
    80005522:	f586                	sd	ra,232(sp)
    80005524:	f1a2                	sd	s0,224(sp)
    80005526:	eda6                	sd	s1,216(sp)
    80005528:	e9ca                	sd	s2,208(sp)
    8000552a:	e5ce                	sd	s3,200(sp)
    8000552c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000552e:	08000613          	li	a2,128
    80005532:	f3040593          	addi	a1,s0,-208
    80005536:	4501                	li	a0,0
    80005538:	ffffd097          	auipc	ra,0xffffd
    8000553c:	614080e7          	jalr	1556(ra) # 80002b4c <argstr>
    80005540:	18054163          	bltz	a0,800056c2 <sys_unlink+0x1a2>
  begin_op();
    80005544:	fffff097          	auipc	ra,0xfffff
    80005548:	bc8080e7          	jalr	-1080(ra) # 8000410c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000554c:	fb040593          	addi	a1,s0,-80
    80005550:	f3040513          	addi	a0,s0,-208
    80005554:	fffff097          	auipc	ra,0xfffff
    80005558:	9c6080e7          	jalr	-1594(ra) # 80003f1a <nameiparent>
    8000555c:	84aa                	mv	s1,a0
    8000555e:	c979                	beqz	a0,80005634 <sys_unlink+0x114>
  ilock(dp);
    80005560:	ffffe097          	auipc	ra,0xffffe
    80005564:	1e6080e7          	jalr	486(ra) # 80003746 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005568:	00003597          	auipc	a1,0x3
    8000556c:	30858593          	addi	a1,a1,776 # 80008870 <syscall_list+0x2c0>
    80005570:	fb040513          	addi	a0,s0,-80
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	696080e7          	jalr	1686(ra) # 80003c0a <namecmp>
    8000557c:	14050a63          	beqz	a0,800056d0 <sys_unlink+0x1b0>
    80005580:	00003597          	auipc	a1,0x3
    80005584:	2f858593          	addi	a1,a1,760 # 80008878 <syscall_list+0x2c8>
    80005588:	fb040513          	addi	a0,s0,-80
    8000558c:	ffffe097          	auipc	ra,0xffffe
    80005590:	67e080e7          	jalr	1662(ra) # 80003c0a <namecmp>
    80005594:	12050e63          	beqz	a0,800056d0 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005598:	f2c40613          	addi	a2,s0,-212
    8000559c:	fb040593          	addi	a1,s0,-80
    800055a0:	8526                	mv	a0,s1
    800055a2:	ffffe097          	auipc	ra,0xffffe
    800055a6:	682080e7          	jalr	1666(ra) # 80003c24 <dirlookup>
    800055aa:	892a                	mv	s2,a0
    800055ac:	12050263          	beqz	a0,800056d0 <sys_unlink+0x1b0>
  ilock(ip);
    800055b0:	ffffe097          	auipc	ra,0xffffe
    800055b4:	196080e7          	jalr	406(ra) # 80003746 <ilock>
  if(ip->nlink < 1)
    800055b8:	04a91783          	lh	a5,74(s2)
    800055bc:	08f05263          	blez	a5,80005640 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055c0:	04491703          	lh	a4,68(s2)
    800055c4:	4785                	li	a5,1
    800055c6:	08f70563          	beq	a4,a5,80005650 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055ca:	4641                	li	a2,16
    800055cc:	4581                	li	a1,0
    800055ce:	fc040513          	addi	a0,s0,-64
    800055d2:	ffffb097          	auipc	ra,0xffffb
    800055d6:	774080e7          	jalr	1908(ra) # 80000d46 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055da:	4741                	li	a4,16
    800055dc:	f2c42683          	lw	a3,-212(s0)
    800055e0:	fc040613          	addi	a2,s0,-64
    800055e4:	4581                	li	a1,0
    800055e6:	8526                	mv	a0,s1
    800055e8:	ffffe097          	auipc	ra,0xffffe
    800055ec:	508080e7          	jalr	1288(ra) # 80003af0 <writei>
    800055f0:	47c1                	li	a5,16
    800055f2:	0af51563          	bne	a0,a5,8000569c <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800055f6:	04491703          	lh	a4,68(s2)
    800055fa:	4785                	li	a5,1
    800055fc:	0af70863          	beq	a4,a5,800056ac <sys_unlink+0x18c>
  iunlockput(dp);
    80005600:	8526                	mv	a0,s1
    80005602:	ffffe097          	auipc	ra,0xffffe
    80005606:	3a6080e7          	jalr	934(ra) # 800039a8 <iunlockput>
  ip->nlink--;
    8000560a:	04a95783          	lhu	a5,74(s2)
    8000560e:	37fd                	addiw	a5,a5,-1
    80005610:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005614:	854a                	mv	a0,s2
    80005616:	ffffe097          	auipc	ra,0xffffe
    8000561a:	064080e7          	jalr	100(ra) # 8000367a <iupdate>
  iunlockput(ip);
    8000561e:	854a                	mv	a0,s2
    80005620:	ffffe097          	auipc	ra,0xffffe
    80005624:	388080e7          	jalr	904(ra) # 800039a8 <iunlockput>
  end_op();
    80005628:	fffff097          	auipc	ra,0xfffff
    8000562c:	b62080e7          	jalr	-1182(ra) # 8000418a <end_op>
  return 0;
    80005630:	4501                	li	a0,0
    80005632:	a84d                	j	800056e4 <sys_unlink+0x1c4>
    end_op();
    80005634:	fffff097          	auipc	ra,0xfffff
    80005638:	b56080e7          	jalr	-1194(ra) # 8000418a <end_op>
    return -1;
    8000563c:	557d                	li	a0,-1
    8000563e:	a05d                	j	800056e4 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005640:	00003517          	auipc	a0,0x3
    80005644:	26050513          	addi	a0,a0,608 # 800088a0 <syscall_list+0x2f0>
    80005648:	ffffb097          	auipc	ra,0xffffb
    8000564c:	efe080e7          	jalr	-258(ra) # 80000546 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005650:	04c92703          	lw	a4,76(s2)
    80005654:	02000793          	li	a5,32
    80005658:	f6e7f9e3          	bgeu	a5,a4,800055ca <sys_unlink+0xaa>
    8000565c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005660:	4741                	li	a4,16
    80005662:	86ce                	mv	a3,s3
    80005664:	f1840613          	addi	a2,s0,-232
    80005668:	4581                	li	a1,0
    8000566a:	854a                	mv	a0,s2
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	38e080e7          	jalr	910(ra) # 800039fa <readi>
    80005674:	47c1                	li	a5,16
    80005676:	00f51b63          	bne	a0,a5,8000568c <sys_unlink+0x16c>
    if(de.inum != 0)
    8000567a:	f1845783          	lhu	a5,-232(s0)
    8000567e:	e7a1                	bnez	a5,800056c6 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005680:	29c1                	addiw	s3,s3,16
    80005682:	04c92783          	lw	a5,76(s2)
    80005686:	fcf9ede3          	bltu	s3,a5,80005660 <sys_unlink+0x140>
    8000568a:	b781                	j	800055ca <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000568c:	00003517          	auipc	a0,0x3
    80005690:	22c50513          	addi	a0,a0,556 # 800088b8 <syscall_list+0x308>
    80005694:	ffffb097          	auipc	ra,0xffffb
    80005698:	eb2080e7          	jalr	-334(ra) # 80000546 <panic>
    panic("unlink: writei");
    8000569c:	00003517          	auipc	a0,0x3
    800056a0:	23450513          	addi	a0,a0,564 # 800088d0 <syscall_list+0x320>
    800056a4:	ffffb097          	auipc	ra,0xffffb
    800056a8:	ea2080e7          	jalr	-350(ra) # 80000546 <panic>
    dp->nlink--;
    800056ac:	04a4d783          	lhu	a5,74(s1)
    800056b0:	37fd                	addiw	a5,a5,-1
    800056b2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056b6:	8526                	mv	a0,s1
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	fc2080e7          	jalr	-62(ra) # 8000367a <iupdate>
    800056c0:	b781                	j	80005600 <sys_unlink+0xe0>
    return -1;
    800056c2:	557d                	li	a0,-1
    800056c4:	a005                	j	800056e4 <sys_unlink+0x1c4>
    iunlockput(ip);
    800056c6:	854a                	mv	a0,s2
    800056c8:	ffffe097          	auipc	ra,0xffffe
    800056cc:	2e0080e7          	jalr	736(ra) # 800039a8 <iunlockput>
  iunlockput(dp);
    800056d0:	8526                	mv	a0,s1
    800056d2:	ffffe097          	auipc	ra,0xffffe
    800056d6:	2d6080e7          	jalr	726(ra) # 800039a8 <iunlockput>
  end_op();
    800056da:	fffff097          	auipc	ra,0xfffff
    800056de:	ab0080e7          	jalr	-1360(ra) # 8000418a <end_op>
  return -1;
    800056e2:	557d                	li	a0,-1
}
    800056e4:	70ae                	ld	ra,232(sp)
    800056e6:	740e                	ld	s0,224(sp)
    800056e8:	64ee                	ld	s1,216(sp)
    800056ea:	694e                	ld	s2,208(sp)
    800056ec:	69ae                	ld	s3,200(sp)
    800056ee:	616d                	addi	sp,sp,240
    800056f0:	8082                	ret

00000000800056f2 <sys_open>:

uint64
sys_open(void)
{
    800056f2:	7131                	addi	sp,sp,-192
    800056f4:	fd06                	sd	ra,184(sp)
    800056f6:	f922                	sd	s0,176(sp)
    800056f8:	f526                	sd	s1,168(sp)
    800056fa:	f14a                	sd	s2,160(sp)
    800056fc:	ed4e                	sd	s3,152(sp)
    800056fe:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005700:	08000613          	li	a2,128
    80005704:	f5040593          	addi	a1,s0,-176
    80005708:	4501                	li	a0,0
    8000570a:	ffffd097          	auipc	ra,0xffffd
    8000570e:	442080e7          	jalr	1090(ra) # 80002b4c <argstr>
    return -1;
    80005712:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005714:	0c054163          	bltz	a0,800057d6 <sys_open+0xe4>
    80005718:	f4c40593          	addi	a1,s0,-180
    8000571c:	4505                	li	a0,1
    8000571e:	ffffd097          	auipc	ra,0xffffd
    80005722:	3ea080e7          	jalr	1002(ra) # 80002b08 <argint>
    80005726:	0a054863          	bltz	a0,800057d6 <sys_open+0xe4>

  begin_op();
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	9e2080e7          	jalr	-1566(ra) # 8000410c <begin_op>

  if(omode & O_CREATE){
    80005732:	f4c42783          	lw	a5,-180(s0)
    80005736:	2007f793          	andi	a5,a5,512
    8000573a:	cbdd                	beqz	a5,800057f0 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    8000573c:	4681                	li	a3,0
    8000573e:	4601                	li	a2,0
    80005740:	4589                	li	a1,2
    80005742:	f5040513          	addi	a0,s0,-176
    80005746:	00000097          	auipc	ra,0x0
    8000574a:	970080e7          	jalr	-1680(ra) # 800050b6 <create>
    8000574e:	892a                	mv	s2,a0
    if(ip == 0){
    80005750:	c959                	beqz	a0,800057e6 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005752:	04491703          	lh	a4,68(s2)
    80005756:	478d                	li	a5,3
    80005758:	00f71763          	bne	a4,a5,80005766 <sys_open+0x74>
    8000575c:	04695703          	lhu	a4,70(s2)
    80005760:	47a5                	li	a5,9
    80005762:	0ce7ec63          	bltu	a5,a4,8000583a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005766:	fffff097          	auipc	ra,0xfffff
    8000576a:	db8080e7          	jalr	-584(ra) # 8000451e <filealloc>
    8000576e:	89aa                	mv	s3,a0
    80005770:	10050263          	beqz	a0,80005874 <sys_open+0x182>
    80005774:	00000097          	auipc	ra,0x0
    80005778:	900080e7          	jalr	-1792(ra) # 80005074 <fdalloc>
    8000577c:	84aa                	mv	s1,a0
    8000577e:	0e054663          	bltz	a0,8000586a <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005782:	04491703          	lh	a4,68(s2)
    80005786:	478d                	li	a5,3
    80005788:	0cf70463          	beq	a4,a5,80005850 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000578c:	4789                	li	a5,2
    8000578e:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005792:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005796:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000579a:	f4c42783          	lw	a5,-180(s0)
    8000579e:	0017c713          	xori	a4,a5,1
    800057a2:	8b05                	andi	a4,a4,1
    800057a4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057a8:	0037f713          	andi	a4,a5,3
    800057ac:	00e03733          	snez	a4,a4
    800057b0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057b4:	4007f793          	andi	a5,a5,1024
    800057b8:	c791                	beqz	a5,800057c4 <sys_open+0xd2>
    800057ba:	04491703          	lh	a4,68(s2)
    800057be:	4789                	li	a5,2
    800057c0:	08f70f63          	beq	a4,a5,8000585e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    800057c4:	854a                	mv	a0,s2
    800057c6:	ffffe097          	auipc	ra,0xffffe
    800057ca:	042080e7          	jalr	66(ra) # 80003808 <iunlock>
  end_op();
    800057ce:	fffff097          	auipc	ra,0xfffff
    800057d2:	9bc080e7          	jalr	-1604(ra) # 8000418a <end_op>

  return fd;
}
    800057d6:	8526                	mv	a0,s1
    800057d8:	70ea                	ld	ra,184(sp)
    800057da:	744a                	ld	s0,176(sp)
    800057dc:	74aa                	ld	s1,168(sp)
    800057de:	790a                	ld	s2,160(sp)
    800057e0:	69ea                	ld	s3,152(sp)
    800057e2:	6129                	addi	sp,sp,192
    800057e4:	8082                	ret
      end_op();
    800057e6:	fffff097          	auipc	ra,0xfffff
    800057ea:	9a4080e7          	jalr	-1628(ra) # 8000418a <end_op>
      return -1;
    800057ee:	b7e5                	j	800057d6 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800057f0:	f5040513          	addi	a0,s0,-176
    800057f4:	ffffe097          	auipc	ra,0xffffe
    800057f8:	708080e7          	jalr	1800(ra) # 80003efc <namei>
    800057fc:	892a                	mv	s2,a0
    800057fe:	c905                	beqz	a0,8000582e <sys_open+0x13c>
    ilock(ip);
    80005800:	ffffe097          	auipc	ra,0xffffe
    80005804:	f46080e7          	jalr	-186(ra) # 80003746 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005808:	04491703          	lh	a4,68(s2)
    8000580c:	4785                	li	a5,1
    8000580e:	f4f712e3          	bne	a4,a5,80005752 <sys_open+0x60>
    80005812:	f4c42783          	lw	a5,-180(s0)
    80005816:	dba1                	beqz	a5,80005766 <sys_open+0x74>
      iunlockput(ip);
    80005818:	854a                	mv	a0,s2
    8000581a:	ffffe097          	auipc	ra,0xffffe
    8000581e:	18e080e7          	jalr	398(ra) # 800039a8 <iunlockput>
      end_op();
    80005822:	fffff097          	auipc	ra,0xfffff
    80005826:	968080e7          	jalr	-1688(ra) # 8000418a <end_op>
      return -1;
    8000582a:	54fd                	li	s1,-1
    8000582c:	b76d                	j	800057d6 <sys_open+0xe4>
      end_op();
    8000582e:	fffff097          	auipc	ra,0xfffff
    80005832:	95c080e7          	jalr	-1700(ra) # 8000418a <end_op>
      return -1;
    80005836:	54fd                	li	s1,-1
    80005838:	bf79                	j	800057d6 <sys_open+0xe4>
    iunlockput(ip);
    8000583a:	854a                	mv	a0,s2
    8000583c:	ffffe097          	auipc	ra,0xffffe
    80005840:	16c080e7          	jalr	364(ra) # 800039a8 <iunlockput>
    end_op();
    80005844:	fffff097          	auipc	ra,0xfffff
    80005848:	946080e7          	jalr	-1722(ra) # 8000418a <end_op>
    return -1;
    8000584c:	54fd                	li	s1,-1
    8000584e:	b761                	j	800057d6 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005850:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005854:	04691783          	lh	a5,70(s2)
    80005858:	02f99223          	sh	a5,36(s3)
    8000585c:	bf2d                	j	80005796 <sys_open+0xa4>
    itrunc(ip);
    8000585e:	854a                	mv	a0,s2
    80005860:	ffffe097          	auipc	ra,0xffffe
    80005864:	ff4080e7          	jalr	-12(ra) # 80003854 <itrunc>
    80005868:	bfb1                	j	800057c4 <sys_open+0xd2>
      fileclose(f);
    8000586a:	854e                	mv	a0,s3
    8000586c:	fffff097          	auipc	ra,0xfffff
    80005870:	d6e080e7          	jalr	-658(ra) # 800045da <fileclose>
    iunlockput(ip);
    80005874:	854a                	mv	a0,s2
    80005876:	ffffe097          	auipc	ra,0xffffe
    8000587a:	132080e7          	jalr	306(ra) # 800039a8 <iunlockput>
    end_op();
    8000587e:	fffff097          	auipc	ra,0xfffff
    80005882:	90c080e7          	jalr	-1780(ra) # 8000418a <end_op>
    return -1;
    80005886:	54fd                	li	s1,-1
    80005888:	b7b9                	j	800057d6 <sys_open+0xe4>

000000008000588a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000588a:	7175                	addi	sp,sp,-144
    8000588c:	e506                	sd	ra,136(sp)
    8000588e:	e122                	sd	s0,128(sp)
    80005890:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005892:	fffff097          	auipc	ra,0xfffff
    80005896:	87a080e7          	jalr	-1926(ra) # 8000410c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000589a:	08000613          	li	a2,128
    8000589e:	f7040593          	addi	a1,s0,-144
    800058a2:	4501                	li	a0,0
    800058a4:	ffffd097          	auipc	ra,0xffffd
    800058a8:	2a8080e7          	jalr	680(ra) # 80002b4c <argstr>
    800058ac:	02054963          	bltz	a0,800058de <sys_mkdir+0x54>
    800058b0:	4681                	li	a3,0
    800058b2:	4601                	li	a2,0
    800058b4:	4585                	li	a1,1
    800058b6:	f7040513          	addi	a0,s0,-144
    800058ba:	fffff097          	auipc	ra,0xfffff
    800058be:	7fc080e7          	jalr	2044(ra) # 800050b6 <create>
    800058c2:	cd11                	beqz	a0,800058de <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	0e4080e7          	jalr	228(ra) # 800039a8 <iunlockput>
  end_op();
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	8be080e7          	jalr	-1858(ra) # 8000418a <end_op>
  return 0;
    800058d4:	4501                	li	a0,0
}
    800058d6:	60aa                	ld	ra,136(sp)
    800058d8:	640a                	ld	s0,128(sp)
    800058da:	6149                	addi	sp,sp,144
    800058dc:	8082                	ret
    end_op();
    800058de:	fffff097          	auipc	ra,0xfffff
    800058e2:	8ac080e7          	jalr	-1876(ra) # 8000418a <end_op>
    return -1;
    800058e6:	557d                	li	a0,-1
    800058e8:	b7fd                	j	800058d6 <sys_mkdir+0x4c>

00000000800058ea <sys_mknod>:

uint64
sys_mknod(void)
{
    800058ea:	7135                	addi	sp,sp,-160
    800058ec:	ed06                	sd	ra,152(sp)
    800058ee:	e922                	sd	s0,144(sp)
    800058f0:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058f2:	fffff097          	auipc	ra,0xfffff
    800058f6:	81a080e7          	jalr	-2022(ra) # 8000410c <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058fa:	08000613          	li	a2,128
    800058fe:	f7040593          	addi	a1,s0,-144
    80005902:	4501                	li	a0,0
    80005904:	ffffd097          	auipc	ra,0xffffd
    80005908:	248080e7          	jalr	584(ra) # 80002b4c <argstr>
    8000590c:	04054a63          	bltz	a0,80005960 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005910:	f6c40593          	addi	a1,s0,-148
    80005914:	4505                	li	a0,1
    80005916:	ffffd097          	auipc	ra,0xffffd
    8000591a:	1f2080e7          	jalr	498(ra) # 80002b08 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000591e:	04054163          	bltz	a0,80005960 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005922:	f6840593          	addi	a1,s0,-152
    80005926:	4509                	li	a0,2
    80005928:	ffffd097          	auipc	ra,0xffffd
    8000592c:	1e0080e7          	jalr	480(ra) # 80002b08 <argint>
     argint(1, &major) < 0 ||
    80005930:	02054863          	bltz	a0,80005960 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005934:	f6841683          	lh	a3,-152(s0)
    80005938:	f6c41603          	lh	a2,-148(s0)
    8000593c:	458d                	li	a1,3
    8000593e:	f7040513          	addi	a0,s0,-144
    80005942:	fffff097          	auipc	ra,0xfffff
    80005946:	774080e7          	jalr	1908(ra) # 800050b6 <create>
     argint(2, &minor) < 0 ||
    8000594a:	c919                	beqz	a0,80005960 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000594c:	ffffe097          	auipc	ra,0xffffe
    80005950:	05c080e7          	jalr	92(ra) # 800039a8 <iunlockput>
  end_op();
    80005954:	fffff097          	auipc	ra,0xfffff
    80005958:	836080e7          	jalr	-1994(ra) # 8000418a <end_op>
  return 0;
    8000595c:	4501                	li	a0,0
    8000595e:	a031                	j	8000596a <sys_mknod+0x80>
    end_op();
    80005960:	fffff097          	auipc	ra,0xfffff
    80005964:	82a080e7          	jalr	-2006(ra) # 8000418a <end_op>
    return -1;
    80005968:	557d                	li	a0,-1
}
    8000596a:	60ea                	ld	ra,152(sp)
    8000596c:	644a                	ld	s0,144(sp)
    8000596e:	610d                	addi	sp,sp,160
    80005970:	8082                	ret

0000000080005972 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005972:	7135                	addi	sp,sp,-160
    80005974:	ed06                	sd	ra,152(sp)
    80005976:	e922                	sd	s0,144(sp)
    80005978:	e526                	sd	s1,136(sp)
    8000597a:	e14a                	sd	s2,128(sp)
    8000597c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000597e:	ffffc097          	auipc	ra,0xffffc
    80005982:	098080e7          	jalr	152(ra) # 80001a16 <myproc>
    80005986:	892a                	mv	s2,a0
  
  begin_op();
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	784080e7          	jalr	1924(ra) # 8000410c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005990:	08000613          	li	a2,128
    80005994:	f6040593          	addi	a1,s0,-160
    80005998:	4501                	li	a0,0
    8000599a:	ffffd097          	auipc	ra,0xffffd
    8000599e:	1b2080e7          	jalr	434(ra) # 80002b4c <argstr>
    800059a2:	04054b63          	bltz	a0,800059f8 <sys_chdir+0x86>
    800059a6:	f6040513          	addi	a0,s0,-160
    800059aa:	ffffe097          	auipc	ra,0xffffe
    800059ae:	552080e7          	jalr	1362(ra) # 80003efc <namei>
    800059b2:	84aa                	mv	s1,a0
    800059b4:	c131                	beqz	a0,800059f8 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	d90080e7          	jalr	-624(ra) # 80003746 <ilock>
  if(ip->type != T_DIR){
    800059be:	04449703          	lh	a4,68(s1)
    800059c2:	4785                	li	a5,1
    800059c4:	04f71063          	bne	a4,a5,80005a04 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059c8:	8526                	mv	a0,s1
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	e3e080e7          	jalr	-450(ra) # 80003808 <iunlock>
  iput(p->cwd);
    800059d2:	15093503          	ld	a0,336(s2)
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	f2a080e7          	jalr	-214(ra) # 80003900 <iput>
  end_op();
    800059de:	ffffe097          	auipc	ra,0xffffe
    800059e2:	7ac080e7          	jalr	1964(ra) # 8000418a <end_op>
  p->cwd = ip;
    800059e6:	14993823          	sd	s1,336(s2)
  return 0;
    800059ea:	4501                	li	a0,0
}
    800059ec:	60ea                	ld	ra,152(sp)
    800059ee:	644a                	ld	s0,144(sp)
    800059f0:	64aa                	ld	s1,136(sp)
    800059f2:	690a                	ld	s2,128(sp)
    800059f4:	610d                	addi	sp,sp,160
    800059f6:	8082                	ret
    end_op();
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	792080e7          	jalr	1938(ra) # 8000418a <end_op>
    return -1;
    80005a00:	557d                	li	a0,-1
    80005a02:	b7ed                	j	800059ec <sys_chdir+0x7a>
    iunlockput(ip);
    80005a04:	8526                	mv	a0,s1
    80005a06:	ffffe097          	auipc	ra,0xffffe
    80005a0a:	fa2080e7          	jalr	-94(ra) # 800039a8 <iunlockput>
    end_op();
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	77c080e7          	jalr	1916(ra) # 8000418a <end_op>
    return -1;
    80005a16:	557d                	li	a0,-1
    80005a18:	bfd1                	j	800059ec <sys_chdir+0x7a>

0000000080005a1a <sys_exec>:

uint64
sys_exec(void)
{
    80005a1a:	7145                	addi	sp,sp,-464
    80005a1c:	e786                	sd	ra,456(sp)
    80005a1e:	e3a2                	sd	s0,448(sp)
    80005a20:	ff26                	sd	s1,440(sp)
    80005a22:	fb4a                	sd	s2,432(sp)
    80005a24:	f74e                	sd	s3,424(sp)
    80005a26:	f352                	sd	s4,416(sp)
    80005a28:	ef56                	sd	s5,408(sp)
    80005a2a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a2c:	08000613          	li	a2,128
    80005a30:	f4040593          	addi	a1,s0,-192
    80005a34:	4501                	li	a0,0
    80005a36:	ffffd097          	auipc	ra,0xffffd
    80005a3a:	116080e7          	jalr	278(ra) # 80002b4c <argstr>
    return -1;
    80005a3e:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a40:	0c054b63          	bltz	a0,80005b16 <sys_exec+0xfc>
    80005a44:	e3840593          	addi	a1,s0,-456
    80005a48:	4505                	li	a0,1
    80005a4a:	ffffd097          	auipc	ra,0xffffd
    80005a4e:	0e0080e7          	jalr	224(ra) # 80002b2a <argaddr>
    80005a52:	0c054263          	bltz	a0,80005b16 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005a56:	10000613          	li	a2,256
    80005a5a:	4581                	li	a1,0
    80005a5c:	e4040513          	addi	a0,s0,-448
    80005a60:	ffffb097          	auipc	ra,0xffffb
    80005a64:	2e6080e7          	jalr	742(ra) # 80000d46 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a68:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005a6c:	89a6                	mv	s3,s1
    80005a6e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a70:	02000a13          	li	s4,32
    80005a74:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a78:	00391513          	slli	a0,s2,0x3
    80005a7c:	e3040593          	addi	a1,s0,-464
    80005a80:	e3843783          	ld	a5,-456(s0)
    80005a84:	953e                	add	a0,a0,a5
    80005a86:	ffffd097          	auipc	ra,0xffffd
    80005a8a:	fe8080e7          	jalr	-24(ra) # 80002a6e <fetchaddr>
    80005a8e:	02054a63          	bltz	a0,80005ac2 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005a92:	e3043783          	ld	a5,-464(s0)
    80005a96:	c3b9                	beqz	a5,80005adc <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a98:	ffffb097          	auipc	ra,0xffffb
    80005a9c:	078080e7          	jalr	120(ra) # 80000b10 <kalloc>
    80005aa0:	85aa                	mv	a1,a0
    80005aa2:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005aa6:	cd11                	beqz	a0,80005ac2 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005aa8:	6605                	lui	a2,0x1
    80005aaa:	e3043503          	ld	a0,-464(s0)
    80005aae:	ffffd097          	auipc	ra,0xffffd
    80005ab2:	012080e7          	jalr	18(ra) # 80002ac0 <fetchstr>
    80005ab6:	00054663          	bltz	a0,80005ac2 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005aba:	0905                	addi	s2,s2,1
    80005abc:	09a1                	addi	s3,s3,8
    80005abe:	fb491be3          	bne	s2,s4,80005a74 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ac2:	f4040913          	addi	s2,s0,-192
    80005ac6:	6088                	ld	a0,0(s1)
    80005ac8:	c531                	beqz	a0,80005b14 <sys_exec+0xfa>
    kfree(argv[i]);
    80005aca:	ffffb097          	auipc	ra,0xffffb
    80005ace:	f48080e7          	jalr	-184(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ad2:	04a1                	addi	s1,s1,8
    80005ad4:	ff2499e3          	bne	s1,s2,80005ac6 <sys_exec+0xac>
  return -1;
    80005ad8:	597d                	li	s2,-1
    80005ada:	a835                	j	80005b16 <sys_exec+0xfc>
      argv[i] = 0;
    80005adc:	0a8e                	slli	s5,s5,0x3
    80005ade:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd8fc0>
    80005ae2:	00878ab3          	add	s5,a5,s0
    80005ae6:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005aea:	e4040593          	addi	a1,s0,-448
    80005aee:	f4040513          	addi	a0,s0,-192
    80005af2:	fffff097          	auipc	ra,0xfffff
    80005af6:	172080e7          	jalr	370(ra) # 80004c64 <exec>
    80005afa:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005afc:	f4040993          	addi	s3,s0,-192
    80005b00:	6088                	ld	a0,0(s1)
    80005b02:	c911                	beqz	a0,80005b16 <sys_exec+0xfc>
    kfree(argv[i]);
    80005b04:	ffffb097          	auipc	ra,0xffffb
    80005b08:	f0e080e7          	jalr	-242(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b0c:	04a1                	addi	s1,s1,8
    80005b0e:	ff3499e3          	bne	s1,s3,80005b00 <sys_exec+0xe6>
    80005b12:	a011                	j	80005b16 <sys_exec+0xfc>
  return -1;
    80005b14:	597d                	li	s2,-1
}
    80005b16:	854a                	mv	a0,s2
    80005b18:	60be                	ld	ra,456(sp)
    80005b1a:	641e                	ld	s0,448(sp)
    80005b1c:	74fa                	ld	s1,440(sp)
    80005b1e:	795a                	ld	s2,432(sp)
    80005b20:	79ba                	ld	s3,424(sp)
    80005b22:	7a1a                	ld	s4,416(sp)
    80005b24:	6afa                	ld	s5,408(sp)
    80005b26:	6179                	addi	sp,sp,464
    80005b28:	8082                	ret

0000000080005b2a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b2a:	7139                	addi	sp,sp,-64
    80005b2c:	fc06                	sd	ra,56(sp)
    80005b2e:	f822                	sd	s0,48(sp)
    80005b30:	f426                	sd	s1,40(sp)
    80005b32:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b34:	ffffc097          	auipc	ra,0xffffc
    80005b38:	ee2080e7          	jalr	-286(ra) # 80001a16 <myproc>
    80005b3c:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b3e:	fd840593          	addi	a1,s0,-40
    80005b42:	4501                	li	a0,0
    80005b44:	ffffd097          	auipc	ra,0xffffd
    80005b48:	fe6080e7          	jalr	-26(ra) # 80002b2a <argaddr>
    return -1;
    80005b4c:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b4e:	0e054063          	bltz	a0,80005c2e <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005b52:	fc840593          	addi	a1,s0,-56
    80005b56:	fd040513          	addi	a0,s0,-48
    80005b5a:	fffff097          	auipc	ra,0xfffff
    80005b5e:	dd6080e7          	jalr	-554(ra) # 80004930 <pipealloc>
    return -1;
    80005b62:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b64:	0c054563          	bltz	a0,80005c2e <sys_pipe+0x104>
  fd0 = -1;
    80005b68:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b6c:	fd043503          	ld	a0,-48(s0)
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	504080e7          	jalr	1284(ra) # 80005074 <fdalloc>
    80005b78:	fca42223          	sw	a0,-60(s0)
    80005b7c:	08054c63          	bltz	a0,80005c14 <sys_pipe+0xea>
    80005b80:	fc843503          	ld	a0,-56(s0)
    80005b84:	fffff097          	auipc	ra,0xfffff
    80005b88:	4f0080e7          	jalr	1264(ra) # 80005074 <fdalloc>
    80005b8c:	fca42023          	sw	a0,-64(s0)
    80005b90:	06054963          	bltz	a0,80005c02 <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b94:	4691                	li	a3,4
    80005b96:	fc440613          	addi	a2,s0,-60
    80005b9a:	fd843583          	ld	a1,-40(s0)
    80005b9e:	68a8                	ld	a0,80(s1)
    80005ba0:	ffffc097          	auipc	ra,0xffffc
    80005ba4:	b6c080e7          	jalr	-1172(ra) # 8000170c <copyout>
    80005ba8:	02054063          	bltz	a0,80005bc8 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005bac:	4691                	li	a3,4
    80005bae:	fc040613          	addi	a2,s0,-64
    80005bb2:	fd843583          	ld	a1,-40(s0)
    80005bb6:	0591                	addi	a1,a1,4
    80005bb8:	68a8                	ld	a0,80(s1)
    80005bba:	ffffc097          	auipc	ra,0xffffc
    80005bbe:	b52080e7          	jalr	-1198(ra) # 8000170c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005bc2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bc4:	06055563          	bgez	a0,80005c2e <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005bc8:	fc442783          	lw	a5,-60(s0)
    80005bcc:	07e9                	addi	a5,a5,26
    80005bce:	078e                	slli	a5,a5,0x3
    80005bd0:	97a6                	add	a5,a5,s1
    80005bd2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005bd6:	fc042783          	lw	a5,-64(s0)
    80005bda:	07e9                	addi	a5,a5,26
    80005bdc:	078e                	slli	a5,a5,0x3
    80005bde:	00f48533          	add	a0,s1,a5
    80005be2:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005be6:	fd043503          	ld	a0,-48(s0)
    80005bea:	fffff097          	auipc	ra,0xfffff
    80005bee:	9f0080e7          	jalr	-1552(ra) # 800045da <fileclose>
    fileclose(wf);
    80005bf2:	fc843503          	ld	a0,-56(s0)
    80005bf6:	fffff097          	auipc	ra,0xfffff
    80005bfa:	9e4080e7          	jalr	-1564(ra) # 800045da <fileclose>
    return -1;
    80005bfe:	57fd                	li	a5,-1
    80005c00:	a03d                	j	80005c2e <sys_pipe+0x104>
    if(fd0 >= 0)
    80005c02:	fc442783          	lw	a5,-60(s0)
    80005c06:	0007c763          	bltz	a5,80005c14 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c0a:	07e9                	addi	a5,a5,26
    80005c0c:	078e                	slli	a5,a5,0x3
    80005c0e:	97a6                	add	a5,a5,s1
    80005c10:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005c14:	fd043503          	ld	a0,-48(s0)
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	9c2080e7          	jalr	-1598(ra) # 800045da <fileclose>
    fileclose(wf);
    80005c20:	fc843503          	ld	a0,-56(s0)
    80005c24:	fffff097          	auipc	ra,0xfffff
    80005c28:	9b6080e7          	jalr	-1610(ra) # 800045da <fileclose>
    return -1;
    80005c2c:	57fd                	li	a5,-1
}
    80005c2e:	853e                	mv	a0,a5
    80005c30:	70e2                	ld	ra,56(sp)
    80005c32:	7442                	ld	s0,48(sp)
    80005c34:	74a2                	ld	s1,40(sp)
    80005c36:	6121                	addi	sp,sp,64
    80005c38:	8082                	ret
    80005c3a:	0000                	unimp
    80005c3c:	0000                	unimp
	...

0000000080005c40 <kernelvec>:
    80005c40:	7111                	addi	sp,sp,-256
    80005c42:	e006                	sd	ra,0(sp)
    80005c44:	e40a                	sd	sp,8(sp)
    80005c46:	e80e                	sd	gp,16(sp)
    80005c48:	ec12                	sd	tp,24(sp)
    80005c4a:	f016                	sd	t0,32(sp)
    80005c4c:	f41a                	sd	t1,40(sp)
    80005c4e:	f81e                	sd	t2,48(sp)
    80005c50:	fc22                	sd	s0,56(sp)
    80005c52:	e0a6                	sd	s1,64(sp)
    80005c54:	e4aa                	sd	a0,72(sp)
    80005c56:	e8ae                	sd	a1,80(sp)
    80005c58:	ecb2                	sd	a2,88(sp)
    80005c5a:	f0b6                	sd	a3,96(sp)
    80005c5c:	f4ba                	sd	a4,104(sp)
    80005c5e:	f8be                	sd	a5,112(sp)
    80005c60:	fcc2                	sd	a6,120(sp)
    80005c62:	e146                	sd	a7,128(sp)
    80005c64:	e54a                	sd	s2,136(sp)
    80005c66:	e94e                	sd	s3,144(sp)
    80005c68:	ed52                	sd	s4,152(sp)
    80005c6a:	f156                	sd	s5,160(sp)
    80005c6c:	f55a                	sd	s6,168(sp)
    80005c6e:	f95e                	sd	s7,176(sp)
    80005c70:	fd62                	sd	s8,184(sp)
    80005c72:	e1e6                	sd	s9,192(sp)
    80005c74:	e5ea                	sd	s10,200(sp)
    80005c76:	e9ee                	sd	s11,208(sp)
    80005c78:	edf2                	sd	t3,216(sp)
    80005c7a:	f1f6                	sd	t4,224(sp)
    80005c7c:	f5fa                	sd	t5,232(sp)
    80005c7e:	f9fe                	sd	t6,240(sp)
    80005c80:	cbbfc0ef          	jal	ra,8000293a <kerneltrap>
    80005c84:	6082                	ld	ra,0(sp)
    80005c86:	6122                	ld	sp,8(sp)
    80005c88:	61c2                	ld	gp,16(sp)
    80005c8a:	7282                	ld	t0,32(sp)
    80005c8c:	7322                	ld	t1,40(sp)
    80005c8e:	73c2                	ld	t2,48(sp)
    80005c90:	7462                	ld	s0,56(sp)
    80005c92:	6486                	ld	s1,64(sp)
    80005c94:	6526                	ld	a0,72(sp)
    80005c96:	65c6                	ld	a1,80(sp)
    80005c98:	6666                	ld	a2,88(sp)
    80005c9a:	7686                	ld	a3,96(sp)
    80005c9c:	7726                	ld	a4,104(sp)
    80005c9e:	77c6                	ld	a5,112(sp)
    80005ca0:	7866                	ld	a6,120(sp)
    80005ca2:	688a                	ld	a7,128(sp)
    80005ca4:	692a                	ld	s2,136(sp)
    80005ca6:	69ca                	ld	s3,144(sp)
    80005ca8:	6a6a                	ld	s4,152(sp)
    80005caa:	7a8a                	ld	s5,160(sp)
    80005cac:	7b2a                	ld	s6,168(sp)
    80005cae:	7bca                	ld	s7,176(sp)
    80005cb0:	7c6a                	ld	s8,184(sp)
    80005cb2:	6c8e                	ld	s9,192(sp)
    80005cb4:	6d2e                	ld	s10,200(sp)
    80005cb6:	6dce                	ld	s11,208(sp)
    80005cb8:	6e6e                	ld	t3,216(sp)
    80005cba:	7e8e                	ld	t4,224(sp)
    80005cbc:	7f2e                	ld	t5,232(sp)
    80005cbe:	7fce                	ld	t6,240(sp)
    80005cc0:	6111                	addi	sp,sp,256
    80005cc2:	10200073          	sret
    80005cc6:	00000013          	nop
    80005cca:	00000013          	nop
    80005cce:	0001                	nop

0000000080005cd0 <timervec>:
    80005cd0:	34051573          	csrrw	a0,mscratch,a0
    80005cd4:	e10c                	sd	a1,0(a0)
    80005cd6:	e510                	sd	a2,8(a0)
    80005cd8:	e914                	sd	a3,16(a0)
    80005cda:	710c                	ld	a1,32(a0)
    80005cdc:	7510                	ld	a2,40(a0)
    80005cde:	6194                	ld	a3,0(a1)
    80005ce0:	96b2                	add	a3,a3,a2
    80005ce2:	e194                	sd	a3,0(a1)
    80005ce4:	4589                	li	a1,2
    80005ce6:	14459073          	csrw	sip,a1
    80005cea:	6914                	ld	a3,16(a0)
    80005cec:	6510                	ld	a2,8(a0)
    80005cee:	610c                	ld	a1,0(a0)
    80005cf0:	34051573          	csrrw	a0,mscratch,a0
    80005cf4:	30200073          	mret
	...

0000000080005cfa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005cfa:	1141                	addi	sp,sp,-16
    80005cfc:	e422                	sd	s0,8(sp)
    80005cfe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d00:	0c0007b7          	lui	a5,0xc000
    80005d04:	4705                	li	a4,1
    80005d06:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d08:	c3d8                	sw	a4,4(a5)
}
    80005d0a:	6422                	ld	s0,8(sp)
    80005d0c:	0141                	addi	sp,sp,16
    80005d0e:	8082                	ret

0000000080005d10 <plicinithart>:

void
plicinithart(void)
{
    80005d10:	1141                	addi	sp,sp,-16
    80005d12:	e406                	sd	ra,8(sp)
    80005d14:	e022                	sd	s0,0(sp)
    80005d16:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d18:	ffffc097          	auipc	ra,0xffffc
    80005d1c:	cd2080e7          	jalr	-814(ra) # 800019ea <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d20:	0085171b          	slliw	a4,a0,0x8
    80005d24:	0c0027b7          	lui	a5,0xc002
    80005d28:	97ba                	add	a5,a5,a4
    80005d2a:	40200713          	li	a4,1026
    80005d2e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d32:	00d5151b          	slliw	a0,a0,0xd
    80005d36:	0c2017b7          	lui	a5,0xc201
    80005d3a:	97aa                	add	a5,a5,a0
    80005d3c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d40:	60a2                	ld	ra,8(sp)
    80005d42:	6402                	ld	s0,0(sp)
    80005d44:	0141                	addi	sp,sp,16
    80005d46:	8082                	ret

0000000080005d48 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d48:	1141                	addi	sp,sp,-16
    80005d4a:	e406                	sd	ra,8(sp)
    80005d4c:	e022                	sd	s0,0(sp)
    80005d4e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d50:	ffffc097          	auipc	ra,0xffffc
    80005d54:	c9a080e7          	jalr	-870(ra) # 800019ea <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d58:	00d5151b          	slliw	a0,a0,0xd
    80005d5c:	0c2017b7          	lui	a5,0xc201
    80005d60:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d62:	43c8                	lw	a0,4(a5)
    80005d64:	60a2                	ld	ra,8(sp)
    80005d66:	6402                	ld	s0,0(sp)
    80005d68:	0141                	addi	sp,sp,16
    80005d6a:	8082                	ret

0000000080005d6c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d6c:	1101                	addi	sp,sp,-32
    80005d6e:	ec06                	sd	ra,24(sp)
    80005d70:	e822                	sd	s0,16(sp)
    80005d72:	e426                	sd	s1,8(sp)
    80005d74:	1000                	addi	s0,sp,32
    80005d76:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d78:	ffffc097          	auipc	ra,0xffffc
    80005d7c:	c72080e7          	jalr	-910(ra) # 800019ea <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d80:	00d5151b          	slliw	a0,a0,0xd
    80005d84:	0c2017b7          	lui	a5,0xc201
    80005d88:	97aa                	add	a5,a5,a0
    80005d8a:	c3c4                	sw	s1,4(a5)
}
    80005d8c:	60e2                	ld	ra,24(sp)
    80005d8e:	6442                	ld	s0,16(sp)
    80005d90:	64a2                	ld	s1,8(sp)
    80005d92:	6105                	addi	sp,sp,32
    80005d94:	8082                	ret

0000000080005d96 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d96:	1141                	addi	sp,sp,-16
    80005d98:	e406                	sd	ra,8(sp)
    80005d9a:	e022                	sd	s0,0(sp)
    80005d9c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005d9e:	479d                	li	a5,7
    80005da0:	04a7cb63          	blt	a5,a0,80005df6 <free_desc+0x60>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005da4:	0001d717          	auipc	a4,0x1d
    80005da8:	25c70713          	addi	a4,a4,604 # 80023000 <disk>
    80005dac:	972a                	add	a4,a4,a0
    80005dae:	6789                	lui	a5,0x2
    80005db0:	97ba                	add	a5,a5,a4
    80005db2:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005db6:	eba1                	bnez	a5,80005e06 <free_desc+0x70>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005db8:	00451713          	slli	a4,a0,0x4
    80005dbc:	0001f797          	auipc	a5,0x1f
    80005dc0:	2447b783          	ld	a5,580(a5) # 80025000 <disk+0x2000>
    80005dc4:	97ba                	add	a5,a5,a4
    80005dc6:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005dca:	0001d717          	auipc	a4,0x1d
    80005dce:	23670713          	addi	a4,a4,566 # 80023000 <disk>
    80005dd2:	972a                	add	a4,a4,a0
    80005dd4:	6789                	lui	a5,0x2
    80005dd6:	97ba                	add	a5,a5,a4
    80005dd8:	4705                	li	a4,1
    80005dda:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005dde:	0001f517          	auipc	a0,0x1f
    80005de2:	23a50513          	addi	a0,a0,570 # 80025018 <disk+0x2018>
    80005de6:	ffffc097          	auipc	ra,0xffffc
    80005dea:	5cc080e7          	jalr	1484(ra) # 800023b2 <wakeup>
}
    80005dee:	60a2                	ld	ra,8(sp)
    80005df0:	6402                	ld	s0,0(sp)
    80005df2:	0141                	addi	sp,sp,16
    80005df4:	8082                	ret
    panic("virtio_disk_intr 1");
    80005df6:	00003517          	auipc	a0,0x3
    80005dfa:	aea50513          	addi	a0,a0,-1302 # 800088e0 <syscall_list+0x330>
    80005dfe:	ffffa097          	auipc	ra,0xffffa
    80005e02:	748080e7          	jalr	1864(ra) # 80000546 <panic>
    panic("virtio_disk_intr 2");
    80005e06:	00003517          	auipc	a0,0x3
    80005e0a:	af250513          	addi	a0,a0,-1294 # 800088f8 <syscall_list+0x348>
    80005e0e:	ffffa097          	auipc	ra,0xffffa
    80005e12:	738080e7          	jalr	1848(ra) # 80000546 <panic>

0000000080005e16 <virtio_disk_init>:
{
    80005e16:	1101                	addi	sp,sp,-32
    80005e18:	ec06                	sd	ra,24(sp)
    80005e1a:	e822                	sd	s0,16(sp)
    80005e1c:	e426                	sd	s1,8(sp)
    80005e1e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e20:	00003597          	auipc	a1,0x3
    80005e24:	af058593          	addi	a1,a1,-1296 # 80008910 <syscall_list+0x360>
    80005e28:	0001f517          	auipc	a0,0x1f
    80005e2c:	28050513          	addi	a0,a0,640 # 800250a8 <disk+0x20a8>
    80005e30:	ffffb097          	auipc	ra,0xffffb
    80005e34:	d8a080e7          	jalr	-630(ra) # 80000bba <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e38:	100017b7          	lui	a5,0x10001
    80005e3c:	4398                	lw	a4,0(a5)
    80005e3e:	2701                	sext.w	a4,a4
    80005e40:	747277b7          	lui	a5,0x74727
    80005e44:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e48:	0ef71063          	bne	a4,a5,80005f28 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e4c:	100017b7          	lui	a5,0x10001
    80005e50:	43dc                	lw	a5,4(a5)
    80005e52:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e54:	4705                	li	a4,1
    80005e56:	0ce79963          	bne	a5,a4,80005f28 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e5a:	100017b7          	lui	a5,0x10001
    80005e5e:	479c                	lw	a5,8(a5)
    80005e60:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e62:	4709                	li	a4,2
    80005e64:	0ce79263          	bne	a5,a4,80005f28 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e68:	100017b7          	lui	a5,0x10001
    80005e6c:	47d8                	lw	a4,12(a5)
    80005e6e:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e70:	554d47b7          	lui	a5,0x554d4
    80005e74:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e78:	0af71863          	bne	a4,a5,80005f28 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e7c:	100017b7          	lui	a5,0x10001
    80005e80:	4705                	li	a4,1
    80005e82:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e84:	470d                	li	a4,3
    80005e86:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e88:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e8a:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e8e:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005e92:	8f75                	and	a4,a4,a3
    80005e94:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e96:	472d                	li	a4,11
    80005e98:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e9a:	473d                	li	a4,15
    80005e9c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005e9e:	6705                	lui	a4,0x1
    80005ea0:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ea2:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ea6:	5bdc                	lw	a5,52(a5)
    80005ea8:	2781                	sext.w	a5,a5
  if(max == 0)
    80005eaa:	c7d9                	beqz	a5,80005f38 <virtio_disk_init+0x122>
  if(max < NUM)
    80005eac:	471d                	li	a4,7
    80005eae:	08f77d63          	bgeu	a4,a5,80005f48 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005eb2:	100014b7          	lui	s1,0x10001
    80005eb6:	47a1                	li	a5,8
    80005eb8:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005eba:	6609                	lui	a2,0x2
    80005ebc:	4581                	li	a1,0
    80005ebe:	0001d517          	auipc	a0,0x1d
    80005ec2:	14250513          	addi	a0,a0,322 # 80023000 <disk>
    80005ec6:	ffffb097          	auipc	ra,0xffffb
    80005eca:	e80080e7          	jalr	-384(ra) # 80000d46 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005ece:	0001d717          	auipc	a4,0x1d
    80005ed2:	13270713          	addi	a4,a4,306 # 80023000 <disk>
    80005ed6:	00c75793          	srli	a5,a4,0xc
    80005eda:	2781                	sext.w	a5,a5
    80005edc:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005ede:	0001f797          	auipc	a5,0x1f
    80005ee2:	12278793          	addi	a5,a5,290 # 80025000 <disk+0x2000>
    80005ee6:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005ee8:	0001d717          	auipc	a4,0x1d
    80005eec:	19870713          	addi	a4,a4,408 # 80023080 <disk+0x80>
    80005ef0:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005ef2:	0001e717          	auipc	a4,0x1e
    80005ef6:	10e70713          	addi	a4,a4,270 # 80024000 <disk+0x1000>
    80005efa:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005efc:	4705                	li	a4,1
    80005efe:	00e78c23          	sb	a4,24(a5)
    80005f02:	00e78ca3          	sb	a4,25(a5)
    80005f06:	00e78d23          	sb	a4,26(a5)
    80005f0a:	00e78da3          	sb	a4,27(a5)
    80005f0e:	00e78e23          	sb	a4,28(a5)
    80005f12:	00e78ea3          	sb	a4,29(a5)
    80005f16:	00e78f23          	sb	a4,30(a5)
    80005f1a:	00e78fa3          	sb	a4,31(a5)
}
    80005f1e:	60e2                	ld	ra,24(sp)
    80005f20:	6442                	ld	s0,16(sp)
    80005f22:	64a2                	ld	s1,8(sp)
    80005f24:	6105                	addi	sp,sp,32
    80005f26:	8082                	ret
    panic("could not find virtio disk");
    80005f28:	00003517          	auipc	a0,0x3
    80005f2c:	9f850513          	addi	a0,a0,-1544 # 80008920 <syscall_list+0x370>
    80005f30:	ffffa097          	auipc	ra,0xffffa
    80005f34:	616080e7          	jalr	1558(ra) # 80000546 <panic>
    panic("virtio disk has no queue 0");
    80005f38:	00003517          	auipc	a0,0x3
    80005f3c:	a0850513          	addi	a0,a0,-1528 # 80008940 <syscall_list+0x390>
    80005f40:	ffffa097          	auipc	ra,0xffffa
    80005f44:	606080e7          	jalr	1542(ra) # 80000546 <panic>
    panic("virtio disk max queue too short");
    80005f48:	00003517          	auipc	a0,0x3
    80005f4c:	a1850513          	addi	a0,a0,-1512 # 80008960 <syscall_list+0x3b0>
    80005f50:	ffffa097          	auipc	ra,0xffffa
    80005f54:	5f6080e7          	jalr	1526(ra) # 80000546 <panic>

0000000080005f58 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f58:	7175                	addi	sp,sp,-144
    80005f5a:	e506                	sd	ra,136(sp)
    80005f5c:	e122                	sd	s0,128(sp)
    80005f5e:	fca6                	sd	s1,120(sp)
    80005f60:	f8ca                	sd	s2,112(sp)
    80005f62:	f4ce                	sd	s3,104(sp)
    80005f64:	f0d2                	sd	s4,96(sp)
    80005f66:	ecd6                	sd	s5,88(sp)
    80005f68:	e8da                	sd	s6,80(sp)
    80005f6a:	e4de                	sd	s7,72(sp)
    80005f6c:	e0e2                	sd	s8,64(sp)
    80005f6e:	fc66                	sd	s9,56(sp)
    80005f70:	f86a                	sd	s10,48(sp)
    80005f72:	f46e                	sd	s11,40(sp)
    80005f74:	0900                	addi	s0,sp,144
    80005f76:	8aaa                	mv	s5,a0
    80005f78:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f7a:	00c52c83          	lw	s9,12(a0)
    80005f7e:	001c9c9b          	slliw	s9,s9,0x1
    80005f82:	1c82                	slli	s9,s9,0x20
    80005f84:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005f88:	0001f517          	auipc	a0,0x1f
    80005f8c:	12050513          	addi	a0,a0,288 # 800250a8 <disk+0x20a8>
    80005f90:	ffffb097          	auipc	ra,0xffffb
    80005f94:	cba080e7          	jalr	-838(ra) # 80000c4a <acquire>
  for(int i = 0; i < 3; i++){
    80005f98:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f9a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f9c:	0001dc17          	auipc	s8,0x1d
    80005fa0:	064c0c13          	addi	s8,s8,100 # 80023000 <disk>
    80005fa4:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80005fa6:	4b0d                	li	s6,3
    80005fa8:	a0ad                	j	80006012 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005faa:	00fc0733          	add	a4,s8,a5
    80005fae:	975e                	add	a4,a4,s7
    80005fb0:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005fb4:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005fb6:	0207c563          	bltz	a5,80005fe0 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005fba:	2905                	addiw	s2,s2,1
    80005fbc:	0611                	addi	a2,a2,4
    80005fbe:	19690c63          	beq	s2,s6,80006156 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    80005fc2:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005fc4:	0001f717          	auipc	a4,0x1f
    80005fc8:	05470713          	addi	a4,a4,84 # 80025018 <disk+0x2018>
    80005fcc:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005fce:	00074683          	lbu	a3,0(a4)
    80005fd2:	fee1                	bnez	a3,80005faa <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80005fd4:	2785                	addiw	a5,a5,1
    80005fd6:	0705                	addi	a4,a4,1
    80005fd8:	fe979be3          	bne	a5,s1,80005fce <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80005fdc:	57fd                	li	a5,-1
    80005fde:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005fe0:	01205d63          	blez	s2,80005ffa <virtio_disk_rw+0xa2>
    80005fe4:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005fe6:	000a2503          	lw	a0,0(s4)
    80005fea:	00000097          	auipc	ra,0x0
    80005fee:	dac080e7          	jalr	-596(ra) # 80005d96 <free_desc>
      for(int j = 0; j < i; j++)
    80005ff2:	2d85                	addiw	s11,s11,1
    80005ff4:	0a11                	addi	s4,s4,4
    80005ff6:	ff2d98e3          	bne	s11,s2,80005fe6 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ffa:	0001f597          	auipc	a1,0x1f
    80005ffe:	0ae58593          	addi	a1,a1,174 # 800250a8 <disk+0x20a8>
    80006002:	0001f517          	auipc	a0,0x1f
    80006006:	01650513          	addi	a0,a0,22 # 80025018 <disk+0x2018>
    8000600a:	ffffc097          	auipc	ra,0xffffc
    8000600e:	228080e7          	jalr	552(ra) # 80002232 <sleep>
  for(int i = 0; i < 3; i++){
    80006012:	f8040a13          	addi	s4,s0,-128
{
    80006016:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006018:	894e                	mv	s2,s3
    8000601a:	b765                	j	80005fc2 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000601c:	0001f717          	auipc	a4,0x1f
    80006020:	fe473703          	ld	a4,-28(a4) # 80025000 <disk+0x2000>
    80006024:	973e                	add	a4,a4,a5
    80006026:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000602a:	0001d517          	auipc	a0,0x1d
    8000602e:	fd650513          	addi	a0,a0,-42 # 80023000 <disk>
    80006032:	0001f717          	auipc	a4,0x1f
    80006036:	fce70713          	addi	a4,a4,-50 # 80025000 <disk+0x2000>
    8000603a:	6314                	ld	a3,0(a4)
    8000603c:	96be                	add	a3,a3,a5
    8000603e:	00c6d603          	lhu	a2,12(a3)
    80006042:	00166613          	ori	a2,a2,1
    80006046:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000604a:	f8842683          	lw	a3,-120(s0)
    8000604e:	6310                	ld	a2,0(a4)
    80006050:	97b2                	add	a5,a5,a2
    80006052:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    80006056:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    8000605a:	0612                	slli	a2,a2,0x4
    8000605c:	962a                	add	a2,a2,a0
    8000605e:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006062:	00469793          	slli	a5,a3,0x4
    80006066:	630c                	ld	a1,0(a4)
    80006068:	95be                	add	a1,a1,a5
    8000606a:	6689                	lui	a3,0x2
    8000606c:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006070:	96ca                	add	a3,a3,s2
    80006072:	96aa                	add	a3,a3,a0
    80006074:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    80006076:	6314                	ld	a3,0(a4)
    80006078:	96be                	add	a3,a3,a5
    8000607a:	4585                	li	a1,1
    8000607c:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000607e:	6314                	ld	a3,0(a4)
    80006080:	96be                	add	a3,a3,a5
    80006082:	4509                	li	a0,2
    80006084:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    80006088:	6314                	ld	a3,0(a4)
    8000608a:	97b6                	add	a5,a5,a3
    8000608c:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006090:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006094:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80006098:	6714                	ld	a3,8(a4)
    8000609a:	0026d783          	lhu	a5,2(a3)
    8000609e:	8b9d                	andi	a5,a5,7
    800060a0:	0789                	addi	a5,a5,2
    800060a2:	0786                	slli	a5,a5,0x1
    800060a4:	96be                	add	a3,a3,a5
    800060a6:	00969023          	sh	s1,0(a3)
  __sync_synchronize();
    800060aa:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800060ae:	6718                	ld	a4,8(a4)
    800060b0:	00275783          	lhu	a5,2(a4)
    800060b4:	2785                	addiw	a5,a5,1
    800060b6:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800060ba:	100017b7          	lui	a5,0x10001
    800060be:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800060c2:	004aa783          	lw	a5,4(s5)
    800060c6:	02b79163          	bne	a5,a1,800060e8 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    800060ca:	0001f917          	auipc	s2,0x1f
    800060ce:	fde90913          	addi	s2,s2,-34 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    800060d2:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800060d4:	85ca                	mv	a1,s2
    800060d6:	8556                	mv	a0,s5
    800060d8:	ffffc097          	auipc	ra,0xffffc
    800060dc:	15a080e7          	jalr	346(ra) # 80002232 <sleep>
  while(b->disk == 1) {
    800060e0:	004aa783          	lw	a5,4(s5)
    800060e4:	fe9788e3          	beq	a5,s1,800060d4 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    800060e8:	f8042483          	lw	s1,-128(s0)
    800060ec:	20048713          	addi	a4,s1,512
    800060f0:	0712                	slli	a4,a4,0x4
    800060f2:	0001d797          	auipc	a5,0x1d
    800060f6:	f0e78793          	addi	a5,a5,-242 # 80023000 <disk>
    800060fa:	97ba                	add	a5,a5,a4
    800060fc:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006100:	0001f917          	auipc	s2,0x1f
    80006104:	f0090913          	addi	s2,s2,-256 # 80025000 <disk+0x2000>
    80006108:	a019                	j	8000610e <virtio_disk_rw+0x1b6>
      i = disk.desc[i].next;
    8000610a:	00e7d483          	lhu	s1,14(a5)
    free_desc(i);
    8000610e:	8526                	mv	a0,s1
    80006110:	00000097          	auipc	ra,0x0
    80006114:	c86080e7          	jalr	-890(ra) # 80005d96 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006118:	0492                	slli	s1,s1,0x4
    8000611a:	00093783          	ld	a5,0(s2)
    8000611e:	97a6                	add	a5,a5,s1
    80006120:	00c7d703          	lhu	a4,12(a5)
    80006124:	8b05                	andi	a4,a4,1
    80006126:	f375                	bnez	a4,8000610a <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006128:	0001f517          	auipc	a0,0x1f
    8000612c:	f8050513          	addi	a0,a0,-128 # 800250a8 <disk+0x20a8>
    80006130:	ffffb097          	auipc	ra,0xffffb
    80006134:	bce080e7          	jalr	-1074(ra) # 80000cfe <release>
}
    80006138:	60aa                	ld	ra,136(sp)
    8000613a:	640a                	ld	s0,128(sp)
    8000613c:	74e6                	ld	s1,120(sp)
    8000613e:	7946                	ld	s2,112(sp)
    80006140:	79a6                	ld	s3,104(sp)
    80006142:	7a06                	ld	s4,96(sp)
    80006144:	6ae6                	ld	s5,88(sp)
    80006146:	6b46                	ld	s6,80(sp)
    80006148:	6ba6                	ld	s7,72(sp)
    8000614a:	6c06                	ld	s8,64(sp)
    8000614c:	7ce2                	ld	s9,56(sp)
    8000614e:	7d42                	ld	s10,48(sp)
    80006150:	7da2                	ld	s11,40(sp)
    80006152:	6149                	addi	sp,sp,144
    80006154:	8082                	ret
  if(write)
    80006156:	01a037b3          	snez	a5,s10
    8000615a:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    8000615e:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006162:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006166:	f8042483          	lw	s1,-128(s0)
    8000616a:	00449913          	slli	s2,s1,0x4
    8000616e:	0001f997          	auipc	s3,0x1f
    80006172:	e9298993          	addi	s3,s3,-366 # 80025000 <disk+0x2000>
    80006176:	0009ba03          	ld	s4,0(s3)
    8000617a:	9a4a                	add	s4,s4,s2
    8000617c:	f7040513          	addi	a0,s0,-144
    80006180:	ffffb097          	auipc	ra,0xffffb
    80006184:	f96080e7          	jalr	-106(ra) # 80001116 <kvmpa>
    80006188:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    8000618c:	0009b783          	ld	a5,0(s3)
    80006190:	97ca                	add	a5,a5,s2
    80006192:	4741                	li	a4,16
    80006194:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006196:	0009b783          	ld	a5,0(s3)
    8000619a:	97ca                	add	a5,a5,s2
    8000619c:	4705                	li	a4,1
    8000619e:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800061a2:	f8442783          	lw	a5,-124(s0)
    800061a6:	0009b703          	ld	a4,0(s3)
    800061aa:	974a                	add	a4,a4,s2
    800061ac:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800061b0:	0792                	slli	a5,a5,0x4
    800061b2:	0009b703          	ld	a4,0(s3)
    800061b6:	973e                	add	a4,a4,a5
    800061b8:	058a8693          	addi	a3,s5,88
    800061bc:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    800061be:	0009b703          	ld	a4,0(s3)
    800061c2:	973e                	add	a4,a4,a5
    800061c4:	40000693          	li	a3,1024
    800061c8:	c714                	sw	a3,8(a4)
  if(write)
    800061ca:	e40d19e3          	bnez	s10,8000601c <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800061ce:	0001f717          	auipc	a4,0x1f
    800061d2:	e3273703          	ld	a4,-462(a4) # 80025000 <disk+0x2000>
    800061d6:	973e                	add	a4,a4,a5
    800061d8:	4689                	li	a3,2
    800061da:	00d71623          	sh	a3,12(a4)
    800061de:	b5b1                	j	8000602a <virtio_disk_rw+0xd2>

00000000800061e0 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061e0:	1101                	addi	sp,sp,-32
    800061e2:	ec06                	sd	ra,24(sp)
    800061e4:	e822                	sd	s0,16(sp)
    800061e6:	e426                	sd	s1,8(sp)
    800061e8:	e04a                	sd	s2,0(sp)
    800061ea:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061ec:	0001f517          	auipc	a0,0x1f
    800061f0:	ebc50513          	addi	a0,a0,-324 # 800250a8 <disk+0x20a8>
    800061f4:	ffffb097          	auipc	ra,0xffffb
    800061f8:	a56080e7          	jalr	-1450(ra) # 80000c4a <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800061fc:	0001f717          	auipc	a4,0x1f
    80006200:	e0470713          	addi	a4,a4,-508 # 80025000 <disk+0x2000>
    80006204:	02075783          	lhu	a5,32(a4)
    80006208:	6b18                	ld	a4,16(a4)
    8000620a:	00275683          	lhu	a3,2(a4)
    8000620e:	8ebd                	xor	a3,a3,a5
    80006210:	8a9d                	andi	a3,a3,7
    80006212:	cab9                	beqz	a3,80006268 <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    80006214:	0001d917          	auipc	s2,0x1d
    80006218:	dec90913          	addi	s2,s2,-532 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    8000621c:	0001f497          	auipc	s1,0x1f
    80006220:	de448493          	addi	s1,s1,-540 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    80006224:	078e                	slli	a5,a5,0x3
    80006226:	973e                	add	a4,a4,a5
    80006228:	435c                	lw	a5,4(a4)
    if(disk.info[id].status != 0)
    8000622a:	20078713          	addi	a4,a5,512
    8000622e:	0712                	slli	a4,a4,0x4
    80006230:	974a                	add	a4,a4,s2
    80006232:	03074703          	lbu	a4,48(a4)
    80006236:	ef21                	bnez	a4,8000628e <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    80006238:	20078793          	addi	a5,a5,512
    8000623c:	0792                	slli	a5,a5,0x4
    8000623e:	97ca                	add	a5,a5,s2
    80006240:	7798                	ld	a4,40(a5)
    80006242:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    80006246:	7788                	ld	a0,40(a5)
    80006248:	ffffc097          	auipc	ra,0xffffc
    8000624c:	16a080e7          	jalr	362(ra) # 800023b2 <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006250:	0204d783          	lhu	a5,32(s1)
    80006254:	2785                	addiw	a5,a5,1
    80006256:	8b9d                	andi	a5,a5,7
    80006258:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    8000625c:	6898                	ld	a4,16(s1)
    8000625e:	00275683          	lhu	a3,2(a4)
    80006262:	8a9d                	andi	a3,a3,7
    80006264:	fcf690e3          	bne	a3,a5,80006224 <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006268:	10001737          	lui	a4,0x10001
    8000626c:	533c                	lw	a5,96(a4)
    8000626e:	8b8d                	andi	a5,a5,3
    80006270:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006272:	0001f517          	auipc	a0,0x1f
    80006276:	e3650513          	addi	a0,a0,-458 # 800250a8 <disk+0x20a8>
    8000627a:	ffffb097          	auipc	ra,0xffffb
    8000627e:	a84080e7          	jalr	-1404(ra) # 80000cfe <release>
}
    80006282:	60e2                	ld	ra,24(sp)
    80006284:	6442                	ld	s0,16(sp)
    80006286:	64a2                	ld	s1,8(sp)
    80006288:	6902                	ld	s2,0(sp)
    8000628a:	6105                	addi	sp,sp,32
    8000628c:	8082                	ret
      panic("virtio_disk_intr status");
    8000628e:	00002517          	auipc	a0,0x2
    80006292:	6f250513          	addi	a0,a0,1778 # 80008980 <syscall_list+0x3d0>
    80006296:	ffffa097          	auipc	ra,0xffffa
    8000629a:	2b0080e7          	jalr	688(ra) # 80000546 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
