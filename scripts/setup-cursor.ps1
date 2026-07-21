# One-time local setup for this machine (Cursor + other agents).
# Usage: .\scripts\setup-cursor.ps1 [-Link]
#
# Prefer project installs via: npx skills add marcuskrogh/cursor-skills

param([switch]$Link)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $RepoRoot

Write-Host "=== Agent skills setup ===" -ForegroundColor Cyan
Write-Host ""

# 1. Validate
Write-Host "[1/3] Validating skills..."
& (Join-Path $PSScriptRoot "validate-skills.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 2. Sync to local agent skill dirs
Write-Host ""
Write-Host "[2/3] Syncing to local agent skill directories..."
$syncArgs = @("-Prune")
if ($Link) { $syncArgs += "-Link" }
& (Join-Path $PSScriptRoot "sync-local.ps1") @syncArgs

# 3. Install git hook so pull auto-syncs local skills
Write-Host ""
Write-Host "[3/3] Installing git hooks..."
$hooksDir = Join-Path $RepoRoot ".githooks"
git config core.hooksPath .githooks
Write-Host "  core.hooksPath = .githooks"

Write-Host ""
Write-Host "=== Local setup complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Skills on this machine (Cursor):" -ForegroundColor Cyan
Get-ChildItem (Join-Path $env:USERPROFILE ".cursor\skills") -Directory | ForEach-Object {
    Write-Host "  - $($_.Name)"
}
Write-Host ""
Write-Host "Cross-platform project install:" -ForegroundColor Yellow
Write-Host "  npx skills add marcuskrogh/cursor-skills"
Write-Host ""
Write-Host "Claude Code plugin:" -ForegroundColor Yellow
Write-Host "  claude plugin marketplace add marcuskrogh/cursor-skills"
Write-Host "  claude plugin install marcus-skills@marcuskrogh"
Write-Host ""
Write-Host "Workflow: edit skills in this repo under skills/, then:" -ForegroundColor Cyan
Write-Host "  .\scripts\validate-skills.ps1"
Write-Host "  git add . && git commit -m '...' && git push"
Write-Host "  (local mirrors update automatically on git pull)"
