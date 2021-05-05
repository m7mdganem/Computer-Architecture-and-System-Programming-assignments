#include <stdio.h>

extern void assFunc(int x);

char c_checkValidity(int x){
    if (x%2 == 0)
        return 1;
    return 0;
}

int main(int argc, char const *argv[]){
    char input[12];
    fgets(input,12,stdin);
    int number;
    sscanf(input,"%d",&number);
    assFunc(number);

    return 0;
}
 