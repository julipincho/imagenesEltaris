param(
    [string]$Path = ".\campados.txt"
)

$ErrorActionPreference = "Stop"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

if (-not (Test-Path -LiteralPath $Path)) {
    throw "Campaign file not found: $Path"
}

$resolved = Resolve-Path -LiteralPath $Path
$content = [IO.File]::ReadAllText($resolved, [Text.Encoding]::UTF8)
$pages = $content -split '(?m)^\\page\s*$'

function Get-DisplayedPage {
    param([string]$HeadingPattern)

    for ($i = 0; $i -lt $pages.Count; $i++) {
        if ($pages[$i] -match $HeadingPattern) {
            return $i - 2
        }
    }

    throw "Heading not found for index: $HeadingPattern"
}

$entries = [ordered]@{
    'Lanterra' = Get-DisplayedPage '(?m)^# 12\. Ciudad II: Lanterra\s*$'
    'Metusta' = Get-DisplayedPage '(?m)^# 13\. Ciudad III: Metusta\s*$'
    'Brammavik' = Get-DisplayedPage '(?m)^# 14\. Ciudad IV: Brammavik\s*$'
    'Velkora' = Get-DisplayedPage '(?m)^# 15\. Ciudad V: Velkora\s*$'
    'Valle de los Ecos' = Get-DisplayedPage '(?m)^# 16\. El Valle de los Ecos\s*$'
    'La Fuente del Norte' = Get-DisplayedPage '(?m)^# 17\. La Fuente del Norte\s*$'
    'Deseos y consecuencias' = Get-DisplayedPage '(?m)^# 18\. Deseos, consecuencias y finales personales\s*$'
    'Tablas de viaje' = Get-DisplayedPage '(?m)^# 19\. Tablas de viaje, comedia y encuentros\s*$'
    'Apéndice de criaturas' = Get-DisplayedPage '(?m)^# 20\. Apéndice de criaturas oficiales sugeridas\s*$'
    'Apéndice de personajes' = Get-DisplayedPage 'MUVARIA-PERSONAJES-PORTADA-V1'
    'Nerin — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-NERIN-V1'
    'Calo Bronce — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-CALO-V1'
    'Timo Dos Veces — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-TIMO-V1'
    'Lira de Cinco Llaves — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-LIRA-V1'
    'Niño de las Cartas — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-NINO-V1'
    'Jaska Mir — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-JASKA-V1'
    'Maer Valcor Senn — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-MAER-V1'
    'Sira Nueve Nudos — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-SIRA-V1'
    'Silex Varo — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-SILEX-V1'
    'Hermano Lodo — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-LODO-V1'
    'Madre Seralya — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-SERALYA-V1'
    'Lady Irielle — retrato' = Get-DisplayedPage 'MUVARIA-PERSONAJES-IRIELLE-V1'
    'Cierre para el DM' = Get-DisplayedPage '(?m)^# Cierre para el DM\s*$'
}

$content = $content.Replace('  - Guía de dirección de Miravalle, 16', '  - Guía de las dos copias, 16')

foreach ($entry in $entries.GetEnumerator()) {
    $escaped = [regex]::Escape($entry.Key)
    $pattern = "(?m)^(\s*- $escaped), \d+\s*$"
    $replacement = "`$1, $($entry.Value)"
    $content = [regex]::Replace($content, $pattern, $replacement)
}

[IO.File]::WriteAllText($resolved, $content, $utf8NoBom)

$entries.GetEnumerator() | ForEach-Object {
    "{0}: {1}" -f $_.Key, $_.Value
}
