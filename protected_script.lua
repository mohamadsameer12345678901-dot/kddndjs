--[[ ASTA Pro v1 — Premium Edition ]]
--[[
  PAID_MODE = true  → يطلب كي من المشتري (string match بسيط)
  PAID_MODE = false → يشتغل بدون قفل (للتطوير)
  KEY_LIST         → حط كيوهات المشترين هنا
]]
local PAID_MODE  = false
local KEY_LIST   = {
  -- "ASTA-XXXX-YYYY-ZZZZ",
}
local BRAND      = "ASTA Pro"
local VERSION    = "v1"

local SRC = [==[
-- ══════════════════════════════════════════════
--  ASTA Pro — runtime  (لا تعدّل من هنا للأسفل)
-- ══════════════════════════════════════════════
local Players        = game:GetService("Players")
local TweenService   = game:GetService("TweenService")
local TeleportService= game:GetService("TeleportService")
local RunService     = game:GetService("RunService")
local UIS            = game:GetService("UserInputService")
local GuiService     = game:GetService("GuiService")

local ALLOWED_PLACES = {[11379739543] = true, [98752102030179] = true}
local BRAND          = "ASTA Pro"
local ALERT_DIST     = 20
local WARN_DIST      = 50
local MAX_ENEMIES    = 8

-- ── الثيم الفاخر (dark glass + neon) ──
local C = {
  bg       = Color3.fromRGB(8,  10, 18),
  card     = Color3.fromRGB(18, 22, 38),
  card2    = Color3.fromRGB(24, 28, 50),
  off      = Color3.fromRGB(44, 48, 72),
  border   = Color3.fromRGB(55, 65, 110),
  neon     = Color3.fromRGB(80, 160, 255),
  neon2    = Color3.fromRGB(50, 110, 220),
  gold     = Color3.fromRGB(255, 200, 60),
  gold2    = Color3.fromRGB(200, 140, 20),
  red      = Color3.fromRGB(220, 50,  50),
  green    = Color3.fromRGB(60,  210, 110),
  text     = Color3.fromRGB(230, 235, 255),
  dim      = Color3.fromRGB(120, 130, 170),
  white    = Color3.fromRGB(255, 255, 255),
}

if _G.__asta_pro_kill then pcall(_G.__asta_pro_kill); task.wait(0.7) end

-- ══ أدوات مساعدة ══
local function randomName()
  local t = ""
  for _ = 1, math.random(10,16) do t = t .. string.char(math.random(97,122)) end
  return t
end

-- ══ device spoof (نفس منطق v14 بدون تغيير) ══
local function setTargetDevice(device)
  if device == "Pc" or device == "pc" then device = "PC" end
  if writefile then
    pcall(writefile,"sys_cfg_v5_cache.bin",device)
    pcall(writefile,"asta_device.txt",device)
  end
  _G.TargetDevice = device
end
local function getTargetDevice()
  local d = _G.TargetDevice
  if d == "Pc" or d == "pc" then d = "PC" end
  if (d == nil or d == "") and type(isfile)=="function" and type(readfile)=="function" then
    for _, fname in ipairs({"asta_device.txt","sys_cfg_v5_cache.bin"}) do
      local ok,v = pcall(function()
        if isfile(fname) then return readfile(fname) end
      end)
      if ok and type(v)=="string" then
        v = v:gsub("%s+","")
        if v=="Pc" or v=="pc" then v="PC" end
        if v=="Console" or v=="Mobile" or v=="PC" then d=v; _G.TargetDevice=v; break end
      end
    end
  end
  return d
end
local lockSeen = setmetatable({},{__mode="k"})
local lockOn,cursorRef = false,nil
local function applyCursor() if cursorRef then cursorRef.Visible = lockOn end end
local function forceAncestors(inst)
  local p = inst.Parent
  while p and p ~= game do
    if p:IsA("ScreenGui") then
      if not p.Enabled then p.Enabled=true end
      if not lockSeen[p] then lockSeen[p]=true
        p:GetPropertyChangedSignal("Enabled"):Connect(function()
          if not p.Enabled and not _G.__dm_killed then p.Enabled=true end
        end)
      end
      break
    elseif p:IsA("GuiObject") then
      if not p.Visible then p.Visible=true end
      if not lockSeen[p] then lockSeen[p]=true
        p:GetPropertyChangedSignal("Visible"):Connect(function()
          if not p.Visible and not _G.__dm_killed then p.Visible=true end
        end)
      end
    end
    p = p.Parent
  end
end
local function lockFix(inst)
  if lockSeen[inst] then return end
  local n = inst.Name
  if n~="ConsoleButton" and n~="ShiftLockArea" and n~="Toggle" and n~="MouseLockedCursor" then return end
  if not inst:IsA("GuiObject") then return end
  if n=="ConsoleButton" then lockSeen[inst]=true; inst.Visible=false
  elseif n=="ShiftLockArea" then
    lockSeen[inst]=true; inst.Visible=true
    inst:GetPropertyChangedSignal("Visible"):Connect(function()
      if not inst.Visible and not _G.__dm_killed then inst.Visible=true end
    end)
    forceAncestors(inst)
  elseif n=="Toggle" and inst.Parent and inst.Parent.Name=="ShiftLockArea" then
    lockSeen[inst]=true; inst.Visible=true
    inst:GetPropertyChangedSignal("Visible"):Connect(function()
      if not inst.Visible and not _G.__dm_killed then inst.Visible=true end
    end)
    forceAncestors(inst)
    if inst:IsA("GuiButton") then
      inst.MouseButton1Click:Connect(function() lockOn=not lockOn; applyCursor() end)
    end
  elseif n=="MouseLockedCursor" then
    lockSeen[inst]=true; cursorRef=inst; inst.Visible=lockOn
    inst:GetPropertyChangedSignal("Visible"):Connect(function()
      if inst.Visible~=lockOn and not _G.__dm_killed then inst.Visible=lockOn end
    end)
  end
end
local function watchLock()
  local lp = Players.LocalPlayer
  if not lp then return end
  task.spawn(function()
    local pg = lp:FindFirstChild("PlayerGui") or lp:WaitForChild("PlayerGui")
    pg.DescendantAdded:Connect(function(d) pcall(lockFix,d) end)
    for _,d in ipairs(pg:GetDescendants()) do pcall(lockFix,d) end
    local t0 = os.clock()
    while os.clock()-t0<60 and not _G.__dm_killed do
      pcall(function()
        local area = pg:FindFirstChild("ShiftLockArea",true)
        if area and area:IsA("GuiObject") then
          if lockSeen[area] then
            if not area.Visible then area.Visible=true end
            local tg=area:FindFirstChild("Toggle")
            if tg and tg:IsA("GuiObject") and not tg.Visible then tg.Visible=true end
            forceAncestors(area)
          else
            lockFix(area)
            local tg=area:FindFirstChild("Toggle"); if tg then lockFix(tg) end
            local cur=pg:FindFirstChild("MouseLockedCursor",true); if cur then lockFix(cur) end
          end
        end
      end)
      task.wait(2)
    end
  end)
end
local patchedCache = setmetatable({},{__mode="k"})
local scanning,lastFullScan = false,0
local DEVICE_KEYS = {"Device","Platform","DeviceType","DeviceName","InputDevice","Platform_","CurrentDevice","CurrentPlatform","PlayerDevice","PlayerPlatform"}
local function isDevValue(v) return v=="Mobile" or v=="PC" or v=="Console" end
local function unlockTable(t)
  if type(isreadonly)=="function" and type(setreadonly)=="function" then
    local ok,ro=pcall(isreadonly,t); if ok and ro then pcall(setreadonly,t,false) end
  elseif type(make_writeable)=="function" then pcall(make_writeable,t) end
end
local function patchTable(obj,device)
  local patched,relevant=0,false
  for _,keyName in ipairs(DEVICE_KEYS) do
    local ok,cur=pcall(rawget,obj,keyName)
    if ok and isDevValue(cur) then
      relevant=true
      if cur~=device then
        unlockTable(obj)
        if pcall(rawset,obj,keyName,device) then
          patched=patched+1
          if keyName=="Device" then
            local fix=rawget(obj,"FixXCoordinateAspectRate")
            if type(fix)=="function" then pcall(fix,obj) end
          end
        end
      end
    end
  end
  pcall(function()
    local n=0
    for k,v in next,obj do
      n=n+1; if n>25 then break end
      if type(k)=="string" and isDevValue(v) then
        local lk=k:lower()
        if lk:find("device") or lk:find("platform") or lk:find("plat") then
          relevant=true
          if v~=device then unlockTable(obj); rawset(obj,k,device); patched=patched+1 end
        end
      end
    end
  end)
  local ok2,preferred=pcall(rawget,obj,"PreferredInput")
  if ok2 and type(preferred)=="table" then
    relevant=true
    local wanted=device=="Console" and rawget(obj,"Gamepad") or rawget(obj,"Keyboard")
    if type(wanted)=="table" and preferred~=wanted then
      pcall(function() rawset(obj,"PreferredInput",wanted); patched=patched+1 end)
    end
  end
  return patched,relevant
end
local function collectCandidates()
  local list={}
  if type(filtergc)=="function" then
    local keys={"PreferredInput"}
    for _,k in ipairs(DEVICE_KEYS) do keys[#keys+1]=k end
    for _,key in ipairs(keys) do
      local ok,res=pcall(filtergc,"table",{Keys={key}},false)
      if ok and type(res)=="table" then for _,t in ipairs(res) do list[#list+1]=t end end
    end
    if #list>0 then return list end
  end
  if type(getgc)~="function" then return list end
  local ok,objs=pcall(getgc,true)
  if not ok or type(objs)~="table" then return list end
  local n=0
  for _,o in ipairs(objs) do n=n+1; if type(o)=="table" then list[#list+1]=o end; if n%40000==0 then task.wait() end end
  return list
end
local function spoofDeviceInGc(device,fast)
  if not device then return 0,0 end
  local patched,scanned=0,0
  for t in pairs(patchedCache) do patched=patched+(patchTable(t,device)) end
  if fast then return patched,0 end
  if os.clock()-(_G.__asta_t0 or 0)>30 and next(patchedCache)~=nil then return patched,0 end
  local gap=(os.clock()-(_G.__asta_t0 or 0)<15) and 4 or 60
  if scanning or os.clock()-lastFullScan<gap then return patched,0 end
  if not (type(filtergc)=="function" or type(getgc)=="function") then
    if not _G.__asta_nogc then _G.__asta_nogc=true; warn('[Asta] getgc/filtergc غير مدعوم') end
    return patched,0
  end
  _G.__asta_nscans=(_G.__asta_nscans or 0)+1
  if _G.__asta_nscans>3 and os.clock()-(_G.__asta_t0 or 0)<60 then _G.__asta_nscans=3; return patched,0 end
  scanning=true; lastFullScan=os.clock()
  pcall(function()
    local list=collectCandidates()
    for _,obj in ipairs(list) do
      scanned=scanned+1; if scanned>120000 then break end
      if scanned%4000==0 then task.wait() end
      local p,rel=patchTable(obj,device); patched=patched+p
      if rel then patchedCache[obj]=true end
    end
  end)
  scanning=false
  return patched,scanned
end
local function spoofDeviceExtra(device)
  local lp=Players.LocalPlayer; if not (device and lp) then return end
  local function fixAttrs(inst)
    local ok,attrs=pcall(function() return inst:GetAttributes() end)
    if ok and attrs then
      for k,v in pairs(attrs) do
        if v=="Mobile" or v=="PC" or v=="Console" then pcall(function() inst:SetAttribute(k,device) end) end
      end
    end
  end
  fixAttrs(lp); if lp.Character then fixAttrs(lp.Character) end
end
local function getGuiParent()
  if typeof(gethui)=="function" then local ok,ui=pcall(gethui); if ok and ui then return ui end end
  if typeof(get_hidden_gui)=="function" then local ok,ui=pcall(get_hidden_gui); if ok and ui then return ui end end
  local CoreGui=game:GetService("CoreGui")
  if syn and typeof(syn.protect_gui)=="function" then return CoreGui end
  local lp=Players.LocalPlayer
  return CoreGui:FindFirstChild("RobloxGui") or (lp and lp:WaitForChild("PlayerGui"))
end
local function asta_hideTeleportError()
  task.spawn(function()
    for _=1,30 do
      pcall(function() game:GetService("GuiService"):ClearError() end)
      pcall(function()
        local cg=game:GetService("CoreGui")
        local gui=cg:FindFirstChild("RobloxPromptGui")
        local ov=gui and gui:FindFirstChild("promptOverlay")
        if ov then for _,c in ipairs(ov:GetChildren()) do if c.Name=="ErrorPrompt" then c:Destroy() end end end
      end)
      task.wait(0.1)
    end
  end)
end
pcall(function()
  if type(delfile)=="function" and type(isfile)=="function" then
    local f="asta_norejoin_"..tostring(game.PlaceId)..".txt"
    if isfile(f) then delfile(f) end
  end
end)
_G.__asta_norejoin=nil
local function asta_queueReload()
  if type(queue_on_teleport)~="function" then return end
  local dev=_G.TargetDevice or "PC"
  local code="_G.TargetDevice='"..tostring(dev).."'; pcall(function() local f=readfile('Asta_Pro_core.lua'); loadstring(f)() end)"
  pcall(queue_on_teleport,code)
end
local function asta_installHooks()
  if _G.__asta_hooked or type(hookmetamethod)~="function" then return end
  _G.__asta_hooked=true
  pcall(function()
    local UIS=game:GetService("UserInputService")
    local GS=game:GetService("GuiService")
    local isCaller=type(checkcaller)=="function" and checkcaller or function() return false end
    local function gameCaller()
      if type(getcallingscript)~="function" then return false end
      local ok,sc=pcall(getcallingscript)
      if not ok or typeof(sc)~="Instance" then return false end
      local ok2,core=pcall(function()
        return sc.Name=="PlayerModule" or sc:FindFirstAncestor("PlayerModule")~=nil
      end)
      return not (ok2 and core)
    end
    local wrap=type(newcclosure)=="function" and newcclosure or function(f) return f end
    local oldIdx
    oldIdx=hookmetamethod(game,"__index",wrap(function(self,key)
      if _G.__asta_hookoff then return oldIdx(self,key) end
      if self==UIS and type(key)=="string" then
        local dev=_G.TargetDevice
        if dev and (key=="TouchEnabled" or key=="KeyboardEnabled" or key=="MouseEnabled" or key=="GamepadEnabled") then
          if not isCaller() and gameCaller() then
            if key=="TouchEnabled" then return dev=="Mobile" end
            if key=="GamepadEnabled" then return dev=="Console" end
            return dev=="PC"
          end
        end
      end
      return oldIdx(self,key)
    end))
    local oldNc
    oldNc=hookmetamethod(game,"__namecall",wrap(function(self,...)
      if _G.__asta_hookoff then return oldNc(self,...) end
      if self==GS or self==UIS then
        local dev=_G.TargetDevice
        if dev and not isCaller() then
          local m=getnamecallmethod()
          if m=="IsTenFootInterface" and self==GS and gameCaller() then return dev=="Console" end
          if m=="GetPlatform" and self==UIS and gameCaller() then
            return dev=="Console" and Enum.Platform.XBoxOne or dev=="PC" and Enum.Platform.Windows or Enum.Platform.IOS
          end
        end
      end
      return oldNc(self,...)
    end))
    task.delay(25,function()
      _G.__asta_hookoff=true
      pcall(hookmetamethod,game,"__index",oldIdx)
      pcall(hookmetamethod,game,"__namecall",oldNc)
    end)
  end)
end
local function asta_notify(text)
  pcall(function() warn("[Asta] "..text) end)
  pcall(function()
    local g=Instance.new("ScreenGui")
    g.Name=randomName(); g.ResetOnSpawn=false; g.IgnoreGuiInset=true
    g.DisplayOrder=999; g.Parent=getGuiParent()
    local l=Instance.new("TextLabel")
    l.Size=UDim2.fromOffset(360,52); l.Position=UDim2.new(0.5,-180,0,10)
    l.BackgroundColor3=Color3.fromRGB(8,10,18); l.TextColor3=Color3.fromRGB(80,160,255)
    l.TextWrapped=true; l.TextSize=13; l.Font=Enum.Font.GothamMedium; l.Text=text; l.Parent=g
    Instance.new("UICorner",l).CornerRadius=UDim.new(0,10)
    local st=Instance.new("UIStroke",l); st.Color=Color3.fromRGB(55,65,110); st.Thickness=1.4
    task.delay(10,function() g:Destroy() end)
  end)
end

_G.__dm_killed=false
local lp=Players.LocalPlayer
do
  local dev=getTargetDevice()
  if dev then
    _G.TargetDevice=dev; asta_installHooks()
    if not _G.__asta_lockwatch then _G.__asta_lockwatch=true; pcall(watchLock) end
    pcall(asta_queueReload)
    if not _G.__asta_early then
      _G.__asta_early=true
      task.spawn(function()
        local t0=os.clock(); _G.__asta_t0=t0
        while not _G.__dm_killed and os.clock()-t0<15 do
          local d=_G.TargetDevice or dev
          pcall(spoofDeviceInGc,d); pcall(spoofDeviceExtra,d)
          task.wait(1)
        end
      end)
    end
  end
end
if not game:IsLoaded() then game.Loaded:Wait() end
if not ALLOWED_PLACES[game.PlaceId] then
  asta_notify("PlaceId = "..tostring(game.PlaceId).." (مو في القائمة، بس السكربت يكمل)")
  if setclipboard then pcall(setclipboard,tostring(game.PlaceId)) end
end
asta_installHooks()
if getTargetDevice() and not _G.__asta_lockwatch then _G.__asta_lockwatch=true; watchLock() end

local function reapplyDevice()
  if _G.__dm_killed then return end
  local device=getTargetDevice()
  if device then pcall(spoofDeviceInGc,device); pcall(spoofDeviceExtra,device) end
end
task.spawn(function()
  local t0=os.clock()
  while not _G.__dm_killed do
    local dt=os.clock()-t0; reapplyDevice()
    if dt<30 then task.wait(3) elseif dt<90 then task.wait(10) else break end
  end
end)
task.spawn(function()
  local pg=lp:FindFirstChild("PlayerGui") or lp:WaitForChild("PlayerGui",30)
  if not pg then return end
  local pending=false
  pg.DescendantAdded:Connect(function()
    if pending or _G.__dm_killed then return end
    pending=true
    task.delay(1.5,function()
      pending=false
      local d=getTargetDevice(); if d then pcall(spoofDeviceInGc,d,true) end
    end)
  end)
  pg.ChildAdded:Connect(function()
    if _G.__dm_killed then return end
    task.delay(0.3,reapplyDevice)
  end)
end)
lp.CharacterAdded:Connect(function() task.wait(1); if not _G.__dm_killed then reapplyDevice() end end)

-- ══════════════════════════════════
--  حالة الميزات
-- ══════════════════════════════════
local players,localPlayer,runService,uis,guiService,tweenService =
  Players,lp,RunService,UIS,GuiService,TweenService
local playerGui=lp:WaitForChild("PlayerGui")

local ST = {
  assist   = true,
  grab     = true,
  radar    = false,
  track    = false,
  esp      = false,   -- ★ جديد: هايلايت الأعداء
  speed    = false,   -- ★ جديد: بوست السرعة
  autojump = false,   -- ★ جديد: أوتو جمب عند الجدران
  locked   = {},
}
local CFG = {
  MAX_RANGE          = 60,
  STOP_DIST          = 2.4,
  RESUME_GAP         = 0.7,
  START_DELAY        = 0.0,
  GRAB_RANGE         = 14,
  LEAD_MAX           = 0.55,
  SMOOTH             = 6,
  MAX_LOCKED         = 4,
  RELEASE_DELAY      = 0,
  GRAB_FALLBACK_NEAREST = false,
  TRACK_DIST         = 2.3,
  MATCH_RANGE        = 40,
  FAST_TURN          = 5,
  FAST_GRAB_CD       = 0.03,
  DOUBLE_TAP         = 0.45,
  ASSIST_POWER       = 48,
  ASSIST_RANGE       = 10,
  SPEED_BONUS        = 20,   -- ★ جديد: زيادة WalkSpeed
  JUMP_CHECK_DIST    = 4,    -- ★ جديد: مسافة كشف الجدار أمامك
}
local GRAB_COOLDOWN = 0.1
local DISPLAY = {Console="Console",Mobile="Mobile",PC="PC"}
local GEAR_FALLBACK = {x0=0.50,y0=0.00,x1=0.70,y1=0.20}

local conns,guis={},{}
local function keep(c) conns[#conns+1]=c; return c end
local function alive() return not _G.__dm_killed end
_G.__asta_pro_kill = function()
  _G.__dm_killed=true
  for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
  pcall(function() RunService:UnbindFromRenderStep("AstaProDrive") end)
  for _,g in ipairs(guis) do pcall(function() g:Destroy() end) end
  -- نظّف ESP
  pcall(function()
    for _,p in ipairs(Players:GetPlayers()) do
      local ch=p.Character; if ch then
        local h=ch:FindFirstChild("__AstaESP")
        if h then h:Destroy() end
      end
    end
  end)
  -- إرجاع السرعة الأصلية
  pcall(function()
    local ch=lp.Character; local hum=ch and ch:FindFirstChildOfClass("Humanoid")
    if hum and _G.__asta_base_speed then hum.WalkSpeed=_G.__asta_base_speed end
  end)
end

-- ══ كشف الجويستيك ══
local manualTouches={}
local MOVE_KEYS={Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,
  Enum.KeyCode.Up,Enum.KeyCode.Down,Enum.KeyCode.Left,Enum.KeyCode.Right}
local uiBlock=function(pos) return false end

keep(UIS.InputBegan:Connect(function(input)
  if input.UserInputType~=Enum.UserInputType.Touch then return end
  local cam=workspace.CurrentCamera; if not cam then return end
  local pos=Vector2.new(input.Position.X,input.Position.Y)
  if uiBlock(pos) then return end
  if pos.X<cam.ViewportSize.X*0.45 and pos.Y>cam.ViewportSize.Y*0.45 then manualTouches[input]=true end
end))
keep(UIS.InputEnded:Connect(function(input) manualTouches[input]=nil end))
local function touchHeld()
  for input in pairs(manualTouches) do
    local st=input.UserInputState
    if st==Enum.UserInputState.End or st==Enum.UserInputState.Cancel then manualTouches[input]=nil end
  end
  return next(manualTouches)~=nil
end
local function keyHeld()
  if not UIS:GetFocusedTextBox() then
    for _,k in ipairs(MOVE_KEYS) do if UIS:IsKeyDown(k) then return true end end
  end
  local ok,res=pcall(function()
    for _,io in ipairs(UIS:GetGamepadState(Enum.UserInputType.Gamepad1)) do
      if io.KeyCode==Enum.KeyCode.Thumbstick1 and io.Position.Magnitude>0.25 then return true end
    end
    return false
  end)
  return ok and res==true
end
local function anyHeld() return touchHeld() or keyHeld() end

-- ══ أدوات مشتركة ══
local function isTeammate(p)
  local myTeam=localPlayer.Team
  if myTeam and p.Team==myTeam then return true end
  if localPlayer.Neutral==false and p.Neutral==false and p.TeamColor==localPlayer.TeamColor then return true end
  return false
end
local lastGrab=0
local function findBomb(char)
  local fallback
  for _,it in ipairs(char:GetChildren()) do
    if it:IsA("Tool") then
      local n=it.Name:lower()
      if n:find("bomb") or it.Name:find("قنبل") then return it end
      fallback=fallback or it
    end
  end
  return fallback
end
local function tryGrab(targetChar,targetRoot,myChar,myRoot,cd,all)
  local now=os.clock()
  if now-lastGrab<(cd or GRAB_COOLDOWN) then return end
  lastGrab=now
  for _,item in ipairs(myChar:GetChildren()) do
    if item:IsA("Tool") then pcall(function() item:Activate() end) end
  end
  if fireproximityprompt then
    for _,d in ipairs(targetChar:GetDescendants()) do
      if d:IsA("ProximityPrompt") and d.Enabled then pcall(fireproximityprompt,d) end
    end
  end
  if not firetouchinterest then
    local flat=Vector3.new(targetRoot.Position.X-myRoot.Position.X,0,targetRoot.Position.Z-myRoot.Position.Z)
    if flat.Magnitude>1.6 then
      local step=math.min(flat.Magnitude-1.4,all and 9 or 5)
      local dest=myRoot.Position+flat.Unit*step
      myRoot.CFrame=CFrame.new(dest)*(myRoot.CFrame-myRoot.CFrame.Position)
    end
  else
    local bomb=findBomb(targetChar)
    local parts={targetRoot}
    local handle=bomb and bomb:FindFirstChild("Handle")
    if handle then table.insert(parts,handle) end
    for _,n in ipairs({"Torso","UpperTorso","Head","Right Arm","RightHand"}) do
      local pt=targetChar:FindFirstChild(n); if pt then table.insert(parts,pt) end
    end
    if all then
      local function addAll(root0)
        for _,d in ipairs(root0:GetDescendants()) do
          if #parts>=24 then return end
          if d:IsA("BasePart") then table.insert(parts,d) end
        end
      end
      addAll(targetChar); if bomb then addAll(bomb) end
    end
    pcall(function()
      for _,pt in ipairs(parts) do firetouchinterest(myRoot,pt,0); firetouchinterest(myRoot,pt,1) end
    end)
  end
end

-- ══ كشف اللاعبين الخضر ══
local isGreenTeammate
do
  local function isGreenColor(c) return c and c.G>0.45 and c.G>c.R*1.35 and c.G>c.B*1.35 end
  local function colorsOf(inst)
    local out={}
    if inst:IsA("Highlight") then table.insert(out,inst.FillColor); table.insert(out,inst.OutlineColor)
    elseif inst:IsA("SelectionBox") or inst:IsA("SelectionSphere") then table.insert(out,inst.Color3)
    elseif inst:IsA("TextLabel") or inst:IsA("TextButton") then
      table.insert(out,inst.TextColor3)
      if inst.BackgroundTransparency<0.9 then table.insert(out,inst.BackgroundColor3) end
    elseif inst:IsA("ImageLabel") then table.insert(out,inst.ImageColor3)
    elseif inst:IsA("Frame") and inst.BackgroundTransparency<0.9 then table.insert(out,inst.BackgroundColor3)
    elseif inst:IsA("UIStroke") then table.insert(out,inst.Color)
    end
    return out
  end
  local function hasGreenMark(root)
    for _,d in ipairs(root:GetDescendants()) do
      for _,c in ipairs(colorsOf(d)) do if isGreenColor(c) then return true end end
    end
    return false
  end
  local cache,at={},0
  local function refresh()
    local now=os.clock(); if now-at<0.6 then return end; at=now; cache={}
    for _,p in ipairs(players:GetPlayers()) do
      if p~=localPlayer then
        local green=false
        pcall(function()
          if p.Team and isGreenColor(p.TeamColor.Color) then green=true end
          local ch=p.Character
          if not green and ch then
            for _,d in ipairs(ch:GetDescendants()) do
              if d:IsA("Highlight") or d:IsA("SelectionBox") then
                for _,c in ipairs(colorsOf(d)) do if isGreenColor(c) then green=true end end
              elseif d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
                if hasGreenMark(d) then green=true end
              end
              if green then break end
            end
          end
        end)
        cache[p]=green
      end
    end
  end
  isGreenTeammate=function(p) refresh(); return cache[p]==true end
end

local rayParams=RaycastParams.new()
rayParams.FilterType=Enum.RaycastFilterType.Exclude
local nextFilter=0
local function refreshFilter()
  local list={}
  for _,p in ipairs(players:GetPlayers()) do if p.Character then table.insert(list,p.Character) end end
  rayParams.FilterDescendantsInstances=list
end
local function blocked(from,to)
  for _,yOff in ipairs({0,-2}) do
    local o=Vector3.new(from.X,from.Y+yOff,from.Z)
    local d=Vector3.new(to.X,from.Y+yOff,to.Z)-o
    if d.Magnitude>0.5 then
      local hit=workspace:Raycast(o,d,rayParams)
      if hit and hit.Instance.CanCollide then return true end
    end
  end
  return false
end
local function getAvoidDir(from,to,prefer)
  local flat=Vector3.new(to.X-from.X,0,to.Z-from.Z)
  if flat.Magnitude<0.5 then return flat,prefer end
  local forward=flat.Unit
  local function rot(rad)
    return Vector3.new(forward.X*math.cos(rad)-forward.Z*math.sin(rad),0,
      forward.X*math.sin(rad)+forward.Z*math.cos(rad))
  end
  local first=(prefer==-1) and -1 or 1
  for _,deg in ipairs({30,60,90,120}) do
    local rad=math.rad(deg)
    local d1=rot(rad*first); if not blocked(from,from+d1*6) then return d1,first end
    local d2=rot(-rad*first); if not blocked(from,from+d2*6) then return d2,-first end
  end
  return -forward,first
end

-- ══ محرك الحركة + human-like noise ══
local D={pos=nil,untilT=0,owner=nil,avoid=nil,avoidUntil=0,side=nil,lastDir=nil}
local function setDrive(pos,owner) D.pos=pos; D.untilT=os.clock()+0.2; D.owner=owner end
local function clearDrive()
  D.pos=nil; D.owner=nil; D.avoid=nil; D.avoidUntil=0; D.side=nil; D.lastDir=nil
end

--[[
  HUM: حالة الـ humanizer
  المبدأ:
    1. دريفت زاوية — كل فريم نضيف offset زاوية يتغير بـ smoothed-random (مش sine ثابت)
       الزاوية تتذبذب ±DRIFT_MAX راد/ثانية حول الاتجاه الحقيقي
    2. micro-pause — كل PAUSE_INTERVAL±جيتر ثانية، نوقف hum:Move لـ PAUSE_DUR ثانية
       يحاكي human input lag / لحظة تفكير
    3. overshoot — كل OVERSHOOT_INTERVAL نمد الهدف شوي وبعدين نرجع
       يحاكي لاعب يتجاوز الخصم ويصحح
    4. سرعة الـ lerp للاتجاه تتغير عشوائياً (TURN_SPEED) — ما يلف بنفس السرعة دايماً
]]
local HUM = {
  -- drift
  driftAngle   = 0,          -- الزاوية الحالية (radians)
  driftVel     = 0,          -- سرعة تغير الزاوية
  DRIFT_MAX    = 0.38,       -- أقصى انحراف (راد) ≈ 22°
  DRIFT_ACCEL  = 1.8,        -- تسارع العشوائية
  DRIFT_DAMP   = 0.88,       -- تخميد (يمنع drift لا نهائي)
  -- micro-pause
  pauseUntil   = 0,
  nextPause    = 0,
  PAUSE_MIN    = 1.4,        -- أقل وقت بين pause وthانية
  PAUSE_MAX    = 3.2,
  PAUSE_DUR_MIN= 0.06,       -- مدة الـ pause
  PAUSE_DUR_MAX= 0.18,
  -- overshoot
  overshootEnd = 0,
  nextOvershoot= 0,
  overshootOff = Vector3.zero,
  OVER_MIN     = 2.5,
  OVER_MAX     = 5.0,
  OVER_DIST    = 1.8,        -- كم stud يتجاوز
  -- turn speed jitter
  turnSpeed    = 0.35,
  nextTurnRoll = 0,
}
-- شيّل الـ pause و overshoot state لما يتغير الهدف أو يمسك اللاعب
local function humReset()
  HUM.driftAngle=0; HUM.driftVel=0
  HUM.pauseUntil=0; HUM.nextPause=0
  HUM.overshootEnd=0; HUM.nextOvershoot=0; HUM.overshootOff=Vector3.zero
end

-- pseudo-random بدون seed ثابت — يعيد قيمة [-1,1] متغيرة مع الوقت
local function nrand(t,seed)
  -- خليط من sinusoids بترددات غير متناسبة (غير دورية عملياً)
  return math.sin(t*7.3+seed)*math.cos(t*3.17+seed*2.1)
       + math.sin(t*13.9+seed*0.7)*0.4
end

local function humanizeDir(rawDir, dist, now)
  local dt = 1/60   -- نفترض 60fps كـ cap (القيم صغيرة، لا يهم التفاوت)

  -- 1. drift: نحرّك driftVel نحو target عشوائي، ونخمّده
  local target = nrand(now, 3.14) * HUM.DRIFT_MAX
  HUM.driftVel = HUM.driftVel + (target - HUM.driftAngle) * HUM.DRIFT_ACCEL * dt
  HUM.driftVel = HUM.driftVel * HUM.DRIFT_DAMP
  HUM.driftAngle = HUM.driftAngle + HUM.driftVel * dt
  -- قرّب من الصفر كل ما اقتربنا من الهدف (ما نطير حوله)
  local distFactor = math.clamp((dist - 2) / 8, 0, 1)
  local angle = HUM.driftAngle * distFactor

  -- دوران الاتجاه بزاوية drift
  local cos_a, sin_a = math.cos(angle), math.sin(angle)
  local driftedDir = Vector3.new(
    rawDir.X * cos_a - rawDir.Z * sin_a,
    0,
    rawDir.X * sin_a + rawDir.Z * cos_a
  )
  if driftedDir.Magnitude > 0.01 then driftedDir = driftedDir.Unit end

  -- 2. turn speed jitter — كل فترة نغير سرعة الـ lerp
  if now >= HUM.nextTurnRoll then
    HUM.turnSpeed = 0.22 + math.abs(nrand(now, 9.9)) * 0.28   -- 0.22 .. 0.50
    HUM.nextTurnRoll = now + 0.4 + math.abs(nrand(now, 1.5)) * 0.6
  end

  return driftedDir
end

local function shouldPause(now)
  -- إعداد أول pause
  if HUM.nextPause == 0 then
    HUM.nextPause = now + HUM.PAUSE_MIN + math.abs(nrand(now,7.7)) * (HUM.PAUSE_MAX - HUM.PAUSE_MIN)
  end
  if now < HUM.pauseUntil then return true end
  if now >= HUM.nextPause then
    local dur = HUM.PAUSE_DUR_MIN + math.abs(nrand(now,2.3)) * (HUM.PAUSE_DUR_MAX - HUM.PAUSE_DUR_MIN)
    HUM.pauseUntil = now + dur
    HUM.nextPause  = now + dur + HUM.PAUSE_MIN + math.abs(nrand(now,5.1)) * (HUM.PAUSE_MAX - HUM.PAUSE_MIN)
    return true
  end
  return false
end

local function overshootOffset(rawDir, dist, now)
  if now >= HUM.overshootEnd then HUM.overshootOff = Vector3.zero end
  if HUM.nextOvershoot == 0 then
    HUM.nextOvershoot = now + HUM.OVER_MIN + math.abs(nrand(now,4.4)) * (HUM.OVER_MAX - HUM.OVER_MIN)
  end
  if now >= HUM.nextOvershoot and dist < 5 then
    -- قرب الهدف: نعطيه overshoot بسيط
    local perpAngle = (nrand(now,8.8) > 0) and math.pi/2 or -math.pi/2
    local cos_p, sin_p = math.cos(perpAngle), math.sin(perpAngle)
    local perp = Vector3.new(rawDir.X*cos_p - rawDir.Z*sin_p, 0, rawDir.X*sin_p + rawDir.Z*cos_p)
    HUM.overshootOff = perp * (HUM.OVER_DIST * (0.6 + math.abs(nrand(now,6.6))*0.4))
    HUM.overshootEnd = now + 0.25 + math.abs(nrand(now,3.3))*0.2
    HUM.nextOvershoot = now + HUM.OVER_MIN + math.abs(nrand(now,1.1))*(HUM.OVER_MAX-HUM.OVER_MIN)
  end
  return HUM.overshootOff
end

RunService:BindToRenderStep("AstaProDrive",Enum.RenderPriority.Input.Value+1,function()
  local char=lp.Character
  local hum=char and char:FindFirstChildOfClass("Humanoid")
  local root=char and char:FindFirstChild("HumanoidRootPart")
  if not hum or not root or hum.Health<=0 or root.Anchored then return end
  if not D.pos or os.clock()>D.untilT then return end
  if anyHeld() then humReset(); return end

  local now = os.clock()

  -- micro-pause: وقف قصير يحاكي human input lag
  if shouldPause(now) then hum:Move(Vector3.zero,false); return end

  local d=Vector3.new(D.pos.X-root.Position.X,0,D.pos.Z-root.Position.Z)
  if d.Magnitude>1.2 then
    local dist = d.Magnitude
    local rawDir = d.Unit

    -- overshoot offset (قرب الهدف فقط)
    local over = overshootOffset(rawDir, dist, now)
    local targetPos = D.pos + over

    -- اتجاه نحو الهدف المعدّل
    local td = Vector3.new(targetPos.X-root.Position.X, 0, targetPos.Z-root.Position.Z)
    if td.Magnitude > 0.1 then rawDir = td.Unit end

    -- wall avoidance
    local myPos=root.Position; local dir=rawDir; local nowT=now
    if D.avoid and nowT<D.avoidUntil then
      if blocked(myPos,myPos+D.avoid*4) then D.avoid,D.side=getAvoidDir(myPos,D.pos,D.side); D.avoidUntil=nowT+0.5 end
      dir=D.avoid
    elseif blocked(myPos,myPos+rawDir*5) then
      local avoid,side=getAvoidDir(myPos,D.pos,D.side)
      D.avoid,D.side=avoid,side; D.avoidUntil=nowT+0.5; dir=avoid
    else D.avoid=nil end

    -- human drift على الاتجاه النهائي
    dir = humanizeDir(dir, dist, now)

    -- lerp بسرعة متغيرة
    if D.lastDir and dir:Dot(D.lastDir)>-0.5 then
      local sm=D.lastDir:Lerp(dir, HUM.turnSpeed)
      if sm.Magnitude>0.01 then dir=sm.Unit end
    end
    D.lastDir=dir
    hum:Move(dir,false)
  else
    humReset()
    hum:Move(Vector3.zero,false)
  end
end)

-- ══ اختيار الأهداف ══
local function hasBomb(c) return findBomb(c)~=nil end
local function validRoot(c)
  local tr=c and c:FindFirstChild("HumanoidRootPart")
  local th=c and c:FindFirstChildOfClass("Humanoid")
  if tr and th and th.Health>0 then return tr end
end
local hudSeen=false
local hudCache={t=0,v=false}
local function reallyVisible(o)
  local cur=o
  while cur and cur~=game do
    if cur:IsA("GuiObject") and not cur.Visible then return false end
    if cur:IsA("ScreenGui") then return cur.Enabled end
    cur=cur.Parent
  end
  return true
end
local function scoreHud()
  local now=os.clock(); if now-hudCache.t<0.5 then return hudCache.v end
  hudCache.t=now; local found=false
  pcall(function()
    local pg=lp:FindFirstChild("PlayerGui"); if not pg then return end
    for _,d in ipairs(pg:GetDescendants()) do
      if d:IsA("TextLabel") and #d.Text<=9 and d.Text:match("^%s*%d+%s*%-%s*%d+%s*$") and reallyVisible(d) then
        found=true; break
      end
    end
  end)
  if found then hudSeen=true end; hudCache.v=found; return found
end
local function matchGate() if scoreHud() then return true end; return not hudSeen end
local function matchOn(myChar,entries)
  if scoreHud() then return true end; if hudSeen then return false end
  if myChar and myChar:FindFirstChildOfClass("Tool") then return true end
  for _,e in ipairs(entries) do
    if e.Dist<=CFG.MATCH_RANGE and e.Root and e.Root.Parent and hasBomb(e.Root.Parent) then return true end
  end
  return false
end
local function pickTargets(root)
  local nearest,nd=nil,CFG.MAX_RANGE; local bomb,bd=nil,CFG.MAX_RANGE
  if #ST.locked>0 then
    nd=math.huge
    for i=#ST.locked,1,-1 do
      local p=players:FindFirstChild(ST.locked[i])
      if not p then table.remove(ST.locked,i)
      else
        local tr=validRoot(p.Character)
        if tr then
          local d=(root.Position-tr.Position).Magnitude
          if d<nd then nd=d; nearest=tr end
          if d<bd and hasBomb(p.Character) then bd=d; bomb=tr end
        end
      end
    end
    return nearest,nd,bomb,#ST.locked>0
  end
  for _,p in ipairs(players:GetPlayers()) do
    if p~=lp and not isTeammate(p) and not isGreenTeammate(p) then
      local tr=validRoot(p.Character)
      if tr and not tr.Anchored and math.abs(tr.Position.Y-root.Position.Y)<=25 then
        local d=(root.Position-tr.Position).Magnitude
        if d<=CFG.MAX_RANGE then
          if d<nd then nd=d; nearest=tr end
          if d<bd and hasBomb(p.Character) then bd=d; bomb=tr end
        end
      end
    end
  end
  return nearest,nd,bomb,false
end
local function pickGrabTarget(root)
  if not matchGate() then return nil end
  local holder,hd=nil,math.huge; local any,ad=nil,math.huge
  local lockedMode=#ST.locked>0
  local function consider(p)
    local c=p.Character; local tr=validRoot(c); if not tr or tr.Anchored then return end
    local d=(tr.Position-root.Position).Magnitude
    if not lockedMode and (d>CFG.MATCH_RANGE or math.abs(tr.Position.Y-root.Position.Y)>12) then return end
    if d<ad then ad=d; any=tr end
    if d<hd and hasBomb(c) then hd=d; holder=tr end
  end
  if lockedMode then
    for _,n in ipairs(ST.locked) do local p=players:FindFirstChild(n); if p then consider(p) end end
  else
    for _,p in ipairs(players:GetPlayers()) do
      if p~=lp and not isTeammate(p) and not isGreenTeammate(p) then consider(p) end
    end
  end
  if holder then return holder end
  if lockedMode then return any end
  if CFG.GRAB_FALLBACK_NEAREST then return any end
  return nil
end
local function interceptPoint(me,tr,speed,vOverride)
  local tp=tr.Position; local rv=tr.AssemblyLinearVelocity
  local v=vOverride or Vector3.new(rv.X,0,rv.Z)
  if v.Magnitude>80 then v=Vector3.zero end
  if v.Magnitude<1.5 then return tp,true end
  local t=(Vector3.new(tp.X-me.X,0,tp.Z-me.Z)).Magnitude/speed
  for _=1,3 do
    local pred=tp+v*math.min(t,0.9)
    t=Vector3.new(pred.X-me.X,0,pred.Z-me.Z).Magnitude/speed
  end
  local off=v*math.min(t,0.9)
  if off.Magnitude>12 then off=off.Unit*12 end
  return tp+off,false
end

-- ══ الاسيست ══
local A={holding=false,had=false,resumeAt=0,smooth=nil,lastSmooth=0,lastTr=nil}
A.track=setmetatable({},{__mode="k"})
local function assistReset() A.holding=false; A.had=false; A.smooth=nil; A.lastTr=nil end
local function assistStep(char,hum,root,now)
  local tr,_,bombRoot=pickTargets(root)
  if not tr then if #ST.locked>0 then clearDrive(); return end; A.holding=false; clearDrive(); return end
  if ST.grab and bombRoot then tr=bombRoot end
  local tPos,me=tr.Position,root.Position
  local dist=Vector3.new(tPos.X-me.X,0,tPos.Z-me.Z).Magnitude
  if ST.grab and dist<=CFG.GRAB_RANGE and not root.Anchored then tryGrab(tr.Parent,tr,char,root) end
  if not A.had then A.had=true; A.resumeAt=now+CFG.START_DELAY end
  if now<A.resumeAt then A.holding=false; clearDrive(); return end
  local eff_stop=math.min(CFG.STOP_DIST,CFG.ASSIST_RANGE)
  if A.holding then if dist>eff_stop+CFG.RESUME_GAP then A.holding=false end
  elseif dist<=eff_stop then A.holding=true end
  if A.holding then clearDrive(); D.untilT=0; return end
  local rv=tr.AssemblyLinearVelocity; local vel=Vector3.new(rv.X,0,rv.Z)
  if vel.Magnitude>80 then vel=Vector3.zero end
  local key=tr.Parent; local tk=A.track[key]
  if not tk then tk={vel=vel,t=now,acc=Vector3.zero}; A.track[key]=tk end
  local dtv=now-tk.t
  if dtv>0.05 then tk.acc=tk.acc*0.6+((vel-tk.vel)/dtv)*0.4; tk.vel=vel; tk.t=now end
  local acc=tk.acc; if acc.Magnitude>40 then acc=acc.Unit*40 end
  local lead=math.clamp(dist/18,0,CFG.LEAD_MAX)
  local off=vel*lead+acc*(0.5*lead*lead); if off.Magnitude>7 then off=off.Unit*7 end
  local raw=tPos+off
  local dtS=math.min(now-A.lastSmooth,0.1); A.lastSmooth=now
  if not A.smooth or A.lastTr~=tr then A.smooth=raw
  else A.smooth=A.smooth:Lerp(raw,math.clamp((CFG.ASSIST_POWER*0.1)*dtS,0,1)) end
  A.lastTr=tr; setDrive(A.smooth,"assist")
end

-- ══ اوتو قراب ══
local G={heldAt=0,smooth=nil,lastTr=nil,lastT=0}
local function grabReset() G.smooth=nil; G.lastTr=nil; G.lastDir=nil; G.hist=nil; G.histTr=nil; G.lastLook=nil end
local function turnRate(tr,now,st)
  st=st or G; local rate,moveRate=0,0
  local lv=tr.CFrame.LookVector; local lk=Vector3.new(lv.X,0,lv.Z)
  if lk.Magnitude>0.01 then
    lk=lk.Unit
    if st.lastLook and st.lastLookT then
      local dot=math.clamp(lk:Dot(st.lastLook),-1,1)
      rate=math.acos(dot)/math.max(now-st.lastLookT,1/120)
    end
    st.lastLook=lk; st.lastLookT=now
  end
  local rv=tr.AssemblyLinearVelocity; local v=Vector3.new(rv.X,0,rv.Z)
  if v.Magnitude>2 then
    if st.lastDir and st.lastDirT then
      local dot=math.clamp(v.Unit:Dot(st.lastDir),-1,1)
      moveRate=math.acos(dot)/math.max(now-st.lastDirT,1/120)
    end
    st.lastDir=v.Unit; st.lastDirT=now
  else st.lastDir=nil end
  return math.max(rate,moveRate,math.abs(tr.AssemblyAngularVelocity.Y))
end
local function trackTarget(tr,now,st)
  st=st or G
  if st.histTr~=tr or not st.hist then st.hist={}; st.histTr=tr end
  local h=st.hist; h[#h+1]={t=now,p=tr.Position}
  while #h>2 and now-h[1].t>0.25 do table.remove(h,1) end
  local first,last=h[1],h[#h]; local dtv=last.t-first.t
  if dtv<0.04 then return Vector3.zero end
  local v=(last.p-first.p)/dtv; return Vector3.new(v.X,0,v.Z)
end
local function grabStep(char,hum,root,now)
  if anyHeld() then G.heldAt=now; grabReset(); clearDrive(); return end
  if CFG.RELEASE_DELAY>0 and now-G.heldAt<CFG.RELEASE_DELAY then clearDrive(); return end
  local tr=pickGrabTarget(root)
  if not tr then grabReset(); clearDrive(); return end
  local me,tp=root.Position,tr.Position
  local dist=Vector3.new(tp.X-me.X,0,tp.Z-me.Z).Magnitude
  local vel=trackTarget(tr,now)
  local fast=turnRate(tr,now)>CFG.FAST_TURN
  if dist<=CFG.GRAB_RANGE+(fast and 4 or 0) then tryGrab(tr.Parent,tr,char,root,fast and CFG.FAST_GRAB_CD or nil,fast) end
  if dist<=1.3 then clearDrive(); return end
  local pt,still=interceptPoint(me,tr,math.max(hum.WalkSpeed,10),vel)
  local dt=math.min(now-G.lastT,0.1); G.lastT=now
  if fast or still or not G.smooth or G.lastTr~=tr then G.smooth=pt
  else G.smooth=G.smooth:Lerp(pt,math.clamp(9*dt,0,1)) end
  G.lastTr=tr; setDrive(G.smooth,"grab")
end

-- ══ autoTrack ══
local T={smooth=nil,lastTr=nil,lastT=0,holding=false}
local function trackReset()
  T.smooth=nil; T.lastTr=nil; T.holding=false
  T.hist=nil; T.histTr=nil; T.lastDir=nil; T.lastLook=nil
  T.prevVel=nil; T.prevT=nil; T.acc=nil
end
local function dropTrack() if D.owner=="track" then clearDrive() end end
local function trackEntries(root)
  local list={}
  for _,p in ipairs(players:GetPlayers()) do
    if p~=lp and not isTeammate(p) then
      local tr=validRoot(p.Character)
      if tr then list[#list+1]={Dist=(tr.Position-root.Position).Magnitude,Root=tr} end
    end
  end
  return list
end
local function pickTrackTarget(root)
  local lockedMode=#ST.locked>0
  local best,bd=nil,lockedMode and math.huge or CFG.MATCH_RANGE
  local function consider(p)
    local tr=validRoot(p.Character); if not tr or tr.Anchored then return end
    if not lockedMode and math.abs(tr.Position.Y-root.Position.Y)>12 then return end
    local d=(tr.Position-root.Position).Magnitude; if d<bd then bd=d; best=tr end
  end
  if lockedMode then
    for _,n in ipairs(ST.locked) do local p=players:FindFirstChild(n); if p then consider(p) end end
  else
    for _,p in ipairs(players:GetPlayers()) do
      if p~=lp and not isTeammate(p) and not isGreenTeammate(p) then consider(p) end
    end
  end
  return best
end
local function trackStep(char,hum,root,now)
  if anyHeld() then trackReset(); dropTrack(); return end
  local tr=pickTrackTarget(root); if not tr then trackReset(); dropTrack(); return end
  local me,tp=root.Position,tr.Position
  local dist=Vector3.new(tp.X-me.X,0,tp.Z-me.Z).Magnitude
  local vel=trackTarget(tr,now,T); if vel.Magnitude>80 then vel=Vector3.zero end
  local fast=turnRate(tr,now,T)>CFG.FAST_TURN
  if dist<=CFG.GRAB_RANGE+(fast and 4 or 0) and not root.Anchored then
    tryGrab(tr.Parent,tr,char,root,fast and CFG.FAST_GRAB_CD or nil,fast)
  end
  local eff_track=math.min(CFG.TRACK_DIST,CFG.ASSIST_RANGE)
  if T.holding then if dist>eff_track+CFG.RESUME_GAP then T.holding=false end
  elseif dist<=eff_track then T.holding=true end
  if T.holding then dropTrack(); return end
  local dtA=now-(T.prevT or now)
  if not T.prevVel or T.lastTr~=tr or dtA>0.5 then
    T.acc=Vector3.zero; T.prevVel=vel; T.prevT=now
  elseif dtA>0.05 then
    T.acc=(T.acc or Vector3.zero)*0.5+((vel-T.prevVel)/dtA)*0.5
    T.prevVel=vel; T.prevT=now
  end
  local acc=T.acc or Vector3.zero; if acc.Magnitude>40 then acc=acc.Unit*40 end
  local speed=math.max(hum.WalkSpeed,10)
  local lead=math.clamp(dist/speed,0,CFG.LEAD_MAX*1.5)
  local off=vel*lead+acc*(0.5*lead*lead); if off.Magnitude>9 then off=off.Unit*9 end
  local blend=math.clamp((dist-3)/8,0,1); local aim=tp+off*blend
  local dt=math.min(now-T.lastT,0.1); T.lastT=now; local still=vel.Magnitude<1.5
  if fast or still or not T.smooth or T.lastTr~=tr then T.smooth=aim
  else T.smooth=T.smooth:Lerp(aim,math.clamp((CFG.ASSIST_POWER*0.15)*dt,0,1)) end
  T.lastTr=tr; setDrive(T.smooth,"track")
end

-- ══════════════════════════════════════════════
--  ★ ESP — هايلايت الأعداء
-- ══════════════════════════════════════════════
local espHandles = {}   -- [player] = Highlight instance

local function espApply(p)
  if p == localPlayer then return end
  local ch = p.Character
  if not ch then return end
  local existing = ch:FindFirstChild("__AstaESP")
  if existing then return end
  local h = Instance.new("Highlight")
  h.Name        = "__AstaESP"
  h.FillColor   = Color3.fromRGB(220,50,50)
  h.OutlineColor= Color3.fromRGB(255,80,80)
  h.FillTransparency   = 0.55
  h.OutlineTransparency= 0.0
  h.DepthMode   = Enum.HighlightDepthMode.AlwaysOnTop
  h.Parent      = ch
  espHandles[p] = h
  -- بيلبورد المسافة فوق الرأس
  local bb = Instance.new("BillboardGui")
  bb.Name = "__AstaESP_bb"
  bb.Size = UDim2.fromOffset(120,30)
  bb.StudsOffset = Vector3.new(0,3.5,0)
  bb.AlwaysOnTop = true
  local root = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("UpperTorso") or ch.PrimaryPart
  if root then bb.Adornee = root end
  bb.Parent = ch
  local lbl = Instance.new("TextLabel",bb)
  lbl.Size = UDim2.fromScale(1,1)
  lbl.BackgroundTransparency = 1
  lbl.TextColor3 = Color3.fromRGB(255,255,255)
  lbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
  lbl.TextStrokeTransparency = 0.3
  lbl.TextSize = 14
  lbl.Font = Enum.Font.GothamBold
  lbl.Text = p.DisplayName
  -- نحدّث المسافة كل فريم
  keep(RunService.Heartbeat:Connect(function()
    if not ST.esp or not bb.Parent or not ch.Parent then return end
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local hisRoot = ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("UpperTorso")
    if myRoot and hisRoot then
      local d = math.floor((myRoot.Position-hisRoot.Position).Magnitude)
      lbl.Text = p.DisplayName .. "\n" .. d .. "m"
    end
  end))
end

local function espClear(p)
  local h = espHandles[p]
  if h then pcall(function() h:Destroy() end) end
  espHandles[p] = nil
  if p.Character then
    local bb = p.Character:FindFirstChild("__AstaESP_bb")
    if bb then pcall(function() bb:Destroy() end) end
  end
end

local function espRefresh()
  if not ST.esp then
    for p in pairs(espHandles) do espClear(p) end
    return
  end
  for _,p in ipairs(Players:GetPlayers()) do
    if p ~= localPlayer and not isTeammate(p) and not isGreenTeammate(p) then
      if not espHandles[p] then espApply(p) end
    else
      espClear(p)
    end
  end
  -- نظّف المغادرين
  for p in pairs(espHandles) do
    if not p.Parent then espClear(p) end
  end
end

keep(Players.PlayerAdded:Connect(function(p)
  p.CharacterAdded:Connect(function()
    task.wait(0.5); if ST.esp then espApply(p) end
  end)
end))
keep(Players.PlayerRemoving:Connect(function(p) espClear(p) end))

-- ══════════════════════════════════════════════
--  ★ Speed Boost
-- ══════════════════════════════════════════════
local function applySpeed()
  local ch = lp.Character; local hum = ch and ch:FindFirstChildOfClass("Humanoid")
  if not hum then return end
  if not _G.__asta_base_speed then _G.__asta_base_speed = hum.WalkSpeed end
  hum.WalkSpeed = ST.speed and (_G.__asta_base_speed + CFG.SPEED_BONUS) or _G.__asta_base_speed
end

keep(lp.CharacterAdded:Connect(function(ch)
  _G.__asta_base_speed = nil
  ch:WaitForChild("Humanoid",10)
  task.wait(0.5); applySpeed()
end))

-- ══════════════════════════════════════════════
--  ★ AutoJump — يجمب لما يكشف جدار قدامك
-- ══════════════════════════════════════════════
local ajParams = RaycastParams.new()
ajParams.FilterType = Enum.RaycastFilterType.Exclude
local lastJump = 0

local function autoJumpStep(char,hum,root)
  if not ST.autojump then return end
  if anyHeld() then return end   -- لو اللاعب يلعب بنفسه: لا تتدخل
  if os.clock() - lastJump < 0.5 then return end
  local lv = root.CFrame.LookVector
  local dir = Vector3.new(lv.X,0,lv.Z)
  if dir.Magnitude < 0.01 then return end
  dir = dir.Unit
  local origin = root.Position + Vector3.new(0,-1.5,0)
  local ch2 = {}
  for _,p in ipairs(Players:GetPlayers()) do if p.Character then ch2[#ch2+1]=p.Character end end
  ajParams.FilterDescendantsInstances = ch2
  local hit = workspace:Raycast(origin, dir * CFG.JUMP_CHECK_DIST, ajParams)
  if hit and hit.Instance.CanCollide then
    -- جدار قدامنا: نجمب
    local gr = workspace:Raycast(root.Position, Vector3.new(0,-3,0), ajParams)
    if gr then   -- نتأكد إنا على الأرض
      hum.Jump = true
      lastJump = os.clock()
    end
  end
end

-- ══ الحلقة الرئيسية ══
local nextFilterAt=0
keep(RunService.Heartbeat:Connect(function()
  if not alive() then return end
  local now=os.clock()
  local char=lp.Character; local hum=char and char:FindFirstChildOfClass("Humanoid")
  local root=char and char:FindFirstChild("HumanoidRootPart")
  if not hum or not root or hum.Health<=0 then clearDrive(); return end
  if root.Anchored then clearDrive(); assistReset(); grabReset(); return end
  if now>=nextFilterAt then nextFilterAt=now+1; pcall(refreshFilter) end

  -- ★ ميزات جديدة
  pcall(autoJumpStep,char,hum,root)

  local hasTool=false
  for _,it in ipairs(char:GetChildren()) do if it:IsA("Tool") then hasTool=true; break end end

  if hasTool then
    grabReset()
    if ST.track then assistReset(); trackStep(char,hum,root,now)
    elseif ST.assist then trackReset(); assistStep(char,hum,root,now)
    else assistReset(); trackReset(); clearDrive() end
  else
    assistReset(); trackReset()
    if ST.grab then grabStep(char,hum,root,now) else clearDrive() end
  end
end))

-- ESP refresh loop
task.spawn(function()
  while alive() do task.wait(1); pcall(espRefresh) end
end)

-- Speed reapply on char change
task.spawn(function()
  while alive() do task.wait(2); pcall(applySpeed) end
end)

-- ══════════════════════════════════════════════
--  الواجهة (فاخرة — dark glass + neon blue/gold)
-- ══════════════════════════════════════════════
local UI = {}
do
  local C = {
    bg       = Color3.fromRGB(8,  10, 18),
    card     = Color3.fromRGB(18, 22, 38),
    card2    = Color3.fromRGB(24, 28, 50),
    off      = Color3.fromRGB(44, 48, 72),
    border   = Color3.fromRGB(55, 65, 110),
    neon     = Color3.fromRGB(80, 160, 255),
    neon2    = Color3.fromRGB(50, 110, 220),
    gold     = Color3.fromRGB(255, 200, 60),
    gold2    = Color3.fromRGB(200, 140, 20),
    red      = Color3.fromRGB(220, 50,  50),
    green    = Color3.fromRGB(60,  210, 110),
    text     = Color3.fromRGB(230, 235, 255),
    dim      = Color3.fromRGB(120, 130, 1
