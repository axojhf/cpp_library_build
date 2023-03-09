$file = "libcurl.pc"
$content = Get-Content $file
$newContent = ""

foreach ($line in $content) {
    if ($line.StartsWith("supported_features=")) {
        $features = $line.Substring(19) -replace '\s+', ';'
        $line = "supported_features=$features"
    }
    if ($line.StartsWith("supported_protocols=")) {
        $features = $line.Substring(20) -replace '\s+', ';'
        $line = "supported_protocols=$features"
    }
    $newContent += $line + "`n"
}

Set-Content $file $newContent.TrimEnd("`n")
