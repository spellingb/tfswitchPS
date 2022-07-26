Function Convertfrom-TerraformHTML {
    [CmdletBinding()]
    Param(
        $HTMLInput
    )
    Process {
        $versionName =$htmlInput.trim().TrimEnd('</a>').Split('>')[1]
        $removeVersion = $htmlInput.TrimStart().Split('"')[1].Split('/').Where({$_})[-1]
        $versionPath = $htmlInput.Trim().Split('"')[1]
        $os = if($IsWindows){'windows'}elseif($IsLinux){'linux'}else{throw 'invalid OS'}
        $arch = if([Environment]::Is64BitOperatingSystem){'amd64'}else{'386'}

        $href = 'https://releases.hashicorp.com{0}{1}_{2}_{3}.zip' -f $versionPath, $versionName,$os,$arch
        New-Object psobject -Property ([ordered]@{
            Version = $htmlInput.TrimStart().Split('"')[1].Split('/').Where({$_})[-1]
            Name = $versionName
            isInstalled = [bool](Get-TerraformInstalledVersionList -Version $removeVersion -Verbose:$false -WarningAction SilentlyContinue)
            Link = $href
        })
    }
}