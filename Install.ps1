param($installPath, $toolsPath, $package, $project)

$project.Properties | where { $_.Name -eq "PostBuildEvent" } | foreach { $_.Value = "COPY `$(SolutionDir)$package\Voltage.Payments.Host.Native.dll `$(TargetDir); COPY `$(SolutionDir)$package\ingfips.dll `$(TargetDir)" }

##"COPY `$(SolutionDir)$installPath\Voltage.Payments.Host.Native.dll `$(TargetDir); COPY `$(SolutionDir)$installPath\ingfips.dll `$(TargetDir)"

##\packages\PassportClearingEncryption.32bit.1.0.3