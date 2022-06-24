@{
    <#
    File        : CultuurhuysDeKroon.psd1
    Purpose     : Configuratie voor deze module.
    Version     : 1.0
    Source      : 
        - https://docs.microsoft.com/en-us/powershell/dsc/configurations/configdata
        - DSC descriptions, but they mostly use different type (XML).
    Usage       :

    PS> $xx = Import-PowerShellDataFile -Path <full-path-to-configfile.psd1>
    PS> $xx
    Name                           Value
    ----                           -----
    Personal                       {System.Collections.Hashtable, System.Collections.Hashtable, System.Collections.Hashtable}
    Folders                        {Config, Logs, Html, Output...}

    PS> $xx.Personal.Where{ $_.Leverancier -eq 'microsoft' }.mail
    <user>@outlook.com

    Created     : 220624
    History     :
    - 220624 MR. Dit sjabloon bestand aangemaakt.

    #>

    Mappen = @(
        # In mijn omgeving controleer ik of deze mappen bestaan in $env:userprofile'\documents'.
        # Als de volgende mappen nietbestaan worden ze aangemaakt.
        'Config',   # Gebruiken voor bestanden waarin configuratie informatie staat.
        'Logs',     # Waar de logfiles komen.
        'Html',     # Waar (automatisch) aangemaakte HTML bestanden komen. Bijvoorbeeld die gemaakt worden via module: https://github.com/azurefieldnotes/ReportHTML
        'Output',   # Waar allerhande output bestanden komen, bijvoorbeeld: csv, xml, pdf, json
        'Temp'      # Waar je tijdelijke bestanden plaatst.
    )

    Persoonlijk = @(
        @{
            Leverancier = 'GitHub'
            Gebruikersnaam = '<username>'
            Mail = '<user>@<maildomain>'
        },
        @{
            Leverancier = 'Google'
            Gebruikersnaam = '<username>'
            Mail = '<user>@gmail.com'
        },
        @{
            Leverancier = 'Microsoft'
            Gebruikersnaam = '<username>'
            Mail = '<user>@outlook.com'
        }
    )
}
