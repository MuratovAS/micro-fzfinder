VERSION = "0.1.0"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")
local shell = import("micro/shell")

local fzfArg =  config.GetGlobalOption("fzfarg")
local fzfCmd =  config.GetGlobalOption("fzfcmd")

function fzfinder(bp)
  if fzfArg == nil then
    fzfArg = "";
  end
  if fzfCmd == nil then
     fzfCmd = "fzf";
  end
  
  local output, err = shell.RunInteractiveShell(fzfCmd.." "..fzfArg, false, true)
  if err == nil then
    fzfOutput(output, {bp})
  end

end

function fzfOutput(output, args)
  local bp = args[1]
  local strings = import("strings")
  output = strings.TrimSpace(output)
  if output ~= "" then
    local buf, err = buffer.NewBufferFromFile(output)
    if err == nil then
      bp:OpenBuffer(buf)
    end
  end
end

function init()
  config.MakeCommand("fzfinder", fzfinder, config.NoComplete)
end