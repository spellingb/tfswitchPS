Function Get-TerraformActiveVersion{
    [CmdletBinding()]
    Param()
    # $tfVersionTest = Invoke-Expression "terraform --version"
    
    try {
        Invoke-Expression "terraform --version" | Where-Object { $_ -match 'Terraform v\d{1,}\.\d{1,}\.\d{1,}' }
    } catch {
        Write-Warning 'Terraform not installed or path not set'
    }
}
