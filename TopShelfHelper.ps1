param(
	[parameter(mandatory=$true)]
	[validateset("start","stop","uninstall", "install")]
	$command
)

$ErrorActionPreference = "Stop"

push-Location

try
{
	get-ChildItem -Path $pwd -Recurse |
		where-Object {$_.name -eq 'topshelfhost.exe'} |
		select-Object fullname |
		foreach-object {& $_.fullname $command}

	"INFO: Operation completed successfully."
}
catch
{
	$Error[0]
	"ERROR: An error occurred performing the operation."
}
finally
{
	pop-Location
}