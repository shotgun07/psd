# Generate SHA-1 and SHA-256 fingerprints from a JKS keystore on Windows
param(
  [string]$KeystorePath = "android/app/oblns-release-key.jks",
  [string]$Alias = "oblns"
)

if (-not (Test-Path $KeystorePath)) {
  Write-Error "Keystore not found at $KeystorePath. Create one with keytool or place it there."
  exit 1
}

# Use keytool (from JDK) to print fingerprints
$keytool = "keytool"

$keytoolArgs = "-list -v -keystore \"$KeystorePath\" -alias $Alias"
Write-Output "Running: $keytool $keytoolArgs"
& $keytool -list -v -keystore $KeystorePath -alias $Alias

Write-Output "If keytool is not found, install JDK and ensure keytool is on PATH."
Write-Output "Use the SHA-1 value above when configuring OAuth client in Google Cloud Console and Firebase."