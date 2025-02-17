# kargs

The kargs module injects kernel arguments into the image.

Kernel arguments can be used to define how kernel will interact with the hardware or software.

Instead of modifying & rebuilding the kernel, it is much easier to just input the kernel arguments & `bootc` will do its job.

You can see how `bootc` injects kernel arguments [here](https://containers.github.io/bootc/building/kernel-arguments.html).

For this reason, it is required to have `bootc` installed & used in the image.  
By usage, it means that instead of `rpm-ostree update`, you need to use `bootc update` for kargs to get applied on next boot.  

To see which kargs are currently applied to the system in run-time, you can issue `rpm-ostree kargs` command.