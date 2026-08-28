# Neovim configuration

Personal Neovim configuration targeting Neovim 0.12.4+ (Windows oriented).
(Btw, lsp is disabled by default)

## Windows prerequisites

Install [Chocolatey](https://chocolatey.org/install), open PowerShell as Administrator, and install the core tools:
Or Install them one by one through they own installers (choco not always safe option, all up to you)

```powershell
choco install git ripgrep fd cmake make mingw rustup.install 7zip -y
```

What they are used for:

- `git`: bootstraps lazy.nvim, downloads plugins, and powers the Git integrations.
- `ripgrep` (`rg`): Telescope live grep and text search.
- `fd`: fast file discovery used by Telescope when available.
- `make` and MinGW/GCC: compile `telescope-fzf-native.nvim` and Tree-sitter parsers.
- `cmake`: general native-plugin build support and an alternative fzf-native build system. The current config uses `build = "make"`, so CMake alone is not enough.
- Rust/Cargo: installs current Rust CLI tools such as `tree-sitter-cli` and optionally Bob, ripgrep, and fd.
- `7zip`: extracts packages installed by Mason on Windows.

Close and reopen PowerShell after Chocolatey finishes so that the updated `PATH` is visible.

## Neovim 0.12+

Install nvim via their Github Releases installer or install via `choco` (or any other package manager)

Alternatively, manage Neovim versions with [Bob](https://github.com/MordechaiHadad/bob):

```powershell
cargo install cargo-binstall --locked
cargo binstall --no-confirm bob-nvim
bob use latest
```

Do not keep multiple Neovim installations earlier on `PATH`. Verify the selected executable with:

```powershell
Get-Command nvim
nvim --version
```

## Tree-sitter CLI

This config installs parsers through the rewritten `nvim-treesitter`, which requires `tree-sitter-cli` 0.26.1 or later, `tar`, `curl`, and a C compiler. Modern Windows includes `tar` and `curl`; MinGW provides GCC.

Install the current CLI with [cargo-binstall](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md):

```powershell
cargo binstall --no-confirm tree-sitter-cli
```

Fallback when cargo-binstall cannot find a binary:

```powershell
cargo install --locked tree-sitter-cli
```

Do not use Chocolatey's `tree-sitter` package for this config unless it provides version 0.26.1 or later; older releases do not satisfy nvim-treesitter's requirement.

Verify the native toolchain:

```powershell
tree-sitter --version
gcc --version
make --version
cmake --version
tar --version
curl.exe --version
```

## ripgrep and fd alternatives

Chocolatey is the simplest installation method:

```powershell
choco install ripgrep fd -y
```

If Rust is already installed, prebuilt binaries can instead be installed through cargo-binstall:

```powershell
cargo binstall --no-confirm ripgrep
cargo binstall --no-confirm fd-find
```

The executable names must be `rg.exe` and `fd.exe`:

```powershell
rg --version
fd --version
```

## Why fzf-native needs GCC

`telescope-fzf-native.nvim` does not ship a prebuilt DLL. This configuration runs its Makefile, which invokes `gcc` and produces `build/libfzf.dll`. The required Windows combination is therefore:

```text
make.exe + gcc.exe (MinGW)
```

After installing the compiler, rebuild it inside Neovim:

```vim
:Lazy build telescope-fzf-native.nvim
```

See the plugin's [official build instructions](https://github.com/nvim-telescope/telescope-fzf-native.nvim#installation) for the alternative CMake/MSVC workflow.

## Install this configuration

Clone it to Neovim's Windows configuration directory. Back up any existing directory first.

```powershell
git clone https://github.com/SanzharKuandyk/mynvim "$env:LOCALAPPDATA\nvim"
nvim
```

lazy.nvim bootstraps itself on first launch. Useful maintenance commands:

```vim
:Lazy sync
:TSUpdate
:Mason
:checkhealth
```

Mason ensures `clangd` and `lua-language-server`. Other configured language servers start only when their corresponding tools are installed: Zig/ZLS, Odin/OLS, Dart/Flutter, and Vue Language Server.

On Windows, Mason also expects PowerShell, Git, tar, and an archive utility such as 7-Zip. Run `:checkhealth mason` if a tool installation fails. See [Mason's requirements](https://github.com/mason-org/mason.nvim#requirements) for details.

## Optional development tooling

The repository contains Node-based formatting and Git-hook dependencies. They are only needed when developing this configuration:

```powershell
choco install nodejs-lts -y
npm install
```

Install a Nerd Font and select it in the terminal to display file and UI icons correctly.

## Windows drive listing in Oil

New Windows releases no longer provide WMIC, while Oil currently calls it when navigating above a drive root. This repository includes `bin/wmic.cmd`, a narrow compatibility shim that lists drives using built-in .NET APIs. `navigation.lua` exposes the shim to Oil only on Windows and only when a real `wmic` executable is unavailable.

## Quick verification

Run this in a newly opened PowerShell window:

```powershell
Get-Command nvim, git, rg, fd, make, gcc, cmake, tree-sitter
nvim --version
```

If a command is missing after installation, restart the terminal or sign out and back in so Windows rebuilds the process environment.
