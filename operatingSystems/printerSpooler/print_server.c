#include "common.h"
#include <unistd.h>

int fd;
Shared* shared_mem;
int firstPrinterFlag = 0;
int pastFullFlag = 0;
int pastMutexFlag = 0;
int printerID;

FILE * hist;

//====================================SHAREDMEMORY_SETUP===========================
int setup_shared_memory(){
    fd = shm_open(MY_SHM, O_CREAT | O_EXCL, S_IRWXU);
    if(fd == -1){
    	fd = shm_open(MY_SHM, O_RDWR, S_IRWXU);
    } else {
    	firstPrinterFlag = 1;
	    fd = shm_open(MY_SHM, O_RDWR, S_IRWXU);
	    if(fd == -1){
	        printf("shm_open() failed\n");
	    	exit(1);
		}
    ftruncate(fd, sizeof(Shared));
    }
}

int attach_shared_memory(){
    shared_mem = (Shared*)  mmap(NULL, sizeof(Shared), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if(shared_mem == MAP_FAILED){
        printf("Printer mmap() failed\n");
        exit(1);
    }

    return 0;
}

//==============================BUFFER_INITIALIZING================================
int init_shared_memory() {
	remove("history_log.txt");
	shared_mem->nmbOfServers = 1;
	shared_mem->nmbOfClients = 0;
    shared_mem->queueOut = 0;
    shared_mem->queueIn = 0;
    sem_init(&(shared_mem->mutex), 1, 1);
    sem_init(&(shared_mem->empty), 1, 10);
    sem_init(&(shared_mem->full), 1, 0);
}

//=================================BUFFER_HANDLING=================================
Jobs take_a_job() {
	if(shared_mem->queueIn == shared_mem->queueOut) {
		printf("SEMAPHORE NOT WORKING\n");
		exit(0); /* Queue Empty - nothing to get - abort*/
	}

	Jobs old_job = shared_mem->buffer[shared_mem->queueOut];
	shared_mem->queueOut = (shared_mem->queueOut + 1) % BUFFER_COUNT;
	return old_job;
}

//===============================CRASH_HANDLER=====================================
void handler(int signo){
	hist = fopen ("history_log.txt", "a");
	fprintf(hist,"\n=====/!\\=====Printer %d has quit=====/!\\=====\n\n", printerID);
	fclose(hist);

	if (shared_mem->nmbOfServers == 1){
		munmap(shared_mem, sizeof(Shared));			//unmap server from shared mem
		if(shm_unlink(MY_SHM) == -1)				//if it's the last server, also unlink shared_memory
			perror("Unlink failed...");
		exit(0);
	} else {										//if there are other printers running
		shared_mem->nmbOfServers--;
		if(pastFullFlag)
			sem_post(&shared_mem->full);
		if(pastMutexFlag)
			sem_post(&shared_mem->mutex);

		munmap(shared_mem, sizeof(Shared));			//unmap server from shared mem
		exit(0);
	}
}
//=================================================================================

int main() {
	if(signal(SIGINT, handler) == SIG_ERR)
    	printf("Signal Handler Failure ..\n");

    setup_shared_memory();
    attach_shared_memory();

    if(firstPrinterFlag){
    	init_shared_memory();
    }else{
    	shared_mem->nmbOfServers++;
    }

    Jobs job;
    printerID = shared_mem->nmbOfServers;
    int temp;
    
	while (1){
		sem_getvalue(&shared_mem->full, &temp);
		if(temp == 0){							//only print sleeping action when buffer is empty
			hist = fopen ("history_log.txt", "a");
			fprintf(hist, "=========================================\n");
			fprintf(hist, "No requests in buffer, Printer %d sleeps.\n", printerID);
			fprintf(hist, "-----------------------------------------\n\n");
			fclose(hist);
		}

		sem_wait(&shared_mem->full);
		pastFullFlag = 1;
		sem_wait(&shared_mem->mutex);
		pastMutexFlag = 1;

		job = take_a_job();

		hist = fopen ("history_log.txt", "a");
		fprintf(hist,"Job ID: %d, Source: %d, Duration: %d\n\n", job.id,job.source,job.duration);
		fprintf(hist,"Printer %d starts printing %d pages\n\n", printerID,job.duration);
		fclose(hist);

		sem_post(&shared_mem->mutex);
		pastMutexFlag = 0;
		sem_post(&shared_mem->empty);
		pastFullFlag = 0;

		sleep(job.duration);
		hist = fopen ("history_log.txt", "a");
		fprintf(hist,"Printer %d finishes printing %d pages\n\n", printerID,job.duration);
		fclose(hist);
    }

    munmap(shared_mem, sizeof(Shared));

    return 0;
}
