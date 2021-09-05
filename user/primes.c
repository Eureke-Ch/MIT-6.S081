#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]){
  if(argc > 1){
    fprintf(2, "Error of Input!");
    exit(1);
  }
  int p[2];
  pipe(p);
  char buf[1];
  int prime = 0;
  if(fork() != 0){
    close(p[0]);
    for(int i = 0;i < 34;++i){
      buf[0] = i+'0'+2;
      write(p[1], buf, 1);
    }
    close(p[1]);
    wait(0);
    exit(0);
  }else{
    close(p[1]);
    while(1){
      if(read(p[0], buf, 1) != 0){
        prime = buf[0] - '0';
        printf("prime %d\n", prime);
        int p_c[2];
        pipe(p_c);
        if(fork() != 0){
          close(p_c[0]);
          while(read(p[0], buf, 1) != 0){
            int num = buf[0] - '0';
            if(num % prime != 0){
              write(p_c[1], buf, 1);
            }
          }
          close(p[0]);
          close(p_c[1]);
          close(p_c[0]);
          break;
        }else{
          close(p[0]);
          p[0] = p_c[0];
          close(p_c[1]);
        }
      }else{
        close(p[0]);
        break;
      }
    }
    wait(0);
    exit(0);
  }
  exit(0);
}