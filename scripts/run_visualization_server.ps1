[CmdletBinding()]
param(
    [string]$BindAddress = "127.0.0.1",

    [ValidateRange(1, 65535)]
    [int]$Port = 8080,

    [ValidateNotNullOrEmpty()]
    [string]$AllowOrigin = "http://localhost:5173",

    [ValidateRange(1, 65535)]
    [int]$Workers = [Math]::Max(2, [Math]::Min(8, [Environment]::ProcessorCount)),

    [ValidateRange(1, 65535)]
    [int]$TimeoutSeconds = 120,

    [ValidatePattern('^[1-9][0-9]*[kKmMgG]$')]
    [string]$WorkerHeap = "1g",

    [string]$BuildDirectory,

    [switch]$CompileOnly
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Get-RequiredCommand {
    param([Parameter(Mandatory = $true)][string]$Name)

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -eq $command) {
        throw "Required command '$Name' was not found. Install a Java 17 or newer JDK and add its bin directory to PATH."
    }
    return $command.Source
}

function ConvertTo-JavacArgFileValue {
    param([Parameter(Mandatory = $true)][string]$Value)

    $normalized = $Value.Replace('\', '/')
    $escaped = $normalized.Replace('"', '\"')
    return '"' + $escaped + '"'
}

$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$Repo = [IO.Path]::GetFullPath((Join-Path $ScriptDirectory ".."))
$SourceDirectory = Join-Path $Repo "src"
$LibraryDirectory = Join-Path $Repo "lib"

if ([string]::IsNullOrWhiteSpace($BuildDirectory)) {
    $BuildDirectory = Join-Path $Repo "build\visualization-server"
} elseif (-not [IO.Path]::IsPathRooted($BuildDirectory)) {
    $BuildDirectory = [IO.Path]::GetFullPath((Join-Path $Repo $BuildDirectory))
} else {
    $BuildDirectory = [IO.Path]::GetFullPath($BuildDirectory)
}

if (-not (Test-Path -LiteralPath $SourceDirectory -PathType Container)) {
    throw "Java source directory not found: $SourceDirectory"
}
if (-not (Test-Path -LiteralPath $LibraryDirectory -PathType Container)) {
    throw "Java library directory not found: $LibraryDirectory"
}

$LibraryFiles = @(Get-ChildItem -LiteralPath $LibraryDirectory -Recurse -File -Filter "*.jar" |
    Sort-Object -Property FullName)
if ($LibraryFiles.Count -eq 0) {
    throw "No dependency JARs were found under $LibraryDirectory"
}
$DependencyClasspath = ($LibraryFiles | ForEach-Object { $_.FullName }) -join [IO.Path]::PathSeparator
Write-Verbose "Dependency classpath: $DependencyClasspath"

$Javac = Get-RequiredCommand "javac"
$Java = Get-RequiredCommand "java"
$JavacVersion = (& $Javac -version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) {
    throw "Unable to run javac: $JavacVersion"
}
if ($JavacVersion -notmatch '(\d+)(?:\.\d+)*') {
    throw "Unable to determine the javac version from: $JavacVersion"
}
if ([int]$Matches[1] -lt 17) {
    throw "Java 17 or newer is required; found $JavacVersion"
}

$SourceFiles = @(Get-ChildItem -LiteralPath $SourceDirectory -Recurse -File -Filter "*.java" |
    Sort-Object -Property FullName)
if ($SourceFiles.Count -eq 0) {
    throw "No Java source files were found under $SourceDirectory"
}

if (Test-Path -LiteralPath $BuildDirectory) {
    Remove-Item -LiteralPath $BuildDirectory -Recurse -Force
}
New-Item -ItemType Directory -Path $BuildDirectory -Force | Out-Null

$ArgumentFile = Join-Path $BuildDirectory "javac.args"
$CompilerArguments = [System.Collections.Generic.List[string]]::new()
$CompilerArguments.Add("-encoding")
$CompilerArguments.Add("UTF-8")
$CompilerArguments.Add("--release")
$CompilerArguments.Add("17")
$CompilerArguments.Add("--add-modules")
$CompilerArguments.Add("jdk.httpserver")
$CompilerArguments.Add("-classpath")
$CompilerArguments.Add((ConvertTo-JavacArgFileValue $DependencyClasspath))
$CompilerArguments.Add("-d")
$CompilerArguments.Add((ConvertTo-JavacArgFileValue $BuildDirectory))
foreach ($source in $SourceFiles) {
    $CompilerArguments.Add((ConvertTo-JavacArgFileValue $source.FullName))
}

$Utf8WithoutBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllLines($ArgumentFile, $CompilerArguments, $Utf8WithoutBom)

Write-Host "Compiling $($SourceFiles.Count) Java sources with $JavacVersion ..."
Write-Host "Using $($LibraryFiles.Count) dependency JARs from $LibraryDirectory"
& $Javac "@$ArgumentFile"
if ($LASTEXITCODE -ne 0) {
    throw "javac failed with exit code $LASTEXITCODE. Compiler arguments are retained in $ArgumentFile"
}

if ($CompileOnly) {
    Write-Host "Visualization server compiled successfully into $BuildDirectory"
    return
}

$RuntimeClasspath = $BuildDirectory + [IO.Path]::PathSeparator + $DependencyClasspath
$ServerArguments = @(
    "--add-modules", "jdk.httpserver",
    "-cp", $RuntimeClasspath,
    "is.fivefivefive.CanDis.VisualizationServer",
    "--bind", $BindAddress,
    "--port", $Port.ToString([Globalization.CultureInfo]::InvariantCulture),
    "--allow-origin", $AllowOrigin,
    "--workers", $Workers.ToString([Globalization.CultureInfo]::InvariantCulture),
    "--timeout-seconds", $TimeoutSeconds.ToString([Globalization.CultureInfo]::InvariantCulture),
    "--worker-heap", $WorkerHeap
)

Write-Host "Starting the visualization API at http://${BindAddress}:${Port}/api/v1/"
Write-Host "Allowed browser origin: $AllowOrigin"
Write-Host "Analysis workers: $Workers; timeout: ${TimeoutSeconds}s; heap per worker: $WorkerHeap"
& $Java @ServerArguments
if ($LASTEXITCODE -ne 0) {
    throw "VisualizationServer exited with code $LASTEXITCODE"
}
