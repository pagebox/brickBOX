

(get-module brickBOX).ExportedCommands.Values | ForEach-Object {
    # Write-Host $_.Name
    get-help $_.Name | select-object Name,Synopsis

} | ConvertTo-Markdown


# get-help invoke-API | select-object -property Name,synopsis | Format-Table
# get-help invoke-API | select-object * | fl   


