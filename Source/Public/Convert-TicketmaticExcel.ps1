function Convert-TicketmaticExcel {
    <#
    .SYNOPSIS
    Use a Ticketmatic exported 'Evenementen' MS-Excel file, convert data and color it.

    .DESCRIPTION
    Use a Ticketmatic exported 'Evenementen' MS-Excel file, convert data and color it.

    In Ticketmatic with the proper role you can export a list of 'Evenementen' to a MS-Excel file.
    Not sure if this is the default output, but in our case we get the following headers:
        Naam            Name of event.
        Ondertitel      Subtitle.
                        This is normally not used, only if the event is for 'customers' BDGV or VONK,
                        the values 'Bibliotheek De Groene Venen' or 'Stichting Vonk' should be used.
                        This will trigger the proper setup and colors in the mails send to the customers.
        Weekdag         Day of week.
        Datum           Date of event.
        Beschikbaarheid x/y     x = still available tickets, y = maximum tickets that can be sold.
        Status          If the event is in 'Draft' or 'Published' (active and visible).
        Genre(s)        There should be at least 1 (one) genre.


    .NOTES
    Name    : Convert-Ticketmatic
    Author  : Marcel Rijsbergen
    Historie:

    220625 - 1.1.0 MR
    - Added comment based help.
    - Made it a function.
    - Added some default PowerShell default setup like params, version.
    - Generate colors based on genre.
    - Colors are more close to the defined ones by the graphic designer(s): Ine, Inge
    - #TODO Split the genre and check if 'Bibliotheek' or 'VONK' is supplied. If 'Lezing' make it 'Bibliotheek'.

    220625 - 1.0.0 MR
    - Delivered a 1st working version.
    - Use the original MS-Excel sheet, put it into a named sheet and create a new sheet with a copy.
    - Tested with 2 hardcoded colors.

    220624 - 0.1.0 MR
    - Started based on the link below and several other (microsoft) pages about color, module ImportExcel, ...

    
    .LINK
    https://bronowski.it/blog/2020/12/how-to-format-an-entire-excel-row-based-on-the-cell-values-with-powershell/
    
    .EXAMPLE
    Test-MyTestFunction -Verbose
    
    #>
    
    #region 'Initialization.'
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch] $Version = $false
    )

    $ScriptName = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Begin."

    Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Test if parameter 'Version' is supplied."
    [Version] $ScriptVersion = '1.1.0'
    if ($Version) {
        Write-Verbose -Message "$(Get-TimeStamp) $($ScriptName) Version: $($ScriptVersion)"
        return $ScriptVersion
    }
    #endregion 'Initialization.'

    # Colors used by graphic designer CDK.
    # Used calculator: https://www.w3schools.com/colors/colors_cmyk.asp
    #
    # #ff21ab   cmyk(0%, 87%, 33%, 0%)
    # #ffa81a   cmyk(0%, 34%, 90%, 0%)
    # #000000   cmyk(0%, 40%, 0%, 100%) -> cmyk(0%, 0%, 0%, 100%)
    # #33cccc   cmyk(80%, 20%, 20%, 100%) -> cmyk(0%, 0%, 0%, 100%)
    # #582314   cmyk(57%, 83%, 90%, 20%) -> cmyk(0%, 60%, 77%, 66%)
    # #ff5421   cmyk(0%, 67%, 87%, 0%)                                
    # #5ad081   cmyk(59%, 5%, 41%, 14%) -> cmyk(57%, 0%, 38%, 18%)
    # #9b00b6   cmyk(31%, 100%, 19%, 12%) -> cmyk(15%, 100%, 0%, 29%)
    # #2b6bff   cmyk(83%, 58%, 0%, 0%)                                
    #
    # CurColors:
    #   - The first colors are the same order as the CurTags. Colors from year calendar.
    #   - The remaining colors can be used for other purposes.
    $CurColorsRGB = @(
        # Colors for CurTags
        '#33cccc',  # rgb  51, 204, 204     cmyk(80%, 20%, 20%, 100%) -> cmyk(0%, 0%, 0%, 100%)
        '#ffa81a',  # rgb 255, 168,  26     cmyk(0%, 34%, 90%, 0%)
        '#ff5421',  # rgb 255,  84,  33     cmyk(0%, 67%, 87%, 0%)
        '#ff21ab',  # rgb 255,  33, 171     cmyk(0%, 87%, 33%, 0%)
        '#ffff00',  # rgb 255, 255,   0     cmyk(0%, 0%, 100%, 0%) - defined myself, seems yellow(ish).
        '#5ad081',  # rgb  90, 208, 129     cmyk(59%, 5%, 41%, 14%) -> cmyk(57%, 0%, 38%, 18%)

        # Default color for unknown CurTags.
        '#2b6bff',  # rgb  43, 107, 255     cmyk(83%, 58%, 0%, 0%)

        # Remaining colors.
        '#582314',  # rgb  88,  35,  20     cmyk(57%, 83%, 90%, 20%) -> cmyk(0%, 60%, 77%, 66%)
        '#9b00b6',  # rgb 155,   0, 182     cmyk(31%, 100%, 19%, 12%) -> cmyk(15%, 100%, 0%, 29%)
        '#000000'   # rgb   0,   0,   0     cmyk(0%, 40%, 0%, 100%) -> cmyk(0%, 0%, 0%, 100%)
    )
    $CurColors = @(
        'DarkCyan',
        'Gray'
        'Red',
        'DarkYellow',
        'DarkRed',
        'DarkGray',
        'Blue'
    )
    $CurTags = (
        'Cabaret',
        'Educatie',
        'Kinderen',
        'Lezing',
        'Muziek',
        'Pubquiz',
        'Toneel'
    )

    # Set variables.
    $MyLocation = 'D:\Users\rijsb\Downloads\CDK'
    $TMOriginal = Join-Path -Path $MyLocation -ChildPath 'Ticketmatic-export_20220620.xlsx'
    $TMImport   = Import-Excel -Path $TMOriginal
    $TMNew      = Join-Path -Path $MyLocation -ChildPath 'Ticketmatic-CultuurhuysDeKroon.xlsx'

    # Define sheet names.
    $SheetOriginal = 'Origineel'
    $SheetNew      = 'Nieuw'

    # Remove Excel working file.
    #Set-Location -Path $MyLocation
    write-verbose "Remove excel file if exists."
    if (Test-Path $TMNew) {
        Try {
            Remove-Item $TMNew -ErrorAction SilentlyContinue
        } Catch {
            write-Warning -Message "Error removing Excel work file, make sure the sheet is closed."
            Return
        }
    }

    # Connect to Excel file.
    Write-Output -InputObject "Create Excel file: $($TMNew)"
    $excelPackage = Open-ExcelPackage -Path $TMNew -KillExcel

    # Save original data to sheet 'Original' and close Excel file.
    Write-Output -InputObject "Save original data to sheet: $($SheetOriginal)"
    $TMImport | Export-Excel -Path $TMNew -WorksheetName $SheetOriginal -AutoFilter -AutoSize -KillExcel

    # Connect to Excel file.
    write-verbose "Connect to Excel file: $($TMNew)"
    $excelPackage = Open-ExcelPackage -Path $TMNew -KillExcel
    #write-verbose "Connect to sheet: $($SheetOriginal)"
    #$excelOriginal = $excelPackage.Workbook.Worksheets["$($SheetOriginal)"]

    # Close and show.
    #Close-ExcelPackage -ExcelPackage $excelPackage -Show

    # Save modified data to sheet 'New'.
    Write-Output -InputObject "Save original data to sheet: $($SheetNew)"
    $TMImport | Export-Excel -Path $TMNew -WorksheetName $SheetNew -AutoFilter -AutoSize -KillExcel

    # Connect to Excel file.
    write-verbose "Connect to Excel file: $($TMNew)"
    $excelPackage = Open-ExcelPackage -Path $TMNew -KillExcel
    write-verbose "Connect to sheet: $($SheetNew)"
    $excelNew = $excelPackage.Workbook.Worksheets["$($SheetNew)"]

    #$xx = $TMImport | Export-Excel -Path $TMNew -PassThru -ClearSheet
    #$ws        = $xx.Workbook.WorkSheets['Ticketmatic']
    #$totalRows = $ws.Dimension.Rows
    #$totalCols = $ws.Dimension.Cols
    #write-host -Object "Rows $($totalRows) Cols $($totalCols)"

    #$ws        = $excelNew.Workbook.WorkSheets["$($SheetNew)"]
    #$totalRows = $ws.Dimension.Rows
    #$totalCols = $ws.Dimension.Columns
    
    $totalRows = $excelNew.Dimension.Rows
    $totalCols = $excelNew.Dimension.Columns
    Write-Output -InputObject "Cols $($totalCols) Rows $($totalRows)"

    #works:     
    #$MyTag = "Muziek"
    #Add-ConditionalFormatting -Worksheet $excelNew -Address A2:g43 -RuleType Expression -ConditionValue '=$G2="Cabaret"' -BackgroundColor Blue
    #Add-ConditionalFormatting -Worksheet $excelNew -Address A2:g43 -RuleType Expression -ConditionValue ('=$G2="' + $MyTag + '"') -BackgroundColor DarkCyan
    
    foreach ($CurTag in $CurTags) {
        $TagIndex    = $CurTags.IndexOf("$($CurTag)")
        $TagColor    = $CurColors[$TagIndex]
        $TagColorRGB = $CurColorsRGB[$TagIndex] -replace '#', ''
        [int] $ColA = 8 # Transparency 255 is none.
        [int] $ColB = [Convert]::ToInt64($TagColorRGB.Substring(4, 2), 16)
        [int] $ColG = [Convert]::ToInt64($TagColorRGB.Substring(2, 2), 16)
        [int] $ColR = [Convert]::ToInt64($TagColorRGB.Substring(0, 2), 16)
        $NewBGColor = [System.Drawing.Color]::FromArgb($ColA, $ColB, $ColG, $ColR)
        Write-Output -InputObject "Genre: $($CurTag.PadRight(8)) - Color $($TagColor.PadRight(20)) - $($TagColorRGB) - $($ColA):$($ColR):$($ColG):$($ColB)"
        #Add-ConditionalFormatting -Worksheet $excelNew -Address A2:g43 -RuleType Expression -ConditionValue ('=$G2="' + $CurTag + '"') -BackgroundColor $TagColor
        Add-ConditionalFormatting -Worksheet $excelNew -Address A2:g43 -RuleType Expression -ConditionValue ('=$G2="' + $CurTag + '"') -BackgroundColor $NewBGColor
    }

    #Write-Output -InputObject "Set color to: $($MyTag)"
    #Add-ConditionalFormatting -Worksheet $excelNew -Address A2:g43 -RuleType Expression -ConditionValue "=$G2=""$($MyTag)""" -BackgroundColor "#ff21ab"

    #Set-ExcelRange -Range $ws.Cells["B2:B$($totalRows)"] -BackgroundColor LightBlue
    #Set-ExcelRange -Range $ws.Cells["a4:a$($totalCols)"] -BackgroundColor green

    # save the changes and open the spreadsheet
    Write-Output -InputObject "Close Excel file and show end result."
    Close-ExcelPackage -ExcelPackage $excelPackage -Show
    #Export-Excel -ExcelPackage $xx -KillExcel -Show
}
