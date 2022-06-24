@{
    Path = "PSModule.Base.psd1"
    OutputDirectory = "$( $env:OneDrive )\Modules\PSModule.Base"
    VersionedOutputDirectory = $true
    CopyDirectories = @( 'en-US', 'nl-NL', 'tests' )
}
