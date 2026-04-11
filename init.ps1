#!pwsh

param(
    [Parameter(Position=0)]
    [string]$Command,

    [Parameter(ValueFromRemainingArguments=$true)]
    $Args
)

function Invoke-Dispatcher {
    param($Command, $Args)

    if (-not $Command) {
        $Command = "main"
    }

    $normalized = $Command.Substring(0,1).ToUpper() + $Command.Substring(1)

    $fn = "Invoke-$normalized"

    if (Get-Command $fn -CommandType Function -ErrorAction SilentlyContinue) {
        & $fn @Args
    }
    else {
        Write-Error "Unknown subcommand: $Command"
        exit 1
    }
}

function Invoke-Help {
  Write-Host "Available commands:`n"

  Get-Command -CommandType Function |
    Where-Object {
        $_.Name -like "Invoke-*" -and
        $_.Name -notlike "Invoke-Dispatcher" -and
        $_.Source -eq ""
    } |
    ForEach-Object {
        $_.Name.Replace("Invoke-", "").ToLower()
    } |
    Sort-Object |
    ForEach-Object { "  $_" }

  Write-Host "`nUsage:"
  Write-Host "  script.ps1 <command> [args]"
}

function Invoke-Main {
  if (-not [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform(
    [System.Runtime.InteropServices.OSPlatform]::Windows)) {
    Write-Error "This script must be run on Windows."
    exit 1
  }

  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "winget is not installed or not in PATH."
    exit 1
  }

  if (-not (Get-Command nu -ErrorAction SilentlyContinue)) {
    Write-Host "Nushell not found. Installing via winget..."

    winget install `
      --id Nushell.Nushell `
      -e `
      --accept-package-agreements `
      --accept-source-agreements

    if ($LASTEXITCODE -ne 0) {
      Write-Error "Failed to install Nushell."
      exit 1
    }

    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
  }

  $scriptDir = $PSScriptRoot
  $initFile = Join-Path $scriptDir "init.nu"

  if (-not (Test-Path $initFile)) {
    Write-Error "init.nu not found at $initFile"
    exit 1
  }

  nu $initFile

  if ($LASTEXITCODE -ne 0) {
    Write-Error "init.nu execution failed."
    exit 1
  }

  Write-Host "Done."
}

Invoke-Dispatcher $Command $Args
