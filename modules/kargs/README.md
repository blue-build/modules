# `kargs`

The `kargs` module injects kernel arguments into the image. Kernel arguments can be used to define how kernel will interact with the hardware or software.

Instead of modifying & rebuilding the kernel, the module uses `/usr/lib/bootc/kargs.d/` to define the kernel arguments. See the link below for how `bootc` injects kernel arguments:  
https://containers.github.io/bootc/building/kernel-arguments.html

Because the kargs are managed by `bootc`, to use this module, it is required to be have it installed & to be using it for example for updating the image. This means that instead of `rpm-ostree update`, you need to use `bootc update` for kargs to get applied on the next boot. Or in case of changing the image, you need to use `bootc switch` instead of `rpm-ostree rebase`.

To see which kargs are currently applied, you can issue `rpm-ostree kargs` command in a local terminal.

To see which kargs are supported in the kernel, you can see [this detailed documentation](https://web.git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/Documentation/admin-guide/kernel-parameters.txt).  
Switch the branch accordingly to the kernel version your image is on to get the more accurate version of the documentation.  
Take a note it's possible that some working kargs are not in the documentation.
