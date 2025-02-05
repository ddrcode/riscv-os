#ifndef FILE_H
#define FILE_H

#include "types.h"

typedef struct {
    u32 id;
    u32 size;
    u8 flags;
    char name[30];
} FileInfo;


u32 file_scan_dir(int (*callback)(FileInfo*), void*);

int file_find(char* fname);

#endif
