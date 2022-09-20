$Response = Invoke-WebRequest -URI https://www.bing.com?q=how+many+feet+in+a+mile
$Response.AllElements | Where-Object {
    $_.name -like "* Value" -and $_.tagName -eq "INPUT"
} | Select-Object Name, Value