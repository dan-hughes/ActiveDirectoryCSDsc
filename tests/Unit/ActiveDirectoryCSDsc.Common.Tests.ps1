<#
    .SYNOPSIS
        Unit test for helper functions in module ActiveDirectoryCSDsc.Common.

    .NOTES
#>

# Suppressing this rule because Script Analyzer does not understand Pester's syntax.
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param ()

BeforeDiscovery {
    try
    {
        if (-not (Get-Module -Name 'DscResource.Test'))
        {
            # Assumes dependencies has been resolved, so if this module is not available, run 'noop' task.
            if (-not (Get-Module -Name 'DscResource.Test' -ListAvailable))
            {
                # Redirect all streams to $null, except the error stream (stream 2)
                & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
            }

            # If the dependencies has not been resolved, this will throw an error.
            Import-Module -Name 'DscResource.Test' -Force -ErrorAction 'Stop'
        }
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -ResolveDependency -Tasks build" first.'
    }
}

BeforeAll {
    $script:dscModuleName = 'ActiveDirectoryCSDsc'
    $script:subModuleName = 'ActiveDirectoryCSDsc.Common'

    $script:parentModule = Get-Module -Name $script:dscModuleName -ListAvailable | Select-Object -First 1
    $script:subModulesFolder = Join-Path -Path $script:parentModule.ModuleBase -ChildPath 'Modules'

    $script:subModulePath = Join-Path -Path $script:subModulesFolder -ChildPath $script:subModuleName

    Import-Module -Name $script:subModulePath -Force -ErrorAction 'Stop'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\TestHelpers\CommonTestHelper.psm1')


    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:subModuleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:subModuleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:subModuleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    # Unload the module being tested so that it doesn't impact any other tests.
    Get-Module -Name $script:subModuleName -All | Remove-Module -Force

    # Remove module common test helper.
    Get-Module -Name 'CommonTestHelper' -All | Remove-Module -Force
}

Describe 'ActiveDirectoryCSDsc.Common\Restart-SystemService' -Tag 'RestartSystemService' {
    BeforeAll {
        Mock -CommandName Restart-Service

        $restartServiceIfExistsParams = @{
            Name = 'BITS'
        }
    }

    Context 'When service does not exist and is not restarted' {
        BeforeAll {
            Mock -CommandName Get-Service
        }

        It 'Should call the expected mocks' {
            Restart-ServiceIfExists @restartServiceIfExistsParams

            Should -Invoke -CommandName Get-Service -ParameterFilter {
                $Name -eq $restartServiceIfExistsParams.Name
            } -Exactly -Times 1 -Scope It
            
            Should -Invoke -CommandName Restart-Service -Exactly -Times 0 -Scope It
        }
    }

    Context 'When service exists and will be restarted' {
        BeforeAll {
            $mockGetService = {
                @{
                    Status      = 'Running'
                    Name        = 'Servsvc'
                    DisplayName = 'Service service'
                }
            }

            Mock -CommandName Get-Service -MockWith $mockGetService
        }

        It 'Should call the expected mocks' {
            Restart-ServiceIfExists @restartServiceIfExistsParams

            Should -Invoke -CommandName Get-Service -ParameterFilter {
                $Name -eq $restartServiceIfExistsParams.Name
            } -Exactly -Times 1 -Scope It

            Should -Invoke -CommandName Restart-Service -Exactly -Times 1 -Scope It
        }
    }
}
