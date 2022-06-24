<#
.SYNOPSIS
Prefix part to a module.

.DESCRIPTION
Prefix part to a module.
Based on ModuleBuilder documentation.
Use this prefix part to do some initialization for the module.
Like : load config for this module.

.EXAMPLE
NA

.INPUTS
NA

.OUTPUTS
NA

.NOTES
Copyright 2018-<today>, Marcel Rijsbergen.
    
History:
Do not forget to create a short modification text in CHANGELOG.md.

190518 MR
- 1.0.3 Added VerbosePreference check.

190518 MR
- 1.0.2 Still struggling with -verbose.

#>

#Region 'Initialize.'

[ CmdletBinding( )]

param( )

$CurCommand   = $MyInvocation.MyCommand
$ScriptName   = [io.path]::GetFileNameWithoutExtension($CurCommand.Name)
$ScriptFolder = Split-Path $CurCommand.Path
#TODO Find a way to check language for local name of 'Documents'.
[string] $FolderRoot   = Join-Path -Path $env:OneDrive -ChildPath 'Documenten'
[string] $FolderConfig = Join-Path -Path $FolderRoot -ChildPath 'Config'
[bool]   $IsVerbose    = $false

#Region : 'Check if Verbose file is set.'
$VerboseFile = $ScriptFolder + '\' + $ScriptName + '.On'
if (Test-Path $VerboseFile) {
    $IsVerbose = $true
}
#EndRegion : 'Check if Verbose file is set.'

#Region 'Function - Required - Get-TimeStamp.'
if (Get-Command Get-TimeStamp -ErrorAction SilentlyContinue) {
    if ($IsVerbose) {
        Write-Output -InputObject "$( Get-TimeStamp ) $( $ScriptName ) INFO Function 'Get-TimeStamp' exists."
    }
} else {
    if ($IsVerbose) {
        Write-Output -InputObject '...' $ScriptName "INFO Function 'Get-TimeStamp' does not exist, create a quick one."
    }
    function Get-TimeStamp {
        <#

        .SYNOPSIS
        Return a time stamp to be used in e.g.: logfiles, 

        .DESCRIPTION
        Return a time stamp to be used in e.g.: logfiles, 

        .EXAMPLE
        PS> Get-TimeStamp
        20191004-184821.729

        .INPUTS
        NA

        .OUTPUTS
        NA

        .NOTES
        Author      : Marcel Rijsbergen.
        Copyright   : 2018-<today>, Marcel Rijsbergen.
        History     : Can not remember. Used it already pretty quick after i created functions.
        Ideas       :
        - Add parameters to be able to return different output.
        
        #>
        Return (Get-Date -Format "yyyyMMdd-HHMMSS")
    }
}
#EndRegion 'Function - Required - Get-TimeStamp.'

if ($IsVerbose) {Write-Output -InputObject "$(Get-TimeStamp) $($ScriptName) INFO Loading module."}
#EndRegion 'Initialize.'

#Region 'Test for config and read it.'
$Curdir = Get-Location
if ($IsVerbose) {Write-Output -InputObject "$(Get-TimeStamp) $ScriptName INFO Current folder : $($curdir)"}
$ConfigFile = $FolderConfig + '\Config-' + $ScriptName + '.psd1'
$ConfigName = $ScriptName -replace '[-_]',''
if ($IsVerbose) {Write-Output -InputObject "$(Get-TimeStamp) $ScriptName INFO Try Config file : $($ConfigFile)"}
if ($IsVerbose) {Write-Output -InputObject "$(Get-TimeStamp) $ScriptName INFO Set Config variable : $($ConfigName)"}
if (Test-Path $ConfigFile ) {
    try {
        $CurConfig = "Config.$($ConfigName)"
        $SetVarHash = @{
            Name        = $CurConfig
            Value       = (Import-PowerShellDataFile -Path $ConfigFile)
            Description = "Configuration for module $($ScriptName)"
        }
        Set-Variable -Scope Global @SetVarHash
        if ($IsVerbose) {
            Write-Host -Object "$(Get-TimeStamp) $ScriptName INFO Config loaded into : $($CurConfig)" -ForegroundColor Green
        }
        try {
            $ThisConfig = (Get-Variable $CurConfig).Value
            if ($ThisConfig.Folders) {
                if ($IsVerbose) {
                    Write-Output -InputObject "$(Get-TimeStamp) $ScriptName INFO Config found for folders, process."
                    Write-Output -InputObject "$(Get-TimeStamp) $ScriptName INFO Test folders."
                }
                else {
                    write-Host "$(Get-TimeStamp) $ScriptName INFO Process folder" -NoNewline
                }
                foreach ($TestFolder in $ThisConfig.Folders) {
                    $ThisFolder = Join-Path -Path $FolderRoot -ChildPath $TestFolder
                    if ($IsVerbose) {
                        Write-Output -InputObject "$(Get-TimeStamp) $ScriptName INFO Process folder : $($ThisFolder)"
                    }
                    $ThisStatus = 'none'
                    if (Test-Path -Path $ThisFolder) {
                        if ($IsVerbose) {Write-Output -InputObject "$(Get-TimeStamp) $ScriptName INFO Folder exists."}
                        $ThisStatus = 'exists'
                        Set-Variable -Name "Folder$($TestFolder)" -Value "$($ThisFolder)" -Scope Global
                    }
                    else {
                        if ($IsVerbose) {Write-Output -InputObject "$(Get-TimeStamp) $ScriptName INFO Folder does NOT exists."}
                        try {
                            if ($IsVerbose) {Write-Output -InputObject "$(Get-TimeStamp) $ScriptName INFO Create folder."}
                            New-Item -Path $ThisFolder -ItemType Directory -ErrorAction Stop
                            if ($IsVerbose) {Write-Output -InputObject "$(Get-TimeStamp) $ScriptName INFO Created folder."}
                            Set-Variable -Name "Folder$($TestFolder)" -Value "$($ThisFolder)" -Scope Global
                            $ThisStatus = 'create - success'
                        }
                        catch {
                            if ($IsVerbose) {Write-Warning -Message "$(Get-TimeStamp) $ScriptName INFO Error creating folder."}
                            $ThisStatus = 'create - failed'
                        }
                    }
                    if (-NOT ($IsVerbose)) {Write-Output -InputObject " - $($TestFolder) ($($ThisStatus))" -NoNewline}
                }
                if (-NOT ($IsVerbose)) {Write-Output -InputObject ''}
            }
            else {
                Write-Warning -Message "$(Get-TimeStamp) $($ScriptName) WARNING No config found for 'Folders'."
            }
        }
        catch {
            #
        }
    } catch {
        if ($IsVerbose) {
            Write-Host -Object "$(Get-TimeStamp) $ScriptName WARNING Config load : Failed" -ForegroundColor Yellow
        }
    }
} else {
    if ($IsVerbose) {
        Write-Output -InputObject "$(Get-TimeStamp) $ScriptName INFO No config file :" $ConfigFile
    }
}
#EndRegion 'Test for config and read it.'
