# Bootstrap Ollama as a local LLM backend (Windows PowerShell variant).
# Bash equivalent: ollama-up.sh
#
# Usage:
#   .\3-playbook\act\script\ollama-up.ps1 [model-name]

param(
    [string]$ModelName = "workspace-default"
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path
Set-Location $RepoRoot

$Modelfile = "$RepoRoot\4-control\runtime\ollama\Modelfile"
$EnvFile   = "$RepoRoot\4-control\runtime\ollama\env"

if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) {
    Write-Error "ollama CLI not found in PATH. Install from https://ollama.com"
    exit 1
}

if (-not (Test-Path $Modelfile)) {
    Write-Error "no Modelfile at $Modelfile"
    Write-Host "hint: create one. See WORKSPACE.md and runtime-integration.md." -ForegroundColor Yellow
    exit 2
}

if (Test-Path $EnvFile) {
    Get-Content $EnvFile | ForEach-Object {
        if ($_ -match '^\s*([^=#\s]+)\s*=\s*(.*)$') {
            [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], "Process")
        }
    }
}

try { ollama list | Out-Null } catch {
    Write-Host "ollama server not reachable; starting via 'ollama serve' in background." -ForegroundColor Yellow
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden
    Start-Sleep -Seconds 2
}

Write-Host "building model '$ModelName' from $Modelfile"
ollama create $ModelName -f $Modelfile
if ($LASTEXITCODE -ne 0) { Write-Error "ollama create failed"; exit 3 }

$Host_ = if ($env:OLLAMA_HOST) { $env:OLLAMA_HOST } else { "localhost:11434" }
Write-Host "ready: ollama run $ModelName"
Write-Host "       OpenAI-compat: http://$Host_/v1"
Write-Host "       Anthropic-compat (Claude Code): http://$Host_"
