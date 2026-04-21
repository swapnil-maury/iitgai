if (Get-Command jupyter -ErrorAction SilentlyContinue) {
    Write-Host "Starting Jupyter Notebook..."
    jupyter notebook
} else {
    Write-Host "Jupyter is not installed or not in PATH." -ForegroundColor Red
}