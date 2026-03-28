$ErrorActionPreference = "Stop"

$root = (Get-Location).Path
$dest = Join-Path $root "split-repos"

Write-Host "Creating split repos in $dest"
New-Item -ItemType Directory -Force -Path $dest | Out-Null

$repos = @(
  @{ Name = "app-repo"; Path = "app-repo" },
  @{ Name = "infra-repo"; Path = "infra-repo" },
  @{ Name = "gitops-repo"; Path = "gitops-repo" }
)

foreach ($repo in $repos) {
  $src = Join-Path $root $repo.Path
  $dst = Join-Path $dest $repo.Name

  if (-not (Test-Path $src)) {
    Write-Host "Skip missing $src"
    continue
  }

  Write-Host "Copying $src to $dst"
  Copy-Item -Recurse -Force $src $dst

  Push-Location $dst
  if (-not (Test-Path (Join-Path $dst ".git"))) {
    git init | Out-Null
    git add .
    git commit -m "Initial commit" | Out-Null
  }
  Pop-Location
}

Write-Host "Split repos created. Add remotes manually and push."
