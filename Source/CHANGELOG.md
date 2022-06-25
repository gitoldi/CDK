# Changelog voor Module CultuurhuysDeKroon

Het streven is om hierin alle wijzigingen bij te houden, ook voor alle scripts.

---

## ToDo

Waar nodig bestanden aanpassen zodat ze (ook) werken met mijn versie van 'Get-Command -Module <modulenaam>'.

```PowerShell
PS>Get-CommandVersion -Modules CultuurhuysDeKroon

Source (version)      Name                       Version Error
----------------      ----                       ------- -----
CultuurhuysDeKroon (1.2.3) Convert-AsciiTextViceversa 0.9.2
CultuurhuysDeKroon (1.2.3) Get-MACAddressVendor       0.0.0   Has no (proper) parameter "Version".
...
CultuurhuysDeKroon (1.2.3) Test-ArrayVsHashtable      0.0.0   Has no (proper) parameter "Version".
```

---

## Historie van wijzigingen

### 0.3.0 ( 2022-06-25 )

* _Nieuw_
  * Convert-TicketmaticExcel - Converteer een Ticketmatic MS-Excel export en maak een kopie met kleuren.

### 0.2.0 ( 2022-06-25 )

* _Aangepast_
  * Kleine type fouten.
  * Kleine cosmetische aanpassingen in een aantal script.
  * Nog 2-3 'PSModule.ToDo' vervangen door 'CultuurhuysDeKroon'.

### 0.1.0 ( 2022-06-24 )

* _Nieuw_
  * De basis mappen (Source, nl-NL, Tests, ...) en bestanden (CHANGELOG.MD, Build.ps1, ...).

---

## Types van wijzigingen

Type | Omschrijving
----- | -----
_Added_ | Nieuw.
_Changed_ | Wijziging.
_Deprecated_ | Wanneer bestanden (binnenkort) verwijderd worden.
_Removed_ | Verwijdert.
_Fixed_ | Voor fouten (bugs) die zijn aangepast.
_Security_ | Aanpassingen in relatie tot beveiliging.
