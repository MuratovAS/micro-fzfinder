VERSION = "0.1.0"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")
local shell = import("micro/shell")

local fzfArg =  config.GetGlobalOption("fzfarg")
local fzfCmd =  config.GetGlobalOption("fzfcmd")
local fzfOpen = config.GetGlobalOption("fzfopen")

function fzfinder(bp)
  if fzfArg == nil then
    fzfArg = "";
  end

  if fzfOpen == nil then
    fzfOpen = "thispane"
  elseif fzfOpen == "hsplit" or fzfOpen == "vsplit" or fzfOpen == "newtab" then
    fzfArg = "-m "..fzfArg
  end

  local output, err

  if fzfCmd == nil then
     output, err = shell.RunInteractiveShell("fzf".." "..fzfArg, false, true)
  else
     output, err = shell.RunInteractiveShell("sh -c '"..fzfCmd.." ".."| fzf".." "..fzfArg.."'", false, true)
  end

  if err == nil then
    fzfOutput(output, {bp})
  end
end

function fzfOutput(output, args)
   local bp = args[1]

   if output ~= "" then
      for file in output:gmatch("[^\r\n]+") do
         if fzfOpen == "newtab" then
            bp:NewTabCmd({file})
         else
            local buf, err = buffer.NewBufferFromFile(file)
            if fzfOpen == "vsplit" then
               bp:VSplitIndex(buf, true)
            elseif fzfOpen == "hsplit" then
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
