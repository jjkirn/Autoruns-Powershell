#
# Create Self-Signed Certificate
#
New-SelfSignedCertificate -CertStoreLocation Cert:\CurrentUser\My `
-Subject "CN=Local Code Signing" `
-KeyAlgorithm RSA `
-KeyLength 2048 `
-Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" `
-KeyExportPolicy Exportable `
-KeyUsage DigitalSignature `
-Type CodeSigningCert
