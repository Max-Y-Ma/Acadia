#include "stdio.h"
#include "stdlib.h"
#include "acadia.h"

unsigned int sqmul(int base, int power, int mod, int len)
{
        int i;
        unsigned int result = 1;
        int mul;
        for (i = 0; i < len; i++)
        {
            if((power >> (len-1-i)) & 1){
                mul = 1;
            }else{
                mul = 0;
            }
            // result = __umodsi3( (result * result) , mod);
            result = (result * result) % mod;
            if (mul){
                // result = __umodsi3( (result * base) , mod);
                result =  (result * base) % mod;
            }

        }
        return result;
}

int main(){
    init_acaida_addrs();

    asm volatile ("slti x0, x0, 1");
    asm volatile ("slti x0, x0, 3");
    unsigned int res;

    for(int i = 0; i < 8; i++){
        for(int j = 0; j < 5; j++){
            for(int b = 0; b < 5; b++){
                res = sqmul(b, i, j, 1<<5);
            }
        }
    }
    asm volatile ("slti x0, x0, 4");
    asm volatile ("slti x0, x0, 2");

    // Dump Core
    *GPIO_A_OUTPUT = 0x69;
    *GPIO_A_TRISTATE = 0xFF;
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");

    return res;

}