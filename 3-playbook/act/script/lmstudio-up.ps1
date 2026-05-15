# Bootstrap LM Studio as a local LLM backend (Windows PowerShell variant).
# Bash equivalent: lmstudio-up.sh
#
# Usage:
#   .\3-playbook\act\script\lmstudio-up.ps1 [model-identifier] [port]

param(
    [string]$Model = "",
    [int]$Port = 1234
)

$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path "$PSScriptRoot\..\..\..").Path
$LmStudioDir = "$RepoRoot\4-control\runtime\lmstudio"

if (-not (Get-Command lms -ErrorAction SilentlyContinue)) {
    Write-Error "lms CLI not found in PATH."
    Write-Host "  Install LM Studio (https://lmstudio.ai) and launch it once" -ForegroundColor Yellow
    Write-Host "  to register the CLI." -ForegroundColor Yellow
    exit 1
}

$status = & lms server status --quiet 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "lms server already running on port $Port"
} else {
    Write-Host "starting lms server on port $Port (CORS enabled)"
    & lms server start --port $Port --cors
    if ($LASTEXITCODE -ne 0) { Write-Error "lms server start failed"; exit 2 }
}

if ($Model) {
    Write-Host "loading model: $Model"
    & lms load $Model
    if ($LASTEXITCODE -ne 0) { Write-Error "lms load failed for $Model"; exit 3 }
}

if (Test-Path "$LmStudioDir\presets") {
    Write-Host "workspace presets available at: $LmStudioDir\presets\"
}
if (Test-Path "$LmStudioDir\mcp.json") {
    Write-Host "workspace MCP config: $LmStudioDir\mcp.json"
    Write-Host "  apply via LM Studio: Program tab → Install → Edit mcp.json"
}

Write-Host "ready:"
Write-Host "  OpenAI-compat:        http://localhost:$Port/v1"
Write-Host "  Anthropic-compat:     http://localhost:$Port  (Claude Code: ANTHROPIC_BASE_URL=http://localhost:$Port, ANTHROPIC_AUTH_TOKEN=lmstudio)"
Write-Host "  Native LM Studio API: http://localhost:$Port/api/v1"
