param (
    [string]$GitUrl, # Git URL cần clone và push
    [string[]]$SourceFiles, # Danh sách file nguồn cần chép
    [string[]]$TargetFiles  # Danh sách file đích (tương đối) trong repo tương ứng
)

# Hàm để loại bỏ ký tự đặc biệt khỏi GitUrl để tạo tên thư mục
function Remove-SpecialChars {
    param ([string]$str)
    return $str -replace '[^a-zA-Z0-9]', ''
}

# Loại bỏ ký tự đặc biệt khỏi GitUrl để tạo thư mục
$cloneFolder = Remove-SpecialChars $GitUrl

# Cấu hình Git user
git config --global user.name "github-actions"
git config --global user.email "github-actions@github.com"

# Resolve đường dẫn của file nguồn trước khi cd vào thư mục clone
$resolvedSourceFiles = @()
for ($i = 0; $i -lt $SourceFiles.Length; $i++) {
    $resolvedSourcePath = Resolve-Path $SourceFiles[$i]
    $resolvedSourceFiles += $resolvedSourcePath
    Write-Host "Resolved source file: $resolvedSourcePath"
}

# Clone repository vào thư mục đã loại bỏ ký tự đặc biệt
git clone $GitUrl $cloneFolder

# Lấy đường dẫn đầy đủ của thư mục clone
$fullCloneFolderPath = Resolve-Path $cloneFolder

# Di chuyển vào thư mục đã clone
cd $fullCloneFolderPath

# Biến để lưu version từ file .js
$Version = ""

# Overwrite từng file từ danh sách resolvedSourceFiles và TargetFiles
for ($i = 0; $i -lt $resolvedSourceFiles.Length; $i++) {
    $resolvedSourcePath = $resolvedSourceFiles[$i]
    
    # Khởi tạo biến chứa đường dẫn file để lấy version, chỉ khi file là .aes hoặc .js
    $versionFilePath = $null

    # Kiểm tra nếu file là .aes để bỏ đuôi .aes và tìm tên file .js tương ứng
    if ($resolvedSourcePath -like "*.aes") {
        $versionFilePath = $resolvedSourcePath -replace ".aes", ""
        Write-Host "File .aes refers to JS file: $versionFilePath"
    }

    # Kiểm tra nếu file là .js, thì lấy luôn file đó làm versionFilePath
    elseif ($resolvedSourcePath -like "*.js") {
        $versionFilePath = $resolvedSourcePath
        Write-Host "File is JS: $versionFilePath"
    }

    # Chỉ xử lý nếu versionFilePath đã được xác định
    if ($versionFilePath) {
        # Kiểm tra nếu file tồn tại trước khi đọc phiên bản
        if (Test-Path $versionFilePath) {
            # Đọc dòng đầu tiên của file và trích xuất version nếu có
            $firstLine = Get-Content $versionFilePath -TotalCount 1

            if ($firstLine -match "===WEBPACK BUILD: (.*?)===") {
                $Version = $matches[1]
                Write-Host "Version extracted: $Version from $versionFilePath"
            }
            else {
                Write-Host "Version not found in $versionFilePath"
            }
        }
        else {
            Write-Host "Version file not found: $versionFilePath"
        }
    }

    # Kết hợp đường dẫn tương đối với thư mục clone
    $fullTargetPath = Join-Path -Path $fullCloneFolderPath -ChildPath $TargetFiles[$i]

    # Kiểm tra và tạo thư mục đích nếu chưa tồn tại
    $targetDirectory = Split-Path $fullTargetPath -Parent
    if (-not (Test-Path $targetDirectory)) {
        Write-Host "Creating directory: $targetDirectory"
        New-Item -Path $targetDirectory -ItemType Directory -Force
    }

    # Hiển thị log đường dẫn đầy đủ của file nguồn và file đích
    Write-Host "Copying file from '$resolvedSourcePath' to '$fullTargetPath'"

    # Copy file nguồn tới đường dẫn đích đã kết hợp
    if (Test-Path $resolvedSourcePath) {
        Copy-Item -Path $resolvedSourcePath -Destination $fullTargetPath -Force
    }
    else {
        Write-Host "Source file not found: $resolvedSourcePath"
        exit 1
    }
}

$commitMessage = "WEBPACK BUILD 🅥 $Version "

# Thay thế phần https:// trong GitUrl để thêm GITHUB_TOKEN
$GitUrlWithToken = $GitUrl -replace 'https://', "https://x-access-token:${env:WEBPACKPUSHCODE}@"

# Stage, commit, and push the changes
git add .
git commit -m "$commitMessage"
git push $GitUrlWithToken
