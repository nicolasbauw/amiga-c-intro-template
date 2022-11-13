CC = vc
CFLAGS = -c99 +aos68km
LDFLAGS = -lamiga -lauto

all:
	$(CC) $(CFLAGS) -o intro main.c $(LDFLAGS)

clean:
	rm intro
