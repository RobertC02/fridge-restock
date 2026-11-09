# Builds site/index.html (the hostable, offline-capable app) from app.html.
$here = $PSScriptRoot
$head = @'
<!doctype html>
<html lang="en"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, viewport-fit=cover">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="Restock">
<link rel="manifest" href="manifest.webmanifest">
<link rel="apple-touch-icon" href="icon.png">
<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}</style>

'@
[IO.File]::WriteAllText("$here\docs\index.html", $head + [IO.File]::ReadAllText("$here\app.html"), [Text.UTF8Encoding]::new($false))

if (-not (Test-Path "$here\docs\icon.png")) {
  Add-Type -AssemblyName System.Drawing
  $b = New-Object Drawing.Bitmap 180, 180
  $g = [Drawing.Graphics]::FromImage($b); $g.SmoothingMode = 'AntiAlias'
  $g.Clear([Drawing.Color]::FromArgb(17, 22, 27))
  $amber = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(227, 168, 76))
  $pen = New-Object Drawing.Pen ([Drawing.Color]::FromArgb(230, 235, 239)), 6
  $g.DrawRectangle($pen, 40, 26, 100, 128)                      # fridge
  foreach ($y in 66, 106) { $g.DrawLine($pen, 40, $y, 140, $y) } # shelves
  foreach ($row in @(@(36, 4), @(76, 2), @(116, 3))) {           # bottles
    for ($i = 0; $i -lt $row[1]; $i++) { $g.FillRectangle($amber, 52 + $i * 21, $row[0] + 8, 12, 20) }
  }
  $b.Save("$here\docs\icon.png", [Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $b.Dispose()
}
