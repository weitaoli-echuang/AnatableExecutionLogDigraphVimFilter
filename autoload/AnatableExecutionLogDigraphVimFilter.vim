if exists('g:AnatableExecutionLogDigraphVimFilter')
  finish
endif
let g:AnatableExecutionLogDigraphVimFilter= 1

function! s:RemoveShaderProgram()
    execute 'normal! G' 
    execute '?```' 
    execute 'normal! dG'
    execute 'normal! G'
    execute '?```'
    execute 'normal! dgg'
    execute 'g/^vs_/d'
    execute 'g/^fs_/d'
    execute 'g/^gs_/d'
    execute 'g/^cs_/d'
    execute 'g/^tcs_/d'
    execute 'g/^tes_/d'
    execute 'g/_program/d'
    execute 'g/_component/d'
    execute 'g/^Cut/d'
    execute 'g/QRCode/d'
    execute 'g/qrcode/d'
    execute 'normal! gg'
endfunction

function! s:TrimSpace(content)
    let l:result = substitute(a:content,'^\s\+','','')
    let l:result = substitute(l:result,'\s\+$','','')
    return l:result
endfunction

function! s:RemoveOneRefLeaf()
    "nodes dependents
    let l:node_deps = {}
    "nodes is dependented on
    let l:node_is_dep_on = {}
    "all nodes
    let l:nodes = {}
    " Get the total number of lines in the buffer
    let l:line_count = line('$')

    " Loop through each line from the current line to the end
    for l:lnum in range(line('.'), l:line_count)
        " Read the current line
        let l:current_line = getline(l:lnum)

        " Split the line by '->'
        let l:parts = split(l:current_line, '->')

        " Check if the split resulted in at least two parts
        if len(l:parts) >= 2
            "l:parts[0] dependents l:parts[1], so l:parts[0] is not leaf
            let l:key = s:TrimSpace(l:parts[0])
            let l:node_deps[l:key]=1
            let l:nodes[l:key]=1

            let l:key = s:TrimSpace(l:parts[1])
            let l:nodes[l:key]=1

            if has_key(l:node_is_dep_on,l:key)
                let l:node_is_dep_on[l:key] = l:node_is_dep_on[l:key]+1
            else
                let l:node_is_dep_on[l:key] = 1
            endif
        endif
    endfor

    "for l:key in keys(l:node_is_dep_on)
    "    echo l:key . ' ' . l:node_is_dep_on[l:key]
    "endfor

    " find leaf node which will be delete
    let l:remove_keys = {}
    for l:key in keys(l:nodes)
        if !has_key(l:node_deps,l:key) && l:node_is_dep_on[l:key] == 1
            let l:remove_keys[l:key]=1
        endif
    endfor

    " in reverse order to delete line which contains node that will be deleted
    for l:lnum in reverse(range(1, l:line_count))
        " Get the content of the current line
        let l:current_line = getline(l:lnum)

        " Split the line by '->'
        let l:parts = split(l:current_line, '->')

        " Check if the split resulted in at least two parts
        if len(l:parts) >= 2
            "remove leaf dependents 
            let l:key = s:TrimSpace(l:parts[1])
            if has_key(l:remove_keys,l:key)
                execute lnum . 'delete'
            endif
        else
            "remove leaf node 
            let l:parts = split(l:current_line,"[")
            if len(l:parts)>=2
                let l:key = s:TrimSpace(l:parts[0])
                if has_key(l:remove_keys,l:key)
                    execute lnum . 'delete'
                endif
            endif
        endif
    endfor
endfunction

function! DigraphFilter#execution()
  call s:RemoveShaderProgram()
  call s:RemoveOneRefLeaf()
endfunction

