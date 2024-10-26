function GenerateKey()
{
  try
  {
    $aes = [System.Security.Cryptography.Aes]::Create();
    $aesProvider = New-Object System.Security.Cryptography.AesCryptoServiceProvider;
    $aesProvider.GenerateKey();
    return $aesProvider.Key;
  }
  finally
  {
    if ($aesProvider -ne $null) { $aesProvider.Dispose(); }
    if ($aes -ne $null) { $aes.Dispose(); }
  }
}
function GenerateIV()
{
  try
  {
    $aes = [System.Security.Cryptography.Aes]::Create();
    return $aes.IV;
  }
  finally
  {
    if ($aes -ne $null) { $aes.Dispose(); }
  }
}
function EncryptFileWithIV(
  [parameter(Mandatory = $true)] [string] $sourceFile, 
  [parameter(Mandatory = $true)] [string] $targetFile, 
  [parameter(Mandatory = $true)] [byte[]] $encryptionKey, 
  [parameter(Mandatory = $true)] [byte[]] $hmacKey, 
  [parameter(Mandatory = $true)] [byte[]] $initializationVector)
{
  $bufferBlockSize = 1024 * 4;
  $computedMac = $null;

  try
  {
    $aes = [System.Security.Cryptography.Aes]::Create();
    $hmacSha256 = New-Object System.Security.Cryptography.HMACSHA256;
    $hmacSha256.Key = $hmacKey;
    $hmacLength = $hmacSha256.HashSize / 8;

    $buffer = New-Object byte[] $bufferBlockSize;
    $bytesRead = 0;

    $targetStream = [System.IO.File]::Open($targetFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read);
    $targetStream.Write($buffer, 0, $hmacLength + $initializationVector.Length);

    try
    {
      $encryptor = $aes.CreateEncryptor($encryptionKey, $initializationVector);
      $sourceStream = [System.IO.File]::Open($sourceFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read);
      $cryptoStream = New-Object System.Security.Cryptography.CryptoStream -ArgumentList @($targetStream, $encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write);

      $targetStream = $null;
      while (($bytesRead = $sourceStream.Read($buffer, 0, $bufferBlockSize)) -gt 0)
      {
        $cryptoStream.Write($buffer, 0, $bytesRead);
        $cryptoStream.Flush();
      }
      $cryptoStream.FlushFinalBlock();
    }
    finally
    {
      if ($cryptoStream -ne $null) { $cryptoStream.Dispose(); }
      if ($sourceStream -ne $null) { $sourceStream.Dispose(); }
      if ($encryptor -ne $null) { $encryptor.Dispose(); }
    }

    try
    {
      $finalStream = [System.IO.File]::Open($targetFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::Read)

      $finalStream.Seek($hmacLength, [System.IO.SeekOrigin]::Begin) > $null;
      $finalStream.Write($initializationVector, 0, $initializationVector.Length);
      $finalStream.Seek($hmacLength, [System.IO.SeekOrigin]::Begin) > $null;

      $hmac = $hmacSha256.ComputeHash($finalStream);
      $computedMac = $hmac;

      $finalStream.Seek(0, [System.IO.SeekOrigin]::Begin) > $null;
      $finalStream.Write($hmac, 0, $hmac.Length);
    }
    finally
    {
      if ($finalStream -ne $null) { $finalStream.Dispose(); }
    }
  }
  finally
  {
    if ($targetStream -ne $null) { $targetStream.Dispose(); }
    if ($aes -ne $null) { $aes.Dispose(); }
  }

  return $computedMac;
}
function EncryptFile(
  [parameter(Mandatory = $true)] [string] $sourceFile, 
  [parameter(Mandatory = $true)] [string] $targetFile)
{
  $encryptionKey = GenerateKey;
  $hmacKey = GenerateKey;
  $initializationVector = GenerateIV;

  # Create the encrypted target file and compute the HMAC value.
  $mac = EncryptFileWithIV $sourceFile $targetFile $encryptionKey $hmacKey $initializationVector;

  # Compute the SHA256 hash of the source file and convert the result to bytes.
  $fileDigest = (Get-FileHash $sourceFile -Algorithm SHA256).Hash;
  $fileDigestBytes = New-Object byte[] ($fileDigest.Length / 2);
  for ($i = 0; $i -lt $fileDigest.Length; $i += 2)
  {
    $fileDigestBytes[$i / 2] = [System.Convert]::ToByte($fileDigest.Substring($i, 2), 16);
  }

  # Return an object that will serialize correctly to the file commit Graph API.
  $encryptionInfo = @{};
  $encryptionInfo.encryptionKey = [System.Convert]::ToBase64String($encryptionKey);
  $encryptionInfo.macKey = [System.Convert]::ToBase64String($hmacKey);
  $encryptionInfo.initializationVector = [System.Convert]::ToBase64String($initializationVector);
  $encryptionInfo.mac = [System.Convert]::ToBase64String($mac);
  $encryptionInfo.profileIdentifier = "ProfileVersion1";
  $encryptionInfo.fileDigest = [System.Convert]::ToBase64String($fileDigestBytes);
  $encryptionInfo.fileDigestAlgorithm = "SHA256";

  $fileEncryptionInfo = @{};
  $fileEncryptionInfo.fileEncryptionInfo = $encryptionInfo;

  return $fileEncryptionInfo;
}

function ConvertTo-Base32String([parameter(Mandatory = $true)] [byte[]] $byteArray)
{
  Set-Variable CROCKFORS_ALPHABET -Value "0123456789abcdefghjkmnpqrstvwxyz";
  Set-Variable B32_BLOCK_SIZE -Value 5;

  $originalLength = $byteArray.Length;
  $groupsCount = [Math]::floor($originalLength / $B32_BLOCK_SIZE);
  $extraBytes = $originalLength % $B32_BLOCK_SIZE;

  $buffer = $byteArray.Clone();

  for ($i = 0; $i -lt $groupsCount; $i++)
  {
    $currentGroup = $i * $B32_BLOCK_SIZE;
    $result += $CROCKFORS_ALPHABET[($buffer[$currentGroup] -shr 3)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup] -band 0x07) -shl 2) -bor ($buffer[$currentGroup + 1] -shr 6)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 1] -band 0x3F) -shr 1)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 1] -band 0x01) -shl 4) -bor ($buffer[$currentGroup + 2] -shr 4)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 2] -band 0x0F) -shl 1) -bor ($buffer[$currentGroup + 3] -shr 7)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 3] -band 0x7C) -shr 2)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 3] -band 0x03) -shl 3) -bor ($buffer[$currentGroup + 4] -shr 5)];
    $result += $CROCKFORS_ALPHABET[(($buffer[$currentGroup + 4] -band 0x1F))];
  }

  if ( $extraBytes -gt 0 )
  {
    $endBuffer = $byteArray[($groupsCount * $B32_BLOCK_SIZE)..($originalLength - 1)];
    $currentGroup = 0;
    $result += $CROCKFORS_ALPHABET[($endBuffer[$currentGroup] -shr 3)];
    if ( $extraBytes -gt 1 )
    {
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup] -band 0x07) -shl 2) -bor ($endBuffer[$currentGroup + 1] -shr 6)];
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup + 1] -band 0x3F) -shr 1)];
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup + 1] -band 0x01) -shl 4) -bor ($endBuffer[$currentGroup + 2] -shr 4)];
    }

    if ( $extraBytes -gt 2 )
    {
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup + 2] -band 0x0F) -shl 1) -bor ($endBuffer[$currentGroup + 3] -shr 7)];
    }

    if ( $extraBytes -gt 3)
    {
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup + 3] -band 0x7C) -shr 2)];
      $result += $CROCKFORS_ALPHABET[(($endBuffer[$currentGroup + 3] -band 0x03) -shl 3) -bor ($endBuffer[$currentGroup + 4] -shr 5)];
    }
  }

  return $result;
}


# SIG # Begin signature block
# MII92wYJKoZIhvcNAQcCoII9zDCCPcgCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCAZc2hARflxx4Uv
# Z3+HW9X4siiI9bbGMCvOxATHz8EW6aCCInQwggXMMIIDtKADAgECAhBUmNLR1FsZ
# lUgTecgRwIeZMA0GCSqGSIb3DQEBDAUAMHcxCzAJBgNVBAYTAlVTMR4wHAYDVQQK
# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jvc29mdCBJZGVu
# dGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAy
# MDAeFw0yMDA0MTYxODM2MTZaFw00NTA0MTYxODQ0NDBaMHcxCzAJBgNVBAYTAlVT
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jv
# c29mdCBJZGVudGl0eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRo
# b3JpdHkgMjAyMDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALORKgeD
# Bmf9np3gx8C3pOZCBH8Ppttf+9Va10Wg+3cL8IDzpm1aTXlT2KCGhFdFIMeiVPvH
# or+Kx24186IVxC9O40qFlkkN/76Z2BT2vCcH7kKbK/ULkgbk/WkTZaiRcvKYhOuD
# PQ7k13ESSCHLDe32R0m3m/nJxxe2hE//uKya13NnSYXjhr03QNAlhtTetcJtYmrV
# qXi8LW9J+eVsFBT9FMfTZRY33stuvF4pjf1imxUs1gXmuYkyM6Nix9fWUmcIxC70
# ViueC4fM7Ke0pqrrBc0ZV6U6CwQnHJFnni1iLS8evtrAIMsEGcoz+4m+mOJyoHI1
# vnnhnINv5G0Xb5DzPQCGdTiO0OBJmrvb0/gwytVXiGhNctO/bX9x2P29Da6SZEi3
# W295JrXNm5UhhNHvDzI9e1eM80UHTHzgXhgONXaLbZ7LNnSrBfjgc10yVpRnlyUK
# xjU9lJfnwUSLgP3B+PR0GeUw9gb7IVc+BhyLaxWGJ0l7gpPKWeh1R+g/OPTHU3mg
# trTiXFHvvV84wRPmeAyVWi7FQFkozA8kwOy6CXcjmTimthzax7ogttc32H83rwjj
# O3HbbnMbfZlysOSGM1l0tRYAe1BtxoYT2v3EOYI9JACaYNq6lMAFUSw0rFCZE4e7
# swWAsk0wAly4JoNdtGNz764jlU9gKL431VulAgMBAAGjVDBSMA4GA1UdDwEB/wQE
# AwIBhjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTIftJqhSobyhmYBAcnz1AQ
# T2ioojAQBgkrBgEEAYI3FQEEAwIBADANBgkqhkiG9w0BAQwFAAOCAgEAr2rd5hnn
# LZRDGU7L6VCVZKUDkQKL4jaAOxWiUsIWGbZqWl10QzD0m/9gdAmxIR6QFm3FJI9c
# Zohj9E/MffISTEAQiwGf2qnIrvKVG8+dBetJPnSgaFvlVixlHIJ+U9pW2UYXeZJF
# xBA2CFIpF8svpvJ+1Gkkih6PsHMNzBxKq7Kq7aeRYwFkIqgyuH4yKLNncy2RtNwx
# AQv3Rwqm8ddK7VZgxCwIo3tAsLx0J1KH1r6I3TeKiW5niB31yV2g/rarOoDXGpc8
# FzYiQR6sTdWD5jw4vU8w6VSp07YEwzJ2YbuwGMUrGLPAgNW3lbBeUU0i/OxYqujY
# lLSlLu2S3ucYfCFX3VVj979tzR/SpncocMfiWzpbCNJbTsgAlrPhgzavhgplXHT2
# 6ux6anSg8Evu75SjrFDyh+3XOjCDyft9V77l4/hByuVkrrOj7FjshZrM77nq81YY
# uVxzmq/FdxeDWds3GhhyVKVB0rYjdaNDmuV3fJZ5t0GNv+zcgKCf0Xd1WF81E+Al
# GmcLfc4l+gcK5GEh2NQc5QfGNpn0ltDGFf5Ozdeui53bFv0ExpK91IjmqaOqu/dk
# ODtfzAzQNb50GQOmxapMomE2gj4d8yu8l13bS3g7LfU772Aj6PXsCyM2la+YZr9T
# 03u4aUoqlmZpxJTG9F9urJh4iIAGXKKy7aIwggbOMIIEtqADAgECAhMzAAC4wiCd
# paH8EYwDAAAAALjCMA0GCSqGSIb3DQEBDAUAMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDEwHhcNMjMxMjE0MDc1MDMyWhcNMjMxMjE3
# MDc1MDMyWjBLMQswCQYDVQQGEwJSTzEQMA4GA1UEBxMHQ3JhaW92YTEUMBIGA1UE
# ChMLQ2FwaHlvbiBTUkwxFDASBgNVBAMTC0NhcGh5b24gU1JMMIIBojANBgkqhkiG
# 9w0BAQEFAAOCAY8AMIIBigKCAYEAlAWbeMMJ+wxRFQ45nca9Y9+IbQB65s/uEbka
# EGkSMt3ONYwXV2BXbriY1kig7U+nLgjYrxZap88ZuyRiZrnne+vNSMepnHfnw2N8
# bRncrhfkqrVxlyHr670hqpdK9lQKFXDFbJxh/LmuQqFg94xQtzGGIUTGIzzIxGOn
# RsLm815nWQw0Zo/SgxliaAjfiVWNEPJKJDkiTpQRLRVikUalsXvUC6s57+BrRQri
# 34fJeeabiQyZpBkeVmPBpY89v0c58FuFADQzh6SapLNMTj6QjtEs2jlCk7DencmF
# R1jjCOAmLzkLgQyia/moayrB7cmlCnJHyOZqpImXoUCZ5rPuMe6OppAyILsnaX5m
# Fd6yCwux56gZo4kP8Zw6RdaBzhltPOj4BoeloS49kiuhnXnivBfo5t+Q1w1h42GS
# 3YMpMBeed1z0QG2uSie9j893gTMkBxi1zYF7sATyu/BLCMLC52zljqv/nb/38e8e
# GX8sYVTXU5RDKk3eRnJ+pn9SBy5dAgMBAAGjggIaMIICFjAMBgNVHRMBAf8EAjAA
# MA4GA1UdDwEB/wQEAwIHgDA9BgNVHSUENjA0BgorBgEEAYI3YQEABggrBgEFBQcD
# AwYcKwYBBAGCN2GDoY/BNoG0pZl+goH440yB/YauXTAdBgNVHQ4EFgQUzpgewFZm
# /Fox2ZNb0S0Kyf4ajt4wHwYDVR0jBBgwFoAU6IPEM9fcnwycdpoKptTfh6ZeWO4w
# ZwYDVR0fBGAwXjBcoFqgWIZWaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9w
# cy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmllZCUyMENTJTIwQU9DJTIwQ0El
# MjAwMS5jcmwwgaUGCCsGAQUFBwEBBIGYMIGVMGQGCCsGAQUFBzAChlhodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElEJTIw
# VmVyaWZpZWQlMjBDUyUyMEFPQyUyMENBJTIwMDEuY3J0MC0GCCsGAQUFBzABhiFo
# dHRwOi8vb25lb2NzcC5taWNyb3NvZnQuY29tL29jc3AwZgYDVR0gBF8wXTBRBgwr
# BgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMAgGBmeBDAEEATANBgkqhkiG
# 9w0BAQwFAAOCAgEATSrIq1+gHJOktOBIcvZG/myrn9CUXiJLA7/M1i73S7EIdcy/
# DUIJ5S8mC/yWdCMFgtO5cpqCIQz2qgFZApqKCE73SivyWmUlNGWxvnvlk95PzeGG
# pNvCmFOvprS6+6/YJE0tyMB7kcxb+t+/odmzyr36LvVvDMOID/J69QA5OrAsPEOP
# tOf8ZgIDMrv7xuSPDlrk3gP3gnaKUQfiN+A1YRDNuvjwNf968bYcQQyeZh+kyCSc
# 3En1V+aY4Ze2s78eenyk/MWQu9ptdmTxUwJ2ZtdKgVqhGnk4Prug7QeQN3Bg1hbE
# jj2ySmgtIVH+H9JWl1vUWhUrEz/Y1K98LgDry2BYR30zzJyhy28WokSsyTYVR/0D
# /f16RKKzo9Yx+6gZ5dNUOz1w2vxHYVpkpfARpvzJFV5+/5QH4j0bjhNfyl4FhqJ0
# xXGi4sGuWFRF34amngS0PtKYnq4fn2ZmNQBtUraJ3FplLNW8tUhgn3rZx/tsM7Ur
# /Ju61MYy0jy3WauM0b2Dr5RyflWkW2pdxdEyplxBiQivsFvJgHg7Gj1Nh0HCA4Xu
# tX+FNkmPvkEClq/1AGWdKD0hy30YGAo4/4UjZKb4L+9XueIy6RKIsYJ1N9mS2QOi
# kFQmjlwBqnX7+sFA7n1gMjhBgXPc60OqNVeMIoL4JKydPv79mPtrWGIc15kwggbO
# MIIEtqADAgECAhMzAAC4wiCdpaH8EYwDAAAAALjCMA0GCSqGSIb3DQEBDAUAMFox
# CzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzAp
# BgNVBAMTIk1pY3Jvc29mdCBJRCBWZXJpZmllZCBDUyBBT0MgQ0EgMDEwHhcNMjMx
# MjE0MDc1MDMyWhcNMjMxMjE3MDc1MDMyWjBLMQswCQYDVQQGEwJSTzEQMA4GA1UE
# BxMHQ3JhaW92YTEUMBIGA1UEChMLQ2FwaHlvbiBTUkwxFDASBgNVBAMTC0NhcGh5
# b24gU1JMMIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAlAWbeMMJ+wxR
# FQ45nca9Y9+IbQB65s/uEbkaEGkSMt3ONYwXV2BXbriY1kig7U+nLgjYrxZap88Z
# uyRiZrnne+vNSMepnHfnw2N8bRncrhfkqrVxlyHr670hqpdK9lQKFXDFbJxh/Lmu
# QqFg94xQtzGGIUTGIzzIxGOnRsLm815nWQw0Zo/SgxliaAjfiVWNEPJKJDkiTpQR
# LRVikUalsXvUC6s57+BrRQri34fJeeabiQyZpBkeVmPBpY89v0c58FuFADQzh6Sa
# pLNMTj6QjtEs2jlCk7DencmFR1jjCOAmLzkLgQyia/moayrB7cmlCnJHyOZqpImX
# oUCZ5rPuMe6OppAyILsnaX5mFd6yCwux56gZo4kP8Zw6RdaBzhltPOj4BoeloS49
# kiuhnXnivBfo5t+Q1w1h42GS3YMpMBeed1z0QG2uSie9j893gTMkBxi1zYF7sATy
# u/BLCMLC52zljqv/nb/38e8eGX8sYVTXU5RDKk3eRnJ+pn9SBy5dAgMBAAGjggIa
# MIICFjAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDA9BgNVHSUENjA0Bgor
# BgEEAYI3YQEABggrBgEFBQcDAwYcKwYBBAGCN2GDoY/BNoG0pZl+goH440yB/Yau
# XTAdBgNVHQ4EFgQUzpgewFZm/Fox2ZNb0S0Kyf4ajt4wHwYDVR0jBBgwFoAU6IPE
# M9fcnwycdpoKptTfh6ZeWO4wZwYDVR0fBGAwXjBcoFqgWIZWaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSUQlMjBWZXJpZmll
# ZCUyMENTJTIwQU9DJTIwQ0ElMjAwMS5jcmwwgaUGCCsGAQUFBwEBBIGYMIGVMGQG
# CCsGAQUFBzAChlhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRz
# L01pY3Jvc29mdCUyMElEJTIwVmVyaWZpZWQlMjBDUyUyMEFPQyUyMENBJTIwMDEu
# Y3J0MC0GCCsGAQUFBzABhiFodHRwOi8vb25lb2NzcC5taWNyb3NvZnQuY29tL29j
# c3AwZgYDVR0gBF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0
# cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRt
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEATSrIq1+gHJOktOBIcvZG/myr
# n9CUXiJLA7/M1i73S7EIdcy/DUIJ5S8mC/yWdCMFgtO5cpqCIQz2qgFZApqKCE73
# SivyWmUlNGWxvnvlk95PzeGGpNvCmFOvprS6+6/YJE0tyMB7kcxb+t+/odmzyr36
# LvVvDMOID/J69QA5OrAsPEOPtOf8ZgIDMrv7xuSPDlrk3gP3gnaKUQfiN+A1YRDN
# uvjwNf968bYcQQyeZh+kyCSc3En1V+aY4Ze2s78eenyk/MWQu9ptdmTxUwJ2ZtdK
# gVqhGnk4Prug7QeQN3Bg1hbEjj2ySmgtIVH+H9JWl1vUWhUrEz/Y1K98LgDry2BY
# R30zzJyhy28WokSsyTYVR/0D/f16RKKzo9Yx+6gZ5dNUOz1w2vxHYVpkpfARpvzJ
# FV5+/5QH4j0bjhNfyl4FhqJ0xXGi4sGuWFRF34amngS0PtKYnq4fn2ZmNQBtUraJ
# 3FplLNW8tUhgn3rZx/tsM7Ur/Ju61MYy0jy3WauM0b2Dr5RyflWkW2pdxdEyplxB
# iQivsFvJgHg7Gj1Nh0HCA4XutX+FNkmPvkEClq/1AGWdKD0hy30YGAo4/4UjZKb4
# L+9XueIy6RKIsYJ1N9mS2QOikFQmjlwBqnX7+sFA7n1gMjhBgXPc60OqNVeMIoL4
# JKydPv79mPtrWGIc15kwggdaMIIFQqADAgECAhMzAAAABzeMW6HZW4zUAAAAAAAH
# MA0GCSqGSIb3DQEBDAUAMGMxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xNDAyBgNVBAMTK01pY3Jvc29mdCBJRCBWZXJpZmllZCBD
# b2RlIFNpZ25pbmcgUENBIDIwMjEwHhcNMjEwNDEzMTczMTU0WhcNMjYwNDEzMTcz
# MTU0WjBaMQswCQYDVQQGEwJVUzEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSswKQYDVQQDEyJNaWNyb3NvZnQgSUQgVmVyaWZpZWQgQ1MgQU9DIENBIDAx
# MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAt/fAAygHxbo+jxA04hNI
# 8bz+EqbWvSu9dRgAawjCZau1Y54IQal5ArpJWi8cIj0WA+mpwix8iTRguq9JELZv
# TMo2Z1U6AtE1Tn3mvq3mywZ9SexVd+rPOTr+uda6GVgwLA80LhRf82AvrSwxmZpC
# H/laT08dn7+Gt0cXYVNKJORm1hSrAjjDQiZ1Jiq/SqiDoHN6PGmT5hXKs22E79Me
# FWYB4y0UlNqW0Z2LPNua8k0rbERdiNS+nTP/xsESZUnrbmyXZaHvcyEKYK85WBz3
# Sr6Et8Vlbdid/pjBpcHI+HytoaUAGE6rSWqmh7/aEZeDDUkz9uMKOGasIgYnenUk
# 5E0b2U//bQqDv3qdhj9UJYWADNYC/3i3ixcW1VELaU+wTqXTxLAFelCi/lRHSjaW
# ipDeE/TbBb0zTCiLnc9nmOjZPKlutMNho91wxo4itcJoIk2bPot9t+AV+UwNaDRI
# bcEaQaBycl9pcYwWmf0bJ4IFn/CmYMVG1ekCBxByyRNkFkHmuMXLX6PMXcveE46j
# Mr9syC3M8JHRddR4zVjd/FxBnS5HOro3pg6StuEPshrp7I/Kk1cTG8yOWl8aqf6O
# JeAVyG4lyJ9V+ZxClYmaU5yvtKYKk1FLBnEBfDWw+UAzQV0vcLp6AVx2Fc8n0vpo
# yudr3SwZmckJuz7R+S79BzMCAwEAAaOCAg4wggIKMA4GA1UdDwEB/wQEAwIBhjAQ
# BgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU6IPEM9fcnwycdpoKptTfh6ZeWO4w
# VAYDVR0gBE0wSzBJBgRVHSAAMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWlj
# cm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTAZBgkrBgEEAYI3
# FAIEDB4KAFMAdQBiAEMAQTASBgNVHRMBAf8ECDAGAQH/AgEAMB8GA1UdIwQYMBaA
# FNlBKbAPD2Ns72nX9c0pnqRIajDmMHAGA1UdHwRpMGcwZaBjoGGGX2h0dHA6Ly93
# d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3JsL01pY3Jvc29mdCUyMElEJTIwVmVy
# aWZpZWQlMjBDb2RlJTIwU2lnbmluZyUyMFBDQSUyMDIwMjEuY3JsMIGuBggrBgEF
# BQcBAQSBoTCBnjBtBggrBgEFBQcwAoZhaHR0cDovL3d3dy5taWNyb3NvZnQuY29t
# L3BraW9wcy9jZXJ0cy9NaWNyb3NvZnQlMjBJRCUyMFZlcmlmaWVkJTIwQ29kZSUy
# MFNpZ25pbmclMjBQQ0ElMjAyMDIxLmNydDAtBggrBgEFBQcwAYYhaHR0cDovL29u
# ZW9jc3AubWljcm9zb2Z0LmNvbS9vY3NwMA0GCSqGSIb3DQEBDAUAA4ICAQB3/utL
# ItkwLTp4Nfh99vrbpSsL8NwPIj2+TBnZGL3C8etTGYs+HZUxNG+rNeZa+Rzu9oEc
# AZJDiGjEWytzMavD6Bih3nEWFsIW4aGh4gB4n/pRPeeVrK4i1LG7jJ3kPLRhNOHZ
# iLUQtmrF4V6IxtUFjvBnijaZ9oIxsSSQP8iHMjP92pjQrHBFWHGDbkmx+yO6Ian3
# QN3YmbdfewzSvnQmKbkiTibJgcJ1L0TZ7BwmsDvm+0XRsPOfFgnzhLVqZdEyWww1
# 0bflOeBKqkb3SaCNQTz8nshaUZhrxVU5qNgYjaaDQQm+P2SEpBF7RolEC3lllfuL
# 4AOGCtoNdPOWrx9vBZTXAVdTE2r0IDk8+5y1kLGTLKzmNFn6kVCc5BddM7xoDWQ4
# aUoCRXcsBeRhsclk7kVXP+zJGPOXwjUJbnz2Kt9iF/8B6FDO4blGuGrogMpyXkuw
# CC2Z4XcfyMjPDhqZYAPGGTUINMtFbau5RtGG1DOWE9edCahtuPMDgByfPixvhy3s
# n7zUHgIC/YsOTMxVuMQi/bgamemo/VNKZrsZaS0nzmOxKpg9qDefj5fJ9gIHXcp2
# F0OHcVwe3KnEXa8kqzMDfrRl/wwKrNSFn3p7g0b44Ad1ONDmWt61MLQvF54LG62i
# 6ffhTCeoFT9Z9pbUo2gxlyTFg7Bm0fgOlnRfGDCCB54wggWGoAMCAQICEzMAAAAH
# h6M0o3uljhwAAAAAAAcwDQYJKoZIhvcNAQEMBQAwdzELMAkGA1UEBhMCVVMxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjFIMEYGA1UEAxM/TWljcm9zb2Z0
# IElkZW50aXR5IFZlcmlmaWNhdGlvbiBSb290IENlcnRpZmljYXRlIEF1dGhvcml0
# eSAyMDIwMB4XDTIxMDQwMTIwMDUyMFoXDTM2MDQwMTIwMTUyMFowYzELMAkGA1UE
# BhMCVVMxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjE0MDIGA1UEAxMr
# TWljcm9zb2Z0IElEIFZlcmlmaWVkIENvZGUgU2lnbmluZyBQQ0EgMjAyMTCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBALLwwK8ZiCji3VR6TElsaQhVCbRS
# /3pK+MHrJSj3Zxd3KU3rlfL3qrZilYKJNqztA9OQacr1AwoNcHbKBLbsQAhBnIB3
# 4zxf52bDpIO3NJlfIaTE/xrweLoQ71lzCHkD7A4As1Bs076Iu+mA6cQzsYYH/Cbl
# 1icwQ6C65rU4V9NQhNUwgrx9rGQ//h890Q8JdjLLw0nV+ayQ2Fbkd242o9kH82RZ
# sH3HEyqjAB5a8+Ae2nPIPc8sZU6ZE7iRrRZywRmrKDp5+TcmJX9MRff241UaOBs4
# NmHOyke8oU1TYrkxh+YeHgfWo5tTgkoSMoayqoDpHOLJs+qG8Tvh8SnifW2Jj3+i
# i11TS8/FGngEaNAWrbyfNrC69oKpRQXY9bGH6jn9NEJv9weFxhTwyvx9OJLXmRGb
# AUXN1U9nf4lXezky6Uh/cgjkVd6CGUAf0K+Jw+GE/5VpIVbcNr9rNE50Sbmy/4RT
# CEGvOq3GhjITbCa4crCzTTHgYYjHs1NbOc6brH+eKpWLtr+bGecy9CrwQyx7S/Bf
# YJ+ozst7+yZtG2wR461uckFu0t+gCwLdN0A6cFtSRtR8bvxVFyWwTtgMMFRuBa3v
# mUOTnfKLsLefRaQcVTgRnzeLzdpt32cdYKp+dhr2ogc+qM6K4CBI5/j4VFyC4QFe
# UP2YAidLtvpXRRo3AgMBAAGjggI1MIICMTAOBgNVHQ8BAf8EBAMCAYYwEAYJKwYB
# BAGCNxUBBAMCAQAwHQYDVR0OBBYEFNlBKbAPD2Ns72nX9c0pnqRIajDmMFQGA1Ud
# IARNMEswSQYEVR0gADBBMD8GCCsGAQUFBwIBFjNodHRwOi8vd3d3Lm1pY3Jvc29m
# dC5jb20vcGtpb3BzL0RvY3MvUmVwb3NpdG9yeS5odG0wGQYJKwYBBAGCNxQCBAwe
# CgBTAHUAYgBDAEEwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTIftJqhSob
# yhmYBAcnz1AQT2ioojCBhAYDVR0fBH0wezB5oHegdYZzaHR0cDovL3d3dy5taWNy
# b3NvZnQuY29tL3BraW9wcy9jcmwvTWljcm9zb2Z0JTIwSWRlbnRpdHklMjBWZXJp
# ZmljYXRpb24lMjBSb290JTIwQ2VydGlmaWNhdGUlMjBBdXRob3JpdHklMjAyMDIw
# LmNybDCBwwYIKwYBBQUHAQEEgbYwgbMwgYEGCCsGAQUFBzAChnVodHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMElkZW50aXR5
# JTIwVmVyaWZpY2F0aW9uJTIwUm9vdCUyMENlcnRpZmljYXRlJTIwQXV0aG9yaXR5
# JTIwMjAyMC5jcnQwLQYIKwYBBQUHMAGGIWh0dHA6Ly9vbmVvY3NwLm1pY3Jvc29m
# dC5jb20vb2NzcDANBgkqhkiG9w0BAQwFAAOCAgEAfyUqnv7Uq+rdZgrbVyNMul5s
# kONbhls5fccPlmIbzi+OwVdPQ4H55v7VOInnmezQEeW4LqK0wja+fBznANbXLB0K
# rdMCbHQpbLvG6UA/Xv2pfpVIE1CRFfNF4XKO8XYEa3oW8oVH+KZHgIQRIwAbyFKQ
# 9iyj4aOWeAzwk+f9E5StNp5T8FG7/VEURIVWArbAzPt9ThVN3w1fAZkF7+YU9kbq
# 1bCR2YD+MtunSQ1Rft6XG7b4e0ejRA7mB2IoX5hNh3UEauY0byxNRG+fT2MCEhQl
# 9g2i2fs6VOG19CNep7SquKaBjhWmirYyANb0RJSLWjinMLXNOAga10n8i9jqeprz
# SMU5ODmrMCJE12xS/NWShg/tuLjAsKP6SzYZ+1Ry358ZTFcx0FS/mx2vSoU8s8HR
# vy+rnXqyUJ9HBqS0DErVLjQwK8VtsBdekBmdTbQVoCgPCqr+PDPB3xajYnzevs7e
# idBsM71PINK2BoE2UfMwxCCX3mccFgx6UsQeRSdVVVNSyALQe6PT12418xon2iDG
# E81OGCreLzDcMAZnrUAx4XQLUz6ZTl65yPUiOh3k7Yww94lDf+8oG2oZmDh5O1Qe
# 38E+M3vhKwmzIeoB1dVLlz4i3IpaDcR+iuGjH2TdaC1ZOmBXiCRKJLj4DT2uhJ04
# ji+tHD6n58vhavFIrmcxghq9MIIauQIBATBxMFoxCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKzApBgNVBAMTIk1pY3Jvc29mdCBJ
# RCBWZXJpZmllZCBDUyBBT0MgQ0EgMDECEzMAALjCIJ2lofwRjAMAAAAAuMIwDQYJ
# YIZIAWUDBAIBBQCggYYwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwLwYJKoZI
# hvcNAQkEMSIEIOZnV5aEl4FrKmYBqeeNCuXHsSWGbyNSLUwhK78YzTptMDgGCisG
# AQQBgjcCAQwxKjAooCaAJABBAGQAdgBhAG4AYwBlAGQAIABJAG4AcwB0AGEAbABs
# AGUAcjANBgkqhkiG9w0BAQEFAASCAYCGD/bUZzdWAGis8aNLNj9hpCWD0BLo93sm
# MslwNdAPU3z0f4hmgA8jUZyFkWZu+1kY3Wk5a6syp+Hyd/fmL7On7Cz3K9lpGgtR
# H92sxZQQOYCkId9pHhQZAmBu91Vu4ztGcF1NcQG/zWlBhjfU5fxUFPtd/MppVEKm
# Z7iR9Dz1zBU94Bxb2voZCV+42LzP8uGYvbGq8atKnVY1Mv6epMEpD8hLAZcLL7eR
# bjsObn3gU+2v7a4JEDpCkDSEqj8TB+YmoVjFqw8WMTjUwSjWeVB4XVsI6lNlU2O4
# PlW2odHtQlKCKGW2hRCZ6rXWYg4gigSN7XsSSMeTRjmeC3rAx4F92UvlyZ5cS6wp
# 9UL8+ftDDS08qEo9HkjPnuOjvYgA7AH7DoJlzA1iNRJnrHSdtGDMF9n2W7CHtrdv
# yFLzJFw0VICingekV853h9pz35Za6UZD0b4z94cgvFrkD4yoB2+4rxi+BALgzlPB
# kFi5HbNfIrUf/r7eOIx0OI3C3ck11suhghgUMIIYEAYKKwYBBAGCNwMDATGCGAAw
# ghf8BgkqhkiG9w0BBwKgghftMIIX6QIBAzEPMA0GCWCGSAFlAwQCAQUAMIIBYgYL
# KoZIhvcNAQkQAQSgggFRBIIBTTCCAUkCAQEGCisGAQQBhFkKAwEwMTANBglghkgB
# ZQMEAgEFAAQgfzZrZ8JO2aKRc8tQydinGE7Jul5uOL3zhTbzjJkjgTYCBmVbVNAC
# 5RgTMjAyMzEyMTQxMjUxMjUuODQyWjAEgAIB9KCB4aSB3jCB2zELMAkGA1UEBhMC
# VVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNV
# BAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFt
# ZXJpY2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjc4MDAt
# MDVFMC1EOTQ3MTUwMwYDVQQDEyxNaWNyb3NvZnQgUHVibGljIFJTQSBUaW1lIFN0
# YW1waW5nIEF1dGhvcml0eaCCDyEwggeCMIIFaqADAgECAhMzAAAABeXPD/9mLsmH
# AAAAAAAFMA0GCSqGSIb3DQEBDAUAMHcxCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xSDBGBgNVBAMTP01pY3Jvc29mdCBJZGVudGl0
# eSBWZXJpZmljYXRpb24gUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAyMDAe
# Fw0yMDExMTkyMDMyMzFaFw0zNTExMTkyMDQyMzFaMGExCzAJBgNVBAYTAlVTMR4w
# HAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29m
# dCBQdWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMIICIjANBgkqhkiG9w0B
# AQEFAAOCAg8AMIICCgKCAgEAnnznUmP94MWfBX1jtQYioxwe1+eXM9ETBb1lRkd3
# kcFdcG9/sqtDlwxKoVIcaqDb+omFio5DHC4RBcbyQHjXCwMk/l3TOYtgoBjxnG/e
# ViS4sOx8y4gSq8Zg49REAf5huXhIkQRKe3Qxs8Sgp02KHAznEa/Ssah8nWo5hJM1
# xznkRsFPu6rfDHeZeG1Wa1wISvlkpOQooTULFm809Z0ZYlQ8Lp7i5F9YciFlyAKw
# n6yjN/kR4fkquUWfGmMopNq/B8U/pdoZkZZQbxNlqJOiBGgCWpx69uKqKhTPVi3g
# VErnc/qi+dR8A2MiAz0kN0nh7SqINGbmw5OIRC0EsZ31WF3Uxp3GgZwetEKxLms7
# 3KG/Z+MkeuaVDQQheangOEMGJ4pQZH55ngI0Tdy1bi69INBV5Kn2HVJo9XxRYR/J
# PGAaM6xGl57Ei95HUw9NV/uC3yFjrhc087qLJQawSC3xzY/EXzsT4I7sDbxOmM2r
# l4uKK6eEpurRduOQ2hTkmG1hSuWYBunFGNv21Kt4N20AKmbeuSnGnsBCd2cjRKG7
# 9+TX+sTehawOoxfeOO/jR7wo3liwkGdzPJYHgnJ54UxbckF914AqHOiEV7xTnD1a
# 69w/UTxwjEugpIPMIIE67SFZ2PMo27xjlLAHWW3l1CEAFjLNHd3EQ79PUr8FUXet
# Xr0CAwEAAaOCAhswggIXMA4GA1UdDwEB/wQEAwIBhjAQBgkrBgEEAYI3FQEEAwIB
# ADAdBgNVHQ4EFgQUa2koOjUvSGNAz3vYr0npPtk92yEwVAYDVR0gBE0wSzBJBgRV
# HSAAMEEwPwYIKwYBBQUHAgEWM2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lv
# cHMvRG9jcy9SZXBvc2l0b3J5Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkr
# BgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQY
# MBaAFMh+0mqFKhvKGZgEByfPUBBPaKiiMIGEBgNVHR8EfTB7MHmgd6B1hnNodHRw
# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNyb3NvZnQlMjBJZGVu
# dGl0eSUyMFZlcmlmaWNhdGlvbiUyMFJvb3QlMjBDZXJ0aWZpY2F0ZSUyMEF1dGhv
# cml0eSUyMDIwMjAuY3JsMIGUBggrBgEFBQcBAQSBhzCBhDCBgQYIKwYBBQUHMAKG
# dWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0
# JTIwSWRlbnRpdHklMjBWZXJpZmljYXRpb24lMjBSb290JTIwQ2VydGlmaWNhdGUl
# MjBBdXRob3JpdHklMjAyMDIwLmNydDANBgkqhkiG9w0BAQwFAAOCAgEAX4h2x35t
# tVoVdedMeGj6TuHYRJklFaW4sTQ5r+k77iB79cSLNe+GzRjv4pVjJviceW6AF6yc
# WoEYR0LYhaa0ozJLU5Yi+LCmcrdovkl53DNt4EXs87KDogYb9eGEndSpZ5ZM74LN
# vVzY0/nPISHz0Xva71QjD4h+8z2XMOZzY7YQ0Psw+etyNZ1CesufU211rLslLKsO
# 8F2aBs2cIo1k+aHOhrw9xw6JCWONNboZ497mwYW5EfN0W3zL5s3ad4Xtm7yFM7Uj
# rhc0aqy3xL7D5FR2J7x9cLWMq7eb0oYioXhqV2tgFqbKHeDick+P8tHYIFovIP7Y
# G4ZkJWag1H91KlELGWi3SLv10o4KGag42pswjybTi4toQcC/irAodDW8HNtX+cbz
# 0sMptFJK+KObAnDFHEsukxD+7jFfEV9Hh/+CSxKRsmnuiovCWIOb+H7DRon9Tlxy
# diFhvu88o0w35JkNbJxTk4MhF/KgaXn0GxdH8elEa2Imq45gaa8D+mTm8LWVydt4
# ytxYP/bqjN49D9NZ81coE6aQWm88TwIf4R4YZbOpMKN0CyejaPNN41LGXHeCUMYm
# Bx3PkP8ADHD1J2Cr/6tjuOOCztfp+o9Nc+ZoIAkpUcA/X2gSMkgHAPUvIdtoSAHE
# UKiBhI6JQivRepyvWcl+JYbYbBh7pmgAXVswggeXMIIFf6ADAgECAhMzAAAAJ6+t
# r2cVJrjjAAAAAAAnMA0GCSqGSIb3DQEBDAUAMGExCzAJBgNVBAYTAlVTMR4wHAYD
# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQ
# dWJsaWMgUlNBIFRpbWVzdGFtcGluZyBDQSAyMDIwMB4XDTIzMDQwNjE4NDQxOFoX
# DTI0MDQwNDE4NDQxOFowgdsxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n
# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y
# YXRpb24xJTAjBgNVBAsTHE1pY3Jvc29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJzAl
# BgNVBAsTHm5TaGllbGQgVFNTIEVTTjo3ODAwLTA1RTAtRDk0NzE1MDMGA1UEAxMs
# TWljcm9zb2Z0IFB1YmxpYyBSU0EgVGltZSBTdGFtcGluZyBBdXRob3JpdHkwggIi
# MA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCikpcltWm4MIR4ljhdHyv4jtsR
# M5MxXmc5FbTy6pjNiU5D8w/l8hVXVw5V1+rsaJStAZeS/vhSpTt4853YMIM9tslj
# mpuNwv5bY/xciAw4ql9MmtPu4EEgQK4vxcir6wR1cjqD4A2MA4P7c7NnFzcZq2Ms
# 6gychuFdII0EKxILPcvmtJ8Db/c2abjW6gcPPONvZlyscadLkwzSrHlG87k5QZIX
# +J7+2Y9slQ84caKDhdUN4ELnU6NB+Bw9b5dVIEV45Ut8mw+N7DzdpwWEMrPhcwIn
# 0QUF3COEfn5G/DSVY2CRF5du396xlXW6Ft0FYdR4RiFL10j9ZSD+TnSW8oiyMqcP
# H5URFFPTrlDCfBCX+I0ecUnZMin4Z9LLoj7qYNL6VTco0xjHzXol2MtJJ08p/TZh
# eVhO7Yk7pNh+WFKAmSZE45q3RkdLEuPHrFT+ZT66rUrFs/JOFClx+sejN4mCjFsK
# 6jcGae5mpESL9F4Kw64QD6WEgIiJ0TzSu00SpoivDxUMu3DP5cn5K9Z+7XrqB/kr
# T1aZYDFxXkguFOPbRALtagdZTjVzx0GvWFLiL8zOU+gPPATmCR8JQ9FTlZ9jBz9A
# CSjIUmS/4b1UqgsGoYWqp2VilYhGCZV8Bvv6a3aBrFOBF9eSGKp8JsL5YhDlU+1B
# O5zXPPBRLXWLBkclSQIDAQABo4IByzCCAccwHQYDVR0OBBYEFDkGPnmttacv/FRh
# KUdWs4wqDalQMB8GA1UdIwQYMBaAFGtpKDo1L0hjQM972K9J6T7ZPdshMGwGA1Ud
# HwRlMGMwYaBfoF2GW2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvY3Js
# L01pY3Jvc29mdCUyMFB1YmxpYyUyMFJTQSUyMFRpbWVzdGFtcGluZyUyMENBJTIw
# MjAyMC5jcmwweQYIKwYBBQUHAQEEbTBrMGkGCCsGAQUFBzAChl1odHRwOi8vd3d3
# Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NlcnRzL01pY3Jvc29mdCUyMFB1YmxpYyUy
# MFJTQSUyMFRpbWVzdGFtcGluZyUyMENBJTIwMjAyMC5jcnQwDAYDVR0TAQH/BAIw
# ADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAOBgNVHQ8BAf8EBAMCB4AwZgYDVR0g
# BF8wXTBRBgwrBgEEAYI3TIN9AQEwQTA/BggrBgEFBQcCARYzaHR0cDovL3d3dy5t
# aWNyb3NvZnQuY29tL3BraW9wcy9Eb2NzL1JlcG9zaXRvcnkuaHRtMAgGBmeBDAEE
# AjANBgkqhkiG9w0BAQwFAAOCAgEAUzWrvdgOPCr2If2IcNJrx8DMkn5nMxXVciXr
# u5Gs8aZx6RK6WwHHZaAQLYeLa0d4DptaiZO7rd0IvEY1qP8R26Fl6L4UyaQq1cum
# sPVgQNxYqRDVNM+6zWWlG2+o9T8X9nhpRUc3zQuvoe4gXf2H36uwK/Pwmvj8eUoX
# SOp4zYiam7L1ScPoaLcwHm4vsVYOqQ3KGxeop2d7NpSKPcr4873djCvr+kg/qYiv
# W/ej/sxGTM/TK2ailO3vf90BPDCn9VAMiuRa2wMky3FtekX3kGUMUMZvQ0Kcl84+
# 8tAVlnttw7z9J5zo01e+y9Eui2NvGl1CVuVslM8VpZDDl+W4q3aJHiaekfqcnp2V
# KK78teubbXJC5fry4QicHg7KgXR2ADi8t+1fPqapIkSEBIQ4VZSZ8H4bsH+XKO3E
# EB4o2v8KNrKdpJj+Uw3w+eHP3w8WFuJf//dHzMEWryvOr7DmmrvI9/sWbRRdypOW
# y2SAcwcsaForoq1t2CxEfg1J7F5uo+z3aGQ0ICvlOjE8xjYqQ9KMTvx7q3XUuBaR
# hesbgS3xoGgISmT83TKrxwUr+hsaoqWHVP+P8TB0+54gHaQG3g329bNPgQPML2pB
# c1DN36vkjOCivvCMz0nm47aVarG55b/F1ZZcXmi8toDxBeIoWAml2fzLQj0Iq5Kh
# wJOg8VYxggdGMIIHQgIBATB4MGExCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJsaWMgUlNB
# IFRpbWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAJ6+tr2cVJrjjAAAAAAAnMA0GCWCG
# SAFlAwQCAQUAoIIEnzARBgsqhkiG9w0BCRACDzECBQAwGgYJKoZIhvcNAQkDMQ0G
# CyqGSIb3DQEJEAEEMBwGCSqGSIb3DQEJBTEPFw0yMzEyMTQxMjUxMjVaMC8GCSqG
# SIb3DQEJBDEiBCBDlg+00C+56xdmBQRdhoGE04k36Zma27SsbbJ1wD+KqjCBuQYL
# KoZIhvcNAQkQAi8xgakwgaYwgaMwgaAEIM7FSGD4dV/C1+7DRBze8INgiHRTzk+/
# 7LdbUZVW8nYTMHwwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJsaWMgUlNBIFRp
# bWVzdGFtcGluZyBDQSAyMDIwAhMzAAAAJ6+tr2cVJrjjAAAAAAAnMIIDYQYLKoZI
# hvcNAQkQAhIxggNQMIIDTKGCA0gwggNEMIICLAIBATCCAQmhgeGkgd4wgdsxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJTAjBgNVBAsTHE1pY3Jv
# c29mdCBBbWVyaWNhIE9wZXJhdGlvbnMxJzAlBgNVBAsTHm5TaGllbGQgVFNTIEVT
# Tjo3ODAwLTA1RTAtRDk0NzE1MDMGA1UEAxMsTWljcm9zb2Z0IFB1YmxpYyBSU0Eg
# VGltZSBTdGFtcGluZyBBdXRob3JpdHmiIwoBATAHBgUrDgMCGgMVAI1FCC+Kblqx
# slJoRAUOh08m2RwMoGcwZaRjMGExCzAJBgNVBAYTAlVTMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBQdWJsaWMgUlNB
# IFRpbWVzdGFtcGluZyBDQSAyMDIwMA0GCSqGSIb3DQEBCwUAAgUA6SV3UTAiGA8y
# MDIzMTIxNDEyNDUwNVoYDzIwMjMxMjE1MTI0NTA1WjB3MD0GCisGAQQBhFkKBAEx
# LzAtMAoCBQDpJXdRAgEAMAoCAQACAhuMAgH/MAcCAQACAhMKMAoCBQDpJsjRAgEA
# MDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSChCjAI
# AgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBAGpcbaQgTx9sIwyL+Zl0sYKFY+we
# kpt57LQLTx+E/Ximb4QLVHyr8QRMuzte1jMaoncw6+BS0bkMUaklqK+YGTMzafLx
# CwU06c2Yy3yCQpvxtaCbCx1H6HbD17W6Bcn5BiBiPMxDvzpp35CG0DBHDXKCPGI7
# sWTOJR0JyNyNV4908PC45BHfIX5OC/yNZ/ixZA+3dh/g6+wayGVU/u8xNyPH7JBG
# PusXoOcvNgIlkz8MDsHL5upN7iHmP7oOsiaACQ/NFPgzsPrIKqM3e7C/Za99hPvo
# wNf0Zn921Bcejf7vMm/ygExyGYn+FtoJYMcTBc97zbBQ1ps9hUSQ3l9pv0MwDQYJ
# KoZIhvcNAQEBBQAEggIAA1Ca3TT29u8toDvkUG16vaMuLuBrFsiVyZAjmTDFWprY
# W9piEJT8byVR8y0ZcrTCe/fKhx6PI2RNifS7rk4IqDKSdbB0VKimp72acRwdIS0+
# NXY9zkDiL05Cf+dmYsZgrK1LmQXc6NT152H+1wjo39qI2btGyIN76+OyPD6Nlb+B
# ox5kdYWTUohWBZ/h/ZPWxXDDaq/v83cRoUFu8CeNIUdAjG649Oifz6Ec1KOWrYOz
# LtE2VANA40Vz79gRp2NdMzycIw7i06jRbXJI+5gk7jj0QnEPyXzrco/maBJJ/rxZ
# 82xFPOW5UJiPK7iCjGUVTELnIQSSdwSL5LIs3UwqqOobvef/Ae+W84RImPZHRT7J
# D8tk9+7QgUq0qxge9Yx3TbIY7AhzNIvL4WC9T2qMSfqZVgTEzuM+lyO7O/djWO77
# 7HMZTiB3FSo2SU8GkItaHd5cQJov9wFYWRbkRQwqq/oTLTKUVqteq74Rv3WUsTgB
# Al82mt9q152qpnyURCsFclnipzgHK/l9WV3TRFSUa3NNZ0vXltdUDW9fDVpLuwzP
# 2ECD3n7t08y3Zpr8aCUHmGDtkBxOutn6tEo+k5kYGgUCa+/aga5aGtteFj29pNDN
# 8TrRkTasf9WCi7fOo0eysuLra0zBX0incz9sXKaAMcm0/YNp2F6W8ub9CgfoNkw=
# SIG # End signature block
