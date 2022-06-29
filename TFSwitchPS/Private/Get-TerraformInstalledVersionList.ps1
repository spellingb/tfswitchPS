Function Get-TerraformInstalledVersionList {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Version
    )
    $tfVersions = Get-ChildItem $baseInstallDir -Recurse -File -Filter 'terraform.exe'
    if ( !$tfversions ) {
        Write-Warning "No Terraform Install found in location $baseInstallDir"
    }

    $tfVersions | ForEach-Object {
        $versionTemp = Split-Path $_ -Parent | Split-Path -Leaf
        New-Object psobject -Property ([ordered]@{
            Version = $versionTemp
            isActive = $versionTemp -eq $env:TFSWITCH_VERSION
            Path = $_.FullName
        })
    } | Where-Object { if($Version){$_.Version -eq $Version }else{$true}}
                
        # ForEach-Object {
        #     New-object psobject -Property ([Ordered]@{
        #         Version = (Invoke-Expression "$($_.FullName) --version" | Where-Object { $_ -match 'Terraform v\d{1,}\.\d{1,}\.\d{1,}' }).Split()[-1].Trim('v')
        #         Path = $_.FullName
        #     })
        # } | Where-Object {if($Version){$_.Version -eq $Version}else{$true}}
}
