std = 'lua5.4'

self = false

files['spec'].std = '+busted'

files['.luacheckrc'].ignore = { '111', '112', '131' }

max_line_length = 90

globals = {
  -- external globals
  'vim',
  'vim.g',
  'vim.o',
  'vim.opt',
  'vim.filetype',
  -- misc,
  '-',
}
