-- Minimal single-buffer "agent chat" skeleton.
-- Pattern: one read-only buffer for everything. Motions/visual/yank work freely.
-- Pressing `i`/`a`/`o` jumps to the input zone at the bottom and unlocks the
-- buffer just long enough for you to type. Submitting locks it again and
-- appends the user message + a streamed "agent" reply.

local M = {}

local NS = vim.api.nvim_create_namespace 'agent_chat'

local state = {
  buf = nil,
  win = nil,
  input_start = 0, -- 0-indexed line where the editable input zone begins
}

-- Run `fn` with the buffer temporarily writable, then restore.
local function with_writable(buf, fn)
  vim.bo[buf].modifiable = true
  local ok, err = pcall(fn)
  if vim.fn.mode() ~= 'i' then
    vim.bo[buf].modifiable = false
  end
  if not ok then error(err) end
end

-- Highlight everything from input_start to end of buffer as the "input zone".
local function highlight_input_zone()
  vim.api.nvim_buf_clear_namespace(state.buf, NS, 0, -1)
  local last = vim.api.nvim_buf_line_count(state.buf) - 1
  for ln = state.input_start, last do
    vim.api.nvim_buf_set_extmark(state.buf, NS, ln, 0, {
      end_row = ln + 1,
      hl_eol = true,
      hl_group = 'AgentChatInputBg',
      priority = 100,
    })
  end
end

local function scroll_to_bottom()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    local last = vim.api.nvim_buf_line_count(state.buf)
    pcall(vim.api.nvim_win_set_cursor, state.win, { last, 0 })
  end
end

local function create_buf()
  local buf = vim.api.nvim_create_buf(false, true) -- unlisted, scratch
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].swapfile = false
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].filetype = 'agentchat'
  vim.api.nvim_buf_set_name(buf, 'agent://chat')
  state.buf = buf

  with_writable(buf, function()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
      '── Agent Chat ─────────────────────────────',
      '  i = type   <C-Enter> or <C-j> = send   q = close',
      '',
      '', -- input zone starts here
    })
  end)
  state.input_start = 3
  highlight_input_zone()

  -- Buffer-local keymaps. We intercept the "enter insert" keys so they always
  -- land in the input zone, never in the history.
  local opt = { buffer = buf, silent = true, nowait = true }
  for _, key in ipairs { 'i', 'a', 'o', 'I', 'A' } do
    vim.keymap.set('n', key, function() M.enter_input() end, opt)
  end
  vim.keymap.set({ 'i', 'n' }, '<C-CR>', function() M.submit() end, opt)
  vim.keymap.set({ 'i', 'n' }, '<C-j>', function() M.submit() end, opt) -- universal fallback (ASCII line feed)
  vim.keymap.set('n', 'q', function() M.close() end, opt)

  -- Re-lock the buffer the instant the user leaves insert mode.
  vim.api.nvim_create_autocmd('InsertLeave', {
    buffer = buf,
    callback = function() vim.bo[buf].modifiable = false end,
  })

  return buf
end

function M.enter_input()
  vim.api.nvim_win_set_cursor(state.win, { state.input_start + 1, 0 })
  vim.bo[state.buf].modifiable = true
  vim.cmd 'startinsert!'
end

function M.submit()
  local input = vim.api.nvim_buf_get_lines(state.buf, state.input_start, -1, false)
  local text = vim.trim(table.concat(input, '\n'))
  if text == '' then return end

  vim.cmd 'stopinsert'

  local SEP = string.rep('─', 50)
  with_writable(state.buf, function()
    -- wipe input zone
    vim.api.nvim_buf_set_lines(state.buf, state.input_start, -1, false, {})
    -- append user block + assistant header + empty line to stream into
    local lines = { '', SEP, 'user:', '' }
    for _, l in ipairs(vim.split(text, '\n')) do
      table.insert(lines, l)
    end
    vim.list_extend(lines, { '', SEP, 'assistant:', '', '' })
    vim.api.nvim_buf_set_lines(state.buf, -1, -1, false, lines)
  end)

  local stream_line = vim.api.nvim_buf_line_count(state.buf) - 1
  M.stream_fake_reply(text, stream_line)
end

-- Pretend to be a streaming LLM: emit one token per timer tick into `target_line`.
-- Swap this for an actual HTTP/SSE call later — same shape: write token, repeat.
function M.stream_fake_reply(user_text, target_line)
  -- Strip any newlines from user_text before interpolating — nvim_buf_set_lines
  -- rejects replacement strings that contain '\n'.
  local clean = user_text:gsub('[\n\r]+', ' ')
  local reply = ('I heard: "%s". This is a streamed reply appearing token by token to show how the buffer updates while a response is in-flight.'):format(clean)
  local tokens = vim.split(reply, ' ')
  local idx = 1
  local timer = vim.uv.new_timer()

  timer:start(80, 40, vim.schedule_wrap(function()
    if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
      timer:stop()
      timer:close()
      return
    end

    if idx > #tokens then
      timer:stop()
      timer:close()
      -- stream done: append blank line + fresh input zone, re-highlight, lock
      with_writable(state.buf, function()
        vim.api.nvim_buf_set_lines(state.buf, -1, -1, false, { '', '' })
      end)
      state.input_start = vim.api.nvim_buf_line_count(state.buf) - 1
      highlight_input_zone()
      scroll_to_bottom()
      return
    end

    with_writable(state.buf, function()
      local existing = vim.api.nvim_buf_get_lines(state.buf, target_line, target_line + 1, false)[1] or ''
      local sep = existing == '' and '' or ' '
      -- Defensive: strip any stray newlines from the token so set_lines never errors.
      local tok = tokens[idx]:gsub('[\n\r]+', ' ')
      vim.api.nvim_buf_set_lines(state.buf, target_line, target_line + 1, false, { existing .. sep .. tok })
    end)
    scroll_to_bottom()
    idx = idx + 1
  end))
end

function M.open()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    create_buf()
  end
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_set_current_win(state.win)
    return
  end

  vim.cmd 'botright vsplit'
  state.win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.win, state.buf)
  vim.api.nvim_win_set_width(state.win, 60)
  vim.wo[state.win].number = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].signcolumn = 'no'
  vim.wo[state.win].wrap = true
  vim.wo[state.win].linebreak = true
end

function M.close()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

function M.setup(opts)
  opts = opts or {}
  vim.api.nvim_set_hl(0, 'AgentChatInputBg', { bg = '#2a2438', default = true })
  vim.api.nvim_create_user_command('AgentChat', function() M.open() end, { desc = 'Open agent chat' })
  vim.api.nvim_create_user_command('AgentChatClose', function() M.close() end, { desc = 'Close agent chat' })
  vim.keymap.set('n', '<leader>ac', function() M.open() end, { desc = '[A]gent [C]hat' })
end

return M
