Function Install-TerraformVersion {
    [CmdletBinding()]
    [Alias('Install-TFVersion')]

    param (

        [Parameter(Mandatory)]
        [string]
        $Version

    )
    Begin {
        Write-Verbose "[$($MyInvocation.MyCommand)] Starting Function"

        $splat = @{
            Uri = ''
            OutFile = ''
            Method = 'Get'
            ErrorAction = 'Stop'
            Verbose = $false
            DisableKeepAlive = $true
        }
    }
    Process {
        #Make Directory Structure
        $versionDirectory = Join-Path -Path $env:TFSWITCH_BASEDIR -ChildPath $Version

        New-Item $versionDirectory -Force -ItemType Directory | Out-Null
    
        #Get Remote Version
        $targetVersion = Get-TerraformRemoteVersionList -Version $Version

        if ( !$targetVersion ) {

            Write-Verbose "[$($MyInvocation.MyCommand)] [$Version] version not found on remote."

            Write-Warning "[$($MyInvocation.MyCommand)] [$Version] version not found"

            return $null
        } else {

            $splat.Uri = $targetVersion.Link

            $splat.OutFile = "$env:TEMP\$($targetVersion.Name).zip"

            try {
                #Download Zip File to temp location
                Invoke-WebRequest @splat
        
                #Unzip to destination
                Expand-Archive -Path $splat.OutFile -DestinationPath $versionDirectory -Force
        
                #Validate File
                $validatedFile = Test-TFVersion -Version $Version

                if ( $validatedFile ) {

                    Get-TerraformInstalledVersionList -Version $Version

                } else {

                    throw 'File Validation Failed'

                }
        
                #Clean up
                Remove-Item -Path $splat.OutFile -Force -ErrorAction SilentlyContinue
        
            }
            catch {

                Write-Warning "Failed to Install terraform version [$Version]"

                Write-Warning ( $_.Exception | Out-String )

                return $null

            }
    
        }
            
    }
}
