# **`os-release` Module**

The `os-release` module offers a way to modify and set values in the [`/etc/os-release`](https://www.freedesktop.org/software/systemd/man/latest/os-release.html) file in your image. This file contains metadata about the running Linux operating system and is read by various programs. 

:::note
Modifying the `ID` value within `/etc/os-release` can cause COPR package identification and installation failures during the build process. Therefore, it is recommended to place thie `os-release` module at the end of your build, if you are planning to modify that value.
:::
 
## Example

```yaml
type: os-release
properties:
  ID: blue_build
  NAME: BlueBuild
  PRETTY_NAME: BlueBuild Image
```
