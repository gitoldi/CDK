# CDK

Maak een branch voor CDK (Cultuurhuys De Kroon) gerelateerde projecten.

## Introductie

Op dit moment - juni 2022 - zijn er nog geen scripts.

De wijzigingen worden bijgehouden in het document: [Changelog](CHANGELOG.md).

* De structuur wordt opgezet om gebruikt te kunnen worden met [ModuleBuilder](https://github.com/PoshCode/ModuleBuilder) om een module te kunnen maken.
* Het wordt geadviseerd om ModuleBuilder in een van je paden in $env:PSModulePath te zetten. Het liefst in een pad dat je zowel vanuit  PowerShell 'Desktop' en 'Core' kunt benaderen.
* Dus deze repo bevat alleen de bestanden om een module te kunnen *bouwern*. Je dient dus bekend te zijn met _ModuleBuilder_ en de gemaakte module in je eigen omgeving te kunnen gebruiken.

---

## Voorbeeld om een module te bouwen

Pas eerst de volgende 2 parameters in "_FullPathTo_\CultuurhuysDeKroon\Source\Build.psd1" aan.

```PowerShell
OutputDirectory          = "$( $env:OneDrive )\Modules\CultuurhuysDeKroon"
VersionedOutputDirectory = $true
```

* OutputDirectory
  * Die verwijst naar de map waar de gemaakte module geplaatst wordt.
  * Bij voorkeur is deze map onderdeel van je $env:PSModulePath.
* VersionedOutputDirectory
  * Bij voorkeur staat deze op _$true_ zodat bij het aanpassen van het versie nummer in de betreffende bestanden er voor zorgt dat er een aparte map met versienummer gemaakt wordt waarin de module wordt opgeslagen. Op die manier heb je diverse versies beschikbaar en kun je altijd terug naar een vorige (werkende) versie van je module.

### Voorbeeld als module ModuleBuilder in je $env:PSModulePath staat

```PowerShell
Import-Module ModuleBuilder
```

### Voorbeeld als module ModuleBuilder NIET in je $env:PSModulePath staat

```PowerShell
Import-Module <FullPathTo>ModuleBuilder<.psm1>
```

### Bouw de module

De _-Prefix_ en/of _-Suffix_ zijn optioneel en alleen nodig als je ze ook echt gemaakt hebt met een bepaald doel om 'voor' en 'na' je functies opgenomen te worden in het module script.

```PowerShell
Build-Module '<FullPathTo>\PSModule.ToDo\Source\' [-Prefix 'prefix.ps1'] [-Suffix 'suffix.ps1']
```

---

## Uiteindelijke module

De module wordt gemaakt en geplaatst in de map die beschreven is in de 'build.psd1'.

### Voorbeeld van de module structuur

Gebaseerd op de bovenstaande parameters _OutputDirectory_ en _VersionedOutputDirectory_ is op __$true__ gezet en je hebt 2 versies '1.0.0' and '1.1.0' gemaakt de uiteindelijke structuur zal op het volgende voorbeeld lijken.

Als de module in je pad _$env:PSModulePath_ staat zal het commando _'PS> Import-Module PSModule.ToDo'_ altijd de laatste versie, in dit geval _'1.1.0'_ laden.

```PowerShell
PS> Get-ChildItem -Recurse "$( $env:OneDrive )\Modules\CultuurhuysDeKroon"

    Directory: <FullPathTo>\Modules\CultuurhuysDeKroon

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
la---            1-1-2020    17:31                1.0.0
la---           10-2-2020    21:04                1.0.1

    Directory: <FullPathTo>\Modules\CultuurhuysDeKroon\1.0.0

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
la---            1-1-2020    17:31                en-US
la---            1-1-2020    17:31                nl-NL
la---           29-1-2020    19:03           7574 CultuurhuysDeKroon.psd1
la---           30-1-2020    22:41           6694 CultuurhuysDeKroon.psm1

    Directory: <FullPathTo>\Modules\CultuurhuysDeKroon\1.0.1

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
la---           10-2-2020    21:04                en-US
la---           10-2-2020    21:04                nl-NL
la---           10-2-2020    21:04                Tests
la---           10-2-2020    21:04           4683 CultuurhuysDeKroon.psd1
la---            3-3-2020    20:55          96021 CultuurhuysDeKroon.psm1
```

* Map: en-US
  * Bevat de US taal specifieke help.
* Map: xx-XX
  * Bevat de XX taal specifieke help.
* Map: Private
  * Alle scripts die nodig zijn voor de module zelf maar deze worden niet aan de gebruiker getoond.
* Map: Public
  * Alle scripts die worden getoond aan de gerbruikers.
* Map: Tests
  * Deze Map bevat PowerShell [Pester](https://github.com/pester/Pester) tests voor het controleren/testen van je module en/of scripts.
* Bestand: PSModule.ToDo.psd1
  * Het module manifest bestand.
* Bestand: PSModule.ToDo.psm1
  * Het uiteindelijke module bestand dat wordt gemaakt door _Build-Module_ en is een samenvoeging van:
  * Prefix.ps1
    * Zoals opgegeven tijdens het bouwen in het _Build-Module_ commando '-prefix prefix.ps1'.
    * e.g. Dit zet een aantal zaken voordat functions worden gedefinieerd.
  * Alle functies
    * Alle functies gedefinieerd in de _private_ en _public_ mappen.
  * Suffix.ps1
    * Zoals opgegeven tijdens het bouwen in het _Build-Module_ commando '-suffix suffix.ps1'.
    * e.g. Alles wat je alvast automatisch wilt laten uitvoeren als alle functies gedefinieerd zijn.

---

## Mappen en bestanden in de source repository

In the root van de repo:

* Bestand - CHANGELOG.md
  * Om alle wijzigingen in bij te houden. Zelf houd ik hier alle wijzigingen in bij van alle ps1, psd1, psm1 bestanden.
* Bestand- README.md (dit bestand)
  * Algemene uitleg van de module.

---

## Map - Sources

Deze map bevat de bestanden die nodig zijn voor het bouwen van de module.

* Bestand - Build.psd1
  * Configuratie bestand voor ['ModuleBuilder'](https://github.com/PoshCode/ModuleBuilder)
* Bestand - Prefix.ps1
  * Gebruikt door ModuleBuilder.
  * De inhoud van dit bestand zal in het begin van _CultuurhuysDeKroon.psm1_ komen.
  * Hier kun je een aantal zaken definieren die je verderop nodig hebt in het module bestand. Bijvoorbeeld het laden van een configuratie bestand.
* Bestand - Suffix.ps1
  * Gebruikt door ModuleBuilder.
  * De inhoud van dit bestand zal in het eind van _CultuurhuysDeKroon.psm1_ komen na alle functies.
  * Hier kun je bijvoorbeeld alvast zaken uit laten voeren of wat opschoonwerk doen.
* Bestand - PSModule-Base.psd1
  * Het manifest bestand voor de module.

---

## Markdown guides

Hier een aantal verwijzingen naar documentatie om dit soort 'MD' (Markdown) bestanden te maken.

* [Markdown guide](https://www.markdownguide.org/basic-syntax/)
* [John Gruder - markdown creator](https://daringfireball.net/projects/markdown/)
* [GitHub mastering markdown](https://guides.github.com/features/mastering-markdown/)
* [Pandoc - PowerShell module to convert 'Markdown' to ...](http://pandoc.org/)

---

## Getest op

Operation System | PowerShell | PowerShell Core
-------------------------------------------------- | ---------- | ----------
Microsoft Windows 10 Home | 5.1 | 7.0, 7.1
