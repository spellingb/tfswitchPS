Function Get-TerraformVersion {
    try {
        Get-Command -Name Terraform -ErrorAction Stop | Select-Object Version,Name,Source
    }
    Catch {
        Write-Warning 'Terraform install not found'
    }
}
Function Test-TerraformVersion {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Version
    )
    Process {
        $baseInstallDir = 'C:\Tools\HashiCorp\Terraform'
        $installDir = $baseInstallDir + "\$Version"
        $binary = "$installDir\terraform.exe"
        $return = $false

        #Check if version already exists
        if ( Test-Path $installDir ) {
            if ( Test-Path $binary ) {
                ( Invoke-Expression "$binary --version" ) -match $Version
            }
        }
        if ( -not ( Test-Path $baseInstallDir ) ) {
            Write-Verbose 'Terraform Base Directory Missing'
            New-Item $baseInstallDir -Force -ItemType Directory | Out-Null
        }
        
        try {
            ( Get-ChildItem $baseInstallDir -Name $TargetVersion ) -eq $TargetVersion
        } catch {
            $false 
        }

    }
}
Function Get-TerraformVersionList {
    Param(
        [string]
        $Version,

        [switch]
        $Latest
    )
    Begin {
        Function TrimHTML($inputCode){
            $inputCode.TrimStart().Split('"')[1].Split('/').Where({$_})[-1]
        }
    }
    Process {
        $splat = @{
            Uri = 'https://releases.hashicorp.com/terraform/'
            Verbose = $false
            ErrorAction = 'Stop'
        }
        try {
            $terraformReleasesRaw = Invoke-WebRequest @splat

            if ( $terraformReleasesRaw.StatusCode -eq '200') {
                $return = $terraformReleasesRaw.Content -split "`n" | 
                    Where-Object { $_ -match "<a href=`"/terraform/" -and $_ -like "*$Version*" } |
                        ForEach-Object { TrimHTML $_ }
            }
        } catch {
            Write-Warning $($_.Exception.Message)
        }
        if ( $Latest ) {
            $return | Where-Object { try { [version]$_}catch{}} | Select-Object -First 1
        } else {
            $return | Where-Object { try { [version]$_}catch{}}
        }
    }
}

Function Install-TerraformVersion {
    [CmdletBinding()]
    param (
        [Parameter()]
        $Version = 'Latest'
    )
    Begin {
        $baseInstallDir = 'C:\Tools\HashiCorp\Terraform'
        $baseUri = 'https://releases.hashicorp.com/terraform/'
        #'1.2.3/terraform_1.2.3_windows_amd64.zip'
    }
    Process {
        #Validate Version
        if ( $Version -eq 'Latest' ) {
            $TargetVersion = Get-TerraformVersionList -Latest
        } else {
            $TargetVersion = Get-TerraformVersionList -Version $Version
        }

        #check if version exists
        if ( [string]::IsNullOrEmpty( $TargetVersion ) ) {
            Write-Warning "Terraform version $Version not found in repository $baseUri"
            return $null
        }

        
        
    }
}

