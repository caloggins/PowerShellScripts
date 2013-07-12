$count = 0

$reader = new-object System.IO.StreamReader("C:\Users\christopher.loggins\Documents\Projects\TestFiles\termtot20130711_fixed.xml")
$rootName = 'TermTotMessage'
$ext = 'xml'

while(($line = $reader.ReadLine()) -ne $null)
{
	if($line -eq '<?xml version="1.0" encoding="utf-8"?>')
	{
		++$count
		$fileName = "{0}{1}.{2}" -f ($rootName, $count, $ext)
		echo $fileName
	}
	
    Add-Content -path $fileName -value $line
}

$reader.Close()