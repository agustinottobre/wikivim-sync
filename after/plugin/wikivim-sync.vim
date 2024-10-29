augroup wiki_sync
  autocmd!

  " Initialize synchronization variables
  if !exists('g:zettel_synced')
    let g:zettel_synced = 0
  endif

  " Set the wiki root directory
  if !exists('g:wiki_root')
    let g:wiki_root = expand('~/wiki')  " Ensure the path is expanded
  endif

  " Make the Git branch used for synchronization configurable
  if !exists('g:wiki_sync_branch')
    let g:wiki_sync_branch = "HEAD"
  endif

  " Enable disabling of Taskwarrior synchronization
  if !exists("g:sync_taskwarrior")
    let g:sync_taskwarrior = 1
  endif

  " Get the current file's directory
  let current_dir = expand("%:p:h")

  " Check if the current file is within the wiki directory
  if !current_dir ==# fnamemodify(g:wiki_root, ":h")
    finish
  endif

  " Set the commit message for Git
  if !exists('g:wiki_sync_commit_message')
    let g:wiki_sync_commit_message = 'Auto commit + push. %c'
  endif

  " Function to execute Git commands
  function! s:git_action(action)
    execute ':silent !' . a:action
    redraw!
  endfunction

  " Callback for when the Git job exits
  function! My_exit_cb(channel, msg)
    echom "[wiki sync] Sync done"
    execute 'checktime'
  endfunction

  " Pull changes from the Git repository
  function! s:pull_changes()
    if g:zettel_synced == 0
      echom "[wiki sync] pulling changes"
      let g:zettel_synced = 1

      let gitCommand = "git -C " . g:wiki_root . " pull --rebase origin " . g:wiki_sync_branch
      let s:gitCallbacks = {"exit_cb": "My_exit_cb"}

      if has("nvim")
        call jobstart(gitCommand, s:gitCallbacks)
      else
        call job_start(gitCommand, s:gitCallbacks)
      endif

      " Sync Taskwarrior if enabled
      if g:sync_taskwarrior == 1
        call jobstart("task sync")
      endif
    else
      echom "[wiki sync] Already synced."
    endif
  endfunction

  " Push changes to the Git repository
  function! s:push_changes()
    let gitCommand = "git -C " . g:wiki_root . " push origin " . g:wiki_sync_branch
    call jobstart(gitCommand)
  endfunction

  " Auto-sync changes at the start
  au! VimEnter * call <sid>pull_changes()
  au! BufRead * call <sid>pull_changes()
  au! BufEnter * call <sid>pull_changes()

  " Auto-commit changes on each file write
  au! BufWritePost * call <sid>git_action("git -C " . g:wiki_root . " add . ; git -C " . g:wiki_root . " commit -m \"" . strftime(g:wiki_sync_commit_message) . "\"")

  " Push changes on Vim leave
  au! VimLeave * call <sid>git_action("[ $(git -C " . g:wiki_root . " rev-list @{u}..@ --count) = 0 ] && : || git -C " . g:wiki_root . " push origin " . g:wiki_sync_branch)

  " Optional: Fetch changes on focus lost
  au! FocusLost * call <sid>git_action("git -C " . g:wiki_root . " fetch")
augroup END

