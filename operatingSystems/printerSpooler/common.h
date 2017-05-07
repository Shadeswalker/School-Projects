#ifndef _INCLUDE_COMMON_H_
#define _INCLUDE_COMMON_H_

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

// from `man shm_open`
#include <sys/mman.h>
#include <sys/stat.h>        /* For mode constants */
#include <fcntl.h>           /* For O_* constants */
#include <signal.h>
#include <semaphore.h>

#define MY_SHM "/PRINTERSPOOL"
#define BUFFER_SIZE 10
#define BUFFER_COUNT (BUFFER_SIZE + 1)


typedef struct {
    int duration;
    int id;
    int source;
} Jobs;

typedef struct {
    sem_t mutex;
    sem_t full;
    sem_t empty;

    int nmbOfServers, nmbOfClients;

    Jobs buffer[BUFFER_SIZE];			//buffer is a queue(circular array)
    int queueIn, queueOut;
} Shared;

#endif //_INCLUDE_COMMON_H_

