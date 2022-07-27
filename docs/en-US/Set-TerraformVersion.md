---
external help file: TFSwitchPS-help.xml
Module Name: tfswitchPS
online version:
schema: 2.0.0
---

# Set-TerraformVersion

## SYNOPSIS

Use this function to manage the active version of Terraform

## SYNTAX

### none (Default)

```
Set-TerraformVersion [[-Version] <String>] [<CommonParameters>]
```

### Install

```
Set-TerraformVersion [-Install] [-Version] <String> [<CommonParameters>]
```

### Uninstall

```
Set-TerraformVersion [-Uninstall] [[-Version] <String>] [<CommonParameters>]
```

### List

```
Set-TerraformVersion [-List] [[-Version] <String>] [-Remote] [<CommonParameters>]
```

### Set

```
Set-TerraformVersion [-Set] [-Version] <String> [<CommonParameters>]
```

### Unset

```
Set-TerraformVersion [-UnSet] [<CommonParameters>]
```

## DESCRIPTION

Use this cmdlet to List, Install, Uninstall, and Set the active version of Terraform. The version is persistent.
Installing a version of Terraform does not automatically set it as active.

## EXAMPLES

### Example 1
```powershell
PS C:\> tfswitch
```

this will return the current active version of terraform

### Example 2

```powershell
PS C:\> tfswitch -l
```

this will return a list of installed terraform versions

### Example 3

```powershell
PS C:\> tfswitch -l -r
```

this will return a list of terraform versions available for install

### Example 4

```powershell
PS C:\> tfswitch -r 1.2.*
```

this will return a list of remote terraform versions that contain 1.2

### Example 5

```powershell
PS C:\> tfswitch -i 1.2.5
```

this will install Terraform version 1.2.5

### Example 6

```powershell
PS C:\> tfswitch 1.2.5
```

this will set Terraform version 1.2.5 as the active version

### Example 7

```powershell
PS C:\> tfswitch -UnSet
```

this will clear the active terraform version

### Example 8

```powershell
PS C:\> tfswitch -Uninstall 1.2.5
```

this will uninstall Terraform version 1.2.5


## PARAMETERS

### -Install
Installs a specific terraform version

```yaml
Type: SwitchParameter
Parameter Sets: Install
Aliases: i

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -List
Lists terraform versions. by default, lists local versions. us the -Remote parameter to list remote versions

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases: l

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remote
Lists terraform versions available for install

```yaml
Type: SwitchParameter
Parameter Sets: List
Aliases: r

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Set
Sets the active terraform version. this is the default parameter if you run tfswitch VERSION

```yaml
Type: SwitchParameter
Parameter Sets: Set
Aliases: s

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UnSet
Clears the active terraform version, leaving no version as active.

```yaml
Type: SwitchParameter
Parameter Sets: Unset
Aliases: u

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uninstall
Uninstalls the specified version of Terraform and deletes the local files.

```yaml
Type: SwitchParameter
Parameter Sets: Uninstall
Aliases: d

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Version
Specify the version number when performing an operation

```yaml
Type: String
Parameter Sets: none, Uninstall, List
Aliases: v

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: Install, Set
Aliases: v

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
