" Vim syntax file
" Language:    Linux source code reference
" Maintainers: Raphael Fikel <raphael@cs.uky.edu>
" Last Change: 2003 Jun 3

syntax reset

syn case match

syn match    LinuxComment      +%.*+
syn match    LinuxID           "\w*_\(\w\|_\)\+"
syn keyword  LinuxKeyword      macro struct type fields states
syn keyword  LinuxKeyword  	     operators trace operations field
syn match    LinuxFileRef      "\w\+/[a-zA-Z][-a-zA-Z0-9./_]\+\(:\d\+\)\?"
syn match    LinuxBookRef      "book [-0-9:]\+"
syn match    LinuxFunctionRef  "\w\+()"
syn match    LinuxStructRef    "struct \w\+"ms=s+7
syn match    LinuxMacroRef     "\(macro\|field\) \w\+"ms=s+6
syn match    LinuxVarRef       "var \w\+"ms=s+4
syn match    LinuxSysCall      "system call \w\+"ms=s+12
syn match    LinuxSysCall      "syscall \w\+"ms=s+8
syn match    LinuxLookForRef   "look for \w\+"ms=s+9
syn region   LinuxQuery        start="\["ms=s+1 end="\]"me=e-1
syn sync ccomment maxlines=50

" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_Linux_syn_inits")
  if version < 508
    let did_Linux_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command! -nargs=+ HiLink hi def link <args>
  endif

" The default highlighting.
    HiLink LinuxComment            Comment
    HiLink LinuxFileRef            Comment
    HiLink LinuxKeyword            Title
    HiLink LinuxBookRef            Question
    HiLink LinuxSysCall	       Title
    HiLink LinuxFunctionRef        Number
    HiLink LinuxStructRef          Number
    HiLink LinuxMacroRef           Number
    HiLink LinuxVarRef             Number
    HiLink LinuxID                 Number
    HiLink LinuxLookForRef         Number
    HiLink LinuxQuery              Comment

  delcommand HiLink
endif

let b:current_syntax = "Linux"

" vim: ts=28
