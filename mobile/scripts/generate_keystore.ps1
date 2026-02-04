<#
Generate an Android keystore (.jks) on Windows using keytool.

Usage:
  .\generate_keystore.ps1 -OutputPath "android\app\oblns-release-key.jks" -Alias "oblns"

Note: Requires JDK (keytool) available on PATH.
#>
param(
  [string]$OutputPath = "android\app\oblns-release-key.jks",
  [string]$Alias = "oblns",
  [int]$ValidityDays = 10000
)

if (Test-Path $OutputPath) {
  Write-Host "Keystore already exists at $OutputPath" -ForegroundColor Yellow
  exit 0
}

$storePass = Read-Host -AsSecureString "Enter keystore password"
$storePassPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
  [Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePass)
)

$keyPass = Read-Host -AsSecureString "Enter key password (press Enter to use keystore password)"
if ($keyPass.Length -eq 0) {
  $keyPassPlain = $storePassPlain
} else {
  $keyPassPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPass)
  )
}

$dname = Read-Host "Enter Distinguished Name (e.g. CN=Your Name, OU=Dev, O=Company, L=City, S=State, C=XX)"
if ([string]::IsNullOrWhiteSpace($dname)) {
  $dname = "CN=Oblns, OU=Engineering, O=Oblns Ltd, L=Tripoli, S=Libya, C=LY"
}

$keytool = "keytool"

Write-Host "Generating keystore at $OutputPath..."
& $keytool -genkeypair -v -keystore $OutputPath -alias $Alias -keyalg RSA -keysize 2048 -validity $ValidityDays -storepass $storePassPlain -keypass $keyPassPlain -dname $dname

if ($LASTEXITCODE -eq 0) {
  Write-Host "Keystore generated: $OutputPath" -ForegroundColor Green
  Write-Host "Update android/key.properties with the values (storeFile path should be relative to repo root)."
} else {
  Write-Error "keytool failed. Ensure JDK is installed and keytool is on PATH."
}
