#include "queue.h"

#define NULL 0
void enqueue(PCB_Q_t *q, PCB_t *pcb) {
    pcb->next = NULL;
    if (q->tail == NULL) {
        q->head = q->tail = pcb;
    } else {
        q->tail->next = pcb;
        q->tail = pcb;
    }
}
PCB_t *dequeue(PCB_Q_t *q) {
    PCB_t *temp = NULL;
    if (q->head == NULL)
        return NULL;        
    
    temp = q->head;
    if (q->head == q->tail)
        q->head = q->tail = NULL;
    else
        q->head = q->head->next;
    return temp;
}