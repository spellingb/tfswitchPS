Function Set-TerraformVersion {
    [CmdletBinding(DefaultParameterSetName = 'none')]
    [alias('tfswitch','tfs')]
    param (
        # Install a version of terraform
        [Parameter(ParameterSetName = 'Install')]
        [alias('i')]
        [switch]
        $Install,

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

        # Specific version of Terraform to view, install, or set as active
        [Parameter(ParameterSetName = 'Set',Position = 0, Mandatory = $true)]
        [Parameter(ParameterSetName = 'Install', Position = 0, Mandatory = $true)]
        [Parameter(ParameterSetName = 'List', Position = 0)]
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
        $choco = Invoke-Expression "choco list terraform -le"
        if ( $choco ){
            $chocoPackageInstalls = $choco | Where-Object {$_ -match "\d{1,} packages installed" }
            [int]$packageCount = $chocoPackageInstalls.Substring(0,2).trim()
            if ( $packageCount ) {
                Write-Warning "Chocolatey Terraform Packages detected. Uninstall in order to use tfswitch."
                $choco
                # exit
            }
        }
        $baseInstallDir = $home + '\.terraform'
        if ( -not ( Test-Path $baseInstallDir ) ) {
            Write-Verbose 'Terraform Base Directory Missing'
            New-Item $baseInstallDir -Force -ItemType Directory | Out-Null
        }

        Function Get-TFInstalledVersionList($Version) {
            $tfVersions = Get-ChildItem $baseInstallDir -Recurse -File -Filter 'terraform.exe'
            if ( !$tfversions ) {
                Write-Warning "No Terraform Install found in location $baseInstallDir"
            }
            $currentTFVersion = Get-TFActiveVersion -WarningAction SilentlyContinue

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
        Function Test-TFVersion($Version){
            $tfVersion = Get-TFInstalledVersionList -Version $Version
            $versionTest = Invoke-Expression "$($tfVersion.Path) --version"
            $versionTestVersion = ($versionTest | Where-Object { $_ -match 'Terraform v\d{1,}\.\d{1,}\.\d{1,}' }).Split()[-1].Trim('v')
            $tfVersion.Version -eq $versionTestVersion
        }
        Function Get-TFActiveVersion{
            [CmdletBinding()]
            Param()
            # $tfVersionTest = Invoke-Expression "terraform --version"
            
            try {
                Invoke-Expression "terraform --version" | Where-Object { $_ -match 'Terraform v\d{1,}\.\d{1,}\.\d{1,}' }
            } catch {
                Write-Warning 'Terraform not installed or path not set'
            }
        }
        Function Get-TFRemoteVersionList($Version){
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
                    isInstalled = [bool](tfswitch -list -Version $version)
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
        Function Install-TFVersion ( $Version ){
                $versionDirectory = Join-Path -Path $baseInstallDir -ChildPath $Version
                
                #Make Directory Structure
                New-Item $versionDirectory -Force -ItemType Directory | Out-Null

                $targetVersion = Get-TFRemoteVersionList -Version $Version

                $splat = @{
                    Uri = $targetVersion.Link
                    OutFile = "$env:TEMP\$($targetVersion.Name).zip"
                    Method = 'Get'
                    ErrorAction = 'Stop'
                    Verbose = $false
                    DisableKeepAlive = $true
                }
                try {
                    #Download Zip File to temp location
                    Invoke-WebRequest @splat

                    #Unzip to destination
                    Expand-Archive -Path $splat.OutFile -DestinationPath $versionDirectory -Force

                    #Validate
                    $validatedFile = Test-TFVersion -Version $Version
                    if ( $validatedFile ) {
                        Get-TFInstalledVersionList -Version $Version
                    } else {
                        throw 'File Validation Failed'
                    }

                    #Clean up
                    Remove-Item -Path $splat.OutFile -Force -ErrorAction SilentlyContinue

                }
                catch {
                    Write-Warning "Failed to Install terraform version [$Version]"
                    Write-Warning ( $_.Exception | Out-String )
                    return
                }
        }
        Function Set-TFActiveVersion( $Version ){
            Clear-TFActiveVersion
            $targetVersion = Get-TFInstalledVersionList -Version $Version
            if ( [string]::IsNullOrEmpty($targetVersion) ) {
                Write-Warning "No active Terraform Version Set"
                return
            } else {
                $env:TFSWITCH_VERSION = $Version
                $env:TFSWITCH_PATH = Split-Path $targetVersion.Path
                $env:Path = $env:Path + ";$($env:TFSWITCH_PATH)"
    
                [System.Environment]::SetEnvironmentVariable('TFSWITCH_VERSION', $env:TFSWITCH_VERSION, [System.EnvironmentVariableTarget]::User)
                [System.Environment]::SetEnvironmentVariable('TFSWITCH_PATH', $env:TFSWITCH_PATH, [System.EnvironmentVariableTarget]::User)
                [System.Environment]::SetEnvironmentVariable('path', $env:Path ,[System.EnvironmentVariableTarget]::User)
            }
        }
        Function Clear-TFActiveVersion {
            $pathTemp = $env:Path.Clone()
            $env:Path = ($pathTemp.Split(';') | Where-Object {$_ -notmatch "\.terraform" }) -join ';'
            [System.Environment]::SetEnvironmentVariable( 'TFSWITCH_VERSION', $null, [System.EnvironmentVariableTarget]::User)
            [System.Environment]::SetEnvironmentVariable('path', $env:Path ,[System.EnvironmentVariableTarget]::User)
        }
    }
    Process {
        
        if ( $PSCmdlet.ParameterSetName -eq 'none' ) {
            Write-Verbose 'Running Workflow [default]'
            if ( $Version ) {
                tfswitch -Set -Version $Version
            } else {
                Get-TFActiveVersion    
            }
        }
        if ( $PSCmdlet.ParameterSetName -eq 'Install' ) {
            Write-Verbose 'Running "Install" Workflow'
            $tfTargetVersion = tfswitch -List -Remote -Version $Version

            if ( [string]::IsNullOrEmpty($tfTargetVersion) ) {
                Write-Warning "Terraform version [$Version] Not found"
                return
            }
            if ( $tfTargetVersion.isInstalled ) {
                return $tfTargetVersion
            } else {
                Install-TFVersion -Version $Version
            }
        }
        if ( $PSCmdlet.ParameterSetName -eq 'Set' ) {
            Write-Verbose 'Running Workflow [Set]'
            Set-TFActiveVersion -Version $Version
            Get-TFActiveVersion
        }
        if ( $PSCmdlet.ParameterSetName -eq 'List' ) {
            Write-Verbose 'Running workflow [List]'
            if ( $Remote ) {
                if ( $Version ) {
                    Get-TFRemoteVersionList -Version $Version
                } else {
                    Get-TFRemoteVersionList
                }
            } else {
                Get-TFInstalledVersionList| Where-Object { if($Version){$_.Version -like "*$Version*"}else{$true} }
            }
        }
    }
    End {

    }
}