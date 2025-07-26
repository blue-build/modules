# **`os-release` Module**

The `os-release` module offers a way to modify and set values in the [`/etc/os-release`](https://www.freedesktop.org/software/systemd/man/latest/os-release.html) file in your image. This file contains metadata about the running Linux operating system and is read by various programs. 

:::note
Modifying the `ID` value within `/etc/os-release` can cause COPR package identification and installation failures during the build process. When changing the `ID`, you should always set `ID_LIKE` to the type of base image you are using, ex. `ID_LIKE: fedora`. Errors from setting the `ID` may also be alleviated by running the module at the end of the build process, but beware that those errors would still be present in images derived from your image.
:::
