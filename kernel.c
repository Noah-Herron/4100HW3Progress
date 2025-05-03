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
int main(void) {
 
    create_process(p1);
    create_process(p2);
    create_process(p3);
    create_process(p4);

    go();

	return 0;
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
        dispatch();
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
        dispatch();
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
        dispatch();
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
        dispatch();
    }
    return 0;
}
