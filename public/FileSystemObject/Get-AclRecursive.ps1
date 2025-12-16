
function Get-AclRecursive {
    param (
        [string]$Path
    )
    $Output = @()
    foreach ($access in (Get-Acl -Path $Path).Access) {
        $Output += [PSCustomObject]@{
            'Path'          = $Path
            'User/Group'    = $access.IdentityReference
            'Permissions'   = $access.FileSystemRights
            'AccessType'    = $access.AccessControlType
        }
    }
    Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        foreach ($access in (Get-Acl -Path $_.FullName).Access) {
            if ($access.IsInherited -eq $false) {
                $Output += [PSCustomObject]@{
                    'Path'          = $_.FullName
                    'User/Group'    = $access.IdentityReference
                    'Permissions'   = $access.FileSystemRights
                    'AccessType'    = $access.AccessControlType
                }
                
            }
        }
    }
    return $Output
}


Get-AclRecursive "C:\Page" 


