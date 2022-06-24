<#
.SYNOPSIS
    Suffix part to a module.

.DESCRIPTION
    Suffix part to a module.
    Based on ModuleBuilder documentation.
    Use this suffix part to do some cleanup for the module.
    Like : start something directly after load.

.EXAMPLE
    NA

.INPUTS
    NA

.OUTPUTS
    NA

.NOTES
    Copyright 2019-<today>, Marcel Rijsbergen.
    
    History:

    220624 MR
    - 0.2.0 Kopie gebruikt voor deze CultuurhuysDeKroon module.

    190604 MR
    - 0.1.0 First release.

#>
if ($IsVerbose) {
    Write-Verbose "$(Get-TimeStamp) $($ScriptName) INFO The 'suffix.ps1' of this module."
}
