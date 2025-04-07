# Path to pdflatex.exe (adjust if needed)
$pdflatexPath = "C:\Program Files\MiKTeX\miktex\bin\x64\pdflatex.exe"

# Output file name
$outputPdf = "final.pdf"
$combinedMd = "combined.md"

# Remove old combined file if it exists
if (Test-Path $combinedMd) {
    Remove-Item $combinedMd
}

# Collect and combine all README.md files, fixing relative image paths
Get-ChildItem -Path . -Recurse -Filter "README.md" | ForEach-Object {
    $dirName = $_.Directory.Name
    Add-Content -Path $combinedMd -Value "`n# $dirName`n"
    
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
s