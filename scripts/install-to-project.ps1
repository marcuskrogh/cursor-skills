# Install skills from this repo into a project's agent skill directories.
# Prefer: npx skills add marcuskrogh/cursor-skills
#
# Usage:
#   .\scripts\install-to-project.ps1 -ProjectPath C:\path\to\repo
#   .\scripts\install-to-project.ps1 -ProjectPath C:\path\to\repo -Skill explore,design
#   .\scripts\install-to-project.ps1 -ProjectPath C:\path\to\repo -Target agents
#
# -Target agents  → .agents/skills/ (Cursor / Copilot / Codex project default)
# -Target cursor  → .cursor/skills/ (legacy Cursor project path)
# -Target both    → both (default)

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [string[]]$Skill = @(),

    [ValidateSet("agents", "cursor", "both")]
    [string]$Target = "both",

    [switch]$All
)

$ErrorActionPreference = "Stop"

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
$SourceDir = Join-Path $RepoRoot "skills"

if (-not (Test-Path -LiteralPath $ProjectPath)) {
    Write-Error "Project path not found: $ProjectPath"
}
$ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path

if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory not found: $SourceDir"
}

$targetDirs = @()
switch ($Target) {
    "agents" { $targetDirs = @((Join-Path $ProjectPath ".agents\skills")) }
    "cursor" { $targetDirs = @((Join-Path $ProjectPath ".cursor\skills")) }
    "both" {
        $targetDirs = @(
            (Join-Path $ProjectPath ".agents\skills"),
            (Join-Path $ProjectPath ".cursor\skills")
        )
    }
}

$available = Get-ChildItem -Path $SourceDir -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName "SKILL.md")
}

if ($All -or $Skill.Count -eq 0) {
    $toInstall = $available
} else {
    $toInstall = $available | Where-Object { $_.Name -in $Skill }
    $missing = $Skill | Where-Object { $_ -notin ($available.Name) }
    foreach ($name in $missing) {
        Write-Warning "Skill not found in repo: $name"
    }
}

foreach ($TargetDir in $targetDirs) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

    foreach ($skill in $toInstall) {
        $dest = Join-Path $TargetDir $skill.Name
        if (Test-Path $dest) {
            Remove-Item $dest -Recurse -Force
        }
        Copy-Item -Path $skill.FullName -Destination $dest -Recurse -Force
        Write-Host "Installed to $($TargetDir): $($skill.Name)"
    }

    Write-Host "Installed $($toInstall.Count) skill(s) to $TargetDir"
}

Write-Host ""
Write-Host "Prefer the universal installer when possible:"
Write-Host "  npx skills add marcuskrogh/cursor-skills"
Write-Host "Commit .agents/skills/ (and/or .cursor/skills/) to share with cloud agents and your team."
