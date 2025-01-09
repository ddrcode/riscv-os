#ifndef PLIC_H
#define PLIC_H

#include "types.h"

int plic_init(void);
int plic_set_treshold(int treshold);
int plic_enable_irq(int irq, int priority);
int plic_get_source_id(void);
int plic_complete(int irq);

#endif
