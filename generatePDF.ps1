# Path to pdflatex.exe (adjust if needed)
$pdflatexPath = "C:\Program Files\MiKTeX\miktex\bin\x64\pdflatex.exe"

# Output file name
$outputPdf = "Podman_IBM_UVT_Proiect_Colectiv_DevOps.pdf"
$combinedMd = "combined.md"

# Remove old combined file if it exists
if (Test-Path $combinedMd) {
    Remove-Item $combinedMd
}

# Collect and combine all README.md files, fixing relative image paths and formatting titles
Get-ChildItem -Path . -Recurse -Filter "README.md" | ForEach-Object {
    $dirName = $_.Directory.Name

    if ($dirName -match '^(\d+)-(.*)$') {
        $number = $matches[1]
        $title = $matches[2] -replace '[-_]', ' ' -split '\s+' | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() }
        $prettyTitle = "$number $($title -join ' ')"
    } else {
        $title = $dirName -replace '[-_]', ' ' -split '\s+' | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() }
        $prettyTitle = $title -join ' '
    }

    # Add heading
    Add-Content -Path $combinedMd -Value "`n# $prettyTitle`n" -Encoding UTF8

    # Read, fix image paths and remove control characters
    $content = Get-Content $_.FullName -Raw -Encoding UTF8
    $fixedContent = $content `
        -replace "\!\[(.*?)\]\(\.\.\/_img\/(.*?)\)", '![${1}](./_img/${2})' `
        -replace '[\x00-\x08\x0B\x0C\x0E-\x1F]', ''  # Remove control characters

    Add-Content -Path $combinedMd -Value $fixedContent -Encoding UTF8
}

# Generate the PDF with Pandoc
try {
    pandoc $combinedMd -o $outputPdf --pdf-engine="$pdflatexPath" --resource-path=. --from markdown
    Write-Host "Generated $outputPdf from all README.md files, including images."

    # Clean up only if successful
    Remove-Item $combinedMd
} catch {
    Write-Host "PDF generation failed: $_"
    Write-Host "Leaving $combinedMd in place for debugging."
}
