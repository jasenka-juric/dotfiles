$sshPath = "$env:USERPROFILE.ssh\id_ed25519"

if (!(Test-Path $sshPath)) {
  Write-Host "Generating SSH key..."
  ssh-keygen -a 100 -t ed25519 -f $sshPath -N ""
} else {
  Write-Host "SSH key already exists, skipping."
}

$packages = @(
  "ajeetdsouza.zoxide",
  "BurntSushi.ripgrep.GNU",
  "sharkdp.fd",
  "Git.Git",
  "Helix.Helix",
  "Alacritty.Alacritty",
  "Nushell.Nushell",
  "jesseduffield.lazygit",
  "twpayne.chezmoi",
  "sxyazi.yazi",
  "WireGuard.WireGuard",
  "Brave.Brave"
)

foreach ($pkg in $packages) {
  Write-Host "Installing $pkg..."
  winget install --id $pkg -e --source winget --accept-package-agreements --accept-source-agreements
}

$dotfilesPath = "$env:USERPROFILE\source\repos\dotfiles"

if (Test-Path $dotfilesPath) {
  Write-Host "Initializing chezmoi with existing repo..."
  chezmoi init ssh://git@github.com/jasenka-juric/dotfiles --source $dotfilesPath
  chezmoi apply
} else {
  Write-Host "Dotfiles repo not found at $dotfilesPath"
}
