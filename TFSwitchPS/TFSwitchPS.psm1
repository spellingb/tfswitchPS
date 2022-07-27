#Region Dependencies
$choco = Get-Command 'choco.exe' -ErrorAction SilentlyContinue
if ( $choco ) {
    $chocoInstalledTerraform = . {choco list -local -allversions --limitoutput --exact 'terraform'} #| Where-Object { $_ -match "\d{1,} packages installed" }
    if ( $chocoInstalledTerraform ) {
        Write-Warning 'Chocolatey Terraform Packages detected. Uninstall in order to use tfswitch. (Command: "choco uninstall terraform -a -f -y" )'
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