
"Running tests"
$ErrorActionPreference = "Stop"


if ($env:APPVEYOR_BUILD_VERSION) {
  # run in CI
  $version = $env:APPVEYOR_BUILD_VERSION -replace('\.[^.\\/]+$')
} else {
  # run manually
  [xml]$spec = Get-Content vmware-powercli-psmodule.nuspec
  $version = $spec.package.metadata.version
}

"TEST: Version $version in vmware-powercli-psmodule.nuspec file should match"
[xml]$spec = Get-Content vmware-powercli-psmodule.nuspec
if ($spec.package.metadata.version.CompareTo($version)) {
  Write-Error "FAIL: Wrong version in nuspec file!"
}

"TEST: Package should contain install/uninstall scripts"
Add-Type -assembly "system.io.compression.filesystem"
$zip = [IO.Compression.ZipFile]::OpenRead("$pwd\vmware-powercli-psmodule.$version.nupkg")
# Write-Host $zip.Entries.FullName
Write-Host $zip.Entries.Count
if ($zip.Entries.Count -ne 8) {
  Write-Error "FAIL: Wrong count in nupkg!"
}
$zip.Dispose()

"TEST: Installation of package should work but may fail due to dependency requirements"
. choco install -y vmware-powercli-psmodule -source . -version $version

"TEST: Uninstallation of package should work but will fail if install failed"
. choco uninstall -y vmware-powercli-psmodule -source .

"TEST: Finished"