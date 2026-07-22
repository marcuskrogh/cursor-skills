# Sync skills from this repo to local agent skill directories.
# Usage: .\scripts\sync-local.ps1 [-Prune] [-Link]
#
# Default targets are common Agent Skills home dirs across popular harnesses.
# Override with -Targets. For project installs, prefer: npx skills add marcuskrogh/cursor-skills

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

if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory not found: $SourceDir"
}

$skillDirs = Get-ChildItem -Path $SourceDir -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName "SKILL.md")
}

if ($skillDirs.Count -eq 0) {
    Write-Error "No skills with SKILL.md found under $SourceDir"
}

foreach ($TargetDir in $Targets) {
  New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
  $synced = @()

  foreach ($skill in $skillDirs) {
    $dest = Join-Path $TargetDir $skill.Name

    if ($Link) {
      if (Test-Path $dest) {
        $item = Get-Item $dest -Force
        if ($item.LinkType) {
          if ($item.Target -eq $skill.FullName) {
            Write-Host "Linked ($TargetDir): $($skill.Name)"
            $synced += $skill.Name
            continue
          }
          Remove-Item $dest -Force
        } else {
          Remove-Item $dest -Recurse -Force
        }
      }
      New-Item -ItemType Junction -Path $dest -Target $skill.FullName | Out-Null
      Write-Host "Linked ($TargetDir): $($skill.Name)"
    } else {
      if (Test-Path $dest) {
        Remove-Item $dest -Recurse -Force
      }
      Copy-Item -Path $skill.FullName -Destination $dest -Recurse -Force
      Write-Host "Copied ($TargetDir): $($skill.Name)"
    }

    $synced += $skill.Name
  }

  if ($Prune) {
    $existing = Get-ChildItem -Path $TargetDir -Directory -ErrorAction SilentlyContinue
    foreach ($dir in $existing) {
      if ($dir.Name -notin $synced) {
        Write-Host "Pruning ($TargetDir): $($dir.Name)"
        Remove-Item $dir.FullName -Recurse -Force
      }
    }
  }

  Write-Host "Synced $($synced.Count) skill(s) to $TargetDir"
}

Write-Host ""
if (-not $Link) {
  Write-Host "Tip: use -Link for live edits without re-syncing (requires Windows Developer Mode or admin)."
}
Write-Host "Tip: for project installs, prefer: npx skills add marcuskrogh/cursor-skills"
