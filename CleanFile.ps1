$path = "some directory here"

$files = Get-ChildItem $path -Filter "*.cs"
foreach($file in $files){
    $oldfile = $file.FullName
    $newfile = $file.FullName + '.out'
    Get-Content $oldfile | Where-Object {$_ -notmatch '^\s+\[Xml.+|\s+\[Seri.+|\s+using.+' } | Set-Content $newfile
    Remove-Item $oldfile
}

Get-ChildItem *.out | Rename-Item -NewName {$_.name -replace '\.cs\.out','.cs'}