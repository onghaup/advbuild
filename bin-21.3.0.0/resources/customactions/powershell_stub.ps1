#Requires -version 3
Param()

# Let's see which Powershell we're using. Feel free to remove this function
Function Say-Hello() {
  # Powershell Core (pwsh.exe) is used when Requires -version is greater or equal to 6
  # By default, Windows PowerShell (powershell.exe) will be used. Let's see what we're using now...

  # Access Windows Installer properties using Set-Property and Get-Property
  Set-Property -name "PSVersion" -value $host.Version.ToString()
  [string] $helloMessage = "Hello from PowerShell " + (Get-Property -name "PSVersion")
  $helloMessage += If ([Environment]::Is64BitProcess) { " 64bit" } else { " 32bit" }
  
  # Writing messages to the Windows Installer log is also easy
  Write-Output $helloMessage
  
  # When testing or debugging your script, you can quickly display a message box
  [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
  [System.Windows.Forms.MessageBox]::Show($helloMessage)
}

# Your code goes here
Say-Hello