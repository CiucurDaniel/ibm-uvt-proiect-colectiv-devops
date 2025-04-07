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

    # Extract the number (if it exists) and the rest of the directory name
    if ($dirName -match '^(\d+)-(.*)$') {
        $number = $matches[1]
        $title = $matches[2] -replace '[-_]', ' ' -split '\s+' | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() }
        $prettyTitle = "$number $($title -join ' ')"
    }
    else {
        # If no number, just process as a regular title
        $title = $dirName -replace '[-_]', ' ' -split '\s+' | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() }
        $prettyTitle = $title -join ' '
    }

    # Add the formatted title to the combined markdown
    Add-Content -Path $combinedMd -Value "`n# $prettyTitle`n"

    # Read content and fix image paths
    $content = Get-Content $_.FullName
    $fixedContent = $content -replace "\!\[(.*?)\]\(\.\.\/_img\/(.*?)\)", '![${1}](./_img/${2})'

    Add-Content -Path $combinedMd -Value $fixedContent
}

# Generate the PDF with Pandoc
try {
    pandoc $combinedMd -o $outputPdf --pdf-engine="$pdflatexPath" --resource-path=.
    Write-Host "✅ Generated $outputPdf from all README.md files, including images."
} catch {
    Write-Host "❌ PDF generation failed: $_"
}

# Clean up temporary file
Remove-Item $combinedMd
