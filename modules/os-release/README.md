# **`os-release` Module**

The `os-release` module offers a way to modify and set values in the [`/etc/os-release`](https://www.freedesktop.org/software/systemd/man/latest/os-release.html) file in your image. This file contains metadata about the running Linux operating system and is read by various programs. 
 
## Example

```yaml
type: os-release
properties:
  ID: blue_build
  NAME: BlueBuild
  PRETTY_NAME: BlueBuild Image
```
