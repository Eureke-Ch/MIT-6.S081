#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"

int readline(char *new_argv[], int pos){
  char buf[512];
  int i = 0;
  int flag = 1;
  while(read(0, buf+i, 1)){
    flag = 0;
    i++;
    if(buf[i-1] == '\n'){
      buf[i-1] = 0;
      new_argv[pos++] = malloc(i-1);
      strcpy(new_argv[pos-1], buf);
      i = 0;
      break;
    }else if(buf[i-1] == ' '){
      buf[i-1] = 0;
      new_argv[pos++] = malloc(i-1);
      strcpy(new_argv[pos-1], buf);
      i = 0;
    }
  }
  if(flag){return 0;}
  return pos;
}

int main(int argc, char *argv[]){
  char *new_argv[MAXARG];
  char *commod;
  commod = argv[1];
  for(int i = 1;i < argc; ++i){
    new_argv[i-1] = argv[i];
  }
  int pos;
  while((pos = readline(new_argv, argc-1)) != 0){
    new_argv[pos] = 0;
    if(fork() == 0){
      printf("%s\n", commod);
      for(int i = 0;i < pos;++i){
        printf("%s ", new_argv[i]);
      }
      exec(commod, new_argv);
      fprintf(2, "Exec Failed!\n");
      exit(1);
    }
    wait(0);
  }

  exit(0);
}
