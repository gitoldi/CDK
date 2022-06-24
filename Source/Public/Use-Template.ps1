function Find-DuplicateFiles {
    <#

    .SYNOPSIS
    Find duplicate files.

    .DESCRIPTION
    Find duplicate files.

    .PARAMETER Path
    The folder where the script will start to show the tree.
    Default: current location.

    .PARAMETER Version
    Show the current version of the script and stop executing.

    .EXAMPLE
    C:\> .\Find-DuplicateFiles.ps1

    .INPUTS
    The parameters, see 'Get-Help -Detailed'

    .OUTPUTS
    All files that seem to have duplicates.
    A 'PSCustomObject'.

    .LINK
    https://social.technet.microsoft.com/wiki/contents/articles/52270.windows-powershell-how-to-find-duplicate-files.aspx

    .LINK
    https://stackoverflow.com/questions/49666204/powershell-to-display-duplicate-files

    .NOTES
    Name    : Find-DuplicateFiles
    Author  : Marcel Rijsbergen
    History :

    220509 - 0.2.1 MR
    - When started without parameters, tell user it may take some time.
    - Added property 'Duplicates' to return object.
    - Added parameter 'Display' to show output during execution.

    220407 - 0.2.0 MR
    - Link 2 - Found an example using 'Get-FileHash' which i though of to start with.
    - Removed the 'length' solution started with in 0.1.0.    

    220407 - 0.1.0 - MR
    - MR (Marcel Rijsbergen)
    - Started with some pointers. See the 'LINKS' in 'Get-Help' for this script.
    - Used (auto) 'Align' here and there.
    - Started with parameters: Path, Version
    - Link 1 - only on file length, tested, works but not usefull. File length can be the same but contents can differ.
    #>

    #region 'Initialization.'
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string] $Path = $env:USERPROFILE
        ,
        [Parameter(Mandatory = $false)]
        [switch] $Display = $false
        ,
        [Parameter(Mandatory = $false)]
        [switch] $Version = $false
    )
    $ScriptName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Begin."

    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Test if parameter 'Version' is supplied."
    [Version] $ScriptVersion = '0.2.1'
    if ($Version) {
        Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Version: $($ScriptVersion)"
        return $ScriptVersion
    }
    #endregion 'Initialization.'

    #region 'Define variables.'
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Define variables."
    $ConfigFile         = Join-Path -Path $FolderConfig -ChildPath "$($ScriptName).psd1"
    $ReturnData         = @()
    $ReturnError        = @()
    #$Path              = '\\PDC\Shared\Accounting' #define path to folders to find duplicate files
    $Counter            = 0
    $MatchedSourceFiles = @()
    #endregion 'Define variables.'

    #region 'Main.'

    #region 'Test parameter PATH'.
    if (-not $Path) {
        Write-Warning -Message "$(Get-TimeStamp) $($ScriptName) Parameter 'PATH' not supplied, using 'USERPROFILE' will take time!"
    }
    #endregion 'Test parameter PATH'.
    
    Write-Host -Object "$(Get-TimeStamp) $($ScriptName) List files from: $($Path)"
    $FilesAll           = Get-ChildItem -File -Recurse -path $Path
    $FilesTotal         = $FilesAll.Count
    Write-Host -Object "$(Get-TimeStamp) $($ScriptName) Files to test  # $($FilesTotal)"

    # Group all files based on length and only get files where count is greater than 1.
    # After all if length is different the hash will be different anyway.
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Group all files based on length. Save when count > 1."
    $MatchLength = $FilesAll |
        Group-Object -Property Length |
        Where-Object {$_.Count -gt 1} |
        ForEach-Object {$_.Group}
    
    # Get-FileHash for the remaining files.
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Group all files with same length on file hash. Save when count > 1."
    $MatchHash = $MatchLength |
        Get-FileHash |
        Group-Object -Property Hash |
        Where-Object {$_.Count -gt 1} |
        ForEach-Object {$_.Group}
    
    # Now sort on hash and get unique values. For each value show the files.
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Sort on hash. Save only unique ones. Find files with same hash."
    $UniqueHash = $MatchHash | Sort-Object -Property Hash -Unique | Select-Object -Property Hash
    foreach ($TmpRecord in $UniqueHash) {
        $TmpHash = $TmpRecord.Hash
        if ($Display) {Write-Host -Object "Hash: $($TmpHash)"}
        $TmpFiles = $MatchHash | Where-Object {$_.Hash -match $TmpHash}
        $TmpHashFiles = @{
            Hash  = $TmpHash
            Files = $TmpFiles.Path
        }
        $ReturnData += $TmpHashFiles
        if ($Display) {
            foreach ($TmpFile in $TmpFiles) {
                Write-Host -Object "`tFile: $($TmpFile.Path)"
            }
        }
    }

    #$MatchedSourceFiles
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Found matching files # $($ReturnData.Count)"
    #endregion 'Main.'

    #region 'Finished.'
    [PSCustomObject]@{
        FilesAll    = $FilesAll
        MatchLength = $MatchLength
        MatchHash   = $MatchHash
        UniqueHash  = $UniqueHash
        Duplicates  = $ReturnData
        Errors      = $ReturnError
    }
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Finished."
    #endregion 'Finished.'
}