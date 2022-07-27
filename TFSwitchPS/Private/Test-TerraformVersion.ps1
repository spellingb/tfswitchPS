Function Test-TerraformVersion {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter()]
        [string]
        $Version
    )
    Process {
        $tfVersion = Get-TerraformInstalledVersionList -Version $Version
        $versionTest = Invoke-Expression "$($tfVersion.Path) --version"
        $versionTestVersion = ($versionTest | Where-Object { $_ -match 'Terraform v\d{1,}\.\d{1,}\.\d{1,}' }).Split()[-1].Trim('v')
        [bool]($tfVersion.Version -eq $versionTestVersion)
    }
}
