#!/usr/bin/env nu
# generates modules-latest directory with only latest versions of modules and builds the Containerfile

const PLATFORMS = [
  'linux/amd64'
  'linux/amd64/v2'
  'linux/arm64'
  'linux/arm'
  'linux/arm/v6'
  'linux/arm/v7'
  'linux/386'
  'linux/loong64'
  'linux/mips'
  'linux/mipsle'
  'linux/mips64'
  'linux/mips64le'
  'linux/ppc64'
  'linux/ppc64le'
  'linux/riscv64'
  'linux/s390x'
]

print $"(ansi green_bold)Gathering images(ansi reset)"

rm -rf ./modules-latest
mkdir ./modules-latest

ls modules | each { |moduleDir|

    # module is unversioned
    if (glob $"($moduleDir.name)/($moduleDir.name | path basename).{sh,nu}" | any { path exists }) {

        print $"(ansi cyan)Found(ansi reset) (ansi cyan_bold)unversioned(ansi reset) (ansi cyan)module:(ansi reset) ($moduleDir.name | path basename)"

        cp --recursive ($moduleDir.name) $"./modules-latest/($moduleDir.name | path basename)"

    } else { # module is versioned

        print -n $"(ansi cyan)Found(ansi reset) (ansi blue_bold)versioned(ansi reset) (ansi cyan)module:(ansi reset) ($moduleDir.name | path basename), "

        let latest = glob $"./($moduleDir.name)/v*" | last # the glob result is already orderer such that the last value is the biggest

        print $"(ansi blue_bold)Latest version:(ansi reset) ($latest | path basename)"

        cp --recursive ($latest) $"./modules-latest/($moduleDir.name | path basename)"

    }
}

print $"(ansi green_bold)Starting image build(ansi reset)"

let tag = if ($env.GH_EVENT_NAME != "pull_request" and $env.GH_BRANCH == "main") {
    "latest"
} else if ($env.GH_EVENT_NAME != "pull_request") {
    $env.GH_BRANCH
} else {
    $"pr-($env.GH_PR_NUMBER)"
}


print $"(ansi green_bold)Generated tags for image:(ansi reset) ($tag)"

(docker build .
    -f ./unified.Containerfile
    --push
    ...($PLATFORMS | each { $'--platform=($in)' })
    -t $"($env.REGISTRY)/modules:($tag)"
)

let inspect_image = $'($env.REGISTRY)/modules:($tag)'
print $"(ansi cyan)Inspecting image:(ansi reset) ($inspect_image)"
let digest = (docker
    buildx
    imagetools
    inspect
    --format '{{json .}}'
    $inspect_image)
    | from json
    | get manifest.digest

let digest_image = $'($env.REGISTRY)/modules@($digest)'
print $"(ansi cyan)Signing image:(ansi reset) ($digest_image)"
cosign sign -y --recursive --key env://COSIGN_PRIVATE_KEY $digest_image

print $"(ansi green_bold)DONE!(ansi reset)"
