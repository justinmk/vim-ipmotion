" Improved paragraph motion
" Last Change: 2012-02-27
" Maintainer: Luke Ng <kalokng@gmail.com>
" Version: 1.0
" Description:
" A simple utility improve the "{" and "}" motion in normal / visual mode.
" In vim, a blank line only containing white space is NOT a paragraph
" boundary, this utility remap the key "{" and "}" to handle that.
"
" The utility uses a custom regexp to define paragraph boundaries, the
" matched line will be treated as paragraph boundary.
" Note that the regexp will be enforced to match from the start of line, to
" avoid strange behaviour when moving.
"
" It supports in normal and visual mode, and able to handle with count. It
" also support redefine the regexp for boundary, or local definition of
" boundary.
"
" Install:
" Simply copy the file to plugin folder and restart vim.
"
" If you do not know where to place it,
" check with "USING A GLOBAL PLUGIN" under :help standard-plugin
"
" Without any setting, it will treat empty line (with or without space) as
" paragraph boundary.
"
" Configuration Variables:
" g:ip_skipfold     Set as 1 will make the "{" and "}" motion skip paragraph
"                   boundaries in closed fold.
"                   Default is 0.
"
" g:ip_boundary     The global definition of paragraph boundary.
"                   Default value is "\s*$".
"                   It can be changed in .vimrc or anytime. Defining
"                   b:ip_boundary will override this setting.
"
"                   Example:
"                       :let g:ip_boundary = '"\?\s*$'
"                   Setting that will make empty lines, and lines only
"                   contains '"' as boundaries.
"
"                   Note that there is no need adding a "^" sign at the
"                   beginning. It is enforced by the script.
"
" b:ip_boundary     Local definition of paragraph boundary. It will override
"                   g:ip_boundary if set. Useful when customize boundary for
"                   local buffer or only apply to particular file type.
"                   Default is unset.

if exists('g:loaded_ipmotion')
	finish
endif
let g:loaded_ipmotion = 1

if !exists('g:ip_boundary')
	let g:ip_boundary='\s*$'
endif
if !exists('g:ip_skipfold')
	let g:ip_skipfold=0
endif

nnoremap <silent> { :<C-U>call <SID>ParagBack()<CR>
nnoremap <silent> } :<C-U>call <SID>ParagFore()<CR>
vnoremap <silent> { :<C-U>exe "normal! gv"<Bar>call <SID>ParagBack()<CR>
vnoremap <silent> } :<C-U>exe "normal! gv"<Bar>call <SID>ParagFore()<CR>

function! s:Unfold()
	while foldclosed('.') > 0
		normal za
	endwhile
endfunction

function! <SID>ParagBack()
	let l:boundary='^\%('.(exists('b:ip_boundary') ? b:ip_boundary : g:ip_boundary).'\)'
	let l:notboundary=l:boundary.'\@!'
	let l:res = search(l:notboundary, 'scWb')
	if l:res <= 0
		call cursor(1,1)
		return s:Unfold()
	endif
	let l:res = search(l:boundary, 'Wb')
	if l:res <= 0
		call cursor(1,1)
		return s:Unfold()
	endif
	if !g:ip_skipfold || foldclosed('.') < 0
		let l:count = v:count1 - 1
	else
		call cursor(foldclosed('.'), 1)
		let l:count = v:count1
	endif
	while l:count > 0
		let l:res = search(l:notboundary, 'cWb')
		let l:res = search(l:boundary, 'Wb')
		if l:res <= 0
			call cursor(1,1)
			return s:Unfold()
		endif
		if !g:ip_skipfold || foldclosed('.') < 0
			let l:count = l:count - 1
		else
			call cursor(foldclosed('.'), 1)
		endif
	endwhile
	return s:Unfold()
endfunction

function! <SID>ParagFore()
	let l:boundary='^\%('.(exists('b:ip_boundary') ? b:ip_boundary : g:ip_boundary).'\)'
	let l:notboundary=l:boundary.'\@!'
	if getline('.') =~# l:boundary
		let l:res = search(l:notboundary, 'sW')
		if l:res <= 0
			call cursor(line('$'),1)
			return s:Unfold()
		endif
	endif
	let l:res = search(l:boundary, 'W')
	if l:res <= 0
		call cursor(line('$'),1)
		return s:Unfold()
	endif
	if !g:ip_skipfold || foldclosedend('.') < 0
		let l:count = v:count1 - 1
	else
		call cursor(foldclosedend('.'), 1)
		let l:count = v:count1
	endif
	while l:count > 0
		let l:res = search(l:notboundary, 'cW')
		let l:res = search(l:boundary, 'W')
		if l:res <= 0
			call cursor(line('$'),1)
			return s:Unfold()
		endif
		if !g:ip_skipfold || foldclosedend('.') < 0
			let l:count = l:count - 1
		else
			call cursor(foldclosedend('.'), 1)
		endif
	endwhile
	return s:Unfold()
endfunction
