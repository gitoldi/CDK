# Pester file for module: PSModule-Base
# Used Pester test file as a start.
# Removed some specific Pester stuff.
#
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ScriptRoot = Split-Path -Parent $ScriptRoot
$ScriptName = [ io.path ]::GetFileNameWithoutExtension( $myinvocation.mycommand.name ) 
$CurModuleName = $ScriptName -replace '.tests',''
$WHColor = @{
    ForegroundColor = 'Magenta'
    BackgroundColor = 'Black'
}
Write-Host -Object "`t-> ScriptRoot : $($ScriptRoot)" @WHColor
Write-Host -Object "`t-> ScriptName : $($ScriptName)" @WHColor
$manifestPath  = ( Join-Path $ScriptRoot "$($CurModuleName).psd1" )
$changeLogPath = ( Join-Path $ScriptRoot 'CHANGELOG.md' )

# DO NOT CHANGE THIS TAG NAME; IT AFFECTS THE CI BUILD.

Describe -Tags 'VersionChecks' "$($CurModuleName) manifest and changelog" {
    $script:manifest = $null
    It "Has a valid manifest" {
        {
            $script:manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "Has a valid name in the manifest" {
        $script:manifest.Name | Should Be $CurModuleName
    }

    It "Has a valid guid in the manifest" {
        $script:manifest.Guid | Should Be '71156bb5-6c15-415a-8b21-7bdfe5a01061'
    }

    It "Has a valid version in the manifest" {
        $script:manifest.Version -as [Version] | Should Not BeNullOrEmpty
    }

    $script:changelogVersion = $null
    It "Has a valid version in the changelog" {

        foreach ( $line in (Get-Content $changeLogPath )) {
            if ( $line -match "^\D*(?<Version>(\d+\.){1,3}\d+)" ) {
                $script:changelogVersion = $matches.Version
                break
            }
        }
        $script:changelogVersion                | Should Not BeNullOrEmpty
        $script:changelogVersion -as [Version]  | Should Not BeNullOrEmpty
    }

    It "Changelog and manifest versions are the same" {
        $script:changelogVersion -as [Version] | Should be ( $script:manifest.Version -as [Version] )
    }

    if ( Get-Command git.exe -ErrorAction SilentlyContinue ) {
        #$skipVersionTest = -not [bool](( git remote -v 2>&1 ) -match "github.com/Pester/" )
        $skipVersionTest = -not [bool](( git remote -v 2>&1 ) -match "Github-location-of-this-module" )
        $script:tagVersion = $null

        It "Find Github version of this module" -skip:$skipVersionTest {
            $thisCommit = git.exe log --decorate --oneline HEAD~1..HEAD

            if ( $thisCommit -match 'tag:\s*(\d+(?:\.\d+)*)' ) {
                $script:tagVersion = $matches[1]
            }

            $script:tagVersion                  | Should Not BeNullOrEmpty
            $script:tagVersion -as [Version]    | Should Not BeNullOrEmpty
        }

        It "Github and local version are the same" -skip:$skipVersionTest {
            $script:changelogVersion -as [Version] | Should be ( $script:manifest.Version -as [Version] )
            $script:manifest.Version -as [Version] | Should be ( $script:tagVersion -as [Version] )
        }

    }
}

if ( $PSVersionTable.PSVersion.Major -ge 3 ) {
    $error.Clear()
    Describe 'Clean treatment of the $error variable' {
        Context 'A Context' {
            It 'Performs a successful test' {
                $true | Should Be $true
            }
        }

        It 'Did not add anything to the $error variable' {
            $error.Count | Should Be 0
        }
    }

    InModuleScope PSModule-Base {
        Describe 'SafeCommands table' {
            $path = $ExecutionContext.SessionState.Module.ModuleBase
            #$filesToCheck = Get-ChildItem -Path $path -Recurse -Include *.ps1,*.psm1 -Exclude *.Tests.ps1
            $files = Get-ChildItem -Path $path -Recurse -Include *.ps1,*.psm1 -Exclude *.Tests.ps1
            $callsToSafeCommands = @(
                foreach ( $file in $files )
                {
                    $tokens = $parseErrors = $null
                    $ast = [System.Management.Automation.Language.Parser]::ParseFile( $file.FullName, [ref] $tokens, [ref] $parseErrors )
                    $filter = {
                        $args[0] -is [System.Management.Automation.Language.CommandAst] -and
                        $args[0].InvocationOperator -eq [System.Management.Automation.Language.TokenKind]::Ampersand -and
                        $args[0].CommandElements[0] -is [System.Management.Automation.Language.IndexExpressionAst] -and
                        $args[0].CommandElements[0].Target -is [System.Management.Automation.Language.VariableExpressionAst] -and
                        $args[0].CommandElements[0].Target.VariablePath.UserPath -match '^(?:script:)?SafeCommands$'
                    }

                    $ast.FindAll($filter, $true)
                }
            )

            $uniqueSafeCommands = $callsToSafeCommands | ForEach-Object { $_.CommandElements[0].Index.Value } | Select-Object -Unique
            $missingSafeCommands = $uniqueSafeCommands | Where-Object { -not $script:SafeCommands.ContainsKey($_) }

            It 'The SafeCommands table contains all commands that are called from the module' {
                $missingSafeCommands | Should Be $null
            }
        }
    }
}

Describe 'Style rules' {
    $ModuleRoot = ( Get-Module $ScriptName ).ModuleBase

    $files = @(
        Get-ChildItem $ModuleRoot\* -Include *.ps1,*.psm1
        #Get-ChildItem ( Join-Path $ModuleRoot 'Functions' ) -Include *.ps1,*.psm1 -Recurse
    )

    It "Module source files contain no trailing whitespace" {
        $badLines = @(
            foreach ( $file in $files ) {
                $lines = [System.IO.File]::ReadAllLines( $file.FullName )
                $lineCount = $lines.Count

                for ( $i = 0; $i -lt $lineCount; $i++ ) {
                    if ( $lines[$i] -match '\s+$' ) {
                        'File: {0}, Line: {1}' -f $file.FullName, ( $i + 1 )
                    }
                }
            }
        )

        if ( $badLines.Count -gt 0 ) {
            throw "The following $( $badLines.Count ) lines contain trailing whitespace: `r`n`r`n$( $badLines -join "`r`n" )"
        }
    }

    It 'Module source files lines start with a tab character' {
        $badLines = @(
            foreach ( $file in $files ) {
                $lines = [System.IO.File]::ReadAllLines( $file.FullName )
                $lineCount = $lines.Count

                for ( $i = 0; $i -lt $lineCount; $i++ ) {
                    if ( $lines[$i] -match '^[  ]*\t|^\t|^\t[  ]*' ) {
                        'File: {0}, Line: {1}' -f $file.FullName, ( $i + 1 )
                    }
                }
            }
        )

        if ( $badLines.Count -gt 0 ) {
            throw "The following $($badLines.Count) lines start with a tab character: `r`n`r`n$( $badLines -join "`r`n" )"
        }
    }

    It 'Module Source Files all end with a newline' {
        $badFiles = @(
            foreach ( $file in $files ) {
                $string = [System.IO.File]::ReadAllText( $file.FullName )
                if ( $string.Length -gt 0 -and $string[-1] -ne "`n" ) {
                    $file.FullName
                }
            }
        )

        if ( $badFiles.Count -gt 0 ) {
            throw "The following files do not end with a newline: `r`n`r`n$( $badFiles -join "`r`n" )"
        }
    }
}

Describe 'Testing if all functions have a corresponding pester file.' {
    $CurCommands = Get-Command -Module $CurModuleName
    foreach ( $CurCommand in $CurCommands ) {
        $CmdTest = $CurCommand.Name + '.Tests.ps1'
        It "Find 'Pester' test file: $($CmdTest)" {
            $CmdFound = Get-ChildItem -Recurse -Filter "$($CmdTest)"
            $CmdFound | Should Be $true
        }
    }

    Context 'Function : Show-ModulePath' {
        Write-Host -Object "`t-> Current Powershell is : $($PSEdition)" @WHColor
        #$FuncTxt       = @()
        $FuncTxt        = ''
        $skipPS1Desktop = -not [bool]($PSEdition -match 'Desktop')
        $skipPS1Core    = -not [bool]($PSEdition -match 'Core')

        #region Desktop
        It 'Test function "Show-ModulePath" for Powershell Desktop' -skip:$skipPS1Desktop {
            $FuncTxt += "C:\Users\mrijsber\OneDrive - Centric\modules;"
            $FuncTxt += "C:\Users\mrijsber\Documents\WindowsPowerShell\Modules;"
            $FuncTxt += "C:\Program Files\WindowsPowerShell\Modules;"
            $FuncTxt += "C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules;"
            $FuncTxt += "C:\Program Files (x86)\Microsoft Azure Information Protection\Powershell"
            $env:PSModulePath.ToLower() | Should BeExactly $FuncTxt.ToLower()
        }
        #endregion Desktop

        #region Core
        It 'Test function "Show-ModulePath" for Powershell Core' -skip:$skipPS1Core {
            $FuncTxt += "C:\Users\mrijsber\OneDrive - Centric\modules;"
            $FuncTxt += "C:\Users\mrijsber\Documents\PowerShell\Modules;"
            $FuncTxt += "C:\Program Files\PowerShell\Modules;"
            $FuncTxt += "c:\Program Files\PowerShell\7\Modules;"
            $FuncTxt += "C:\Program Files\WindowsPowerShell\Modules;"
            $FuncTxt += "C:\WINDOWS\system32\WindowsPowerShell\v1.0\Modules;"
            $FuncTxt += "C:\Program Files (x86)\Microsoft Azure Information Protection\Powershell"
            $env:PSModulePath.ToLower() | Should BeExactly $FuncTxt.ToLower()
        }
        #endregion Core
    }

    Context 'Function : Get-TestMe (in=fixed 6 lines, out=random lines - Forced to go wrong mostly)' {
        function Get-TestMe {
            $MaxLoop = Get-Random -Maximum 7
            Write-Host -Object "`t-> Create random text with $($MaxLoop - 1) lines." @WHColor
            $TextString = @()
            for ( $i = 1; $i -lt $MaxLoop; $i++ ) {
                $TextString += "Get-TestMe: $($i) - This is a test"
            }
            #Write-Host -Object "...$($TextString.count)"
            Return $TextString
        }
        It 'Test function : Get-TestMe' {
            $FuncTxt = @()
            $FuncTxt += "Get-TestMe: 1 - This is a test"
            $FuncTxt += "Get-TestMe: 2 - This is a test"
            $FuncTxt += "Get-TestMe: 3 - This is a test"
            $FuncTxt += "Get-TestMe: 4 - This is a test"
            $FuncTxt += "Get-TestMe: 5 - This is a test"
            $FuncTxt += "Get-TestMe: 6 - This is a test"
            $getFunc = Get-TestMe
            $getFunc | Should beExactly $FuncTxt
        }
    }

    Context 'Function : Convert-Bytes' {
        It 'Test function : Convert-Bytes Byte and KiloByte' {
            (Convert-Bytes  999).Value | Should BeExactly '999,00'
            (Convert-Bytes  999).Metric | Should BeExactly 'B = Byte'
            (Convert-Bytes 1000).Value | Should BeExactly '1,00'
            (Convert-Bytes 1000).Metric | Should BeExactly 'KB = KiloByte'
            (Convert-Bytes 1004).Value | Should BeExactly '1,00'
            (Convert-Bytes 1004).Metric | Should BeExactly 'KB = KiloByte'
            (Convert-Bytes 1006).Value | Should BeExactly '1,01'
            (Convert-Bytes 1006).Metric | Should BeExactly 'KB = KiloByte'
            (Convert-Bytes  999994).Value | Should BeExactly '999,99'
            (Convert-Bytes  999994).Metric | Should BeExactly 'KB = KiloByte'
            (Convert-Bytes  999995).Value | Should BeExactly '1.000,00'
            (Convert-Bytes  999995).Metric | Should BeExactly 'KB = KiloByte'
        }
        It 'Test function : Convert-Bytes MegaByte' {
            (Convert-Bytes 1000000).Value | Should BeExactly '1,00'
            (Convert-Bytes 1000000).Metric | Should BeExactly 'MB = MegaByte'
            (Convert-Bytes  999994999).Value | Should BeExactly '999,99'
            (Convert-Bytes  999994999).Metric | Should BeExactly 'MB = MegaByte'
            (Convert-Bytes  999995000).Value | Should BeExactly '1.000,00'
            (Convert-Bytes  999995000).Metric | Should BeExactly 'MB = MegaByte'
            (Convert-Bytes 1000000000).Value | Should BeExactly '1,00'
        }
        It 'Test function : Convert-Bytes GigaByte'{
            (Convert-Bytes 1000000000).Metric | Should BeExactly 'GB = GigaByte'

            #Convert-Bytes  999994999999 | Should BeExactly '999,99 TB'
            #Convert-Bytes  999995000000 | Should BeExactly '1.000,00 TB'
            #Convert-Bytes 1000000000000 | Should BeExactly '1,00 PB'

            # tested on PS command: "{0:N2}" -f ( 999994999999999 / $CurpB )
            #Convert-Bytes  999994999999999 | Should BeExactly '999,99 TB'
            # tested on PS command: "{0:N2}" -f ( 999995000000000 / $CurpB )
            #Convert-Bytes  999995000000000 | Should BeExactly '1.000,00 PB'
            # tested on PS command: "{0:N2}" -f ( 1000000000000000 / $CurEB )
            #Convert-Bytes 1000000000000000 | Should BeExactly '1,00 EB'
        }
    }

}
