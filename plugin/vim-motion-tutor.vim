if exists('g:loaded_motion_tutor') | finish | endif
let g:loaded_motion_tutor = 1

let g:vmt_buffer_winheight=winheight(0)
let g:vmt_duration=60
let g:vmt_txt="Helsinki"


" RandInt:
"   @param max
"       upper bound integer value
"   @param min
"       lower bound integer value
"   Returns a random number between max and min integer values.
"
"   see:
"   https://stackoverflow.com/questions/12737977/native-vim-random-number-script
"
"   accessed: 2020-08-09 09:57
function! RandInt(Low, High) abort
    let l:milisec=str2nr(matchstr(reltimestr(reltime()), '\v\.\zs\d+'))
    return l:milisec % (a:High - a:Low + 1) + a:Low
endfunction


" GenerateLineText:
"   Generates text at a random line
function! SetText()
    silent execute 'call setbufline(' .
                \ bufnr('%') . ', ' .
                \ RandInt(1, g:vmt_buffer_winheight) .
                \ ', "Helsinki")'
endfunction

function! Play()
    if getline('.') ==# 'Helsinki'
        execute 'normal! dd'
        execute 'call SetText()'
        let b:motions=b:motions + 1
        echo 'current relative number motions = ' .
                    \ b:motions . ' | elapsed seconds = ' .
                    \ b:duration
    endif
endfunction

""
" EndGame:
"   Ends Game and shows stats.
function! EndGame()
    1,$d
    for i in range(1, g:vmt_buffer_winheight) | call append(line('.'), '') | endfor

    let b:game_stats=b:motions . ' relative number motions in  ' .
                \ b:duration . ' seconds'

    silent execute 'call setbufline(' . bufnr('%') . ', ' . 25 .', "              Game Over!")'
    silent execute 'call setbufline(' . bufnr('%') . ', ' . 27 .','. string(b:game_stats) . ')'
    silent execute 'call setbufline(' . bufnr('%') . ', ' . 29 .', "      Pres CTRL + R to try again")'

    " honor previous vim config and
    " clean up no longer needed au groups
    autocmd! game_auto_cmds
endfunction

""
" UpdateGameBuffer:
"   Implements game timer.
function! UpdateGameBuffer()
    let b:current=str2nr(reltimestr(reltime()))
    let b:duration=b:current - b:start
    if (b:duration >= g:vmt_duration)
        call EndGame()
    else
        call Play()
    endif
endfunc

""
" SetUpGameEnv:
"   Creates relative line numbers for the game.
function! SetLineNumbers()
    if line('$') < g:vmt_buffer_winheight
        call append(line('$'), '')
    endif
endfunc

""
" RelativeNumberMotion: Sets current buffer up with environment
"   for practicing relative number motion.
function! RelativeNumberMotion()
    1,$d

    for i in range(1, g:vmt_buffer_winheight) | call append(line('.'), '') | endfor
    execute 'call SetText()'
    let b:start=str2nr(reltimestr(reltime()))
    let b:motions=0

    augroup game_auto_cmds
        autocmd! * <buffer>
        autocmd CursorMoved <buffer> call SetLineNumbers()
        autocmd CursorMoved <buffer> call UpdateGameBuffer()
    augroup END

endfunc

""
" LaunchTutor:
"  Creates a new term window and launches VIM-MOTION-TUTOR.
"  n.b. Honors the current state vim, i.e., does on not
"  modify any augroups that might affect active buffers
function! LaunchTutor()
    if has('nvim')
        FloatermNew
                    \ --height=0.8
                    \ --width=0.8
                    \ --wintype=floating
                    \ --name=vim_motion_tutor
                    \ nvim -c ':call RelativeNumberMotion()'
    else
        set termwinsize=0x86
        vert term vim -c ':call RelativeNumberMotion()'
    endif

endfunction

" plugins commands
command! -nargs=* Heist :call LaunchTutor(<f-args>)
command! -nargs=* Restart :call RelativeNumberMotion(<f-args>)

" plugin mappings
nnoremap <silent><C-G> :Heist<CR>
nnoremap <silent><C-G><C-R> :Restart<CR>
