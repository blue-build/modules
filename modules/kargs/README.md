# `kargs`

The `kargs `module injects kernel arguments into the image. Kernel arguments can be used to define how kernel will interact with the hardware or software.

Instead of modifying & rebuilding the kernel, the module uses `/usr/lib/bootc/kargs.d/` to define the kernel arguments. See the link below for how `bootc` injects kernel arguments:  
https://containers.github.io/bootc/building/kernel-arguments.html

Because the kargs are managed by `bootc`, to use this module it is required to be have it installed and to be using it for example for updating the image. This means that instead of `rpm-ostree update`, you need to use `bootc update` for kargs to get applied on the next boot.  

To see which kargs are currently applied, you can issue `rpm-ostree kargs` command in a local terminal.