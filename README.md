# tfswitchPS

Powershell utility to switch between Terraform versions

## INSTALLATION

Install the module from PSGallery

    Install-Module -Name TFSwitchPS

Import the Module

    Import-Module -Name TFSwitchPS

## USAGE

### List Local/Remote Versions

List Installed TF Versions

    tfswitch -l
    or
    tfswitch -List

List Versions available for install (remote versions)

    tfswitch -l -r
    or
    tfswitch -List -Remote

List a specific Version

local

    tfswitch -l 1.1.0
    or
    tfswitch -List 1.1.0
    or
    tfswitch -List -Version 1.1.0
    or
    tfswitch -l -v 1.1.0

remote

    tfswitch -l -r 1.1.0
    or
    tfswitch -List -Remote -Version 1.1.0
    or
    tfswitch -l -r -v 1.1.0

### Set/Unset Version

Set Active Terraform Version

    tfswitch 1.1.0
    or
    tfswitch -Set 1.1.0

Unset Active Terraform Version

    tfswitch -u
    or
    tfswitch -UnSet

### Install/Uninstall Version

Note that installing a version does not set it as the *Default Version*

Install specific version.

    tfswitch -Install -Version 1.1.0
    or
    tfswitch -i 1.1.0

Uninstall version

    tfswitch -d 1.2.2
    or
    tfswitch -Uninstall 1.2.2
