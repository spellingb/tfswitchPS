#Region Dependencies
$choco = Invoke-Expression "choco list terraform -le"
if ( $choco ){
    $chocoPackageInstalls = $choco | Where-Object {$_ -match "\d{1,} packages installed" }
    [int]$packageCount = $chocoPackageInstalls.Substring(0,2).trim()
    if ( $packageCount ) {
        Write-Warning "Chocolatey Terraform Packages detected. Uninstall in order to use tfswitch."
        $choco
        exit 1
    }
}

#endregion

#region Configuration
$env:TFSWITCH_BASEDIR = ( Resolve-Path ~\.terraform ).Path

#endregion

#region LoadFunctions
$PublicFunctions = @( Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -ErrorAction SilentlyContinue )
$PrivateFunctions = @( Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue )

# Dot source the functions
foreach ($file in @($PublicFunctions + $PrivateFunctions)) {
    try {
        . $file.FullName
    }
    catch {
        $exception = ([System.ArgumentException]"Function not found")
        $errorId = "Load.Function"
        $errorCategory = 'ObjectNotFound'
        $errorTarget = $file
        $errorItem = New-Object -TypeName System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $errorTarget
        $errorItem.ErrorDetails = "Failed to import function $($file.BaseName)"
        throw $errorItem
    }
}
# Export-ModuleMember -Function $PublicFunctions.BaseName -Alias *
#endregion