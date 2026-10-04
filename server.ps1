$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Host "Servidor rodando em http://localhost:8080/"
try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        try {
            $response = $context.Response
            
            # Forar o navegador a no usar cache
            $response.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate")
            $response.AddHeader("Pragma", "no-cache")
            $response.AddHeader("Expires", "0")

            $path = $context.Request.Url.LocalPath
            if ($path -eq "/" -or $path -eq "/index.html") {
                $filePath = Join-Path "c:\BAU DOS DESENHOS" "index.html"
                if (Test-Path $filePath) {
                    $buffer = [System.IO.File]::ReadAllBytes($filePath)
                    $response.ContentType = "text/html; charset=utf-8"
                    $response.ContentLength64 = $buffer.Length
                    $response.OutputStream.Write($buffer, 0, $buffer.Length)
                } else {
                    $response.StatusCode = 404
                }
            } else {
                $response.StatusCode = 404
            }
            $response.Close()
        } catch {
            Write-Host "Ignorado: $($_.Exception.Message)"
        }
    }
} finally {
    $listener.Stop()
}
