Function Test-TerraformVersion{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Version
    )
    $tfVersion = Get-TerraformInstalledVersionList -Version $Version
    $versionTest = Invoke-Expression "$($tfVersion.Path) --version"
    $versionTestVersion = ($versionTest | Where-Object { $_ -match 'Terraform v\d{1,}\.\d{1,}\.\d{1,}' }).Split()[-1].Trim('v')
    $tfVersion.Version -eq $versionTestVersion
}
