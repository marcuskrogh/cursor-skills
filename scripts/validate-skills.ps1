# Validate SKILL.md files in this repo.
# Usage: .\scripts\validate-skills.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$SkillsDir = Join-Path $RepoRoot "skills"
$errors = 0

if (-not (Test-Path $SkillsDir)) {
    Write-Error "Skills directory not found: $SkillsDir"
}

function Test-SkillFrontmatter {
    param([string]$Path)

    $content = Get-Content -Path $Path -Raw
    if ($content -notmatch '(?s)^---\s*\r?\n(.*?)\r?\n---') {
        Write-Host "FAIL: Missing YAML frontmatter - $Path"
        return $false
    }

    $yaml = $Matches[1]
    $ok = $true

    if ($yaml -notmatch '(?m)^name:\s*(.+)$') {
        Write-Host "FAIL: Missing name field - $Path"
        $ok = $false
    } else {
        $name = $Matches[1].Trim().Trim('"').Trim("'")
        if ($name -notmatch '^[a-z0-9-]+$') {
            Write-Host "FAIL: Invalid name '$name' - $Path"
            $ok = $false
        }
        $folder = Split-Path (Split-Path $Path -Parent) -Leaf
        if ($name -ne $folder) {
            Write-Host "FAIL: name '$name' does not match folder '$folder' - $Path"
            $ok = $false
        }
    }

    if ($yaml -notmatch '(?m)^description:\s*(.+)$') {
        Write-Host "FAIL: Missing description field - $Path"
        $ok = $false
    }

    $lines = (Get-Content -Path $Path).Count
    if ($lines -gt 500) {
        Write-Host "WARN: SKILL.md exceeds 500 lines ($lines) - $Path"
    }

    if ($ok) {
        Write-Host "OK: $Path"
    }
    return $ok
}

Get-ChildItem -Path $SkillsDir -Recurse -Filter "SKILL.md" | ForEach-Object {
    if (-not (Test-SkillFrontmatter -Path $_.FullName)) {
        $script:errors++
    }
}

$pluginJson = Join-Path $RepoRoot ".claude-plugin\plugin.json"
if (Test-Path $pluginJson) {
    $plugin = Get-Content $pluginJson -Raw | ConvertFrom-Json
    $declared = @($plugin.skills)
    $onDisk = Get-ChildItem -Path $SkillsDir -Directory | Where-Object {
        Test-Path (Join-Path $_.FullName "SKILL.md")
    } | ForEach-Object { "./skills/$($_.Name)" }

    foreach ($path in $declared) {
        $abs = Join-Path $RepoRoot ($path -replace '^\./', '' -replace '/', '\')
        if (-not (Test-Path (Join-Path $abs "SKILL.md"))) {
            Write-Host "FAIL: plugin.json declares missing skill: $path"
            $script:errors++
        }
    }

    foreach ($path in $onDisk) {
        if ($path -notin $declared) {
            Write-Host "WARN: skill on disk not declared in plugin.json: $path"
        }
    }
} else {
    Write-Host "WARN: .claude-plugin/plugin.json missing"
}

if ($errors -gt 0) {
    Write-Host ""
    Write-Host "Validation failed with $errors error(s)."
    exit 1
}

Write-Host ""
Write-Host "All skills validated."
