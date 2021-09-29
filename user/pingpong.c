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
  char buf[10];

  if(fork() != 0){
    // buf = "ping";
    write(p[1], "ping", 4);
    wait(0);
    read(p[0], buf, 4);
    int pid_p = getpid();
    printf("%d: received %s\n", pid_p, buf);
    exit(0);
  }else{
    int pid_c = getpid();
    read(p[0], buf, 10);
    close(p[0]);
    printf("%d: received %s\n", pid_c,buf);
    write(p[1], "pong", 4);
    close(p[1]);
    exit(0);
  }
  exit(0);
}