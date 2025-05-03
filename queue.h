#ifndef QUEUE_H
#define QUEUE_H
#include "process.h"
void enqueue(PCB_Q_t *q, PCB_t *pcb);
PCB_t *dequeue(PCB_Q_t *q);
#endif

