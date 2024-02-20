README
======
find local keywords ordered by distance cause what you define you're most
likely to use again. So this saves a lot of typing

Implementations:
    lua/cmp-qad-regex-vim.lua
    lua/cmp-qad-regex-ruby.lua
    lua/cmp-qad-regex-typescipt.lua
    lua/cmp-qad-regex-javascript.lua
    lua/cmp-qad-regex-php.lua
    lua/cmp-qad-regex-python.lua
    lua/cmp-qad-regex-lua.lua

Example usage:

```lua
local sources = {}

-- register sources you want
local qd_langs = {"lua", "python", "ruby", "vim", "php", "javascript", "typescript"}
for i, v in ipairs(qd_langs) do
   require('cmp').register_source(v .. '_local_keywords', require('cmp-qad-regex-' ..  v))
   -- using high priority
   table.insert(sources, { name = v .. '_local_keywords', max_item_count = 8, priority = 20} )
end

cmp.setup({
  performance = { fetching_timeout = 150, },
  completion = {
    autocomplete = {
      types.cmp.TriggerEvent.TextChanged,
      types.cmp.TriggerEvent.InsertEnter,
    },
    completeopt = 'menu,menuone,noselect',
    keyword_pattern = [[\k\+]]
  },
  matching = {
    disallow_partial_fuzzy_matching = true,
    disallow_fuzzy_matching = true
  },
  sorting = {
    comparators = {
      require 'cmp-qad-compare'
      -- important to preserver order for same score eg local ..
      -- compare.score,
    }
  },
  sources = sources
  }
})
```

TESTING
=======
Copy paste the comments into a /tmp/x.y file
Open editor, use completion and check that all N[x] identifiers were found

ROADMAP
=======
[ ] add test suite and extract the sample files into files so that testing is easier


IDEAS FOR FUTURE
=================
Ues treesitter instead?
  Eg see https://github.com/ray-x/cmp-treesitter
  See https://github.com/ray-x/cmp-treesitter/issues/14
  Preserving order is missing to get same usefulness


Treesitter based completions
============================
Eg continue within while / repeat and if () .. condition ?

Eventually use parser rather than regex cause they are ery limited in lua (yet
seems to get the job done reasonably well to be useful for the languages above)
