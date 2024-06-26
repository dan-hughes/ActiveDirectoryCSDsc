using module .\Modules\DscResource.Base

$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules/DscResource.Common'
Import-Module -Name $script:dscResourceCommonModulePath

# TODO: The goal would be to remove this, when no classes and public or private functions need it.
$script:activeDirectoryCSDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules/ActiveDirectoryCSDsc.Common'
Import-Module -Name $script:activeDirectoryCSDscCommonModulePath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'
