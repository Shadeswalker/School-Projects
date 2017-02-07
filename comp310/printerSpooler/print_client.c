#include "common.h"

int fd;
Shared* shared_mem;

FILE * hist;

//====================================SHAREDMEMORY_SETUP===========================
int setup_shared_memory(){
    fd = shm_open(MY_SHM, O_RDWR, S_IRWXU);
    if(fd == -1){
        printf("shm_open() failed\n");
        exit(1);
    }
}

int attach_shared_memory(){
    shared_mem = (Shared*) mmap(NULL, sizeof(Shared), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if(shared_mem == MAP_FAILED){
        printf("Client mmap() failed\n");
        exit(1);
    }

    return 0;
}

// =================================BUFFER_HANDLING=================================
int put_a_job(Jobs new_job) {
	if(shared_mem->queueIn == (( shared_mem->queueOut - 1 + BUFFER_COUNT) % BUFFER_COUNT)) {
		printf("SEMAPHORE NOT WORKING\n");
		return -1; /* Queue Full*/
	}

	shared_mem->buffer[shared_mem->queueIn] = new_job;
	shared_mem->queueIn = (shared_mem->queueIn + 1) % BUFFER_COUNT;
	return 0;
}

//==================================================================================

int main(int argc, char *argv[]) {
	if (argc != 2){
		printf("Wrong number of arguments. Only enter duration as first argument.\n");
		return -1;
	}
    
    setup_shared_memory();
    attach_shared_memory();

    hist = fopen ("history_log.txt", "a");
    Jobs job;
    job.duration = atoi(argv[1]);
    job.id = getpid();
    job.source = ++(shared_mem->nmbOfClients);

    sem_wait(&shared_mem->empty);
    sem_wait(&shared_mem->mutex);

    fprintf(hist,"Client %d has %d pages to print, puts request in Buffer.\n", job.source,job.duration);
    fclose(hist);
    put_a_job(job);

    sem_post(&shared_mem->mutex);
    sem_post(&shared_mem->full);
    
    munmap(shared_mem, sizeof(Shared));

    return 0;
}
