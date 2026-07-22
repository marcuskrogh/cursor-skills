# Install skills from this repo into a project's Agent Skills directory.
# Prefer: npx skills add marcuskrogh/cursor-skills
#
# Usage:
#   .\scripts\install-to-project.ps1 -ProjectPath C:\path\to\repo
#   .\scripts\install-to-project.ps1 -ProjectPath C:\path\to\repo -Skill explore,design
#   .\scripts\install-to-project.ps1 -ProjectPath C:\path\to\repo -TargetDir .agents\skills

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [string[]]$Skill = @(),

    # Relative to the project root. Default is the Agent Skills standard path.
    [string]$TargetDir = ".agents\skills",

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

$destRoot = if ([System.IO.Path]::IsPathRooted($TargetDir)) {
    $TargetDir
} else {
    Join-Path $ProjectPath $TargetDir
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

New-Item -ItemType Directory -Force -Path $destRoot | Out-Null

foreach ($skill in $toInstall) {
    $dest = Join-Path $destRoot $skill.Name
    if (Test-Path $dest) {
        Remove-Item $dest -Recurse -Force
    }
    Copy-Item -Path $skill.FullName -Destination $dest -Recurse -Force
    Write-Host "Installed: $($skill.Name) -> $dest"
}

Write-Host ""
Write-Host "Installed $($toInstall.Count) skill(s) to $destRoot"
Write-Host "Prefer the universal installer when possible:"
Write-Host "  npx skills add marcuskrogh/cursor-skills"
Write-Host "Commit $TargetDir to share with collaborators and cloud environments."
