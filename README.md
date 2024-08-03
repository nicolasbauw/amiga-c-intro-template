# Amiga C template for hardware screen setup and module replay

To use with the VBCC compiler (see my [installation script](https://github.com/nicolasbauw/Amiga-cc)). Provides startup and system restore code, copperlist setup, and also module replay and VBL interrupts.

For kickstart 1.3, replace +aos68km with +kick13m in the makefile.

The make_adf.sh creates a bootable floppy to allow you to test your code in an emulator (you will need [xdftool](https://amitools.readthedocs.io/en/latest/tools/xdftool.html)).

Another easy way to test your code is to slide your file in the [vAmigaweb](https://vamigaweb.github.io/) emulator.
