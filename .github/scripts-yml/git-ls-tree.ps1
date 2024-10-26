# Hiển thị thông tin các tệp đã được commit
Write-Host "+------------------------------+" -ForegroundColor Cyan
Write-Host "|📄Listing committed files----|" -ForegroundColor Cyan
Write-Host "+------------------------------+" -ForegroundColor Cyan
git ls-tree -r -t -l HEAD
# Ngăn cách bằng dòng trống để dễ đọc
Write-Host "`n"

# Hiển thị các tệp chưa được theo dõi (untracked files)
Write-Host "+------------------------------+" -ForegroundColor Yellow
Write-Host "|🛠️Listing untracked files----|" -ForegroundColor Yellow
Write-Host "+------------------------------+" -ForegroundColor Yellow
# git ls-files --others
git ls-files --others --exclude='node_modules/*'
# Ngăn cách bằng dòng trống để dễ đọc
Write-Host "`n"