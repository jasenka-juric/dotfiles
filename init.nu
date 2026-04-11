#!nu

def main [] {
  let ssh_path = $'($env.USERPROFILE)\.ssh\id_ed25519'

  if not ($ssh_path | path exists) {
      print "Generating SSH key..."
      ^ssh-keygen -a 100 -t ed25519 -f $ssh_path -N ""
  } else {
      print "SSH key already exists, skipping."
  }

  let packages = [
    "ajeetdsouza.zoxide"
    "BurntSushi.ripgrep.GNU"
    "sharkdp.fd"
    "Git.Git"
    "Helix.Helix"
    "Alacritty.Alacritty"
    "Nushell.Nushell"
    "JesseDuffield.lazygit"
    "twpayne.chezmoi"
    "sxyazi.yazi"
    "WireGuard.WireGuard"
    "Brave.Brave"
    "DEVCOM.JetBrainsMonoNerdFont"
    "TeamViewer.TeamViewer"
  ]

  let installed = ( ^winget list --source winget | lines )

  for pkg in $packages {
      if ($installed | any {|line| $line | str contains $pkg }) {
          print $"($pkg) already installed, skipping."
      } else {
          print $"Installing ($pkg)..."
          ^winget install --id $pkg -e --source winget `
            --accept-package-agreements `
            --accept-source-agreements
      }
  }

  let dotfiles_path = $'($env.USERPROFILE)\source\repos\dotfiles'

  if ($dotfiles_path | path exists) {
      print "Initializing chezmoi..."

      let chezmoi_dir = $'($env.USERPROFILE)\.local\share\chezmoi'

      if not ($chezmoi_dir | path exists) {
          ^chezmoi init ssh://git@github.com/jasenka-juric/dotfiles --source $dotfiles_path
      } else {
          print "chezmoi already initialized, skipping init."
      }

      ^chezmoi apply
  } else {
      print $"Dotfiles repo not found at ($dotfiles_path)"
  }
}

