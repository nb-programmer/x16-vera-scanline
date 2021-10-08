#include <stdio.h>
#include <cx16.h>

extern void initirq();
extern void restoreirq();
extern void initvera();

int main() {
    int i;
    char inp;

    //Initialize our custom interrupt handler
    initirq();

    //Setup VERA registers
    initvera();

    printf("***** Enter q to exit *****\n");

    //Fill the screen with some text to see the effect
    for (i=0;i<0x400;i++) printf("ABCD");

    //Wait for quit command
    while (scanf("%c", &inp))
        if (inp == 'q')
            break;

    restoreirq();

    return 0;
}