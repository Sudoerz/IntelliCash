# IntelliCash Version Update Script (PowerShell)
# Updates version in pubspec.yaml and related files

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [string]$BuildNumber,
    
    [switch]$DryRun,
    
    [switch]$Help
)

# Function to show usage
function Show-Usage {
    Write-Host "Usage: .\update_version.ps1 <version> [options]" -ForegroundColor Blue
    Write-Host ""
    Write-Host "Arguments:" -ForegroundColor White
    Write-Host "  version    New version in format MAJOR.MINOR.PATCH (e.g., 7.5.2)" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -BuildNumber <number>    Set build number (default: auto-generated)" -ForegroundColor White
    Write-Host "  -DryRun                  Show what would be changed without making changes" -ForegroundColor White
    Write-Host "  -Help                    Show this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  .\update_version.ps1 7.5.2                  Update to version 7.5.2" -ForegroundColor White
    Write-Host "  .\update_version.ps1 8.0.0 -BuildNumber 800000  Update to version 8.0.0 with build number 800000" -ForegroundColor White
    Write-Host "  .\update_version.ps1 7.5.3 -DryRun        Show what would be changed for version 7.5.3" -ForegroundColor White
}

# Function to print colored output
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Function to validate version format
function Test-VersionFormat {
    param([string]$Version)
    
    if ($Version -notmatch '^\d+\.\d+\.\d+$') {
        Write-Error "Invalid version format. Use MAJOR.MINOR.PATCH (e.g., 7.5.2)"
        exit 1
    }
}

# Function to get current version from pubspec.yaml
function Get-CurrentVersion {
    $pubspecFile = "pubspec.yaml"
    
    if (-not (Test-Path $pubspecFile)) {
        Write-Error "pubspec.yaml not found"
        exit 1
    }
    
    $versionLine = Get-Content $pubspecFile | Where-Object { $_ -match '^version:' } | Select-Object -First 1
    $currentVersion = $versionLine -replace 'version: ', '' -replace '\+[0-9]*', ''
    return $currentVersion
}

# Function to generate build number
function Get-BuildNumber {
    param([string]$Version)
    
    $parts = $Version -split '\.'
    $major = [int]$parts[0]
    $minor = [int]$parts[1]
    $patch = [int]$parts[2]
    
    # Format: MMMNNPPP (Major=3 digits, Minor=2 digits, Patch=3 digits)
    return "{0:D3}{1:D2}{2:D3}" -f $major, $minor, $patch
}

# Function to update pubspec.yaml
function Update-Pubspec {
    param(
        [string]$NewVersion,
        [string]$BuildNumber,
        [bool]$DryRun
    )
    
    $pubspecFile = "pubspec.yaml"
    $newVersionLine = "version: $NewVersion+$BuildNumber"
    
    if ($DryRun) {
        Write-Info "Would update $pubspecFile:"
        $currentLine = Get-Content $pubspecFile | Where-Object { $_ -match '^version:' } | Select-Object -First 1
        Write-Info "  Current: $currentLine"
        Write-Info "  New:     $newVersionLine"
    } else {
        # Create backup
        Copy-Item $pubspecFile "$pubspecFile.backup"
        
        # Update version
        $content = Get-Content $pubspecFile
        $content = $content -replace '^version:.*', $newVersionLine
        Set-Content $pubspecFile $content
        
        Write-Success "Updated $pubspecFile to version $NewVersion+$BuildNumber"
    }
}

# Function to update CHANGELOG.md
function Update-Changelog {
    param(
        [string]$NewVersion,
        [bool]$DryRun
    )
    
    $changelogFile = "CHANGELOG.md"
    
    if (-not (Test-Path $changelogFile)) {
        Write-Warning "CHANGELOG.md not found, skipping changelog update"
        return
    }
    
    $currentDate = Get-Date -Format "yyyy-MM-dd"
    $newEntry = "## [$NewVersion] - $currentDate"
    
    if ($DryRun) {
        Write-Info "Would add to $changelogFile:"
        Write-Info "  $newEntry"
    } else {
        # Add new version entry after [Unreleased]
        $content = Get-Content $changelogFile
        $newContent = @()
        $added = $false
        
        foreach ($line in $content) {
            $newContent += $line
            
            if ($line -match '## \[Unreleased\]' -and -not $added) {
                $newContent += ""
                $newContent += $newEntry
                $newContent += ""
                $newContent += "### Added"
                $newContent += "- "
                $newContent += ""
                $newContent += "### Changed"
                $newContent += "- "
                $newContent += ""
                $newContent += "### Fixed"
                $newContent += "- "
                $newContent += ""
                $newContent += "### Security"
                $newContent += "- "
                $newContent += ""
                $added = $true
            }
        }
        
        Set-Content $changelogFile $newContent
        Write-Success "Added new version entry to $changelogFile"
    }
}

# Function to create git tag
function New-GitTag {
    param(
        [string]$NewVersion,
        [bool]$DryRun
    )
    
    if ($DryRun) {
        Write-Info "Would create git tag: v$NewVersion"
    } else {
        try {
            $existingTag = git rev-parse --verify "v$NewVersion" 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Warning "Git tag v$NewVersion already exists"
            } else {
                git tag "v$NewVersion"
                Write-Success "Created git tag v$NewVersion"
            }
        } catch {
            Write-Warning "Could not create git tag: $_"
        }
    }
}

# Function to update version in other files
function Update-OtherFiles {
    param(
        [string]$NewVersion,
        [bool]$DryRun
    )
    
    # Update version in main.dart if it exists
    $mainFile = "lib/main.dart"
    if (Test-Path $mainFile) {
        if ($DryRun) {
            Write-Info "Would check $mainFile for version references"
        } else {
            $content = Get-Content $mainFile -Raw
            if ($content -match "version|Version") {
                Write-Info "Found version references in $mainFile - please review manually"
            }
        }
    }
    
    # Update version in README.md if it exists
    $readmeFile = "README.md"
    if (Test-Path $readmeFile) {
        if ($DryRun) {
            Write-Info "Would check $readmeFile for version references"
        } else {
            $content = Get-Content $readmeFile -Raw
            if ($content -match "version|Version") {
                Write-Info "Found version references in $readmeFile - please review manually"
            }
        }
    }
}

# Function to show summary
function Show-Summary {
    param(
        [string]$NewVersion,
        [string]$BuildNumber,
        [bool]$DryRun
    )
    
    Write-Host ""
    if ($DryRun) {
        Write-Info "DRY RUN SUMMARY:"
        Write-Info "  New version: $NewVersion+$BuildNumber"
        Write-Info "  Files that would be updated:"
        Write-Info "    - pubspec.yaml"
        Write-Info "    - CHANGELOG.md"
        Write-Info "    - Git tag: v$NewVersion"
    } else {
        Write-Success "VERSION UPDATE COMPLETED:"
        Write-Success "  New version: $NewVersion+$BuildNumber"
        Write-Success "  Updated files:"
        Write-Success "    - pubspec.yaml"
        Write-Success "    - CHANGELOG.md"
        Write-Success "    - Git tag: v$NewVersion"
        Write-Host ""
        Write-Info "Next steps:"
        Write-Info "  1. Review the changes"
        Write-Info "  2. Update CHANGELOG.md with actual changes"
        Write-Info "  3. Commit changes: git add . && git commit -m 'Bump version to $NewVersion'"
        Write-Info "  4. Push changes: git push && git push --tags"
    }
}

# Main script
function Main {
    # Show help if requested
    if ($Help) {
        Show-Usage
        return
    }
    
    # Validate version format
    Test-VersionFormat $Version
    
    # Get current version
    $currentVersion = Get-CurrentVersion
    Write-Info "Current version: $currentVersion"
    Write-Info "New version: $Version"
    
    # Generate build number if not provided
    if (-not $BuildNumber) {
        $BuildNumber = Get-BuildNumber $Version
        Write-Info "Generated build number: $BuildNumber"
    }
    
    # Update files
    Update-Pubspec $Version $BuildNumber $DryRun
    Update-Changelog $Version $DryRun
    Update-OtherFiles $Version $DryRun
    
    # Create git tag
    New-GitTag $Version $DryRun
    
    # Show summary
    Show-Summary $Version $BuildNumber $DryRun
}

# Run main function
Main 