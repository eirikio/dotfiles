# dotfiles

Personal Windows + WSL development environment setup. One-command bootstrap for a full dev machine.

## What you get

### Windows Applications
| App | Installed via |
|-----|--------------|
| PowerShell 7 | winget |
| VS Code | winget |
| Spotify | winget |
| Oh My Posh | winget |
| Git | winget (if missing) |

> **Note:** Brave, Discord, WinRAR, SteelSeries GG, OBS, and Microsoft PowerToys are listed in the script but commented out — uncomment in `Scripts/bootstrap-windows.ps1` to include them.

### PowerShell Modules
* `posh-git` — Git status in prompt
* `Terminal-Icons` — File/folder icons in terminal
* `PSWebSearch` — Web search from CLI
* `PSReadLine` — Syntax highlighting, history search, smart tab completion

### WSL / Linux Packages
* `zsh`, `git`, `curl`, `wget`, `build-essential`
* `fzf`, `ripgrep`, `bat` — fuzzy finder, fast search, better cat
* `figlet`, `toilet`, `jp2a` — ASCII art for the greeting
* `jq`, `unzip`, `wslu`

### Node.js Toolchain (via NVM)
* NVM (Node Version Manager)
* Node.js LTS
* npm + pnpm + TypeScript (global)

### VS Code Extensions
* `esbenp.prettier-vscode` — Prettier formatter
* `dbaeumer.vscode-eslint` — ESLint
* `bradlc.vscode-tailwindcss` — Tailwind CSS IntelliSense
* `dsznajder.es7-react-js-snippets` — React/JS snippets
* `pulkitgangwar.nextjs-snippets` — Next.js snippets
* `prisma.prisma` — Prisma ORM support
* `donjayamanne.githistory` + `mhutchie.git-graph` — Git history
* `github.copilot` + `github.copilot-chat` — GitHub Copilot
* `mikestead.dotenv` — .env file support
* `ms-vscode.live-server` + `ritwickdey.liveserver` — Live Server
* `ms-vscode.powershell` — PowerShell support
* `ms-vscode-remote.remote-wsl` — WSL remote dev
* `mtxr.sqltools` — SQL client
* `pkief.material-icon-theme` — Material icons
* `sleistner.vscode-fileutils` — File operations
* `aaron-bond.better-comments` — Color-coded comments
* `rvest.vs-code-prettier-eslint` — Prettier + ESLint integration
* `tonybaloney.vscode-pets` — VS Code pets
* `aic.docify` — Docs generation

### Zsh Plugins (Oh My Zsh)
* `zsh-autosuggestions` — Fish-style command suggestions
* `zsh-syntax-highlighting` — Real-time syntax highlighting (with `rm -rf` warning)
* `ohmyzsh-full-autoupdate` — Auto-update all plugins
* `git`, `github`, `gitignore`, `history-substring-search`
* `nvm`, `node`, `npm`, `docker`, `deno`
* `vscode`, `sudo`, `web-search`, `z`, `extract`, `adb`

### Windows Settings Tweaks
* Long paths enabled
* File extensions always visible
* Explorer opens to "This PC" by default
* Classic right-click context menu
* Hibernate disabled
* Taskbar Start button moved to the left (classic layout)
* Disables: Windows Media Player, XPS Document Writer, WorkFolders
* Enables: Windows Sandbox
* Creates `C:\Workspaces`

### Style & Theming
* **Oh My Posh** — Space theme (Windows terminal prompt)
* **Oh My Zsh** — `af-magic` theme (Zsh prompt)
* **Inconsolata Nerd Font**
* **Windows Terminal** — custom `settings.json` (WSL Ubuntu as default profile)
* **VS Code** — Prettier as default formatter, Material Icon Theme, Inconsolata Nerd Font in terminal

### Shell Aliases & Functions

**Zsh (`.zshrc`):**
| Alias / Function | Description |
|-----------------|-------------|
| `znano` | Edit `.zshrc` in nano |
| `zcode` | Edit `.zshrc` in VS Code |
| `zsource` | Reload `.zshrc` |
| `bat` | `batcat` (Debian package alias) |
| `commands` | Open HTML cheatsheet in browser |
| `publish` | Run `publish-to-git-from-cli.sh` |
| `gowindows` | `cd` to Windows home via `/mnt/c/Users/` |
| `pwsh()` | Open PowerShell in Windows home dir |
| `aliases()` | Print list of available aliases |
| `rebuildhistory()` | Repair corrupted `.zsh_history` |
| `typer()` | Typewriter-style text output |
| `gm_message` | Greeting banner on shell startup |

**PowerShell profile:**
| Function | Description |
|----------|-------------|
| `wslhome` | Open WSL home in current window |
| `workspace` | Navigate to `C:\Workspaces` |

### Git Config (`.gitconfig`)
* `git ac "message"` — `add -A` + `commit -m`
* `git acp "message"` — `add -A` + `commit -m` + `push`
* Default branch: `main`
* Git LFS enabled

### CheatSheet
An HTML cheatsheet page copied to `~/CheatSheet/` (Windows) — open with `commands` alias in Zsh.

### publish-to-git-from-cli.sh
A shell script placed at `~/Workspace/Scripts/terminal-scripts/publish-to-git-from-cli/` for quick git add/commit/push from the CLI.

---

## Installation

### Windows bootstrap (run once, no admin needed)

1. Open PowerShell and download the repo:
```powershell
curl -L -o "C:\Users\$env:USERNAME\Downloads\dotfiles-main.zip" https://github.com/eirikio/dotfiles/archive/refs/heads/main.zip
```
```powershell
Expand-Archive -Force "C:\Users\$env:USERNAME\Downloads\dotfiles-main.zip" "C:\Users\$env:USERNAME"
```
```powershell
Rename-Item -Path "C:\Users\$env:USERNAME\dotfiles-main" -NewName "dotfiles"
```

2. Run the bootstrap:
```powershell
powershell.exe -ExecutionPolicy Bypass -File .\dotfiles\master-user-bootstrap.ps1
```

This installs Spotify, Oh My Posh, and Git, then schedules the admin bootstrap to run after a reboot and restarts your PC.

3. After reboot, the admin bootstrap runs automatically — it elevates and runs `Scripts/bootstrap-windows.ps1` (installs apps, modules, applies all Windows tweaks and style settings).

### WSL bootstrap (run manually after Windows setup)

Open WSL (Ubuntu) and run:
```bash
bash ~/dotfiles/Scripts/bootstrap-wsl.sh
```

This installs all Linux packages, Oh My Zsh + plugins, NVM/Node, VS Code extensions, copies `.zshrc` and `.gitconfig`, and sets Zsh as the default shell.

---

## Bootstrap flow

```
master-user-bootstrap.ps1   ← run this first (no admin)
  └─ Installs: Spotify, Oh My Posh, Git
  └─ Clones dotfiles repo
  └─ Schedules admin task → reboots

master-admin-bootstrap.ps1  ← runs automatically after reboot (elevated)
  └─ Scripts/bootstrap-windows.ps1
       └─ Installs: PowerShell 7, VS Code
       └─ Installs: PS modules
       └─ Applies: Windows tweaks, themes, profiles

Scripts/bootstrap-wsl.sh    ← run manually in WSL
  └─ Installs: Linux packages, Oh My Zsh, NVM/Node
  └─ Copies: .zshrc, .gitconfig
  └─ Installs: VS Code extensions, VS Code settings
```

## Repository structure

```
dotfiles/
├── master-user-bootstrap.ps1     # Entry point (non-admin)
├── master-admin-bootstrap.ps1    # Post-reboot admin stage
├── .zshrc                        # Zsh config for WSL
├── .gitconfig                    # Git aliases and config
├── publish-to-git-from-cli.sh    # Quick git publish script
├── Scripts/
│   ├── bootstrap-windows.ps1     # Windows apps, modules, tweaks
│   ├── bootstrap-wsl.sh          # WSL/Linux full setup
│   └── schedule-reboot-tasks.ps1 # Schedules post-reboot tasks
├── powershell/
│   └── Microsoft.PowerShell_profile.ps1
├── style-settings/
│   ├── oh-my-posh/.space.omp.json
│   ├── terminal/settings.json    # Windows Terminal config
│   └── vscode/settings.json      # VS Code settings
└── CheatSheet/
    └── index.html                # CLI cheatsheet
```
