powershell.exe -NoProfile -ExecutionPolicy unrestricted -Command "& { Import-Module '.\psakev4\psake.psm1'; Invoke-psake ci; if ($lastexitcode -ne 0) {write-host "ERROR: $lastexitcode" -fore RED; exit $lastexitcode} }" 