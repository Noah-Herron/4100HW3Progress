#include "libos.h"
#include "process.h"
#include <stdbool.h>

int box(unsigned int sr, unsigned int sc, unsigned int er, unsigned int ec);
int p1();
int p2();
int p3(); 
int p4();

void go();
void dispatch();

void setup_EVT();
void init_timer();
void enable_interrupts();
void disable_interrupts();
int get_el();
void unsupported_handler();

int main(void) {

    create_process(p1);
    create_process(p2);
    create_process(p3);
    create_process(p4);

    setup_EVT();
    init_timer();

    // enable_interrupts();

    go();

	return 0;
}

// void unsupported_handler() {
//     print_to(0, 0, "Error: unsupported exception!");
//     while(1); // infinite loop
// }


void unsupported_handler() {
    int el;
    asm volatile ("mrs %0, CurrentEL" : "=r" (el));
    el = (el >> 2) & 3;

    // Manually convert EL to ASCII char
    char msg[] = "Unsupported! EL = 0";
    msg[19] = '0' + el;

    print_to(0, 0, msg);
    while (1);
}

void enable_interrupts() {
    asm volatile("msr DAIFClr, #0x2");  // Enable IRQs
}


int p1() {
    box(9,23, 11, 39);
    char hello[] = "Process 1: 0";
    while (1) {
 
        print_to(10, 25, hello);
        if (hello[11] == '9')
            hello[11] = '0';
        else 
            hello[11]++;
    }
    return 0;
}

int p2() {
    box(13,23, 15, 39);
    char hello[] = "Process 2: 0";
    print_to(14, 25, hello);
    while (1) {
        putc_to(14, 36, hello[11]);
        if (hello[11] == '9')
            hello[11] = '0';
        else 
            hello[11]++;
    }
    return 0;
}

int p3() {
    box(9,49, 11, 65);
    char hello[] = "Process 3: 0";
    while (1) {
        print_to(10, 51, hello);
        if (hello[11] == '9')
            hello[11] = '0';
        else 
            hello[11]++;
    }
    return 0;
}

int p4() {
    box(13,49, 15, 65);
    char hello[] = "Process 4: 0";
    while (1) {
        print_to(14, 51, hello);
        if (hello[11] == '9')
            hello[11] = '0';
        else 
            hello[11]++;
    }
    return 0;
}
