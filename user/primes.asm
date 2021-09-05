
user/_primes：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]){
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	0080                	addi	s0,sp,64
  if(argc > 1){
   c:	4785                	li	a5,1
   e:	02a7d063          	bge	a5,a0,2e <main+0x2e>
    fprintf(2, "Error of Input!");
  12:	00001597          	auipc	a1,0x1
  16:	90658593          	addi	a1,a1,-1786 # 918 <malloc+0xe6>
  1a:	4509                	li	a0,2
  1c:	00000097          	auipc	ra,0x0
  20:	730080e7          	jalr	1840(ra) # 74c <fprintf>
    exit(1);
  24:	4505                	li	a0,1
  26:	00000097          	auipc	ra,0x0
  2a:	3da080e7          	jalr	986(ra) # 400 <exit>
  }
  int p[2];
  pipe(p);
  2e:	fd840513          	addi	a0,s0,-40
  32:	00000097          	auipc	ra,0x0
  36:	3de080e7          	jalr	990(ra) # 410 <pipe>
  char buf[1];
  int prime = 0;
  if(fork() != 0){
  3a:	00000097          	auipc	ra,0x0
  3e:	3be080e7          	jalr	958(ra) # 3f8 <fork>
  42:	c939                	beqz	a0,98 <main+0x98>
    close(p[0]);
  44:	fd842503          	lw	a0,-40(s0)
  48:	00000097          	auipc	ra,0x0
  4c:	3e0080e7          	jalr	992(ra) # 428 <close>
  50:	03200493          	li	s1,50
    for(int i = 0;i < 34;++i){
  54:	05400913          	li	s2,84
      buf[0] = i+'0'+2;
  58:	fc940823          	sb	s1,-48(s0)
      write(p[1], buf, 1);
  5c:	4605                	li	a2,1
  5e:	fd040593          	addi	a1,s0,-48
  62:	fdc42503          	lw	a0,-36(s0)
  66:	00000097          	auipc	ra,0x0
  6a:	3ba080e7          	jalr	954(ra) # 420 <write>
    for(int i = 0;i < 34;++i){
  6e:	2485                	addiw	s1,s1,1
  70:	0ff4f493          	zext.b	s1,s1
  74:	ff2492e3          	bne	s1,s2,58 <main+0x58>
    }
    close(p[1]);
  78:	fdc42503          	lw	a0,-36(s0)
  7c:	00000097          	auipc	ra,0x0
  80:	3ac080e7          	jalr	940(ra) # 428 <close>
    wait(0);
  84:	4501                	li	a0,0
  86:	00000097          	auipc	ra,0x0
  8a:	382080e7          	jalr	898(ra) # 408 <wait>
    exit(0);
  8e:	4501                	li	a0,0
  90:	00000097          	auipc	ra,0x0
  94:	370080e7          	jalr	880(ra) # 400 <exit>
  }else{
    close(p[1]);
  98:	fdc42503          	lw	a0,-36(s0)
  9c:	00000097          	auipc	ra,0x0
  a0:	38c080e7          	jalr	908(ra) # 428 <close>
    while(1){
      if(read(p[0], buf, 1) != 0){
        prime = buf[0] - '0';
        printf("prime %d\n", prime);
  a4:	00001917          	auipc	s2,0x1
  a8:	88490913          	addi	s2,s2,-1916 # 928 <malloc+0xf6>
      if(read(p[0], buf, 1) != 0){
  ac:	4605                	li	a2,1
  ae:	fd040593          	addi	a1,s0,-48
  b2:	fd842503          	lw	a0,-40(s0)
  b6:	00000097          	auipc	ra,0x0
  ba:	362080e7          	jalr	866(ra) # 418 <read>
  be:	c95d                	beqz	a0,174 <main+0x174>
        prime = buf[0] - '0';
  c0:	fd044483          	lbu	s1,-48(s0)
  c4:	fd04849b          	addiw	s1,s1,-48
        printf("prime %d\n", prime);
  c8:	85a6                	mv	a1,s1
  ca:	854a                	mv	a0,s2
  cc:	00000097          	auipc	ra,0x0
  d0:	6ae080e7          	jalr	1710(ra) # 77a <printf>
        int p_c[2];
        pipe(p_c);
  d4:	fc840513          	addi	a0,s0,-56
  d8:	00000097          	auipc	ra,0x0
  dc:	338080e7          	jalr	824(ra) # 410 <pipe>
        if(fork() != 0){
  e0:	00000097          	auipc	ra,0x0
  e4:	318080e7          	jalr	792(ra) # 3f8 <fork>
  e8:	e115                	bnez	a0,10c <main+0x10c>
          close(p[0]);
          close(p_c[1]);
          close(p_c[0]);
          break;
        }else{
          close(p[0]);
  ea:	fd842503          	lw	a0,-40(s0)
  ee:	00000097          	auipc	ra,0x0
  f2:	33a080e7          	jalr	826(ra) # 428 <close>
          p[0] = p_c[0];
  f6:	fc842783          	lw	a5,-56(s0)
  fa:	fcf42c23          	sw	a5,-40(s0)
          close(p_c[1]);
  fe:	fcc42503          	lw	a0,-52(s0)
 102:	00000097          	auipc	ra,0x0
 106:	326080e7          	jalr	806(ra) # 428 <close>
 10a:	b74d                	j	ac <main+0xac>
          close(p_c[0]);
 10c:	fc842503          	lw	a0,-56(s0)
 110:	00000097          	auipc	ra,0x0
 114:	318080e7          	jalr	792(ra) # 428 <close>
          while(read(p[0], buf, 1) != 0){
 118:	4605                	li	a2,1
 11a:	fd040593          	addi	a1,s0,-48
 11e:	fd842503          	lw	a0,-40(s0)
 122:	00000097          	auipc	ra,0x0
 126:	2f6080e7          	jalr	758(ra) # 418 <read>
 12a:	c115                	beqz	a0,14e <main+0x14e>
            int num = buf[0] - '0';
 12c:	fd044783          	lbu	a5,-48(s0)
 130:	fd07879b          	addiw	a5,a5,-48
            if(num % prime != 0){
 134:	0297e7bb          	remw	a5,a5,s1
 138:	d3e5                	beqz	a5,118 <main+0x118>
              write(p_c[1], buf, 1);
 13a:	4605                	li	a2,1
 13c:	fd040593          	addi	a1,s0,-48
 140:	fcc42503          	lw	a0,-52(s0)
 144:	00000097          	auipc	ra,0x0
 148:	2dc080e7          	jalr	732(ra) # 420 <write>
 14c:	b7f1                	j	118 <main+0x118>
          close(p[0]);
 14e:	fd842503          	lw	a0,-40(s0)
 152:	00000097          	auipc	ra,0x0
 156:	2d6080e7          	jalr	726(ra) # 428 <close>
          close(p_c[1]);
 15a:	fcc42503          	lw	a0,-52(s0)
 15e:	00000097          	auipc	ra,0x0
 162:	2ca080e7          	jalr	714(ra) # 428 <close>
          close(p_c[0]);
 166:	fc842503          	lw	a0,-56(s0)
 16a:	00000097          	auipc	ra,0x0
 16e:	2be080e7          	jalr	702(ra) # 428 <close>
          break;
 172:	a039                	j	180 <main+0x180>
        }
      }else{
        close(p[0]);
 174:	fd842503          	lw	a0,-40(s0)
 178:	00000097          	auipc	ra,0x0
 17c:	2b0080e7          	jalr	688(ra) # 428 <close>
        break;
      }
    }
    wait(0);
 180:	4501                	li	a0,0
 182:	00000097          	auipc	ra,0x0
 186:	286080e7          	jalr	646(ra) # 408 <wait>
    exit(0);
 18a:	4501                	li	a0,0
 18c:	00000097          	auipc	ra,0x0
 190:	274080e7          	jalr	628(ra) # 400 <exit>

0000000000000194 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 194:	1141                	addi	sp,sp,-16
 196:	e422                	sd	s0,8(sp)
 198:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 19a:	87aa                	mv	a5,a0
 19c:	0585                	addi	a1,a1,1
 19e:	0785                	addi	a5,a5,1
 1a0:	fff5c703          	lbu	a4,-1(a1)
 1a4:	fee78fa3          	sb	a4,-1(a5)
 1a8:	fb75                	bnez	a4,19c <strcpy+0x8>
    ;
  return os;
}
 1aa:	6422                	ld	s0,8(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret

00000000000001b0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b0:	1141                	addi	sp,sp,-16
 1b2:	e422                	sd	s0,8(sp)
 1b4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b6:	00054783          	lbu	a5,0(a0)
 1ba:	cb91                	beqz	a5,1ce <strcmp+0x1e>
 1bc:	0005c703          	lbu	a4,0(a1)
 1c0:	00f71763          	bne	a4,a5,1ce <strcmp+0x1e>
    p++, q++;
 1c4:	0505                	addi	a0,a0,1
 1c6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	fbe5                	bnez	a5,1bc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ce:	0005c503          	lbu	a0,0(a1)
}
 1d2:	40a7853b          	subw	a0,a5,a0
 1d6:	6422                	ld	s0,8(sp)
 1d8:	0141                	addi	sp,sp,16
 1da:	8082                	ret

00000000000001dc <strlen>:

uint
strlen(const char *s)
{
 1dc:	1141                	addi	sp,sp,-16
 1de:	e422                	sd	s0,8(sp)
 1e0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e2:	00054783          	lbu	a5,0(a0)
 1e6:	cf91                	beqz	a5,202 <strlen+0x26>
 1e8:	0505                	addi	a0,a0,1
 1ea:	87aa                	mv	a5,a0
 1ec:	4685                	li	a3,1
 1ee:	9e89                	subw	a3,a3,a0
 1f0:	00f6853b          	addw	a0,a3,a5
 1f4:	0785                	addi	a5,a5,1
 1f6:	fff7c703          	lbu	a4,-1(a5)
 1fa:	fb7d                	bnez	a4,1f0 <strlen+0x14>
    ;
  return n;
}
 1fc:	6422                	ld	s0,8(sp)
 1fe:	0141                	addi	sp,sp,16
 200:	8082                	ret
  for(n = 0; s[n]; n++)
 202:	4501                	li	a0,0
 204:	bfe5                	j	1fc <strlen+0x20>

0000000000000206 <memset>:

void*
memset(void *dst, int c, uint n)
{
 206:	1141                	addi	sp,sp,-16
 208:	e422                	sd	s0,8(sp)
 20a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 20c:	ca19                	beqz	a2,222 <memset+0x1c>
 20e:	87aa                	mv	a5,a0
 210:	1602                	slli	a2,a2,0x20
 212:	9201                	srli	a2,a2,0x20
 214:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 218:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 21c:	0785                	addi	a5,a5,1
 21e:	fee79de3          	bne	a5,a4,218 <memset+0x12>
  }
  return dst;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret

0000000000000228 <strchr>:

char*
strchr(const char *s, char c)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 22e:	00054783          	lbu	a5,0(a0)
 232:	cb99                	beqz	a5,248 <strchr+0x20>
    if(*s == c)
 234:	00f58763          	beq	a1,a5,242 <strchr+0x1a>
  for(; *s; s++)
 238:	0505                	addi	a0,a0,1
 23a:	00054783          	lbu	a5,0(a0)
 23e:	fbfd                	bnez	a5,234 <strchr+0xc>
      return (char*)s;
  return 0;
 240:	4501                	li	a0,0
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret
  return 0;
 248:	4501                	li	a0,0
 24a:	bfe5                	j	242 <strchr+0x1a>

000000000000024c <gets>:

char*
gets(char *buf, int max)
{
 24c:	711d                	addi	sp,sp,-96
 24e:	ec86                	sd	ra,88(sp)
 250:	e8a2                	sd	s0,80(sp)
 252:	e4a6                	sd	s1,72(sp)
 254:	e0ca                	sd	s2,64(sp)
 256:	fc4e                	sd	s3,56(sp)
 258:	f852                	sd	s4,48(sp)
 25a:	f456                	sd	s5,40(sp)
 25c:	f05a                	sd	s6,32(sp)
 25e:	ec5e                	sd	s7,24(sp)
 260:	1080                	addi	s0,sp,96
 262:	8baa                	mv	s7,a0
 264:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 266:	892a                	mv	s2,a0
 268:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 26a:	4aa9                	li	s5,10
 26c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 26e:	89a6                	mv	s3,s1
 270:	2485                	addiw	s1,s1,1
 272:	0344d863          	bge	s1,s4,2a2 <gets+0x56>
    cc = read(0, &c, 1);
 276:	4605                	li	a2,1
 278:	faf40593          	addi	a1,s0,-81
 27c:	4501                	li	a0,0
 27e:	00000097          	auipc	ra,0x0
 282:	19a080e7          	jalr	410(ra) # 418 <read>
    if(cc < 1)
 286:	00a05e63          	blez	a0,2a2 <gets+0x56>
    buf[i++] = c;
 28a:	faf44783          	lbu	a5,-81(s0)
 28e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 292:	01578763          	beq	a5,s5,2a0 <gets+0x54>
 296:	0905                	addi	s2,s2,1
 298:	fd679be3          	bne	a5,s6,26e <gets+0x22>
  for(i=0; i+1 < max; ){
 29c:	89a6                	mv	s3,s1
 29e:	a011                	j	2a2 <gets+0x56>
 2a0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a2:	99de                	add	s3,s3,s7
 2a4:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a8:	855e                	mv	a0,s7
 2aa:	60e6                	ld	ra,88(sp)
 2ac:	6446                	ld	s0,80(sp)
 2ae:	64a6                	ld	s1,72(sp)
 2b0:	6906                	ld	s2,64(sp)
 2b2:	79e2                	ld	s3,56(sp)
 2b4:	7a42                	ld	s4,48(sp)
 2b6:	7aa2                	ld	s5,40(sp)
 2b8:	7b02                	ld	s6,32(sp)
 2ba:	6be2                	ld	s7,24(sp)
 2bc:	6125                	addi	sp,sp,96
 2be:	8082                	ret

00000000000002c0 <stat>:

int
stat(const char *n, struct stat *st)
{
 2c0:	1101                	addi	sp,sp,-32
 2c2:	ec06                	sd	ra,24(sp)
 2c4:	e822                	sd	s0,16(sp)
 2c6:	e426                	sd	s1,8(sp)
 2c8:	e04a                	sd	s2,0(sp)
 2ca:	1000                	addi	s0,sp,32
 2cc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ce:	4581                	li	a1,0
 2d0:	00000097          	auipc	ra,0x0
 2d4:	170080e7          	jalr	368(ra) # 440 <open>
  if(fd < 0)
 2d8:	02054563          	bltz	a0,302 <stat+0x42>
 2dc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2de:	85ca                	mv	a1,s2
 2e0:	00000097          	auipc	ra,0x0
 2e4:	178080e7          	jalr	376(ra) # 458 <fstat>
 2e8:	892a                	mv	s2,a0
  close(fd);
 2ea:	8526                	mv	a0,s1
 2ec:	00000097          	auipc	ra,0x0
 2f0:	13c080e7          	jalr	316(ra) # 428 <close>
  return r;
}
 2f4:	854a                	mv	a0,s2
 2f6:	60e2                	ld	ra,24(sp)
 2f8:	6442                	ld	s0,16(sp)
 2fa:	64a2                	ld	s1,8(sp)
 2fc:	6902                	ld	s2,0(sp)
 2fe:	6105                	addi	sp,sp,32
 300:	8082                	ret
    return -1;
 302:	597d                	li	s2,-1
 304:	bfc5                	j	2f4 <stat+0x34>

0000000000000306 <atoi>:

int
atoi(const char *s)
{
 306:	1141                	addi	sp,sp,-16
 308:	e422                	sd	s0,8(sp)
 30a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 30c:	00054683          	lbu	a3,0(a0)
 310:	fd06879b          	addiw	a5,a3,-48
 314:	0ff7f793          	zext.b	a5,a5
 318:	4625                	li	a2,9
 31a:	02f66863          	bltu	a2,a5,34a <atoi+0x44>
 31e:	872a                	mv	a4,a0
  n = 0;
 320:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 322:	0705                	addi	a4,a4,1
 324:	0025179b          	slliw	a5,a0,0x2
 328:	9fa9                	addw	a5,a5,a0
 32a:	0017979b          	slliw	a5,a5,0x1
 32e:	9fb5                	addw	a5,a5,a3
 330:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 334:	00074683          	lbu	a3,0(a4)
 338:	fd06879b          	addiw	a5,a3,-48
 33c:	0ff7f793          	zext.b	a5,a5
 340:	fef671e3          	bgeu	a2,a5,322 <atoi+0x1c>
  return n;
}
 344:	6422                	ld	s0,8(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret
  n = 0;
 34a:	4501                	li	a0,0
 34c:	bfe5                	j	344 <atoi+0x3e>

000000000000034e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 34e:	1141                	addi	sp,sp,-16
 350:	e422                	sd	s0,8(sp)
 352:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 354:	02b57463          	bgeu	a0,a1,37c <memmove+0x2e>
    while(n-- > 0)
 358:	00c05f63          	blez	a2,376 <memmove+0x28>
 35c:	1602                	slli	a2,a2,0x20
 35e:	9201                	srli	a2,a2,0x20
 360:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 364:	872a                	mv	a4,a0
      *dst++ = *src++;
 366:	0585                	addi	a1,a1,1
 368:	0705                	addi	a4,a4,1
 36a:	fff5c683          	lbu	a3,-1(a1)
 36e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 372:	fee79ae3          	bne	a5,a4,366 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 376:	6422                	ld	s0,8(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret
    dst += n;
 37c:	00c50733          	add	a4,a0,a2
    src += n;
 380:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 382:	fec05ae3          	blez	a2,376 <memmove+0x28>
 386:	fff6079b          	addiw	a5,a2,-1
 38a:	1782                	slli	a5,a5,0x20
 38c:	9381                	srli	a5,a5,0x20
 38e:	fff7c793          	not	a5,a5
 392:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 394:	15fd                	addi	a1,a1,-1
 396:	177d                	addi	a4,a4,-1
 398:	0005c683          	lbu	a3,0(a1)
 39c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3a0:	fee79ae3          	bne	a5,a4,394 <memmove+0x46>
 3a4:	bfc9                	j	376 <memmove+0x28>

00000000000003a6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3a6:	1141                	addi	sp,sp,-16
 3a8:	e422                	sd	s0,8(sp)
 3aa:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3ac:	ca05                	beqz	a2,3dc <memcmp+0x36>
 3ae:	fff6069b          	addiw	a3,a2,-1
 3b2:	1682                	slli	a3,a3,0x20
 3b4:	9281                	srli	a3,a3,0x20
 3b6:	0685                	addi	a3,a3,1
 3b8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3ba:	00054783          	lbu	a5,0(a0)
 3be:	0005c703          	lbu	a4,0(a1)
 3c2:	00e79863          	bne	a5,a4,3d2 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3c6:	0505                	addi	a0,a0,1
    p2++;
 3c8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3ca:	fed518e3          	bne	a0,a3,3ba <memcmp+0x14>
  }
  return 0;
 3ce:	4501                	li	a0,0
 3d0:	a019                	j	3d6 <memcmp+0x30>
      return *p1 - *p2;
 3d2:	40e7853b          	subw	a0,a5,a4
}
 3d6:	6422                	ld	s0,8(sp)
 3d8:	0141                	addi	sp,sp,16
 3da:	8082                	ret
  return 0;
 3dc:	4501                	li	a0,0
 3de:	bfe5                	j	3d6 <memcmp+0x30>

00000000000003e0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e406                	sd	ra,8(sp)
 3e4:	e022                	sd	s0,0(sp)
 3e6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3e8:	00000097          	auipc	ra,0x0
 3ec:	f66080e7          	jalr	-154(ra) # 34e <memmove>
}
 3f0:	60a2                	ld	ra,8(sp)
 3f2:	6402                	ld	s0,0(sp)
 3f4:	0141                	addi	sp,sp,16
 3f6:	8082                	ret

00000000000003f8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3f8:	4885                	li	a7,1
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <exit>:
.global exit
exit:
 li a7, SYS_exit
 400:	4889                	li	a7,2
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <wait>:
.global wait
wait:
 li a7, SYS_wait
 408:	488d                	li	a7,3
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 410:	4891                	li	a7,4
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <read>:
.global read
read:
 li a7, SYS_read
 418:	4895                	li	a7,5
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <write>:
.global write
write:
 li a7, SYS_write
 420:	48c1                	li	a7,16
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <close>:
.global close
close:
 li a7, SYS_close
 428:	48d5                	li	a7,21
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <kill>:
.global kill
kill:
 li a7, SYS_kill
 430:	4899                	li	a7,6
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <exec>:
.global exec
exec:
 li a7, SYS_exec
 438:	489d                	li	a7,7
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <open>:
.global open
open:
 li a7, SYS_open
 440:	48bd                	li	a7,15
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 448:	48c5                	li	a7,17
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 450:	48c9                	li	a7,18
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 458:	48a1                	li	a7,8
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <link>:
.global link
link:
 li a7, SYS_link
 460:	48cd                	li	a7,19
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 468:	48d1                	li	a7,20
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 470:	48a5                	li	a7,9
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <dup>:
.global dup
dup:
 li a7, SYS_dup
 478:	48a9                	li	a7,10
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 480:	48ad                	li	a7,11
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 488:	48b1                	li	a7,12
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 490:	48b5                	li	a7,13
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 498:	48b9                	li	a7,14
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4a0:	1101                	addi	sp,sp,-32
 4a2:	ec06                	sd	ra,24(sp)
 4a4:	e822                	sd	s0,16(sp)
 4a6:	1000                	addi	s0,sp,32
 4a8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ac:	4605                	li	a2,1
 4ae:	fef40593          	addi	a1,s0,-17
 4b2:	00000097          	auipc	ra,0x0
 4b6:	f6e080e7          	jalr	-146(ra) # 420 <write>
}
 4ba:	60e2                	ld	ra,24(sp)
 4bc:	6442                	ld	s0,16(sp)
 4be:	6105                	addi	sp,sp,32
 4c0:	8082                	ret

00000000000004c2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4c2:	7139                	addi	sp,sp,-64
 4c4:	fc06                	sd	ra,56(sp)
 4c6:	f822                	sd	s0,48(sp)
 4c8:	f426                	sd	s1,40(sp)
 4ca:	f04a                	sd	s2,32(sp)
 4cc:	ec4e                	sd	s3,24(sp)
 4ce:	0080                	addi	s0,sp,64
 4d0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4d2:	c299                	beqz	a3,4d8 <printint+0x16>
 4d4:	0805c963          	bltz	a1,566 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4d8:	2581                	sext.w	a1,a1
  neg = 0;
 4da:	4881                	li	a7,0
 4dc:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4e0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4e2:	2601                	sext.w	a2,a2
 4e4:	00000517          	auipc	a0,0x0
 4e8:	4b450513          	addi	a0,a0,1204 # 998 <digits>
 4ec:	883a                	mv	a6,a4
 4ee:	2705                	addiw	a4,a4,1
 4f0:	02c5f7bb          	remuw	a5,a1,a2
 4f4:	1782                	slli	a5,a5,0x20
 4f6:	9381                	srli	a5,a5,0x20
 4f8:	97aa                	add	a5,a5,a0
 4fa:	0007c783          	lbu	a5,0(a5)
 4fe:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 502:	0005879b          	sext.w	a5,a1
 506:	02c5d5bb          	divuw	a1,a1,a2
 50a:	0685                	addi	a3,a3,1
 50c:	fec7f0e3          	bgeu	a5,a2,4ec <printint+0x2a>
  if(neg)
 510:	00088c63          	beqz	a7,528 <printint+0x66>
    buf[i++] = '-';
 514:	fd070793          	addi	a5,a4,-48
 518:	00878733          	add	a4,a5,s0
 51c:	02d00793          	li	a5,45
 520:	fef70823          	sb	a5,-16(a4)
 524:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 528:	02e05863          	blez	a4,558 <printint+0x96>
 52c:	fc040793          	addi	a5,s0,-64
 530:	00e78933          	add	s2,a5,a4
 534:	fff78993          	addi	s3,a5,-1
 538:	99ba                	add	s3,s3,a4
 53a:	377d                	addiw	a4,a4,-1
 53c:	1702                	slli	a4,a4,0x20
 53e:	9301                	srli	a4,a4,0x20
 540:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 544:	fff94583          	lbu	a1,-1(s2)
 548:	8526                	mv	a0,s1
 54a:	00000097          	auipc	ra,0x0
 54e:	f56080e7          	jalr	-170(ra) # 4a0 <putc>
  while(--i >= 0)
 552:	197d                	addi	s2,s2,-1
 554:	ff3918e3          	bne	s2,s3,544 <printint+0x82>
}
 558:	70e2                	ld	ra,56(sp)
 55a:	7442                	ld	s0,48(sp)
 55c:	74a2                	ld	s1,40(sp)
 55e:	7902                	ld	s2,32(sp)
 560:	69e2                	ld	s3,24(sp)
 562:	6121                	addi	sp,sp,64
 564:	8082                	ret
    x = -xx;
 566:	40b005bb          	negw	a1,a1
    neg = 1;
 56a:	4885                	li	a7,1
    x = -xx;
 56c:	bf85                	j	4dc <printint+0x1a>

000000000000056e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 56e:	7119                	addi	sp,sp,-128
 570:	fc86                	sd	ra,120(sp)
 572:	f8a2                	sd	s0,112(sp)
 574:	f4a6                	sd	s1,104(sp)
 576:	f0ca                	sd	s2,96(sp)
 578:	ecce                	sd	s3,88(sp)
 57a:	e8d2                	sd	s4,80(sp)
 57c:	e4d6                	sd	s5,72(sp)
 57e:	e0da                	sd	s6,64(sp)
 580:	fc5e                	sd	s7,56(sp)
 582:	f862                	sd	s8,48(sp)
 584:	f466                	sd	s9,40(sp)
 586:	f06a                	sd	s10,32(sp)
 588:	ec6e                	sd	s11,24(sp)
 58a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 58c:	0005c903          	lbu	s2,0(a1)
 590:	18090f63          	beqz	s2,72e <vprintf+0x1c0>
 594:	8aaa                	mv	s5,a0
 596:	8b32                	mv	s6,a2
 598:	00158493          	addi	s1,a1,1
  state = 0;
 59c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 59e:	02500a13          	li	s4,37
 5a2:	4c55                	li	s8,21
 5a4:	00000c97          	auipc	s9,0x0
 5a8:	39cc8c93          	addi	s9,s9,924 # 940 <malloc+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5ac:	02800d93          	li	s11,40
  putc(fd, 'x');
 5b0:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5b2:	00000b97          	auipc	s7,0x0
 5b6:	3e6b8b93          	addi	s7,s7,998 # 998 <digits>
 5ba:	a839                	j	5d8 <vprintf+0x6a>
        putc(fd, c);
 5bc:	85ca                	mv	a1,s2
 5be:	8556                	mv	a0,s5
 5c0:	00000097          	auipc	ra,0x0
 5c4:	ee0080e7          	jalr	-288(ra) # 4a0 <putc>
 5c8:	a019                	j	5ce <vprintf+0x60>
    } else if(state == '%'){
 5ca:	01498d63          	beq	s3,s4,5e4 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5ce:	0485                	addi	s1,s1,1
 5d0:	fff4c903          	lbu	s2,-1(s1)
 5d4:	14090d63          	beqz	s2,72e <vprintf+0x1c0>
    if(state == 0){
 5d8:	fe0999e3          	bnez	s3,5ca <vprintf+0x5c>
      if(c == '%'){
 5dc:	ff4910e3          	bne	s2,s4,5bc <vprintf+0x4e>
        state = '%';
 5e0:	89d2                	mv	s3,s4
 5e2:	b7f5                	j	5ce <vprintf+0x60>
      if(c == 'd'){
 5e4:	11490c63          	beq	s2,s4,6fc <vprintf+0x18e>
 5e8:	f9d9079b          	addiw	a5,s2,-99
 5ec:	0ff7f793          	zext.b	a5,a5
 5f0:	10fc6e63          	bltu	s8,a5,70c <vprintf+0x19e>
 5f4:	f9d9079b          	addiw	a5,s2,-99
 5f8:	0ff7f713          	zext.b	a4,a5
 5fc:	10ec6863          	bltu	s8,a4,70c <vprintf+0x19e>
 600:	00271793          	slli	a5,a4,0x2
 604:	97e6                	add	a5,a5,s9
 606:	439c                	lw	a5,0(a5)
 608:	97e6                	add	a5,a5,s9
 60a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 60c:	008b0913          	addi	s2,s6,8
 610:	4685                	li	a3,1
 612:	4629                	li	a2,10
 614:	000b2583          	lw	a1,0(s6)
 618:	8556                	mv	a0,s5
 61a:	00000097          	auipc	ra,0x0
 61e:	ea8080e7          	jalr	-344(ra) # 4c2 <printint>
 622:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 624:	4981                	li	s3,0
 626:	b765                	j	5ce <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 628:	008b0913          	addi	s2,s6,8
 62c:	4681                	li	a3,0
 62e:	4629                	li	a2,10
 630:	000b2583          	lw	a1,0(s6)
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	e8c080e7          	jalr	-372(ra) # 4c2 <printint>
 63e:	8b4a                	mv	s6,s2
      state = 0;
 640:	4981                	li	s3,0
 642:	b771                	j	5ce <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 644:	008b0913          	addi	s2,s6,8
 648:	4681                	li	a3,0
 64a:	866a                	mv	a2,s10
 64c:	000b2583          	lw	a1,0(s6)
 650:	8556                	mv	a0,s5
 652:	00000097          	auipc	ra,0x0
 656:	e70080e7          	jalr	-400(ra) # 4c2 <printint>
 65a:	8b4a                	mv	s6,s2
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bf85                	j	5ce <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 660:	008b0793          	addi	a5,s6,8
 664:	f8f43423          	sd	a5,-120(s0)
 668:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 66c:	03000593          	li	a1,48
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	e2e080e7          	jalr	-466(ra) # 4a0 <putc>
  putc(fd, 'x');
 67a:	07800593          	li	a1,120
 67e:	8556                	mv	a0,s5
 680:	00000097          	auipc	ra,0x0
 684:	e20080e7          	jalr	-480(ra) # 4a0 <putc>
 688:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68a:	03c9d793          	srli	a5,s3,0x3c
 68e:	97de                	add	a5,a5,s7
 690:	0007c583          	lbu	a1,0(a5)
 694:	8556                	mv	a0,s5
 696:	00000097          	auipc	ra,0x0
 69a:	e0a080e7          	jalr	-502(ra) # 4a0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 69e:	0992                	slli	s3,s3,0x4
 6a0:	397d                	addiw	s2,s2,-1
 6a2:	fe0914e3          	bnez	s2,68a <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6a6:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6aa:	4981                	li	s3,0
 6ac:	b70d                	j	5ce <vprintf+0x60>
        s = va_arg(ap, char*);
 6ae:	008b0913          	addi	s2,s6,8
 6b2:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6b6:	02098163          	beqz	s3,6d8 <vprintf+0x16a>
        while(*s != 0){
 6ba:	0009c583          	lbu	a1,0(s3)
 6be:	c5ad                	beqz	a1,728 <vprintf+0x1ba>
          putc(fd, *s);
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	dde080e7          	jalr	-546(ra) # 4a0 <putc>
          s++;
 6ca:	0985                	addi	s3,s3,1
        while(*s != 0){
 6cc:	0009c583          	lbu	a1,0(s3)
 6d0:	f9e5                	bnez	a1,6c0 <vprintf+0x152>
        s = va_arg(ap, char*);
 6d2:	8b4a                	mv	s6,s2
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	bde5                	j	5ce <vprintf+0x60>
          s = "(null)";
 6d8:	00000997          	auipc	s3,0x0
 6dc:	26098993          	addi	s3,s3,608 # 938 <malloc+0x106>
        while(*s != 0){
 6e0:	85ee                	mv	a1,s11
 6e2:	bff9                	j	6c0 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 6e4:	008b0913          	addi	s2,s6,8
 6e8:	000b4583          	lbu	a1,0(s6)
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	db2080e7          	jalr	-590(ra) # 4a0 <putc>
 6f6:	8b4a                	mv	s6,s2
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bdd1                	j	5ce <vprintf+0x60>
        putc(fd, c);
 6fc:	85d2                	mv	a1,s4
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	da0080e7          	jalr	-608(ra) # 4a0 <putc>
      state = 0;
 708:	4981                	li	s3,0
 70a:	b5d1                	j	5ce <vprintf+0x60>
        putc(fd, '%');
 70c:	85d2                	mv	a1,s4
 70e:	8556                	mv	a0,s5
 710:	00000097          	auipc	ra,0x0
 714:	d90080e7          	jalr	-624(ra) # 4a0 <putc>
        putc(fd, c);
 718:	85ca                	mv	a1,s2
 71a:	8556                	mv	a0,s5
 71c:	00000097          	auipc	ra,0x0
 720:	d84080e7          	jalr	-636(ra) # 4a0 <putc>
      state = 0;
 724:	4981                	li	s3,0
 726:	b565                	j	5ce <vprintf+0x60>
        s = va_arg(ap, char*);
 728:	8b4a                	mv	s6,s2
      state = 0;
 72a:	4981                	li	s3,0
 72c:	b54d                	j	5ce <vprintf+0x60>
    }
  }
}
 72e:	70e6                	ld	ra,120(sp)
 730:	7446                	ld	s0,112(sp)
 732:	74a6                	ld	s1,104(sp)
 734:	7906                	ld	s2,96(sp)
 736:	69e6                	ld	s3,88(sp)
 738:	6a46                	ld	s4,80(sp)
 73a:	6aa6                	ld	s5,72(sp)
 73c:	6b06                	ld	s6,64(sp)
 73e:	7be2                	ld	s7,56(sp)
 740:	7c42                	ld	s8,48(sp)
 742:	7ca2                	ld	s9,40(sp)
 744:	7d02                	ld	s10,32(sp)
 746:	6de2                	ld	s11,24(sp)
 748:	6109                	addi	sp,sp,128
 74a:	8082                	ret

000000000000074c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 74c:	715d                	addi	sp,sp,-80
 74e:	ec06                	sd	ra,24(sp)
 750:	e822                	sd	s0,16(sp)
 752:	1000                	addi	s0,sp,32
 754:	e010                	sd	a2,0(s0)
 756:	e414                	sd	a3,8(s0)
 758:	e818                	sd	a4,16(s0)
 75a:	ec1c                	sd	a5,24(s0)
 75c:	03043023          	sd	a6,32(s0)
 760:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 764:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 768:	8622                	mv	a2,s0
 76a:	00000097          	auipc	ra,0x0
 76e:	e04080e7          	jalr	-508(ra) # 56e <vprintf>
}
 772:	60e2                	ld	ra,24(sp)
 774:	6442                	ld	s0,16(sp)
 776:	6161                	addi	sp,sp,80
 778:	8082                	ret

000000000000077a <printf>:

void
printf(const char *fmt, ...)
{
 77a:	711d                	addi	sp,sp,-96
 77c:	ec06                	sd	ra,24(sp)
 77e:	e822                	sd	s0,16(sp)
 780:	1000                	addi	s0,sp,32
 782:	e40c                	sd	a1,8(s0)
 784:	e810                	sd	a2,16(s0)
 786:	ec14                	sd	a3,24(s0)
 788:	f018                	sd	a4,32(s0)
 78a:	f41c                	sd	a5,40(s0)
 78c:	03043823          	sd	a6,48(s0)
 790:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 794:	00840613          	addi	a2,s0,8
 798:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 79c:	85aa                	mv	a1,a0
 79e:	4505                	li	a0,1
 7a0:	00000097          	auipc	ra,0x0
 7a4:	dce080e7          	jalr	-562(ra) # 56e <vprintf>
}
 7a8:	60e2                	ld	ra,24(sp)
 7aa:	6442                	ld	s0,16(sp)
 7ac:	6125                	addi	sp,sp,96
 7ae:	8082                	ret

00000000000007b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7b0:	1141                	addi	sp,sp,-16
 7b2:	e422                	sd	s0,8(sp)
 7b4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ba:	00000797          	auipc	a5,0x0
 7be:	1f67b783          	ld	a5,502(a5) # 9b0 <freep>
 7c2:	a02d                	j	7ec <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c4:	4618                	lw	a4,8(a2)
 7c6:	9f2d                	addw	a4,a4,a1
 7c8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7cc:	6398                	ld	a4,0(a5)
 7ce:	6310                	ld	a2,0(a4)
 7d0:	a83d                	j	80e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7d2:	ff852703          	lw	a4,-8(a0)
 7d6:	9f31                	addw	a4,a4,a2
 7d8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7da:	ff053683          	ld	a3,-16(a0)
 7de:	a091                	j	822 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e0:	6398                	ld	a4,0(a5)
 7e2:	00e7e463          	bltu	a5,a4,7ea <free+0x3a>
 7e6:	00e6ea63          	bltu	a3,a4,7fa <free+0x4a>
{
 7ea:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ec:	fed7fae3          	bgeu	a5,a3,7e0 <free+0x30>
 7f0:	6398                	ld	a4,0(a5)
 7f2:	00e6e463          	bltu	a3,a4,7fa <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f6:	fee7eae3          	bltu	a5,a4,7ea <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7fa:	ff852583          	lw	a1,-8(a0)
 7fe:	6390                	ld	a2,0(a5)
 800:	02059813          	slli	a6,a1,0x20
 804:	01c85713          	srli	a4,a6,0x1c
 808:	9736                	add	a4,a4,a3
 80a:	fae60de3          	beq	a2,a4,7c4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 80e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 812:	4790                	lw	a2,8(a5)
 814:	02061593          	slli	a1,a2,0x20
 818:	01c5d713          	srli	a4,a1,0x1c
 81c:	973e                	add	a4,a4,a5
 81e:	fae68ae3          	beq	a3,a4,7d2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 822:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 824:	00000717          	auipc	a4,0x0
 828:	18f73623          	sd	a5,396(a4) # 9b0 <freep>
}
 82c:	6422                	ld	s0,8(sp)
 82e:	0141                	addi	sp,sp,16
 830:	8082                	ret

0000000000000832 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 832:	7139                	addi	sp,sp,-64
 834:	fc06                	sd	ra,56(sp)
 836:	f822                	sd	s0,48(sp)
 838:	f426                	sd	s1,40(sp)
 83a:	f04a                	sd	s2,32(sp)
 83c:	ec4e                	sd	s3,24(sp)
 83e:	e852                	sd	s4,16(sp)
 840:	e456                	sd	s5,8(sp)
 842:	e05a                	sd	s6,0(sp)
 844:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 846:	02051493          	slli	s1,a0,0x20
 84a:	9081                	srli	s1,s1,0x20
 84c:	04bd                	addi	s1,s1,15
 84e:	8091                	srli	s1,s1,0x4
 850:	0014899b          	addiw	s3,s1,1
 854:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 856:	00000517          	auipc	a0,0x0
 85a:	15a53503          	ld	a0,346(a0) # 9b0 <freep>
 85e:	c515                	beqz	a0,88a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 860:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 862:	4798                	lw	a4,8(a5)
 864:	02977f63          	bgeu	a4,s1,8a2 <malloc+0x70>
 868:	8a4e                	mv	s4,s3
 86a:	0009871b          	sext.w	a4,s3
 86e:	6685                	lui	a3,0x1
 870:	00d77363          	bgeu	a4,a3,876 <malloc+0x44>
 874:	6a05                	lui	s4,0x1
 876:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 87a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 87e:	00000917          	auipc	s2,0x0
 882:	13290913          	addi	s2,s2,306 # 9b0 <freep>
  if(p == (char*)-1)
 886:	5afd                	li	s5,-1
 888:	a895                	j	8fc <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 88a:	00000797          	auipc	a5,0x0
 88e:	12e78793          	addi	a5,a5,302 # 9b8 <base>
 892:	00000717          	auipc	a4,0x0
 896:	10f73f23          	sd	a5,286(a4) # 9b0 <freep>
 89a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 89c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a0:	b7e1                	j	868 <malloc+0x36>
      if(p->s.size == nunits)
 8a2:	02e48c63          	beq	s1,a4,8da <malloc+0xa8>
        p->s.size -= nunits;
 8a6:	4137073b          	subw	a4,a4,s3
 8aa:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ac:	02071693          	slli	a3,a4,0x20
 8b0:	01c6d713          	srli	a4,a3,0x1c
 8b4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8ba:	00000717          	auipc	a4,0x0
 8be:	0ea73b23          	sd	a0,246(a4) # 9b0 <freep>
      return (void*)(p + 1);
 8c2:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8c6:	70e2                	ld	ra,56(sp)
 8c8:	7442                	ld	s0,48(sp)
 8ca:	74a2                	ld	s1,40(sp)
 8cc:	7902                	ld	s2,32(sp)
 8ce:	69e2                	ld	s3,24(sp)
 8d0:	6a42                	ld	s4,16(sp)
 8d2:	6aa2                	ld	s5,8(sp)
 8d4:	6b02                	ld	s6,0(sp)
 8d6:	6121                	addi	sp,sp,64
 8d8:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8da:	6398                	ld	a4,0(a5)
 8dc:	e118                	sd	a4,0(a0)
 8de:	bff1                	j	8ba <malloc+0x88>
  hp->s.size = nu;
 8e0:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8e4:	0541                	addi	a0,a0,16
 8e6:	00000097          	auipc	ra,0x0
 8ea:	eca080e7          	jalr	-310(ra) # 7b0 <free>
  return freep;
 8ee:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8f2:	d971                	beqz	a0,8c6 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f6:	4798                	lw	a4,8(a5)
 8f8:	fa9775e3          	bgeu	a4,s1,8a2 <malloc+0x70>
    if(p == freep)
 8fc:	00093703          	ld	a4,0(s2)
 900:	853e                	mv	a0,a5
 902:	fef719e3          	bne	a4,a5,8f4 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 906:	8552                	mv	a0,s4
 908:	00000097          	auipc	ra,0x0
 90c:	b80080e7          	jalr	-1152(ra) # 488 <sbrk>
  if(p == (char*)-1)
 910:	fd5518e3          	bne	a0,s5,8e0 <malloc+0xae>
        return 0;
 914:	4501                	li	a0,0
 916:	bf45                	j	8c6 <malloc+0x94>
