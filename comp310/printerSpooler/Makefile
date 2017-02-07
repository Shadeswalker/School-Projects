LIBS := -lrt -lpthread

all: server client

server: print_server.c
	gcc $^ -o $@ $(LIBS)

client: print_client.c
	gcc $^ -o $@ $(LIBS)

clean:
	-rm server client
