CC = vc
AS = vasmm68k_mot
CFLAGS = -c99 +aos68km
LDFLAGS = -lamiga -lauto

all: ptreplay.o
	$(CC) $(CFLAGS) -o intro main.c ptreplay.o $(LDFLAGS)

ptreplay.o:
	$(AS) -Fhunk -o ptreplay.o ptreplay.s

clean:
	rm intro ptreplay.o
