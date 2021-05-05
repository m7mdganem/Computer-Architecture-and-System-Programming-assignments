#include <stdio.h>
#include <string.h>
#define	MAX_LEN 34			/* maximal input string size */
					/* enough to get 32-bit string + '\n' + null terminator */
extern int convertor(char* buf);

int main(int argc, char** argv)
{
  char buf[MAX_LEN ];
  int bool = 1;
  while(bool){
    fgets(buf, MAX_LEN, stdin);		/* get user input string */
    bool = convertor(buf);			/* call your assembly function */
  }
  return 0;
}