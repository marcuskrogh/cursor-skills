# Sync skills from this repo to local agent skill directories.
# Usage: .\scripts\sync-local.ps1 [-Prune] [-Link]
#
# Default targets are common Agent Skills home dirs across popular harnesses.
# Override with -Targets. For project installs, prefer: npx skills add marcuskrogh/skills
#
# Always syncs skills/*/ (with SKILL.md) and skills/concepts/ as sibling folders.

param(
    [switch]$Prune,
    [switch]$Link,
    [string[]]$Targets = @(
        (Join-Path $env:USERPROFILE ".agents\skills"),
        (Join-Path $env:USERPROFILE ".claude\skills"),
        (Join-Path $env:USERPROFILE ".codex\skills"),
        (Join-Path $env:USERPROFILE ".copilot\skills"),
        (Join-Path $env:USERPROFILE ".cursor\skills")
    )
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$SourceDir = Join-Path $RepoRoot "skills"
$ConceptsSource = Join-Path $SourceDir "concepts"

if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory not found: $SourceDir"
}

$skillDirs = Get-ChildItem -Path $SourceDir -Directory | Where-Object {
    $_.Name -ne "concepts" -and (Test-Path (Join-Path $_.FullName "SKILL.md"))
}

if ($skillDirs.Count -eq 0) {
    Write-Error "No skills with SKILL.md found under $SourceDir"
}

if (-not (Test-Path $ConceptsSource)) {
    Write-Error "Concepts directory not found: $ConceptsSource"
}

function Sync-Item {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [string]$Label,
        [switch]$AsLink
    )

    if ($AsLink) {
        if (Test-Path $DestPath) {
            $item = Get-Item $DestPath -Force
            if ($item.LinkType) {
                if ($item.Target -eq $SourcePath) {
                    Write-Host "Linked ($Label)"
                    return
                }
                Remove-Item $DestPath -Force
            } else {
                Remove-Item $DestPath -Recurse -Force
            }
        }
        New-Item -ItemType Junction -Path $DestPath -Target $SourcePath | Out-Null
        Write-Host "Linked ($Label)"
    } else {
        if (Test-Path $DestPath) {
            Remove-Item $DestPath -Recurse -Force
        }
        Copy-Item -Path $SourcePath -Destination $DestPath -Recurse -Force
        Write-Host "Copied ($Label)"
    }
}

foreach ($TargetDir in $Targets) {
  New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
  $synced = @()

  foreach ($skill in $skillDirs) {
    $dest = Join-Path $TargetDir $skill.Name
    Sync-Item -SourcePath $skill.FullName -DestPath $dest -Label "$TargetDir`: $($skill.Name)" -AsLink:$Link
    $synced += $skill.Name
  }

  $conceptsDest = Join-Path $TargetDir "concepts"
  Sync-Item -SourcePath $ConceptsSource -DestPath $conceptsDest -Label "$TargetDir`: concepts" -AsLink:$Link
  $synced += "concepts"

  if ($Prune) {
    $existing = Get-ChildItem -Path $TargetDir -Directory -ErrorAction SilentlyContinue
    foreach ($dir in $existing) {
      if ($dir.Name -notin $synced) {
        Write-Host "Pruning ($TargetDir): $($dir.Name)"
        Remove-Item $dir.FullName -Recurse -Force
      }
    }
  }

  Write-Host "Synced $($synced.Count) item(s) to $TargetDir"
}

Write-Host ""
if (-not $Link) {
  Write-Host "Tip: use -Link for live edits without re-syncing (requires Windows Developer Mode or admin)."
}
Write-Host "Tip: for project installs, prefer: npx skills add marcuskrogh/skills"
