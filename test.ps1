Write-Host "Loop started"

do
{
    $result = Invoke-WebRequest -URI "https://prod-191.westus.logic.azure.com/workflows/f54f8dcc8765421797a099032d809809/triggers/manual/paths/invoke?api-version=2016-06-01&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=vJRtV5zX5O6-vfd7IgzPPJGfpSFXvWFbFb8QcCNWVwM"
    $json = $result | ConvertFrom-Json
    Write-Host "API status:" $json[0].status
    Start-Sleep -Seconds 10
}
while (($json[0].status -ne 'success'))

Write-Host "Loop ended"