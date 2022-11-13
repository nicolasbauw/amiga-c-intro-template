# C template for Amiga intros

To use with the VBCC compiler (see my [installation script](https://github.com/nicolasbauw/Amiga-cc)). Provides startup and system restore code, copperlist setup, and also module replay¹ and VBL interrupts as features you can activate or not.

For kickstart 1.3, replace +aos68km with +kick13m in the makefile.

The make_adf.sh creates a bootable floppy to allow you to test your code in an emulator (you will need [xdftool](https://amitools.readthedocs.io/en/latest/tools/xdftool.html)), but for now I can't get the intro to work directly from the floppy, you will have to copy the files on a hard drive.

Compiled with module replay and VBL features, the executable weighs 1256 bytes.

## Notes
¹ Use [PTReplay v7 library](https://www.pouet.net/prod.php?which=82170) by Mattias Karlsson Andreas Pålsson and StingRay.
