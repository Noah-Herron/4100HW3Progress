#ifndef PROCESS_H
#define PROCESS_H
#include <stdint.h>

int create_process(int (*pfun)());

typedef struct PCB PCB_t;
struct PCB {
    uint64_t sp;  
    uint64_t iaddr; 
    uint32_t pid; 
    PCB_t *next;
};

typedef struct PCB_Q PCB_Q_t;
struct PCB_Q {
    PCB_t *head;
    PCB_t *tail;
};
#endif