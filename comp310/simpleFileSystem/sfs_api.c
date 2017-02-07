//Author: Arjun B. Gupta
//ID: 260623737

//UNCOMMENT PRINT STATEMENTS IN READ AND WRITE TO GET INFO AND OUTPUT
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sfs_api.h"
#include "disk_emu.h"

#define FILESYSTEM "arjun.disk"
#define FILESYSTEM_SIZE 8291			//1024 bytes (Hold bitmap in 1 block) * 8 = 8192 bits mapping to 8192 blocks
#define BLOCK_SIZE 1024					//Blocks of 1024 bytes
#define MAX_FD 96						//Max number of files the test will attempt to open or create
#define FIRST_DB 99						//First datablock (1 superblock + 1 nitmap block + 97 inodes)

typedef struct SuperBlock {
	int magic;
	int blockSize;
	int fs_size;
	int nmbOfInodes;
	int root_inode;
} superblock;

typedef struct INodes {
	int mode;
	int uid;
	int gid;
	int size;
	int pointer[12];
	int indirect_pntr; 
} inode;

typedef struct Directory {
	char fname[28];					//20 char + null char
	int inode;
} dir;

typedef struct FileDescriptors {
	int flag;						//is the file descriptor empty?
	int inode;
	int rptr;
	int wptr;
} fd;

void *buffer;						//Buffer of size 1 block
superblock sb;						//superblock of size 1 block
unsigned int bitmap[256];			//free bit map (size of a block)
inode inode_table[MAX_FD+1];		//inode table of size nmb of max files + 1 (for root dir)
dir root[MAX_FD];
fd fd_table[MAX_FD];				//file descriptor table of size nmb of max files
int next_file = 0;

//=======================================================================================
//==============================SECONDARY API FUNCTIONS==================================
//=======================================================================================
int get_first_freeblock() {
	int bitmap_x, bitmap_y;
	for (bitmap_x = 0; bitmap_x < 256; bitmap_x++){
		for (bitmap_y = 0; bitmap_y < 32; bitmap_y++){
			if ((bitmap[bitmap_x] & (1<<bitmap_y)) > 0) {
				bitmap[bitmap_x] = bitmap[bitmap_x] ^ (1<<bitmap_y);
				return ((bitmap_x * 32 + bitmap_y) + FIRST_DB); //first free datablock
			}
		}
	}
	printf("/!\\ NO MORE SPACE ON DISK /!\\ \n");
	return 0;
}

void free_bitmap(int block){
	block -= FIRST_DB;
	int bitmap_x, bitmap_y;
	bitmap_x = block / 32;
	bitmap_y = block % 32;
	bitmap[bitmap_x] = bitmap[bitmap_x] | (1<<bitmap_y);
}

//Checks if pointer_index is initialized, and if it isn't it initializes it to the first free block
//returns -1 if failure, and block number in the sfs on success
int fetch_block(int inode, int pointer_index){
	int freeblock;
	//Procedure for direct pointers
	if (pointer_index < 12){
		if (inode_table[inode].pointer[pointer_index] == -1){	//if the pointer is NOT initialized
			freeblock = get_first_freeblock();
			if(freeblock){
				inode_table[inode].pointer[pointer_index] = freeblock;	//initialize to first free block
			} else {
				return -1;
			}
		}
		return inode_table[inode].pointer[pointer_index];
	//Procedure for indirect pointers
	} else if (pointer_index < 268){		//256 indirect pointers  + 12 direct = 268
		int indir_ptr[256];
		//If indirect pointer block is not initialized
		if (inode_table[inode].indirect_pntr == -1){
			freeblock = get_first_freeblock();
			if(freeblock){
				inode_table[inode].indirect_pntr = freeblock;	//initialize indirect pointer to first free block
				//initialize all indirect pointer to -1
				for (int i = 0; i < 256; i++){
					indir_ptr[i] = -1;
				}
				write_blocks(inode_table[inode].indirect_pntr, 1, indir_ptr);	//flush the indirect pointer block
			} else {
				return -1;
			}
		}
		//fetch the indirect pointer
		read_blocks(inode_table[inode].indirect_pntr,1,indir_ptr);
		int indir_ptr_index = pointer_index - 12;
		if (indir_ptr[indir_ptr_index] == -1){		//if the indirect pointer is not initialized
			freeblock = get_first_freeblock();
			if (freeblock){
				indir_ptr[indir_ptr_index] = freeblock;		//initialize to first free block
				write_blocks(inode_table[inode].indirect_pntr, 1, indir_ptr);	//flush the indirect pointer block
			} else {
				return -1;
			}
		}
		return indir_ptr[indir_ptr_index];
	//Pointer out of bound
	} else {
		printf("File too large, cannot initialize new pointer\n");
		return -1;
	}
}

int find_first_free_fd() {
	int index = 0;
	while (fd_table[index].flag != 1){
		if (index == MAX_FD){			//fd_table full, cannot open or add a new file
			printf("File limit reached, could not open or create new file\n");
			return -1;
		}
		index++;
	}
	return index;
}
int find_first_free_dir() {
	int index = 0;
	while (strcmp("",root[index].fname) != 0){
		if (index == MAX_FD){			//directory full, cannot add a new file
			printf("File limit reached, could not open or create new file\n");
			return -1;
		}
		index++;
	}
	return index;
}

int flush_to_disk(int file_inode, int options) {
	/*OPTIONS:
	(0) Flush everything (Bitmap Table, Root Directory table, Inode of specified file) to the disk
	(1) Flush Root Directory and Inode of specified file to the disk
	(2) Flush Bitmap table and Inode of specified file*/
	buffer = (void*) malloc(BLOCK_SIZE);
	//Flushing Inode
	memcpy(buffer, &(inode_table[file_inode]), sizeof(inode));
	write_blocks(file_inode+2, 1, buffer);
	free(buffer);

	if (options == 0){
		//Flushing root directory table
		buffer = (void*) malloc(BLOCK_SIZE*3);
		memset(buffer,0,BLOCK_SIZE*3);
		memcpy(buffer, &root, 3*BLOCK_SIZE);
		write_blocks(MAX_FD+3, 3, buffer);
		free(buffer);
		//Flushing bit map table
		buffer = (void*) malloc(BLOCK_SIZE);
		memcpy(buffer, &bitmap, BLOCK_SIZE);
		write_blocks(1, 1, buffer);
		free(buffer);
		return 0;
	} else if (options == 1){
		//Flushing root directory table
		buffer = (void*) malloc(BLOCK_SIZE*3);
		memset(buffer,0,BLOCK_SIZE*3);
		memcpy(buffer, &root, 3*BLOCK_SIZE);
		write_blocks(MAX_FD+3, 3, buffer);
		free(buffer);
		return 0;
	} else if (options == 2){
		//Flushing bit map table
		buffer = (void*) malloc(BLOCK_SIZE);
		memcpy(buffer, &bitmap, BLOCK_SIZE);
		write_blocks(1, 1, buffer);
		free(buffer);
		return 0;
	} else{
		printf("Please specify option 1, 2, or 3\n");
		return -1;
	}
}

int check_open(int fileID){
	if ((fileID < 0) || (fileID >= MAX_FD)){
		printf("FileID out of bound\n");
		return 0;
	}
	if (fd_table[fileID].flag == 1){
		printf("No open file in fd_table at fileID\n");
		return 0;
	} else {
		return fd_table[fileID].inode;			//return inode number linked to the fileID
	}											//IMPORTANT: 0 can't be returned since it's the root dir inode
}



//=======================================================================================
//==============================PRIMARY API FUNCTIONS====================================
//=======================================================================================
void mksfs(int fresh){
	buffer = (void*) malloc(BLOCK_SIZE);
	memset(buffer,0,BLOCK_SIZE);
	if (fresh){							//FORMAT VIRTUAL DISK, CREATE NEW FROM SCRATCH
		init_fresh_disk(FILESYSTEM, BLOCK_SIZE, FILESYSTEM_SIZE);
		//=========Storing sb in-memory===========
		sb = (superblock){0, BLOCK_SIZE, FILESYSTEM_SIZE, MAX_FD, 0};
		memcpy(buffer, &sb, sizeof(superblock));

		//========Storing sb on-disk==============
		write_blocks(0, 1, buffer);
		
		//========Initializing Bitmap block=======
		unsigned int bit_row =  4294967295;		//Row consisting of 32 '1' bits
		for (int i = 0; i<256; i++){
			bitmap[i] = bit_row;					//Filling table with 1's (1 means block is free)
		}
		/*We use the first 3 blocks to store the Root Directory mapping table*/
		bitmap[0] = bitmap[0] << 3;
		write_blocks(1, 1, bitmap);
		
		//========Storing inode table on-disk=====
		//inode inode_table[MAX_FD+1];
		for (int i = 0; i <= MAX_FD; i++){
			inode_table[i] = (inode){0, 1, 1, 0, {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}, -1};
			if (i == 0)	{	//First inode is root dir inode.
				//It spans 3 blocks of data -> first three blocks in the datablock section
				inode_table[i] = (inode){0,1,1,3,{FIRST_DB,FIRST_DB+1,FIRST_DB+2,-1,-1,-1,-1,-1,-1,-1,-1,-1},-1};
			}
			memcpy(buffer, &(inode_table[i]), sizeof(inode));
			write_blocks(i+2, 1, buffer);
		}
		//====Initializing rootdir in-memory======
		for (int i = 0; i < MAX_FD; i++){
			root[i] = (dir){"", -1};
		}
		//====Initializing rootdir on-disk========
		free(buffer);
		buffer = (void*) malloc(BLOCK_SIZE*3);
		memset(buffer,0,BLOCK_SIZE*3);
		memcpy(buffer, &root, 3*BLOCK_SIZE);
		write_blocks(MAX_FD+3, 3, buffer);

		//====Initializing fd table in-memory=====
		for (int i = 0; i < MAX_FD; i++)
			fd_table[i] = (fd){1,-1,-1,-1};			//mark all entries in fd_table as empty (flag = 1 means empty)
	} else {
		init_disk(FILESYSTEM, BLOCK_SIZE, FILESYSTEM_SIZE);
	}
	free(buffer);
}

int sfs_get_next_file_name(char *fname){
	while (next_file < MAX_FD){
		if (strcmp(root[next_file].fname, "")){
			strcpy(fname, root[next_file].fname);
			next_file++;
			return 1;
		}
		next_file++;
	}
	next_file = 0;
	return 0;
}

int sfs_get_file_size(char* path){
	int inode_index = -1;
	for (int i = 0; i < MAX_FD; i++){
		if (strcmp(path, root[i].fname) == 0){
			inode_index = root[i].inode;
			break;
		}
	}
	if (inode_index == -1) {
		printf("No file found\n");
		return -1;
	}
	return inode_table[inode_index].size;
}

int sfs_fopen(char *name){
	int index = -1;
	int fd_index;
	for (int i = 0; i < MAX_FD; i++){
		if (strcmp(name, root[i].fname) == 0){
			index = i;							//matching file with index i
		}
	}
	if (index >= 0) {		//we found a file with matching name in the root_directory at index "index"
		for (int i = 0; i < MAX_FD; i++){		//Let's check if we have a file already open linked to the same inode
			if (root[index].inode == fd_table[i].inode) { //if we find an open file with same inode as the matched file
				printf("Note: file was already opened\n");
				return index;					//Then the file is already open, still return the file descriptor index
			}
		}
		fd_index = find_first_free_fd();	//file isn't open, so we open it at first empty spot in fd_table
		if (fd_index < 0){
			return -1;
		} else {
			//Set flag to 0, inode number, rptr to 0 (bginning of file) and wptr to the size of the file
			fd_table[fd_index] = (fd){0,root[index].inode,0,inode_table[(root[index].inode)].size};
			return fd_index;
		}
	} else { 			//No file has this name so create a new file and open it
		fd_index = find_first_free_fd();
		if (fd_index<0) {
			return -1;
		} else {
			//Found an empty index in which we can create new file
			//We assume the file name given is composed only of letters and has at most 1 '.'
			if (strlen(name) > 20){
				printf("File name too large, can be maximum 20 characters\n");
				return -1;
			}
			char *extension = strchr(name, '.');
			int extension_length = strlen(extension);
			if ((extension == NULL) || (extension_length <= 4)) {
				int dir_index = find_first_free_dir();
				if (dir_index < 0)
					return -1;
				//========UPDATING ROOT DIRECTORY, LINKING FILE TO NEW INODE, LINKING FILE TO FD_TABLE===========
				strcpy(root[dir_index].fname,name);
				root[dir_index].inode = dir_index+1;			//first inode is taken by root directory
				inode_table[dir_index+1] = (inode){777, 1, 1, 0, {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}, -1};
				fd_table[fd_index] = (fd){0, dir_index+1, 0, 0};

				flush_to_disk(root[dir_index].inode, 1);
				return fd_index;
			}
			return -1;
		}
	}
}

int sfs_fclose(int fileID){
	if (check_open(fileID)){
		fd_table[fileID] = (fd){1,-1,-1,-1};
		return 0;
	} else {
		return -1;
	}
}

int sfs_frseek(int fileID, int loc){
	if (check_open(fileID)){
		if ((loc<0) || (loc >= inode_table[(fd_table[fileID].inode)].size )) {
			if ((loc==0) && (inode_table[(fd_table[fileID].inode)].size == 0)){
				fd_table[fileID].rptr = loc;
				return 0;
			}
			return -1; //if the pointer is negative or greater than the file size
		} else {
			fd_table[fileID].rptr = loc;
			return 0;
		}
	} else {
		return -1;
	}
}

int sfs_fwseek(int fileID, int loc){
	if (check_open(fileID)){
		if ((loc<0) || (loc >= inode_table[(fd_table[fileID].inode)].size)) {
			if ((loc==0) && (inode_table[(fd_table[fileID].inode)].size == 0)){
				fd_table[fileID].wptr = loc;
				return 0;
			}
			return -1; //if the pointer is negative or greater than the file size
		} else {
			fd_table[fileID].wptr = loc;
			return 0;
		}
	} else {
		return -1;
	}
}

int sfs_fwrite(int fileID, char *buf, int length){
	if (check_open(fileID) == 0){
		printf("Can't write, file not opened\n");
		return -1;
	}
	//SETTING UP META INFO FOR EASY ACCESS
	buffer = (void*) malloc(BLOCK_SIZE);
	int blk_inode = fd_table[fileID].inode;			//inode index of file we are writing in
	int current_size = inode_table[blk_inode].size;	//file size in bytes
	int write_ptr = fd_table[fileID].wptr;			//write pointer in bytes
	int blk_offset = write_ptr % BLOCK_SIZE;		//offset in bytes of the wptr within the first block
	int blk_index = write_ptr / BLOCK_SIZE;			//inode pointer of first block we start to write in

	//get block number where wptr is located within sfs
	int block_nmb = fetch_block(blk_inode, blk_index);		//get the block number in the sfs
	if (block_nmb == -1){
		return -1;
	}

	//GETTING THE BLOCK WHERE WPTR IS
	read_blocks(block_nmb,1,buffer);						//read what's already on the block

	/*printf("WPTR AT: %d\n", write_ptr);
	printf("File size before read: %d\n", current_size);
	printf("current_size: %d\n", current_size);
	printf("Write pointer + length: %d\n", write_ptr + length);*/
	//UPDATING INODE SIZE
	if (current_size <  write_ptr + length) {
		inode_table[blk_inode].size = write_ptr + length;
	}
	fd_table[fileID].wptr = write_ptr + length;
	//==========================if the data WILL NOT overflow to next block========================
	if (blk_offset + length < BLOCK_SIZE) {
		memcpy((buffer+blk_offset),buf,length);		//write the whole block with added data in buffer

		//WRITE THE BLOCK ON DISK
		write_blocks(block_nmb, 1, buffer);

	//==========================if the data WILL overflow to next block=============================
	} else {
		int nmb_of_bytes_copied = 0;

		//WRITING THE FIRST BLOCK
		memcpy(buffer+blk_offset,buf,(BLOCK_SIZE-blk_offset));	//write the whole block with added data in buffer
		nmb_of_bytes_copied += BLOCK_SIZE - blk_offset;

		//(1) WRITE THE FIRST BLOCK ON DISK
		write_blocks(block_nmb, 1, buffer);
		blk_index++;

		//(2) WRITE THE FULL BLOCKS
		int nmb_of_fullblocks = (length - (BLOCK_SIZE-blk_offset)) / BLOCK_SIZE;
		for (int i = 0; i < nmb_of_fullblocks; i++){
			memcpy(buffer,(buf+nmb_of_bytes_copied),BLOCK_SIZE);
			nmb_of_bytes_copied += BLOCK_SIZE;

			block_nmb = fetch_block(blk_inode, blk_index);		//get the block number in the sfs
			if (block_nmb == -1){
				return -1;
			}
			write_blocks(block_nmb, 1, buffer);
			blk_index++;
		}

		//(3) WRITE LAST BLOCK
		memcpy(buffer,(buf+nmb_of_bytes_copied),(length-nmb_of_bytes_copied));
		block_nmb = fetch_block(blk_inode, blk_index);		//get the block number in the sfs
		if (block_nmb == -1){
			return -1;
		}
		write_blocks(block_nmb, 1, buffer);
	}
	
	//printf("Length written: %d\n", length);
	//printf("File size after read: %d\n", inode_table[blk_inode].size);

	//END THE WRITE
	free(buffer);
	flush_to_disk(blk_inode, 2);		//flushing with option 2
	return length;
}

int sfs_fread(int fileID, char *buf, int length){
	if (check_open(fileID) == 0){
		printf("Can't write, file not opened\n");
		return -1;
	}
	//SETTING UP META INFO FOR EASY ACCESS
	int blk_inode = fd_table[fileID].inode;			//inode index of file we are reading from
	int read_ptr = fd_table[fileID].rptr;			//read pointer in bytes
	int blk_offset = read_ptr % BLOCK_SIZE;			//offset in bytes of the wptr within the first block
	int blk_index = read_ptr / BLOCK_SIZE;			//inode pointer of first block we start to read from
	int block_nmb;

	/*printf("===================================\n");
	printf("Read Pointer is at : %d\n", read_ptr);
	printf("Length taken as argument: %d\n", length);
	printf("File size: %d\n", inode_table[blk_inode].size);*/

	if (inode_table[blk_inode].size == 0){
		printf("File is empty, nothing to read\n");
		free(buffer);
		return 0;
	}
	if ((read_ptr + length) > inode_table[blk_inode].size) {
		length = inode_table[blk_inode].size - read_ptr;
	}
	
	buffer = (void*) malloc(BLOCK_SIZE);
	int nmb_of_bytes_read = 0;
	block_nmb = fetch_block(blk_inode, blk_index);
	//====================if the data we want to read is less than a block========================
	if ((blk_offset + length) < BLOCK_SIZE){
		read_blocks(block_nmb,1,buffer);
		memcpy(buf, (buffer+blk_offset), length);	//copy to buf only starting from offset
		nmb_of_bytes_read += length;
	
	//====================if the data we want to read is more than a block========================
	}else{
		// (1) READING REST OF FIRST BLOCK WHERE RPTR IS TO BUFFER
		read_blocks(block_nmb,1,buffer);
		memcpy(buf, (buffer+blk_offset), (BLOCK_SIZE - blk_offset));	//copy to buf only starting from offset
		blk_index++;

		nmb_of_bytes_read += BLOCK_SIZE - blk_offset;
		// (2) READING THE FULL BLOCKS
		int nmb_of_fullblocks = (length - (BLOCK_SIZE - blk_offset)) / BLOCK_SIZE;
		for (int i = 0; i < nmb_of_fullblocks; i++){
			block_nmb = fetch_block(blk_inode, blk_index);
			read_blocks(block_nmb,1,buffer);
			memcpy((buf + nmb_of_bytes_read),buffer,BLOCK_SIZE);
			nmb_of_bytes_read += BLOCK_SIZE;
			blk_index++;
		}

		// (3) READING THE LAST BLOCK
		block_nmb = fetch_block(blk_inode, blk_index);
		read_blocks(block_nmb,1,buffer);
		memcpy(buf + nmb_of_bytes_read, buffer, length - nmb_of_bytes_read);
		nmb_of_bytes_read += length - nmb_of_bytes_read;
	}

	//printf("Number of bytes read: %d\n", nmb_of_bytes_read);
	//printf("\nIn buf:\n%s\n", buf);

	//END THE READ
	//printf("String Length:%lu\n", strlen(buf));
	//printf("Length:%d\n", length);
	free(buffer);
	return length;
}

int sfs_remove(char *file){
	int index = -1;
	for (int i = 0; i < MAX_FD; i++){
		if (strcmp(file, root[i].fname) == 0){
			index = i;							//matching file with index i
		}
	}

	//If there is no file with that name
	if (index < 0){
		printf("No file to remove\n");
		return 0;

	//If there is a file with that name	
	} else {
		int inode_indx = root[index].inode;
		int block_location;
		if (inode_table[inode_indx].size > 0){	//if there are some blocks to free
			//Number of blocks the file spans across:
			int nmb_of_blocks = (inode_table[inode_indx].size / BLOCK_SIZE) + 1; 
			for (int i = 0; i<nmb_of_blocks; i++){
				block_location = fetch_block(inode_indx,i);
				free_bitmap(block_location);
			}
		}
		//CLOSE IF FILE IS OPEN
		for (int i = 0; i < MAX_FD; i++){		//check if we have a file opened linked to the same inode
			if (inode_indx == fd_table[i].inode) { //if we find an open file with same inode as the matched file
				sfs_fclose(i);
			}
		}
		//REMOVE FROM ROOT DIRECTORY
		root[index] = (dir){"", -1};
		//REINITIALIZE INODE
		inode_table[inode_indx] = (inode){0, 1, 1, 0, {-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1}, -1};
		//FLUSH
		flush_to_disk(inode_indx, 0);
		return 0;
	}
}