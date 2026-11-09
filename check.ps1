# PowerShell Check Runner for Windows
param (
    [string]$Target = "",
    [string]$Flag = ""
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# 1. ถ้าเครื่องมี Git Bash หรือ bash ให้ส่งต่อให้ check.sh ทันที (ให้ผลลัพธ์เหมือนกัน 100%)
$BashCmd = Get-Command "bash" -ErrorAction SilentlyContinue
if (-not $BashCmd) {
    # ลองหาตำแหน่ง Git Bash มาตรฐานบน Windows
    $CommonGitPaths = @(
        "C:\Program Files\Git\bin\bash.exe",
        "C:\Program Files\Git\usr\bin\bash.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
    )
    foreach ($path in $CommonGitPaths) {
        if (Test-Path $path) {
            $BashCmd = $path
            break
        }
    }
}

if ($BashCmd) {
    Set-Location $ScriptDir
    & $BashCmd "./check.sh" $Target $Flag
    exit $LASTEXITCODE
}

# 2. กรณีเครื่องไม่มี bash ให้ทำงานด้วย PowerShell Mode
function Show-Help {
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "🛠️  Terraform Practice Suite - Windows PowerShell Checker" -ForegroundColor Cyan
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "วิธีใช้งานบน Windows PowerShell:"
    Write-Host "  .\check.ps1 lab01        - ตรวจคำตอบของ Lab 01"
    Write-Host "  .\check.ps1 lab02        - ตรวจคำตอบของ Lab 02"
    Write-Host "  .\check.ps1 lab03        - ตรวจคำตอบของ Lab 03"
    Write-Host "  .\check.ps1 lab04        - ตรวจคำตอบของ Lab 04"
    Write-Host "  .\check.ps1 lab05        - ตรวจคำตอบของ Lab 05"
    Write-Host "  .\check.ps1 mock         - ตรวจและคิดคะแนน Mock Exam (100 คะแนน)"
    Write-Host "  .\check.ps1 all          - ตรวจทุกข้อรวดเดียว"
    Write-Host ""
    Write-Host "ทริก: เติม --solution เพื่อตรวจเช็กกับไฟล์เฉลย เช่น .\check.ps1 lab01 --solution"
    Write-Host "==========================================================" -ForegroundColor Cyan
}

if (-not $Target) {
    Show-Help
    exit 0
}

# Helper function to find target directory
function Get-TargetDir($labFolder, $flag) {
    $fullLabPath = Join-Path $ScriptDir $labFolder
    if ($flag -eq "--solution" -or $flag -eq "-s") {
        return (Join-Path $fullLabPath "solution")
    }
    $practicePath = Join-Path $fullLabPath "practice"
    if ((Test-Path $practicePath) -and (Get-ChildItem -Path $practicePath -Filter *.tf -ErrorAction SilentlyContinue)) {
        return $practicePath
    }
    if (Get-ChildItem -Path $fullLabPath -Filter *.tf -ErrorAction SilentlyContinue) {
        return $fullLabPath
    }
    Write-Host "`n❌ ไม่พบไฟล์ .tf ที่คุณเขียนใน $labFolder หรือ $labFolder\practice!" -ForegroundColor Red
    Write-Host "💡 เริ่มทำได้โดยการสร้างไฟล์ .tf ในโฟลเดอร์ดังกล่าว" -ForegroundColor Yellow
    Write-Host "💡 (หรือทดสอบตรวจไฟล์เฉลยได้ด้วย: .\check.ps1 $Target --solution)`n" -ForegroundColor Yellow
    return $null
}

$CacheDir = Join-Path (Split-Path -Parent $ScriptDir) ".terraform-cache"

function Run-LabCheck($labFolder, $labName, $flag) {
    $dir = Get-TargetDir $labFolder $flag
    if (-not $dir) { return }

    Write-Host "`n👉 กำลังตรวจโค้ดใน: $dir" -ForegroundColor Green
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "🔍 ตรวจแบบฝึกหัด $labName" -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan

    Push-Location $dir
    try {
        # Check fmt
        Write-Host -NoNewline "1. จัดรูปแบบโค้ด (terraform fmt): "
        terraform fmt -check *>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ PASS" -ForegroundColor Green
        } else {
            Write-Host "⚠ WARN (รัน 'terraform fmt' เพื่อจัดระเบียบ)" -ForegroundColor Yellow
        }

        # Check init & validate
        Write-Host -NoNewline "2. ตรวจสอบความถูกต้อง Syntax (terraform validate): "
        if (Test-Path $CacheDir) {
            terraform init -input=false -plugin-dir="$CacheDir" *>$null
        } else {
            terraform init -input=false *>$null
        }
        terraform validate *>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ PASS" -ForegroundColor Green
        } else {
            Write-Host "✗ FAIL (รัน 'terraform validate' เพื่อดู error)" -ForegroundColor Red
        }

        # Check .tf content
        $content = Get-ChildItem -Filter *.tf | Get-Content -Raw
        Write-Host -NoNewline "3. ตรวจสอบโครงสร้างไฟล์และบล็อกสำคัญ: "
        if ($content -match "resource|data|variable") {
            Write-Host "✓ PASS" -ForegroundColor Green
        } else {
            Write-Host "✗ FAIL" -ForegroundColor Red
        }
    } finally {
        Pop-Location
    }
}

switch ($Target.ToLower()) {
    "lab01" { Run-LabCheck "lab01_hcl_basics" "Lab 01: HCL & EC2" $Flag }
    "lab02" { Run-LabCheck "lab02_variables_modules" "Lab 02: Variables & Modules" $Flag }
    "lab03" { Run-LabCheck "lab03_iteration_dynamic" "Lab 03: Iteration & Dynamic" $Flag }
    "lab04" { Run-LabCheck "lab04_state_and_lifecycle" "Lab 04: State & Lifecycle" $Flag }
    "lab05" { Run-LabCheck "lab05_remote_state_management" "Lab 05: Remote State" $Flag }
    "mock"  { Run-LabCheck "mock_exam_full" "Mock Exam Full" $Flag }
    "all"   {
        Run-LabCheck "lab01_hcl_basics" "Lab 01" $Flag
        Run-LabCheck "lab02_variables_modules" "Lab 02" $Flag
        Run-LabCheck "lab03_iteration_dynamic" "Lab 03" $Flag
        Run-LabCheck "lab04_state_and_lifecycle" "Lab 04" $Flag
        Run-LabCheck "lab05_remote_state_management" "Lab 05" $Flag
        Run-LabCheck "mock_exam_full" "Mock Exam" $Flag
    }
    Default { Show-Help }
}
