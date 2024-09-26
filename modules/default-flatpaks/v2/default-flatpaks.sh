#!/usr/bin/env nu

const flathubURL = "https://dl.flathub.org/repo/flathub.flatpakrepo"

const defaultInstallation = {
    notify: true
    scope: user
    repo: {
        url: $flathubURL
        name: "flathub"
        title: "Flathub"
    }
    install: []
}
const configPath = '/usr/share/bluebuild/default-flatpaks/configuration.yaml'

def main [configStr: string] {
    let config = $configStr | from yaml
    
    let installations = $config.installations | each {|installation|
        mut merged = $defaultInstallation | merge $installation
        $merged.repo = $defaultInstallation.repo | merge $merged.repo # make sure all repo properties exist

        print $"Validating installation of (ansi default_italic)($merged.install | length)(ansi reset) Flatpaks from (ansi default_italic)($merged.repo.title)(ansi reset)"

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
        | append $installations
        | to yaml | save -f $configPath

    print $"(ansi green_bold)Successfully generated following installations:(ansi reset)"
    print ($installations | to yaml)
}

def checkFlathub [packages: list<string>] {
    print "Checking if configured packages exist on Flathub..."
    $packages | each { |package| 
        try {
            let _ = http get $"https://flathub.org/apps/($package)"
        } catch {
            print $"(ansi red_bold)Package(ansi reset) (ansi default_italic)($package)(ansi reset) (ansi red_bold)does not exist on Flathub, which is the specified repository for it to be installed from.(ansi reset)"
            exit 1
        }
    }
}