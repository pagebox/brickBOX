function Get-LatestWriteTime {
    <#
    .SYNOPSIS
        Returns a list of objects of given folder as input. Output contains information about the most latest written file within any subfolder.
    .COMPONENT
        FileSystemObject
    .EXAMPLE
        Get-LatestWriteTime '.'
    .EXAMPLE
        Get-LatestWriteTime '.' | Sort-Object DaysAgo -Descending | Out-GridView -OutputMode Single | Select-Object -ExpandProperty Folder | Set-Clipboard
    #>
    [CmdletBinding()]
    param (
        # path containing subfolders, which are looked for 
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $true)][string]$path
    )
    process {
        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]('Folder', 'LastWriteTime', 'DaysAgo'))
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)

        Get-ChildItem $path -Directory | ForEach-Object {
            $childs = Get-ChildItem $_ -Recurse -File | Sort-Object LastWriteTime -Descending
            $latest = $childs | Select-Object -First 1 FullName,LastWriteTime
            $totalBytes = $childs | Measure-Object Length -Sum | Select-Object -ExpandProperty Sum
        
            $object = [PSCustomObject]@{
                PSTypeName = 'Folder.LatestWriteTime'
                Folder = $_.FullName
                LatestFile = $latest.FullName
                LastWriteTime = $latest.LastWriteTime
                DaysAgo = if($latest.LastWriteTime){(New-TimeSpan -Start $latest.LastWriteTime -End (Get-Date)).Days}
                TotalSize = $totalBytes | Format-Bytes
                TotalBytes = $totalBytes
            }
            $object | Add-Member MemberSet PSStandardMembers $PSStandardMembers
            $object
        } 
    }
}


# $p.LastWriteTime = Get-Date('21.02.2024')