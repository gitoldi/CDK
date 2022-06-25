@{
    # The main script module that is automatically loaded as part of this module
    RootModule             = 'CultuurhuysDeKroon.psm1'

    # The module version should be SemVer.org compatible
    ModuleVersion          = "0.2.0"

    # ID used to uniquely identify this module
    # GUID created 220624 MR.
    GUID                   = '729f147f-f301-4d49-ad25-f82bc8626778'
    Description            = 'Een module voor Cultuurhuys De Kroon.'

    # Common stuff for all our modules:
    CompanyName            = 'Privé'
    Author                 = 'Marcel Rijsbergen'
    Copyright              = "Copyright 2018 - today, Marcel Rijsbergen"

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion      = '5.1'
    #CompatiblePSEditions = @( 'Core','Desktop' )

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules        = @(
        # https://github.com/PoshCode/Configuration
        'Configuration'
    )

    # Always define FunctionsToExport as an empty @() which will be replaced on build
    FunctionsToExport      = '*'
    
    # Variables to export from this module
    VariablesToExport = '*'

    # Aliases to export from this module
    AliasesToExport = '*'

    # PrivateData is where all third-party metadata goes
    PrivateData            = @{
        # PrivateData.PSData is the PowerShell Gallery data
        PSData             = @{
            # Prerelease string should be here, so we can set it
            Prerelease     = 'beta'

            # Release Notes have to be here, so we can update them
            ReleaseNotes   = 'Zie CHANGELOG.md'

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags           = 'Marcel Rijsbergen', 'PowerShell', 'GitHub', 'PowerShell module', 'module', 'CultuurhuysDeKroon'

            # A URL to the license for this module.
            LicenseUri     = 'https://github.com/gitoldi/CDK/blob/master/LICENSE' # 'https://github.com/PoshCode/ModuleBuilder/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri     = 'https://github.com/gitoldi/CDK' # 'https://github.com/PoshCode/ModuleBuilder'

            # A URL to an icon representing this module.
            # 'https://github.com/PoshCode/ModuleBuilder/blob/resources/ModuleBuilder.png?raw=true'
            IconUri        = ''
        }
        # End of PSData

    }
    # End of PrivateData

}
