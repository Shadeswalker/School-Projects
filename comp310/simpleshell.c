//Developer: Arjun B. Gupta
//ID : 260623737

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/wait.h>

#define HISTORY_SIZE 10
#define ARGS_ARRAY_SIZE 20
#define JOBS_ARRAY_SIZE 100


typedef struct history_t {
	char* buffer[HISTORY_SIZE][ARGS_ARRAY_SIZE];
	int currentCmd;
} History;

typedef struct joblist_t {
	char* jobs[JOBS_ARRAY_SIZE];
	pid_t pids[JOBS_ARRAY_SIZE];
} Joblist;


int getcmd(char *prompt, char *args[], int *background, int *pipe_flag, History *hist) {
	int length, i = 0, hist_flag = 0, cmd_requested = 0;
	char *token, *loc;
	char *line = (char *)malloc(sizeof(char));
	size_t linecap = 0;

	printf("%s", prompt);
	length = getline(&line, &linecap, stdin);
	
	if (length <= 0) {
		exit(-1);
	} else if (strcmp(line,"\n") == 0){
		return i;
	}

	// Check if background is specified..
	if ((loc = index(line, '&')) != NULL) {
		*background = 1;
		*loc = ' ';
	} else
		*background = 0;

	if (line[0] == '!') 
		hist_flag = 1;				//if the first char is '!' we turn hist_flag on

	while ((token = strsep(&line, " \t\n")) != NULL) {
		for (int j = 0; j < strlen(token); j++) {
			if (hist_flag){ 		//if '!' is the first char
				if ((token[j] >= 48) && (token[j] <= 57)){
					cmd_requested = cmd_requested*10 + (token[j]-48);
					//transforming an array of char into an int
				}
			}
			if (token[j] <= 32)
				token[j] = '\0';
		}
		if (hist_flag){ //procedure when user is calling command from history
			if ((cmd_requested >= hist->currentCmd) || (cmd_requested > (hist->currentCmd - 10)) ) {
				for (i = 0; (hist->buffer[((cmd_requested-1)%10)][i]) != NULL; i++){
					args[i] = hist->buffer[((cmd_requested-1)%10)][i];
					//loading requested command in args
					hist->buffer[((hist->currentCmd-1)%10)][i] = hist->buffer[((cmd_requested-1)%10)][i];
					//saving requested command at current current command in history
				}
			} else {
				printf("No command found in history.\n");
				return 0; //Doesn't save invalid history requests in history
			}
		} else if (strlen(token) > 0) {
			args[i] = token;
			hist->buffer[((hist->currentCmd-1)%10)][i] = token; //saving in history

			//when we encounter a pipe, we set the pipe flag on
			//and we replace it with a NULL to act as a reference
			if (strcmp(token, "|") == 0){
				*pipe_flag = 1;
				args[i] = NULL;
			}
			i++;
		}
	}

	hist->currentCmd++; //Doesn't save empty strings
	free(line);
	return i;
}


int main(void) {
	char *args[ARGS_ARRAY_SIZE];
	char *args1[ARGS_ARRAY_SIZE];
	char *args2[ARGS_ARRAY_SIZE];
	int bg, pipe_flag, bgProcess = 0;
	int status;
	History hist;
	Joblist joblist;
	hist.currentCmd = 1;
	int pipe_fd[2];

	while(1) {
		bg = 0, pipe_flag = 0;
		int cnt = getcmd("\n>>", args, &bg, &pipe_flag, &hist);
		args[cnt] = NULL;
		hist.buffer[(hist.currentCmd-2)%10][cnt] = NULL;


		if (args[0] == NULL){
			continue;
		}

		if (strcmp(args[0],"exit")==0)
			exit(0);

		if (strcmp(args[0],"cd")==0){
			char currentwd[1024], pastwd[1024];
			getcwd(pastwd, sizeof(pastwd));
			chdir(args[1]);
				if (strcmp(pastwd, getcwd(currentwd, sizeof(currentwd)))==0)
					printf("No such file or directory.\n");
			continue;
		}

		if (strcmp(args[0],"pwd")==0){
			char currentwd[1024];
			getcwd(currentwd, sizeof(currentwd));
			printf("%s\n", currentwd);
			continue;
		}

		//======================= jobs + fg command =============================
		if (strcmp(args[0],"jobs") == 0) {
			//CHECKING FOR DEAD PROCESS
			printf("PID\tCommand\n");
			if (bgProcess==0)
				continue;
			for (int i =0; joblist.pids[i] != -1; i++){
				//Check if the process is still running
				if (waitpid(joblist.pids[i], &status, WNOHANG) != 0) {
					//if it is, take it out and shift
					for (int j = i; joblist.pids[j] != -1; j++){
						joblist.pids[j] = joblist.pids[j+1];
						joblist.jobs[j] = joblist.jobs[j+1];
						bgProcess--;
					}
				}
			}
			//PRINTING PROCESSES
			for (int i =0; joblist.pids[i] != -1; i++){
				printf("%d\t", joblist.pids[i]);
				printf("%s\n", joblist.jobs[i]);
			}
			continue;
		}

		if (strcmp(args[0],"fg")==0){
			int nopid = 0;
			for (int id = 0; joblist.pids[id] != -1; id++)
				nopid = 1;
			if (nopid){
				waitpid(atoi(args[1]), &status, 0);
			} else {
				printf("No process to put in foreground, check argument.\n");
			}
			continue;
		}

		//======================= history command ==============================
		if (strcmp(args[0],"history")==0){
			printf("\nNumber\tCommand\n");
			if (hist.currentCmd <= 10){
				for(int y=0; y < hist.currentCmd-1; y++) {
					printf("%d\t", y+1);
					for(int z=0; hist.buffer[y][z] != NULL; z++) {
						printf("%s ", hist.buffer[y][z]);
					}
					printf("\n");
				}
			} else {
				for(int y = hist.currentCmd - 11; y < hist.currentCmd-1; y++) {
					printf("%d\t", y+1);
					for(int z=0; (hist.buffer[y%10][z]) != NULL; z++) {
						printf("%s ", hist.buffer[y%10][z]);
					}
					printf("\n");
				}
			}
			continue;
		}//=====================================================================


		pid_t pid = fork();
		
	//=========================CHILD PROCESS====================================
		if(pid == 0){
			//==========================PIPING==================================
			if (pipe_flag){
				int k, p2_start, i = 0;

				if (pipe(pipe_fd) == -1)
					exit(-1);

				for (k = 0; args[k] != NULL; k++){
					args1[k] = args[k];
				}
				args1[++k] = NULL;
				p2_start = k;
				for (k; args[k] != NULL; k++){
					args2[i++] = args[k];
				}
				args2[++k] = NULL;

				pid_t pipe_pid = fork();

				if (pipe_pid == 0) {				//CHILD
					close(1);
					dup(pipe_fd[0]);
					execvp(args1[0], args1);
				} else {							//PARENT
					waitpid(pipe_pid, &status, 0);
					close(0);
					dup(pipe_fd[1]);
					execvp(args2[0], args2);
				}
				exit(0);
			}
			//=====================OUTPUT REDIRECTION===========================
			if ((cnt > 2) && (strcmp(">", args[cnt-2]) == 0)){
				close(1);
				int file = open(args[cnt-1], O_RDWR|O_CREAT, S_IRWXU);
				if (file < 0)
					exit(-1);
				args[cnt-2] = NULL;
			}
			execvp(args[0], args);
			exit(0);


	//=======================PARENT PROCESS=====================================
		} else if(bg == 0) {				//waits if the bg flag isn't set
			waitpid(pid, &status, 0);
		} else {							//else continues without waiting
			joblist.jobs[bgProcess] = args[0];
			joblist.pids[bgProcess++] = pid;
			joblist.pids[bgProcess] = -1;
		}
	}
}