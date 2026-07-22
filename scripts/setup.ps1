# One-time local setup for authors of this skills repo.
# Usage: .\scripts\setup.ps1 [-Link]
#
# Prefer project installs via: npx skills add marcuskrogh/cursor-skills

param([switch]$Link)

$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $RepoRoot

Write-Host "=== Agent skills setup ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/3] Validating skills..."
& (Join-Path $PSScriptRoot "validate-skills.ps1")
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "[2/3] Syncing to local agent skill directories..."
$syncArgs = @("-Prune")
if ($Link) { $syncArgs += "-Link" }
& (Join-Path $PSScriptRoot "sync-local.ps1") @syncArgs

Write-Host ""
Write-Host "[3/3] Installing git hooks..."
git config core.hooksPath .githooks
Write-Host "  core.hooksPath = .githooks"

Write-Host ""
Write-Host "=== Local setup complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Skills mirrored under ~/.agents/skills (and other detected agent homes)." -ForegroundColor Cyan
$agentsHome = Join-Path $env:USERPROFILE ".agents\skills"
if (Test-Path $agentsHome) {
    Get-ChildItem $agentsHome -Directory | ForEach-Object {
        Write-Host "  - $($_.Name)"
    }
}
Write-Host ""
Write-Host "Project install (any Agent Skills harness):" -ForegroundColor Yellow
Write-Host "  npx skills add marcuskrogh/cursor-skills"
Write-Host ""
Write-Host "Optional Claude Code plugin:" -ForegroundColor Yellow
Write-Host "  claude plugin marketplace add marcuskrogh/cursor-skills"
Write-Host "  claude plugin install marcus-skills@marcuskrogh"
Write-Host ""
Write-Host "Workflow: edit skills/<name>/, then:" -ForegroundColor Cyan
Write-Host "  .\scripts\validate-skills.ps1"
Write-Host "  git add . && git commit -m '...' && git push"
Write-Host "  (local mirrors update automatically on git pull)"
