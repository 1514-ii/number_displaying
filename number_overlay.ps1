Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic

$appName = 'NumberOverlayPS'
$runKeyPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$configDir = Join-Path $env:APPDATA 'NumberOverlay'
$configPath = Join-Path $configDir 'number.txt'
$opacityPath = Join-Path $configDir 'opacity.txt'
$scriptPath = $MyInvocation.MyCommand.Path

if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir | Out-Null
}

if (-not (Test-Path $configPath)) {
    '0' | Out-File -FilePath $configPath -Encoding ascii
}
if (-not (Test-Path $opacityPath)) {
    '1.0' | Out-File -FilePath $opacityPath -Encoding ascii
}

$number = (Get-Content $configPath -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
if ([string]::IsNullOrWhiteSpace($number)) { $number = '0' }
$opacityRaw = (Get-Content $opacityPath -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
$opacity = 1.0
if ([double]::TryParse($opacityRaw, [ref]$opacity) -eq $false) { $opacity = 1.0 }
if ($opacity -lt 0.2 -or $opacity -gt 1.0) { $opacity = 1.0 }

$psCmd = "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
Set-ItemProperty -Path $runKeyPath -Name $appName -Value $psCmd

$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$form.Location = New-Object System.Drawing.Point(0,0)
$form.TopMost = $true
$form.ShowInTaskbar = $false
$form.AutoSize = $true
$form.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
$form.BackColor = [System.Drawing.Color]::Black
$form.Opacity = $opacity

$label = New-Object System.Windows.Forms.Label
$label.AutoSize = $true
$label.Font = New-Object System.Drawing.Font('Segoe UI',11,[System.Drawing.FontStyle]::Bold)
$label.ForeColor = [System.Drawing.Color]::Lime
$label.BackColor = [System.Drawing.Color]::Black
$label.Padding = New-Object System.Windows.Forms.Padding(8,0,8,0)
$label.Text = $number
$form.Controls.Add($label)

function Set-Number([string]$value) {
    if ([string]::IsNullOrWhiteSpace($value)) { return }
    $v = $value.Trim()
    $script:label.Text = $v
    $v | Out-File -FilePath $script:configPath -Encoding ascii
}


function Set-Opacity([double]$value) {
    if ($value -lt 0.2 -or $value -gt 1.0) { return }
    $script:form.Opacity = $value
    ([string]$value) | Out-File -FilePath $script:opacityPath -Encoding ascii
}

function Change-Number {
    $input = [Microsoft.VisualBasic.Interaction]::InputBox('Enter number to display:','Change Number',$script:label.Text)
    if (-not [string]::IsNullOrWhiteSpace($input)) {
        Set-Number $input
    }
}

$menu = New-Object System.Windows.Forms.ContextMenuStrip
$changeItem = $menu.Items.Add('Change Number')
$opacity100 = $menu.Items.Add('Opacity 100%')
$opacity75 = $menu.Items.Add('Opacity 75%')
$opacity50 = $menu.Items.Add('Opacity 50%')
$opacity25 = $menu.Items.Add('Opacity 25%')
$exitItem = $menu.Items.Add('Exit')
$changeItem.Add_Click({ Change-Number })
$opacity100.Add_Click({ Set-Opacity 1.0 })
$opacity75.Add_Click({ Set-Opacity 0.75 })
$opacity50.Add_Click({ Set-Opacity 0.5 })
$opacity25.Add_Click({ Set-Opacity 0.25 })
$exitItem.Add_Click({ $form.Close() })
$form.ContextMenuStrip = $menu

$form.Add_MouseClick({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Right) {
        $form.ContextMenuStrip.Show($form, $e.Location)
    }
})

$label.Add_MouseClick({
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        Change-Number
    }
})

[void]$form.ShowDialog()
