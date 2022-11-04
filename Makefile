CC = vc
CFLAGS = -c99 +kick13m
LDFLAGS = -lamiga -lauto

all:
	$(CC) $(CFLAGS) -o intro main.c $(LDFLAGS)

clean:
	rm intro
