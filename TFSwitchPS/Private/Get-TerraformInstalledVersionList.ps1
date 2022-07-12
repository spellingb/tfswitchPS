Function Get-TerraformInstalledVersionList {
    [CmdletBinding()]
    param (

        [Parameter()]
        [string]
        $Version

    )
    Begin {

        Write-Verbose "[$($MyInvocation.MyCommand)] Starting Function"
    
    }
    Process {

        $tfVersions = Get-ChildItem $env:TFSWITCH_BASEDIR -Recurse -File -Filter 'terraform.exe' -ErrorAction SilentlyContinue

        if ( !$tfversions ) {

            Write-Warning "No Terraform Install found in location $env:TFSWITCH_BASEDIR"


        } elseif ( $Version ) {

            Write-Verbose "[$($MyInvocation.MyCommand)] Filtering for Version [$Version]"

        }
        
        $return = $tfVersions | ForEach-Object {

            $versionTemp = Split-Path $_ -Parent | Split-Path -Leaf

            New-Object psobject -Property ([ordered]@{

                Version = $versionTemp

                isActive = $versionTemp -eq $env:TFSWITCH_VERSION

                Path = $_.FullName

            })
        }

        if ( $Version ) {

            $return = $return | Where-Object { $_.Version -eq $Version }

            if ( !$return ) {

                Write-Warning "[$Version] version not found locally."

            }
        }
    
        return $return

    }
}
