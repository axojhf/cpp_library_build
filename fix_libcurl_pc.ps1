$file = "C:/curl_install/lib/pkgconfig/libcurl.pc"
$content = Get-Content $file
$newContent = ""

foreach ($line in $content) {
    if ($line.StartsWith("supported_features=")) {
        $features = $line.Substring(19) -replace '\s+', ';'
        $line = "supported_features=$features"
    }
    $newContent += $line + "`n"
}

Set-Content $file $newContent.TrimEnd("`n")