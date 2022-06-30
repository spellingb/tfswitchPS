#requires -modules BuildHelpers
#requires -modules Pester

Describe "General Module Validation" -Tag Unit {

    BeforeAll {
        Remove-Item -Path Env:\BH*
        $projectRoot = (Resolve-Path "$PSScriptRoot/..").Path
        if ($projectRoot -like "*Release") {
            $projectRoot = (Resolve-Path "$projectRoot/..").Path
        }

        Import-Module BuildHelpers
        Set-BuildEnvironment -BuildOutput '$ProjectPath/Release' -Path $projectRoot -ErrorAction SilentlyContinue

        $env:BHManifestToTest = $env:BHPSModuleManifest
        $script:isBuild = $PSScriptRoot -like "$env:BHBuildOutput*"
        if ($script:isBuild) {
            $Pattern = [regex]::Escape($env:BHProjectPath)

            $env:BHBuildModuleManifest = $env:BHPSModuleManifest -replace $Pattern, $env:BHBuildOutput
            $env:BHManifestToTest = $env:BHBuildModuleManifest
        }

        Import-Module "$env:BHProjectPath/Tools/BuildTools.psm1"

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue -Force
        # Import-Module $env:BHManifestToTest

    }
    AfterAll {
        # Set-Content -Value $oldConfig -Path $configFile -Force

        Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
        Remove-Module BuildHelpers -ErrorAction SilentlyContinue
        Remove-Item -Path Env:\BH*
    }

    It "passes Test-ModuleManifest" {
        { Test-ModuleManifest -Path $env:BHManifestToTest -ErrorAction Stop } | Should -Not -Throw
    }

    It "module '$env:BHManifestToTest' can import cleanly" {
        { Import-Module $env:BHManifestToTest } | Should -Not -Throw
    }

    It -Name "module '$env:BHProjectName' exports functions" -Test {
        Import-Module $env:BHManifestToTest

        (Get-Command -Module $env:BHProjectName | Measure-Object).Count | Should -BeGreaterThan 0
    }

    It "module uses the correct root module" {
        Get-Metadata -Path $env:BHManifestToTest -PropertyName RootModule | Should -Be 'TFSwitchPS.psm1'
    }

    It "module uses the correct guid" {
        Get-Metadata -Path $env:BHManifestToTest -PropertyName Guid | Should -Be 'd80481d7-da90-4e48-89e2-4a6f392c9b9c'
    }

    It "module uses a valid version" {
        [Version](Get-Metadata -Path $env:BHManifestToTest -PropertyName ModuleVersion) | Should -Not -BeNullOrEmpty
        [Version](Get-Metadata -Path $env:BHManifestToTest -PropertyName ModuleVersion) | Should -BeOfType [Version]
    }
}
