# Paths for your local clones
$scratchModArchivePath = "C:\Users\desse\OneDrive\Documents\GitHub\ScratchModArchive"
$penguinModPath       = "C:\Users\desse\OneDrive\Documents\GitHub\stuff\peng"
$turboWarpPath        = "C:\Users\desse\OneDrive\Documents\GitHub\stuff\turbo"
$sharkPoolPath        = "C:\Users\desse\OneDrive\Documents\GitHub\stuff\shark"

# Repository URLs
$scratchModRepo = "https://github.com/Jakdee123/ScratchModArchive.git"
$penguinRepo    = "https://github.com/PenguinMod/PenguinMod-ExtensionsGallery.git"
$turboWarpRepo  = "https://github.com/TurboWarp/extensions.git"
$sharkPoolRepo  = "https://github.com/SharkPool-SP/SharkPools-Extensions.git"

# Function to clone if missing or pull if exists
function Pull-Or-Clone {
    param([string]$repoUrl, [string]$localPath)
    if (Test-Path $localPath) {
        Write-Host "Pulling $localPath..."
        git -C $localPath pull
    } else {
        Write-Host "Cloning $repoUrl to $localPath..."
        git clone $repoUrl $localPath
    }
}

# Function to copy all files, always overwriting
function Copy-AllOverwrite {
    param([string]$source, [string]$destination)
    if (-not (Test-Path $source)) {
        Write-Host "Source path does not exist: $source"
        return
    }
    Get-ChildItem -Path $source -Recurse | ForEach-Object {
        $dest = Join-Path $destination ($_.FullName.Substring($source.Length + 1))
        $destDir = Split-Path $dest
        if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        if (-not $_.PSIsContainer) { Copy-Item $_.FullName $dest -Force }
    }
}

# Step 1: Pull or clone repositories
Pull-Or-Clone $scratchModRepo $scratchModArchivePath
Pull-Or-Clone $penguinRepo $penguinModPath
Pull-Or-Clone $turboWarpRepo $turboWarpPath
Pull-Or-Clone $sharkPoolRepo $sharkPoolPath

# Step 2: Copy all files, always overwriting
Write-Host "Copying PenguinMod files..."
Copy-AllOverwrite "$penguinModPath\static\extensions" "$scratchModArchivePath\static\extensions"
Copy-AllOverwrite "$penguinModPath\static\images" "$scratchModArchivePath\static\images"

Write-Host "Copying TurboWarp SVGs and JS..."
Copy-AllOverwrite "$turboWarpPath" "$scratchModArchivePath\static"

Write-Host "Copying SharkPools extensions..."
Copy-AllOverwrite "$sharkPoolPath\extension-code" "$scratchModArchivePath\static\extensions"
Copy-AllOverwrite "$sharkPoolPath\extension-thumbs" "$scratchModArchivePath\static\images"

# Step 3: Commit and push changes
Write-Host "Committing and pushing changes..."
git -C $scratchModArchivePath add .
git -C $scratchModArchivePath commit -m "added mods"
git -C $scratchModArchivePath push

Write-Host "All done!"
