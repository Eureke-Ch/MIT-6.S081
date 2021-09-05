
user/_find：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <find>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

void find(char *path, char *str){
   0:	d9010113          	addi	sp,sp,-624
   4:	26113423          	sd	ra,616(sp)
   8:	26813023          	sd	s0,608(sp)
   c:	24913c23          	sd	s1,600(sp)
  10:	25213823          	sd	s2,592(sp)
  14:	25313423          	sd	s3,584(sp)
  18:	25413023          	sd	s4,576(sp)
  1c:	23513c23          	sd	s5,568(sp)
  20:	23613823          	sd	s6,560(sp)
  24:	1c80                	addi	s0,sp,624
  26:	892a                	mv	s2,a0
  28:	89ae                	mv	s3,a1
  struct stat st;
  struct dirent de;
  char buf[512], *p;
  int fd;
  if((fd = open(path, 0)) < 0){
  2a:	4581                	li	a1,0
  2c:	00000097          	auipc	ra,0x0
  30:	4d8080e7          	jalr	1240(ra) # 504 <open>
  34:	10054763          	bltz	a0,142 <find+0x142>
  38:	84aa                	mv	s1,a0
    fprintf(2, "find: cannot open %s\n", path);
    exit(1);
  }

  if(fstat(fd, &st) < 0){
  3a:	fa840593          	addi	a1,s0,-88
  3e:	00000097          	auipc	ra,0x0
  42:	4de080e7          	jalr	1246(ra) # 51c <fstat>
  46:	10054d63          	bltz	a0,160 <find+0x160>
    fprintf(2, "find: cannot stat %s\n", path);
    close(fd);
    exit(1);
  }
  if(strlen(path) + 1 + DIRSIZ + 1 > sizeof(buf)){
  4a:	854a                	mv	a0,s2
  4c:	00000097          	auipc	ra,0x0
  50:	254080e7          	jalr	596(ra) # 2a0 <strlen>
  54:	2541                	addiw	a0,a0,16
  56:	20000793          	li	a5,512
  5a:	12a7e763          	bltu	a5,a0,188 <find+0x188>
    printf("find: path too long\n");
    exit(1);
  }
  strcpy(buf, path);
  5e:	85ca                	mv	a1,s2
  60:	d9840513          	addi	a0,s0,-616
  64:	00000097          	auipc	ra,0x0
  68:	1f4080e7          	jalr	500(ra) # 258 <strcpy>
  p = buf+strlen(buf);
  6c:	d9840513          	addi	a0,s0,-616
  70:	00000097          	auipc	ra,0x0
  74:	230080e7          	jalr	560(ra) # 2a0 <strlen>
  78:	1502                	slli	a0,a0,0x20
  7a:	9101                	srli	a0,a0,0x20
  7c:	d9840793          	addi	a5,s0,-616
  80:	00a78933          	add	s2,a5,a0
  *p++ = '/';
  84:	00190b13          	addi	s6,s2,1
  88:	02f00793          	li	a5,47
  8c:	00f90023          	sb	a5,0(s2)
  while(read(fd, &de, sizeof(de)) == sizeof(de)){
    if(de.inum == 0 || strcmp(de.name, ".") == 0 || !strcmp(de.name, ".."))
  90:	00001a17          	auipc	s4,0x1
  94:	998a0a13          	addi	s4,s4,-1640 # a28 <malloc+0x132>
  98:	00001a97          	auipc	s5,0x1
  9c:	998a8a93          	addi	s5,s5,-1640 # a30 <malloc+0x13a>
  while(read(fd, &de, sizeof(de)) == sizeof(de)){
  a0:	4641                	li	a2,16
  a2:	f9840593          	addi	a1,s0,-104
  a6:	8526                	mv	a0,s1
  a8:	00000097          	auipc	ra,0x0
  ac:	434080e7          	jalr	1076(ra) # 4dc <read>
  b0:	47c1                	li	a5,16
  b2:	10f51b63          	bne	a0,a5,1c8 <find+0x1c8>
    if(de.inum == 0 || strcmp(de.name, ".") == 0 || !strcmp(de.name, ".."))
  b6:	f9845783          	lhu	a5,-104(s0)
  ba:	d3fd                	beqz	a5,a0 <find+0xa0>
  bc:	85d2                	mv	a1,s4
  be:	f9a40513          	addi	a0,s0,-102
  c2:	00000097          	auipc	ra,0x0
  c6:	1b2080e7          	jalr	434(ra) # 274 <strcmp>
  ca:	d979                	beqz	a0,a0 <find+0xa0>
  cc:	85d6                	mv	a1,s5
  ce:	f9a40513          	addi	a0,s0,-102
  d2:	00000097          	auipc	ra,0x0
  d6:	1a2080e7          	jalr	418(ra) # 274 <strcmp>
  da:	d179                	beqz	a0,a0 <find+0xa0>
      continue;
    memmove(p, de.name, DIRSIZ);
  dc:	4639                	li	a2,14
  de:	f9a40593          	addi	a1,s0,-102
  e2:	855a                	mv	a0,s6
  e4:	00000097          	auipc	ra,0x0
  e8:	32e080e7          	jalr	814(ra) # 412 <memmove>
    p[DIRSIZ] = 0;
  ec:	000907a3          	sb	zero,15(s2)
    if(stat(buf, &st) < 0){
  f0:	fa840593          	addi	a1,s0,-88
  f4:	d9840513          	addi	a0,s0,-616
  f8:	00000097          	auipc	ra,0x0
  fc:	28c080e7          	jalr	652(ra) # 384 <stat>
 100:	0a054163          	bltz	a0,1a2 <find+0x1a2>
      printf("find: cannot stat %s\n", buf);
      continue;
    }
    if(st.type == T_DIR){
 104:	fb041783          	lh	a5,-80(s0)
 108:	0007869b          	sext.w	a3,a5
 10c:	4705                	li	a4,1
 10e:	0ae68563          	beq	a3,a4,1b8 <find+0x1b8>
      find(buf, str);
    }else if(st.type == T_FILE){ 
 112:	2781                	sext.w	a5,a5
 114:	4709                	li	a4,2
 116:	f8e795e3          	bne	a5,a4,a0 <find+0xa0>
      if(strcmp(de.name, str) == 0){
 11a:	85ce                	mv	a1,s3
 11c:	f9a40513          	addi	a0,s0,-102
 120:	00000097          	auipc	ra,0x0
 124:	154080e7          	jalr	340(ra) # 274 <strcmp>
 128:	fd25                	bnez	a0,a0 <find+0xa0>
        fprintf(1,"%s\n", buf);
 12a:	d9840613          	addi	a2,s0,-616
 12e:	00001597          	auipc	a1,0x1
 132:	90a58593          	addi	a1,a1,-1782 # a38 <malloc+0x142>
 136:	4505                	li	a0,1
 138:	00000097          	auipc	ra,0x0
 13c:	6d8080e7          	jalr	1752(ra) # 810 <fprintf>
 140:	b785                	j	a0 <find+0xa0>
    fprintf(2, "find: cannot open %s\n", path);
 142:	864a                	mv	a2,s2
 144:	00001597          	auipc	a1,0x1
 148:	89c58593          	addi	a1,a1,-1892 # 9e0 <malloc+0xea>
 14c:	4509                	li	a0,2
 14e:	00000097          	auipc	ra,0x0
 152:	6c2080e7          	jalr	1730(ra) # 810 <fprintf>
    exit(1);
 156:	4505                	li	a0,1
 158:	00000097          	auipc	ra,0x0
 15c:	36c080e7          	jalr	876(ra) # 4c4 <exit>
    fprintf(2, "find: cannot stat %s\n", path);
 160:	864a                	mv	a2,s2
 162:	00001597          	auipc	a1,0x1
 166:	89658593          	addi	a1,a1,-1898 # 9f8 <malloc+0x102>
 16a:	4509                	li	a0,2
 16c:	00000097          	auipc	ra,0x0
 170:	6a4080e7          	jalr	1700(ra) # 810 <fprintf>
    close(fd);
 174:	8526                	mv	a0,s1
 176:	00000097          	auipc	ra,0x0
 17a:	376080e7          	jalr	886(ra) # 4ec <close>
    exit(1);
 17e:	4505                	li	a0,1
 180:	00000097          	auipc	ra,0x0
 184:	344080e7          	jalr	836(ra) # 4c4 <exit>
    printf("find: path too long\n");
 188:	00001517          	auipc	a0,0x1
 18c:	88850513          	addi	a0,a0,-1912 # a10 <malloc+0x11a>
 190:	00000097          	auipc	ra,0x0
 194:	6ae080e7          	jalr	1710(ra) # 83e <printf>
    exit(1);
 198:	4505                	li	a0,1
 19a:	00000097          	auipc	ra,0x0
 19e:	32a080e7          	jalr	810(ra) # 4c4 <exit>
      printf("find: cannot stat %s\n", buf);
 1a2:	d9840593          	addi	a1,s0,-616
 1a6:	00001517          	auipc	a0,0x1
 1aa:	85250513          	addi	a0,a0,-1966 # 9f8 <malloc+0x102>
 1ae:	00000097          	auipc	ra,0x0
 1b2:	690080e7          	jalr	1680(ra) # 83e <printf>
      continue;
 1b6:	b5ed                	j	a0 <find+0xa0>
      find(buf, str);
 1b8:	85ce                	mv	a1,s3
 1ba:	d9840513          	addi	a0,s0,-616
 1be:	00000097          	auipc	ra,0x0
 1c2:	e42080e7          	jalr	-446(ra) # 0 <find>
 1c6:	bde9                	j	a0 <find+0xa0>
      }
    }
  }
  close(fd);
 1c8:	8526                	mv	a0,s1
 1ca:	00000097          	auipc	ra,0x0
 1ce:	322080e7          	jalr	802(ra) # 4ec <close>
}
 1d2:	26813083          	ld	ra,616(sp)
 1d6:	26013403          	ld	s0,608(sp)
 1da:	25813483          	ld	s1,600(sp)
 1de:	25013903          	ld	s2,592(sp)
 1e2:	24813983          	ld	s3,584(sp)
 1e6:	24013a03          	ld	s4,576(sp)
 1ea:	23813a83          	ld	s5,568(sp)
 1ee:	23013b03          	ld	s6,560(sp)
 1f2:	27010113          	addi	sp,sp,624
 1f6:	8082                	ret

00000000000001f8 <main>:


int main(int argc, char *argv[]){
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e406                	sd	ra,8(sp)
 1fc:	e022                	sd	s0,0(sp)
 1fe:	0800                	addi	s0,sp,16
  if(argc < 2 || argc > 3){
 200:	ffe5069b          	addiw	a3,a0,-2
 204:	4705                	li	a4,1
 206:	02d76163          	bltu	a4,a3,228 <main+0x30>
 20a:	87ae                	mv	a5,a1
    fprintf(2, "find: Error of Input!");
    exit(1);
  }else if(argc == 2){
 20c:	4709                	li	a4,2
 20e:	02e50b63          	beq	a0,a4,244 <main+0x4c>
    find(".", argv[1]);
  }else{
    find(argv[1], argv[2]);
 212:	698c                	ld	a1,16(a1)
 214:	6788                	ld	a0,8(a5)
 216:	00000097          	auipc	ra,0x0
 21a:	dea080e7          	jalr	-534(ra) # 0 <find>
  }
  exit(0);
 21e:	4501                	li	a0,0
 220:	00000097          	auipc	ra,0x0
 224:	2a4080e7          	jalr	676(ra) # 4c4 <exit>
    fprintf(2, "find: Error of Input!");
 228:	00001597          	auipc	a1,0x1
 22c:	81858593          	addi	a1,a1,-2024 # a40 <malloc+0x14a>
 230:	4509                	li	a0,2
 232:	00000097          	auipc	ra,0x0
 236:	5de080e7          	jalr	1502(ra) # 810 <fprintf>
    exit(1);
 23a:	4505                	li	a0,1
 23c:	00000097          	auipc	ra,0x0
 240:	288080e7          	jalr	648(ra) # 4c4 <exit>
    find(".", argv[1]);
 244:	658c                	ld	a1,8(a1)
 246:	00000517          	auipc	a0,0x0
 24a:	7e250513          	addi	a0,a0,2018 # a28 <malloc+0x132>
 24e:	00000097          	auipc	ra,0x0
 252:	db2080e7          	jalr	-590(ra) # 0 <find>
 256:	b7e1                	j	21e <main+0x26>

0000000000000258 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 25e:	87aa                	mv	a5,a0
 260:	0585                	addi	a1,a1,1
 262:	0785                	addi	a5,a5,1
 264:	fff5c703          	lbu	a4,-1(a1)
 268:	fee78fa3          	sb	a4,-1(a5)
 26c:	fb75                	bnez	a4,260 <strcpy+0x8>
    ;
  return os;
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret

0000000000000274 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 274:	1141                	addi	sp,sp,-16
 276:	e422                	sd	s0,8(sp)
 278:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 27a:	00054783          	lbu	a5,0(a0)
 27e:	cb91                	beqz	a5,292 <strcmp+0x1e>
 280:	0005c703          	lbu	a4,0(a1)
 284:	00f71763          	bne	a4,a5,292 <strcmp+0x1e>
    p++, q++;
 288:	0505                	addi	a0,a0,1
 28a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 28c:	00054783          	lbu	a5,0(a0)
 290:	fbe5                	bnez	a5,280 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 292:	0005c503          	lbu	a0,0(a1)
}
 296:	40a7853b          	subw	a0,a5,a0
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret

00000000000002a0 <strlen>:

uint
strlen(const char *s)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	cf91                	beqz	a5,2c6 <strlen+0x26>
 2ac:	0505                	addi	a0,a0,1
 2ae:	87aa                	mv	a5,a0
 2b0:	4685                	li	a3,1
 2b2:	9e89                	subw	a3,a3,a0
 2b4:	00f6853b          	addw	a0,a3,a5
 2b8:	0785                	addi	a5,a5,1
 2ba:	fff7c703          	lbu	a4,-1(a5)
 2be:	fb7d                	bnez	a4,2b4 <strlen+0x14>
    ;
  return n;
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
  for(n = 0; s[n]; n++)
 2c6:	4501                	li	a0,0
 2c8:	bfe5                	j	2c0 <strlen+0x20>

00000000000002ca <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e422                	sd	s0,8(sp)
 2ce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2d0:	ca19                	beqz	a2,2e6 <memset+0x1c>
 2d2:	87aa                	mv	a5,a0
 2d4:	1602                	slli	a2,a2,0x20
 2d6:	9201                	srli	a2,a2,0x20
 2d8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2dc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2e0:	0785                	addi	a5,a5,1
 2e2:	fee79de3          	bne	a5,a4,2dc <memset+0x12>
  }
  return dst;
}
 2e6:	6422                	ld	s0,8(sp)
 2e8:	0141                	addi	sp,sp,16
 2ea:	8082                	ret

00000000000002ec <strchr>:

char*
strchr(const char *s, char c)
{
 2ec:	1141                	addi	sp,sp,-16
 2ee:	e422                	sd	s0,8(sp)
 2f0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2f2:	00054783          	lbu	a5,0(a0)
 2f6:	cb99                	beqz	a5,30c <strchr+0x20>
    if(*s == c)
 2f8:	00f58763          	beq	a1,a5,306 <strchr+0x1a>
  for(; *s; s++)
 2fc:	0505                	addi	a0,a0,1
 2fe:	00054783          	lbu	a5,0(a0)
 302:	fbfd                	bnez	a5,2f8 <strchr+0xc>
      return (char*)s;
  return 0;
 304:	4501                	li	a0,0
}
 306:	6422                	ld	s0,8(sp)
 308:	0141                	addi	sp,sp,16
 30a:	8082                	ret
  return 0;
 30c:	4501                	li	a0,0
 30e:	bfe5                	j	306 <strchr+0x1a>

0000000000000310 <gets>:

char*
gets(char *buf, int max)
{
 310:	711d                	addi	sp,sp,-96
 312:	ec86                	sd	ra,88(sp)
 314:	e8a2                	sd	s0,80(sp)
 316:	e4a6                	sd	s1,72(sp)
 318:	e0ca                	sd	s2,64(sp)
 31a:	fc4e                	sd	s3,56(sp)
 31c:	f852                	sd	s4,48(sp)
 31e:	f456                	sd	s5,40(sp)
 320:	f05a                	sd	s6,32(sp)
 322:	ec5e                	sd	s7,24(sp)
 324:	1080                	addi	s0,sp,96
 326:	8baa                	mv	s7,a0
 328:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 32a:	892a                	mv	s2,a0
 32c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 32e:	4aa9                	li	s5,10
 330:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 332:	89a6                	mv	s3,s1
 334:	2485                	addiw	s1,s1,1
 336:	0344d863          	bge	s1,s4,366 <gets+0x56>
    cc = read(0, &c, 1);
 33a:	4605                	li	a2,1
 33c:	faf40593          	addi	a1,s0,-81
 340:	4501                	li	a0,0
 342:	00000097          	auipc	ra,0x0
 346:	19a080e7          	jalr	410(ra) # 4dc <read>
    if(cc < 1)
 34a:	00a05e63          	blez	a0,366 <gets+0x56>
    buf[i++] = c;
 34e:	faf44783          	lbu	a5,-81(s0)
 352:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 356:	01578763          	beq	a5,s5,364 <gets+0x54>
 35a:	0905                	addi	s2,s2,1
 35c:	fd679be3          	bne	a5,s6,332 <gets+0x22>
  for(i=0; i+1 < max; ){
 360:	89a6                	mv	s3,s1
 362:	a011                	j	366 <gets+0x56>
 364:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 366:	99de                	add	s3,s3,s7
 368:	00098023          	sb	zero,0(s3)
  return buf;
}
 36c:	855e                	mv	a0,s7
 36e:	60e6                	ld	ra,88(sp)
 370:	6446                	ld	s0,80(sp)
 372:	64a6                	ld	s1,72(sp)
 374:	6906                	ld	s2,64(sp)
 376:	79e2                	ld	s3,56(sp)
 378:	7a42                	ld	s4,48(sp)
 37a:	7aa2                	ld	s5,40(sp)
 37c:	7b02                	ld	s6,32(sp)
 37e:	6be2                	ld	s7,24(sp)
 380:	6125                	addi	sp,sp,96
 382:	8082                	ret

0000000000000384 <stat>:

int
stat(const char *n, struct stat *st)
{
 384:	1101                	addi	sp,sp,-32
 386:	ec06                	sd	ra,24(sp)
 388:	e822                	sd	s0,16(sp)
 38a:	e426                	sd	s1,8(sp)
 38c:	e04a                	sd	s2,0(sp)
 38e:	1000                	addi	s0,sp,32
 390:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 392:	4581                	li	a1,0
 394:	00000097          	auipc	ra,0x0
 398:	170080e7          	jalr	368(ra) # 504 <open>
  if(fd < 0)
 39c:	02054563          	bltz	a0,3c6 <stat+0x42>
 3a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3a2:	85ca                	mv	a1,s2
 3a4:	00000097          	auipc	ra,0x0
 3a8:	178080e7          	jalr	376(ra) # 51c <fstat>
 3ac:	892a                	mv	s2,a0
  close(fd);
 3ae:	8526                	mv	a0,s1
 3b0:	00000097          	auipc	ra,0x0
 3b4:	13c080e7          	jalr	316(ra) # 4ec <close>
  return r;
}
 3b8:	854a                	mv	a0,s2
 3ba:	60e2                	ld	ra,24(sp)
 3bc:	6442                	ld	s0,16(sp)
 3be:	64a2                	ld	s1,8(sp)
 3c0:	6902                	ld	s2,0(sp)
 3c2:	6105                	addi	sp,sp,32
 3c4:	8082                	ret
    return -1;
 3c6:	597d                	li	s2,-1
 3c8:	bfc5                	j	3b8 <stat+0x34>

00000000000003ca <atoi>:

int
atoi(const char *s)
{
 3ca:	1141                	addi	sp,sp,-16
 3cc:	e422                	sd	s0,8(sp)
 3ce:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3d0:	00054683          	lbu	a3,0(a0)
 3d4:	fd06879b          	addiw	a5,a3,-48
 3d8:	0ff7f793          	zext.b	a5,a5
 3dc:	4625                	li	a2,9
 3de:	02f66863          	bltu	a2,a5,40e <atoi+0x44>
 3e2:	872a                	mv	a4,a0
  n = 0;
 3e4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3e6:	0705                	addi	a4,a4,1
 3e8:	0025179b          	slliw	a5,a0,0x2
 3ec:	9fa9                	addw	a5,a5,a0
 3ee:	0017979b          	slliw	a5,a5,0x1
 3f2:	9fb5                	addw	a5,a5,a3
 3f4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3f8:	00074683          	lbu	a3,0(a4)
 3fc:	fd06879b          	addiw	a5,a3,-48
 400:	0ff7f793          	zext.b	a5,a5
 404:	fef671e3          	bgeu	a2,a5,3e6 <atoi+0x1c>
  return n;
}
 408:	6422                	ld	s0,8(sp)
 40a:	0141                	addi	sp,sp,16
 40c:	8082                	ret
  n = 0;
 40e:	4501                	li	a0,0
 410:	bfe5                	j	408 <atoi+0x3e>

0000000000000412 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 412:	1141                	addi	sp,sp,-16
 414:	e422                	sd	s0,8(sp)
 416:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 418:	02b57463          	bgeu	a0,a1,440 <memmove+0x2e>
    while(n-- > 0)
 41c:	00c05f63          	blez	a2,43a <memmove+0x28>
 420:	1602                	slli	a2,a2,0x20
 422:	9201                	srli	a2,a2,0x20
 424:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 428:	872a                	mv	a4,a0
      *dst++ = *src++;
 42a:	0585                	addi	a1,a1,1
 42c:	0705                	addi	a4,a4,1
 42e:	fff5c683          	lbu	a3,-1(a1)
 432:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 436:	fee79ae3          	bne	a5,a4,42a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 43a:	6422                	ld	s0,8(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret
    dst += n;
 440:	00c50733          	add	a4,a0,a2
    src += n;
 444:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 446:	fec05ae3          	blez	a2,43a <memmove+0x28>
 44a:	fff6079b          	addiw	a5,a2,-1
 44e:	1782                	slli	a5,a5,0x20
 450:	9381                	srli	a5,a5,0x20
 452:	fff7c793          	not	a5,a5
 456:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 458:	15fd                	addi	a1,a1,-1
 45a:	177d                	addi	a4,a4,-1
 45c:	0005c683          	lbu	a3,0(a1)
 460:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 464:	fee79ae3          	bne	a5,a4,458 <memmove+0x46>
 468:	bfc9                	j	43a <memmove+0x28>

000000000000046a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 46a:	1141                	addi	sp,sp,-16
 46c:	e422                	sd	s0,8(sp)
 46e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 470:	ca05                	beqz	a2,4a0 <memcmp+0x36>
 472:	fff6069b          	addiw	a3,a2,-1
 476:	1682                	slli	a3,a3,0x20
 478:	9281                	srli	a3,a3,0x20
 47a:	0685                	addi	a3,a3,1
 47c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 47e:	00054783          	lbu	a5,0(a0)
 482:	0005c703          	lbu	a4,0(a1)
 486:	00e79863          	bne	a5,a4,496 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 48a:	0505                	addi	a0,a0,1
    p2++;
 48c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 48e:	fed518e3          	bne	a0,a3,47e <memcmp+0x14>
  }
  return 0;
 492:	4501                	li	a0,0
 494:	a019                	j	49a <memcmp+0x30>
      return *p1 - *p2;
 496:	40e7853b          	subw	a0,a5,a4
}
 49a:	6422                	ld	s0,8(sp)
 49c:	0141                	addi	sp,sp,16
 49e:	8082                	ret
  return 0;
 4a0:	4501                	li	a0,0
 4a2:	bfe5                	j	49a <memcmp+0x30>

00000000000004a4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4a4:	1141                	addi	sp,sp,-16
 4a6:	e406                	sd	ra,8(sp)
 4a8:	e022                	sd	s0,0(sp)
 4aa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4ac:	00000097          	auipc	ra,0x0
 4b0:	f66080e7          	jalr	-154(ra) # 412 <memmove>
}
 4b4:	60a2                	ld	ra,8(sp)
 4b6:	6402                	ld	s0,0(sp)
 4b8:	0141                	addi	sp,sp,16
 4ba:	8082                	ret

00000000000004bc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4bc:	4885                	li	a7,1
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4c4:	4889                	li	a7,2
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <wait>:
.global wait
wait:
 li a7, SYS_wait
 4cc:	488d                	li	a7,3
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4d4:	4891                	li	a7,4
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <read>:
.global read
read:
 li a7, SYS_read
 4dc:	4895                	li	a7,5
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <write>:
.global write
write:
 li a7, SYS_write
 4e4:	48c1                	li	a7,16
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <close>:
.global close
close:
 li a7, SYS_close
 4ec:	48d5                	li	a7,21
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4f4:	4899                	li	a7,6
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <exec>:
.global exec
exec:
 li a7, SYS_exec
 4fc:	489d                	li	a7,7
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <open>:
.global open
open:
 li a7, SYS_open
 504:	48bd                	li	a7,15
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 50c:	48c5                	li	a7,17
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 514:	48c9                	li	a7,18
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 51c:	48a1                	li	a7,8
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <link>:
.global link
link:
 li a7, SYS_link
 524:	48cd                	li	a7,19
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 52c:	48d1                	li	a7,20
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 534:	48a5                	li	a7,9
 ecall
 536:	00000073          	ecall
 ret
 53a:	8082                	ret

000000000000053c <dup>:
.global dup
dup:
 li a7, SYS_dup
 53c:	48a9                	li	a7,10
 ecall
 53e:	00000073          	ecall
 ret
 542:	8082                	ret

0000000000000544 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 544:	48ad                	li	a7,11
 ecall
 546:	00000073          	ecall
 ret
 54a:	8082                	ret

000000000000054c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 54c:	48b1                	li	a7,12
 ecall
 54e:	00000073          	ecall
 ret
 552:	8082                	ret

0000000000000554 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 554:	48b5                	li	a7,13
 ecall
 556:	00000073          	ecall
 ret
 55a:	8082                	ret

000000000000055c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 55c:	48b9                	li	a7,14
 ecall
 55e:	00000073          	ecall
 ret
 562:	8082                	ret

0000000000000564 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 564:	1101                	addi	sp,sp,-32
 566:	ec06                	sd	ra,24(sp)
 568:	e822                	sd	s0,16(sp)
 56a:	1000                	addi	s0,sp,32
 56c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 570:	4605                	li	a2,1
 572:	fef40593          	addi	a1,s0,-17
 576:	00000097          	auipc	ra,0x0
 57a:	f6e080e7          	jalr	-146(ra) # 4e4 <write>
}
 57e:	60e2                	ld	ra,24(sp)
 580:	6442                	ld	s0,16(sp)
 582:	6105                	addi	sp,sp,32
 584:	8082                	ret

0000000000000586 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 586:	7139                	addi	sp,sp,-64
 588:	fc06                	sd	ra,56(sp)
 58a:	f822                	sd	s0,48(sp)
 58c:	f426                	sd	s1,40(sp)
 58e:	f04a                	sd	s2,32(sp)
 590:	ec4e                	sd	s3,24(sp)
 592:	0080                	addi	s0,sp,64
 594:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 596:	c299                	beqz	a3,59c <printint+0x16>
 598:	0805c963          	bltz	a1,62a <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 59c:	2581                	sext.w	a1,a1
  neg = 0;
 59e:	4881                	li	a7,0
 5a0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 5a4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 5a6:	2601                	sext.w	a2,a2
 5a8:	00000517          	auipc	a0,0x0
 5ac:	51050513          	addi	a0,a0,1296 # ab8 <digits>
 5b0:	883a                	mv	a6,a4
 5b2:	2705                	addiw	a4,a4,1
 5b4:	02c5f7bb          	remuw	a5,a1,a2
 5b8:	1782                	slli	a5,a5,0x20
 5ba:	9381                	srli	a5,a5,0x20
 5bc:	97aa                	add	a5,a5,a0
 5be:	0007c783          	lbu	a5,0(a5)
 5c2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 5c6:	0005879b          	sext.w	a5,a1
 5ca:	02c5d5bb          	divuw	a1,a1,a2
 5ce:	0685                	addi	a3,a3,1
 5d0:	fec7f0e3          	bgeu	a5,a2,5b0 <printint+0x2a>
  if(neg)
 5d4:	00088c63          	beqz	a7,5ec <printint+0x66>
    buf[i++] = '-';
 5d8:	fd070793          	addi	a5,a4,-48
 5dc:	00878733          	add	a4,a5,s0
 5e0:	02d00793          	li	a5,45
 5e4:	fef70823          	sb	a5,-16(a4)
 5e8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5ec:	02e05863          	blez	a4,61c <printint+0x96>
 5f0:	fc040793          	addi	a5,s0,-64
 5f4:	00e78933          	add	s2,a5,a4
 5f8:	fff78993          	addi	s3,a5,-1
 5fc:	99ba                	add	s3,s3,a4
 5fe:	377d                	addiw	a4,a4,-1
 600:	1702                	slli	a4,a4,0x20
 602:	9301                	srli	a4,a4,0x20
 604:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 608:	fff94583          	lbu	a1,-1(s2)
 60c:	8526                	mv	a0,s1
 60e:	00000097          	auipc	ra,0x0
 612:	f56080e7          	jalr	-170(ra) # 564 <putc>
  while(--i >= 0)
 616:	197d                	addi	s2,s2,-1
 618:	ff3918e3          	bne	s2,s3,608 <printint+0x82>
}
 61c:	70e2                	ld	ra,56(sp)
 61e:	7442                	ld	s0,48(sp)
 620:	74a2                	ld	s1,40(sp)
 622:	7902                	ld	s2,32(sp)
 624:	69e2                	ld	s3,24(sp)
 626:	6121                	addi	sp,sp,64
 628:	8082                	ret
    x = -xx;
 62a:	40b005bb          	negw	a1,a1
    neg = 1;
 62e:	4885                	li	a7,1
    x = -xx;
 630:	bf85                	j	5a0 <printint+0x1a>

0000000000000632 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 632:	7119                	addi	sp,sp,-128
 634:	fc86                	sd	ra,120(sp)
 636:	f8a2                	sd	s0,112(sp)
 638:	f4a6                	sd	s1,104(sp)
 63a:	f0ca                	sd	s2,96(sp)
 63c:	ecce                	sd	s3,88(sp)
 63e:	e8d2                	sd	s4,80(sp)
 640:	e4d6                	sd	s5,72(sp)
 642:	e0da                	sd	s6,64(sp)
 644:	fc5e                	sd	s7,56(sp)
 646:	f862                	sd	s8,48(sp)
 648:	f466                	sd	s9,40(sp)
 64a:	f06a                	sd	s10,32(sp)
 64c:	ec6e                	sd	s11,24(sp)
 64e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 650:	0005c903          	lbu	s2,0(a1)
 654:	18090f63          	beqz	s2,7f2 <vprintf+0x1c0>
 658:	8aaa                	mv	s5,a0
 65a:	8b32                	mv	s6,a2
 65c:	00158493          	addi	s1,a1,1
  state = 0;
 660:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 662:	02500a13          	li	s4,37
 666:	4c55                	li	s8,21
 668:	00000c97          	auipc	s9,0x0
 66c:	3f8c8c93          	addi	s9,s9,1016 # a60 <malloc+0x16a>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 670:	02800d93          	li	s11,40
  putc(fd, 'x');
 674:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 676:	00000b97          	auipc	s7,0x0
 67a:	442b8b93          	addi	s7,s7,1090 # ab8 <digits>
 67e:	a839                	j	69c <vprintf+0x6a>
        putc(fd, c);
 680:	85ca                	mv	a1,s2
 682:	8556                	mv	a0,s5
 684:	00000097          	auipc	ra,0x0
 688:	ee0080e7          	jalr	-288(ra) # 564 <putc>
 68c:	a019                	j	692 <vprintf+0x60>
    } else if(state == '%'){
 68e:	01498d63          	beq	s3,s4,6a8 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 692:	0485                	addi	s1,s1,1
 694:	fff4c903          	lbu	s2,-1(s1)
 698:	14090d63          	beqz	s2,7f2 <vprintf+0x1c0>
    if(state == 0){
 69c:	fe0999e3          	bnez	s3,68e <vprintf+0x5c>
      if(c == '%'){
 6a0:	ff4910e3          	bne	s2,s4,680 <vprintf+0x4e>
        state = '%';
 6a4:	89d2                	mv	s3,s4
 6a6:	b7f5                	j	692 <vprintf+0x60>
      if(c == 'd'){
 6a8:	11490c63          	beq	s2,s4,7c0 <vprintf+0x18e>
 6ac:	f9d9079b          	addiw	a5,s2,-99
 6b0:	0ff7f793          	zext.b	a5,a5
 6b4:	10fc6e63          	bltu	s8,a5,7d0 <vprintf+0x19e>
 6b8:	f9d9079b          	addiw	a5,s2,-99
 6bc:	0ff7f713          	zext.b	a4,a5
 6c0:	10ec6863          	bltu	s8,a4,7d0 <vprintf+0x19e>
 6c4:	00271793          	slli	a5,a4,0x2
 6c8:	97e6                	add	a5,a5,s9
 6ca:	439c                	lw	a5,0(a5)
 6cc:	97e6                	add	a5,a5,s9
 6ce:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 6d0:	008b0913          	addi	s2,s6,8
 6d4:	4685                	li	a3,1
 6d6:	4629                	li	a2,10
 6d8:	000b2583          	lw	a1,0(s6)
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	ea8080e7          	jalr	-344(ra) # 586 <printint>
 6e6:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	b765                	j	692 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ec:	008b0913          	addi	s2,s6,8
 6f0:	4681                	li	a3,0
 6f2:	4629                	li	a2,10
 6f4:	000b2583          	lw	a1,0(s6)
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	e8c080e7          	jalr	-372(ra) # 586 <printint>
 702:	8b4a                	mv	s6,s2
      state = 0;
 704:	4981                	li	s3,0
 706:	b771                	j	692 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 708:	008b0913          	addi	s2,s6,8
 70c:	4681                	li	a3,0
 70e:	866a                	mv	a2,s10
 710:	000b2583          	lw	a1,0(s6)
 714:	8556                	mv	a0,s5
 716:	00000097          	auipc	ra,0x0
 71a:	e70080e7          	jalr	-400(ra) # 586 <printint>
 71e:	8b4a                	mv	s6,s2
      state = 0;
 720:	4981                	li	s3,0
 722:	bf85                	j	692 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 724:	008b0793          	addi	a5,s6,8
 728:	f8f43423          	sd	a5,-120(s0)
 72c:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 730:	03000593          	li	a1,48
 734:	8556                	mv	a0,s5
 736:	00000097          	auipc	ra,0x0
 73a:	e2e080e7          	jalr	-466(ra) # 564 <putc>
  putc(fd, 'x');
 73e:	07800593          	li	a1,120
 742:	8556                	mv	a0,s5
 744:	00000097          	auipc	ra,0x0
 748:	e20080e7          	jalr	-480(ra) # 564 <putc>
 74c:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 74e:	03c9d793          	srli	a5,s3,0x3c
 752:	97de                	add	a5,a5,s7
 754:	0007c583          	lbu	a1,0(a5)
 758:	8556                	mv	a0,s5
 75a:	00000097          	auipc	ra,0x0
 75e:	e0a080e7          	jalr	-502(ra) # 564 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 762:	0992                	slli	s3,s3,0x4
 764:	397d                	addiw	s2,s2,-1
 766:	fe0914e3          	bnez	s2,74e <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 76a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 76e:	4981                	li	s3,0
 770:	b70d                	j	692 <vprintf+0x60>
        s = va_arg(ap, char*);
 772:	008b0913          	addi	s2,s6,8
 776:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 77a:	02098163          	beqz	s3,79c <vprintf+0x16a>
        while(*s != 0){
 77e:	0009c583          	lbu	a1,0(s3)
 782:	c5ad                	beqz	a1,7ec <vprintf+0x1ba>
          putc(fd, *s);
 784:	8556                	mv	a0,s5
 786:	00000097          	auipc	ra,0x0
 78a:	dde080e7          	jalr	-546(ra) # 564 <putc>
          s++;
 78e:	0985                	addi	s3,s3,1
        while(*s != 0){
 790:	0009c583          	lbu	a1,0(s3)
 794:	f9e5                	bnez	a1,784 <vprintf+0x152>
        s = va_arg(ap, char*);
 796:	8b4a                	mv	s6,s2
      state = 0;
 798:	4981                	li	s3,0
 79a:	bde5                	j	692 <vprintf+0x60>
          s = "(null)";
 79c:	00000997          	auipc	s3,0x0
 7a0:	2bc98993          	addi	s3,s3,700 # a58 <malloc+0x162>
        while(*s != 0){
 7a4:	85ee                	mv	a1,s11
 7a6:	bff9                	j	784 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 7a8:	008b0913          	addi	s2,s6,8
 7ac:	000b4583          	lbu	a1,0(s6)
 7b0:	8556                	mv	a0,s5
 7b2:	00000097          	auipc	ra,0x0
 7b6:	db2080e7          	jalr	-590(ra) # 564 <putc>
 7ba:	8b4a                	mv	s6,s2
      state = 0;
 7bc:	4981                	li	s3,0
 7be:	bdd1                	j	692 <vprintf+0x60>
        putc(fd, c);
 7c0:	85d2                	mv	a1,s4
 7c2:	8556                	mv	a0,s5
 7c4:	00000097          	auipc	ra,0x0
 7c8:	da0080e7          	jalr	-608(ra) # 564 <putc>
      state = 0;
 7cc:	4981                	li	s3,0
 7ce:	b5d1                	j	692 <vprintf+0x60>
        putc(fd, '%');
 7d0:	85d2                	mv	a1,s4
 7d2:	8556                	mv	a0,s5
 7d4:	00000097          	auipc	ra,0x0
 7d8:	d90080e7          	jalr	-624(ra) # 564 <putc>
        putc(fd, c);
 7dc:	85ca                	mv	a1,s2
 7de:	8556                	mv	a0,s5
 7e0:	00000097          	auipc	ra,0x0
 7e4:	d84080e7          	jalr	-636(ra) # 564 <putc>
      state = 0;
 7e8:	4981                	li	s3,0
 7ea:	b565                	j	692 <vprintf+0x60>
        s = va_arg(ap, char*);
 7ec:	8b4a                	mv	s6,s2
      state = 0;
 7ee:	4981                	li	s3,0
 7f0:	b54d                	j	692 <vprintf+0x60>
    }
  }
}
 7f2:	70e6                	ld	ra,120(sp)
 7f4:	7446                	ld	s0,112(sp)
 7f6:	74a6                	ld	s1,104(sp)
 7f8:	7906                	ld	s2,96(sp)
 7fa:	69e6                	ld	s3,88(sp)
 7fc:	6a46                	ld	s4,80(sp)
 7fe:	6aa6                	ld	s5,72(sp)
 800:	6b06                	ld	s6,64(sp)
 802:	7be2                	ld	s7,56(sp)
 804:	7c42                	ld	s8,48(sp)
 806:	7ca2                	ld	s9,40(sp)
 808:	7d02                	ld	s10,32(sp)
 80a:	6de2                	ld	s11,24(sp)
 80c:	6109                	addi	sp,sp,128
 80e:	8082                	ret

0000000000000810 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 810:	715d                	addi	sp,sp,-80
 812:	ec06                	sd	ra,24(sp)
 814:	e822                	sd	s0,16(sp)
 816:	1000                	addi	s0,sp,32
 818:	e010                	sd	a2,0(s0)
 81a:	e414                	sd	a3,8(s0)
 81c:	e818                	sd	a4,16(s0)
 81e:	ec1c                	sd	a5,24(s0)
 820:	03043023          	sd	a6,32(s0)
 824:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 828:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 82c:	8622                	mv	a2,s0
 82e:	00000097          	auipc	ra,0x0
 832:	e04080e7          	jalr	-508(ra) # 632 <vprintf>
}
 836:	60e2                	ld	ra,24(sp)
 838:	6442                	ld	s0,16(sp)
 83a:	6161                	addi	sp,sp,80
 83c:	8082                	ret

000000000000083e <printf>:

void
printf(const char *fmt, ...)
{
 83e:	711d                	addi	sp,sp,-96
 840:	ec06                	sd	ra,24(sp)
 842:	e822                	sd	s0,16(sp)
 844:	1000                	addi	s0,sp,32
 846:	e40c                	sd	a1,8(s0)
 848:	e810                	sd	a2,16(s0)
 84a:	ec14                	sd	a3,24(s0)
 84c:	f018                	sd	a4,32(s0)
 84e:	f41c                	sd	a5,40(s0)
 850:	03043823          	sd	a6,48(s0)
 854:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 858:	00840613          	addi	a2,s0,8
 85c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 860:	85aa                	mv	a1,a0
 862:	4505                	li	a0,1
 864:	00000097          	auipc	ra,0x0
 868:	dce080e7          	jalr	-562(ra) # 632 <vprintf>
}
 86c:	60e2                	ld	ra,24(sp)
 86e:	6442                	ld	s0,16(sp)
 870:	6125                	addi	sp,sp,96
 872:	8082                	ret

0000000000000874 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 874:	1141                	addi	sp,sp,-16
 876:	e422                	sd	s0,8(sp)
 878:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87e:	00000797          	auipc	a5,0x0
 882:	2527b783          	ld	a5,594(a5) # ad0 <freep>
 886:	a02d                	j	8b0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 888:	4618                	lw	a4,8(a2)
 88a:	9f2d                	addw	a4,a4,a1
 88c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 890:	6398                	ld	a4,0(a5)
 892:	6310                	ld	a2,0(a4)
 894:	a83d                	j	8d2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 896:	ff852703          	lw	a4,-8(a0)
 89a:	9f31                	addw	a4,a4,a2
 89c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 89e:	ff053683          	ld	a3,-16(a0)
 8a2:	a091                	j	8e6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a4:	6398                	ld	a4,0(a5)
 8a6:	00e7e463          	bltu	a5,a4,8ae <free+0x3a>
 8aa:	00e6ea63          	bltu	a3,a4,8be <free+0x4a>
{
 8ae:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8b0:	fed7fae3          	bgeu	a5,a3,8a4 <free+0x30>
 8b4:	6398                	ld	a4,0(a5)
 8b6:	00e6e463          	bltu	a3,a4,8be <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8ba:	fee7eae3          	bltu	a5,a4,8ae <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8be:	ff852583          	lw	a1,-8(a0)
 8c2:	6390                	ld	a2,0(a5)
 8c4:	02059813          	slli	a6,a1,0x20
 8c8:	01c85713          	srli	a4,a6,0x1c
 8cc:	9736                	add	a4,a4,a3
 8ce:	fae60de3          	beq	a2,a4,888 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8d2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8d6:	4790                	lw	a2,8(a5)
 8d8:	02061593          	slli	a1,a2,0x20
 8dc:	01c5d713          	srli	a4,a1,0x1c
 8e0:	973e                	add	a4,a4,a5
 8e2:	fae68ae3          	beq	a3,a4,896 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8e6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8e8:	00000717          	auipc	a4,0x0
 8ec:	1ef73423          	sd	a5,488(a4) # ad0 <freep>
}
 8f0:	6422                	ld	s0,8(sp)
 8f2:	0141                	addi	sp,sp,16
 8f4:	8082                	ret

00000000000008f6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8f6:	7139                	addi	sp,sp,-64
 8f8:	fc06                	sd	ra,56(sp)
 8fa:	f822                	sd	s0,48(sp)
 8fc:	f426                	sd	s1,40(sp)
 8fe:	f04a                	sd	s2,32(sp)
 900:	ec4e                	sd	s3,24(sp)
 902:	e852                	sd	s4,16(sp)
 904:	e456                	sd	s5,8(sp)
 906:	e05a                	sd	s6,0(sp)
 908:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 90a:	02051493          	slli	s1,a0,0x20
 90e:	9081                	srli	s1,s1,0x20
 910:	04bd                	addi	s1,s1,15
 912:	8091                	srli	s1,s1,0x4
 914:	0014899b          	addiw	s3,s1,1
 918:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 91a:	00000517          	auipc	a0,0x0
 91e:	1b653503          	ld	a0,438(a0) # ad0 <freep>
 922:	c515                	beqz	a0,94e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 924:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 926:	4798                	lw	a4,8(a5)
 928:	02977f63          	bgeu	a4,s1,966 <malloc+0x70>
 92c:	8a4e                	mv	s4,s3
 92e:	0009871b          	sext.w	a4,s3
 932:	6685                	lui	a3,0x1
 934:	00d77363          	bgeu	a4,a3,93a <malloc+0x44>
 938:	6a05                	lui	s4,0x1
 93a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 93e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 942:	00000917          	auipc	s2,0x0
 946:	18e90913          	addi	s2,s2,398 # ad0 <freep>
  if(p == (char*)-1)
 94a:	5afd                	li	s5,-1
 94c:	a895                	j	9c0 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 94e:	00000797          	auipc	a5,0x0
 952:	18a78793          	addi	a5,a5,394 # ad8 <base>
 956:	00000717          	auipc	a4,0x0
 95a:	16f73d23          	sd	a5,378(a4) # ad0 <freep>
 95e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 960:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 964:	b7e1                	j	92c <malloc+0x36>
      if(p->s.size == nunits)
 966:	02e48c63          	beq	s1,a4,99e <malloc+0xa8>
        p->s.size -= nunits;
 96a:	4137073b          	subw	a4,a4,s3
 96e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 970:	02071693          	slli	a3,a4,0x20
 974:	01c6d713          	srli	a4,a3,0x1c
 978:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 97a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 97e:	00000717          	auipc	a4,0x0
 982:	14a73923          	sd	a0,338(a4) # ad0 <freep>
      return (void*)(p + 1);
 986:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 98a:	70e2                	ld	ra,56(sp)
 98c:	7442                	ld	s0,48(sp)
 98e:	74a2                	ld	s1,40(sp)
 990:	7902                	ld	s2,32(sp)
 992:	69e2                	ld	s3,24(sp)
 994:	6a42                	ld	s4,16(sp)
 996:	6aa2                	ld	s5,8(sp)
 998:	6b02                	ld	s6,0(sp)
 99a:	6121                	addi	sp,sp,64
 99c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 99e:	6398                	ld	a4,0(a5)
 9a0:	e118                	sd	a4,0(a0)
 9a2:	bff1                	j	97e <malloc+0x88>
  hp->s.size = nu;
 9a4:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9a8:	0541                	addi	a0,a0,16
 9aa:	00000097          	auipc	ra,0x0
 9ae:	eca080e7          	jalr	-310(ra) # 874 <free>
  return freep;
 9b2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9b6:	d971                	beqz	a0,98a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9b8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9ba:	4798                	lw	a4,8(a5)
 9bc:	fa9775e3          	bgeu	a4,s1,966 <malloc+0x70>
    if(p == freep)
 9c0:	00093703          	ld	a4,0(s2)
 9c4:	853e                	mv	a0,a5
 9c6:	fef719e3          	bne	a4,a5,9b8 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 9ca:	8552                	mv	a0,s4
 9cc:	00000097          	auipc	ra,0x0
 9d0:	b80080e7          	jalr	-1152(ra) # 54c <sbrk>
  if(p == (char*)-1)
 9d4:	fd5518e3          	bne	a0,s5,9a4 <malloc+0xae>
        return 0;
 9d8:	4501                	li	a0,0
 9da:	bf45                	j	98a <malloc+0x94>
