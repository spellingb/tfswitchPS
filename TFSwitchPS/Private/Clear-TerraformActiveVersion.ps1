Function Clear-TerraformActiveVersion {
    [CmdletBinding()]
    [OutputType([void])]
    param (
    )
    Process {
        Write-Verbose "[$($MyInvocation.MyCommand)] Starting Function"
        Write-Verbose "Clearing Active Terraform Version State"
        Remove-Item Env:\TFSWITCH_PATH -ErrorAction SilentlyContinue
        Remove-Item Env:\TFSWITCH_VERSION -ErrorAction SilentlyContinue
        $pathTemp = $env:Path.Clone()
        $env:Path = ($pathTemp.Split(';') | Where-Object {$_ -notmatch "\.terraform" }) -join ';'
        [System.Environment]::SetEnvironmentVariable( 'TFSWITCH_VERSION', $null, [System.EnvironmentVariableTarget]::User)
        [System.Environment]::SetEnvironmentVariable('path', $env:Path ,[System.EnvironmentVariableTarget]::User)
    }
}
