augroup wiki_sync
  autocmd!

  " Initialize synchronization variables
  if !exists('g:zettel_synced')
    let g:zettel_synced = 0
  endif

  " Initialize flags for ongoing operations
  if !exists('g:pull_in_progress')
    let g:pull_in_progress = 0
  endif

  if !exists('g:push_in_progress')
    let g:push_in_progress = 0
  endif

  " Set the wiki root directory
  if !exists('g:wiki_root')
    let g:wiki_root = expand('~/wiki')  " Ensure the path is expanded
  endif

  " Make the Git branch used for synchronization configurable
  if !exists('g:wiki_sync_branch')
    let g:wiki_sync_branch = "HEAD"
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
    let g:pull_in_progress = 0
    let g:push_in_progress = 0
  endfunction

  " Pull changes from the Git repository
  function! s:pull_changes()
    if g:pull_in_progress == 0 && g:zettel_synced == 0
      echom "[wiki sync] pulling changes"
      let g:zettel_synced = 1
      let g:pull_in_progress = 1

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
      echom "[wiki sync] Already synced or pull in progress."
    endif
  endfunction

  " Push changes to the Git repository
  function! s:push_changes()
    if g:push_in_progress == 0
      let g:push_in_progress = 1
      let gitCommand = "git -C " . g:wiki_root . " push origin " . g:wiki_sync_branch
      call jobstart(gitCommand)
    else
      echom "[wiki sync] Push already in progress."
    endif
  endfunction

  " Check if the current file is within the wiki directory
  function! s:is_in_wiki_directory()
    return expand("%:p:h") =~# fnamemodify(g:wiki_root, ":p")
  endfunction

  " Auto-sync changes at the start
  au! VimEnter * if s:is_in_wiki_directory() | call <sid>pull_changes() | endif
  au! BufRead * if s:is_in_wiki_directory() | call <sid>pull_changes() | endif
  au! BufEnter * if s:is_in_wiki_directory() | call <sid>pull_changes() | endif

  " Auto-commit changes on each file write
  au! BufWritePost * if s:is_in_wiki_directory() | call <sid>git_action("git -C " . g:wiki_root . " add . ; git -C " . g:wiki_root . " commit -m \"" . strftime(g:wiki_sync_commit_message) . "\"") | endif

  " Push changes on Vim leave
  au! VimLeave * if s:is_in_wiki_directory() | call <sid>push_changes() | endif

  " Optional: Fetch changes on focus lost
  au! FocusLost * if s:is_in_wiki_directory() | call <sid>git_action("git -C " . g:wiki_root . " fetch") | endif

augroup END
