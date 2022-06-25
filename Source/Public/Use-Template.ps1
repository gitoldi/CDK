function Use-Template {
    <#

    .SYNOPSIS
    Sjabloon bestand.

    .DESCRIPTION
    Sjabloon bestand.

    Een sjabloon gemaakt als begin voor nieuwe scripts.
    Deze kopieren naar een nieuw bestand en die dan bewerken.

    .PARAMETER xxx
    Beschrijf de parameters die je gebruikt in je script.

    .PARAMETER Version
    Deze parameter gebruik ik altijd in mijn scripts om per script de versie op te kunnen vragen.
    Als deze is opgezet wordt dit ook goed gebruikt door mijn versie van 'Get-Command -module <modulenaam>' 
    namelijk 'Get-CommandVersion -module 'modulenaam'.

    .EXAMPLE
    C:\> .\Use-Template.ps1

    .INPUTS
    Anderen dan de 'PARAMETERS'.

    .OUTPUTS
    Wat er als resultaat beschikbaar is als het script is gebruikt.
    Bijvoorbeeld:
    - HTML bestand.
    - Log bestand.
    - Een 'PSCustomObject'.

    .LINK
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.2

    .NOTES
    Name    : Use-Template
    Author  : <Auteur>
    Historie:

    220625 - 0.2.0 MR
    - Type foutjes aangepast.
    - Kleine aanpassingen.

    220624 - 0.1.0 MR
    - 220624 is JJMMDD.
    - De eerste versie van het sjabloon bestand.
    #>

    #region 'Initialization.'
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string] $Path = $env:USERPROFILE
        ,
        [Parameter(Mandatory = $false)]
        [switch] $Version = $false
    )
    $ScriptName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Begin."

    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Test if parameter 'Version' is supplied."
    [Version] $ScriptVersion = '0.2.0'
    if ($Version) {
        Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Version: $($ScriptVersion)"
        return $ScriptVersion
    }
    #endregion 'Initialization.'

    #region 'Define variables.'
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Define variables."
    $FilesAll           = @{}
    $FilesTotal         = $FilesAll.Count
    #endregion 'Define variables.'

    #region 'Main.'
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Begin."

    #region 'Test parameter PATH'.
    if (Test-Path $Path -ErrorAction SilentlyContinue) {
        Write-Host -Object "$(Get-TimeStamp) $($ScriptName) List files from: $($Path)"
        $FilesAll           = Get-ChildItem -File -Recurse -path $Path
        $FilesTotal         = $FilesAll.Count
        Write-Host -Object "$(Get-TimeStamp) $($ScriptName) Files found    # $($FilesTotal)"    
    }
    else {
        Write-Warning -Message "$(Get-TimeStamp) $($ScriptName) Parameter 'PATH' not supplied."
    }
    #endregion 'Test parameter PATH'.
    
    #endregion 'Main.'

    #region 'Finished.'
    [PSCustomObject]@{
        FilesAll   = $FilesAll
        FilesTotal = $FilesTotal
    }
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Einde."
    #endregion 'Finished.'
}