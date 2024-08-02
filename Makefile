CC = vc
AS = vasmm68k_mot
CFLAGS = -c99 +aos68km
LDFLAGS = -lamiga -lauto

all: ptreplay.o module.o
	$(CC) $(CFLAGS) -o intro main.c ptreplay.o module.o $(LDFLAGS)

ptreplay.o:
	$(AS) -Fhunk -o ptreplay.o ptreplay.s

module.o:
	$(AS) -Fhunk -o module.o module.s

clean:
	rm intro ptreplay.o module.o
