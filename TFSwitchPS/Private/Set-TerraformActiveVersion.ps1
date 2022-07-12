Function Set-TerraformActiveVersion{
    [CmdletBinding()]
    [Alias('Set-TFActiveVersion')]
    param (
        [Parameter()]
        [string]
        $Version
    )
    Begin {
        Clear-TFActiveVersion
        $targetVersion = Get-TerraformInstalledVersionList -Version $Version
    }
    Process {
        if ( [string]::IsNullOrEmpty($targetVersion) ) {
            Write-Warning "No active Terraform Version Set"
            return
        } else {
            Write-Verbose "Setting Variable: TFSWITCH_VERSION ;Value: [$Version]"
            $env:TFSWITCH_VERSION = $Version

            Write-Verbose "Setting Variable: TFSWITCH_PATH ;Value: [$(Split-Path $targetVersion.Path)]"
            $env:TFSWITCH_PATH = Split-Path $targetVersion.Path

            Write-Verbose "Setting Variable: PATH ;Value: [`$env:path + ;$env:TFSWITCH_PATH]"
            $env:Path = $env:Path + ";$($env:TFSWITCH_PATH)"

            [System.Environment]::SetEnvironmentVariable('TFSWITCH_VERSION', $env:TFSWITCH_VERSION, [System.EnvironmentVariableTarget]::User)
            [System.Environment]::SetEnvironmentVariable('TFSWITCH_PATH', $env:TFSWITCH_PATH, [System.EnvironmentVariableTarget]::User)
            [System.Environment]::SetEnvironmentVariable('path', $env:Path ,[System.EnvironmentVariableTarget]::User)
        }
    }
}
