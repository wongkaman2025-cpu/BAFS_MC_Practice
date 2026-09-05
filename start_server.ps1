$dir = "C:\Users\user\Desktop\MC V@"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Host "Server running at http://localhost:8080/"
Write-Host "Open http://localhost:8080/BAFS_MC_操練.html in your browser"

while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
        $reqUrl = $ctx.Request.Url.LocalPath
        $filePath = Join-Path $dir $reqUrl.TrimStart("/").Replace("/","\")
        
        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            switch ($ext) {
                ".html" { $ct = "text/html; charset=utf-8" }
                ".js"   { $ct = "application/javascript; charset=utf-8" }
                ".css"  { $ct = "text/css" }
                default { $ct = "application/octet-stream" }
            }
            $ctx.Response.ContentType = $ct
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $ctx.Response.ContentLength64 = $bytes.Length
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $ctx.Response.StatusCode = 404
        }
        $ctx.Response.Close()
    } catch {
        Write-Host "Error: $_"
    }
}
