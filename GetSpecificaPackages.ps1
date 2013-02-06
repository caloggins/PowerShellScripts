$feedUrlBase = "http://go.microsoft.com/fwlink/?LinkID=206669"
$webClient = New-Object System.Net.WebClient
$latest = $true
$overwrite = $false
$destinationDirectory = join-path ([Environment]::GetFolderPath("MyDocuments")) "NuGetLocal"

# the NuGet feed uses a fwlink which redirects
# using this to follow the redirect
function GetPackageUrl {
	param ([string]$feedUrlBase) 
	$resp = [xml]$webClient.DownloadString($feedUrlBase)
	return $resp.service.GetAttribute("xml:base")
}

# download entries on a page, recursively called for page continuations
function DownloadEntries {
	param ([string]$feedUrl) 
	$feed = [xml]$webClient.DownloadString($feedUrl)
	$entries = $feed.feed.entry 
	$progress = 0
	        
	foreach ($entry in $entries) {
		$url = $entry.content.src
		$fileName = $entry.properties.id + "." + $entry.properties.version + ".nupkg"
		$saveFileName = join-path $destinationDirectory $fileName
		$pagepercent = ((++$progress)/$entries.Length*100)
		if ((-not $overwrite) -and (Test-Path -path $saveFileName)) 
		{
		    write-progress -activity "$fileName already downloaded" `
		                   -status "$pagepercent% of current page complete" `
		                   -percentcomplete $pagepercent
		    continue
		}
		write-progress -activity "Downloading $fileName" `
		               -status "$pagepercent% of current page complete" `
		               -percentcomplete $pagepercent

		[int]$trials = 0
		do {
			    try {
			        $trials +=1
			        $webClient.DownloadFile($url, $saveFileName)
			        break
			    } catch [System.Net.WebException] {
			        write-host "Problem downloading $url `tTrial $trials `
			                   `n`tException: " $_.Exception.Message
			    }
			}
			while ($trials -lt 3)
	}

	$link = $feed.feed.link | where { $_.rel.startsWith("next") } | select href
	if ($link -ne $null) {
		# if using a paged url with a $skiptoken like 
		# http:// ... /Packages?$skiptoken='EnyimMemcached-log4net','2.7'
		# remember that you need to escape the $ in powershell with `
		return $link.href
	}
	return $null
} 

function EnsureDestinationDirectoryExists{
	if (!(Test-Path -path $destinationDirectory)) { 
	    New-Item $destinationDirectory -type directory 
	}
}

#
# The Script
#

EnsureDestinationDirectoryExists

$serviceBase = GetPackageUrl($feedUrlBase)
$feedUrl = $serviceBase + "Packages"
$feedUrl = $feedUrl + "?`$filter=substringof('EasyNet',Id) eq true"
if($latest){
	$feedUrl = $feedUrl + " and IsLatestVersion eq true"
}
Write-Host $feedUrl

while($feedUrl -ne $null) {
    $feedUrl = DownloadEntries $feedUrl
}
