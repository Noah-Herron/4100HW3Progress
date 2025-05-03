#include "process.h"
#include "queue.h"

PCB_t *Running = 0;
PCB_Q_t ReadyQ;

void notcalled() {Running = 0;}  // quickfix dummy function to remove 
                                 //  warning the Running is not used
                                 //  it is used in process_asm.S
#define X30_OFFSET 30
#define MAX_STACKS 10
#define STACK_SIZE 2048
#define NULL 0

static uint64_t Stacks[MAX_STACKS][STACK_SIZE];
static uint32_t Next_stack = 0;
uint64_t *alloc_stack() {
    if (Next_stack >= 10) return NULL;
    return Stacks[Next_stack++];
}

#define MAX_PCBS 10
static PCB_t Pcbs[MAX_PCBS];
static uint32_t Next_pcb = 0;
PCB_t *alloc_pcb() {
    if (Next_pcb >= 10) return NULL;
    return &(Pcbs[Next_pcb++]);
}

static uint32_t Next_process = 0;

int create_process(int (*pfun)()) {
    // create the stack
    uint64_t *sp = alloc_stack();
    if (sp == NULL) return -1;
    sp += STACK_SIZE;
    for (uint64_t i = 0; i < 33; i++) {
        sp--;
        *sp = 0;
    }   
    *(sp+30) = (uint64_t) pfun;
    PCB_t *pcb = alloc_pcb();
    if (pcb == NULL) return -1;
    pcb->sp = (uint64_t) sp;
    pcb->pid = Next_process++;
    pcb->next = NULL;
    enqueue(&ReadyQ, pcb);
    return 0; 
}
