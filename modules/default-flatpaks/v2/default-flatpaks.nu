#!/usr/libexec/bluebuild/nu/nu

const flathubURL = "https://dl.flathub.org/repo/flathub.flatpakrepo"

const defaultConfiguration = {
    notify: true
    scope: user
    repo: {
        url: $flathubURL
        name: "flathub"
        title: "Flathub"
    }
    install: []
}

const usrSharePath = "/usr/share/bluebuild/default-flatpaks"
const libExecPath = "/usr/libexec/bluebuild/default-flatpaks"
const configPath = $"($usrSharePath)/configuration.yaml"

def main [configStr: string] {
    let config = $configStr | from yaml
    
    if ('user' in $config or 'system' in $config) {
        print $"(ansi red_bold)CONFIGURATION ERROR(ansi reset)"
        print $"(ansi yellow_reverse)HINT(ansi reset): the default-flatpaks module has been updated with breaking changes!"
        print $"It seems like you are trying to run the new (ansi default_italic)default-flatpaks@v2(ansi reset) module with configuration made for the older version."
        print $"You can read the docs to migrate to the new and improved module, or just change switch back to the old module like this (ansi default_italic)type: default-flatpaks@v1(ansi reset)"
        exit 1
    }

    let configurations = $config.configurations | each {|configuration|
        mut merged = $defaultConfiguration | merge $configuration
        $merged.repo = $defaultConfiguration.repo | merge $merged.repo # make sure all repo properties exist

        print $"Validating configuration of (ansi default_italic)($merged.install | length)(ansi reset) Flatpaks from (ansi default_italic)($merged.repo.title)(ansi reset)"

        if (not ($merged.scope == "system" or $merged.scope == "user")) {
            print $"(ansi red_bold)Scope must be either(ansi reset) (ansi blue_italic)system(ansi reset) (ansi red_bold)or(ansi reset) (ansi blue_italic)user(ansi reset)"
            print $"(ansi blue)Your input:(ansi reset) ($merged.scope)"
            exit 1
        }
        if (not ($merged.notify == true or $merged.notify == false)) {
            print $"(ansi red_bold)Notify must be either(ansi reset) (ansi blue_italic)true(ansi reset) (ansi red_bold)or(ansi reset) (ansi blue_italic)false(ansi reset)"
            print $"(ansi blue)Your input:(ansi reset) ($merged.notify)"
            exit 1
        }
        if ($merged.repo.url == $flathubURL) {
            checkFlathub $merged.install
        }

        print $"Validation successful!"

        $merged
    }


    if (not ($configPath | path exists)) {
        mkdir ($configPath | path dirname)
        '[]'| save $configPath
    }

    open $configPath
        | append $configurations
        | to yaml | save -f $configPath

    print $"(ansi green_bold)Successfully generated following configurations:(ansi reset)"
    print ($configurations | to yaml)

    print "Setting up Flatpak setup services..."

    mkdir /usr/lib/systemd/system/
    cp $"($env.MODULE_DIRECTORY)/default-flatpaks/post-boot/system-flatpak-setup.service" /usr/lib/systemd/system/system-flatpak-setup.service
    cp $"($env.MODULE_DIRECTORY)/default-flatpaks/post-boot/system-flatpak-setup.timer" /usr/lib/systemd/system/system-flatpak-setup.timer
    mkdir /usr/lib/systemd/user/
    cp $"($env.MODULE_DIRECTORY)/default-flatpaks/post-boot/user-flatpak-setup.service" /usr/lib/systemd/user/user-flatpak-setup.service
    cp $"($env.MODULE_DIRECTORY)/default-flatpaks/post-boot/user-flatpak-setup.timer" /usr/lib/systemd/user/user-flatpak-setup.timer
    systemctl enable --force system-flatpak-setup.timer
    systemctl enable --force --global user-flatpak-setup.timer

    mkdir ($libExecPath)
    cp $"($env.MODULE_DIRECTORY)/default-flatpaks/post-boot/system-flatpak-setup" $"($libExecPath)/system-flatpak-setup" 
    cp $"($env.MODULE_DIRECTORY)/default-flatpaks/post-boot/user-flatpak-setup" $"($libExecPath)/user-flatpak-setup" 
    chmod +x $"($libExecPath)/system-flatpak-setup"
    chmod +x $"($libExecPath)/user-flatpak-setup"

    cp $"($env.MODULE_DIRECTORY)/default-flatpaks/post-boot/bluebuild-flatpak-manager" "/usr/bin/bluebuild-flatpak-manager"
    chmod +x "/usr/bin/bluebuild-flatpak-manager"
}

def checkFlathub [packages: list<string>] {
    print "Checking if configured packages exist on Flathub..."
    let unavailablePackages = $packages | each { |package| 
        try {
            let _ = http get $"https://flathub.org/api/v2/stats/($package)"
        } catch {
            $package
        }
    }
    if ($unavailablePackages | length) > 0 {
        print $"(ansi red_bold)The following packages are not available on Flathub, which is the specified repository for them to be installed from:(ansi reset) "
        for package in $unavailablePackages {
            print $"(ansi default_italic)($package)(ansi reset)"
        }
        exit 1
    }
}
