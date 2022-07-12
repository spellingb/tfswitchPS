Function Set-TerraformVersion {
    [CmdletBinding(DefaultParameterSetName = 'none')]
    [alias('tfswitch','tfs')]
    param (
        # Install a version of terraform
        [Parameter(ParameterSetName = 'Install')]
        [alias('i')]
        [switch]
        $Install,

        [Parameter(ParameterSetName = 'Uninstall')]
        [alias('d')]
        [switch]
        $Uninstall,

        # List installed TF Versions
        [Parameter(ParameterSetName = 'List')]
        [alias('l')]
        [switch]
        $List,

        # Set the active version of Terraform
        [Parameter(ParameterSetName = 'Set')]
        [alias('s')]
        [switch]
        $Set,

        # Set the active version of Terraform
        [Parameter(ParameterSetName = 'Unset')]
        [alias('u')]
        [switch]
        $UnSet,

        # Specific version of Terraform to view, install, or set as active
        [Parameter(ParameterSetName = 'Set',Position = 0, Mandatory = $true)]
        [Parameter(ParameterSetName = 'Install', Position = 0, Mandatory = $true)]
        [Parameter(ParameterSetName = 'List', Position = 0)]
        [Parameter(ParameterSetName = 'Uninstall', Position = 0)]
        [Parameter(ParameterSetName = 'none', Position = 0)]
        [alias('v')]
        [string]
        $Version,

        #When listing versions, use to get a list of versions available for install
        [Parameter(ParameterSetName = 'List')]
        [alias('r')]
        [switch]
        $Remote
    )
    Begin {
        $baseInstallDir = $home + '\.terraform'
        if ( -not ( Test-Path $baseInstallDir ) ) {
            Write-Verbose 'Terraform Base Directory Missing'
            New-Item $baseInstallDir -Force -ItemType Directory | Out-Null
        }

    }
    Process {
        
        if ( $PSCmdlet.ParameterSetName -eq 'none' ) {
            Write-Verbose 'Running Workflow [default]'
            if ( $Version ) {
                tfswitch -Set -Version $Version
            } else {
                Get-TerraformActiveVersion    
            }
        }
        if ( $PSCmdlet.ParameterSetName -eq 'Install' ) {
            Write-Verbose 'Running Workflow [Install]'
            $tfTargetVersion = Get-TerraformRemoteVersionList -Version $Version

            if ( [string]::IsNullOrEmpty($tfTargetVersion) ) {
                Write-Warning "Terraform version [$Version] Not found"
                return
            }
            if ( $tfTargetVersion.isInstalled ) {
                return $tfTargetVersion
            } else {
                Install-TerraformVersion -Version $Version
            }
        }
        if ( $PSCmdlet.ParameterSetName -eq 'Uninstall' ) {
            Write-Verbose 'Running "Install" Workflow'
            $tfTargetVersion = Get-TerraformInstalledVersionList -Version $Version

            if ( [string]::IsNullOrEmpty($tfTargetVersion) ) {
                Write-Warning "Terraform version [$Version] Not found"
                return
            }
            if ( $tfTargetVersion.isActive ) {
                Write-Warning 'Version Currently set as active. Unset and try again.'
                return
            }

            $versionPath = Split-Path $tfTargetVersion.Path

            try {
                Remove-Item $versionPath -Force -Confirm:$false -Recurse -ErrorAction Stop
                Write-Warning "Terraform Version [$Version] deleted successfully"
            }
            catch {
                Write-Warning "Failed to delete Terraform Version [$Version]"
            } 
        }
        if ( $PSCmdlet.ParameterSetName -eq 'Set' ) {
            Write-Verbose 'Running Workflow [Set]'
            Set-TerraformActiveVersion -Version $Version
            Get-TerraformActiveVersion
        }
        if ( $PSCmdlet.ParameterSetName -eq 'Unset' ) {
            Write-Verbose 'Running Workflow [Unset]'
            Install-TerraformActiveVersion   
            Get-TerraformActiveVersion
        }
        if ( $PSCmdlet.ParameterSetName -eq 'List' ) {
            Write-Verbose 'Running workflow [List]'
            if ( $Remote ) {
                if ( $Version ) {
                    Get-TerraformRemoteVersionList -Version $Version
                } else {
                    Get-TerraformRemoteVersionList
                }
            } else {
                if ( $Version ) {
                    Get-TerraformInstalledVersionList -Version $Version    
                }else {
                    Get-TerraformInstalledVersionList
                }
            }
        }
    }
    End {

    }
}