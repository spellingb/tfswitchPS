Function Install-TerraformVersion {
    [CmdletBinding()]
    [Alias('Install-TFVersion')]
    param (
        [Parameter()]
        [string]
        $Version
    )
    $versionDirectory = Join-Path -Path $baseInstallDir -ChildPath $Version
    
    #Make Directory Structure
    New-Item $versionDirectory -Force -ItemType Directory | Out-Null

    $targetVersion = Get-TFRemoteVersionList -Version $Version

    $splat = @{
        Uri = $targetVersion.Link
        OutFile = "$env:TEMP\$($targetVersion.Name).zip"
        Method = 'Get'
        ErrorAction = 'Stop'
        Verbose = $false
        DisableKeepAlive = $true
    }
    try {
        #Download Zip File to temp location
        Invoke-WebRequest @splat

        #Unzip to destination
        Expand-Archive -Path $splat.OutFile -DestinationPath $versionDirectory -Force

        #Validate
        $validatedFile = Test-TFVersion -Version $Version
        if ( $validatedFile ) {
            Get-TFInstalledVersionList -Version $Version
        } else {
            throw 'File Validation Failed'
        }

        #Clean up
        Remove-Item -Path $splat.OutFile -Force -ErrorAction SilentlyContinue

    }
    catch {
        Write-Warning "Failed to Install terraform version [$Version]"
        Write-Warning ( $_.Exception | Out-String )
        return
    }
}
