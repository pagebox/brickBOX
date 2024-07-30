function Get-LatestWriteTime {
    param (
        [string]$path
    )
    Get-ChildItem $path -Directory | ForEach-Object {
        $childs = Get-ChildItem $_ -Recurse -File | Sort-Object LastWriteTime -Descending
        $latest = $childs | Select-Object -First 1 FullName,LastWriteTime
        $totalBytes = $childs | Measure-Object Length -Sum | Select-Object -ExpandProperty Sum
    
        [PSCustomObject]@{
            Folder = $_.FullName
            LatestFile = $latest.FullName
            LastWriteTime = $latest.LastWriteTime
            DaysAgo = if($latest.LastWriteTime){(New-TimeSpan -Start $latest.LastWriteTime -End (Get-Date)).Days}
            TotalSize = $totalBytes | Format-Bytes
            TotalBytes = $totalBytes
        }
    } 
    
}
