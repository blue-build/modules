#!/usr/bin/env nu
# generates modules-latest directory with only latest versions of modules and builds the Containerfile

use constants.nu *

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
    --annotation $"index,manifest:org.opencontainers.image.created=(date now | date to-timezone UTC | format date '%Y-%m-%dT%H:%M:%SZ')"
    --annotation "index,manifest:org.opencontainers.image.url=https://github.com/blue-build/modules"
    --annotation "index,manifest:org.opencontainers.image.documentation=https://blue-build.org/"
    --annotation "index,manifest:org.opencontainers.image.source=https://github.com/blue-build/modules"
    --annotation "index,manifest:org.opencontainers.image.version=nightly"
    --annotation $"index,manifest:org.opencontainers.image.revision=($env.GITHUB_SHA)"
    --annotation "index,manifest:org.opencontainers.image.licenses=Apache-2.0"
    --annotation "index,manifest:org.opencontainers.image.title=BlueBuild Modules"
    --annotation "index,manifest:org.opencontainers.image.description=BlueBuild standard modules used for building your Atomic Images"
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
(cosign sign
    --new-bundle-format=false
    --use-signing-config=false
    -y --recursive
    --key env://COSIGN_PRIVATE_KEY
    $digest_image)
(cosign verify
    --key=./cosign.pub
    $digest_image)

print $"(ansi green_bold)DONE!(ansi reset)"
