Function Get-TerraformRemoteVersionList{
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Version
    )
    Function parseVersion($htmlInput){
        $versionName =$htmlInput.trim().TrimEnd('</a>').Split('>')[1]
        $version = $htmlInput.TrimStart().Split('"')[1].Split('/').Where({$_})[-1]
        $versionPath = $htmlInput.Trim().Split('"')[1]
        $os = if($IsWindows){'windows'}elseif($IsLinux){'linux'}else{throw 'invalid OS'}
        $arch = if([Environment]::Is64BitOperatingSystem){'amd64'}else{'386'}

        $href = 'https://releases.hashicorp.com{0}{1}_{2}_{3}.zip' -f $versionPath, $versionName,$os,$arch
        New-Object psobject -Property ([ordered]@{
            Version = $htmlInput.TrimStart().Split('"')[1].Split('/').Where({$_})[-1]
            Name = $versionName
            isInstalled = [bool](Get-TerraformInstalledVersionList -Version $version -Verbose:$false -WarningAction SilentlyContinue)
            Link = $href
        })
    }
    $splat = @{
        Uri = 'https://releases.hashicorp.com/terraform'
        Verbose = $false
        ErrorAction = 'Stop'
    }
    $versionPattern = "<a href=`"/terraform/\d{1,}\.\d{1,}\.\d{1,}\/"
    try {
        $tfReturn = Invoke-WebRequest @splat

        if ( $tfReturn.StatusCode -eq '200') {
            $tfReturn.Content -split "`n" | 
                Where-Object { $_ -match $versionPattern -and $_ -like "*$Version*"} |
                    ForEach-Object { parseVersion $_ } |
                        Where-Object {if($Version){$_.Version -eq $Version}else{$true}}
        }
    } catch {
        Write-Warning $($_.Exception.Message)
    }
}
