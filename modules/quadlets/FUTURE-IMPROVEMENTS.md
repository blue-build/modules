# Future Improvements for Quadlets Module

This document tracks planned features and improvements for the BlueBuild quadlets module, drawing inspiration from existing Podman quadlet tools and container management projects.

## From pq (https://github.com/rgolangh/pq)

### Staged Updates (Update Stashing)
- **Status**: Planned
- **Priority**: High
- **Description**: Download and validate quadlet updates without immediately applying them, allowing users to review changes before deployment.
- **Implementation**:
  - Add `--dry-run` flag to update commands
  - Store staged updates in `/var/lib/bluebuild/quadlets/staged/`
  - New CLI commands:
    - `bluebuild-quadlets-manager stage [name]` - Download updates without applying
    - `bluebuild-quadlets-manager apply-staged [name]` - Apply staged updates
    - `bluebuild-quadlets-manager discard-staged [name]` - Discard staged updates
    - `bluebuild-quadlets-manager diff [name]` - Show differences between current and staged
  - Notification when updates are staged
- **Reference**: 
  - `cmd/install.go` (dryRun flag and podman-system-generator integration)
  - `cmd/inspect.go` (preview functionality)
- **Benefits**: Safer updates, ability to review changes, rollback prevention

### Interactive Service Management
- **Status**: Planned
- **Priority**: Medium
- **Description**: Better integration with systemd service lifecycle with interactive prompts and confirmations.
- **Implementation**:
  - Interactive confirmation before systemd daemon-reload
  - Prompt to start/stop services during operations
  - View logs directly from CLI with paging
  - Service dependency visualization
  - Health check integration
- **Reference**: 
  - `pkg/systemd/daemon.go` (interactive prompts)
  - `cmd/remove.go` (confirmation patterns)
- **Benefits**: More control over service operations, reduced accidents

### Repository Management & Discovery
- **Status**: Planned
- **Priority**: Medium
- **Description**: Support for custom quadlet repositories and discovery of available quadlets.
- **Implementation**:
  - Default repository configuration in `~/.config/bluebuild-quadlets/config.yaml`
  - CLI command to add/remove repositories
  - Browse available quadlets from configured repos:
    - `bluebuild-quadlets-manager browse [repo]`
    - `bluebuild-quadlets-manager search <keyword>`
  - Support for local/private repositories
  - Repository metadata and indexing
- **Reference**: 
  - `cmd/root.go` (config handling)
  - `cmd/list.go` (repo listing and directory walking)
- **Benefits**: Easier discovery of quadlets, community repositories

### Quadlet Inspection & Preview
- **Status**: Planned
- **Priority**: High
- **Description**: Preview quadlet contents and generated systemd units before installation.
- **Implementation**:
  - Show all files in quadlet directory with syntax highlighting
  - Display generated systemd units (via podman-system-generator)
  - Preview what services will be created
  - Detect potential conflicts (ports, volumes, networks)
  - CLI command: `bluebuild-quadlets-manager inspect <quadlet> [--source <git-url>]`
- **Reference**: 
  - `cmd/inspect.go` (complete implementation)
  - `cmd/install.go` (podman-system-generator --dryrun usage)
- **Benefits**: Know what you're installing, catch issues early

### Service Status Dashboard
- **Status**: Under Consideration
- **Priority**: Low
- **Description**: Enhanced status view showing all quadlets and their services at a glance.
- **Implementation**:
  - Table view of all quadlets with health status
  - Resource usage per quadlet
  - Color-coded status indicators
  - Quick actions (restart, stop, logs)
- **Reference**: 
  - `cmd/list_services.go` (service listing logic)
  - `pkg/systemd/daemon.go` (status checking)
- **Benefits**: Better overview, easier troubleshooting

## From marmorata/taxifolia (https://github.com/tulilirockz/marmorata)

### Container Backup & Restore
- **Status**: Planned (High Priority)
- **Priority**: High
- **Description**: Automatic backup of container volumes and configurations before updates, with restore capability on failure.
- **Implementation**:
  - Pre-update hooks to backup volumes
  - Export container state and configuration
  - Automatic restore on update failure
  - Configurable backup retention policy
  - Manual backup/restore commands:
    - `bluebuild-quadlets-manager backup <quadlet>`
    - `bluebuild-quadlets-manager restore <quadlet> [--from <backup-id>]`
    - `bluebuild-quadlets-manager list-backups <quadlet>`
  - Backup location: `/var/lib/bluebuild/quadlets/backups/`
- **Reference**: 
  - `base.just` (volume management patterns)
  - Container lifecycle in quadlet examples (ai-stack, wordpress)
- **Benefits**: Safe updates, disaster recovery, easy rollback

### Just-based Workflow Integration  
- **Status**: Under Consideration
- **Priority**: Low
- **Description**: Provide Justfile recipes for common quadlet operations as an alternative CLI.
- **Implementation**:
  - Optional Justfile templates for quadlet operations
  - Common recipes:
    - `just install <quadlet>` - Install from repo
    - `just deploy <quadlet>` - Full deployment workflow
    - `just clean <quadlet>` - Remove with volumes
    - `just backup <quadlet>` - Backup volumes and config
    - `just logs <quadlet>` - View logs
  - Integration with existing system Justfiles
- **Reference**: 
  - `base.just` (comprehensive example with all patterns)
  - Individual quadlet Justfiles in examples
- **Benefits**: Familiar workflow for Just users, scriptable operations

### Firewall Rule Generation
- **Status**: Planned
- **Priority**: Medium
- **Description**: Automatically generate and apply firewalld rules from quadlet PublishPort directives.
- **Implementation**:
  - Parse `PublishPort=` from .container/.pod files
  - Generate firewalld service XML automatically
  - Apply with `firewall-cmd` during setup
  - CLI commands:
    - `bluebuild-quadlets-manager firewall <quadlet>` - Apply firewall rules
    - `bluebuild-quadlets-manager firewall --preview <quadlet>` - Show generated XML
  - Optional automatic application during setup
- **Reference**: 
  - `base.just` (firewall-xml and firewall functions)
  - XML generation logic
- **Benefits**: Automatic network security, less manual configuration

### Environment Variable Management
- **Status**: Under Consideration
- **Priority**: Medium
- **Description**: Better handling of environment files with templating and secret integration.
- **Implementation**:
  - Template expansion for environment files
  - Support for `.env.template` files
  - Integration with secret managers (Bitwarden, Vault)
  - Per-environment overrides (dev/staging/prod)
  - Validation of required variables
- **Reference**: 
  - Quadlet examples with `EnvironmentFile=`
  - `.service.d/env` pattern in ai-stack
- **Benefits**: Easier secret management, environment-specific configs

### Multi-arch Support
- **Status**: Planned
- **Priority**: Medium
- **Description**: Handle architecture-specific quadlet installations and image selection.
- **Implementation**:
  - Detect host architecture automatically
  - Select appropriate images for arch
  - Validate compatibility before installation
  - Support for multi-arch container images
  - Conditional quadlet installation based on arch
- **Reference**: 
  - `container/build_files/github-release-install.sh` (arch filtering)
  - Build system arch detection
- **Benefits**: Works across x86_64, ARM, etc.

### Volume Management Tools
- **Status**: Planned
- **Priority**: Medium
- **Description**: CLI tools for managing persistent volumes associated with quadlets.
- **Implementation**:
  - List volumes by quadlet: `bluebuild-quadlets-manager volumes <quadlet>`
  - Backup individual volumes: `bluebuild-quadlets-manager volume backup <volume>`
  - Restore volumes: `bluebuild-quadlets-manager volume restore <volume>`
  - Clean orphaned volumes: `bluebuild-quadlets-manager volume prune`
  - Volume migration between systems
  - Volume size reporting and usage stats
- **Reference**: 
  - `base.just` (clean function with volume removal)
  - Volume definitions in quadlet examples
- **Benefits**: Better volume lifecycle management

### Podman Compose Migration Tool
- **Status**: Under Consideration
- **Priority**: Low
- **Description**: Convert docker-compose.yml or podman-compose.yml files to Podman Quadlets.
- **Implementation**:
  - Parse compose YAML
  - Generate equivalent .container, .pod, .network, .volume files
  - Handle compose-specific features (depends_on, healthchecks, etc.)
  - CLI command: `bluebuild-quadlets-manager convert <compose-file>`
  - Validation and warnings for unsupported features
- **Benefits**: Easy migration from compose, reuse existing configs

### Bootc/OCI Integration
- **Status**: Future
- **Priority**: Low
- **Description**: Better integration with bootc container image workflow.
- **Implementation**:
  - Include quadlets in bootc images naturally
  - Coordinate updates with bootc updates
  - Rollback support tied to bootc snapshots
  - Image layering awareness
- **Reference**: 
  - `container/Containerfile.in`
  - `build.sh` (bootc patterns)
  - `Justfile` (bootc integration in cayo)
- **Benefits**: Native bootc experience, atomic updates

## Community Requests

### Notification System Enhancement
- **Status**: Planned
- **Priority**: Medium
- **Description**: Enhanced desktop notifications with more detail and interactivity.
- **Implementation**:
  - Detailed notifications with actions
  - Update summaries (e.g., "3 quadlets updated")
  - Error notifications with troubleshooting links
  - Option to disable per-quadlet
  - System tray indicator
- **Reference**: default-flatpaks module notification system
- **Benefits**: Better user awareness, less surprise

### Dependency Management
- **Status**: Under Research
- **Priority**: High
- **Description**: Handle quadlet dependencies automatically (networks, volumes before containers).
- **Implementation**:
  - Parse systemd `After=`, `Requires=`, etc. from quadlet files
  - Topological sort of dependencies
  - Automatic ordering of operations
  - Dependency graph visualization
  - Detect circular dependencies
- **Reference**: systemd ordering directives in quadlet files
- **Benefits**: Reliable startup order, fewer errors

### Web UI / Cockpit Integration
- **Status**: Future
- **Priority**: Low
- **Description**: Cockpit plugin for graphical quadlet management.
- **Implementation**:
  - Cockpit plugin for quadlet overview
  - Install/update/remove operations
  - Log viewing and service management
  - Configuration editing
  - Visual dependency graph
- **Reference**: Cockpit integration in taxifolia
- **Benefits**: GUI option, easier for non-CLI users

### Health Checks & Monitoring
- **Status**: Under Consideration
- **Priority**: Medium
- **Description**: Built-in health check monitoring and alerting.
- **Implementation**:
  - Monitor quadlet-defined health checks
  - Alert on failures
  - Automatic restart on health check failure (configurable)
  - Health status in CLI/UI
  - Integration with monitoring systems (Prometheus, etc.)
- **Benefits**: Proactive issue detection

### Template/Skeleton Generator
- **Status**: Planned
- **Priority**: Low
- **Description**: Generate skeleton quadlet files from templates.
- **Implementation**:
  - Interactive wizard: `bluebuild-quadlets-manager new <name>`
  - Templates for common patterns (webapp, database, monitoring)
  - Customizable templates
  - Validation as you build
- **Benefits**: Easier to get started, best practices

## Prioritization

### High Priority (Next Release)
1. Staged Updates
2. Quadlet Inspection & Preview
3. Container Backup & Restore
4. Dependency Management

### Medium Priority (Future Release)
1. Firewall Rule Generation
2. Interactive Service Management
3. Repository Management
4. Volume Management Tools
5. Multi-arch Support

### Low Priority (Future)
1. Just Integration
2. Web UI
3. Compose Migration
4. Template Generator
