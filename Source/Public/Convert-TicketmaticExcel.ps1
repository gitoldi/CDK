function Convert-TicketmaticExcel {
    # Verder testen met:
    #   - https://bronowski.it/blog/2020/12/how-to-format-an-entire-excel-row-based-on-the-cell-values-with-powershell/
    [cmdletbinding()]
    param(
    )

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
    $CurColorsCMYK = @(
        # Colors for CurTags
        '#33cccc',  # cmyk(80%, 20%, 20%, 100%) -> cmyk(0%, 0%, 0%, 100%)
        '#ffa81a',  # cmyk(0%, 34%, 90%, 0%)
        '#ff5421',  # cmyk(0%, 67%, 87%, 0%)
        '#ff21ab',  # cmyk(0%, 87%, 33%, 0%)
        '#ffff00',  # cmyk(0%, 0%, 100%, 0%) - defined myself, seems yellow(ish).
        '#5ad081',  # cmyk(59%, 5%, 41%, 14%) -> cmyk(57%, 0%, 38%, 18%)

        # Default color for unknown CurTags.
        '#2b6bff',  # cmyk(83%, 58%, 0%, 0%)

        # Remaining colors.
        '#582314',  # cmyk(57%, 83%, 90%, 20%) -> cmyk(0%, 60%, 77%, 66%)
        '#9b00b6',  # cmyk(31%, 100%, 19%, 12%) -> cmyk(15%, 100%, 0%, 29%)
        '#000000'   # cmyk(0%, 40%, 0%, 100%) -> cmyk(0%, 0%, 0%, 100%)
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
    write-verbose "Connect to sheet: $($SheetOriginal)"
    $excelOriginal = $excelPackage.Workbook.Worksheets["$($SheetOriginal)"]

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
    
    #$totalRows = $excelNew.Dimension.Rows
    #$totalCols = $excelNew.Dimension.Columns
    #Write-Output -InputObject "Rows $($totalRows) Cols $($totalCols)"

    #works:     
    #$MyTag = "Muziek"
    #Add-ConditionalFormatting -Worksheet $excelNew -Address A2:g43 -RuleType Expression -ConditionValue '=$G2="Cabaret"' -BackgroundColor Blue
    #Add-ConditionalFormatting -Worksheet $excelNew -Address A2:g43 -RuleType Expression -ConditionValue ('=$G2="' + $MyTag + '"') -BackgroundColor DarkCyan
    
    foreach ($CurTag in $CurTags) {
        $TagIndex = $CurTags.IndexOf("$($CurTag)")
        $TagColor = $CurColors[$TagIndex]
        Write-Output -InputObject "Genre: $($CurTag.PadRight(8)) - Color $($TagColor)"
        Add-ConditionalFormatting -Worksheet $excelNew -Address A2:g43 -RuleType Expression -ConditionValue ('=$G2="' + $CurTag + '"') -BackgroundColor $TagColor
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
