# Validate SKILL.md files and CONCEPT_*.md files in this repo.
# Usage: .\scripts\validate-skills.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$SkillsDir = Join-Path $RepoRoot "skills"
$ConceptsDir = Join-Path $SkillsDir "concepts"
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
    $parentName = Split-Path $_.DirectoryName -Leaf
    if ($parentName -eq "concepts") {
        Write-Host "FAIL: concepts/ must not contain SKILL.md - $($_.FullName)"
        $script:errors++
        return
    }
    if (-not (Test-SkillFrontmatter -Path $_.FullName)) {
        $script:errors++
    }
}

if (-not (Test-Path $ConceptsDir)) {
    Write-Host "FAIL: Missing concepts directory: $ConceptsDir"
    $script:errors++
} else {
    $conceptFiles = Get-ChildItem -Path $ConceptsDir -File -Filter "CONCEPT_*.md"
    if ($conceptFiles.Count -eq 0) {
        Write-Host "FAIL: No CONCEPT_*.md files in $ConceptsDir"
        $script:errors++
    }
    foreach ($cf in $conceptFiles) {
        if ($cf.Name -notmatch '^CONCEPT_[A-Z0-9_]+\.md$') {
            Write-Host "FAIL: Invalid concept filename '$($cf.Name)' (expected CONCEPT_<NAME>.md)"
            $script:errors++
        } else {
            Write-Host "OK: $($cf.FullName)"
        }
    }
    Get-ChildItem -Path $ConceptsDir -File | Where-Object {
        $_.Name -notlike "CONCEPT_*.md" -and $_.Name -ne "README.md"
    } | ForEach-Object {
        Write-Host "WARN: unexpected file in concepts/: $($_.Name)"
    }
}

$pluginJson = Join-Path $RepoRoot ".claude-plugin\plugin.json"
if (Test-Path $pluginJson) {
    $plugin = Get-Content $pluginJson -Raw | ConvertFrom-Json
    $declared = @($plugin.skills)
    $onDisk = Get-ChildItem -Path $SkillsDir -Directory | Where-Object {
        $_.Name -ne "concepts" -and (Test-Path (Join-Path $_.FullName "SKILL.md"))
    } | ForEach-Object { "./skills/$($_.Name)" }

    foreach ($path in $declared) {
        $abs = Join-Path $RepoRoot ($path -replace '^\./', '' -replace '/', '\')
        if (-not (Test-Path (Join-Path $abs "SKILL.md"))) {
            Write-Host "FAIL: plugin.json declares missing skill: $path"
            $script:errors++
        }
        if ($path -match 'concepts') {
            Write-Host "FAIL: plugin.json must not declare concepts as a skill: $path"
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
Write-Host "All skills and concepts validated."
