param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$Query,

    [int]$Top = 8,

    [string]$Root = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Root)) {
    $scriptHome = if ($PSScriptRoot) {
        $PSScriptRoot
    } else {
        Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    $Root = (Resolve-Path (Join-Path $scriptHome "..")).Path
}

function Repair-Mojibake {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }

    try {
        $latin1 = [System.Text.Encoding]::GetEncoding(28591)
        $bytes = $latin1.GetBytes($Text)
        $fixed = [System.Text.Encoding]::UTF8.GetString($bytes)
        if (-not [string]::IsNullOrWhiteSpace($fixed) -and $fixed -ne $Text) {
            return $fixed
        }
    } catch {
    }

    return $Text
}

function Normalize-SearchText {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return ""
    }

    $combined = "$Text`n$(Repair-Mojibake $Text)"
    $normalized = $combined.Normalize([Text.NormalizationForm]::FormD)
    $builder = New-Object System.Text.StringBuilder

    foreach ($char in $normalized.ToCharArray()) {
        $category = [Globalization.CharUnicodeInfo]::GetUnicodeCategory($char)
        if ($category -ne [Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$builder.Append([char]::ToLowerInvariant($char))
        }
    }

    return (($builder.ToString() -replace "[^a-z0-9\s\-]", " ") -replace "\s+", " ").Trim()
}

function Get-SectionText {
    param(
        [string[]]$Lines,
        [string]$StartPattern,
        [string]$EndPattern
    )

    $start = ($Lines | Select-String $StartPattern | Select-Object -First 1).LineNumber
    if (-not $start) {
        return ""
    }

    $end = ($Lines | Select-String $EndPattern | Select-Object -First 1).LineNumber
    if (-not $end) {
        $end = $Lines.Count + 1
    }

    return ($Lines[($start)..($end - 2)] -join "`n")
}

function Count-TermMatches {
    param(
        [string]$Text,
        [string]$Term
    )

    if ([string]::IsNullOrWhiteSpace($Text) -or [string]::IsNullOrWhiteSpace($Term)) {
        return 0
    }

    return [regex]::Matches($Text, "(?<!\S)$([regex]::Escape($Term))(?!\S)").Count
}

$queryText = ($Query -join " ").Trim()
$normalizedQuery = Normalize-SearchText $queryText
$terms = $normalizedQuery -split " " | Where-Object { $_.Length -ge 2 } | Select-Object -Unique

if (-not $terms -or @($terms).Count -eq 0) {
    throw "Provide at least one search term."
}

$notesPath = Join-Path $Root "notes"
$noteFiles = Get-ChildItem -Path $notesPath -File -Filter "parte-*.md" | Sort-Object Name
if (-not $noteFiles) {
    throw "No parte-*.md files found under $notesPath"
}

$results = foreach ($file in $noteFiles) {
    $raw = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $lines = $raw -split "`r?`n"

    $nameText = Normalize-SearchText $file.Name
    $headerText = Normalize-SearchText (($lines | Select-Object -First 12) -join "`n")
    $questionsText = Normalize-SearchText (Get-SectionText -Lines $lines -StartPattern "^## 13\." -EndPattern "^## 14\.")
    $actionsText = Normalize-SearchText (Get-SectionText -Lines $lines -StartPattern "^## 14\." -EndPattern "^## 15\.")
    $allText = Normalize-SearchText $raw

    $score = 0
    $matchedTerms = New-Object System.Collections.Generic.List[string]

    if ($allText.Contains($normalizedQuery)) {
        $score += 10
    }

    foreach ($term in $terms) {
        $matched = $false

        if ($nameText.Contains($term)) {
            $score += 5
            $matched = $true
        }
        if ($headerText.Contains($term)) {
            $score += 4
            $matched = $true
        }
        if ($questionsText.Contains($term)) {
            $score += 3
            $matched = $true
        }
        if ($actionsText.Contains($term)) {
            $score += 2
            $matched = $true
        }

        $occurrences = Count-TermMatches -Text $allText -Term $term
        if ($occurrences -gt 0) {
            $score += [Math]::Min(3, $occurrences)
            $matched = $true
        }

        if ($matched) {
            $matchedTerms.Add($term)
        }
    }

    if ($score -le 0) {
        continue
    }

    $fragment = ($lines | Where-Object { $_ -like "- **Fragmento/Parte:*" } | Select-Object -First 1)
    $themes = ($lines | Where-Object { $_ -like "- **Temas principales:*" } | Select-Object -First 1)

    $snippets = foreach ($term in $matchedTerms | Select-Object -Unique) {
        $line = $lines | Where-Object {
            $normalizedLine = Normalize-SearchText $_
            $normalizedLine.Contains($term) -and $_ -notmatch "^## "
        } | Select-Object -First 1

        if ($line) {
            $line.Trim()
        }
    }

    [pscustomobject]@{
        Name = $file.Name
        Score = $score
        Fragment = $fragment
        Themes = $themes
        MatchedTerms = ($matchedTerms | Select-Object -Unique)
        Snippets = ($snippets | Select-Object -Unique -First 2)
    }
}

$ranked = $results |
    Sort-Object `
        @{ Expression = "Score"; Descending = $true }, `
        @{ Expression = "Name"; Descending = $false } |
    Select-Object -First $Top

if (-not $ranked) {
    throw "No notes matched query: $queryText"
}

foreach ($result in $ranked) {
    Write-Output ("FILE: {0}" -f $result.Name)
    Write-Output ("Score: {0}" -f $result.Score)
    if ($result.Fragment) {
        Write-Output $result.Fragment
    }
    if ($result.Themes) {
        Write-Output $result.Themes
    }
    if ($result.MatchedTerms) {
        Write-Output ("Matched terms: {0}" -f (($result.MatchedTerms | Select-Object -Unique) -join ", "))
    }
    foreach ($snippet in ($result.Snippets | Where-Object { $_ })) {
        Write-Output ("Snippet: {0}" -f $snippet)
    }
    Write-Output ""
}
