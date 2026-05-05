param(
    [string]$TemplateDocxPath = "C:\Users\Vũ Hải Quân\OneDrive\Desktop\KLTN-main\tmp_report.docx",
    [string]$TemplateExtractedPath = "C:\Users\Vũ Hải Quân\OneDrive\Desktop\KLTN-main\tmp_report_unzipped",
    [string]$ContentPath = "C:\Users\Vũ Hải Quân\OneDrive\Desktop\KLTN-main\report_tools\thesis_report_content.txt",
    [string]$OutputDocxPath = "C:\Users\Vũ Hải Quân\OneDrive\Desktop\KLTN-main\KLTN_WebThuongMaiDienTu_AIAgent_Updated.docx"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Escape-XmlText {
    param([string]$Text)

    if ($null -eq $Text) {
        return ''
    }

    $escaped = [System.Security.SecurityElement]::Escape($Text)
    return $escaped.Replace("`r", '').Replace("`n", '&#xA;')
}

function New-RunXml {
    param(
        [string]$Text,
        [int]$FontSize = 26,
        [switch]$Bold
    )

    $boldXml = if ($Bold) { '<w:b/>' } else { '' }
    $escapedText = Escape-XmlText $Text

    return "<w:r><w:rPr><w:rFonts w:ascii=""Times New Roman"" w:hAnsi=""Times New Roman"" w:cs=""Times New Roman""/><w:lang w:val=""vi-VN""/>$boldXml<w:sz w:val=""$FontSize""/><w:szCs w:val=""$FontSize""/></w:rPr><w:t xml:space=""preserve"">$escapedText</w:t></w:r>"
}

function New-ParagraphXml {
    param(
        [string]$Kind,
        [string]$Text
    )

    switch ($Kind) {
        'BLANK' {
            return '<w:p><w:pPr><w:spacing w:before="0" w:after="0" w:line="240" w:lineRule="auto"/></w:pPr></w:p>'
        }
        'PAGEBREAK' {
            return '<w:p><w:r><w:br w:type="page"/></w:r></w:p>'
        }
        'CENTER_BOLD' {
            return "<w:p><w:pPr><w:jc w:val=""center""/><w:spacing w:before=""0"" w:after=""0"" w:line=""280"" w:lineRule=""auto""/></w:pPr>$(New-RunXml -Text $Text -FontSize 28 -Bold)</w:p>"
        }
        'CENTER' {
            return "<w:p><w:pPr><w:jc w:val=""center""/><w:spacing w:before=""0"" w:after=""0"" w:line=""280"" w:lineRule=""auto""/></w:pPr>$(New-RunXml -Text $Text -FontSize 26)</w:p>"
        }
        'TITLE' {
            return "<w:p><w:pPr><w:jc w:val=""center""/><w:spacing w:before=""120"" w:after=""120"" w:line=""300"" w:lineRule=""auto""/></w:pPr>$(New-RunXml -Text $Text -FontSize 32 -Bold)</w:p>"
        }
        'CHAPTER' {
            return "<w:p><w:pPr><w:pStyle w:val=""Heading1""/><w:jc w:val=""center""/><w:spacing w:before=""120"" w:after=""120"" w:line=""300"" w:lineRule=""auto""/></w:pPr>$(New-RunXml -Text $Text -FontSize 30 -Bold)</w:p>"
        }
        'SECTION' {
            return "<w:p><w:pPr><w:pStyle w:val=""Heading2""/><w:spacing w:before=""120"" w:after=""60"" w:line=""300"" w:lineRule=""auto""/></w:pPr>$(New-RunXml -Text $Text -FontSize 28 -Bold)</w:p>"
        }
        'SUBSECTION' {
            return "<w:p><w:pPr><w:pStyle w:val=""Heading3""/><w:spacing w:before=""80"" w:after=""40"" w:line=""280"" w:lineRule=""auto""/></w:pPr>$(New-RunXml -Text $Text -FontSize 26 -Bold)</w:p>"
        }
        'BODY' {
            return "<w:p><w:pPr><w:pStyle w:val=""Body""/><w:jc w:val=""both""/><w:spacing w:before=""100"" w:after=""0"" w:line=""360"" w:lineRule=""auto""/><w:ind w:firstLine=""709""/></w:pPr>$(New-RunXml -Text $Text -FontSize 26)</w:p>"
        }
        'NOTE' {
            return "<w:p><w:pPr><w:jc w:val=""left""/><w:spacing w:before=""60"" w:after=""0"" w:line=""320"" w:lineRule=""auto""/></w:pPr>$(New-RunXml -Text $Text -FontSize 24)</w:p>"
        }
        'BULLET' {
            return "<w:p><w:pPr><w:pStyle w:val=""Body""/><w:jc w:val=""both""/><w:spacing w:before=""60"" w:after=""0"" w:line=""320"" w:lineRule=""auto""/><w:ind w:left=""709""/></w:pPr>$(New-RunXml -Text ("• " + $Text) -FontSize 26)</w:p>"
        }
        'TOC' {
            return "<w:p><w:pPr><w:spacing w:before=""20"" w:after=""20"" w:line=""280"" w:lineRule=""auto""/></w:pPr>$(New-RunXml -Text $Text -FontSize 24)</w:p>"
        }
        'SIGN' {
            return "<w:p><w:pPr><w:jc w:val=""center""/><w:spacing w:before=""80"" w:after=""80"" w:line=""280"" w:lineRule=""auto""/></w:pPr>$(New-RunXml -Text $Text -FontSize 24)</w:p>"
        }
        default {
            return "<w:p><w:pPr><w:pStyle w:val=""Body""/><w:jc w:val=""both""/><w:spacing w:before=""100"" w:after=""0"" w:line=""360"" w:lineRule=""auto""/><w:ind w:firstLine=""709""/></w:pPr>$(New-RunXml -Text $Text -FontSize 26)</w:p>"
        }
    }
}

function New-TableParagraphXml {
    param(
        [string]$Text,
        [int]$FontSize = 26,
        [switch]$Bold,
        [string]$Align = 'left'
    )

    return "<w:p><w:pPr><w:jc w:val=""$Align""/><w:spacing w:before=""40"" w:after=""40"" w:line=""320"" w:lineRule=""auto""/></w:pPr>$(New-RunXml -Text $Text -FontSize $FontSize -Bold:$Bold)</w:p>"
}

function New-TableCellXml {
    param(
        [string]$Text,
        [int]$Width,
        [switch]$Bold,
        [string]$Align = 'left'
    )

    return "<w:tc><w:tcPr><w:tcW w:w=""$Width"" w:type=""dxa""/><w:vAlign w:val=""top""/></w:tcPr>$(New-TableParagraphXml -Text $Text -FontSize 26 -Bold:$Bold -Align $Align)</w:tc>"
}

function New-TableRowXml {
    param(
        [string[]]$Cells,
        [int[]]$Widths,
        [string]$RowKind
    )

    $cellXml = New-Object System.Collections.Generic.List[string]

    for ($i = 0; $i -lt $Widths.Length; $i++) {
        $cellText = if ($i -lt $Cells.Length) { $Cells[$i] } else { '' }

        switch ($RowKind) {
            'TABLE_HEADER' {
                $cellXml.Add((New-TableCellXml -Text $cellText -Width $Widths[$i] -Bold -Align 'center'))
            }
            'TABLE_ROW_LABEL' {
                $isBold = ($i -eq 0)
                $cellXml.Add((New-TableCellXml -Text $cellText -Width $Widths[$i] -Bold:$isBold -Align 'left'))
            }
            'TABLE_ROW_STRONG' {
                $cellXml.Add((New-TableCellXml -Text $cellText -Width $Widths[$i] -Bold -Align 'left'))
            }
            default {
                $cellXml.Add((New-TableCellXml -Text $cellText -Width $Widths[$i] -Align 'left'))
            }
        }
    }

    return "<w:tr>$($cellXml -join '')</w:tr>"
}

function New-TableXml {
    param(
        [int[]]$Widths,
        [object[]]$Rows
    )

    $gridCols = ($Widths | ForEach-Object { "<w:gridCol w:w=""$_""/>" }) -join ''
    $rowXml = New-Object System.Collections.Generic.List[string]

    foreach ($row in $Rows) {
        $rowXml.Add((New-TableRowXml -Cells $row.Cells -Widths $Widths -RowKind $row.Kind))
    }

    return @"
<w:tbl>
  <w:tblPr>
    <w:tblW w:w="0" w:type="auto"/>
    <w:tblBorders>
      <w:top w:val="single" w:sz="8" w:space="0" w:color="auto"/>
      <w:left w:val="single" w:sz="8" w:space="0" w:color="auto"/>
      <w:bottom w:val="single" w:sz="8" w:space="0" w:color="auto"/>
      <w:right w:val="single" w:sz="8" w:space="0" w:color="auto"/>
      <w:insideH w:val="single" w:sz="8" w:space="0" w:color="auto"/>
      <w:insideV w:val="single" w:sz="8" w:space="0" w:color="auto"/>
    </w:tblBorders>
  </w:tblPr>
  <w:tblGrid>$gridCols</w:tblGrid>
  $($rowXml -join '')
</w:tbl>
"@
}

function Get-SectPrXml {
    param([string]$DocumentXmlPath)

    [xml]$doc = Get-Content -LiteralPath $DocumentXmlPath -Encoding UTF8
    $ns = New-Object System.Xml.XmlNamespaceManager($doc.NameTable)
    $ns.AddNamespace('w', 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
    $sectPr = $doc.SelectSingleNode('//w:body/w:sectPr', $ns)
    if (-not $sectPr) {
        throw "Cannot find sectPr in template document."
    }

    return $sectPr.OuterXml
}

function Build-DocumentXml {
    param(
        [string]$ContentFilePath,
        [string]$SectPrXml
    )

    $paragraphXml = New-Object System.Collections.Generic.List[string]
    $lines = Get-Content -LiteralPath $ContentFilePath -Encoding UTF8

    for ($index = 0; $index -lt $lines.Count; $index++) {
        $line = $lines[$index]

        if ([string]::IsNullOrWhiteSpace($line)) {
            $paragraphXml.Add((New-ParagraphXml -Kind 'BLANK' -Text ''))
            continue
        }

        $parts = $line -split '\|', 2
        $kind = $parts[0].Trim()
        $text = if ($parts.Length -gt 1) { $parts[1] } else { '' }

        if ($kind -eq 'TABLE_START') {
            $widths = $text -split ',' | ForEach-Object { [int]$_.Trim() }
            $rows = New-Object System.Collections.Generic.List[object]

            for ($index = $index + 1; $index -lt $lines.Count; $index++) {
                $tableLine = $lines[$index]
                if ([string]::IsNullOrWhiteSpace($tableLine)) {
                    continue
                }

                $tableParts = $tableLine -split '\|', 2
                $tableKind = $tableParts[0].Trim()
                $tableText = if ($tableParts.Length -gt 1) { $tableParts[1] } else { '' }

                if ($tableKind -eq 'TABLE_END') {
                    break
                }

                if ($tableKind -in @('TABLE_HEADER', 'TABLE_ROW', 'TABLE_ROW_LABEL', 'TABLE_ROW_STRONG')) {
                    $cells = $tableText.Split([string[]]@('||'), [System.StringSplitOptions]::None)
                    $rows.Add([pscustomobject]@{
                        Kind = $tableKind
                        Cells = $cells
                    })
                    continue
                }

                throw "Unsupported table row kind: $tableKind"
            }

            $paragraphXml.Add((New-TableXml -Widths $widths -Rows $rows))
            continue
        }

        if ($kind -eq 'SPACE') {
            $count = 0
            [void][int]::TryParse($text, [ref]$count)
            if ($count -lt 1) { $count = 1 }
            for ($spaceIndex = 0; $spaceIndex -lt $count; $spaceIndex++) {
                $paragraphXml.Add((New-ParagraphXml -Kind 'BLANK' -Text ''))
            }
            continue
        }

        $paragraphXml.Add((New-ParagraphXml -Kind $kind -Text $text))
    }

    $bodyXml = ($paragraphXml -join '') + $SectPrXml
    return @"
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:wpc="http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas" xmlns:cx="http://schemas.microsoft.com/office/drawing/2014/chartex" xmlns:cx1="http://schemas.microsoft.com/office/drawing/2015/9/8/chartex" xmlns:cx2="http://schemas.microsoft.com/office/drawing/2015/10/21/chartex" xmlns:cx3="http://schemas.microsoft.com/office/drawing/2016/5/9/chartex" xmlns:cx4="http://schemas.microsoft.com/office/drawing/2016/5/10/chartex" xmlns:cx5="http://schemas.microsoft.com/office/drawing/2016/5/11/chartex" xmlns:cx6="http://schemas.microsoft.com/office/drawing/2016/5/12/chartex" xmlns:cx7="http://schemas.microsoft.com/office/drawing/2016/5/13/chartex" xmlns:cx8="http://schemas.microsoft.com/office/drawing/2016/5/14/chartex" xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:aink="http://schemas.microsoft.com/office/drawing/2016/ink" xmlns:am3d="http://schemas.microsoft.com/office/drawing/2017/model3d" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:oel="http://schemas.microsoft.com/office/2019/extlst" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:w10="urn:schemas-microsoft-com:office:word" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml" xmlns:w16cex="http://schemas.microsoft.com/office/word/2018/wordml/cex" xmlns:w16cid="http://schemas.microsoft.com/office/word/2016/wordml/cid" xmlns:w16="http://schemas.microsoft.com/office/word/2018/wordml" xmlns:w16sdtdh="http://schemas.microsoft.com/office/word/2020/wordml/sdtdatahash" xmlns:w16se="http://schemas.microsoft.com/office/word/2015/wordml/symex" xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup" xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk" xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml" xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape" mc:Ignorable="w14 w15 w16se w16cid w16 w16cex w16sdtdh wp14">
  <w:body>$bodyXml</w:body>
</w:document>
"@
}

function Update-CoreProperties {
    param([string]$CoreXmlPath)

    [xml]$core = Get-Content -LiteralPath $CoreXmlPath -Encoding UTF8
    $ns = New-Object System.Xml.XmlNamespaceManager($core.NameTable)
    $ns.AddNamespace('cp', 'http://schemas.openxmlformats.org/package/2006/metadata/core-properties')
    $ns.AddNamespace('dc', 'http://purl.org/dc/elements/1.1/')
    $ns.AddNamespace('dcterms', 'http://purl.org/dc/terms/')

    ($core.SelectSingleNode('/cp:coreProperties/dc:title', $ns)).InnerText = 'Web thuong mai dien tu thoi trang cao cap tich hop AI Agent'
    ($core.SelectSingleNode('/cp:coreProperties/dc:subject', $ns)).InnerText = 'AURA ARCHIVE thesis report'
    ($core.SelectSingleNode('/cp:coreProperties/dc:creator', $ns)).InnerText = 'Vu Hai Quan; Nguyen Anh Vu'
    ($core.SelectSingleNode('/cp:coreProperties/cp:lastModifiedBy', $ns)).InnerText = 'Codex'
    ($core.SelectSingleNode('/cp:coreProperties/cp:revision', $ns)).InnerText = '1'
    ($core.SelectSingleNode('/cp:coreProperties/dcterms:modified', $ns)).InnerText = [DateTime]::UtcNow.ToString('s') + 'Z'

    $core.Save($CoreXmlPath)
}

if (-not (Test-Path -LiteralPath $TemplateExtractedPath)) {
    throw "Template extracted folder not found: $TemplateExtractedPath"
}

if (-not (Test-Path -LiteralPath $ContentPath)) {
    throw "Content file not found: $ContentPath"
}

$sectPrXml = Get-SectPrXml -DocumentXmlPath (Join-Path $TemplateExtractedPath 'word\document.xml')
$newDocumentXml = Build-DocumentXml -ContentFilePath $ContentPath -SectPrXml $sectPrXml

$outputDir = Split-Path -Parent $OutputDocxPath
$packageDir = Join-Path $outputDir '_generated_docx_package'
$zipPath = [System.IO.Path]::ChangeExtension($OutputDocxPath, '.zip')

if (Test-Path -LiteralPath $packageDir) {
    Remove-Item -LiteralPath $packageDir -Recurse -Force
}
if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}
if (Test-Path -LiteralPath $OutputDocxPath) {
    Remove-Item -LiteralPath $OutputDocxPath -Force
}

Copy-Item -LiteralPath $TemplateExtractedPath -Destination $packageDir -Recurse -Force
Set-Content -LiteralPath (Join-Path $packageDir 'word\document.xml') -Value $newDocumentXml -Encoding UTF8
Update-CoreProperties -CoreXmlPath (Join-Path $packageDir 'docProps\core.xml')

Compress-Archive -Path (Join-Path $packageDir '*') -DestinationPath $zipPath -Force
Move-Item -LiteralPath $zipPath -Destination $OutputDocxPath -Force

Write-Output $OutputDocxPath


