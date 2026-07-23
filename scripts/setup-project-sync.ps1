# Bootstrap a project to fetch skills at environment startup (CI / cloud / VM).
# Writes an Agent Skills–standard sync script under .agents/ and gitignores the install dir.
#
# Usage:
#   .\scripts\setup-project-sync.ps1 -ProjectPath D:\code\MyRepo
#   .\scripts\setup-project-sync.ps1 -ProjectPath D:\code\MyRepo -WireCursorCloud
#
# Prefer interactive installs when possible:
#   npx skills add marcuskrogh/skills

param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [string]$SkillsRepo = "https://github.com/marcuskrogh/skills.git",

    # Also write .cursor/environment.json so Cursor Cloud runs the sync on VM start.
    [switch]$WireCursorCloud,

    [switch]$SkipGitignore
)

$ErrorActionPreference = "Stop"

$TemplateRoot = Resolve-Path (Join-Path $PSScriptRoot "..\templates\project-sync")
if (-not (Test-Path $TemplateRoot)) {
    Write-Error "Template directory not found: $TemplateRoot"
}

if (-not (Test-Path -LiteralPath $ProjectPath)) {
    Write-Error "Project path not found: $ProjectPath"
}
$ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path

$agentsDir = Join-Path $ProjectPath ".agents"
New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null

$syncScript = Join-Path $agentsDir "sync-skills.sh"
Copy-Item (Join-Path $TemplateRoot "sync-skills.sh") $syncScript -Force
(Get-Content $syncScript -Raw) -replace 'https://github.com/marcuskrogh/skills.git', $SkillsRepo |
    Set-Content $syncScript -NoNewline

if (-not $SkipGitignore) {
    $gitignore = Join-Path $ProjectPath ".gitignore"
    $marker = "# Synced agent skills at environment startup — do not commit"
    $entry = ".agents/skills/"
    if (Test-Path $gitignore) {
        $existing = Get-Content $gitignore -Raw
        if ($existing -notmatch [regex]::Escape($entry)) {
            Add-Content -Path $gitignore -Value ""
            Add-Content -Path $gitignore -Value $marker
            Add-Content -Path $gitignore -Value $entry
        }
    } else {
        Set-Content -Path $gitignore -Value "$marker`n$entry"
    }
}

if ($WireCursorCloud) {
    $cursorDir = Join-Path $ProjectPath ".cursor"
    New-Item -ItemType Directory -Force -Path $cursorDir | Out-Null
    $envJson = Join-Path $cursorDir "environment.json"
    $installCmd = "bash .agents/sync-skills.sh"
    if (Test-Path $envJson) {
        Write-Warning "environment.json already exists — merge install steps manually:"
        Write-Warning "  $installCmd && <your existing install>"
    } else {
        $content = @"
{
  "install": "$installCmd"
}
"@
        Set-Content -Path $envJson -Value $content -NoNewline
        Add-Content -Path $envJson -Value ""
    }
}

Write-Host "Project skill sync installed:"
Write-Host "  $syncScript"
Write-Host "Commit .agents/sync-skills.sh and .gitignore"
if ($WireCursorCloud) {
    Write-Host "Also commit .cursor/environment.json (Cursor Cloud adapter)"
}
Write-Host ""
Write-Host "Sync / update to latest main (or another ref):"
Write-Host "  bash .agents/sync-skills.sh"
Write-Host "  SKILLS_REF=main bash .agents/sync-skills.sh          # explicit latest main"
Write-Host "  SKILLS_REF=<tag-or-sha> bash .agents/sync-skills.sh # pin a version"
Write-Host "Installed revision is recorded in .agents/skills/.skills-version"
Write-Host ""
Write-Host "Universal install (preferred for interactive use):"
Write-Host "  npx skills add marcuskrogh/skills"
Write-Host "  npx skills update -y   # later: pull latest for installed skills"
