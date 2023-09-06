VERSION = "0.1.0"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")
local shell = import("micro/shell")
local filepath = import("path/filepath")

local fzfArg =  config.GetGlobalOption("fzfarg")
local fzfCmd =  config.GetGlobalOption("fzfcmd")
local fzfOpen = config.GetGlobalOption("fzfopen")

function fzfinder(bp)
  if fzfArg == nil then
    fzfArg = "";
  end

  if fzfCmd == nil then
     fzfCmd = "fzf";
  end
  rootdir = string.gsub(bp.buf.AbsPath, bp.buf.Path, "")
  relative = filepath.Dir(bp.buf.Path)
  toto = rootdir.." | "..relative

  -- os.Chdir(relative)
  -- if string.find(abspath, "usr") then
      -- toto = "/tmp"
   -- else
      -- toto =  "/usr/local/bin"
   -- end
  bp:CdCmd({relative})

  if fzfOpen == nil then
    fzfOpen = "thispane"
  elseif fzfOpen == "hsplit" or fzfOpen == "vsplit" or fzfOpen == "newtab" then
    fzfArg = "-m "..fzfArg
  end

  local output, err = shell.RunInteractiveShell(fzfCmd.." "..fzfArg, false, true)

  -- os.Chdir(abspath)

  if err == nil then
    fzfOutput(output, {bp})
  end

  micro.InfoBar():Error(toto)
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
