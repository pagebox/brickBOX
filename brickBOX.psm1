
Write-Verbose "Loading module $($ExecutionContext.SessionState.Module)"

#region 🟨 dot source the files and export public functions

$public  = @(Get-ChildItem -Path $PSScriptRoot\public\*.ps1  -Recurse)
$private = @(Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -Recurse)

$Public + $Private | ForEach-Object { . $_.fullname } # dot source the files

Export-ModuleMember -Function $Public.Basename # export public functions

#endregion

