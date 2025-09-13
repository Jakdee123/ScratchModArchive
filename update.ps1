# Paths for your local clones
$scratchModArchivePath = "C:\Users\desse\OneDrive\Documents\GitHub\ScratchModArchive"
$penguinModPath = "C:\Users\desse\OneDrive\Documents\GitHub\stuff\peng"
$turboWarpPath = "C:\Users\desse\OneDrive\Documents\GitHub\stuff\turbo"
$sharkPoolPath = "C:\Users\desse\OneDrive\Documents\GitHub\stuff\sharkpool"

# Helper function to copy all files and folders, always overwriting
function Copy-AllOverwrite {
    param (
        [string]$source,
        [string]$destination
    )
    Get-ChildItem -Path $source -Recurse | ForEach-Object {
        $dest = Join-Path $destination ($_.FullName.Substring($source.Length + 1))
        $destDir = Split-Path $dest
        if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
        if (-not $_.PSIsContainer) { Copy-Item $_.FullName $dest -Force }
    }
}

# Step 1: Pull repositories
Write-Host "Pulling ScratchModArchive..."
git -C $scratchModArchivePath pull

Write-Host "Pulling PenguinMod-ExtensionsGallery..."
git clone $penguinModPath

Write-Host "Pulling TurboWarp extensions..."
git clone $turboWarpPath

Write-Host "Pulling SharkPools-Extensions..."
git clone $sharkPoolPath

# Step 2: Copy all files, always overwriting
Write-Host "Copying PenguinMod files..."
Copy-AllOverwrite "$penguinModPath\static\extensions" "$scratchModArchivePath\static\extensions"
Copy-AllOverwrite "$penguinModPath\static\images" "$scratchModArchivePath\static\images"

Write-Host "Copying TurboWarp SVGs and JS..."
Copy-AllOverwrite "$turboWarpPath" "$scratchModArchivePath\static"

Write-Host "Copying SharkPools extensions..."
Copy-AllOverwrite "$sharkPoolPath\extension-code" "$scratchModArchivePath\static\extensions"
Copy-AllOverwrite "$sharkPoolPath\extension-thumbs" "$scratchModArchivePath\static\images"

# Step 3: Commit and push
Write-Host "Committing and pushing changes..."
git -C $scratchModArchivePath add .
git -C $scratchModArchivePath commit -m "added mods"
git -C $scratchModArchivePath push

Write-Host "All done!"
