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

    $ make install modules_install INSTALL_MOD_PATH=$WORK INSTALL_PATH=$WORK

Then, boot your kernel with:

    $ eudyptula-boot vmlinuz-3.15.0~rc5-02950-g7e61329b0c26

Any additional parameters will be given to KVM.
