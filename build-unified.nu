#!/usr/bin/env nu
# generates modules-latest directory with only latest versions of modules and builds the Containerfile

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

let tags = (
    if ($env.GH_EVENT_NAME != "pull_request" and $env.GH_BRANCH == "main") {
        ["latest"]
    } else if ($env.GH_EVENT_NAME != "pull_request") {
        [$env.GH_BRANCH]
    } else {
        [$"pr-($env.GH_PR_NUMBER)"]
    }
)

print $"(ansi green_bold)Generated tags for image:(ansi reset) ($tags | str join ' ')"

(docker build .
    -f ./unified.Containerfile
    ...($tags | each { |tag| ["-t", $"($env.REGISTRY)/modules:($tag)"] } | flatten) # generate and spread list of tags
)

print $"(ansi cyan)Pushing image:(ansi reset) ($env.REGISTRY)/modules"
let digest = (
    docker push --all-tags $"($env.REGISTRY)/modules"
        | split row "\n"  | last | split row " " | get 2 # parse push output to get digest for signing
)

print $"(ansi cyan)Signing image:(ansi reset) ($env.REGISTRY)/modules@($digest)"
cosign sign -y --key env://COSIGN_PRIVATE_KEY $"($env.REGISTRY)/modules@($digest)"

print $"(ansi green_bold)DONE!(ansi reset)"
