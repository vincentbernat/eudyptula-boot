# eudyptula-boot

`eudyptula-boot` boots a Linux kernel in a VM without a dedicated root
filesystem. The root filesystem is the underlying root filesystem (or
some pre-built chroot). This is a convenient way to do quick tests
with a custom kernel.

The name comes from [Eudyptula][] which is a genus for penguins. This
is also the name of a [challenge for the Linux kernel][].

This utility is aimed at development only. This is a hack. It relies
on AUFS/overlayfs and 9P to build the root filesystem from the running
system.

[Eudyptula]: http://en.wikipedia.org/wiki/Eudyptula
[challenge for the Linux kernel]: http://eudyptula-challenge.org/

Also see
[this blog post](http://vincent.bernat.ch/en/blog/2014-eudyptula-boot)
for a quick presentation of this tool.

## Usage

It is preferable to have a kernel with AUFS or OverlayFS
enabled. Ubuntu and Debian kernels are patched to support AUFS. Since
3.18, vanilla kernels have OverlayFS built-in. Ubuntu kernels also
come with OverlayFS support. Check you have one of those options:

    CONFIG_AUFS_FS=y
    CONFIG_OVERLAY_FS=y
    CONFIG_OVERLAYFS_FS=y

Ensure you have the following options enabled (as a module or builtin):

    CONFIG_9P_FS=y
    CONFIG_NET_9P=y
    CONFIG_NET_9P_VIRTIO=y
    CONFIG_VIRTIO=y
    CONFIG_VIRTIO_PCI=y
    CONFIG_VIRTIO_CONSOLE=y

To get a somewhat minimal configuration, have a look at the
`minimal-configuration` script.

Once compiled, the kernel needs to be installed in some work directory:

    $ make modules_install install INSTALL_MOD_PATH=$WORK INSTALL_PATH=$WORK

Then, boot your kernel with:

    $ eudyptula-boot --kernel $WORK/vmlinuz-3.15.0~rc5-02950-g7e61329b0c26

Use `--help` to get additional available options.

Before booting the kernel, the path to GDB socket will be
displayed. You can use it by running gdb on `vmlinux` (which is
somewhere in the source tree):

    $ gdb vmlinux
    GNU gdb (GDB) 7.4.1-debian
    Reading symbols from /home/bernat/src/linux/vmlinux...done.
    (gdb) target remote /path/to/vm-eudyptula-gdb.pipe
    Remote debugging using /path/to/vm-eudyptula-gdb.pipe
    native_safe_halt () at /home/bernat/src/linux/arch/x86/include/asm/irqflags.h:50
    50  }
    (gdb)

If you have modules, you also need to manually load debug symbols for
them. In guest:

    $ grep . /sys/module/vxlan/sections/{.text,.data,.bss}
    /sys/module/vxlan/sections/.text:0xffffffffc0370000
    /sys/module/vxlan/sections/.data:0xffffffffc0378000
    /sys/module/vxlan/sections/.bss:0xffffffffc0378900

In GDB:

    (gdb) add-symbol-file /usr/lib/debug/lib/modules/$(uname -r)/kernel/drivers/net/vxlan.ko \
                          0xffffffffc0370000 \
                 -s .data 0xffffffffc0378000 \
                 -s .bss  0xffffffffc0378900

This can be automated with `lx-symbols` command if you source
`vmlinux-gdb.py` from a compiled kernel.

A serial port is also exported. It can be convenient for remote
debugging of userland processes. More details can be found in this
[blog post][] (which also covers debugging the kernel).

[blog post]: http://vincent.bernat.ch/en/blog/2012-network-lab-kvm

QEMU monitor is also attached to a UNIX socket. You can use the
following command to interact with it:

    $ socat - UNIX:/path/to/vm-eudyptula-console.pipe
    QEMU 2.0.0 monitor - type 'help' for more information
    (qemu)

You can also get something similar to [guestfish][]:

    $ eudyptula-boot --qemu="-drive file=someimage.qcow2,media=disk,if=virtio"

With `--extra-gettys`, you can allocate additional consoles. To access
one of them, use:

    $ socat STDIO,echo=0,icanon=0 UNIX:/tmp/tmp.oCshB5ryj4/getty-1.pipe

[guestfish]: http://libguestfs.org/guestfish.1.html

## Usage with Nix

You can also run `eudyptula-boot` with the following command if you have Nix
installed:

    $ nix run github:vincentbernat/eudyptula-boot

If you want to add arguments, separate them with `--`:

    $ nix run github:vincentbernat/eudyptula-boot -- --net -m 4G
    
To run `minimal-configuration`, use:

    $ nix run github:vincentbernat/eudyptula-boot#minimal-configuration
    
You can also get a shell with the tools to hack around the kernel:

    $ nix develop github:vincentbernat/eudyptula-boot#kernel-dev

## Alternatives

Similar projects exist:

 - https://github.com/g2p/vido
 - https://git.kernel.org/cgit/utils/kernel/virtme/virtme.git/
