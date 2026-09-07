# Servidor local simples para testar a pagina.
# Serve o index.html e tambem os arquivos das pastas imagens/ e fontes/.
# Uso:  powershell -ExecutionPolicy Bypass -File server.ps1
# Depois abra http://localhost:8080/

$root = (Get-Location).Path

$mime = @{
    ".html" = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".webp" = "image/webp"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".png"  = "image/png"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".woff2" = "font/woff2"
    ".woff" = "font/woff"
    ".ttf"  = "font/ttf"
    ".mp4"  = "video/mp4"
    ".json" = "application/json; charset=utf-8"
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Host "Servidor rodando em http://localhost:8080/  (Ctrl+C para parar)"

try {
    while ($listener.IsListening) {
        $context  = $listener.GetContext()
        $response = $context.Response
        $path     = [System.Uri]::UnescapeDataString($context.Request.Url.LocalPath)

        if ($path -eq "/") { $path = "/index.html" }

        # resolve o caminho e impede sair da pasta do projeto
        $full = Join-Path $root ($path.TrimStart("/") -replace "/", "\")
        $full = [System.IO.Path]::GetFullPath($full)

        if ($full.StartsWith($root) -and (Test-Path $full -PathType Leaf)) {
            $ext = [System.IO.Path]::GetExtension($full).ToLower()
            if ($mime.ContainsKey($ext)) {
                $type = $mime[$ext]
            } else {
                $type = "application/octet-stream"
            }
            $buffer = [System.IO.File]::ReadAllBytes($full)
            $response.ContentType     = $type
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        } else {
            Write-Host "404: $path"
            $response.StatusCode = 404
        }

        $response.Close()
    }
} finally {
    $listener.Stop()
}
