import subprocess
import os
import shutil
import glob

def run_command(cmd):
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        print(result.stdout)
        return result
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {cmd}\nError: {e.stderr}")
        raise e

# Set base directory
base_dir = os.getcwd()

# Define repository directories (use raw strings for Windows compatibility)
scratch_dir = os.path.normpath(os.path.join(base_dir, r'ScratchModArchive'))
penguin_dir = os.path.normpath(os.path.join(base_dir, r'PenguinMod-ExtensionsGallery'))
turbo_dir = os.path.normpath(os.path.join(base_dir, r'TurboWarp-extensions'))
shark_dir = os.path.normpath(os.path.join(base_dir, r'SharkPools-Extensions'))

# Function to clone or pull a repository using gh
def clone_or_pull(repo_url, local_dir):
    repo_name = repo_url.split('/')[-1].replace('.git', '')
    # Ensure the parent directory exists
    os.makedirs(os.path.dirname(local_dir), exist_ok=True)
    if not os.path.exists(local_dir):
        # Use double quotes around the path to handle spaces
        run_command(f'gh repo clone {repo_url} "{local_dir}"')
    else:
        os.chdir(local_dir)
        run_command(f'gh repo sync {repo_name} --force')
        os.chdir(base_dir)

# Clone or pull all repositories
clone_or_pull('https://github.com/Jakdee123/ScratchModArchive.git', scratch_dir)
clone_or_pull('https://github.com/PenguinMod/PenguinMod-ExtensionsGallery.git', penguin_dir)
clone_or_pull('https://github.com/TurboWarp/extensions.git', turbo_dir)
clone_or_pull('https://github.com/SharkPool-SP/SharkPools-Extensions.git', shark_dir)

# Function to copy directory contents (merging, overwriting if necessary)
def copy_dir_contents(src, dst):
    if not os.path.exists(dst):
        os.makedirs(dst)
    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dst, item)
        if os.path.isdir(s):
            shutil.copytree(s, d, dirs_exist_ok=True)
        else:
            shutil.copy2(s, d)

# Copy from PenguinMod to ScratchModArchive
copy_dir_contents(os.path.join(penguin_dir, 'static', 'extensions'), os.path.join(scratch_dir, 'static', 'extensions'))
copy_dir_contents(os.path.join(penguin_dir, 'static', 'images'), os.path.join(scratch_dir, 'static', 'images'))

# Copy SVGs from TurboWarp (preserving subfolder structure)
for svg in glob.glob(os.path.join(turbo_dir, '**/*.svg'), recursive=True):
    rel_path = os.path.relpath(svg, turbo_dir)
    dst = os.path.join(scratch_dir, 'static', 'images', rel_path)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(svg, dst)

# Copy .js files from TurboWarp (preserving subfolder structure)
for js in glob.glob(os.path.join(turbo_dir, '**/*.js'), recursive=True):
    rel_path = os.path.relpath(js, turbo_dir)
    dst = os.path.join(scratch_dir, 'static', 'extensions', rel_path)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(js, dst)

# Copy from SharkPools to ScratchModArchive
copy_dir_contents(os.path.join(shark_dir, 'extension-code'), os.path.join(scratch_dir, 'static', 'extensions'))
copy_dir_contents(os.path.join(shark_dir, 'extension-thumbs'), os.path.join(scratch_dir, 'static', 'images'))

# Commit and push changes in ScratchModArchive using gh
os.chdir(scratch_dir)
run_command('git add .')
try:
    run_command('git commit -m "added mods"')
except subprocess.CalledProcessError:
    print("No changes to commit")
run_command('gh repo sync Jakdee123/ScratchModArchive --source')
os.chdir(base_dir)

print("Automation completed successfully!")