
-- https://gist.github.com/kylechui/a5c1258cd2d86755f97b10fc921315c3
-- https://www.vikasraj.dev/blog/vim-dot-repeat
-- https://github.com/phaazon/hop.nvim/issues/58
-- https://github.com/smoka7/hop.nvim/issues/39

local hop = require("hop")
local builtin_targets = require("hop.jump_target")
local builtin_targets2 = require("hop.jump_regex")

_G._repeated_hop_state = {
  last_chars = nil,
  count = 0,
}

_G._repeatable_hop = function ()
  for i=1,_G._repeated_hop_state.count  do
    hop.hint_with(builtin_targets.jump_target_generator(builtin_targets2.regex_by_case_searching(
      _G._repeated_hop_state.last_chars, true,hop.opts )), 
    hop.opts)
  end
end

hop.setup({})
vim.keymap.set("n", [[f]], 
  function()

      local char
      while true do
        vim.api.nvim_echo({ { "hop 1 char:", "Search" } }, false, {})
        local code = vim.fn.getchar()
        -- fixme: custom char range by needs
        if code >= 61 and code <= 0x7a then
          -- [a-z]
          char = string.char(code)
          break
        elseif code == 0x20 or code == 0x1b then
          -- press space, esc to cancel
          char = nil
          break
        end
      end
      if not char then return end

      -- setup the state to pickup in _G._repeatable_hop
      _G._repeated_hop_state = {
        last_chars = char,
        count = (vim.v.count or 0) + 1
      }

      vim.go.operatorfunc = "v:lua._repeatable_hop"
      -- return this↓ to run that↑
      return "g@l" -- see expr=true
    end , { noremap = true, 
    -- ↓ see "g@l"
    expr = true})
