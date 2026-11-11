param([string]$Generator = 'Visual Studio 17 2022')
$ErrorActionPreference = 'Stop'
$projectRoot = $PSScriptRoot
$cmakeCommand = Get-Command cmake -ErrorAction SilentlyContinue
if ($cmakeCommand) { $cmakePath = $cmakeCommand.Source }
else {
    $candidates = @(
        'C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe',
        'C:\Program Files\Microsoft Visual Studio\18\Community\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
    )
    $cmakePath = $candidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
}
if (!$cmakePath) { throw 'Install Visual Studio Desktop development with C++ and CMake tools, or add CMake to PATH.' }
$buildPath = Join-Path $projectRoot 'out\script-build'
& $cmakePath -S $projectRoot -B $buildPath -G $Generator -A x64
if ($LASTEXITCODE -ne 0) { throw 'CMake configuration failed. Check the installed Visual Studio version and -Generator.' }
& $cmakePath --build $buildPath --config Release --target ForestHome -- /m:1 /nr:false
if ($LASTEXITCODE -ne 0) { throw 'Compilation failed.' }
$binPath = Join-Path $projectRoot 'bin'
New-Item -ItemType Directory -Force $binPath | Out-Null
Copy-Item -LiteralPath (Join-Path $buildPath 'bin\Release\ForestHome.exe') -Destination $binPath -Force
Copy-Item -LiteralPath (Join-Path $buildPath 'bin\Release\shaders') -Destination $binPath -Recurse -Force
Write-Host 'Build completed. Launch Run_ForestHome.cmd.'
