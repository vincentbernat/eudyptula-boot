eudyptula-boot
==============

`eudyptula-boot` boots a Linux kernel in a VM without a dedicated root
filesystem. The root filesystem is the underlying root filesystem (or
some pre-built chroot). This is a convenient way to do quick tests
with a custom kernel.

The name comes from [Eudyptula][] which is a genus for penguins. This
is also the name of a [challenge for the Linux kernel][].

This utility is aimed at development only. This is a hack. It relies
on AUFS and 9P to build the root filesystem from the running system.

[Eudyptula]: http://en.wikipedia.org/wiki/Eudyptula
[challenge for the Linux kernel]: http://eudyptula-challenge.org/

Usage
-----

You need to have a kernel with AUFS enabled. This is not the case of
vanilla kernels. Ubuntu and Debian kernels are patched to support
AUFS. If you need to develop from a vanilla kernel, you can either
apply AUFS patches or use the [AUFS git tree][].

[AUFS git tree]: git://github.com/sfjro/aufs3-linux.git

Ensure you have the following options enabled (as a module or builtin):

    CONFIG_9P_FS=y
    CONFIG_AUFS_FS=y
    CONFIG_NET_9P=y
    CONFIG_NET_9P_VIRTIO=y
    CONFIG_VIRTIO=y
    CONFIG_VIRTIO_PCI=y

Once compiled, the kernel needs to be installed in some work directory:

    $ make modules_install install INSTALL_MOD_PATH=$WORK INSTALL_PATH=$WORK

Then, boot your kernel with:

    $ eudyptula-boot vmlinuz-3.15.0~rc5-02950-g7e61329b0c26

Any additional parameters will be given to the kernel until the first
occurrence of `--`. Remaining arguments will be given to KVM. For example:

    $ eudyptula-boot /vmlinuz cgroup_enable=memory -- -usb

Before booting the kernel, the path to GDB socket will be
displayed. You can use it by running gdb on `vmlinux` (which is
somewhere in the source tree):

    $ gdb vmlinux
    GNU gdb (GDB) 7.4.1-debian
    Reading symbols from /home/bernat/src/linux/vmlinux...done.
    (gdb) target remote | socat UNIX:/path/to/vm-eudyptula-gdb.pipe -
    Remote debugging using | socat UNIX:/path/to/vm-eudyptula-gdb.pipe -
    native_safe_halt () at /home/bernat/src/linux/arch/x86/include/asm/irqflags.h:50
    50  }
    (gdb)

A serial port is also exported. It can be convenient for remote
debugging of userland processes. More details can be found in this
[blog post][] (which also covers debugging the kernel).

[blog post]: http://vincent.bernat.im/en/blog/2012-network-lab-kvm.html

QEMU monitor is also attached to a UNIX socket. You can use the
following command to interact with it:

    $ socat - UNIX:/path/to/vm-eudyptula-console.pipe
    QEMU 2.0.0 monitor - type 'help' for more information
    (qemu)
