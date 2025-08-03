#!/bin/bash

# IntelliCash Version Update Script
# Updates version in pubspec.yaml and related files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <version> [options]"
    echo ""
    echo "Arguments:"
    echo "  version    New version in format MAJOR.MINOR.PATCH (e.g., 7.5.2)"
    echo ""
    echo "Options:"
    echo "  --build-number <number>    Set build number (default: auto-generated)"
    echo "  --dry-run                  Show what would be changed without making changes"
    echo "  --help                     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 7.5.2                  Update to version 7.5.2"
    echo "  $0 8.0.0 --build-number 800000  Update to version 8.0.0 with build number 800000"
    echo "  $0 7.5.3 --dry-run        Show what would be changed for version 7.5.3"
}

# Function to validate version format
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_error "Invalid version format. Use MAJOR.MINOR.PATCH (e.g., 7.5.2)"
        exit 1
    fi
}

# Function to get current version from pubspec.yaml
get_current_version() {
    local pubspec_file="pubspec.yaml"
    if [[ ! -f "$pubspec_file" ]]; then
        print_error "pubspec.yaml not found"
        exit 1
    fi
    
    local version_line=$(grep "^version:" "$pubspec_file" | head -1)
    local current_version=$(echo "$version_line" | sed 's/version: //' | sed 's/+[0-9]*//')
    echo "$current_version"
}

# Function to generate build number
generate_build_number() {
    local version=$1
    local major=$(echo "$version" | cut -d. -f1)
    local minor=$(echo "$version" | cut -d. -f2)
    local patch=$(echo "$version" | cut -d. -f3)
    
    # Format: MMMNNPPP (Major=3 digits, Minor=2 digits, Patch=3 digits)
    printf "%03d%02d%03d" "$major" "$minor" "$patch"
}

# Function to update pubspec.yaml
update_pubspec() {
    local new_version=$1
    local build_number=$2
    local dry_run=$3
    
    local pubspec_file="pubspec.yaml"
    local new_version_line="version: $new_version+$build_number"
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would update $pubspec_file:"
        print_info "  Current: $(grep "^version:" "$pubspec_file")"
        print_info "  New:     $new_version_line"
    else
        # Create backup
        cp "$pubspec_file" "${pubspec_file}.backup"
        
        # Update version
        sed -i "s/^version:.*/$new_version_line/" "$pubspec_file"
        
        print_success "Updated $pubspec_file to version $new_version+$build_number"
    fi
}

# Function to update CHANGELOG.md
update_changelog() {
    local new_version=$1
    local dry_run=$2
    
    local changelog_file="CHANGELOG.md"
    
    if [[ ! -f "$changelog_file" ]]; then
        print_warning "CHANGELOG.md not found, skipping changelog update"
        return
    fi
    
    local current_date=$(date +%Y-%m-%d)
    local new_entry="## [$new_version] - $current_date"
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would add to $changelog_file:"
        print_info "  $new_entry"
    else
        # Add new version entry after [Unreleased]
        sed -i "/## \[Unreleased\]/a\\n$new_entry\\n\\n### Added\\n- \n\\n### Changed\\n- \n\\n### Fixed\\n- \n\\n### Security\\n- \n" "$changelog_file"
        
        print_success "Added new version entry to $changelog_file"
    fi
}

# Function to create git tag
create_git_tag() {
    local new_version=$1
    local dry_run=$2
    
    if [[ "$dry_run" == "true" ]]; then
        print_info "Would create git tag: v$new_version"
    else
        if git rev-parse --verify "v$new_version" >/dev/null 2>&1; then
            print_warning "Git tag v$new_version already exists"
        else
            git tag "v$new_version"
            print_success "Created git tag v$new_version"
        fi
    fi
}

# Function to update version in other files
update_other_files() {
    local new_version=$1
    local dry_run=$2
    
    # Update version in main.dart if it exists
    local main_file="lib/main.dart"
    if [[ -f "$main_file" ]]; then
        if [[ "$dry_run" == "true" ]]; then
            print_info "Would check $main_file for version references"
        else
            # Look for version comments or constants
            if grep -q "version\|Version" "$main_file"; then
                print_info "Found version references in $main_file - please review manually"
            fi
        fi
    fi
    
    # Update version in README.md if it exists
    local readme_file="README.md"
    if [[ -f "$readme_file" ]]; then
        if [[ "$dry_run" == "true" ]]; then
            print_info "Would check $readme_file for version references"
        else
            # Look for version mentions
            if grep -q "version\|Version" "$readme_file"; then
                print_info "Found version references in $readme_file - please review manually"
            fi
        fi
    fi
}

# Function to show summary
show_summary() {
    local new_version=$1
    local build_number=$2
    local dry_run=$3
    
    echo ""
    if [[ "$dry_run" == "true" ]]; then
        print_info "DRY RUN SUMMARY:"
        print_info "  New version: $new_version+$build_number"
        print_info "  Files that would be updated:"
        print_info "    - pubspec.yaml"
        print_info "    - CHANGELOG.md"
        print_info "    - Git tag: v$new_version"
    else
        print_success "VERSION UPDATE COMPLETED:"
        print_success "  New version: $new_version+$build_number"
        print_success "  Updated files:"
        print_success "    - pubspec.yaml"
        print_success "    - CHANGELOG.md"
        print_success "    - Git tag: v$new_version"
        echo ""
        print_info "Next steps:"
        print_info "  1. Review the changes"
        print_info "  2. Update CHANGELOG.md with actual changes"
        print_info "  3. Commit changes: git add . && git commit -m 'Bump version to $new_version'"
        print_info "  4. Push changes: git push && git push --tags"
    fi
}

# Main script
main() {
    local new_version=""
    local build_number=""
    local dry_run=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_usage
                exit 0
                ;;
            --build-number)
                build_number="$2"
                shift 2
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$new_version" ]]; then
                    new_version="$1"
                else
                    print_error "Multiple versions specified"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Check if version is provided
    if [[ -z "$new_version" ]]; then
        print_error "Version is required"
        show_usage
        exit 1
    fi
    
    # Validate version format
    validate_version "$new_version"
    
    # Get current version
    local current_version=$(get_current_version)
    print_info "Current version: $current_version"
    print_info "New version: $new_version"
    
    # Generate build number if not provided
    if [[ -z "$build_number" ]]; then
        build_number=$(generate_build_number "$new_version")
        print_info "Generated build number: $build_number"
    fi
    
    # Update files
    update_pubspec "$new_version" "$build_number" "$dry_run"
    update_changelog "$new_version" "$dry_run"
    update_other_files "$new_version" "$dry_run"
    
    # Create git tag
    create_git_tag "$new_version" "$dry_run"
    
    # Show summary
    show_summary "$new_version" "$build_number" "$dry_run"
}

# Run main function with all arguments
main "$@" 