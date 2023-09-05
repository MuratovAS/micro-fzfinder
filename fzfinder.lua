VERSION = "0.1.0"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")
local shell = import("micro/shell")

local  fzfarg = config.GetGlobalOption("fzfarg")
local fzfopen = config.GetGlobalOption("fzfopen")

function fzfinder(bp)
  if fzfarg == nil then
    fzfarg = ""
  end

  if fzfopen == nil then
    fzfopen = "thispane"
  elseif fzfopen == "hsplit" or fzfopen == "vsplit" or fzfopen == "newtab" then
    fzfarg = "-m "..fzfarg
  end

  local output, err = shell.RunInteractiveShell("fzf "..fzfarg, false, true)
  if err ~= nil then
    micro.InfoBar():Error(err)
  else
    fzfOutput(output, {bp})
  end

end

function fzfOutput(output, args)
   local bp = args[1]

   if output ~= "" then
      for file in output:gmatch("[^\r\n]+") do
         if fzfopen == "newtab" then
            bp:NewTabCmd({file})
         else
            local buf, err = buffer.NewBufferFromFile(file)
            if fzfopen == "vsplit" then
               bp:VSplitIndex(buf, true)
            elseif fzfopen == "hsplit" then
               bp:HSplitIndex(buf, true)
            else
               bp:OpenBuffer(buf)
            end
         end
      end
   end
end

function init()
  config.MakeCommand("fzfinder", fzfinder, config.NoComplete)
end
