--[[ ASTA Pro v1 — Premium Edition ]]
--[[
  PAID_MODE = true  → يطلب كي من المشتري (string match بسيط)
  PAID_MODE = false → يشتغل بدون قفل (للتطوير)
  KEY_LIST         → حط كيوهات المشترين هنا
]]
local PAID_MODE  = true
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

local ALLOWED_PLACES = {[11379739543] = true, [13379739543] = true, [98752102030179] = true}
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
    dim      = Color3.fromRGB(120, 130, 170),
    white    = Color3.fromRGB(255, 255, 255),
  }
  local function mk(class,props,parent)
    local o=Instance.new(class)
    for k,v in pairs(props) do o[k]=v end
    if parent then o.Parent=parent end
    return o
  end
  local function corner(o,r) return mk("UICorner",{CornerRadius=UDim.new(0,r)},o) end
  local function stroke(o,col,th,tr) return mk("UIStroke",{Color=col,Thickness=th,Transparency=tr},o) end
  local function tw(o,t,props) TweenService:Create(o,TweenInfo.new(t),props):Play() end
  local function gradient(o,c0,c1,rot)
    return mk("UIGradient",{Color=ColorSequence.new(c0,c1),Rotation=rot or 0},o)
  end

  local gui=mk("ScreenGui",{Name=randomName(),ResetOnSpawn=false,IgnoreGuiInset=true,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=100})
  if syn and typeof(syn.protect_gui)=="function" then pcall(syn.protect_gui,gui) end
  gui.Parent=getGuiParent(); guis[#guis+1]=gui

  -- ── زر عائم (أيقونة نيون) ──
  local fab=mk("TextButton",{Name=randomName(),Size=UDim2.fromOffset(44,44),
    Position=UDim2.new(0,12,0.3,0),BackgroundColor3=C.card,BackgroundTransparency=0.05,
    Text="⚡",TextSize=22,Font=Enum.Font.GothamBold,AutoButtonColor=false,Active=true,Draggable=true},gui)
  corner(fab,22)
  local fabStroke=stroke(fab,C.neon,2,0.1)
  -- حلقة نبض
  task.spawn(function()
    while alive() and gui.Parent do
      local t=os.clock()
      fabStroke.Transparency=0.1+0.3*math.abs(math.sin(t*2.5))
      fab.Rotation=math.sin(t*1.8)*5
      task.wait(0.04)
    end
  end)

  local W,H=320,500
  local panel=mk("Frame",{Name=randomName(),Size=UDim2.fromOffset(W,H),
    Position=UDim2.new(0.5,-W/2,0.5,-H/2),BackgroundColor3=C.bg,BorderSizePixel=0,
    Visible=false,ClipsDescendants=true,Active=true,Draggable=true},gui)
  corner(panel,16)
  local panelStroke=stroke(panel,C.neon,1.5,0.4)
  -- تدرج خلفية خفيف
  mk("UIGradient",{Rotation=130,Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(14,18,38)),
    ColorSequenceKeypoint.new(0.5,C.bg),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(5,8,12))})},panel)

  -- ── شريط علوي ──
  local topBar=mk("Frame",{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.card2,BorderSizePixel=0,ZIndex=3},panel)
  corner(topBar,16)   -- فقط الجزء العلوي مستدير
  mk("UIGradient",{Rotation=0,Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(20,30,70)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(10,14,30))})},topBar)
  stroke(topBar,C.neon2,1,0.6)
  local titleLbl=mk("TextLabel",{Size=UDim2.new(1,-50,0,26),Position=UDim2.fromOffset(14,8),
    BackgroundTransparency=1,Text="ASTA Pro",TextColor3=C.white,TextSize=20,
    Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},topBar)
  gradient(titleLbl,C.neon,C.gold)
  mk("TextLabel",{Size=UDim2.new(1,-50,0,14),Position=UDim2.fromOffset(14,30),
    BackgroundTransparency=1,Text="Premium Edition  •  "..VERSION,TextColor3=C.dim,TextSize=10,
    Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},topBar)
  local closeBtn=mk("TextButton",{Size=UDim2.fromOffset(28,28),Position=UDim2.new(1,-36,0,12),
    BackgroundTransparency=1,Text="×",TextColor3=C.dim,TextSize=24,Font=Enum.Font.GothamMedium,ZIndex=4},topBar)

  -- ── تبويبات ──
  local tabBar=mk("Frame",{Size=UDim2.new(1,-24,0,32),Position=UDim2.fromOffset(12,56),BackgroundTransparency=1,ZIndex=3},panel)
  mk("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},tabBar)
  local function makeTab(txt,order)
    local b=mk("TextButton",{Size=UDim2.new(0.333,-4,1,0),BackgroundColor3=C.card,BackgroundTransparency=0.15,
      Text=txt,TextColor3=C.dim,TextSize=12,Font=Enum.Font.GothamBold,AutoButtonColor=false,LayoutOrder=order},tabBar)
    corner(b,8); return b
  end
  local tabDev  = makeTab("⚙  Devices", 1)
  local tabFeat = makeTab("★  Features",2)
  local tabCfg  = makeTab("⚡  Settings",3)

  local content=mk("Frame",{Position=UDim2.fromOffset(12,96),Size=UDim2.new(1,-24,1,-130),BackgroundTransparency=1,ZIndex=3},panel)
  mk("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,12,1,-24),BackgroundTransparency=1,
    Text="ASTA Pro  •  Premium",TextColor3=C.dim,TextSize=10,Font=Enum.Font.Gotham,ZIndex=4},panel)

  -- صفحات
  local devPage=mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false,ZIndex=3},content)
  local featPage=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=C.neon,CanvasSize=UDim2.new(),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=true,ZIndex=3},content)
  mk("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},featPage)
  local cfgPage=mk("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=C.neon,CanvasSize=UDim2.new(),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,ZIndex=3},content)
  mk("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},cfgPage)

  local function setTab(name)
    local isFeat = name=="Feat"; local isDev = name=="Dev"; local isCfg = name=="Cfg"
    devPage.Visible=isDev; featPage.Visible=isFeat; cfgPage.Visible=isCfg
    local function tabStyle(btn,on)
      tw(btn,0.12,{BackgroundColor3=on and C.neon2 or C.card,TextColor3=on and C.white or C.dim})
    end
    tabStyle(tabDev,isDev); tabStyle(tabFeat,isFeat); tabStyle(tabCfg,isCfg)
  end
  tabDev.MouseButton1Click:Connect(function() setTab("Dev") end)
  tabFeat.MouseButton1Click:Connect(function() setTab("Feat") end)
  tabCfg.MouseButton1Click:Connect(function() setTab("Cfg") end)
  setTab("Feat")

  -- ── صف toggle ──
  local onChangeHooks={}
  local function toggleRow(parent,order,title,sub,key)
    local row=mk("TextButton",{Size=UDim2.new(1,-4,0,56),BackgroundColor3=C.card,BackgroundTransparency=0.1,
      Text="",AutoButtonColor=false,LayoutOrder=order,ZIndex=3},parent)
    corner(row,10)
    local rs=stroke(row,C.border,1.2,0.6)
    mk("TextLabel",{Size=UDim2.new(1,-68,0,20),Position=UDim2.fromOffset(12,8),BackgroundTransparency=1,
      Text=title,TextColor3=C.text,TextSize=14,Font=Enum.Font.GothamBold,
      TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},row)
    mk("TextLabel",{Size=UDim2.new(1,-68,0,14),Position=UDim2.fromOffset(12,28),BackgroundTransparency=1,
      Text=sub,TextColor3=C.dim,TextSize=10,Font=Enum.Font.Gotham,
      TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},row)
    -- pill
    local pill=mk("Frame",{Size=UDim2.fromOffset(44,22),Position=UDim2.new(1,-54,0.5,-11),
      BackgroundColor3=C.off,BorderSizePixel=0,ZIndex=4},row)
    corner(pill,11)
    local knob=mk("Frame",{Size=UDim2.fromOffset(18,18),Position=UDim2.new(0,2,0.5,-9),
      BackgroundColor3=C.dim,BorderSizePixel=0,ZIndex=5},pill)
    corner(knob,9)
    local function render()
      local on=ST[key]
      tw(pill,0.14,{BackgroundColor3=on and C.neon2 or C.off})
      tw(knob,0.14,{Position=on and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
        BackgroundColor3=on and C.white or C.dim})
      tw(rs,0.14,{Color=on and C.neon or C.border,Transparency=on and 0.2 or 0.6})
    end
    row.MouseButton1Click:Connect(function()
      ST[key]=not ST[key]; render()
      if onChangeHooks[key] then pcall(onChangeHooks[key],ST[key]) end
    end)
    render()
    return row
  end

  local function sectionLbl(parent,order,txt)
    local l=mk("TextLabel",{Size=UDim2.new(1,-4,0,22),BackgroundTransparency=1,LayoutOrder=order,
      Text=txt,TextColor3=C.neon,TextSize=12,Font=Enum.Font.GothamBold,
      TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3},parent)
    return l
  end

  -- ── Features tab ──
  sectionLbl(featPage,0,"── Core ──")
  toggleRow(featPage,1,"Assist","يلحق الخصم وانت ماسك القنبلة","assist")
  toggleRow(featPage,2,"Auto Grab","تشيل يدك → يروح للماسك وياخذ القنبلة","grab")
  toggleRow(featPage,3,"Radar","قائمة المسافات + تنبيه قرب","radar")
  toggleRow(featPage,4,"AutoTrack","ماسك القنبلة: يلحق ويعطيها ويوقف 2.3 studs","track")
  sectionLbl(featPage,9,"── Premium ──")
  toggleRow(featPage,10,"ESP","هايلايت الأعداء + مسافتهم دايماً مرئية","esp")
  toggleRow(featPage,11,"Speed Boost","يرفع سرعة مشيك (قابل للضبط في Settings)","speed")
  toggleRow(featPage,12,"Auto Jump","يجمب تلقائي لما يكشف جدار قدامك","autojump")

  onChangeHooks.esp=function(on)
    if on then espRefresh() else
      for p in pairs(espHandles) do espClear(p) end
    end
  end
  onChangeHooks.speed=function() applySpeed() end

  -- Radar rows
  local radarTitle=sectionLbl(featPage,20,"── Radar ──"); radarTitle.Visible=false
  local radarHolder=mk("Frame",{Size=UDim2.new(1,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundTransparency=1,LayoutOrder=21,Visible=false},featPage)
  mk("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},radarHolder)
  sectionLbl(featPage,30,"── Target Lock ──")
  local targetHolder=mk("Frame",{Size=UDim2.new(1,-4,0,0),AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundTransparency=1,LayoutOrder=31},featPage)
  mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},targetHolder)

  onChangeHooks.radar=function(on) radarTitle.Visible=on; radarHolder.Visible=on; if not on then UI.setAlert(math.huge) end end

  local rrows={}
  for i=1,MAX_ENEMIES do
    local f=mk("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=C.card,BackgroundTransparency=0.2,
      BorderSizePixel=0,LayoutOrder=i,Visible=false},radarHolder)
    corner(f,8)
    local n=mk("TextLabel",{Size=UDim2.new(0.65,0,1,0),Position=UDim2.fromOffset(10,0),BackgroundTransparency=1,
      TextColor3=C.text,TextSize=12,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,
      TextTruncate=Enum.TextTruncate.AtEnd,Text=""},f)
    local d=mk("TextLabel",{Size=UDim2.new(0.35,-10,1,0),Position=UDim2.new(0.65,0,0,0),BackgroundTransparency=1,
      TextColor3=C.neon,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right,Text=""},f)
    rrows[i]={f=f,n=n,d=d}
  end
  function UI.setRadar(entries)
    for i=1,MAX_ENEMIES do
      local r,e=rrows[i],entries[i]
      if e then
        local dd=math.floor(e.Dist); r.f.Visible=true; r.n.Text=e.Name; r.d.Text=dd.."m"
        if dd<ALERT_DIST then r.f.BackgroundColor3=Color3.fromRGB(90,15,20); r.d.TextColor3=C.red
        elseif dd<WARN_DIST then r.f.BackgroundColor3=Color3.fromRGB(80,55,10); r.d.TextColor3=C.gold
        else r.f.BackgroundColor3=C.card; r.d.TextColor3=C.neon end
      else r.f.Visible=false end
    end
  end

  local alertF=mk("Frame",{Size=UDim2.new(1,0,0,38),BackgroundColor3=C.red,BackgroundTransparency=0.25,
    BorderSizePixel=0,Visible=false,ZIndex=50},gui)
  local alertT=mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,TextColor3=C.white,
    TextSize=13,Font=Enum.Font.GothamBold,Text="",ZIndex=51},alertF)
  function UI.setAlert(closest)
    if ST.radar and closest<ALERT_DIST then
      alertT.Text="⚠  Enemy nearby — "..math.floor(closest).."m"; alertF.Visible=true
    else alertF.Visible=false end
  end

  -- Target list (نفس منطق v14)
  local btns,lastSig={},""
  local function isRedColor(c) return c~=nil and c.R>0.6 and c.R>c.G*1.8 and c.R>c.B*1.8 end
  local function hasRedMark(p)
    local red=false
    pcall(function()
      local ch=p.Character; if not ch then return end
      for _,d in ipairs(ch:GetDescendants()) do
        if d:IsA("Highlight") then if isRedColor(d.FillColor) or isRedColor(d.OutlineColor) then red=true; break end
        elseif d:IsA("SelectionBox") or d:IsA("SelectionSphere") then if isRedColor(d.Color3) then red=true; break end end
      end
    end)
    return red
  end
  local function isMate(p)
    local ok,res=pcall(function()
      if isTeammate(p) then return true end
      if isGreenTeammate and isGreenTeammate(p) then return true end
      return false
    end)
    return ok and res or false
  end
  local function distTo(p)
    local ok,d=pcall(function()
      local a=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
      local b=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
      if a and b then return (a.Position-b.Position).Magnitude end; return math.huge
    end)
    return ok and d or math.huge
  end
  local function playerFromGui(d)
    local function tryStr(str)
      if type(str)~="string" or str=="" then return nil end
      for num in str:gmatch("%d+") do
        if #num>=4 then local ok,p=pcall(function() return players:GetPlayerByUserId(tonumber(num)) end); if ok and p then return p end end
      end
      local p=players:FindFirstChild(str); if p and p:IsA("Player") then return p end
    end
    local cur=d
    for _=1,3 do
      if not cur then break end; local p
      if cur:IsA("ImageLabel") or cur:IsA("ImageButton") then p=tryStr(cur.Image) end
      p=p or tryStr(cur.Name); if p then return p end; cur=cur.Parent
    end
  end
  local hudGroups,hudAt=nil,0
  local function parseMatchHud()
    local now=os.clock(); if now-hudAt<1 then return hudGroups end; hudAt=now; hudGroups=nil
    pcall(function()
      local pg=lp:FindFirstChild("PlayerGui"); if not pg then return end
      local score
      for _,d in ipairs(pg:GetDescendants()) do
        if d:IsA("TextLabel") and #d.Text<=9 and d.Text:match("^%s*%d+%s*%-%s*%d+%s*$") and reallyVisible(d) then score=d; break end
      end
      if not score then return end
      local cx=score.AbsolutePosition.X+score.AbsoluteSize.X/2
      local cont,left,right=score.Parent,{},{}
      for _=1,6 do
        if not cont or cont==pg then break end; left,right={},{}
        for _,d in ipairs(cont:GetDescendants()) do
          if d:IsA("ImageLabel") or d:IsA("ImageButton") then
            local p=playerFromGui(d)
            if p then local x=d.AbsolutePosition.X+d.AbsoluteSize.X/2; if x<cx then left[p]=true else right[p]=true end end
          end
        end
        if next(left) and next(right) then break end; cont=cont.Parent
      end
      if not (next(left) and next(right)) then return end
      local mine,enemy
      if left[lp] then mine,enemy=left,right
      elseif right[lp] then mine,enemy=right,left
      else
        local lm,rm=0,0
        for p in pairs(left) do if isMate(p) then lm=lm+1 end end
        for p in pairs(right) do if isMate(p) then rm=rm+1 end end
        if lm>=rm then mine,enemy=left,right else mine,enemy=right,left end
      end
      hudGroups={mine=mine,enemy=enemy}
    end)
    return hudGroups
  end
  local function splitPlayers()
    local en,mates,others={},{},{}; local g=parseMatchHud(); local inHud=scoreHud()
    for _,p in ipairs(players:GetPlayers()) do
      if p~=lp then
        if g then
          if g.enemy[p] then en[#en+1]=p elseif g.mine[p] then mates[#mates+1]=p else others[#others+1]=p end
        elseif inHud then
          local near=distTo(p)<=(CFG.MATCH_RANGE or 150)
          if near and isMate(p) then mates[#mates+1]=p elseif near and hasRedMark(p) then en[#en+1]=p else others[#others+1]=p end
        else others[#others+1]=p end
      end
    end
    local byName=function(a,b) return a.Name:lower()<b.Name:lower() end
    table.sort(en,byName); table.sort(mates,byName); table.sort(others,byName)
    return en,mates,others
  end
  local function signature()
    local en,mates,others=splitPlayers(); local t={}
    for _,p in ipairs(en) do t[#t+1]="E:"..p.Name end
    for _,p in ipairs(mates) do t[#t+1]="M:"..p.Name end
    for _,p in ipairs(others) do t[#t+1]="O:"..p.Name end
    return table.concat(t,",").."|"..table.concat(ST.locked,",")
  end
  function UI.rebuild(force)
    local s=signature(); if s==lastSig and not force then return end; lastSig=s
    for _,b in ipairs(btns) do b:Destroy() end; btns={}
    local order,count=0,#ST.locked; local en,mates,others=splitPlayers()
    local function header(txt,color)
      order=order+1
      local h=mk("TextLabel",{Size=UDim2.new(1,0,0,22),LayoutOrder=order,BackgroundTransparency=1,
        TextColor3=color,TextSize=11,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Text=txt},targetHolder)
      btns[#btns+1]=h
    end
    local allB=mk("TextButton",{Size=UDim2.new(1,0,0,32),LayoutOrder=order,BorderSizePixel=0,AutoButtonColor=false,
      BackgroundColor3=count==0 and C.neon2 or C.card,TextColor3=C.text,TextSize=13,Font=Enum.Font.GothamBold,
      Text=count==0 and "All  (nearest)" or ("All  |  Locked: "..count.."/"..CFG.MAX_LOCKED)},targetHolder)
    corner(allB,8); btns[#btns+1]=allB
    allB.MouseButton1Click:Connect(function() table.clear(ST.locked); UI.rebuild(true) end)
    local function addPlayer(p,kind)
      order=order+1; local idx; for i,n in ipairs(ST.locked) do if n==p.Name then idx=i; break end end
      local atMax=#ST.locked>=CFG.MAX_LOCKED
      local nm=p.Name..(p.DisplayName~=p.Name and " ("..p.DisplayName..")" or "")
      local base=kind=="enemy" and Color3.fromRGB(100,18,28) or kind=="mate" and Color3.fromRGB(80,65,10) or C.card
      local icon=kind=="enemy" and "⊗ " or kind=="mate" and "● " or "○ "
      local b=mk("TextButton",{Size=UDim2.new(1,0,0,30),LayoutOrder=order,BorderSizePixel=0,AutoButtonColor=false,
        BackgroundColor3=idx and Color3.fromRGB(80,18,28) or (atMax and Color3.fromRGB(40,40,60) or base),
        TextColor3=C.text,TextSize=12,Font=Enum.Font.GothamBold,TextTruncate=Enum.TextTruncate.AtEnd,
        Text=(idx and ("["..idx.."] ") or icon)..nm},targetHolder)
      corner(b,7); btns[#btns+1]=b
      local pName=p.Name
      b.MouseButton1Click:Connect(function()
        local at; for i,n in ipairs(ST.locked) do if n==pName then at=i; break end end
        if at then table.remove(ST.locked,at) elseif #ST.locked<CFG.MAX_LOCKED then table.insert(ST.locked,pName) end
        UI.rebuild(true)
      end)
    end
    if #en>0 then header("⊗ Enemies ("..#en..")",C.red); for _,p in ipairs(en) do addPlayer(p,"enemy") end end
    if #mates>0 then header("● Teammates ("..#mates..")",C.gold); for _,p in ipairs(mates) do addPlayer(p,"mate") end end
    if #others>0 then header("○ Others ("..#others..")",C.dim); for _,p in ipairs(others) do addPlayer(p,"other") end end
  end
  keep(Players.PlayerAdded:Connect(function() task.defer(UI.rebuild) end))
  keep(Players.PlayerRemoving:Connect(function() task.defer(UI.rebuild) end))
  task.spawn(function()
    while alive() and gui.Parent do if panel.Visible then pcall(UI.rebuild) end; task.wait(1) end
  end)

  -- ── Settings tab (CFG sliders) ──
  local function sliderRow(parent,order,title,key,mn,mx,step)
    local row=mk("Frame",{Size=UDim2.new(1,-4,0,66),BackgroundColor3=C.card,BackgroundTransparency=0.1,
      LayoutOrder=order},parent)
    corner(row,10); stroke(row,C.border,1.2,0.6)
    mk("TextLabel",{Size=UDim2.new(1,-20,0,18),Position=UDim2.fromOffset(10,6),BackgroundTransparency=1,
      Text=title,TextColor3=C.text,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},row)
    local valLbl=mk("TextLabel",{Size=UDim2.fromOffset(60,18),Position=UDim2.new(1,-68,0,6),
      BackgroundTransparency=1,Text=tostring(CFG[key]),TextColor3=C.neon,TextSize=13,
      Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Right},row)
    -- شريط
    local track=mk("Frame",{Size=UDim2.new(1,-20,0,6),Position=UDim2.fromOffset(10,38),
      BackgroundColor3=C.off,BorderSizePixel=0},row)
    corner(track,3)
    local fill=mk("Frame",{Size=UDim2.fromScale((CFG[key]-mn)/(mx-mn),1),BackgroundColor3=C.neon,BorderSizePixel=0},track)
    corner(fill,3)
    local thumb=mk("TextButton",{Size=UDim2.fromOffset(16,16),
      Position=UDim2.new((CFG[key]-mn)/(mx-mn),0,0.5,-8),
      BackgroundColor3=C.white,BorderSizePixel=0,Text="",AutoButtonColor=false},track)
    corner(thumb,8)
    local dragging=false
    thumb.MouseButton1Down:Connect(function() dragging=true end)
    keep(UIS.InputEnded:Connect(function(i)
      if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragging=false
      end
    end))
    keep(UIS.InputChanged:Connect(function(i)
      if not dragging then return end
      if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
      local ta=track.AbsolutePosition; local ts=track.AbsoluteSize
      local px=(i.Position.X-ta.X)/ts.X
      px=math.clamp(px,0,1)
      local rawV=mn+px*(mx-mn)
      local snapped=math.floor(rawV/step+0.5)*step
      snapped=math.clamp(snapped,mn,mx)
      CFG[key]=snapped; valLbl.Text=tostring(snapped)
      local frac=(snapped-mn)/(mx-mn)
      fill.Size=UDim2.fromScale(frac,1)
      thumb.Position=UDim2.new(frac,0,0.5,-8)
      if key=="SPEED_BONUS" then pcall(applySpeed) end
    end))
    return row
  end

  sectionLbl(cfgPage,0,"── Movement ──")
  sliderRow(cfgPage,1,"Speed Bonus","SPEED_BONUS",0,80,5)
  sliderRow(cfgPage,2,"Assist Power","ASSIST_POWER",10,100,5)
  sliderRow(cfgPage,3,"Max Range","MAX_RANGE",20,120,5)
  sliderRow(cfgPage,4,"Grab Range","GRAB_RANGE",5,30,1)
  sectionLbl(cfgPage,10,"── Safety ──")
  sliderRow(cfgPage,11,"Alert Distance","ALERT_DIST_CFG" or "ALERT_DIST",5,60,5)
  sliderRow(cfgPage,12,"Jump Check Dist","JUMP_CHECK_DIST",2,10,1)

  -- ── Devices tab ──
  local DISPLAY2={Console="Console",Mobile="Mobile",PC="PC"}
  local devRows={}; local targetDevice2,pendingDevice2=getTargetDevice(),nil
  mk("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},devPage)
  local function refreshDevBtns()
    for name,r in pairs(devRows) do
      if name==pendingDevice2 then
        tw(r.Btn,0.15,{BackgroundColor3=Color3.fromRGB(180,100,20)})
        r.Text.Text="Confirm? (rejoins)"; r.Text.TextColor3=C.white
        tw(r.Stroke,0.15,{Color=C.gold,Transparency=0.05})
      elseif name==targetDevice2 then
        tw(r.Btn,0.15,{BackgroundColor3=Color3.fromRGB(20,60,140)})
        r.Text.Text=(DISPLAY2[name] or name).."  ✓ Active"; r.Text.TextColor3=C.neon
        tw(r.Stroke,0.15,{Color=C.neon,Transparency=0.05})
      else
        tw(r.Btn,0.15,{BackgroundColor3=C.card}); r.Text.Text=DISPLAY2[name] or name; r.Text.TextColor3=C.text
        tw(r.Stroke,0.15,{Color=C.border,Transparency=0.6})
      end
    end
  end
  local function rejoinAndApply2(deviceName,label)
    targetDevice2=deviceName; setTargetDevice(deviceName); pendingDevice2=nil
    label.Text="Rejoining..."; refreshDevBtns(); reapplyDevice(); asta_queueReload()
    local finished,stage,conn=false,1,nil
    local function applyInPlace()
      if finished then return end; finished=true; asta_hideTeleportError()
      label.Text="Applied ✓"; for i=1,10 do task.delay((i-1)*0.6,reapplyDevice) end; task.delay(1.5,refreshDevBtns)
    end
    local function finish(r,m)
      if conn then conn:Disconnect(); conn=nil end
      if r~=nil or m~=nil then asta_notify("Rejoin failed: "..tostring(r).." | "..tostring(m)) end
      applyInPlace()
    end
    local function tryAsync()
      return pcall(function()
        local opts=Instance.new("TeleportOptions"); opts.ServerInstanceId=game.JobId
        TeleportService:TeleportAsync(game.PlaceId,{lp},opts)
      end)
    end
    conn=TeleportService.TeleportInitFailed:Connect(function(_,r,m)
      if finished then return end; asta_hideTeleportError()
      if stage==1 then stage=2; task.spawn(function() if not tryAsync() then finish(r,m) end end)
      else finish(r,m) end
    end)
    local okTp=pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,lp) end)
    if not okTp then stage=2; task.spawn(function() if not tryAsync() then finish("pcall","teleport api error") end end) end
    task.delay(10,function() if not finished then finish() end end)
  end
  for order,name in ipairs({"Console","Mobile","PC"}) do
    local btn=mk("TextButton",{Size=UDim2.new(1,0,0,52),BackgroundColor3=C.card,BackgroundTransparency=0.1,
      Text="",AutoButtonColor=false,LayoutOrder=order},devPage)
    corner(btn,10)
    local st2=stroke(btn,C.border,1.4,0.6)
    local label=mk("TextLabel",{Size=UDim2.new(1,-20,1,0),Position=UDim2.fromOffset(14,0),BackgroundTransparency=1,
      Text=DISPLAY2[name],TextColor3=C.text,TextSize=14,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},btn)
    devRows[name]={Btn=btn,Stroke=st2,Text=label}
    btn.MouseButton1Click:Connect(function()
      if targetDevice2==name then return end
      if pendingDevice2==name then rejoinAndApply2(name,label)
      else pendingDevice2=name; refreshDevBtns() end
    end)
  end
  mk("TextLabel",{Size=UDim2.new(1,0,0,36),LayoutOrder=10,BackgroundTransparency=1,TextWrapped=true,
    Text="Press device twice to confirm — game rejoins and applies automatically.",
    TextColor3=C.dim,TextSize=11,Font=Enum.Font.Gotham},devPage)
  refreshDevBtns()

  -- ── فتح/إغلاق ──
  local scale=mk("UIScale",{Scale=1},panel)
  local panelOpen=false
  local function openPanel()
    panelOpen=true; scale.Scale=0.9; panel.Visible=true
    TweenService:Create(scale,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
    -- نبضة الإطار لما يفتح
    panelStroke.Transparency=0.0
    task.delay(0.3,function() tw(panelStroke,0.5,{Transparency=0.4}) end)
    pcall(UI.rebuild,true)
  end
  local function closePanel()
    panelOpen=false; pendingDevice2=nil; refreshDevBtns()
    local t=TweenService:Create(scale,TweenInfo.new(0.12),{Scale=0.9})
    t:Play(); t.Completed:Once(function() if not panelOpen then panel.Visible=false end end)
  end
  fab.MouseButton1Click:Connect(function() if panelOpen then closePanel() else openPanel() end end)
  closeBtn.MouseButton1Click:Connect(closePanel)

  local function inFrame(pos,fr)
    if not (fr and fr.Parent and fr.Visible) then return false end
    local inset=guiService:GetGuiInset()
    local p,s=fr.AbsolutePosition,fr.AbsoluteSize
    for _,q in ipairs({pos,pos+inset}) do
      if q.X>=p.X and q.X<=p.X+s.X and q.Y>=p.Y and q.Y<=p.Y+s.Y then return true end
    end
    return false
  end
  local function findGear()
    for _,d in ipairs(playerGui:GetDescendants()) do
      if d:IsA("GuiButton") and d.Visible and d.AbsoluteSize.X>0 and not d:IsDescendantOf(gui) then
        local n=d.Name:lower(); if n:find("setting") or n:find("gear") then return d end
      end
    end
  end
  local function inGearArea(pos)
    local gear=findGear(); if gear then return inFrame(pos,gear) end
    local v=workspace.CurrentCamera.ViewportSize; local g=GEAR_FALLBACK
    return pos.X>=v.X*g.x0 and pos.X<=v.X*g.x1 and pos.Y>=v.Y*g.y0 and pos.Y<=v.Y*g.y1
  end
  uiBlock=function(pos) return inFrame(pos,panel) or inFrame(pos,fab) or inGearArea(pos) end

  local lastTap2=0
  keep(UIS.InputBegan:Connect(function(input)
    if input.UserInputType~=Enum.UserInputType.Touch and input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    local pos=Vector2.new(input.Position.X,input.Position.Y)
    if not inGearArea(pos) then return end
    local now=os.clock()
    if now-lastTap2<=CFG.DOUBLE_TAP then lastTap2=0; if panelOpen then closePanel() else openPanel() end
    else lastTap2=now end
  end))

  pcall(UI.rebuild,true)
  task.delay(0.5,function()
    asta_notify("ASTA Pro ready — tap ⚡ to open")
  end)
end

-- ══ رادار loop ══
task.spawn(function()
  while alive() do
    task.wait(0.5)
    local char=lp.Character; local myRoot=char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot or not ST.radar then if not ST.radar then UI.setAlert(math.huge) end; continue end
    local entries={}
    for _,p in ipairs(players:GetPlayers()) do
      if p~=lp and not isTeammate(p) then
        local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if r then entries[#entries+1]={Name=p.DisplayName,Dist=(r.Position-myRoot.Position).Magnitude,Root=r} end
      end
    end
    table.sort(entries,function(a,b) return a.Dist<b.Dist end)
    if ST.radar then UI.setRadar(entries); UI.setAlert(entries[1] and entries[1].Dist or math.huge) end
  end
end)
]==]

-- ════════════════════════════════════════════════════════
--  نظام الكي (PAID_MODE)
-- ════════════════════════════════════════════════════════
local function checkKey(input)
  input = input:gsub("%s+","")
  for _, k in ipairs(KEY_LIST) do
    if k == input then return true end
  end
  return false
end

local function launchMain()
  if writefile then
    pcall(writefile, "Asta_Pro_core.lua", "local SRC = [==[" .. SRC .. "]==] loadstring(SRC)()")
    pcall(function()
      if makefolder and isfolder and not isfolder("autoexec") then pcall(makefolder,"autoexec") end
      writefile("autoexec/Asta_Pro_core.lua",
        "pcall(function() loadstring(readfile('Asta_Pro_core.lua'))() end)")
    end)
  end
  local fn, err = loadstring(SRC)
  if not fn then warn("[Asta Pro] "..tostring(err)); return end
  fn()
end

if not PAID_MODE then
  launchMain()
  return
end

-- واجهة إدخال الكي
do
  local Players     = game:GetService("Players")
  local TweenService= game:GetService("TweenService")
  local GuiService  = game:GetService("GuiService")
  local lp          = Players.LocalPlayer
  local function getParent()
    if typeof(gethui)=="function" then local ok,u=pcall(gethui); if ok and u then return u end end
    if typeof(get_hidden_gui)=="function" then local ok,u=pcall(get_hidden_gui); if ok and u then return u end end
    local cg=game:GetService("CoreGui")
    if syn and typeof(syn.protect_gui)=="function" then return cg end
    return cg:FindFirstChild("RobloxGui") or (lp and lp:WaitForChild("PlayerGui"))
  end
  local function mk(c,p,par) local o=Instance.new(c); for k,v in pairs(p) do o[k]=v end; if par then o.Parent=par end; return o end
  local function corner(o,r) mk("UICorner",{CornerRadius=UDim.new(0,r)},o) end
  local function stroke(o,col,th) mk("UIStroke",{Color=col,Thickness=th},o) end

  local C = {
    bg   = Color3.fromRGB(8,10,18),
    card = Color3.fromRGB(18,22,38),
    neon = Color3.fromRGB(80,160,255),
    gold = Color3.fromRGB(255,200,60),
    text = Color3.fromRGB(230,235,255),
    dim  = Color3.fromRGB(120,130,170),
    red  = Color3.fromRGB(220,50,50),
  }

  local gui=mk("ScreenGui",{ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=9999})
  if syn and typeof(syn.protect_gui)=="function" then pcall(syn.protect_gui,gui) end
  gui.Parent=getParent()

  -- backdrop dim
  mk("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.4,
    BorderSizePixel=0,ZIndex=1},gui)

  local W,H=360,220
  local box=mk("Frame",{Size=UDim2.fromOffset(W,H),Position=UDim2.new(0.5,-W/2,0.5,-H/2),
    BackgroundColor3=C.bg,BorderSizePixel=0,ZIndex=2},gui)
  corner(box,16); stroke(box,C.neon,1.5)
  mk("UIGradient",{Rotation=130,Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(14,18,38)),
    ColorSequenceKeypoint.new(1,C.bg)})},box)

  local titleL=mk("TextLabel",{Size=UDim2.new(1,0,0,30),Position=UDim2.fromOffset(0,14),
    BackgroundTransparency=1,Text=BRAND.." — Premium",TextColor3=C.text,TextSize=18,
    Font=Enum.Font.GothamBlack,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=3},box)
  mk("UIGradient",{Color=ColorSequence.new(C.neon,C.gold)},titleL)

  mk("TextLabel",{Size=UDim2.new(1,-40,0,16),Position=UDim2.fromOffset(20,52),
    BackgroundTransparency=1,Text="Enter your license key",TextColor3=C.dim,TextSize=12,
    Font=Enum.Font.Gotham,ZIndex=3},box)

  local input=mk("TextBox",{Size=UDim2.new(1,-40,0,38),Position=UDim2.fromOffset(20,76),
    BackgroundColor3=C.card,TextColor3=C.neon,TextSize=14,Font=Enum.Font.GothamMedium,
    PlaceholderText="ASTA-XXXX-XXXX-XXXX",PlaceholderColor3=C.dim,
    ClearTextOnFocus=false,Text="",ZIndex=3},box)
  corner(input,8); stroke(input,C.neon,1.4)

  local statusL=mk("TextLabel",{Size=UDim2.new(1,-40,0,16),Position=UDim2.fromOffset(20,122),
    BackgroundTransparency=1,Text="",TextColor3=C.dim,TextSize=11,
    Font=Enum.Font.Gotham,ZIndex=3},box)

  local confirmBtn=mk("TextButton",{Size=UDim2.new(1,-40,0,38),Position=UDim2.fromOffset(20,148),
    BackgroundColor3=C.neon,TextColor3=Color3.fromRGB(5,8,18),TextSize=14,
    Font=Enum.Font.GothamBold,Text="Unlock",AutoButtonColor=false,ZIndex=3},box)
  corner(confirmBtn,10)

  confirmBtn.MouseButton1Click:Connect(function()
    local k=input.Text
    if checkKey(k) then
      statusL.Text="✓  Valid key — loading..."; statusL.TextColor3=C.gold
      TweenService:Create(box,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
      task.delay(0.5,function() gui:Destroy(); launchMain() end)
    else
      statusL.Text="✗  Invalid key"; statusL.TextColor3=C.red
      TweenService:Create(input,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(80,18,22)}):Play()
      task.delay(0.5,function()
        TweenService:Create(input,TweenInfo.new(0.2),{BackgroundColor3=C.card}):Play()
      end)
    end
  end)

  -- Enter key
  input.FocusLost:Connect(function(enter)
    if enter then confirmBtn.MouseButton1Click:Fire() end
  end)
end
