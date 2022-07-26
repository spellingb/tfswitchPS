Function Get-TerraformRemoteVersionList{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Version
    )
    Begin {
        $splat = @{
            Uri = 'https://releases.hashicorp.com/terraform'
            Verbose = $false
            ErrorAction = 'Stop'
        }
        $versionPattern = "<a href=`"/terraform/\d{1,}\.\d{1,}\.\d{1,}\/"

    }
    Process {
        try {
            $tfReturn = Invoke-WebRequest @splat

            if ( $tfReturn.StatusCode -eq '200') {
                $tfReturn.Content -split "`n" |
                    Where-Object { $_ -match $versionPattern -and $_ -like "*$Version*"} |
                        ForEach-Object { Convertfrom-TerraformHTML $_ } |
                            Where-Object {
                                if ( $Version ) {
                                    $_.Version -like $Version
                                } else {
                                    $true
                                }
                            }
            }
        } catch {
            Write-Warning $($_.Exception.Message)
        }
    }
}
