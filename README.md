# Wiki Sync Vim Plugin

A Vim plugin for synchronizing your personal wiki using Git. This plugin is designed to work with [wiki.vim](https://github.com/lervag/wiki.vim) and provides automatic syncing capabilities to keep your wiki up-to-date with a Git repository.

## Features

- **Automatic Pulling**: Automatically pulls changes from the remote Git repository when opening or switching buffers.
- **Auto-Commit**: Commits changes to the Git repository automatically on file save.
- **Push Changes**: Pushes local commits to the remote repository when exiting Vim.
- **Taskwarrior Integration**: Optionally syncs with Taskwarrior if enabled.
- **Configurable Git Branch**: Allows you to specify which Git branch to sync with.

## Installation

### Prerequisites

- Vim or Neovim
- Git
- [wiki.vim](https://github.com/lervag/wiki.vim)

### Manual Installation

1. Clone this repository into your Vim plugin directory:
   ```bash
   git clone https://github.com/yourusername/wiki-sync-vim-plugin.git ~/.vim/pack/plugins/start/wiki-sync-vim-plugin
   ```

2. Add the following line to your .vimrc or init.vim:

   let g:wiki_root = '~/wiki'  " Set your wiki directory here

3. Source the plugin in your .vimrc or init.vim:

   runtime! pack/plugins/start/wiki-sync-vim-plugin/plugin/wiki_sync.vim

## Configuration

You can customize the following variables in your .vimrc:

    g:wiki_root: The root directory of your wiki (default: ~/wiki).
    g:wiki_sync_branch: The Git branch to use for synchronization (default: HEAD).
    g:sync_taskwarrior: Set to 1 to enable Taskwarrior synchronization (default: 1).
    g:wiki_sync_commit_message: The commit message format for auto-commits (default: 'Auto commit + push. %c').

## Usage

    Open a file in your wiki directory with Vim.
    The plugin will automatically pull changes from the remote repository.
    Make changes to your files and save them. The plugin will automatically commit the changes.
    When you exit Vim, the plugin will push any local commits to the remote repository.

## Troubleshooting

    Ensure that your g:wiki_root is set correctly and points to a valid Git repository.
    Check the output messages in Vim for any errors during Git operations.
    Use git status in your wiki directory to check the current state of the repository.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

