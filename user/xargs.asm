
user/_xargs：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <readline>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"

int readline(char *new_argv[], int pos){
   0:	da010113          	addi	sp,sp,-608
   4:	24113c23          	sd	ra,600(sp)
   8:	24813823          	sd	s0,592(sp)
   c:	24913423          	sd	s1,584(sp)
  10:	25213023          	sd	s2,576(sp)
  14:	23313c23          	sd	s3,568(sp)
  18:	23413823          	sd	s4,560(sp)
  1c:	23513423          	sd	s5,552(sp)
  20:	23613023          	sd	s6,544(sp)
  24:	21713c23          	sd	s7,536(sp)
  28:	21813823          	sd	s8,528(sp)
  2c:	21913423          	sd	s9,520(sp)
  30:	21a13023          	sd	s10,512(sp)
  34:	1480                	addi	s0,sp,608
  36:	8caa                	mv	s9,a0
  38:	8c2e                	mv	s8,a1
  char buf[512];
  int i = 0;
  int flag = 1;
  while(read(0, buf+i, 1)){
  3a:	00359d13          	slli	s10,a1,0x3
  3e:	9d2a                	add	s10,s10,a0
  int flag = 1;
  40:	4a85                	li	s5,1
    flag = 0;
  42:	4981                	li	s3,0
    i++;
    if(buf[i-1] == '\n'){
  44:	4b29                	li	s6,10
      buf[i-1] = 0;
      new_argv[pos++] = malloc(i-1);
      strcpy(new_argv[pos-1], buf);
      i = 0;
      break;
    }else if(buf[i-1] == ' '){
  46:	02000b93          	li	s7,32
  4a:	da040913          	addi	s2,s0,-608
    flag = 0;
  4e:	8a4e                	mv	s4,s3
  while(read(0, buf+i, 1)){
  50:	4605                	li	a2,1
  52:	85ca                	mv	a1,s2
  54:	854e                	mv	a0,s3
  56:	00000097          	auipc	ra,0x0
  5a:	432080e7          	jalr	1074(ra) # 488 <read>
  5e:	84aa                	mv	s1,a0
  60:	c545                	beqz	a0,108 <readline+0x108>
    i++;
  62:	001a071b          	addiw	a4,s4,1
    if(buf[i-1] == '\n'){
  66:	00094783          	lbu	a5,0(s2)
  6a:	01678863          	beq	a5,s6,7a <readline+0x7a>
    }else if(buf[i-1] == ' '){
  6e:	0905                	addi	s2,s2,1
    flag = 0;
  70:	8ace                	mv	s5,s3
    }else if(buf[i-1] == ' '){
  72:	07778663          	beq	a5,s7,de <readline+0xde>
    i++;
  76:	8a3a                	mv	s4,a4
  78:	bfe1                	j	50 <readline+0x50>
      buf[i-1] = 0;
  7a:	fa0a0793          	addi	a5,s4,-96
  7e:	97a2                	add	a5,a5,s0
  80:	e0078023          	sb	zero,-512(a5)
      new_argv[pos++] = malloc(i-1);
  84:	001c049b          	addiw	s1,s8,1
  88:	0c0e                	slli	s8,s8,0x3
  8a:	9ce2                	add	s9,s9,s8
  8c:	8552                	mv	a0,s4
  8e:	00001097          	auipc	ra,0x1
  92:	814080e7          	jalr	-2028(ra) # 8a2 <malloc>
  96:	00acb023          	sd	a0,0(s9)
      strcpy(new_argv[pos-1], buf);
  9a:	da040593          	addi	a1,s0,-608
  9e:	00000097          	auipc	ra,0x0
  a2:	166080e7          	jalr	358(ra) # 204 <strcpy>
      i = 0;
    }
  }
  if(flag){return 0;}
  return pos;
}
  a6:	8526                	mv	a0,s1
  a8:	25813083          	ld	ra,600(sp)
  ac:	25013403          	ld	s0,592(sp)
  b0:	24813483          	ld	s1,584(sp)
  b4:	24013903          	ld	s2,576(sp)
  b8:	23813983          	ld	s3,568(sp)
  bc:	23013a03          	ld	s4,560(sp)
  c0:	22813a83          	ld	s5,552(sp)
  c4:	22013b03          	ld	s6,544(sp)
  c8:	21813b83          	ld	s7,536(sp)
  cc:	21013c03          	ld	s8,528(sp)
  d0:	20813c83          	ld	s9,520(sp)
  d4:	20013d03          	ld	s10,512(sp)
  d8:	26010113          	addi	sp,sp,608
  dc:	8082                	ret
      buf[i-1] = 0;
  de:	fa0a0793          	addi	a5,s4,-96
  e2:	97a2                	add	a5,a5,s0
  e4:	e0078023          	sb	zero,-512(a5)
      new_argv[pos++] = malloc(i-1);
  e8:	2c05                	addiw	s8,s8,1
  ea:	8552                	mv	a0,s4
  ec:	00000097          	auipc	ra,0x0
  f0:	7b6080e7          	jalr	1974(ra) # 8a2 <malloc>
  f4:	00ad3023          	sd	a0,0(s10)
      strcpy(new_argv[pos-1], buf);
  f8:	da040593          	addi	a1,s0,-608
  fc:	00000097          	auipc	ra,0x0
 100:	108080e7          	jalr	264(ra) # 204 <strcpy>
      i = 0;
 104:	0d21                	addi	s10,s10,8
 106:	b791                	j	4a <readline+0x4a>
  if(flag){return 0;}
 108:	f80a9fe3          	bnez	s5,a6 <readline+0xa6>
 10c:	84e2                	mv	s1,s8
 10e:	bf61                	j	a6 <readline+0xa6>

0000000000000110 <main>:

int main(int argc, char *argv[]){
 110:	7169                	addi	sp,sp,-304
 112:	f606                	sd	ra,296(sp)
 114:	f222                	sd	s0,288(sp)
 116:	ee26                	sd	s1,280(sp)
 118:	ea4a                	sd	s2,272(sp)
 11a:	e64e                	sd	s3,264(sp)
 11c:	e252                	sd	s4,256(sp)
 11e:	1a00                	addi	s0,sp,304
  char *new_argv[MAXARG];
  char *commod;
  commod = argv[1];
 120:	0085b903          	ld	s2,8(a1)
  for(int i = 1;i < argc; ++i){
 124:	4785                	li	a5,1
 126:	02a7d563          	bge	a5,a0,150 <main+0x40>
 12a:	00858713          	addi	a4,a1,8
 12e:	ed040793          	addi	a5,s0,-304
 132:	ffe5061b          	addiw	a2,a0,-2
 136:	02061693          	slli	a3,a2,0x20
 13a:	01d6d613          	srli	a2,a3,0x1d
 13e:	ed840693          	addi	a3,s0,-296
 142:	9636                	add	a2,a2,a3
    new_argv[i-1] = argv[i];
 144:	6314                	ld	a3,0(a4)
 146:	e394                	sd	a3,0(a5)
  for(int i = 1;i < argc; ++i){
 148:	0721                	addi	a4,a4,8
 14a:	07a1                	addi	a5,a5,8
 14c:	fec79ce3          	bne	a5,a2,144 <main+0x34>
  }
  int pos;
  while((pos = readline(new_argv, argc-1)) != 0){
 150:	fff5099b          	addiw	s3,a0,-1
 154:	a031                	j	160 <main+0x50>
      }
      exec(commod, new_argv);
      fprintf(2, "Exec Failed!\n");
      exit(1);
    }
    wait(0);
 156:	4501                	li	a0,0
 158:	00000097          	auipc	ra,0x0
 15c:	320080e7          	jalr	800(ra) # 478 <wait>
  while((pos = readline(new_argv, argc-1)) != 0){
 160:	85ce                	mv	a1,s3
 162:	ed040513          	addi	a0,s0,-304
 166:	00000097          	auipc	ra,0x0
 16a:	e9a080e7          	jalr	-358(ra) # 0 <readline>
 16e:	84aa                	mv	s1,a0
 170:	c549                	beqz	a0,1fa <main+0xea>
    new_argv[pos] = 0;
 172:	00349793          	slli	a5,s1,0x3
 176:	fd078793          	addi	a5,a5,-48
 17a:	97a2                	add	a5,a5,s0
 17c:	f007b023          	sd	zero,-256(a5)
    if(fork() == 0){
 180:	00000097          	auipc	ra,0x0
 184:	2e8080e7          	jalr	744(ra) # 468 <fork>
 188:	f579                	bnez	a0,156 <main+0x46>
      printf("%s\n", commod);
 18a:	85ca                	mv	a1,s2
 18c:	00000517          	auipc	a0,0x0
 190:	7fc50513          	addi	a0,a0,2044 # 988 <malloc+0xe6>
 194:	00000097          	auipc	ra,0x0
 198:	656080e7          	jalr	1622(ra) # 7ea <printf>
      for(int i = 0;i < pos;++i){
 19c:	02905a63          	blez	s1,1d0 <main+0xc0>
 1a0:	ed040993          	addi	s3,s0,-304
 1a4:	34fd                	addiw	s1,s1,-1
 1a6:	02049793          	slli	a5,s1,0x20
 1aa:	01d7d493          	srli	s1,a5,0x1d
 1ae:	ed840793          	addi	a5,s0,-296
 1b2:	94be                	add	s1,s1,a5
        printf("%s ", new_argv[i]);
 1b4:	00000a17          	auipc	s4,0x0
 1b8:	7dca0a13          	addi	s4,s4,2012 # 990 <malloc+0xee>
 1bc:	0009b583          	ld	a1,0(s3)
 1c0:	8552                	mv	a0,s4
 1c2:	00000097          	auipc	ra,0x0
 1c6:	628080e7          	jalr	1576(ra) # 7ea <printf>
      for(int i = 0;i < pos;++i){
 1ca:	09a1                	addi	s3,s3,8
 1cc:	fe9998e3          	bne	s3,s1,1bc <main+0xac>
      exec(commod, new_argv);
 1d0:	ed040593          	addi	a1,s0,-304
 1d4:	854a                	mv	a0,s2
 1d6:	00000097          	auipc	ra,0x0
 1da:	2d2080e7          	jalr	722(ra) # 4a8 <exec>
      fprintf(2, "Exec Failed!\n");
 1de:	00000597          	auipc	a1,0x0
 1e2:	7ba58593          	addi	a1,a1,1978 # 998 <malloc+0xf6>
 1e6:	4509                	li	a0,2
 1e8:	00000097          	auipc	ra,0x0
 1ec:	5d4080e7          	jalr	1492(ra) # 7bc <fprintf>
      exit(1);
 1f0:	4505                	li	a0,1
 1f2:	00000097          	auipc	ra,0x0
 1f6:	27e080e7          	jalr	638(ra) # 470 <exit>
  }

  exit(0);
 1fa:	4501                	li	a0,0
 1fc:	00000097          	auipc	ra,0x0
 200:	274080e7          	jalr	628(ra) # 470 <exit>

0000000000000204 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 20a:	87aa                	mv	a5,a0
 20c:	0585                	addi	a1,a1,1
 20e:	0785                	addi	a5,a5,1
 210:	fff5c703          	lbu	a4,-1(a1)
 214:	fee78fa3          	sb	a4,-1(a5)
 218:	fb75                	bnez	a4,20c <strcpy+0x8>
    ;
  return os;
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret

0000000000000220 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 220:	1141                	addi	sp,sp,-16
 222:	e422                	sd	s0,8(sp)
 224:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 226:	00054783          	lbu	a5,0(a0)
 22a:	cb91                	beqz	a5,23e <strcmp+0x1e>
 22c:	0005c703          	lbu	a4,0(a1)
 230:	00f71763          	bne	a4,a5,23e <strcmp+0x1e>
    p++, q++;
 234:	0505                	addi	a0,a0,1
 236:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 238:	00054783          	lbu	a5,0(a0)
 23c:	fbe5                	bnez	a5,22c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 23e:	0005c503          	lbu	a0,0(a1)
}
 242:	40a7853b          	subw	a0,a5,a0
 246:	6422                	ld	s0,8(sp)
 248:	0141                	addi	sp,sp,16
 24a:	8082                	ret

000000000000024c <strlen>:

uint
strlen(const char *s)
{
 24c:	1141                	addi	sp,sp,-16
 24e:	e422                	sd	s0,8(sp)
 250:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 252:	00054783          	lbu	a5,0(a0)
 256:	cf91                	beqz	a5,272 <strlen+0x26>
 258:	0505                	addi	a0,a0,1
 25a:	87aa                	mv	a5,a0
 25c:	4685                	li	a3,1
 25e:	9e89                	subw	a3,a3,a0
 260:	00f6853b          	addw	a0,a3,a5
 264:	0785                	addi	a5,a5,1
 266:	fff7c703          	lbu	a4,-1(a5)
 26a:	fb7d                	bnez	a4,260 <strlen+0x14>
    ;
  return n;
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
  for(n = 0; s[n]; n++)
 272:	4501                	li	a0,0
 274:	bfe5                	j	26c <strlen+0x20>

0000000000000276 <memset>:

void*
memset(void *dst, int c, uint n)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 27c:	ca19                	beqz	a2,292 <memset+0x1c>
 27e:	87aa                	mv	a5,a0
 280:	1602                	slli	a2,a2,0x20
 282:	9201                	srli	a2,a2,0x20
 284:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 288:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 28c:	0785                	addi	a5,a5,1
 28e:	fee79de3          	bne	a5,a4,288 <memset+0x12>
  }
  return dst;
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret

0000000000000298 <strchr>:

char*
strchr(const char *s, char c)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	cb99                	beqz	a5,2b8 <strchr+0x20>
    if(*s == c)
 2a4:	00f58763          	beq	a1,a5,2b2 <strchr+0x1a>
  for(; *s; s++)
 2a8:	0505                	addi	a0,a0,1
 2aa:	00054783          	lbu	a5,0(a0)
 2ae:	fbfd                	bnez	a5,2a4 <strchr+0xc>
      return (char*)s;
  return 0;
 2b0:	4501                	li	a0,0
}
 2b2:	6422                	ld	s0,8(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret
  return 0;
 2b8:	4501                	li	a0,0
 2ba:	bfe5                	j	2b2 <strchr+0x1a>

00000000000002bc <gets>:

char*
gets(char *buf, int max)
{
 2bc:	711d                	addi	sp,sp,-96
 2be:	ec86                	sd	ra,88(sp)
 2c0:	e8a2                	sd	s0,80(sp)
 2c2:	e4a6                	sd	s1,72(sp)
 2c4:	e0ca                	sd	s2,64(sp)
 2c6:	fc4e                	sd	s3,56(sp)
 2c8:	f852                	sd	s4,48(sp)
 2ca:	f456                	sd	s5,40(sp)
 2cc:	f05a                	sd	s6,32(sp)
 2ce:	ec5e                	sd	s7,24(sp)
 2d0:	1080                	addi	s0,sp,96
 2d2:	8baa                	mv	s7,a0
 2d4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d6:	892a                	mv	s2,a0
 2d8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2da:	4aa9                	li	s5,10
 2dc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2de:	89a6                	mv	s3,s1
 2e0:	2485                	addiw	s1,s1,1
 2e2:	0344d863          	bge	s1,s4,312 <gets+0x56>
    cc = read(0, &c, 1);
 2e6:	4605                	li	a2,1
 2e8:	faf40593          	addi	a1,s0,-81
 2ec:	4501                	li	a0,0
 2ee:	00000097          	auipc	ra,0x0
 2f2:	19a080e7          	jalr	410(ra) # 488 <read>
    if(cc < 1)
 2f6:	00a05e63          	blez	a0,312 <gets+0x56>
    buf[i++] = c;
 2fa:	faf44783          	lbu	a5,-81(s0)
 2fe:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 302:	01578763          	beq	a5,s5,310 <gets+0x54>
 306:	0905                	addi	s2,s2,1
 308:	fd679be3          	bne	a5,s6,2de <gets+0x22>
  for(i=0; i+1 < max; ){
 30c:	89a6                	mv	s3,s1
 30e:	a011                	j	312 <gets+0x56>
 310:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 312:	99de                	add	s3,s3,s7
 314:	00098023          	sb	zero,0(s3)
  return buf;
}
 318:	855e                	mv	a0,s7
 31a:	60e6                	ld	ra,88(sp)
 31c:	6446                	ld	s0,80(sp)
 31e:	64a6                	ld	s1,72(sp)
 320:	6906                	ld	s2,64(sp)
 322:	79e2                	ld	s3,56(sp)
 324:	7a42                	ld	s4,48(sp)
 326:	7aa2                	ld	s5,40(sp)
 328:	7b02                	ld	s6,32(sp)
 32a:	6be2                	ld	s7,24(sp)
 32c:	6125                	addi	sp,sp,96
 32e:	8082                	ret

0000000000000330 <stat>:

int
stat(const char *n, struct stat *st)
{
 330:	1101                	addi	sp,sp,-32
 332:	ec06                	sd	ra,24(sp)
 334:	e822                	sd	s0,16(sp)
 336:	e426                	sd	s1,8(sp)
 338:	e04a                	sd	s2,0(sp)
 33a:	1000                	addi	s0,sp,32
 33c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 33e:	4581                	li	a1,0
 340:	00000097          	auipc	ra,0x0
 344:	170080e7          	jalr	368(ra) # 4b0 <open>
  if(fd < 0)
 348:	02054563          	bltz	a0,372 <stat+0x42>
 34c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 34e:	85ca                	mv	a1,s2
 350:	00000097          	auipc	ra,0x0
 354:	178080e7          	jalr	376(ra) # 4c8 <fstat>
 358:	892a                	mv	s2,a0
  close(fd);
 35a:	8526                	mv	a0,s1
 35c:	00000097          	auipc	ra,0x0
 360:	13c080e7          	jalr	316(ra) # 498 <close>
  return r;
}
 364:	854a                	mv	a0,s2
 366:	60e2                	ld	ra,24(sp)
 368:	6442                	ld	s0,16(sp)
 36a:	64a2                	ld	s1,8(sp)
 36c:	6902                	ld	s2,0(sp)
 36e:	6105                	addi	sp,sp,32
 370:	8082                	ret
    return -1;
 372:	597d                	li	s2,-1
 374:	bfc5                	j	364 <stat+0x34>

0000000000000376 <atoi>:

int
atoi(const char *s)
{
 376:	1141                	addi	sp,sp,-16
 378:	e422                	sd	s0,8(sp)
 37a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 37c:	00054683          	lbu	a3,0(a0)
 380:	fd06879b          	addiw	a5,a3,-48
 384:	0ff7f793          	zext.b	a5,a5
 388:	4625                	li	a2,9
 38a:	02f66863          	bltu	a2,a5,3ba <atoi+0x44>
 38e:	872a                	mv	a4,a0
  n = 0;
 390:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 392:	0705                	addi	a4,a4,1
 394:	0025179b          	slliw	a5,a0,0x2
 398:	9fa9                	addw	a5,a5,a0
 39a:	0017979b          	slliw	a5,a5,0x1
 39e:	9fb5                	addw	a5,a5,a3
 3a0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3a4:	00074683          	lbu	a3,0(a4)
 3a8:	fd06879b          	addiw	a5,a3,-48
 3ac:	0ff7f793          	zext.b	a5,a5
 3b0:	fef671e3          	bgeu	a2,a5,392 <atoi+0x1c>
  return n;
}
 3b4:	6422                	ld	s0,8(sp)
 3b6:	0141                	addi	sp,sp,16
 3b8:	8082                	ret
  n = 0;
 3ba:	4501                	li	a0,0
 3bc:	bfe5                	j	3b4 <atoi+0x3e>

00000000000003be <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3be:	1141                	addi	sp,sp,-16
 3c0:	e422                	sd	s0,8(sp)
 3c2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3c4:	02b57463          	bgeu	a0,a1,3ec <memmove+0x2e>
    while(n-- > 0)
 3c8:	00c05f63          	blez	a2,3e6 <memmove+0x28>
 3cc:	1602                	slli	a2,a2,0x20
 3ce:	9201                	srli	a2,a2,0x20
 3d0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3d4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3d6:	0585                	addi	a1,a1,1
 3d8:	0705                	addi	a4,a4,1
 3da:	fff5c683          	lbu	a3,-1(a1)
 3de:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3e2:	fee79ae3          	bne	a5,a4,3d6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3e6:	6422                	ld	s0,8(sp)
 3e8:	0141                	addi	sp,sp,16
 3ea:	8082                	ret
    dst += n;
 3ec:	00c50733          	add	a4,a0,a2
    src += n;
 3f0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3f2:	fec05ae3          	blez	a2,3e6 <memmove+0x28>
 3f6:	fff6079b          	addiw	a5,a2,-1
 3fa:	1782                	slli	a5,a5,0x20
 3fc:	9381                	srli	a5,a5,0x20
 3fe:	fff7c793          	not	a5,a5
 402:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 404:	15fd                	addi	a1,a1,-1
 406:	177d                	addi	a4,a4,-1
 408:	0005c683          	lbu	a3,0(a1)
 40c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 410:	fee79ae3          	bne	a5,a4,404 <memmove+0x46>
 414:	bfc9                	j	3e6 <memmove+0x28>

0000000000000416 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 416:	1141                	addi	sp,sp,-16
 418:	e422                	sd	s0,8(sp)
 41a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 41c:	ca05                	beqz	a2,44c <memcmp+0x36>
 41e:	fff6069b          	addiw	a3,a2,-1
 422:	1682                	slli	a3,a3,0x20
 424:	9281                	srli	a3,a3,0x20
 426:	0685                	addi	a3,a3,1
 428:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 42a:	00054783          	lbu	a5,0(a0)
 42e:	0005c703          	lbu	a4,0(a1)
 432:	00e79863          	bne	a5,a4,442 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 436:	0505                	addi	a0,a0,1
    p2++;
 438:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 43a:	fed518e3          	bne	a0,a3,42a <memcmp+0x14>
  }
  return 0;
 43e:	4501                	li	a0,0
 440:	a019                	j	446 <memcmp+0x30>
      return *p1 - *p2;
 442:	40e7853b          	subw	a0,a5,a4
}
 446:	6422                	ld	s0,8(sp)
 448:	0141                	addi	sp,sp,16
 44a:	8082                	ret
  return 0;
 44c:	4501                	li	a0,0
 44e:	bfe5                	j	446 <memcmp+0x30>

0000000000000450 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 450:	1141                	addi	sp,sp,-16
 452:	e406                	sd	ra,8(sp)
 454:	e022                	sd	s0,0(sp)
 456:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 458:	00000097          	auipc	ra,0x0
 45c:	f66080e7          	jalr	-154(ra) # 3be <memmove>
}
 460:	60a2                	ld	ra,8(sp)
 462:	6402                	ld	s0,0(sp)
 464:	0141                	addi	sp,sp,16
 466:	8082                	ret

0000000000000468 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 468:	4885                	li	a7,1
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <exit>:
.global exit
exit:
 li a7, SYS_exit
 470:	4889                	li	a7,2
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <wait>:
.global wait
wait:
 li a7, SYS_wait
 478:	488d                	li	a7,3
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 480:	4891                	li	a7,4
 ecall
 482:	00000073          	ecall
 ret
 486:	8082                	ret

0000000000000488 <read>:
.global read
read:
 li a7, SYS_read
 488:	4895                	li	a7,5
 ecall
 48a:	00000073          	ecall
 ret
 48e:	8082                	ret

0000000000000490 <write>:
.global write
write:
 li a7, SYS_write
 490:	48c1                	li	a7,16
 ecall
 492:	00000073          	ecall
 ret
 496:	8082                	ret

0000000000000498 <close>:
.global close
close:
 li a7, SYS_close
 498:	48d5                	li	a7,21
 ecall
 49a:	00000073          	ecall
 ret
 49e:	8082                	ret

00000000000004a0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4a0:	4899                	li	a7,6
 ecall
 4a2:	00000073          	ecall
 ret
 4a6:	8082                	ret

00000000000004a8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4a8:	489d                	li	a7,7
 ecall
 4aa:	00000073          	ecall
 ret
 4ae:	8082                	ret

00000000000004b0 <open>:
.global open
open:
 li a7, SYS_open
 4b0:	48bd                	li	a7,15
 ecall
 4b2:	00000073          	ecall
 ret
 4b6:	8082                	ret

00000000000004b8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4b8:	48c5                	li	a7,17
 ecall
 4ba:	00000073          	ecall
 ret
 4be:	8082                	ret

00000000000004c0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4c0:	48c9                	li	a7,18
 ecall
 4c2:	00000073          	ecall
 ret
 4c6:	8082                	ret

00000000000004c8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4c8:	48a1                	li	a7,8
 ecall
 4ca:	00000073          	ecall
 ret
 4ce:	8082                	ret

00000000000004d0 <link>:
.global link
link:
 li a7, SYS_link
 4d0:	48cd                	li	a7,19
 ecall
 4d2:	00000073          	ecall
 ret
 4d6:	8082                	ret

00000000000004d8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4d8:	48d1                	li	a7,20
 ecall
 4da:	00000073          	ecall
 ret
 4de:	8082                	ret

00000000000004e0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4e0:	48a5                	li	a7,9
 ecall
 4e2:	00000073          	ecall
 ret
 4e6:	8082                	ret

00000000000004e8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4e8:	48a9                	li	a7,10
 ecall
 4ea:	00000073          	ecall
 ret
 4ee:	8082                	ret

00000000000004f0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4f0:	48ad                	li	a7,11
 ecall
 4f2:	00000073          	ecall
 ret
 4f6:	8082                	ret

00000000000004f8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4f8:	48b1                	li	a7,12
 ecall
 4fa:	00000073          	ecall
 ret
 4fe:	8082                	ret

0000000000000500 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 500:	48b5                	li	a7,13
 ecall
 502:	00000073          	ecall
 ret
 506:	8082                	ret

0000000000000508 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 508:	48b9                	li	a7,14
 ecall
 50a:	00000073          	ecall
 ret
 50e:	8082                	ret

0000000000000510 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 510:	1101                	addi	sp,sp,-32
 512:	ec06                	sd	ra,24(sp)
 514:	e822                	sd	s0,16(sp)
 516:	1000                	addi	s0,sp,32
 518:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 51c:	4605                	li	a2,1
 51e:	fef40593          	addi	a1,s0,-17
 522:	00000097          	auipc	ra,0x0
 526:	f6e080e7          	jalr	-146(ra) # 490 <write>
}
 52a:	60e2                	ld	ra,24(sp)
 52c:	6442                	ld	s0,16(sp)
 52e:	6105                	addi	sp,sp,32
 530:	8082                	ret

0000000000000532 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 532:	7139                	addi	sp,sp,-64
 534:	fc06                	sd	ra,56(sp)
 536:	f822                	sd	s0,48(sp)
 538:	f426                	sd	s1,40(sp)
 53a:	f04a                	sd	s2,32(sp)
 53c:	ec4e                	sd	s3,24(sp)
 53e:	0080                	addi	s0,sp,64
 540:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 542:	c299                	beqz	a3,548 <printint+0x16>
 544:	0805c963          	bltz	a1,5d6 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 548:	2581                	sext.w	a1,a1
  neg = 0;
 54a:	4881                	li	a7,0
 54c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 550:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 552:	2601                	sext.w	a2,a2
 554:	00000517          	auipc	a0,0x0
 558:	4b450513          	addi	a0,a0,1204 # a08 <digits>
 55c:	883a                	mv	a6,a4
 55e:	2705                	addiw	a4,a4,1
 560:	02c5f7bb          	remuw	a5,a1,a2
 564:	1782                	slli	a5,a5,0x20
 566:	9381                	srli	a5,a5,0x20
 568:	97aa                	add	a5,a5,a0
 56a:	0007c783          	lbu	a5,0(a5)
 56e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 572:	0005879b          	sext.w	a5,a1
 576:	02c5d5bb          	divuw	a1,a1,a2
 57a:	0685                	addi	a3,a3,1
 57c:	fec7f0e3          	bgeu	a5,a2,55c <printint+0x2a>
  if(neg)
 580:	00088c63          	beqz	a7,598 <printint+0x66>
    buf[i++] = '-';
 584:	fd070793          	addi	a5,a4,-48
 588:	00878733          	add	a4,a5,s0
 58c:	02d00793          	li	a5,45
 590:	fef70823          	sb	a5,-16(a4)
 594:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 598:	02e05863          	blez	a4,5c8 <printint+0x96>
 59c:	fc040793          	addi	a5,s0,-64
 5a0:	00e78933          	add	s2,a5,a4
 5a4:	fff78993          	addi	s3,a5,-1
 5a8:	99ba                	add	s3,s3,a4
 5aa:	377d                	addiw	a4,a4,-1
 5ac:	1702                	slli	a4,a4,0x20
 5ae:	9301                	srli	a4,a4,0x20
 5b0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5b4:	fff94583          	lbu	a1,-1(s2)
 5b8:	8526                	mv	a0,s1
 5ba:	00000097          	auipc	ra,0x0
 5be:	f56080e7          	jalr	-170(ra) # 510 <putc>
  while(--i >= 0)
 5c2:	197d                	addi	s2,s2,-1
 5c4:	ff3918e3          	bne	s2,s3,5b4 <printint+0x82>
}
 5c8:	70e2                	ld	ra,56(sp)
 5ca:	7442                	ld	s0,48(sp)
 5cc:	74a2                	ld	s1,40(sp)
 5ce:	7902                	ld	s2,32(sp)
 5d0:	69e2                	ld	s3,24(sp)
 5d2:	6121                	addi	sp,sp,64
 5d4:	8082                	ret
    x = -xx;
 5d6:	40b005bb          	negw	a1,a1
    neg = 1;
 5da:	4885                	li	a7,1
    x = -xx;
 5dc:	bf85                	j	54c <printint+0x1a>

00000000000005de <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5de:	7119                	addi	sp,sp,-128
 5e0:	fc86                	sd	ra,120(sp)
 5e2:	f8a2                	sd	s0,112(sp)
 5e4:	f4a6                	sd	s1,104(sp)
 5e6:	f0ca                	sd	s2,96(sp)
 5e8:	ecce                	sd	s3,88(sp)
 5ea:	e8d2                	sd	s4,80(sp)
 5ec:	e4d6                	sd	s5,72(sp)
 5ee:	e0da                	sd	s6,64(sp)
 5f0:	fc5e                	sd	s7,56(sp)
 5f2:	f862                	sd	s8,48(sp)
 5f4:	f466                	sd	s9,40(sp)
 5f6:	f06a                	sd	s10,32(sp)
 5f8:	ec6e                	sd	s11,24(sp)
 5fa:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5fc:	0005c903          	lbu	s2,0(a1)
 600:	18090f63          	beqz	s2,79e <vprintf+0x1c0>
 604:	8aaa                	mv	s5,a0
 606:	8b32                	mv	s6,a2
 608:	00158493          	addi	s1,a1,1
  state = 0;
 60c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 60e:	02500a13          	li	s4,37
 612:	4c55                	li	s8,21
 614:	00000c97          	auipc	s9,0x0
 618:	39cc8c93          	addi	s9,s9,924 # 9b0 <malloc+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 61c:	02800d93          	li	s11,40
  putc(fd, 'x');
 620:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 622:	00000b97          	auipc	s7,0x0
 626:	3e6b8b93          	addi	s7,s7,998 # a08 <digits>
 62a:	a839                	j	648 <vprintf+0x6a>
        putc(fd, c);
 62c:	85ca                	mv	a1,s2
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	ee0080e7          	jalr	-288(ra) # 510 <putc>
 638:	a019                	j	63e <vprintf+0x60>
    } else if(state == '%'){
 63a:	01498d63          	beq	s3,s4,654 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 63e:	0485                	addi	s1,s1,1
 640:	fff4c903          	lbu	s2,-1(s1)
 644:	14090d63          	beqz	s2,79e <vprintf+0x1c0>
    if(state == 0){
 648:	fe0999e3          	bnez	s3,63a <vprintf+0x5c>
      if(c == '%'){
 64c:	ff4910e3          	bne	s2,s4,62c <vprintf+0x4e>
        state = '%';
 650:	89d2                	mv	s3,s4
 652:	b7f5                	j	63e <vprintf+0x60>
      if(c == 'd'){
 654:	11490c63          	beq	s2,s4,76c <vprintf+0x18e>
 658:	f9d9079b          	addiw	a5,s2,-99
 65c:	0ff7f793          	zext.b	a5,a5
 660:	10fc6e63          	bltu	s8,a5,77c <vprintf+0x19e>
 664:	f9d9079b          	addiw	a5,s2,-99
 668:	0ff7f713          	zext.b	a4,a5
 66c:	10ec6863          	bltu	s8,a4,77c <vprintf+0x19e>
 670:	00271793          	slli	a5,a4,0x2
 674:	97e6                	add	a5,a5,s9
 676:	439c                	lw	a5,0(a5)
 678:	97e6                	add	a5,a5,s9
 67a:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 67c:	008b0913          	addi	s2,s6,8
 680:	4685                	li	a3,1
 682:	4629                	li	a2,10
 684:	000b2583          	lw	a1,0(s6)
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	ea8080e7          	jalr	-344(ra) # 532 <printint>
 692:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 694:	4981                	li	s3,0
 696:	b765                	j	63e <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 698:	008b0913          	addi	s2,s6,8
 69c:	4681                	li	a3,0
 69e:	4629                	li	a2,10
 6a0:	000b2583          	lw	a1,0(s6)
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e8c080e7          	jalr	-372(ra) # 532 <printint>
 6ae:	8b4a                	mv	s6,s2
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	b771                	j	63e <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6b4:	008b0913          	addi	s2,s6,8
 6b8:	4681                	li	a3,0
 6ba:	866a                	mv	a2,s10
 6bc:	000b2583          	lw	a1,0(s6)
 6c0:	8556                	mv	a0,s5
 6c2:	00000097          	auipc	ra,0x0
 6c6:	e70080e7          	jalr	-400(ra) # 532 <printint>
 6ca:	8b4a                	mv	s6,s2
      state = 0;
 6cc:	4981                	li	s3,0
 6ce:	bf85                	j	63e <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6d0:	008b0793          	addi	a5,s6,8
 6d4:	f8f43423          	sd	a5,-120(s0)
 6d8:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6dc:	03000593          	li	a1,48
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	e2e080e7          	jalr	-466(ra) # 510 <putc>
  putc(fd, 'x');
 6ea:	07800593          	li	a1,120
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	e20080e7          	jalr	-480(ra) # 510 <putc>
 6f8:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6fa:	03c9d793          	srli	a5,s3,0x3c
 6fe:	97de                	add	a5,a5,s7
 700:	0007c583          	lbu	a1,0(a5)
 704:	8556                	mv	a0,s5
 706:	00000097          	auipc	ra,0x0
 70a:	e0a080e7          	jalr	-502(ra) # 510 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 70e:	0992                	slli	s3,s3,0x4
 710:	397d                	addiw	s2,s2,-1
 712:	fe0914e3          	bnez	s2,6fa <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 716:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 71a:	4981                	li	s3,0
 71c:	b70d                	j	63e <vprintf+0x60>
        s = va_arg(ap, char*);
 71e:	008b0913          	addi	s2,s6,8
 722:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 726:	02098163          	beqz	s3,748 <vprintf+0x16a>
        while(*s != 0){
 72a:	0009c583          	lbu	a1,0(s3)
 72e:	c5ad                	beqz	a1,798 <vprintf+0x1ba>
          putc(fd, *s);
 730:	8556                	mv	a0,s5
 732:	00000097          	auipc	ra,0x0
 736:	dde080e7          	jalr	-546(ra) # 510 <putc>
          s++;
 73a:	0985                	addi	s3,s3,1
        while(*s != 0){
 73c:	0009c583          	lbu	a1,0(s3)
 740:	f9e5                	bnez	a1,730 <vprintf+0x152>
        s = va_arg(ap, char*);
 742:	8b4a                	mv	s6,s2
      state = 0;
 744:	4981                	li	s3,0
 746:	bde5                	j	63e <vprintf+0x60>
          s = "(null)";
 748:	00000997          	auipc	s3,0x0
 74c:	26098993          	addi	s3,s3,608 # 9a8 <malloc+0x106>
        while(*s != 0){
 750:	85ee                	mv	a1,s11
 752:	bff9                	j	730 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 754:	008b0913          	addi	s2,s6,8
 758:	000b4583          	lbu	a1,0(s6)
 75c:	8556                	mv	a0,s5
 75e:	00000097          	auipc	ra,0x0
 762:	db2080e7          	jalr	-590(ra) # 510 <putc>
 766:	8b4a                	mv	s6,s2
      state = 0;
 768:	4981                	li	s3,0
 76a:	bdd1                	j	63e <vprintf+0x60>
        putc(fd, c);
 76c:	85d2                	mv	a1,s4
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	da0080e7          	jalr	-608(ra) # 510 <putc>
      state = 0;
 778:	4981                	li	s3,0
 77a:	b5d1                	j	63e <vprintf+0x60>
        putc(fd, '%');
 77c:	85d2                	mv	a1,s4
 77e:	8556                	mv	a0,s5
 780:	00000097          	auipc	ra,0x0
 784:	d90080e7          	jalr	-624(ra) # 510 <putc>
        putc(fd, c);
 788:	85ca                	mv	a1,s2
 78a:	8556                	mv	a0,s5
 78c:	00000097          	auipc	ra,0x0
 790:	d84080e7          	jalr	-636(ra) # 510 <putc>
      state = 0;
 794:	4981                	li	s3,0
 796:	b565                	j	63e <vprintf+0x60>
        s = va_arg(ap, char*);
 798:	8b4a                	mv	s6,s2
      state = 0;
 79a:	4981                	li	s3,0
 79c:	b54d                	j	63e <vprintf+0x60>
    }
  }
}
 79e:	70e6                	ld	ra,120(sp)
 7a0:	7446                	ld	s0,112(sp)
 7a2:	74a6                	ld	s1,104(sp)
 7a4:	7906                	ld	s2,96(sp)
 7a6:	69e6                	ld	s3,88(sp)
 7a8:	6a46                	ld	s4,80(sp)
 7aa:	6aa6                	ld	s5,72(sp)
 7ac:	6b06                	ld	s6,64(sp)
 7ae:	7be2                	ld	s7,56(sp)
 7b0:	7c42                	ld	s8,48(sp)
 7b2:	7ca2                	ld	s9,40(sp)
 7b4:	7d02                	ld	s10,32(sp)
 7b6:	6de2                	ld	s11,24(sp)
 7b8:	6109                	addi	sp,sp,128
 7ba:	8082                	ret

00000000000007bc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7bc:	715d                	addi	sp,sp,-80
 7be:	ec06                	sd	ra,24(sp)
 7c0:	e822                	sd	s0,16(sp)
 7c2:	1000                	addi	s0,sp,32
 7c4:	e010                	sd	a2,0(s0)
 7c6:	e414                	sd	a3,8(s0)
 7c8:	e818                	sd	a4,16(s0)
 7ca:	ec1c                	sd	a5,24(s0)
 7cc:	03043023          	sd	a6,32(s0)
 7d0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7d4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7d8:	8622                	mv	a2,s0
 7da:	00000097          	auipc	ra,0x0
 7de:	e04080e7          	jalr	-508(ra) # 5de <vprintf>
}
 7e2:	60e2                	ld	ra,24(sp)
 7e4:	6442                	ld	s0,16(sp)
 7e6:	6161                	addi	sp,sp,80
 7e8:	8082                	ret

00000000000007ea <printf>:

void
printf(const char *fmt, ...)
{
 7ea:	711d                	addi	sp,sp,-96
 7ec:	ec06                	sd	ra,24(sp)
 7ee:	e822                	sd	s0,16(sp)
 7f0:	1000                	addi	s0,sp,32
 7f2:	e40c                	sd	a1,8(s0)
 7f4:	e810                	sd	a2,16(s0)
 7f6:	ec14                	sd	a3,24(s0)
 7f8:	f018                	sd	a4,32(s0)
 7fa:	f41c                	sd	a5,40(s0)
 7fc:	03043823          	sd	a6,48(s0)
 800:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 804:	00840613          	addi	a2,s0,8
 808:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 80c:	85aa                	mv	a1,a0
 80e:	4505                	li	a0,1
 810:	00000097          	auipc	ra,0x0
 814:	dce080e7          	jalr	-562(ra) # 5de <vprintf>
}
 818:	60e2                	ld	ra,24(sp)
 81a:	6442                	ld	s0,16(sp)
 81c:	6125                	addi	sp,sp,96
 81e:	8082                	ret

0000000000000820 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 820:	1141                	addi	sp,sp,-16
 822:	e422                	sd	s0,8(sp)
 824:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 826:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 82a:	00000797          	auipc	a5,0x0
 82e:	1f67b783          	ld	a5,502(a5) # a20 <freep>
 832:	a02d                	j	85c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 834:	4618                	lw	a4,8(a2)
 836:	9f2d                	addw	a4,a4,a1
 838:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 83c:	6398                	ld	a4,0(a5)
 83e:	6310                	ld	a2,0(a4)
 840:	a83d                	j	87e <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 842:	ff852703          	lw	a4,-8(a0)
 846:	9f31                	addw	a4,a4,a2
 848:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 84a:	ff053683          	ld	a3,-16(a0)
 84e:	a091                	j	892 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 850:	6398                	ld	a4,0(a5)
 852:	00e7e463          	bltu	a5,a4,85a <free+0x3a>
 856:	00e6ea63          	bltu	a3,a4,86a <free+0x4a>
{
 85a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 85c:	fed7fae3          	bgeu	a5,a3,850 <free+0x30>
 860:	6398                	ld	a4,0(a5)
 862:	00e6e463          	bltu	a3,a4,86a <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 866:	fee7eae3          	bltu	a5,a4,85a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 86a:	ff852583          	lw	a1,-8(a0)
 86e:	6390                	ld	a2,0(a5)
 870:	02059813          	slli	a6,a1,0x20
 874:	01c85713          	srli	a4,a6,0x1c
 878:	9736                	add	a4,a4,a3
 87a:	fae60de3          	beq	a2,a4,834 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 87e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 882:	4790                	lw	a2,8(a5)
 884:	02061593          	slli	a1,a2,0x20
 888:	01c5d713          	srli	a4,a1,0x1c
 88c:	973e                	add	a4,a4,a5
 88e:	fae68ae3          	beq	a3,a4,842 <free+0x22>
    p->s.ptr = bp->s.ptr;
 892:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 894:	00000717          	auipc	a4,0x0
 898:	18f73623          	sd	a5,396(a4) # a20 <freep>
}
 89c:	6422                	ld	s0,8(sp)
 89e:	0141                	addi	sp,sp,16
 8a0:	8082                	ret

00000000000008a2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8a2:	7139                	addi	sp,sp,-64
 8a4:	fc06                	sd	ra,56(sp)
 8a6:	f822                	sd	s0,48(sp)
 8a8:	f426                	sd	s1,40(sp)
 8aa:	f04a                	sd	s2,32(sp)
 8ac:	ec4e                	sd	s3,24(sp)
 8ae:	e852                	sd	s4,16(sp)
 8b0:	e456                	sd	s5,8(sp)
 8b2:	e05a                	sd	s6,0(sp)
 8b4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b6:	02051493          	slli	s1,a0,0x20
 8ba:	9081                	srli	s1,s1,0x20
 8bc:	04bd                	addi	s1,s1,15
 8be:	8091                	srli	s1,s1,0x4
 8c0:	0014899b          	addiw	s3,s1,1
 8c4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8c6:	00000517          	auipc	a0,0x0
 8ca:	15a53503          	ld	a0,346(a0) # a20 <freep>
 8ce:	c515                	beqz	a0,8fa <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d2:	4798                	lw	a4,8(a5)
 8d4:	02977f63          	bgeu	a4,s1,912 <malloc+0x70>
 8d8:	8a4e                	mv	s4,s3
 8da:	0009871b          	sext.w	a4,s3
 8de:	6685                	lui	a3,0x1
 8e0:	00d77363          	bgeu	a4,a3,8e6 <malloc+0x44>
 8e4:	6a05                	lui	s4,0x1
 8e6:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8ea:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8ee:	00000917          	auipc	s2,0x0
 8f2:	13290913          	addi	s2,s2,306 # a20 <freep>
  if(p == (char*)-1)
 8f6:	5afd                	li	s5,-1
 8f8:	a895                	j	96c <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8fa:	00000797          	auipc	a5,0x0
 8fe:	12e78793          	addi	a5,a5,302 # a28 <base>
 902:	00000717          	auipc	a4,0x0
 906:	10f73f23          	sd	a5,286(a4) # a20 <freep>
 90a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 90c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 910:	b7e1                	j	8d8 <malloc+0x36>
      if(p->s.size == nunits)
 912:	02e48c63          	beq	s1,a4,94a <malloc+0xa8>
        p->s.size -= nunits;
 916:	4137073b          	subw	a4,a4,s3
 91a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 91c:	02071693          	slli	a3,a4,0x20
 920:	01c6d713          	srli	a4,a3,0x1c
 924:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 926:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 92a:	00000717          	auipc	a4,0x0
 92e:	0ea73b23          	sd	a0,246(a4) # a20 <freep>
      return (void*)(p + 1);
 932:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 936:	70e2                	ld	ra,56(sp)
 938:	7442                	ld	s0,48(sp)
 93a:	74a2                	ld	s1,40(sp)
 93c:	7902                	ld	s2,32(sp)
 93e:	69e2                	ld	s3,24(sp)
 940:	6a42                	ld	s4,16(sp)
 942:	6aa2                	ld	s5,8(sp)
 944:	6b02                	ld	s6,0(sp)
 946:	6121                	addi	sp,sp,64
 948:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 94a:	6398                	ld	a4,0(a5)
 94c:	e118                	sd	a4,0(a0)
 94e:	bff1                	j	92a <malloc+0x88>
  hp->s.size = nu;
 950:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 954:	0541                	addi	a0,a0,16
 956:	00000097          	auipc	ra,0x0
 95a:	eca080e7          	jalr	-310(ra) # 820 <free>
  return freep;
 95e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 962:	d971                	beqz	a0,936 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 964:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 966:	4798                	lw	a4,8(a5)
 968:	fa9775e3          	bgeu	a4,s1,912 <malloc+0x70>
    if(p == freep)
 96c:	00093703          	ld	a4,0(s2)
 970:	853e                	mv	a0,a5
 972:	fef719e3          	bne	a4,a5,964 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 976:	8552                	mv	a0,s4
 978:	00000097          	auipc	ra,0x0
 97c:	b80080e7          	jalr	-1152(ra) # 4f8 <sbrk>
  if(p == (char*)-1)
 980:	fd5518e3          	bne	a0,s5,950 <malloc+0xae>
        return 0;
 984:	4501                	li	a0,0
 986:	bf45                	j	936 <malloc+0x94>
