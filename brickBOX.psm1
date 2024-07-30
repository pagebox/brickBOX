
$public  = @(Get-ChildItem -Path $PSScriptRoot\public\*.ps1  -Recurse)
$private = @(Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -Recurse)

$Public + $Private | ForEach-Object { . $_.fullname } # dot source the files

Export-ModuleMember -Function $Public.Basename # export public functions
