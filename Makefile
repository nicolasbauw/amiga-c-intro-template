CC = vc
CFLAGS = -c99 +aos68km -I$(NDK_INC)
LDFLAGS = -lamiga -lauto

all:
	$(CC) $(CFLAGS) -o intro main.c modplay.c $(LDFLAGS)

clean:
	rm intro
