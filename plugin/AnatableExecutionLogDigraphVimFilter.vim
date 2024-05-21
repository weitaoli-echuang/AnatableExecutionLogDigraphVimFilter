command! -nargs=0 DigraphFilter call AnatableExecutionLogDigraphVimFilter#execution()
xnoremap <silent> <Plug>(DigraphFilter) :DigraphFilter<CR>
