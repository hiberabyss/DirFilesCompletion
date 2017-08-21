if exists('g:dir_file_complete_loaded')
	finish
endif

let g:dir_file_complete_loaded = 1

function! OpenFile(filepath, args)
	let cmd = ":tabnew"
	if len(a:args) > 0
		let cmd = join(a:args)
	endif
	execute(cmd ." ". a:filepath)
endfunction

function! DirFileCompletionList(lead, cmdline, ...) abort
	let cmd = split(a:cmdline)[0]
	if has_key(g:dir_file_completion, cmd)
		let complete_dir = g:dir_file_completion[cmd].dir
	endif

	return map(split(globpath(complete_dir, a:lead . '*'), '\n'), 'fnamemodify(v:val, ":t:r")')
endfunction

function! GotoDirItem(cmdname, ...)
	if !has_key(g:dir_file_completion, a:cmdname)
		echoerr printf('Could not find %s setting!', a:cmdname)
	endif

	let completion_entry = g:dir_file_completion[a:cmdname]
	let dir = completion_entry.dir
	let extension = completion_entry.extension

	let filepath = printf("%s/%s%s", dir, a:1, extension)
	call OpenFile(filepath, a:000[1:])

	if !has_key(completion_entry, 'handler') | return | endif
	execute(printf("call %s('%s')", completion_entry.handler, filepath))
endfunction

function! DefineDirFileCompletionCommand()
	if !exists('g:dir_file_completion') | return | endif

	for cmd in keys(g:dir_file_completion)
		execute(printf("command! -nargs=+ -bar -complete=customlist,DirFileCompletionList %s call GotoDirItem('%s', <f-args>)", cmd, cmd))
		if has_key(g:dir_file_completion[cmd], 'keymap')
			execute(printf('nmap %s :%s ', g:dir_file_completion[cmd].keymap, cmd))
		endif
	endfor
endfunction

call DefineDirFileCompletionCommand()
