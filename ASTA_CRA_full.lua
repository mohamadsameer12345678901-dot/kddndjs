local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local WIDGET_SCALE = 0.85
local ASSIST_MAX_RANGE = 60
local ASSIST_STOP_DIST = 2.3
local SKIN_DEFAULT = false
local FACE_ID = 0
local HEADLESS = true
pcall(function()
if setfpscap then
setfpscap(999)
end
end)
pcall(function()
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)
pcall(function()
game:GetService("Lighting").GlobalShadows = false
end)
pcall(function()
settings().Rendering.EagerBulkExecution = true
end)
local AUTO_SKIN = true
local KORBLOX = true
local KORBLOX_ID = 139607718
local HIDE_LEG = "Right"
local TAG_TEXT = "ASTA CRA v6"
local SKIN = { username = "e4cyz", userId = 0, shirt = 0, pants = 0, graphicTShirt = 0, face = 0, hair = {}, hats = {}, }
local BG_OVERRIDE = ""
local SKIN_OVERRIDE = ""
local SKIN_EMBED = ""
local C = { bg = Color3.fromRGB(5, 8, 16), red = Color3.fromRGB(40, 140, 255), redDk = Color3.fromRGB(12, 45, 115), text = Color3.fromRGB(245, 245, 250), sub = Color3.fromRGB(170, 178, 195), off = Color3.fromRGB(38, 43, 56), yellow = Color3.fromRGB(255, 205, 40), }
local function new(class, props, parent)
local o = Instance.new(class)
for k, v in pairs(props or {}) do
o[k] = v
end
if parent then
o.Parent = parent
end
return o
end
local function corner(o, r)
return new("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o)
end
local function stroke(o, col, th, tr)
return new("UIStroke", {Color = col, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, o)
end do
local places = {}
pcall(function()
table.insert(places, gethui and gethui() or nil)
end)
pcall(function()
table.insert(places, game:GetService("CoreGui"))
end)
pcall(function()
table.insert(places, lp:FindFirstChildOfClass("PlayerGui"))
end)
for _, p in ipairs(places) do
for _, n in ipairs({"AstaTop", "AstaShadow", "AstaAuto"}) do
local old = p and p:FindFirstChild(n)
if old then
old:Destroy()
end
end
end
end
local gui = new("ScreenGui", {Name = "AstaTop", ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999}) do
local ok = pcall(function()
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ok or not gui.Parent then
gui.Parent = lp:WaitForChild("PlayerGui")
end
end
local conns = {}
local running, closed = false, false
local _lastMT = 0
local TweenService = game:GetService("TweenService")
local ACCESS_KEY = "BBB444"
local PASS_COLOR = Color3.fromRGB(0, 150, 255)
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64MAP = {}
for i = 1, #B64 do
B64MAP[string.sub(B64, i, i)] = i - 1
end
local function b64decode(data)
data = string.gsub(data, "[^%w%+/]", "")
local out, buf, bits, n = {}, 0, 0, 0
for i = 1, #data do
if i % 40000 == 0 then
task.wait()
end
buf = buf * 64 + B64MAP[string.sub(data, i, i)]
bits = bits + 6
if bits >= 8 then
bits = bits - 8
local p2 = 2 ^ bits
n = n + 1
out[n] = string.char(math.floor(buf / p2) % 256)
buf = buf % p2
end
end
return table.concat(out)
end
local function loadAsset(name, override, embed, cb)
if override == "" and embed == "" then
return
end
task.spawn(function()
local ok, asset = pcall(function()
if override ~= "" then
if not string.find(override, "^https?://") then
return override
end
writefile("asta_top_" .. name .. ".png", game:HttpGet(override))
return getcustomasset("asta_top_" .. name .. ".png")
end
writefile("asta_top_" .. name .. ".jpg", b64decode(embed))
return getcustomasset("asta_top_" .. name .. ".jpg")
end)
if ok and asset then
cb(asset)
end
end)
end
local SONG_DATA = {}
local LANG = "ar"
local function T(ar, en)
return LANG == "ar" and ar or en
end do
local picked = false
local overlay = new("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.1, ZIndex = 500, Active = true}, gui)
local box = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), Size = UDim2.new(0, 330, 0, 230), BackgroundColor3 = C.bg, ZIndex = 501}, overlay)
corner(box, 18)
stroke(box, PASS_COLOR, 2, 0.1)
new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 14), Size = UDim2.new(1, 0, 0, 40), Text = "ASTA CRA v6", TextColor3 = PASS_COLOR, Font = Enum.Font.GothamBlack, TextSize = 30, ZIndex = 502}, box)
new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 56), Size = UDim2.new(1, 0, 0, 22), Text = "Select Language / اختر اللغة", TextColor3 = C.sub, Font = Enum.Font.Gotham, TextSize = 15, ZIndex = 502}, box)
local function langBtn(y, text, code)
local b = new("TextButton", {Text = text, Position = UDim2.new(0.5, -120, 0, y), Size = UDim2.new(0, 240, 0, 44), BackgroundColor3 = C.off, TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 18, ZIndex = 502, AutoButtonColor = true}, box)
corner(b, 12)
stroke(b, PASS_COLOR, 1.5, 0.4)
b.MouseButton1Click:Connect(function()
LANG = code
picked = true
end)
end
langBtn(96, "English", "en")
langBtn(152, "العربية", "ar")
while not picked and gui.Parent do
task.wait(0.1)
end
overlay:Destroy()
end do
end
local function getChar(p)
local c = p and p.Character
if not c then
return nil
end
local h = c:FindFirstChildOfClass("Humanoid")
local r = c:FindFirstChild("HumanoidRootPart")
if h and r and h.Health > 0 then
return c, h, r
end
return nil
end
local function nearestTarget(myRoot)
local best, bd = nil, math.huge
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp then
local _, _, r = getChar(p)
if r then
local d = (r.Position - myRoot.Position).Magnitude
if d < bd then
best, bd = r, d
end
end
end
end
return best
end
local function nameLooksBomb(n)
n = string.lower(n)
return string.find(n, "bomb", 1, true) ~= nil or string.find(n, "tnt", 1, true) ~= nil or string.find(n, "dynamite", 1, true) ~= nil
end
local function hasBomb(p)
local c = p.Character
if not c then
return false
end
for _, item in ipairs(c:GetChildren()) do
if item:IsA("Tool") then
return true
end
end
for _, n in ipairs({"HasBomb", "Bomb", "IsBomb", "BombHolder", "Holding", "IsIt", "It", "hasBomb"}) do
if c:GetAttribute(n) == true or p:GetAttribute(n) == true then
return true
end
end
for _, d in ipairs(c:GetDescendants()) do
if nameLooksBomb(d.Name) then
if d:IsA("BoolValue") then
if d.Value then
return true
end
elseif d:IsA("BasePart") or d:IsA("Model") or d:IsA("Tool") then
return true
end
end
end
return false
end
local controls = nil
task.spawn(function()
pcall(function()
local ps = lp:WaitForChild("PlayerScripts", 5)
local pm = ps and ps:WaitForChild("PlayerModule", 5)
if pm then
controls = require(pm):GetControls()
end
end)
end)
local function userIsMoving()
if controls then
local ok, v = pcall(function()
return controls:GetMoveVector()
end)
if ok and v then
return v.Magnitude > 0.1
end
end
local k = Enum.KeyCode
return UserInputService:IsKeyDown(k.W) or UserInputService:IsKeyDown(k.A) or UserInputService:IsKeyDown(k.S) or UserInputService:IsKeyDown(k.D)
end
local InsertService = game:GetService("InsertService")
local toast = function(_)
end
local quietToast = false
local skinActive, skinTexture = false, nil
local skinGuis = {}
local saved = nil
local function skinConfigured()
return SKIN.username ~= "" or SKIN.userId > 0 or SKIN.shirt > 0 or SKIN.pants > 0 or SKIN.graphicTShirt > 0 or SKIN.face > 0 or #SKIN.hair > 0 or #SKIN.hats > 0
end
local assetCache = {}
local function loadAssetObj(id)
if assetCache[id] then
return assetCache[id]:Clone()
end
local obj = nil
local ok, objs = pcall(function()
return game:GetObjects("rbxassetid://" .. tostring(id))
end)
if ok and objs and objs[1] then
obj = objs[1]
end
if not obj then
local ok2, model = pcall(function()
return InsertService:LoadAsset(id)
end)
if ok2 and model then
local kids = model:GetChildren()
if kids[1] then
obj = kids[1]
end
end
end
if obj then
local okc, cl = pcall(function()
return obj:Clone()
end)
if okc and cl then
assetCache[id] = cl
end
end
return obj
end
local hideConn
local getDesc
local origDesc, fakeLegParts = nil, {}
local function snapshotAndStrip(char)
saved = {removed = {}, colors = nil, face = nil}
for _, d in ipairs(char:GetChildren()) do
if (d:IsA("Accessory") and not nameLooksBomb(d.Name)) or d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") then
table.insert(saved.removed, d)
d.Parent = nil
end
end
local bc = char:FindFirstChildOfClass("BodyColors")
if bc then
saved.colors = bc:Clone()
end
local head = char:FindFirstChild("Head")
local face = head and head:FindFirstChildOfClass("Decal")
if face then
saved.face = face.Texture
end
end
local function restoreVisual(char)
if hideConn then
hideConn:Disconnect()
hideConn = nil
end
for _, fp in ipairs(fakeLegParts) do
pcall(function()
fp:Destroy()
end)
end
fakeLegParts = {}
if origDesc then
local c = lp.Character
local hm = c and c:FindFirstChildOfClass("Humanoid")
if hm then
pcall(function()
hm:ApplyDescription(origDesc)
end)
end
origDesc = nil
end
for _, g in ipairs(skinGuis) do
pcall(function()
g:Destroy()
end)
end
skinGuis = {}
if not saved then
return
end
char = char or (lp.Character)
if char then
for _, d in ipairs(saved.removed) do
pcall(function()
d.Parent = char
end)
end
local bc = char:FindFirstChildOfClass("BodyColors")
if bc and saved.colors then
for _, prop in ipairs({"HeadColor3", "TorsoColor3", "LeftArmColor3", "RightArmColor3", "LeftLegColor3", "RightLegColor3"}) do
local orig = saved.colors[prop]
bc[prop] = Color3.new(1, 0, 1)
bc[prop] = orig
end
end
local head = char:FindFirstChild("Head")
local face = head and head:FindFirstChildOfClass("Decal")
if face and saved.face then
face.Texture = saved.face
end
end
if saved.transp then
for inst, val in pairs(saved.transp) do
pcall(function()
inst.Transparency = val
end)
end
end
if saved.headMesh then
local hm = saved.headMesh
pcall(function()
hm.mesh.MeshType = hm.MeshType
hm.mesh.MeshId = hm.MeshId
hm.mesh.TextureId = hm.TextureId
hm.mesh.Scale = hm.Scale
hm.mesh.Offset = hm.Offset
end)
end
saved = nil
end
local function isWelded(handle)
for _, d in ipairs(handle:GetChildren()) do
if d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("Motor6D") then
return true
end
end
return false
end
local function attachAccessory(char, h, acc)
pcall(function()
h:AddAccessory(acc)
end)
if acc.Parent ~= char then
acc.Parent = char
end
local handle = acc:FindFirstChild("Handle")
if not handle or not handle:IsA("BasePart") then
return false
end
if isWelded(handle) then
return true
end
handle.CanCollide = false
handle.Massless = true
local att = handle:FindFirstChildOfClass("Attachment")
local target = nil
if att then
for _, part in ipairs(char:GetChildren()) do
if part:IsA("BasePart") then
local a = part:FindFirstChild(att.Name)
if a and a:IsA("Attachment") then
target = a
break
end
end
end
end
local head = char:FindFirstChild("Head")
if target then
handle.CFrame = target.WorldCFrame * att.CFrame:Inverse()
local w = Instance.new("Weld")
w.Part0 = target.Parent
w.Part1 = handle
w.C0 = target.CFrame
w.C1 = att.CFrame
w.Parent = handle
return true
elseif head then
handle.CFrame = head.CFrame * CFrame.new(0, head.Size.Y / 2, 0)
local w = Instance.new("WeldConstraint")
w.Part0 = head
w.Part1 = handle
w.Parent = handle
return true
end
return false
end
local LEG_X, LEG_TOP = 0.5, -1.0
local LEG_W = 0.14
local LEG_TOP_LEN, LEG_TIP_LEN = 0.4, 0.6
local function buildFakeLeg(char)
local hrp = char:FindFirstChild("HumanoidRootPart")
if not hrp then
return
end
local darkTeal = Color3.fromRGB(8, 100, 100)
local teal = Color3.fromRGB(40, 190, 190)
local function add(inst, off, size, col)
inst.Size = size
inst.Color = col
inst.Material = Enum.Material.SmoothPlastic
inst.CanCollide = false
inst.CanTouch = false
inst.CanQuery = false
inst.Massless = true
inst.Anchored = false
inst.CFrame = hrp.CFrame * off
local w = Instance.new("WeldConstraint")
w.Part0 = hrp
w.Part1 = inst
w.Parent = inst
inst.Parent = char
table.insert(fakeLegParts, inst)
end
local zHalf = 0.1
add(Instance.new("Part"), CFrame.new(LEG_X, LEG_TOP - LEG_TOP_LEN / 2, 0), Vector3.new(LEG_W, LEG_TOP_LEN, zHalf * 2), darkTeal)
local y2 = LEG_TOP - LEG_TOP_LEN - LEG_TIP_LEN / 2
add(Instance.new("WedgePart"), CFrame.new(LEG_X, y2, -zHalf / 2) * CFrame.Angles(0, 0, math.pi), Vector3.new(LEG_W, LEG_TIP_LEN, zHalf), teal)
add(Instance.new("WedgePart"), CFrame.new(LEG_X, y2, zHalf / 2) * CFrame.Angles(0, math.pi, math.pi), Vector3.new(LEG_W, LEG_TIP_LEN, zHalf), teal)
end
local dummyCache, modelCache = {}, {}
local function buildUserLeg(char, desc, key)
local hum = char:FindFirstChildOfClass("Humanoid")
if not (hum and desc) then
return false
end
local cacheKey = key and (key .. tostring(hum.RigType))
local okM, dummy = true, nil
if cacheKey and dummyCache[cacheKey] then
dummy = dummyCache[cacheKey]:Clone()
else okM, dummy = pcall(function()
return Players:CreateHumanoidModelFromDescription(desc, hum.RigType)
end)
if okM and dummy and cacheKey then
dummyCache[cacheKey] = dummy:Clone()
end
end
if not (okM and dummy) then
return false
end
if hum.RigType == Enum.HumanoidRigType.R6 then
for _, d in ipairs(dummy:GetChildren()) do
if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.RightLeg then
local cm = d:Clone()
cm.Parent = char
table.insert(fakeLegParts, cm)
end
end
pcall(function()
dummy:Destroy()
end)
return true, true
end
local names = {"RightUpperLeg", "RightLowerLeg", "RightFoot"}
local made = 0
for _, n in ipairs(names) do
local src, dst = dummy:FindFirstChild(n), char:FindFirstChild(n)
if src and dst then
local c = src:Clone()
for _, d in ipairs(c:GetChildren()) do
if d:IsA("Motor6D") or d:IsA("Weld") or d:IsA("WeldConstraint") then
d:Destroy()
end
end
c.Name = "KX_" .. n
c.Anchored = false
c.CanCollide = false
c.CanTouch = false
c.CanQuery = false
c.Massless = true
c.Transparency = 0
c.CFrame = dst.CFrame
local w = Instance.new("WeldConstraint")
w.Part0 = dst
w.Part1 = c
w.Parent = c
c.Parent = char
table.insert(fakeLegParts, c)
made = made + 1
end
end
pcall(function()
dummy:Destroy()
end)
return made > 0
end
local function applySpec(char, h, spec)
local korbloxOk, nativeLeg = false, false
local useFake = false
if KORBLOX and spec.desc then
korbloxOk, nativeLeg = buildUserLeg(char, spec.desc, spec.key)
if not korbloxOk then
useFake = true
end
elseif KORBLOX then
useFake = true
end
snapshotAndStrip(char)
if useFake then
buildFakeLeg(char)
end
local count = 0
for _, key in ipairs({"Shirt", "Pants", "GraphicTShirt"}) do
local id = spec[key]
if id and id > 0 then
local obj = loadAssetObj(id)
if obj then
obj.Parent = char
table.insert(skinGuis, obj)
count = count + 1
end
end
end
local accOk, accTotal = 0, #(spec.accs or {})
for _, id in ipairs(spec.accs or {}) do
local obj = loadAssetObj(id)
if obj and obj:IsA("Accessory") then
if attachAccessory(char, h, obj) then
accOk = accOk + 1
end
table.insert(skinGuis, obj)
count = count + 1
end
end
local bc = char:FindFirstChildOfClass("BodyColors")
if bc and spec.colors then
for k, v in pairs(spec.colors) do
pcall(function()
bc[k] = v
end)
end
end
saved.transp = saved.transp or {}
local legSets = { Right = {"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"}, Left = {"Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot"}, }
local hideLeg = HIDE_LEG
if nativeLeg then
hideLeg = ""
elseif korbloxOk or useFake then
hideLeg = "Right"
end
if hideConn then
hideConn:Disconnect()
end
hideConn = RunService.RenderStepped:Connect(function()
local list = {}
if HEADLESS then
local hd = char:FindFirstChild("Head")
if hd then
table.insert(list, hd)
for _, d in ipairs(hd:GetChildren()) do
if d:IsA("Decal") then
table.insert(list, d)
end
end
end
end
local names = {}
for _, n in ipairs(legSets[hideLeg] or {}) do
names[n] = true
end
if next(names) then
for _, d in ipairs(char:GetDescendants()) do
if d:IsA("BasePart") and names[d.Name] then
table.insert(list, d)
end
end
end
for _, inst in ipairs(list) do
if saved and saved.transp[inst] == nil then
saved.transp[inst] = inst.Transparency
end
inst.Transparency = 1
if inst:IsA("BasePart") then
inst.LocalTransparencyModifier = 1
end
end
end)
local head = char:FindFirstChild("Head")
if head and spec.Face and spec.Face > 0 and not HEADLESS then
local f = loadAssetObj(spec.Face)
if f and f:IsA("Decal") then
local old = head:FindFirstChildOfClass("Decal")
if old then
old.Parent = nil
table.insert(saved.removed, old)
end
f.Name = "face"
f.Parent = head
table.insert(skinGuis, f)
count = count + 1
end
end
return count, "اكسسوارات " .. accOk .. "/" .. accTotal
end
local function applyDefaultSkin(char)
local white = Color3.fromRGB(235, 238, 240)
local black = Color3.fromRGB(18, 18, 20)
local function paint(name, col)
local p = char:FindFirstChild(name)
if p and p:IsA("BasePart") then
p.Color = col
end
end
for _, n in ipairs({"Torso", "Left Leg", "Right Leg", "UpperTorso", "LowerTorso", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
paint(n, black)
end
for _, n in ipairs({"Left Arm", "Right Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand"}) do
paint(n, white)
end
local head = char:FindFirstChild("Head")
if head then
local hs = head.Size
local hairCol = Color3.fromRGB(12, 12, 15)
local function piece(size, cf, col)
local p = Instance.new("Part")
p.Size = size
p.Color = col or hairCol
p.Material = Enum.Material.SmoothPlastic
p.CanCollide = false
p.CanTouch = false
p.CanQuery = false
p.Massless = true
p.CastShadow = false
p.CFrame = head.CFrame * cf
p.Parent = char
local w = Instance.new("WeldConstraint")
w.Part0 = head
w.Part1 = p
w.Parent = p
table.insert(skinGuis, p)
end
local sx, sy, sz = hs.X, hs.Y, hs.Z
piece(Vector3.new(sx * 1.1, sy * 0.4, sz * 1.1), CFrame.new(0, sy * 0.58, 0))
piece(Vector3.new(sx * 0.12, sy * 0.75, sz * 1.05), CFrame.new(sx * 0.53, sy * 0.15, 0))
piece(Vector3.new(sx * 0.12, sy * 0.75, sz * 1.05), CFrame.new(-sx * 0.53, sy * 0.15, 0))
piece(Vector3.new(sx * 1.08, sy * 0.85, sz * 0.14), CFrame.new(0, sy * 0.12, sz * 0.52))
for i = -2, 2 do
piece(Vector3.new(sx * 0.2, sy * (0.45 + 0.1 * math.abs(i)), sz * 0.12), CFrame.new(i * sx * 0.2, sy * 0.4, -sz * 0.52) * CFrame.Angles(0, 0, math.rad(i * 9)))
end
for i = 0, 6 do
local ang = (i / 7) * math.pi * 2
piece(Vector3.new(sx * 0.2, sy * 0.7, sz * 0.2), CFrame.new(math.cos(ang) * sx * 0.32, sy * 0.95, math.sin(ang) * sz * 0.32) * CFrame.Angles(math.sin(ang) * 0.45, 0, -math.cos(ang) * 0.45))
end
for i = 0, 7 do
local ang = (i / 8) * math.pi * 2
piece(Vector3.new(sx * 0.12, sy * 0.38, sz * 0.12), CFrame.new(math.cos(ang) * sx * 0.5, sy * 0.88, math.sin(ang) * sz * 0.5), Color3.fromRGB(35, 38, 48))
end
if FACE_ID > 0 then
local face = head:FindFirstChildOfClass("Decal")
if face then
face.Texture = "rbxassetid://" .. FACE_ID
end
end
end
local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
if torso and skinTexture then
local sg = Instance.new("SurfaceGui")
sg.Face = Enum.NormalId.Front
sg.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
sg.PixelsPerStud = 60
sg.LightInfluence = 0
sg.ResetOnSpawn = false
sg.Adornee = torso
sg.Parent = torso
local img = Instance.new("ImageLabel")
img.BackgroundTransparency = 1
img.Size = UDim2.new(1, 0, 1, 0)
img.Image = skinTexture
if torso.Name == "UpperTorso" then
img.ImageRectOffset = Vector2.new(0, 0)
img.ImageRectSize = Vector2.new(256, 140)
end
img.Parent = sg
table.insert(skinGuis, sg)
end
end
local function applySkin()
local c, h = getChar(lp)
if not c then
return false
end
restoreVisual(c)
if skinConfigured() then
local spec, err = nil, nil
if SKIN.username ~= "" or SKIN.userId > 0 then
local uid = SKIN.userId
if SKIN.username ~= "" then
local ok, res = pcall(function()
return Players:GetUserIdFromNameAsync(SKIN.username)
end)
if ok then
uid = res
else err = "اليوزر غلط أو ما انجاب"
end
end
if not err then
local ok, desc = pcall(getDesc, (SKIN.username ~= "" and SKIN.username or tostring(uid)), uid)
if ok and desc then
local accs = {}
local okA, list = pcall(function()
return desc:GetAccessories(true)
end)
if okA and list then
for _, info in ipairs(list) do
table.insert(accs, info.AssetId)
end
end
spec = { Shirt = desc.Shirt, Pants = desc.Pants, GraphicTShirt = desc.GraphicTShirt, Face = desc.Face, accs = accs, desc = desc, key = tostring(uid), colors = {HeadColor3 = desc.HeadColor, TorsoColor3 = desc.TorsoColor, LeftArmColor3 = desc.LeftArmColor, RightArmColor3 = desc.RightArmColor, LeftLegColor3 = desc.LeftLegColor, RightLegColor3 = desc.RightLegColor}, }
else err = "ما قدر يجيب الأفاتار"
end
end
else
local accs = {}
for _, id in ipairs(SKIN.hair) do
table.insert(accs, id)
end
for _, id in ipairs(SKIN.hats) do
table.insert(accs, id)
end
spec = {Shirt = SKIN.shirt, Pants = SKIN.pants, GraphicTShirt = SKIN.graphicTShirt, Face = SKIN.face, accs = accs}
end
local count, info = 0, ""
if spec then
count, info = applySpec(c, h, spec)
end
if count > 0 then
return true
end
restoreVisual(c)
toast("فشل السكن: " .. (err or "ما انحملت الأغراض") .. (SKIN_DEFAULT and " (السكن الافتراضي)" or ""))
end
if SKIN_DEFAULT then
snapshotAndStrip(c)
pcall(applyDefaultSkin, c)
return true
end
return false
end
local function restoreSkin()
skinActive = false
restoreVisual()
end
local SKINS = { {label = "FF_071", username = "FF_071", exact = true}, {label = "TLLWP", username = "TLLWP", exact = true}, {label = "ASOOXLI", username = "ASOOXLI", exact = true}, {label = "UB1ER", username = "UB1ER", exact = true}, {label = "ZXCFFWX", username = "ZXCFFWX", exact = true}, {label = "xk8sq", username = "xk8sq", exact = true}, {label = "AG Purple", color = Color3.fromRGB(120, 40, 200), forceKorblox = true, build = true}, {label = "AG Gold", color = Color3.fromRGB(235, 185, 40), forceKorblox = true, build = true}, {label = "AG Black", color = Color3.fromRGB(22, 22, 26), forceKorblox = true, build = true}, {label = "AG White", color = Color3.fromRGB(240, 240, 245), forceKorblox = true, build = true}, {label = "Vampire", color = Color3.fromRGB(236, 226, 230), forceKorblox = true, build = true}, {label = "Vampire Dark", color = Color3.fromRGB(60, 8, 16), forceKorblox = true, build = true}, {label = "44j", username = "44j"}, {label = "سكن السكربت", script = true}, }
table.insert(SKINS, {label = "Soulcrxck", username = "Soulcrxck", exact = true})
table.insert(SKINS, {label = "H_XRU", username = "H_XRU", exact = true})
table.insert(SKINS, {label = "silentcrimer", username = "silentcrimer", exact = true})
local D_HEADLESS, D_KORBLOX, D_HIDE_LEG = HEADLESS, KORBLOX, HIDE_LEG
local NEW_SKIN_USERNAMES = { }
for _, u in ipairs(NEW_SKIN_USERNAMES) do
table.insert(SKINS, {label = u, username = u})
end
local LUX_SKINS = { "Linkmon99", "Stickmasterluke", "SonOfSevenless", "Simoon68", "EarlGrey", "zlib", "CV10K", "rip_indra", "Merely", "davidweiss2", "deadx_u", "Teknobytez", "Bourgist", "PolarisxProject", "systask", "kenami", "nutcase123", "Saturniidae", "TigerCode", "InceptionTime", "Murteenee", "Commissioner_Bane", "bIazies", "NirkZarek", "Scoobysnacks1", "GodzGalaxy", "kniryah", "ErmCDH", "Holla4Dolla", "Ieango", "TheMule101", "SuperTrader", "TheSliceOfLife", "NoOneMcNoob", "FP_Nation", "Blizzei", "Woof67", "calwina", "EverythingHurtsx_x", "alphasponge", "ConsiderPhlebas", "Tap_Works", "SirRogerPembleton", "fl8mey", "S1ZE", "Builder_Boy", "Preston_Username", "inkwaves", "mightybaseplate", "DarkenedLord", "TaleOfScripting", "Aken_Aten", "Kilo16820", "00lionn", "Azarth", "Quatos", "Bluecage", "iDiablo", }
local FANCY_MIN_ACC = 4
local LUX_OK = {}
local KX_END = 13
local MAX_LUX = 45
local currentSkin = 1
local refreshSkinButtons = function()
end
local buildSkinGallery = function()
end
local uidCache = {}
local function userIdOf(name)
if uidCache[name] then
return uidCache[name]
end
local ok, uid = pcall(function()
return Players:GetUserIdFromNameAsync(name)
end)
if ok and uid then
uidCache[name] = uid
return uid
end
return nil
end
local function copyBodyParts(char, h, model, opts)
opts = opts or {}
saved = saved or {}
saved.transp = saved.transp or {}
local hideList = {}
local function hideOrig(p)
saved.transp[p] = saved.transp[p] or p.Transparency
table.insert(hideList, p)
for _, d in ipairs(p:GetChildren()) do
if d:IsA("Decal") then
saved.transp[d] = saved.transp[d] or d.Transparency
table.insert(hideList, d)
end
end
end
if h.RigType == Enum.HumanoidRigType.R6 then
for _, d in ipairs(model:GetChildren()) do
if d:IsA("CharacterMesh") then
local cm = d:Clone()
cm.Parent = char
table.insert(fakeLegParts, cm)
end
end
end
for _, src in ipairs(model:GetChildren()) do
local dst = char:FindFirstChild(src.Name)
local isHead = false
local diffMesh = dst and src:IsA("MeshPart") and dst:IsA("MeshPart") and src.MeshId ~= dst.MeshId
if dst and src ~= dst and (isHead or diffMesh) and src.Name ~= "HumanoidRootPart" then
local c = src:Clone()
for _, d in ipairs(c:GetChildren()) do
if d:IsA("Motor6D") or d:IsA("Weld") or d:IsA("WeldConstraint") then
d:Destroy()
end
end
c.Name = "KX_" .. src.Name
c.Anchored = false
c.CanCollide = false
c.CanTouch = false
c.CanQuery = false
c.Massless = true
c.Transparency = 0
c.CFrame = dst.CFrame
local w = Instance.new("WeldConstraint")
w.Part0 = dst
w.Part1 = c
w.Parent = c
c.Parent = char
table.insert(fakeLegParts, c)
hideOrig(dst)
end
end
local hd = char:FindFirstChild("Head")
local mh = model:FindFirstChild("Head")
if hd and mh and not opts.headless then
local om, nm = hd:FindFirstChildOfClass("SpecialMesh"), mh:FindFirstChildOfClass("SpecialMesh")
if om and nm then
saved.headMesh = {mesh = om, MeshType = om.MeshType, MeshId = om.MeshId, TextureId = om.TextureId, Scale = om.Scale, Offset = om.Offset}
pcall(function()
om.MeshType = nm.MeshType
om.MeshId = nm.MeshId
om.TextureId = nm.TextureId
om.Scale = nm.Scale
om.Offset = nm.Offset
end)
end
for _, d in ipairs(hd:GetChildren()) do
if d:IsA("Decal") and d.Name ~= "KX_face" then
saved.transp[d] = saved.transp[d] or d.Transparency
table.insert(hideList, d)
end
end
if not opts.noFace then
for _, d in ipairs(mh:GetChildren()) do
if d:IsA("Decal") then
local c = d:Clone()
c.Name = "KX_face"
c.Transparency = 0
c.Parent = hd
table.insert(fakeLegParts, c)
end
end
end
elseif hd and opts.headless then
for _, d in ipairs(hd:GetChildren()) do
if d:IsA("Decal") then
saved.transp[d] = saved.transp[d] or d.Transparency
table.insert(hideList, d)
end
end
end
local kh = char:FindFirstChild("KX_Head")
if kh and (opts.noFace or opts.headless) then
for _, d in ipairs(kh:GetChildren()) do
if d:IsA("Decal") then
saved.transp[d] = saved.transp[d] or d.Transparency
table.insert(hideList, d)
end
end
end
if opts.headless then
for _, pt in ipairs({hd, kh}) do
if pt then
saved.transp[pt] = saved.transp[pt] or pt.Transparency
table.insert(hideList, pt)
end
end
end
if #hideList > 0 then
if hideConn then
hideConn:Disconnect()
end
hideConn = RunService.RenderStepped:Connect(function()
for _, p in ipairs(hideList) do
if p.Parent then
p.Transparency = 1
end
end
end)
end
end
local function copyFromModel(char, h, model, opts)
snapshotAndStrip(char)
local count = 0
for _, d in ipairs(model:GetChildren()) do
if d:IsA("Accessory") then
local acc = d:Clone()
local handle = acc:FindFirstChild("Handle")
if handle then
for _, w in ipairs(handle:GetChildren()) do
if w:IsA("Weld") or w:IsA("WeldConstraint") or w:IsA("Motor6D") then
w:Destroy()
end
end
end
attachAccessory(char, h, acc)
table.insert(skinGuis, acc)
count = count + 1
elseif d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") then
local o = d:Clone()
o.Parent = char
table.insert(skinGuis, o)
count = count + 1
end
end
local mbc, bc = model:FindFirstChildOfClass("BodyColors"), char:FindFirstChildOfClass("BodyColors")
if mbc and bc then
for _, prop in ipairs({"HeadColor3", "TorsoColor3", "LeftArmColor3", "RightArmColor3", "LeftLegColor3", "RightLegColor3"}) do
pcall(function()
bc[prop] = mbc[prop]
end)
end
end
local mh, hd = model:FindFirstChild("Head"), char:FindFirstChild("Head")
if mh and hd then
local mf, cf = mh:FindFirstChildOfClass("Decal"), hd:FindFirstChildOfClass("Decal")
if mf and cf then
pcall(function()
cf.Texture = mf.Texture
end)
end
end
pcall(copyBodyParts, char, h, model, opts)
return count
end
local HttpService = game:GetService("HttpService")
local FREEZE_SKINS = true
local SKINS_FILE = "AstaGG_skins.json"
local frozen = {}
if FREEZE_SKINS then
pcall(function()
if isfile and isfile(SKINS_FILE) then
frozen = HttpService:JSONDecode(readfile(SKINS_FILE))
end
end)
end
local function saveFrozen()
pcall(function()
if writefile then
writefile(SKINS_FILE, HttpService:JSONEncode(frozen))
end
end)
end
local DESC_PROPS = {"Shirt", "Pants", "GraphicTShirt", "Face", "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "HeightScale", "WidthScale", "HeadScale", "DepthScale", "BodyTypeScale", "ProportionScale"}
local COLOR_PROPS = {"HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor"}
local function freezeDesc(d)
local r = {p = {}, c = {}, a = {}}
for _, k in ipairs(DESC_PROPS) do
pcall(function()
r.p[k] = d[k]
end)
end
for _, k in ipairs(COLOR_PROPS) do
pcall(function()
local c = d[k]
r.c[k] = {c.R, c.G, c.B}
end)
end
local ok, list = pcall(function()
return d:GetAccessories(true)
end)
if ok and list then
for _, i in ipairs(list) do
table.insert(r.a, {AssetId = i.AssetId, Type = i.AccessoryType.Name, Layered = i.IsLayered, Order = i.Order, Puffiness = i.Puffiness})
end
end
return r
end
local function thawDesc(r)
local d = Instance.new("HumanoidDescription")
for k, v in pairs(r.p or {}) do
pcall(function()
d[k] = v
end)
end
for k, v in pairs(r.c or {}) do
pcall(function()
d[k] = Color3.new(v[1], v[2], v[3])
end)
end
local list = {}
for _, i in ipairs(r.a or {}) do
table.insert(list, {AssetId = i.AssetId, AccessoryType = Enum.AccessoryType[i.Type], IsLayered = i.Layered, Order = i.Order, Puffiness = i.Puffiness})
end
pcall(function()
d:SetAccessories(list, true)
end)
return d
end
function getDesc(name, uid)
if FREEZE_SKINS and frozen[name] then
return thawDesc(frozen[name])
end
local d = Players:GetHumanoidDescriptionFromUserId(uid)
if FREEZE_SKINS then
frozen[name] = freezeDesc(d)
saveFrozen()
end
return d
end
task.spawn(function() do
frozen._bad = frozen._bad or {}
local HEADLESS_HEAD, KORBLOX_LEG = 134082579, 139607718
local results, pending = {}, #LUX_SKINS
local function isFancy(d)
local ok, list = pcall(function()
return d:GetAccessories(true)
end)
local n = (ok and list) and #list or 0
local head, leg = 0, 0
pcall(function()
head = d.Head
leg = d.RightLeg
end)
return n >= FANCY_MIN_ACC or head == HEADLESS_HEAD or leg == KORBLOX_LEG
end
for idx, name in ipairs(LUX_SKINS) do
if frozen._bad[name] then
pending = pending - 1
elseif frozen[name] then
local okT, dT = pcall(thawDesc, frozen[name])
if okT and dT and isFancy(dT) then
results[idx] = true
else frozen._bad[name] = true
end
pending = pending - 1
else task.spawn(function()
task.wait(idx * 0.08)
local okAll = pcall(function()
local uid = userIdOf(name)
assert(uid, "no uid")
local d
for _ = 1, 2 do
local okD, res = pcall(getDesc, name, uid)
if okD and res then
d = res
break
end
task.wait(0.5)
end
assert(d, "no desc")
assert(isFancy(d), "not fancy")
results[idx] = true
end)
if not okAll then
frozen[name] = nil
frozen._bad[name] = true
end
pending = pending - 1
end)
end
end
local t0 = os.clock()
while pending > 0 and os.clock() - t0 < 25 do
task.wait(0.1)
end
saveFrozen()
local added = 0
for idx, name in ipairs(LUX_SKINS) do
if results[idx] and added < MAX_LUX then
table.insert(SKINS, {label = "👑 " .. name, username = name, exact = true})
table.insert(LUX_OK, name)
added = added + 1
end
end
end
local KORBLOX_EXTRA = { }
local LIGHT_MAX_ACC = 8
local MAX_KORBLOX = 12 do
frozen._bad2 = frozen._bad2 or {}
local names, seen = {}, {}
for _, n in ipairs(KORBLOX_EXTRA) do
if not seen[n] then
seen[n] = true
table.insert(names, n)
end
end
for _, n in ipairs(LUX_SKINS) do
if not seen[n] then
seen[n] = true
table.insert(names, n)
end
end
local found, pending = {}, #names
local function check(d)
local leg = 0
pcall(function()
leg = d.RightLeg
end)
if leg ~= 139607718 then
return false
end
local ok, list = pcall(function()
return d:GetAccessories(true)
end)
local n = (ok and list) and #list or 0
return n <= LIGHT_MAX_ACC
end
for idx, name in ipairs(names) do
if frozen._bad2[name] then
pending = pending - 1
elseif frozen[name] then
local okT, dT = pcall(thawDesc, frozen[name])
if okT and dT and check(dT) then
found[idx] = true
else frozen._bad2[name] = true
end
pending = pending - 1
else task.spawn(function()
task.wait(idx * 0.08)
local okAll = pcall(function()
local uid = userIdOf(name)
assert(uid, "no uid")
local d = getDesc(name, uid)
assert(d and check(d), "no korblox")
found[idx] = true
end)
if not okAll then
frozen._bad2[name] = true
end
pending = pending - 1
end)
end
end
local t0 = os.clock()
while pending > 0 and os.clock() - t0 < 25 do
task.wait(0.1)
end
saveFrozen()
local pos, added = 13, 0
for idx, name in ipairs(names) do
if found[idx] and added < MAX_KORBLOX then
for i = #SKINS, 1, -1 do
if SKINS[i].username == name then
table.remove(SKINS, i)
end
end
table.insert(SKINS, pos, {label = "🦿 " .. name, username = name, exact = true})
pos = pos + 1
added = added + 1
end
end
KX_END = pos
end
local K_POOL = { "Builderman", "Shedletsky", "Telamon", "ReeseMcBlox", "Sharkbyte", "Quenty", "Crazyblox", "Coeptus", "Seranok", "Loleris", "Hexxed", "KreekCraft", "Tofuu", "Denis", "Bloxxer", "Sketch", "Alexnewtron", "Cindering", "Moolah", "Ruiner", "Jacobtheman", "Panzer", "Bighead", "Jaredvan", "Beeism", "Merlin", "Zeuxcg", "Bobbyjoe", "Isaac", "Quasar", "Pooky", "Rocky", "Spud", "Dollars", "Obliterator", "Atlas", "Ghoul", "Havoc", "Zephyr", "Raven", "Vortex", "Phantom", "Nova", "Cipher", "Blaze", "Frost", "Shadow", "Onyx", "Tempest", "Viper", "Reaper", "Specter", "Rogue", "Titan", "Ember", "Glitch", "Hunter", } do
local FORCED_COUNT = 35
frozen._bad3 = frozen._bad3 or {}
local present = {}
for _, sk in ipairs(SKINS) do
if sk.username then
present[string.lower(sk.username)] = true
end
end
local pool, seenP = {}, {}
local function addC(n)
local k = string.lower(n)
if not present[k] and not seenP[k] and not frozen._bad3[n] then
seenP[k] = true
table.insert(pool, n)
end
end
for _, n in ipairs(K_POOL) do
addC(n)
end
for _, n in ipairs(LUX_SKINS) do
addC(n)
end
local function good(d)
local n = 0
pcall(function()
n = #d:GetAccessories(true)
end)
local shirt = 0
pcall(function()
shirt = d.Shirt
end)
return n >= 2 or shirt ~= 0
end
local found, pending = {}, #pool
for idx, name in ipairs(pool) do
if frozen[name] then
local okT, dT = pcall(thawDesc, frozen[name])
if okT and dT and good(dT) then
found[idx] = true
else frozen._bad3[name] = true
end
pending = pending - 1
else task.spawn(function()
task.wait(idx * 0.08)
local okAll = pcall(function()
local uid = userIdOf(name)
assert(uid, "no uid")
local d = getDesc(name, uid)
assert(d and good(d), "empty avatar")
found[idx] = true
end)
if not okAll then
frozen[name] = nil
frozen._bad3[name] = true
end
pending = pending - 1
end)
end
end
local t0 = os.clock()
while pending > 0 and os.clock() - t0 < 30 do
task.wait(0.1)
end
saveFrozen()
local at, added = KX_END, 0
for idx, name in ipairs(pool) do
if found[idx] and added < FORCED_COUNT then
table.insert(SKINS, at, {label = "🦿 " .. name, username = name, exact = true, forceKorblox = true})
at = at + 1
added = added + 1
end
end
end
pcall(buildSkinGallery)
end)
local DEBUG_SKIN = false
local function debugDump(model, char)
local lines = {}
local function num(s)
return tostring(s):match("%d+$") or "-"
end
local function describe(inst)
local s = inst.ClassName .. ":" .. inst.Name
if inst:IsA("MeshPart") then
s = s .. " mesh=" .. num(inst.MeshId) .. " tex=" .. num(inst.TextureID)
end
if inst:IsA("Decal") then
s = s .. " tex=" .. num(inst.Texture)
end
if inst:IsA("BasePart") then
s = s .. string.format(" size=%.1f,%.1f,%.1f", inst.Size.X, inst.Size.Y, inst.Size.Z)
end
return s
end
local mh = model:FindFirstChild("Head")
table.insert(lines, "== راس الحساب ==")
if mh then
table.insert(lines, describe(mh))
for _, d in ipairs(mh:GetChildren()) do
table.insert(lines, " - " .. describe(d))
end
else table.insert(lines, "ما فيه راس")
end
table.insert(lines, "== اكسسوارات الحساب ==")
for _, a in ipairs(model:GetChildren()) do
if a:IsA("Accessory") then
local at = ""
pcall(function()
at = a.AccessoryType.Name
end)
table.insert(lines, " " .. a.Name .. " [" .. at .. "]")
end
end
local ch = char and char:FindFirstChild("Head")
table.insert(lines, "== راسك ==")
if ch then
table.insert(lines, describe(ch))
for _, d in ipairs(ch:GetChildren()) do
table.insert(lines, " - " .. describe(d))
end
end
local lbl = new("TextLabel", {BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.25, Position = UDim2.new(0.05, 0, 0.03, 0), Size = UDim2.new(0.9, 0, 0.6, 0), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Code, TextSize = 13, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Text = table.concat(lines, "\n"), ZIndex = 300}, gui)
task.delay(40, function()
pcall(function()
lbl:Destroy()
end)
end)
end
local SkinHooks = {setHeadless = function()
end, setKorblox = function()
end}
local HttpSvc = game:GetService("HttpService")
local httpReq = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
local function httpJson(url, method, body)
local ok, res = pcall(function()
if method == "POST" then
if not httpReq then
return nil
end
local r = httpReq({Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = HttpSvc:JSONEncode(body)})
return r and r.Body
end
return game:HttpGet(url)
end)
if not ok or type(res) ~= "string" then
return nil
end
local ok2, data = pcall(function()
return HttpSvc:JSONDecode(res)
end)
return ok2 and data or nil
end
local function resolveUserId(name)
name = (string.gsub(tostring(name or ""), "^%s*@?%s*(.-)%s*$", "%1"))
if name == "" then
return nil
end
if uidCache[name] then
return uidCache[name]
end
if string.match(name, "^%d+$") and #name >= 6 then
local n = tonumber(name)
uidCache[name] = n
return n
end
for _ = 1, 3 do
local ok, uid = pcall(function()
return Players:GetUserIdFromNameAsync(name)
end)
if ok and uid then
uidCache[name] = uid
return uid
end
task.wait(0.3)
end
for _, host in ipairs({"users.roproxy.com", "users.roblox.com"}) do
local d = httpJson("https://" .. host .. "/v1/usernames/users", "POST", {usernames = {name}, excludeBannedUsers = false})
local row = d and d.data and d.data[1]
if row and row.id then
uidCache[name] = row.id
return row.id
end
end
return nil
end
local ACC_TYPES = {Hat = true, HairAccessory = true, FaceAccessory = true, NeckAccessory = true, ShoulderAccessory = true, FrontAccessory = true, BackAccessory = true, WaistAccessory = true, TShirtAccessory = true, ShirtAccessory = true, PantsAccessory = true, JacketAccessory = true, SweaterAccessory = true, ShortsAccessory = true, LeftShoeAccessory = true, RightShoeAccessory = true, DressSkirtAccessory = true, EyebrowAccessory = true, EyelashAccessory = true}
local HEADLESS_ASSET, KORBLOX_ASSET = 134082579, 139607718
local function getAppearanceInfo(uid)
local ok, info = pcall(function()
return Players:GetCharacterAppearanceInfoAsync(uid)
end)
if ok and type(info) == "table" and type(info.assets) == "table" then
return info
end
for _, host in ipairs({"avatar.roproxy.com", "avatar.roblox.com"}) do
local d = httpJson("https://" .. host .. "/v1/users/" .. tostring(uid) .. "/avatar")
if type(d) == "table" and type(d.assets) == "table" then
return d
end
end
return nil
end
local function buildModelFromInfo(uid)
local info = getAppearanceInfo(uid)
if not info then
return nil
end
local m = Instance.new("Model")
m.Name = "AstaBuilt"
local made, pending, faceTex = 0, 0, nil
for _, a in ipairs(info.assets) do
local tname = a.assetType and a.assetType.name
local id = a.id
if id == HEADLESS_ASSET then
m:SetAttribute("Headless", true)
end
if id == KORBLOX_ASSET then
m:SetAttribute("Korblox", true)
end
if tname and id then
local want = nil
if ACC_TYPES[tname] then
want = "Accessory"
elseif tname == "Shirt" then
want = "Shirt"
elseif tname == "Pants" then
want = "Pants"
elseif tname == "TShirt" then
want = "ShirtGraphic"
elseif tname == "Face" then
want = "Decal"
end
if want then
pending = pending + 1
task.spawn(function()
local ok, obj = pcall(loadAssetObj, id)
if ok and obj then
local inst = obj:IsA(want) and obj or obj:FindFirstChildWhichIsA(want, true)
if inst then
if want == "Decal" then
faceTex = inst.Texture
else inst.Parent = m
made = made + 1
end
end
end
pending = pending - 1
end)
end
end
end
local t0 = os.clock()
while pending > 0 and os.clock() - t0 < 15 do
task.wait(0.1)
end
local c = info.bodyColors
if type(c) == "table" then
local bc = Instance.new("BodyColors")
local function setc(prop, key)
local v = c[key]
if v then
pcall(function()
bc[prop] = BrickColor.new(v).Color
end)
end
end
setc("HeadColor3", "headColorId")
setc("TorsoColor3", "torsoColorId")
setc("LeftArmColor3", "leftArmColorId")
setc("RightArmColor3", "rightArmColorId")
setc("LeftLegColor3", "leftLegColorId")
setc("RightLegColor3", "rightLegColorId")
bc.Parent = m
end
if faceTex then
local hd = Instance.new("Part")
hd.Name = "Head"
local dec = Instance.new("Decal")
dec.Name = "face"
dec.Texture = faceTex
dec.Parent = hd
hd.Parent = m
end
if made == 0 and not m:FindFirstChildOfClass("BodyColors") then
pcall(function()
m:Destroy()
end)
return nil
end
return m
end
local function applyUserSkin(username, opts)
local c0, h0 = getChar(lp)
if not c0 then
return false, T("الشخصية مو جاهزة", "Character not ready")
end
local isBuild = opts and opts.build
local desc, uid = nil, nil
if isBuild then
local ok
ok, desc = pcall(function()
local d = Instance.new("HumanoidDescription")
local col = opts.color or Color3.fromRGB(25, 25, 28)
for _, k in ipairs({"HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor"}) do
pcall(function()
d[k] = col
end)
end
return d
end)
if not ok then
desc = nil
end
username = "build_" .. tostring(opts.label)
else uid = resolveUserId(username)
if not uid then
return false, T("اليوزر ما انجاب", "Username not found")
end
for _ = 1, 3 do
local ok, d = pcall(getDesc, username, uid)
if ok and d then
desc = d
break
end
task.wait(0.35)
end
end
if desc and opts and opts.forceKorblox then
pcall(function()
desc.RightLeg = KORBLOX_ID
end)
username = username .. "_K"
end
local flagHead, flagKor = false, false
if desc then
pcall(function()
flagHead = (desc.Head == HEADLESS_ASSET)
flagKor = (desc.RightLeg == KORBLOX_ASSET)
end)
end
local rigKey = tostring(h0.RigType)
local sources = { function()
if not desc then
return nil
end
local mkey = username .. rigKey
if modelCache[mkey] then
return modelCache[mkey]:Clone()
end
local ok, model = pcall(function()
return Players:CreateHumanoidModelFromDescription(desc, h0.RigType)
end)
if ok and model then
modelCache[mkey] = model:Clone()
return model
end
return nil
end, function()
if not uid then
return nil
end
local ok, m = pcall(function()
return Players:GetCharacterAppearanceAsync(uid)
end)
if ok and m then
return m
end
return nil
end, function()
if not uid then
return nil
end
return buildModelFromInfo(uid)
end, }
for _, src in ipairs(sources) do
local okS, model = pcall(src)
if okS and model then
if DEBUG_SKIN then
pcall(debugDump, model, c0)
end
local hasColors = model:FindFirstChildOfClass("BodyColors") ~= nil
local mh, mk = model:GetAttribute("Headless"), model:GetAttribute("Korblox")
restoreVisual(c0)
local c, h = getChar(lp)
if not c then
pcall(function()
model:Destroy()
end)
return false, T("الشخصية مو جاهزة", "Character not ready")
end
local okC, count = pcall(copyFromModel, c, h, model, opts)
pcall(function()
model:Destroy()
end)
if okC and ((count or 0) > 0 or hasColors) then
if mh or flagHead then
pcall(SkinHooks.setHeadless, true)
end
if mk or flagKor then
pcall(SkinHooks.setKorblox, true)
end
return true
end
restoreVisual(c)
c0 = lp.Character or c0
end
end
if desc then
local c, h = getChar(lp)
if c then
restoreVisual(c)
local okO, cur = pcall(function()
return h:GetAppliedDescription()
end)
if okO and cur then
origDesc = cur
end
local okA = pcall(function()
h:ApplyDescription(desc)
end)
if okA then
for _, ch in ipairs(c:GetChildren()) do
if ch:IsA("Accessory") or ch:IsA("Shirt") or ch:IsA("Pants") or ch:IsA("ShirtGraphic") then
table.insert(skinGuis, ch)
end
end
return true
end
origDesc = nil
end
end
return false, T("ما قدرت أجيب سكن هذا اليوزر", "Couldn't fetch this user's skin")
end
local applyKorblox = (function()
local KORBLOX_USER = "FF_071"
local KX = {parts = {}, hidden = {}, hide = {}, char = nil, on = false, busy = false, mode = "", glow = false, orig = nil, models = {}}
local R15_LEG = {"RightUpperLeg", "RightLowerLeg", "RightFoot"}
local LEG_NAMES = {["Right Leg"] = true, RightUpperLeg = true, RightLowerLeg = true, RightFoot = true}
local function strip_joints(inst)
for _, d in ipairs(inst:GetDescendants()) do
if d:IsA("Motor6D") or d:IsA("Weld") or d:IsA("WeldConstraint") or d:IsA("LuaSourceContainer") then
pcall(function()
d:Destroy()
end)
end
end
end
local function find_part(root, name)
local direct = root:FindFirstChild(name)
if direct and direct:IsA("MeshPart") then
return direct
end
local best
for _, d in ipairs(root:GetDescendants()) do
if d:IsA("MeshPart") and d.Name == name then
if d.Parent and d.Parent.Name == "R15Fixed" then
return d
end
best = best or d
end
end
return best
end
local function track(inst)
table.insert(KX.parts, inst)
table.insert(fakeLegParts, inst)
end
local function owned(inst)
for _, p in ipairs(KX.parts) do
if p == inst then
return true
end
end
return false
end
local function skin_has_leg(char)
for _, d in ipairs(char:GetChildren()) do
if not owned(d) then
if d.Name == "KX_RightUpperLeg" then
return true
end
if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.RightLeg then
return true
end
end
end
return false
end
local function parts_alive(char)
if #KX.parts == 0 then
return false
end
for _, p in ipairs(KX.parts) do
if not p:IsDescendantOf(char) then
return false
end
end
return true
end
local function apply_glow()
for _, p in ipairs(KX.parts) do
if p:IsA("BasePart") then
local h = p:FindFirstChild("KXGlow")
if KX.glow and not h then
h = Instance.new("Highlight")
h.Name = "KXGlow"
h.FillColor = Color3.fromRGB(40, 190, 190)
h.OutlineColor = Color3.fromRGB(255, 255, 255)
h.FillTransparency = 0.55
h.OutlineTransparency = 0.15
h.Parent = p
elseif not KX.glow and h then
h:Destroy()
end
end
end
end
local function destroy_all(restore_desc)
for _, p in ipairs(KX.parts) do
pcall(function()
p:Destroy()
end)
end
KX.parts = {}
for inst, t in pairs(KX.hidden) do
pcall(function()
if inst.Parent then
inst.Transparency = t
end
end)
end
KX.hidden, KX.hide = {}, {}
if restore_desc and KX.orig then
local c = lp.Character
local hm = c and c:FindFirstChildOfClass("Humanoid")
if hm then
pcall(function()
hm:ApplyDescription(KX.orig)
end)
end
end
if restore_desc then
KX.orig = nil
end
end
local function user_model(rig)
if KX.models[rig] then
return KX.models[rig]:Clone()
end
local uid = resolveUserId(KORBLOX_USER)
if not uid then
return nil
end
local model
local okd, desc = pcall(getDesc, KORBLOX_USER, uid)
if okd and desc then
local ok, m = pcall(function()
return Players:CreateHumanoidModelFromDescription(desc, rig)
end)
if ok and m then
model = m
end
end
if not model then
local ok, m = pcall(function()
return Players:GetCharacterAppearanceAsync(uid)
end)
if ok and m then
model = m
end
end
if not model then
local ok, m = pcall(buildModelFromInfo, uid)
if ok and m then
model = m
end
end
if model then
KX.models[rig] = model:Clone()
end
return model
end
local function copy_leg(char, hum, root)
if not root then
return false
end
local made, hide = 0, {}
if hum.RigType == Enum.HumanoidRigType.R6 then
local leg = char:FindFirstChild("Right Leg")
local up = leg and find_part(root, "RightUpperLeg")
if up then
local base = leg.CFrame * CFrame.new(0, leg.Size.Y / 2 - up.Size.Y / 2, 0)
for _, n in ipairs(R15_LEG) do
local src = find_part(root, n)
if src then
local c = src:Clone()
strip_joints(c)
c.Name = "KXL_" .. n
c.Anchored = false
c.CanCollide = false
c.CanTouch = false
c.CanQuery = false
c.Massless = true
c.Transparency = 0
c.CFrame = base * up.CFrame:ToObjectSpace(src.CFrame)
local w = Instance.new("WeldConstraint")
w.Part0 = leg
w.Part1 = c
w.Parent = c
c.Parent = char
track(c)
made = made + 1
print("[ASTA] leg part", n, src.MeshId, src.TextureID, tostring(src.Color))
end
end
table.insert(hide, leg)
else
for _, d in ipairs(root:GetDescendants()) do
if d:IsA("CharacterMesh") then
local cm = d:Clone()
cm.BodyPart = Enum.BodyPart.RightLeg
cm.Parent = char
track(cm)
made = made + 1
end
end
end
else
for _, n in ipairs(R15_LEG) do
local src, dst = find_part(root, n), char:FindFirstChild(n)
if src and dst then
local c = src:Clone()
strip_joints(c)
c.Name = "KXL_" .. n
c.Anchored = false
c.CanCollide = false
c.CanTouch = false
c.CanQuery = false
c.Massless = true
c.Transparency = 0
c.CFrame = dst.CFrame
local w = Instance.new("WeldConstraint")
w.Part0 = dst
w.Part1 = c
w.Parent = c
c.Parent = char
track(c)
table.insert(hide, dst)
made = made + 1
end
end
end
pcall(function()
root:Destroy()
end)
return made > 0, hide
end
local function build_from_gg(char, hum)
local r6 = hum.RigType == Enum.HumanoidRigType.R6
local okM, dummy = pcall(function()
local d = Instance.new("HumanoidDescription")
d.RightLeg = KORBLOX_ID
return Players:CreateHumanoidModelFromDescription(d, hum.RigType)
end)
if not (okM and dummy) then
return false
end
local made, hide = 0, {}
if r6 then
for _, d in ipairs(dummy:GetChildren()) do
if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.RightLeg then
local cm = d:Clone()
cm.Parent = char
track(cm)
made = made + 1
end
end
else
for _, n in ipairs(R15_LEG) do
local src, dst = dummy:FindFirstChild(n), char:FindFirstChild(n)
if src and dst then
local c = src:Clone()
strip_joints(c)
c.Name = "KXL_" .. n
c.Anchored = false
c.CanCollide = false
c.CanTouch = false
c.CanQuery = false
c.Massless = true
c.Transparency = 0
local textured = c:IsA("MeshPart") and c.TextureID ~= ""
c.Color = textured and Color3.new(1, 1, 1) or dst.Color
c.CFrame = dst.CFrame
local w = Instance.new("WeldConstraint")
w.Part0 = dst
w.Part1 = c
w.Parent = c
c.Parent = char
track(c)
table.insert(hide, dst)
made = made + 1
end
end
end
pcall(function()
dummy:Destroy()
end)
return made > 0, hide
end
local function build_from_asset(char, hum)
return copy_leg(char, hum, loadAssetObj(KORBLOX_ID))
end
local function build_from_user(char, hum)
local rigs = {hum.RigType}
if hum.RigType == Enum.HumanoidRigType.R6 then
rigs = {Enum.HumanoidRigType.R15, Enum.HumanoidRigType.R6}
end
for _, rig in ipairs(rigs) do
local okm, model = pcall(user_model, rig)
if okm and model then
local ok, hide = copy_leg(char, hum, model)
if ok then
return ok, hide
end
end
end
return false
end
local function build_from_desc(hum)
local ok = pcall(function()
local d = hum:GetAppliedDescription()
if not KX.orig then
KX.orig = d:Clone()
end
d.RightLeg = KORBLOX_ID
hum:ApplyDescription(d)
end)
if not ok then
return false
end
task.wait(0.4)
local ok2, cur = pcall(function()
return hum:GetAppliedDescription().RightLeg
end)
return ok2 and cur == KORBLOX_ID
end
local function build(char)
local hum = char:FindFirstChildOfClass("Humanoid")
if not hum then
return false
end
KX.char = char
if skin_has_leg(char) then
KX.mode = "skin"
return true
end
local ok, hide = build_from_gg(char, hum)
if ok then
KX.mode, KX.hide = "asset", hide or {}
apply_glow()
print("[ASTA] Korblox: built from asset id (GG method)")
return true
end
ok, hide = build_from_user(char, hum)
if ok then
KX.mode, KX.hide = "asset", hide or {}
apply_glow()
print("[ASTA] Korblox: copied from " .. KORBLOX_USER)
return true
end
ok, hide = build_from_asset(char, hum)
if ok then
KX.mode, KX.hide = "asset", hide or {}
apply_glow()
print("[ASTA] Korblox: loaded from asset id")
return true
end
if build_from_desc(hum) then
KX.mode = "desc"
print("[ASTA] Korblox: via ApplyDescription")
return true
end
KX.mode = "none"
warn("[ASTA] Korblox failed: could not fetch " .. KORBLOX_USER .. " or the leg asset (" .. tostring(hum.RigType) .. ")")
return false
end
local function apply(char, on, glow)
if glow ~= nil then
KX.glow = glow and true or false
end
if on and not char then
return false
end
if KX.busy then
return false
end
KX.busy = true
local ok = true
if on then
KX.on = true
destroy_all(false)
local okc, res = pcall(build, char)
ok = okc and res
else KX.on = false
destroy_all(true)
end
KX.busy = false
return ok
end
local acc = 0
table.insert(conns, RunService.RenderStepped:Connect(function(dt)
if closed or not KX.on then
return
end
for _, p in ipairs(KX.hide) do
if p.Parent then
if KX.hidden[p] == nil then
KX.hidden[p] = p.Transparency
end
p.Transparency = 1
end
end
acc = acc + dt
if acc < 0.6 or KX.busy then
return
end
acc = 0
local c = lp.Character
if not c then
return
end
local need = c ~= KX.char or (KX.mode == "asset" and not parts_alive(c)) or (KX.mode == "skin" and not skin_has_leg(c))
if need then
task.spawn(apply, c, true)
end
end))
return apply
end)()
local lastApplyInfo, lastSkinErr = {t = 0, ok = false, skin = 0}, ""
local function applyCurrent()
local sk = SKINS[currentSkin]
if sk.exact then
HEADLESS, KORBLOX, HIDE_LEG = false, false, ""
else HEADLESS, KORBLOX, HIDE_LEG = D_HEADLESS, D_KORBLOX, D_HIDE_LEG
end
if sk.username or sk.build then
local ok, err = applyUserSkin(sk.username or "", sk)
if ok then
return true
end
lastSkinErr = tostring(err)
toast(T("فشل السكن: ", "Skin failed: ") .. tostring(err), "bad")
return false
end
return applySkin() and true or false
end
local applying, forceApply = false, false
local lastSkinChar = nil
local charSeen = setmetatable({}, {__mode = "k"})
local toasted = setmetatable({}, {__mode = "k"})
local function resetForNewChar()
saved = nil
origDesc = nil
restoreVisual()
skinGuis = {}
fakeLegParts = {}
end
local function skinIntact(c)
if lastSkinChar ~= c then
return false
end
local ours = {}
for _, o in ipairs(skinGuis) do
ours[o] = true
end
for _, ch in ipairs(c:GetChildren()) do
if (ch:IsA("Accessory") and not nameLooksBomb(ch.Name)) or ch:IsA("Shirt") or ch:IsA("Pants") or ch:IsA("ShirtGraphic") then
if not ours[ch] then
return false
end
end
end
for _, o in ipairs(skinGuis) do
if not o:IsDescendantOf(c) then
return false
end
end
for _, o in ipairs(fakeLegParts) do
if not o:IsDescendantOf(c) then
return false
end
end
return true
end
local applyStartedAt = 0
local function doApply(silent)
if closed then
return false
end
if applying then
if os.clock() - applyStartedAt < 8 then
return false
end
applying = false
end
applying = true
applyStartedAt = os.clock()
local c0 = lp.Character
local ok, res = pcall(function()
if lastSkinChar ~= c0 then
resetForNewChar()
end
quietToast = silent and true or false
return applyCurrent()
end)
quietToast = false
applying = false
if ok and res and lp.Character == c0 then
lastSkinChar = c0
lastApplyInfo = {t = os.clock(), ok = true, skin = currentSkin}
return true
end
lastApplyInfo = {t = os.clock(), ok = false, skin = currentSkin, err = (not ok) and tostring(res) or lastSkinErr}
if not ok and lp.Character == c0 then
toast("خطأ السكن: " .. tostring(res))
end
return false
end
local function selectSkin(i)
if closed then
return
end
currentSkin = i
skinActive = true
forceApply = true
refreshSkinButtons()
end
local customAdded = {}
local function applyCustomUsername(name, onStatus)
onStatus = onStatus or function()
end
name = (string.gsub(tostring(name or ""), "^%s*@?%s*(.-)%s*$", "%1"))
if name == "" then
onStatus(T("اكتب يوزر اللاعب", "Type a username"), false)
return
end
onStatus(T("جاري البحث عن اليوزر...", "Looking up the user..."), nil)
task.spawn(function()
local uid = resolveUserId(name)
if not uid then
onStatus(T("اليوزر مو موجود", "Username not found"), false)
return
end
local idx = customAdded[uid]
if not idx or not SKINS[idx] or SKINS[idx].username ~= name then
table.insert(SKINS, {label = name, username = name, exact = true, custom = true})
idx = #SKINS
customAdded[uid] = idx
pcall(buildSkinGallery)
end
local prevIdx, prevActive = currentSkin, skinActive
onStatus(T("جاري جلب السكن...", "Fetching the skin..."), nil)
local t0 = os.clock()
selectSkin(idx)
local info
repeat task.wait(0.25)
if lastApplyInfo.t >= t0 and lastApplyInfo.skin == idx then
info = lastApplyInfo
end
until closed or info or os.clock() - t0 > 40
if closed then
return
end
if info and info.ok then
onStatus(T("تم لبس سكن ", "Applied the skin of ") .. name, true)
else onStatus(T("ما قدرت ألبس السكن: ", "Couldn't apply the skin: ") .. tostring(info and info.err or "timeout"), false)
if prevActive and SKINS[prevIdx] then
selectSkin(prevIdx)
else pcall(restoreSkin)
end
end
end)
end
loadAsset("skin", SKIN_OVERRIDE, SKIN_EMBED, function(asset)
skinTexture = asset
end)
table.insert(conns, lp.CharacterAdded:Connect(function()
if closed then
return
end
resetForNewChar()
lastSkinChar = nil
end))
table.insert(conns, lp.CharacterAppearanceLoaded:Connect(function()
if closed then
return
end
lastSkinChar = nil
end))
task.spawn(function()
local stamps = {}
local fails, failChar = 0, nil
local nextTry = 0
while not closed do
task.wait(0.1)
pcall(function()
if not skinActive or closed then
return
end
local c = getChar(lp)
if not c then
return
end
if not c:FindFirstChild("Head") then
return
end
if not (c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")) then
return
end
if charSeen[c] == nil then
charSeen[c] = os.clock()
end
local force = forceApply
if not force then
if os.clock() - charSeen[c] < 0.1 then
return
end
if os.clock() < nextTry then
return
end
if applying and os.clock() - applyStartedAt < 8 then
return
end
if skinIntact(c) then
fails = 0
return
end
end
if failChar ~= c then
failChar = c
fails = 0
end
local now, n = os.clock(), 0
for i = #stamps, 1, -1 do
if now - stamps[i] > 10 then
table.remove(stamps, i)
else n = n + 1
end
end
table.insert(stamps, now)
nextTry = now + (n >= 8 and 2 or 0.15) + math.min(fails, 5) * 0.4
forceApply = false
local ok = doApply(toasted[c] and not force)
if ok then
fails = 0
toasted[c] = true
else fails = fails + 1
end
end)
end
end)
local function isTeammate(p)
local myTeam = lp.Team
if myTeam and p.Team == myTeam then
return true
end
if lp.Neutral == false and p.Neutral == false and p.TeamColor == lp.TeamColor then
return true
end
return false
end
local OUT_WORDS = {"lobby", "spectat", "waiting", "queue", "dead", "eliminat", "out", "idle", "none", "لوبي", "متفرج", "انتظار"}
local OUT_ATTRS = {"InGame", "InMatch", "InRound", "InArena", "Playing", "IsPlaying", "Alive", "InGameplay", "InLobbyGame"}
local OUT_ATTRS_TRUE = {"InLobby", "Spectating", "IsSpectating", "Spectator", "Eliminated", "Dead", "IsDead", "AFK", "Waiting"}
local function nameIsOut(n)
n = string.lower(tostring(n or ""))
for _, w in ipairs(OUT_WORDS) do
if string.find(n, w, 1, true) then
return true
end
end
return false
end
local function isInMatch(p)
local ok, res = pcall(function()
if p.Team and nameIsOut(p.Team.Name) then
return false
end
if lp.Team and not lp.Neutral and (p.Team == nil or p.Neutral) then
return false
end
for _, holder in ipairs({p, p.Character}) do
if holder then
for _, a in ipairs(OUT_ATTRS) do
if holder:GetAttribute(a) == false then
return false
end
end
for _, a in ipairs(OUT_ATTRS_TRUE) do
if holder:GetAttribute(a) == true then
return false
end
end
for _, a in ipairs(OUT_ATTRS) do
local v = holder:FindFirstChild(a)
if v and v:IsA("BoolValue") and v.Value == false then
return false
end
end
for _, a in ipairs(OUT_ATTRS_TRUE) do
local v = holder:FindFirstChild(a)
if v and v:IsA("BoolValue") and v.Value == true then
return false
end
end
end
end
return true
end)
return (not ok) or res
end
local FLOOR_COLOR_TOL = 0.14
local floorParams = RaycastParams.new()
floorParams.FilterType = Enum.RaycastFilterType.Exclude
floorParams.RespectCanCollide = true
local floorCache = setmetatable({}, {__mode = "k"})
local myFloor = {inst = nil, t = 0}
local function floorUnder(char)
local root = char and char:FindFirstChild("HumanoidRootPart")
if not root then
return nil
end
local ex = {char}
if lp.Character and lp.Character ~= char then
table.insert(ex, lp.Character)
end
floorParams.FilterDescendantsInstances = ex
local r = workspace:Raycast(root.Position, Vector3.new(0, -25, 0), floorParams)
return r and r.Instance or nil
end
local function sameFloor(a, b)
if a == b then
return true
end
if a.Material ~= b.Material then
return false
end
local ca, cb = a.Color, b.Color
return math.abs(ca.R - cb.R) < FLOOR_COLOR_TOL and math.abs(ca.G - cb.G) < FLOOR_COLOR_TOL and math.abs(ca.B - cb.B) < FLOOR_COLOR_TOL
end
local feedSet, feedAt, feedScanAt = {}, 0, 0
local function scanFeed()
local now = os.clock()
if now - feedScanAt < 0.5 then
return
end
feedScanAt = now
local pg = lp:FindFirstChildOfClass("PlayerGui")
if not pg then
return
end
local names = {}
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp then
names[string.lower(p.Name)] = p
names[string.lower(p.DisplayName)] = p
end
end
local found, count = {}, 0
pcall(function()
for _, d in ipairs(pg:GetDescendants()) do
if d:IsA("TextLabel") and d.Visible and d.AbsoluteSize.X > 0 and not d:IsDescendantOf(gui) and not d:FindFirstAncestorWhichIsA("BillboardGui") then
local t = string.lower((d.Text or ""):gsub("^%s+", ""):gsub("%s+$", ""))
local pl = names[t]
if pl and not found[pl] then
found[pl] = true
count = count + 1
end
end
end
end)
if count >= 1 and count <= 6 then
feedSet = found
feedAt = now
elseif now - feedAt > 4 then
feedSet = {}
end
end
local function inArena(p)
scanFeed()
if feedSet[p] and os.clock() - feedAt < 4 then
return true
end
local ch = p.Character
if not ch then
return false
end
local now = os.clock()
local f = floorUnder(lp.Character)
if f then
myFloor.inst = f
myFloor.t = now
end
local mine = myFloor.inst
if not mine or not mine.Parent then
return true
end
local c = floorCache[p]
if not c or now - c.t > 0.2 then
local inst = floorUnder(ch)
c = {inst = inst or (c and c.inst), t = now}
floorCache[p] = c
end
if not c.inst or not c.inst.Parent then
return true
end
return sameFloor(mine, c.inst)
end
local function isGreenColor(c)
return c and c.G > 0.45 and c.G > c.R * 1.35 and c.G > c.B * 1.35
end
local function colorsOf(inst)
local out = {}
if inst:IsA("Highlight") then
table.insert(out, inst.FillColor)
table.insert(out, inst.OutlineColor)
elseif inst:IsA("SelectionBox") or inst:IsA("SelectionSphere") then
table.insert(out, inst.Color3)
elseif inst:IsA("TextLabel") or inst:IsA("TextButton") then
table.insert(out, inst.TextColor3)
if inst.BackgroundTransparency < 0.9 then
table.insert(out, inst.BackgroundColor3)
end
elseif inst:IsA("ImageLabel") then
table.insert(out, inst.ImageColor3)
elseif inst:IsA("Frame") and inst.BackgroundTransparency < 0.9 then
table.insert(out, inst.BackgroundColor3)
elseif inst:IsA("UIStroke") then
table.insert(out, inst.Color)
end
return out
end
local function hasGreenMark(root)
for _, d in ipairs(root:GetDescendants()) do
for _, c in ipairs(colorsOf(d)) do
if isGreenColor(c) then
return true
end
end
end
return false
end
local greenCache, greenAt = {}, 0
local function refreshGreen()
local now = os.clock()
if now - greenAt < 0.6 then
return
end
greenAt = now
greenCache = {}
local pg = lp:FindFirstChildOfClass("PlayerGui")
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp then
local green = false
pcall(function()
if p.Team and isGreenColor(p.TeamColor.Color) then
green = true
end
local ch = p.Character
if not green and ch then
for _, d in ipairs(ch:GetDescendants()) do
if d:IsA("Highlight") or d:IsA("SelectionBox") or d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
if d:IsA("Highlight") or d:IsA("SelectionBox") then
for _, c in ipairs(colorsOf(d)) do
if isGreenColor(c) then
green = true
end
end
else
if hasGreenMark(d) then
green = true
end
end
end
if green then
break
end
end
if not green then
for _, root in ipairs({workspace, pg}) do
if root and not green then
for _, d in ipairs(root:GetChildren()) do
if d:IsA("Highlight") or d:IsA("SelectionBox") or d:IsA("BillboardGui") then
local ad = d.Adornee
if ad and (ad == ch or ad:IsDescendantOf(ch)) then
if d:IsA("BillboardGui") then
if hasGreenMark(d) then
green = true
end
else
for _, c in ipairs(colorsOf(d)) do
if isGreenColor(c) then
green = true
end
end
end
end
end
end
end
end
end
end
end)
greenCache[p] = green
end
end
end
local assistRange, stopDist = 30, ASSIST_STOP_DIST
local autoClick, clickCPS, CLICK_RANGE = false, 8, 15
local targetLabel, songSound = nil, nil
local lastLbl, lastLblAt, lastClick = "", 0, 0
local function setTargetText(t)
if targetLabel and t ~= lastLbl and os.clock() - lastLblAt > 0.15 then
lastLbl, lastLblAt = t, os.clock()
targetLabel.Text = t
end
end
local VIM = nil
pcall(function()
VIM = game:GetService("VirtualInputManager")
end)
local function doClick(tool)
pcall(function()
tool:Activate()
end)
local done = false
if mouse1click then
done = pcall(mouse1click)
end
if not done and VIM then
pcall(function()
local c = workspace.CurrentCamera.ViewportSize
VIM:SendMouseButtonEvent(c.X / 2, c.Y / 2, 0, true, game, 0)
VIM:SendMouseButtonEvent(c.X / 2, c.Y / 2, 0, false, game, 0)
end)
end
end
local function getTool(ch)
local t = ch:FindFirstChildOfClass("Tool")
if t then
return t
end
local hum = ch:FindFirstChildOfClass("Humanoid")
local bp = lp:FindFirstChildOfClass("Backpack")
local bt = bp and bp:FindFirstChildOfClass("Tool")
if bt and hum then
pcall(function()
hum:EquipTool(bt)
end)
return bt
end
return nil
end
local STOMP = {busy = false, list = {}, range = 70, life = 4} do
local function watch(p)
local function hook(ch)
local h = ch:WaitForChild("Humanoid", 5)
if not h then
return
end
h.Died:Connect(function()
STOMP.list[ch] = {t = os.clock(), hrp = ch:FindFirstChild("HumanoidRootPart"), p = p}
end)
end
if p.Character then
task.spawn(hook, p.Character)
end
p.CharacterAdded:Connect(hook)
end
for _, p in ipairs(Players:GetPlayers()) do
if p ~= lp then
watch(p)
end
end
table.insert(conns, Players.PlayerAdded:Connect(function(p)
if p ~= lp then
watch(p)
end
end))
local acc, lastJump = 0, 0
table.insert(conns, RunService.Heartbeat:Connect(function(dt)
if closed then
return
end
acc = acc + dt
if acc < 0.1 then
return
end
acc = 0
if not autoClick then
STOMP.busy = false
return
end
local ch = lp.Character
local hum = ch and ch:FindFirstChildOfClass("Humanoid")
local root = ch and ch:FindFirstChild("HumanoidRootPart")
if not (hum and root) or hum.Health <= 0 then
STOMP.busy = false
return
end
STOMP.busy = false
local now = os.clock()
if hum.FloorMaterial ~= Enum.Material.Air and now - lastJump > 0.28 then
lastJump = now
hum.Jump = true
end
local tool = getTool(ch)
if tool and now - lastClick >= 1 / math.max(clickCPS, 1) then
lastClick = now
doClick(tool)
end
end))
end
local hbAcc = 0
table.insert(conns, RunService.Heartbeat:Connect(function(dt)
if closed then
return
end
hbAcc = hbAcc + dt
if hbAcc < 0.15 then
return
end
hbAcc = 0
if not (running or autoClick) then
setTargetText(T("الهدف: متوقف", "Target: Off"))
return
end
local character = lp.Character
if not character then
return
end
local tool = getTool(character)
if not tool then
setTargetText(T("الهدف: بانتظار أداة", "Target: Waiting for Tool"))
return
end
local humanoid = character:FindFirstChild("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")
if not humanoid or not rootPart then
return
end
refreshGreen()
local nearest, nearestName = nil, ""
local shortest = running and assistRange or CLICK_RANGE
local clickDist = math.huge
for _, p in ipairs(Players:GetPlayers()) do
local pc = p.Character
local pr = pc and pc:FindFirstChild("HumanoidRootPart")
local th = pc and pc:FindFirstChildOfClass("Humanoid")
if p ~= lp and pr and th and th.Health > 0 and not isTeammate(p) and not greenCache[p] then
local dist = (rootPart.Position - pr.Position).Magnitude
if dist < clickDist then
clickDist = dist
end
if running and dist < shortest and isInMatch(p) and inArena(p) then
shortest = dist
nearest = pr
nearestName = p.DisplayName or p.Name
end
end
end
if running and nearest then
setTargetText(T("الهدف: ", "Target: ") .. nearestName)
if not STOMP.busy then
if shortest > stopDist + 1 then
local now_m = os.clock()
if not _lastMT or now_m - _lastMT > 0.25 then
_lastMT = now_m
humanoid:MoveTo(nearest.Position)
end
end
end
elseif clickDist <= CLICK_RANGE then
setTargetText(T("الهدف: قريب", "Target: Close"))
else setTargetText(T("الهدف: يبحث...", "Target: Searching..."))
end
if autoClick and clickDist <= CLICK_RANGE and os.clock() - lastClick >= 1 / math.max(clickCPS, 1) then
lastClick = os.clock()
doClick(tool)
end
end))
local function buildIceScene(host)
local scene = Instance.new("Frame")
scene.Name = "AstaScene"
scene.Size = UDim2.new(1, 0, 1, 0)
scene.BackgroundTransparency = 1
scene.BorderSizePixel = 0
scene.ClipsDescendants = true
scene.ZIndex = 1
scene.Parent = host
local sceneCorner = Instance.new("UICorner")
sceneCorner.CornerRadius = UDim.new(0, 8)
sceneCorner.Parent = scene
local function mkFrame(x, y, w, h, color, z)
local f = Instance.new("Frame")
f.Position = UDim2.new(0, x, 0, y)
f.Size = UDim2.new(0, w, 0, h)
f.BackgroundColor3 = color
f.BorderSizePixel = 0
f.ZIndex = z
f.Parent = scene
return f
end
local stars = {}
for i = 1, 16 do
local sz = math.random(1, 2)
local st = mkFrame(math.random(4, 204), math.random(3, 44), sz, sz, Color3.fromRGB(255, 255, 255), 1)
stars[i] = {obj = st, ph = math.random() * 6.28, sp = 1 + math.random() * 2}
end
local aurora = mkFrame(-20, 14, 250, 34, Color3.fromRGB(255, 255, 255), 1)
local auroraCorner = Instance.new("UICorner")
auroraCorner.CornerRadius = UDim.new(0.5, 0)
auroraCorner.Parent = aurora
local auroraGrad = Instance.new("UIGradient")
auroraGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 255, 200)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 200, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 120, 255)) })
auroraGrad.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.82), NumberSequenceKeypoint.new(1, 1) })
auroraGrad.Parent = aurora
local function peak(cx, cy, size, z, baseColor, capColor)
local d = Instance.new("Frame")
d.Size = UDim2.new(0, size, 0, size)
d.Position = UDim2.new(0, cx - size / 2, 0, cy - size / 2)
d.Rotation = 45
d.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
d.BorderSizePixel = 0
d.ZIndex = z
d.Parent = scene
local g = Instance.new("UIGradient")
g.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, capColor), ColorSequenceKeypoint.new(0.3, capColor), ColorSequenceKeypoint.new(0.42, baseColor), ColorSequenceKeypoint.new(1, baseColor) })
g.Rotation = 45
g.Parent = d
return d
end
peak(155, 92, 64, 1, Color3.fromRGB(95, 140, 205), Color3.fromRGB(235, 246, 255))
peak(48, 96, 74, 1, Color3.fromRGB(70, 115, 190), Color3.fromRGB(245, 250, 255))
peak(105, 104, 52, 1, Color3.fromRGB(110, 155, 215), Color3.fromRGB(240, 248, 255))
local function hill(cx, cy, r, z, c1, c2)
local h = Instance.new("Frame")
h.Size = UDim2.new(0, r * 2, 0, r * 2)
h.Position = UDim2.new(0, cx - r, 0, cy - r)
h.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
h.BorderSizePixel = 0
h.ZIndex = z
h.Parent = scene
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0.5, 0)
c.Parent = h
local g = Instance.new("UIGradient")
g.Color = ColorSequence.new(c1, c2)
g.Rotation = 90
g.Parent = h
end
hill(28, 162, 75, 2, Color3.fromRGB(245, 251, 255), Color3.fromRGB(190, 215, 240))
hill(158, 168, 72, 2, Color3.fromRGB(240, 249, 255), Color3.fromRGB(185, 212, 240))
hill(98, 182, 76, 3, Color3.fromRGB(252, 254, 255), Color3.fromRGB(200, 224, 245))
local function pine(x, baseY, scale, z)
local trunk = mkFrame(x - 1, baseY - 3, 3, 5, Color3.fromRGB(70, 50, 40), z)
local sizes = {13, 11, 9}
local ys = {baseY - 9, baseY - 15, baseY - 21}
for i = 1, 3 do
local sz = sizes[i] * scale
peak(x, ys[i] * 1 - (scale - 1) * 6, sz, z, Color3.fromRGB(28, 82, 110), Color3.fromRGB(240, 250, 255))
end
end
pine(12, 99, 1, 3)
pine(28, 102, 1.15, 3)
pine(178, 100, 1.1, 3)
pine(194, 97, 1, 3)
pine(150, 104, 0.9, 3)
local snowHolder = Instance.new("Frame")
snowHolder.Name = "AstaSnow"
snowHolder.Size = UDim2.new(1, 0, 1, 0)
snowHolder.BackgroundTransparency = 1
snowHolder.BorderSizePixel = 0
snowHolder.ClipsDescendants = true
snowHolder.ZIndex = 2
snowHolder.Parent = host
local SNOW_COUNT = 34
local flakes = {}
for i = 1, SNOW_COUNT do
local size = math.random(3, 7)
local f = Instance.new("Frame")
f.Size = UDim2.new(0, size, 0, size)
f.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
f.BackgroundTransparency = math.random(0, 4) / 10
f.BorderSizePixel = 0
f.ZIndex = 2
f.Parent = snowHolder
local fc = Instance.new("UICorner")
fc.CornerRadius = UDim.new(1, 0)
fc.Parent = f
flakes[i] = { obj = f, x = math.random() , y = math.random() * 1.2 - 0.1, speed = 0.12 + math.random() * 0.25 + size * 0.02, sway = 0.01 + math.random() * 0.03, phase = math.random() * 6.28, swaySpeed = 0.8 + math.random() * 1.5 }
end
task.spawn(function()
local last = os.clock()
while host and host.Parent do
local now = os.clock()
local dt = math.min(now - last, 0.1)
last = now
if host.Parent and host.Parent.Visible and host.Parent.Parent and host.Parent.Parent.Visible then
for _, fl in ipairs(flakes) do
fl.y = fl.y + fl.speed * dt
if fl.y > 1.05 then
fl.y = -0.08
fl.x = math.random()
end
local sx = fl.x + math.sin(now * fl.swaySpeed + fl.phase) * fl.sway
fl.obj.Position = UDim2.new(sx, 0, fl.y, 0)
end
auroraGrad.Offset = Vector2.new(math.sin(now * 0.5) * 0.35, 0)
for _, st in ipairs(stars) do
st.obj.BackgroundTransparency = 0.15 + (math.sin(now * st.sp + st.ph) + 1) * 0.35
end
end
task.wait()
end
end)
end
local CINE = {on = false} do
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local cam = workspace.CurrentCamera
local NODOF = {FarIntensity = 0, FocusDistance = 55, InFocusRadius = 45, NearIntensity = 0}
local PRESETS = { cinematic = { timeOfDay = "17:40:00", exposure = 0.15, brightness = 2.2, warmSun = Color3.fromRGB(255, 214, 170), shadowTint = Color3.fromRGB(70, 85, 120), bloom = {Intensity = 0.55, Size = 32, Threshold = 1.0}, sunRays = {Intensity = 0.12, Spread = 0.75}, grade = {Brightness = 0.02, Contrast = 0.22, Saturation = 0.12, Tint = Color3.fromRGB(255, 242, 228)}, dof = {FarIntensity = 0.18, FocusDistance = 55, InFocusRadius = 45, NearIntensity = 0}, atmosphere = {Density = 0.33, Offset = 0.25, Color = Color3.fromRGB(205, 190, 175), Decay = Color3.fromRGB(110, 100, 110), Glare = 0.4, Haze = 1.6}, vignette = true, fov = 0, }, clean = { timeOfDay = "14:00:00", exposure = 0.2, brightness = 3, ambient = Color3.fromRGB(150, 150, 160), outdoor = Color3.fromRGB(165, 165, 175), warmSun = Color3.new(0, 0, 0), shadowTint = Color3.new(0, 0, 0), bloom = {Intensity = 0.3, Size = 24, Threshold = 1.1}, sunRays = {Intensity = 0.05, Spread = 0.6}, grade = {Brightness = 0.03, Contrast = 0.12, Saturation = 0.22, Tint = Color3.fromRGB(255, 250, 245)}, dof = NODOF, atmosphere = nil, vignette = false, fov = 0, }, black = { timeOfDay = "00:00:00", exposure = -0.2, brightness = 0.8, ambient = Color3.fromRGB(30, 30, 38), outdoor = Color3.fromRGB(40, 40, 50), warmSun = Color3.new(0, 0, 0), shadowTint = Color3.new(0, 0, 0), bloom = {Intensity = 0.3, Size = 24, Threshold = 1.2}, sunRays = {Intensity = 0, Spread = 0.5}, grade = {Brightness = -0.05, Contrast = 0.4, Saturation = -0.2, Tint = Color3.fromRGB(215, 215, 230)}, dof = NODOF, atmosphere = {Density = 0.4, Offset = 0, Color = Color3.new(0, 0, 0), Decay = Color3.new(0, 0, 0), Glare = 0, Haze = 0}, vignette = true, fov = 0, }, bw = { timeOfDay = "14:00:00", exposure = 0.1, brightness = 2.4, ambient = Color3.fromRGB(120, 120, 126), outdoor = Color3.fromRGB(135, 135, 142), warmSun = Color3.new(0, 0, 0), shadowTint = Color3.new(0, 0, 0), bloom = {Intensity = 0.2, Size = 24, Threshold = 1.1}, sunRays = {Intensity = 0, Spread = 0.5}, grade = {Brightness = 0, Contrast = 0.3, Saturation = -1, Tint = Color3.new(1, 1, 1)}, dof = NODOF, atmosphere = nil, vignette = true, fov = 0, }, nvidia = { timeOfDay = "13:30:00", exposure = 0.1, brightness = 2.8, ambient = Color3.fromRGB(120, 125, 135), outdoor = Color3.fromRGB(150, 155, 165), warmSun = Color3.fromRGB(255, 244, 225), shadowTint = Color3.fromRGB(60, 70, 95), bloom = {Intensity = 0.45, Size = 28, Threshold = 1.0}, sunRays = {Intensity = 0.1, Spread = 0.7}, grade = {Brightness = 0.01, Contrast = 0.35, Saturation = 0.4, Tint = Color3.fromRGB(245, 255, 240)}, dof = NODOF, atmosphere = {Density = 0.2, Offset = 0.1, Color = Color3.fromRGB(190, 205, 225), Decay = Color3.fromRGB(120, 130, 150), Glare = 0.2, Haze = 0.6}, vignette = false, fov = 0, }, sunset = { timeOfDay = "18:20:00", exposure = 0.2, brightness = 2.6, ambient = Color3.fromRGB(110, 85, 80), outdoor = Color3.fromRGB(140, 105, 95), warmSun = Color3.fromRGB(255, 170, 120), shadowTint = Color3.fromRGB(90, 70, 110), bloom = {Intensity = 0.7, Size = 36, Threshold = 0.95}, sunRays = {Intensity = 0.2, Spread = 0.8}, grade = {Brightness = 0.02, Contrast = 0.2, Saturation = 0.3, Tint = Color3.fromRGB(255, 205, 175)}, dof = NODOF, atmosphere = {Density = 0.3, Offset = 0.2, Color = Color3.fromRGB(235, 175, 140), Decay = Color3.fromRGB(140, 90, 100), Glare = 0.5, Haze = 1.2}, vignette = true, fov = 0, }, }
CINE.presetList = { {id = "cinematic", en = "Cinematic", ar = "سينمائية"}, {id = "clean", en = "Clean bright", ar = "واضحة ونظيفة"}, {id = "black", en = "Black", ar = "أسود"}, {id = "bw", en = "Black & white", ar = "أبيض وأسود"}, {id = "nvidia", en = "NVIDIA", ar = "نيفيديا"}, {id = "sunset", en = "Sunset", ar = "غروب"}, }
CINE.preset = "cinematic"
local S = PRESETS.cinematic
local KEYS = {"ClockTime", "Brightness", "ExposureCompensation", "Ambient", "OutdoorAmbient", "ColorShift_Top", "ColorShift_Bottom", "EnvironmentDiffuseScale", "EnvironmentSpecularScale", "GlobalShadows", "ShadowSoftness", "FogEnd", "FogStart"}
local saved, created, disabled, oldAtmo, oldAtmoParent, oldFov = {}, {}, {}, nil, nil, nil
local function add(class, props, parent)
local o = new(class, props, parent or Lighting)
table.insert(created, o)
return o
end
function CINE.apply()
if CINE.on or closed then
return
end
CINE.on = true
saved, created, disabled = {}, {}, {}
for _, k in ipairs(KEYS) do
pcall(function()
saved[k] = Lighting[k]
end)
end
oldFov = cam and cam.FieldOfView
for _, e in ipairs(Lighting:GetChildren()) do
pcall(function()
if e:IsA("PostEffect") and e.Enabled then
e.Enabled = false
table.insert(disabled, e)
end
end)
end
oldAtmo = Lighting:FindFirstChildOfClass("Atmosphere")
oldAtmoParent = oldAtmo and oldAtmo.Parent
if oldAtmo then
pcall(function()
oldAtmo.Parent = nil
end)
end
pcall(function()
if S.timeOfDay ~= "" then
Lighting.TimeOfDay = S.timeOfDay
end
Lighting.Brightness = S.brightness
Lighting.ExposureCompensation = S.exposure
Lighting.Ambient = S.ambient or Color3.fromRGB(70, 74, 88)
Lighting.OutdoorAmbient = S.outdoor or Color3.fromRGB(95, 100, 120)
Lighting.ColorShift_Top = S.warmSun
Lighting.ColorShift_Bottom = S.shadowTint
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.15
Lighting.FogStart = 0
Lighting.FogEnd = 100000
end)
pcall(function()
sethiddenproperty(Lighting, "Technology", Enum.Technology.Future)
end)
pcall(function()
settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
end)
if Terrain then
pcall(function()
Terrain.Decoration = true
end)
end
add("BloomEffect", S.bloom)
add("SunRaysEffect", S.sunRays)
add("ColorCorrectionEffect", {Brightness = S.grade.Brightness, Contrast = S.grade.Contrast, Saturation = S.grade.Saturation, TintColor = S.grade.Tint})
add("DepthOfFieldEffect", S.dof)
if S.atmosphere then
add("Atmosphere", S.atmosphere)
end
if cam and S.fov > 0 then
pcall(function()
cam.FieldOfView = S.fov
end)
end
if S.vignette then
local function edge(pos, size, rot)
local f = add("Frame", {BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, Position = pos, Size = size, ZIndex = 0, Active = false}, gui)
new("UIGradient", {Rotation = rot, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1)})}, f)
end
edge(UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0.18, 0), 90)
edge(UDim2.new(0, 0, 0.82, 0), UDim2.new(1, 0, 0.18, 0), 270)
edge(UDim2.new(0, 0, 0, 0), UDim2.new(0.12, 0, 1, 0), 0)
edge(UDim2.new(0.88, 0, 0, 0), UDim2.new(0.12, 0, 1, 0), 180)
end
end
function CINE.restore()
if not CINE.on then
return
end
CINE.on = false
for _, o in ipairs(created) do
pcall(function()
o:Destroy()
end)
end
for _, e in ipairs(disabled) do
pcall(function()
e.Enabled = true
end)
end
if oldAtmo and oldAtmoParent then
pcall(function()
oldAtmo.Parent = oldAtmoParent
end)
end
for k, v in pairs(saved) do
pcall(function()
Lighting[k] = v
end)
end
if cam and oldFov then
pcall(function()
cam.FieldOfView = oldFov
end)
end
created, disabled = {}, {}
end
function CINE.setPreset(id)
if not PRESETS[id] then
return
end
local was = CINE.on
if was then
CINE.restore()
end
CINE.preset = id
S = PRESETS[id]
if was then
CINE.apply()
end
end
end
local BOMBSKIN = {on = false} do
local RED, WHITE = Color3.fromRGB(255, 85, 110), Color3.fromRGB(255, 255, 255)
local NAMES = {"bomb", "قنبل"}
local orig = setmetatable({}, {__mode = "k"})
local lights = {}
local cache = {}
local phase = {}
local conn, acc = nil, 0
local STYLES = { redwhite = {c1 = RED, c2 = WHITE, flash = true}, red = {c1 = Color3.fromRGB(230, 25, 40), c2 = Color3.fromRGB(230, 25, 40), flash = false}, redblack = {c1 = Color3.fromRGB(230, 25, 40), c2 = Color3.fromRGB(15, 15, 18), flash = true}, black = {c1 = Color3.fromRGB(15, 15, 18), c2 = Color3.fromRGB(15, 15, 18), flash = false}, gold = {c1 = Color3.fromRGB(255, 200, 40), c2 = Color3.fromRGB(255, 255, 255), flash = true}, blue = {c1 = Color3.fromRGB(40, 120, 255), c2 = Color3.fromRGB(255, 255, 255), flash = true}, }
BOMBSKIN.styleList = { {id = "redwhite", en = "Red / White", ar = "أحمر / أبيض"}, {id = "red", en = "Red", ar = "أحمر ثابت"}, {id = "redblack", en = "Red / Black", ar = "أحمر / أسود"}, {id = "black", en = "Black", ar = "أسود"}, {id = "gold", en = "Gold", ar = "ذهبي"}, {id = "blue", en = "Blue", ar = "أزرق"}, }
BOMBSKIN.style = "redwhite"
function BOMBSKIN.setStyle(id)
if not STYLES[id] then
return
end
BOMBSKIN.style = id
for _, info in pairs(cache) do
info.last = nil
end
end
local function isBomb(name)
name = string.lower(name)
for _, k in ipairs(NAMES) do
if string.find(name, k, 1, true) then
return true
end
end
return false
end
local function addParts(inst, list)
if inst:IsA("BasePart") then
table.insert(list, inst)
end
for _, d in ipairs(inst:GetDescendants()) do
if d:IsA("BasePart") then
table.insert(list, d)
end
end
end
local function readCounter(char)
for _, d in ipairs(char:GetDescendants()) do
if d:IsA("TextLabel") and d:FindFirstAncestorWhichIsA("BillboardGui") then
local n = tonumber(d.Text)
if n then
return n
end
end
end
end
local function scan()
for _, p in ipairs(Players:GetPlayers()) do
local char = p.Character
if char then
local list = {}
for _, c in ipairs(char:GetChildren()) do
if isBomb(c.Name) then
addParts(c, list)
end
end
if #list > 0 then
local o = cache[char]
cache[char] = {parts = list, n = readCounter(char), last = (o and #o.parts == #list) and o.last or nil}
else cache[char] = nil
end
end
end
for char in pairs(cache) do
if not char.Parent then
cache[char] = nil
end
end
end
local function paint(part, color)
if not orig[part] then
local tex
if part:IsA("MeshPart") then
tex = part.TextureID
elseif part:IsA("SpecialMesh") then
tex = part.TextureId
end
orig[part] = {Color = part.Color, Material = part.Material, Reflectance = part.Reflectance, tex = tex}
pcall(function()
if part:IsA("MeshPart") then
part.TextureID = ""
end
end)
end
part.Material = Enum.Material.SmoothPlastic
part.Color = color
part.Reflectance = 0
for _, ch in ipairs(part:GetChildren()) do
if ch:IsA("SpecialMesh") then
pcall(function()
ch.TextureId = ""
end)
end
end
end
function BOMBSKIN.set(v)
if v == BOMBSKIN.on then
return
end
BOMBSKIN.on = v
if v then
scan()
acc = 0
conn = RunService.Heartbeat:Connect(function(dt)
if closed then
return
end
acc = acc + dt
if acc >= 0.5 then
acc = 0
scan()
end
for char, info in pairs(cache) do
local rate = info.n and math.clamp(14 - info.n, 4, 12) or 5
phase[char] = (phase[char] or 0) + dt * rate
local st = STYLES[BOMBSKIN.style] or STYLES.redwhite
local on = (not st.flash) or math.sin(phase[char]) > 0
if info.last ~= on then
info.last = on
local col = on and st.c1 or st.c2
for i, part in ipairs(info.parts) do
if part.Parent then
paint(part, col)
end
end
end
end
end)
table.insert(conns, conn)
else
if conn then
conn:Disconnect()
conn = nil
end
for part, o in pairs(orig) do
pcall(function()
if part.Parent then
part.Color = o.Color
part.Material = o.Material
part.Reflectance = o.Reflectance
if o.tex ~= nil and part:IsA("MeshPart") then
part.TextureID = o.tex
end
end
end)
end
for _, l in pairs(lights) do
pcall(function()
l:Destroy()
end)
end
orig = setmetatable({}, {__mode = "k"})
lights = {}
cache = {}
phase = {}
end
end
end
local function unload()
restoreSkin()
pcall(CINE.restore)
pcall(BOMBSKIN.set, false)
pcall(function()
CINE.fovValue = nil
workspace.CurrentCamera.FieldOfView = 70
end)
pcall(applyKorblox, lp.Character, false)
closed = true
running = false
autoClick = false
pcall(function()
if _G.AstaConn then
_G.AstaConn:Disconnect()
end
end)
pcall(function()
for _, c in ipairs(_G.AstaManualConns or {}) do
pcall(function()
c:Disconnect()
end)
end
end)
pcall(function()
RunService:UnbindFromRenderStep("AstaAssistDrive")
end)
pcall(function()
RunService:UnbindFromRenderStep("AstaThumbVis")
end)
pcall(function()
RunService:UnbindFromRenderStep("AstaWallKeep")
end)
pcall(function()
if songSound then
songSound:Destroy()
end
end)
pcall(function()
local f = workspace:FindFirstChild("AstaFX")
if f then
f:Destroy()
end
end)
for _, cn in ipairs(conns) do
pcall(function()
cn:Disconnect()
end)
end
gui:Destroy()
end
local KFX = {current = 1, range = 45}
KFX.list = { {id = "none", en = "None", ar = "بدون"}, {id = "ghost", en = "Ghost", ar = "شبح"}, {id = "burn", en = "Burn", ar = "حرق"}, {id = "weightless", en = "Weightless", ar = "خالي من الوزن"}, {id = "balloon", en = "Balloon", ar = "بالون"}, {id = "blackheart", en = "Black Heart", ar = "قلب أسود"}, {id = "freeze", en = "Freeze", ar = "تجميد"}, {id = "gold", en = "Gold", ar = "ذهب"}, {id = "thunder", en = "Thunder", ar = "الرعد"}, {id = "silver", en = "Silver", ar = "فضة"}, {id = "redbomb", en = "Red Bomb", ar = "القنبلة الحمراء"}, }
do local function __iife23508()
local Debris = game:GetService("Debris")
local rng = Random.new()
for _, o in ipairs(workspace:GetChildren()) do
if o.Name == "AstaFX" then
o:Destroy()
end
end
local folder = new("Folder", {Name = "AstaFX"}, workspace)
local FX = {}
local H = {}
function H.partsOf(m)
local l = {}
for _, d in ipairs(m:GetDescendants()) do
if d:IsA("BasePart") then
table.insert(l, d)
end
end
return l
end
function H.ghostPart(props)
props.Anchored = true
props.CanCollide = false
props.CanQuery = false
props.CanTouch = false
return new("Part", props, folder)
end
function H.run(dur, step)
local t0 = os.clock()
local conn
conn = RunService.Heartbeat:Connect(function(dt)
local a = (os.clock() - t0) / dur
if a >= 1 or closed then
conn:Disconnect()
pcall(step, 1, dt)
return
end
pcall(step, a, dt)
end)
end
function H.fade(m, dur)
for _, d in ipairs(m:GetDescendants()) do
if d:IsA("BasePart") or d:IsA("Decal") then
TweenService:Create(d, TweenInfo.new(dur), {Transparency = 1}):Play()
elseif d:IsA("Fire") or d:IsA("Smoke") or d:IsA("ParticleEmitter") then
d.Enabled = false
elseif d:IsA("PointLight") then
TweenService:Create(d, TweenInfo.new(dur), {Brightness = 0}):Play()
elseif d:IsA("Highlight") then
TweenService:Create(d, TweenInfo.new(dur), {FillTransparency = 1, OutlineTransparency = 1}):Play()
end
end
end
function H.strip(m)
for _, d in ipairs(m:GetDescendants()) do
pcall(function()
if d:IsA("Shirt") or d:IsA("Pants") or d:IsA("ShirtGraphic") or d:IsA("BodyColors") or d:IsA("SurfaceAppearance") or d:IsA("Decal") or d:IsA("Texture") or d:IsA("CharacterMesh") then
d:Destroy()
elseif d:IsA("MeshPart") then
d.TextureID = ""
elseif d:IsA("SpecialMesh") then
d.TextureId = ""
end
end)
end
end
function H.paint(parts, color, material, reflect, dur)
for _, p in ipairs(parts) do
if p.Name ~= "HumanoidRootPart" then
p.Material = material
p.Reflectance = reflect or 0
if dur then
TweenService:Create(p, TweenInfo.new(dur), {Color = color}):Play()
else p.Color = color
end
end
end
end
function H.sparkles(parts, color, rate)
local list = {}
for _, p in ipairs(parts) do
if p.Name == "Torso" or p.Name == "UpperTorso" or p.Name == "Head" then
table.insert(list, new("ParticleEmitter", {Color = ColorSequence.new(color), Size = NumberSequence.new(0.6, 0), Lifetime = NumberRange.new(0.8, 1.4), Rate = rate or 30, Speed = NumberRange.new(3, 7), SpreadAngle = Vector2.new(180, 180), LightEmission = 1, Transparency = NumberSequence.new(0, 1)}, p))
end
end
return list
end
function H.shards(pos, color, material, count, speed, life)
local list = {}
for i = 1, count do
local s = rng:NextNumber(0.3, 0.9)
local p = H.ghostPart({Size = Vector3.new(s, s * rng:NextNumber(0.6, 1.4), s * rng:NextNumber(0.6, 1.4)), Color = color, Material = material, CFrame = CFrame.new(pos + Vector3.new(rng:NextNumber(-1.2, 1.2), rng:NextNumber(-2, 2), rng:NextNumber(-1.2, 1.2))) * CFrame.Angles(rng:NextNumber(0, 6), rng:NextNumber(0, 6), rng:NextNumber(0, 6))})
local dir = Vector3.new(rng:NextNumber(-1, 1), rng:NextNumber(0.2, 1.2), rng:NextNumber(-1, 1)).Unit
list[i] = {p = p, v = dir * rng:NextNumber(0.5, 1) * speed, w = Vector3.new(rng:NextNumber(-6, 6), rng:NextNumber(-6, 6), rng:NextNumber(-6, 6))}
Debris:AddItem(p, life + 0.5)
end
H.run(life, function(a, dt)
for _, s in ipairs(list) do
if s.p.Parent then
s.v = s.v + Vector3.new(0, -60 * dt, 0)
s.p.CFrame = CFrame.new(s.p.Position + s.v * dt) * (s.p.CFrame - s.p.Position) * CFrame.Angles(s.w.X * dt, s.w.Y * dt, s.w.Z * dt)
if a > 0.6 then
s.p.Transparency = (a - 0.6) / 0.4
end
end
end
end)
end
function H.flatRing(pos, color)
local r = H.ghostPart({Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.3, 2, 2), Color = color, Material = Enum.Material.Neon, CFrame = CFrame.new(pos - Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, 0, math.pi / 2)})
TweenService:Create(r, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.new(0.3, 22, 22), Transparency = 1}):Play()
Debris:AddItem(r, 1)
end
function H.bolt(top, bottom, color, thick)
local pts = {top}
for i = 1, 8 do
table.insert(pts, top:Lerp(bottom, i / 9) + Vector3.new(rng:NextNumber(-3, 3), 0, rng:NextNumber(-3, 3)))
end
table.insert(pts, bottom)
local made = {}
for i = 1, #pts - 1 do
local a, b = pts[i], pts[i + 1]
local len = (b - a).Magnitude
local p = H.ghostPart({Size = Vector3.new(thick, thick, len), Color = color, Material = Enum.Material.Neon, CFrame = CFrame.lookAt(a, b) * CFrame.new(0, 0, -len / 2)})
Debris:AddItem(p, 0.6)
table.insert(made, p)
end
return made
end
FX.ghost = function(m, hrp)
H.strip(m)
local parts = H.partsOf(m)
H.paint(parts, Color3.fromRGB(215, 235, 255), Enum.Material.ForceField, 0)
local hl = new("Highlight", {FillColor = Color3.fromRGB(200, 230, 255), OutlineColor = Color3.new(1, 1, 1), FillTransparency = 0.6, OutlineTransparency = 0.3}, m)
local base = m:GetPivot()
H.run(3, function(a)
m:PivotTo(base * CFrame.new(math.sin(a * 12) * 0.6, 14 * a, 0) * CFrame.Angles(0, a * math.pi * 2, 0))
local tr = 0.35 + 0.65 * math.max(0, (a - 0.5) / 0.5)
for _, p in ipairs(parts) do
if p.Name ~= "HumanoidRootPart" then
p.Transparency = tr
end
end
hl.FillTransparency = math.min(1, 0.6 + 0.4 * math.max(0, (a - 0.5) / 0.5))
hl.OutlineTransparency = math.min(1, 0.3 + 0.7 * math.max(0, (a - 0.5) / 0.5))
end)
end
FX.burn = function(m, hrp)
H.strip(m)
local parts = H.partsOf(m)
H.paint(parts, Color3.fromRGB(25, 20, 18), Enum.Material.Slate, 0, 1.2)
for _, p in ipairs(parts) do
if p.Name ~= "HumanoidRootPart" and p.Size.Magnitude > 1 then
new("Fire", {Size = 6, Heat = 9, Color = Color3.fromRGB(255, 120, 20), SecondaryColor = Color3.fromRGB(255, 40, 0)}, p)
end
end
new("Smoke", {Size = 6, Opacity = 0.35, RiseVelocity = 6, Color = Color3.fromRGB(40, 40, 40)}, hrp)
new("PointLight", {Color = Color3.fromRGB(255, 130, 40), Range = 14, Brightness = 2}, hrp)
task.delay(2.4, function()
H.fade(m, 0.8)
end)
end
FX.weightless = function(m, hrp)
local parts = H.partsOf(m)
local head = m:FindFirstChild("Head")
local owner, vel, spin = {}, {}, {}
for _, p in ipairs(parts) do
local o = p
if head and p:FindFirstAncestorOfClass("Accessory") then
o = head
end
owner[p] = o
if not vel[o] then
vel[o] = Vector3.new(rng:NextNumber(-3, 3), rng:NextNumber(3, 7), rng:NextNumber(-3, 3))
spin[o] = Vector3.new(rng:NextNumber(-3, 3), rng:NextNumber(-3, 3), rng:NextNumber(-3, 3))
end
end
H.run(3.2, function(a, dt)
local centers = {}
for o in pairs(vel) do
centers[o] = o.Position
end
for _, p in ipairs(parts) do
local o = owner[p]
local c = centers[o]
local s = spin[o]
p.CFrame = CFrame.new(vel[o] * dt) * (CFrame.new(c) * CFrame.Angles(s.X * dt, s.Y * dt, s.Z * dt) * CFrame.new(-c) * p.CFrame)
end
end)
task.delay(2.4, function()
H.fade(m, 0.8)
end)
end
FX.balloon = function(m, hrp)
local base = m:GetPivot()
local bpos = hrp.Position
local balloon = H.ghostPart({Shape = Enum.PartType.Ball, Size = Vector3.new(0.5, 0.5, 0.5), Color = Color3.fromRGB(150, 205, 120), Material = Enum.Material.SmoothPlastic, Reflectance = 0.1, CFrame = CFrame.new(bpos + Vector3.new(0, 9, 0))})
local str = H.ghostPart({Size = Vector3.new(0.12, 3.2, 0.12), Color = Color3.fromRGB(235, 235, 235), Material = Enum.Material.SmoothPlastic, CFrame = CFrame.new(bpos + Vector3.new(0, 4, 0))})
Debris:AddItem(balloon, 7)
Debris:AddItem(str, 7)
task.delay(4.2, function()
for _, o in ipairs({balloon, str}) do
TweenService:Create(o, TweenInfo.new(0.7), {Transparency = 1}):Play()
end
H.fade(m, 0.7)
end)
H.run(5, function(a)
local grow = math.min(1, a / 0.07)
local h = (a < 0.07) and 0 or (((a - 0.07) / 0.93) ^ 1.8) * 90
local off = Vector3.new(math.sin(a * 14) * 1.2, h, 0)
local sway = math.sin(a * 9) * 0.12
m:PivotTo((base + off) * CFrame.Angles(0, a * 2, sway))
local r = 0.5 + 5.5 * (1 - (1 - grow) ^ 3)
balloon.Size = Vector3.new(r, r * 1.15, r)
balloon.CFrame = CFrame.new(bpos + off + Vector3.new(0, 6 + r * 0.55, 0)) * CFrame.Angles(0, 0, sway)
str.CFrame = CFrame.new(bpos + off + Vector3.new(0, 4, 0))
end)
end
FX.blackheart = function(m, hrp)
H.strip(m)
local parts = H.partsOf(m)
H.paint(parts, Color3.fromRGB(12, 12, 14), Enum.Material.Slate, 0, 0.6)
local pos = hrp.Position
task.delay(0.9, function()
H.fade(m, 0.5)
H.shards(pos, Color3.fromRGB(14, 14, 18), Enum.Material.Slate, 22, 28, 1.6)
end)
for i = 1, 6 do
task.delay(0.15 * i, function()
local st = pos + Vector3.new(rng:NextNumber(-2, 2), 1 + i * 0.3, rng:NextNumber(-2, 2))
local hp = H.ghostPart({Size = Vector3.new(0.4, 0.4, 0.4), Transparency = 1, CFrame = CFrame.new(st)})
local bb = new("BillboardGui", {Size = UDim2.new(0, 56, 0, 56), LightInfluence = 0}, hp)
local lb = new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "♥", TextScaled = true, Font = Enum.Font.GothamBlack, TextColor3 = Color3.fromRGB(8, 8, 10)}, bb)
local sk = new("UIStroke", {Color = Color3.fromRGB(110, 110, 140), Thickness = 2}, lb)
Debris:AddItem(hp, 3)
H.run(2.2, function(a)
hp.Position = st + Vector3.new(0, a * 9, 0)
local tr = math.max(0, (a - 0.4) / 0.6)
lb.TextTransparency = tr
sk.Transparency = tr
end)
end)
end
end
FX.freeze = function(m, hrp)
H.strip(m)
local parts = H.partsOf(m)
H.paint(parts, Color3.fromRGB(170, 225, 255), Enum.Material.Ice, 0.1, 0.4)
local pos = hrp.Position
local block = H.ghostPart({Size = Vector3.new(0.5, 0.5, 0.5), CFrame = CFrame.new(pos), Color = Color3.fromRGB(190, 235, 255), Material = Enum.Material.Glass, Transparency = 0.45, Reflectance = 0.2})
Debris:AddItem(block, 4)
TweenService:Create(block, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Vector3.new(5.5, 7, 5)}):Play()
task.delay(2.2, function()
block:Destroy()
H.shards(pos, Color3.fromRGB(190, 235, 255), Enum.Material.Ice, 26, 22, 1.6)
H.fade(m, 0.3)
end)
end
FX.gold = function(m, hrp)
H.strip(m)
local parts = H.partsOf(m)
H.paint(parts, Color3.fromRGB(255, 196, 40), Enum.Material.Metal, 0.35, 0.5)
new("PointLight", {Color = Color3.fromRGB(255, 200, 60), Range = 16, Brightness = 2}, hrp)
H.sparkles(parts, Color3.fromRGB(255, 230, 120), 35)
local base = m:GetPivot()
H.run(3, function(a)
m:PivotTo(base * CFrame.new(0, 1.2 * a, 0) * CFrame.Angles(0, a * math.pi * 4, 0))
end)
task.delay(2.4, function()
H.fade(m, 0.6)
end)
end
FX.silver = function(m, hrp)
H.strip(m)
local parts = H.partsOf(m)
H.paint(parts, Color3.fromRGB(200, 205, 215), Enum.Material.Metal, 0.55, 0.5)
H.sparkles(parts, Color3.fromRGB(235, 240, 255), 25)
local pos = hrp.Position
task.delay(2.0, function()
H.shards(pos, Color3.fromRGB(205, 210, 220), Enum.Material.Metal, 24, 22, 1.5)
H.fade(m, 0.2)
end)
end
local THUNDER_SOUND_ID = 0
local THUNDER_SOUND_URL = ""
local THUNDER_VOLUME = 3
local Lighting = game:GetService("Lighting")
local thunderAsset
local function resolveThunderSound()
if thunderAsset then
return thunderAsset
end
if THUNDER_SOUND_URL ~= "" then
local ok, a = pcall(function()
writefile("asta_thunder.mp3", game:HttpGet(THUNDER_SOUND_URL))
return getcustomasset("asta_thunder.mp3")
end)
if ok and a then
thunderAsset = a
return a
end
end
if THUNDER_SOUND_ID ~= 0 then
thunderAsset = "rbxassetid://" .. THUNDER_SOUND_ID
else thunderAsset = "rbxasset://sounds/impact_explosion_03.mp3"
end
return thunderAsset
end
local function thunderSound(emitter, speed, vol, delay, long)
task.delay(delay, function()
if closed then
return
end
local s = new("Sound", {SoundId = resolveThunderSound(), Volume = vol, PlaybackSpeed = speed, RollOffMaxDistance = 300, RollOffMinDistance = 30}, emitter)
new("EqualizerSoundEffect", {LowGain = long and 8 or 0, MidGain = long and -10 or -2, HighGain = long and -14 or 4}, s)
new("ReverbSoundEffect", {DecayTime = long and 4.5 or 1.2, Density = 1, Diffusion = 1, DryLevel = -3, WetLevel = long and 3 or -2}, s)
s:Play()
Debris:AddItem(s, 10)
end)
end
local function jag(a, b, disp, depth, thick, list)
if depth == 0 then
local len = (b - a).Magnitude
if len < 0.05 then
return
end
local cf = CFrame.lookAt(a, b) * CFrame.new(0, 0, -len / 2)
local glow = H.ghostPart({Size = Vector3.new(thick * 4, thick * 4, len), Color = Color3.fromRGB(110, 160, 255), Material = Enum.Material.Neon, Transparency = 0.7, CFrame = cf})
local core = H.ghostPart({Size = Vector3.new(thick, thick, len), Color = Color3.fromRGB(245, 250, 255), Material = Enum.Material.Neon, CFrame = cf})
Debris:AddItem(glow, 1)
Debris:AddItem(core, 1)
table.insert(list, glow)
table.insert(list, core)
return
end
local mid = (a + b) / 2 + Vector3.new(rng:NextNumber(-disp, disp), rng:NextNumber(-disp, disp) * 0.3, rng:NextNumber(-disp, disp))
jag(a, mid, disp * 0.55, depth - 1, thick, list)
jag(mid, b, disp * 0.55, depth - 1, thick, list)
if depth >= 3 and rng:NextNumber() < 0.45 then
local dir = (b - a)
local tip = mid + Vector3.new(rng:NextNumber(-1, 1) * 12, -math.abs(dir.Y) * 0.35, rng:NextNumber(-1, 1) * 12)
jag(mid, tip, disp * 0.6, depth - 2, thick * 0.55, list)
end
end
local function screenFlash(power)
local cc = new("ColorCorrectionEffect", {Brightness = power, Contrast = power * 0.6, Saturation = -power * 0.5}, Lighting)
TweenService:Create(cc, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = 0, Contrast = 0, Saturation = 0}):Play()
Debris:AddItem(cc, 0.5)
end
local function camShake(dur, power)
local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
if not hum then
return
end
H.run(dur, function(a)
local k = (1 - a) * power
hum.CameraOffset = Vector3.new(rng:NextNumber(-k, k), rng:NextNumber(-k, k), 0)
if a >= 1 then
hum.CameraOffset = Vector3.zero
end
end)
end
FX.thunder = function(m, hrp)
H.strip(m)
local parts = H.partsOf(m)
local pos = hrp.Position
local groundPos = pos - Vector3.new(0, 2.8, 0)
local emitter = H.ghostPart({Size = Vector3.new(1, 1, 1), Transparency = 1, CFrame = CFrame.new(pos)})
Debris:AddItem(emitter, 12)
local light = new("PointLight", {Color = Color3.fromRGB(180, 210, 255), Range = 45, Brightness = 0}, hrp)
local top = pos + Vector3.new(rng:NextNumber(-6, 6), 85, rng:NextNumber(-6, 6))
local strikes = {{0, 1.0}, {0.09, 0.6}, {0.21, 0.8}}
for k, st in ipairs(strikes) do
task.delay(st[1], function()
if closed then
return
end
local list = {}
jag(top + Vector3.new(rng:NextNumber(-1, 1), 0, rng:NextNumber(-1, 1)), pos, 14, 5, 0.35 + 0.15 * st[2], list)
for _, p in ipairs(list) do
TweenService:Create(p, TweenInfo.new(0.22 + 0.1 * k), {Transparency = 1}):Play()
end
light.Brightness = 14 * st[2]
TweenService:Create(light, TweenInfo.new(0.3), {Brightness = 0}):Play()
H.paint(parts, Color3.fromRGB(250, 252, 255), Enum.Material.Neon, 0)
screenFlash(0.45 * st[2])
if k == 1 then
H.flatRing(pos, Color3.fromRGB(140, 190, 255))
camShake(0.55, 0.45)
thunderSound(emitter, 1.35, THUNDER_VOLUME * 1.1, 0, false)
thunderSound(emitter, 0.5, THUNDER_VOLUME, 0.28, true)
H.shards(groundPos + Vector3.new(0, 1, 0), Color3.fromRGB(255, 240, 160), Enum.Material.Neon, 14, 26, 0.6)
local scorch = H.ghostPart({Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.12, 6, 6), Color = Color3.fromRGB(12, 12, 14), Material = Enum.Material.Slate, Transparency = 0.15, CFrame = CFrame.new(groundPos) * CFrame.Angles(0, 0, math.pi / 2)})
task.delay(4, function()
TweenService:Create(scorch, TweenInfo.new(3), {Transparency = 1}):Play()
end)
Debris:AddItem(scorch, 8)
end
task.delay(0.06, function()
H.paint(parts, Color3.fromRGB(22, 20, 24), Enum.Material.Slate, 0)
end)
end)
end
task.delay(0.3, function()
for _, p in ipairs(parts) do
if p.Name == "Torso" or p.Name == "UpperTorso" or p.Name == "Head" then
new("ParticleEmitter", {Color = ColorSequence.new(Color3.fromRGB(60, 60, 66)), Size = NumberSequence.new(0.8, 2.4), Lifetime = NumberRange.new(1.2, 2.2), Rate = 22, Speed = NumberRange.new(2, 4), Acceleration = Vector3.new(0, 4, 0), SpreadAngle = Vector2.new(25, 25), Transparency = NumberSequence.new(0.4, 1)}, p)
new("ParticleEmitter", {Color = ColorSequence.new(Color3.fromRGB(255, 150, 50)), Size = NumberSequence.new(0.25, 0), Lifetime = NumberRange.new(0.5, 1.1), Rate = 18, Speed = NumberRange.new(3, 8), LightEmission = 1, SpreadAngle = Vector2.new(60, 60)}, p)
end
end
local base = m:GetPivot()
H.run(0.5, function(a)
local k = (1 - a) * 0.25
m:PivotTo(base * CFrame.new(rng:NextNumber(-k, k), 0, rng:NextNumber(-k, k)))
end)
end)
task.delay(2.6, function()
H.fade(m, 0.8)
end)
end
local function boomSound(parent, id, speed, vol, delay, deep)
task.delay(delay, function()
if closed then
return
end
local s = new("Sound", {SoundId = id, Volume = vol, PlaybackSpeed = speed, RollOffMaxDistance = 300, RollOffMinDistance = 30}, parent)
new("EqualizerSoundEffect", {LowGain = deep and 8 or 0, MidGain = deep and -6 or 0, HighGain = deep and -12 or 2}, s)
new("ReverbSoundEffect", {DecayTime = deep and 3.5 or 1.4, Density = 1, Diffusion = 1, DryLevel = -2, WetLevel = deep and 2 or -3}, s)
s:Play()
Debris:AddItem(s, 8)
end)
end
local function sphere(pos, color, size0, size1, t, tr0, ease)
local s = H.ghostPart({Shape = Enum.PartType.Ball, Size = Vector3.one * size0, Color = color, Material = Enum.Material.Neon, Transparency = tr0, CFrame = CFrame.new(pos)})
TweenService:Create(s, TweenInfo.new(t, ease or Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = Vector3.one * size1, Transparency = 1}):Play()
Debris:AddItem(s, t + 0.2)
return s
end
FX.redbomb = function(m, hrp)
local parts = H.partsOf(m)
local pos = hrp.Position
local groundY = pos.Y - 2.6
local BOMB_TIME = 1.15
local RED, WHITE = Color3.fromRGB(255, 25, 25), Color3.fromRGB(255, 255, 255)
local DRED = Color3.fromRGB(120, 8, 8)
local bpos = pos + Vector3.new(0, 0.6, -0.9)
local bomb = H.ghostPart({Shape = Enum.PartType.Ball, Size = Vector3.one * 2.1, Color = RED, Material = Enum.Material.Neon, CFrame = CFrame.new(bpos)})
local band = H.ghostPart({Shape = Enum.PartType.Cylinder, Size = Vector3.new(0.45, 2.16, 2.16), Color = WHITE, Material = Enum.Material.Neon, CFrame = CFrame.new(bpos) * CFrame.Angles(0, 0, math.pi / 2)})
local eye = H.ghostPart({Shape = Enum.PartType.Ball, Size = Vector3.one * 0.8, Color = WHITE, Material = Enum.Material.Neon, CFrame = CFrame.new(bpos + Vector3.new(0, 1.1, 0))})
local glow = new("PointLight", {Color = RED, Range = 18, Brightness = 0}, bomb)
new("ParticleEmitter", {Texture = "rbxasset://textures/particles/sparkles_main.dds", Color = ColorSequence.new(WHITE, RED), Size = NumberSequence.new(0.5, 0), Lifetime = NumberRange.new(0.2, 0.5), Rate = 40, Speed = NumberRange.new(3, 7), SpreadAngle = Vector2.new(60, 60), LightEmission = 1}, eye)
local beep = new("Sound", {SoundId = "rbxasset://sounds/electronicpingshort.wav", Volume = 2, RollOffMaxDistance = 120}, bomb)
local phase, lastOn = 0, false
local basePivot = m:GetPivot()
H.run(BOMB_TIME, function(a, dt)
phase = phase + dt * (9 + a * 34)
local on = math.sin(phase) > 0
bomb.Color = on and RED or WHITE
band.Color = on and WHITE or RED
eye.Color = on and WHITE or RED
glow.Color = on and RED or WHITE
glow.Brightness = 6 + a * 12
if on and not lastOn then
beep.PlaybackSpeed = 0.9 + a * 1.2
beep:Play()
end
lastOn = on
local k = a * 0.18
m:PivotTo(basePivot * CFrame.new(rng:NextNumber(-k, k), 0, rng:NextNumber(-k, k)))
end)
task.delay(BOMB_TIME, function()
if closed then
return
end
bomb:Destroy()
band:Destroy()
eye:Destroy()
local ep = H.ghostPart({Size = Vector3.one, Transparency = 1, CFrame = CFrame.new(bpos)})
Debris:AddItem(ep, 8)
boomSound(ep, "rbxasset://sounds/impact_explosion_03.mp3", 1.0, 4.5, 0, false)
boomSound(ep, "rbxasset://sounds/impact_explosion_03.mp3", 0.55, 4, 0.08, true)
sphere(bpos, Color3.fromRGB(255, 255, 255), 4, 32, 0.22, 0, Enum.EasingStyle.Quad)
sphere(bpos, Color3.fromRGB(255, 45, 45), 3, 26, 0.55, 0.15)
sphere(bpos, Color3.fromRGB(190, 10, 10), 2, 18, 0.75, 0.3)
local core = H.ghostPart({Shape = Enum.PartType.Ball, Size = Vector3.one * 2, Color = Color3.fromRGB(18, 14, 12), Material = Enum.Material.SmoothPlastic, Transparency = 0.1, CFrame = CFrame.new(bpos)})
TweenService:Create(core, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = Vector3.one * 15, Transparency = 1}):Play()
Debris:AddItem(core, 1.7)
H.flatRing(Vector3.new(bpos.X, groundY + 2.5, bpos.Z), Color3.fromRGB(255, 255, 255))
local fire = new("ParticleEmitter", {Texture = "rbxasset://textures/particles/fire_main.dds", Rate = 0, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 40, 40)), ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 20, 20))}), Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 4), NumberSequenceKeypoint.new(0.4, 9), NumberSequenceKeypoint.new(1, 13)}), Lifetime = NumberRange.new(0.5, 1.1), Speed = NumberRange.new(25, 55), Drag = 3, Acceleration = Vector3.new(0, 10, 0), SpreadAngle = Vector2.new(180, 180), LightEmission = 1, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.7, 0.4), NumberSequenceKeypoint.new(1, 1)}), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-120, 120)}, ep)
local sparks = new("ParticleEmitter", {Texture = "rbxasset://textures/particles/sparkles_main.dds", Rate = 0, Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 40, 40)), Size = NumberSequence.new(0.7, 0), Lifetime = NumberRange.new(0.6, 1.6), Speed = NumberRange.new(40, 85), Drag = 1.5, Acceleration = Vector3.new(0, -45, 0), SpreadAngle = Vector2.new(180, 180), LightEmission = 1}, ep)
local smoke = new("ParticleEmitter", {Texture = "rbxasset://textures/particles/smoke_main.dds", Rate = 0, Color = ColorSequence.new(Color3.fromRGB(35, 33, 32), Color3.fromRGB(95, 92, 90)), Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 5), NumberSequenceKeypoint.new(1, 18)}), Lifetime = NumberRange.new(2, 3.4), Speed = NumberRange.new(6, 16), Drag = 2, Acceleration = Vector3.new(0, 7, 0), SpreadAngle = Vector2.new(180, 180), Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.35), NumberSequenceKeypoint.new(1, 1)}), Rotation = NumberRange.new(0, 360), RotSpeed = NumberRange.new(-40, 40)}, ep)
fire:Emit(70)
sparks:Emit(45)
task.delay(0.12, function()
smoke:Emit(34)
end)
H.shards(bpos, Color3.fromRGB(30, 28, 28), Enum.Material.Slate, 18, 38, 1.4)
local lt = new("PointLight", {Color = Color3.fromRGB(255, 70, 70), Range = 60, Brightness = 25}, ep)
TweenService:Create(lt, TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Brightness = 0}):Play()
screenFlash(0.5)
camShake(0.8, 0.7)
for _, p in ipairs(parts) do
if p.Name ~= "HumanoidRootPart" then
TweenService:Create(p, TweenInfo.new(0.4), {Color = Color3.fromRGB(28, 22, 20)}):Play()
end
end
local v = Vector3.new(rng:NextNumber(-1, 1) * 34, 42, rng:NextNumber(-1, 1) * 34)
local w = Vector3.new(rng:NextNumber(-9, 9), rng:NextNumber(-9, 9), rng:NextNumber(-9, 9))
local cf = m:GetPivot()
H.run(1.8, function(a, dt)
v = v + Vector3.new(0, -75 * dt, 0)
local p = cf.Position + v * dt
if p.Y < groundY then
p = Vector3.new(p.X, groundY, p.Z)
v = Vector3.new(v.X * 0.55, math.abs(v.Y) * 0.3, v.Z * 0.55)
w = w * 0.6
end
cf = CFrame.new(p) * (cf - cf.Position) * CFrame.Angles(w.X * dt, w.Y * dt, w.Z * dt)
m:PivotTo(cf)
end)
task.delay(2.2, function()
H.fade(m, 0.8)
end)
end)
end
local function snapshot(char, cf)
local clone
pcall(function()
local old = char.Archivable
char.Archivable = true
clone = char:Clone()
char.Archivable = old
end)
if not clone then
return nil
end
for _, d in ipairs(clone:GetDescendants()) do
pcall(function()
if d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Humanoid") or d:IsA("Sound") or d:IsA("BillboardGui") or d:IsA("ForceField") or d:IsA("Tool") or d:IsA("Highlight") or d:IsA("ParticleEmitter") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then
d:Destroy()
end
end)
end
for _, p in ipairs(H.partsOf(clone)) do
p.Anchored = true
p.CanCollide = false
p.CanTouch = false
p.CanQuery = false
p.Massless = true
end
if cf then
clone:PivotTo(cf)
end
clone.Parent = folder
Debris:AddItem(clone, 12)
return clone
end
local function hideOriginal(char)
local hum = char:FindFirstChildOfClass("Humanoid")
if hum then
pcall(function()
hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
end)
end
local function hide()
for _, d in ipairs(char:GetDescendants()) do
if d:IsA("BasePart") then
d.LocalTransparencyModifier = 1
d.Transparency = 1
elseif d:IsA("Decal") or d:IsA("Texture") then
d.Transparency = 1
elseif d:IsA("BillboardGui") then
d.Enabled = false
elseif d:IsA("ParticleEmitter") or d:IsA("Fire") or d:IsA("Smoke") or d:IsA("Sparkles") then
d.Enabled = false
end
end
end
hide()
task.spawn(function()
local t = os.clock()
while os.clock() - t < 8 and char.Parent and not closed do
hide()
RunService.Heartbeat:Wait()
end
end)
end
function KFX.play(id, char, cf)
local fn = FX[id]
if not fn or not char then
return
end
local m = snapshot(char, cf)
if not m then
return
end
if not cf then
hideOriginal(char)
end
local hrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
if not hrp then
m:Destroy()
return
end
local ok = pcall(fn, m, hrp)
if not ok then
m:Destroy()
end
end
local hooked = setmetatable({}, {__mode = "k"})
local played = setmetatable({}, {__mode = "k"})
local function onDeath(char)
if closed or played[char] then
return
end
played[char] = true
if KFX.current <= 1 then
return
end
local _, _, myRoot = getChar(lp)
local root = char:FindFirstChild("HumanoidRootPart")
if not (myRoot and root) then
return
end
if (root.Position - myRoot.Position).Magnitude > KFX.range then
return
end
KFX.play(KFX.list[KFX.current].id, char)
end
local function watchChar(char)
if hooked[char] then
return
end
hooked[char] = true
local hum = char:WaitForChild("Humanoid", 5)
if not hum then
return
end
local fired = false
local function died()
if fired then
return
end
fired = true
pcall(onDeath, char)
end
table.insert(conns, hum.Died:Connect(died))
table.insert(conns, hum.HealthChanged:Connect(function(h)
if h <= 0 then
died()
end
end))
table.insert(conns, char.AncestryChanged:Connect(function(_, parent)
if not parent and hum.Health <= 0 then
died()
end
end))
end
local function watchPlayer(p)
if p == lp then
return
end
if p.Character then
task.spawn(watchChar, p.Character)
end
table.insert(conns, p.CharacterAdded:Connect(watchChar))
table.insert(conns, p.CharacterRemoving:Connect(function(c)
local h = c:FindFirstChildOfClass("Humanoid")
if h and h.Health <= 0 then
pcall(onDeath, c)
end
end))
end
for _, p in ipairs(Players:GetPlayers()) do
watchPlayer(p)
end
table.insert(conns, Players.PlayerAdded:Connect(watchPlayer))
KFX.folder = folder end __iife23508() end
if AUTO_SKIN then
skinActive = true
end
local AstaAssist = (function()
local LocalPlayer = lp
local WindUI = {Notify = function(_, t)
pcall(toast, (t and t.Content) or "")
end}
local AstaAssist
AstaAssist = {SetSpeed = function()
end, SetSpeedPct = function()
end, SetAssist = function()
end, SetGrab = function()
end, SetJump = function()
end, manualHeld = function()
return false
end, isGrab = function()
return false
end, pickTarget = function()
return nil
end} do
local players = Players
local runService = RunService
local uis = game:GetService("UserInputService")
local localPlayer = LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local oldJoy = playerGui:FindFirstChild("AstaJoyGui")
if oldJoy then
oldJoy:Destroy()
end
if _G.AstaConn then
pcall(function()
_G.AstaConn:Disconnect()
end)
end
if _G.AstaManualConns then
for _, c in ipairs(_G.AstaManualConns) do
pcall(function()
c:Disconnect()
end)
end
end
_G.AstaManualConns = {}
pcall(function()
runService:UnbindFromRenderStep("AstaAssistDrive")
end)
pcall(function()
runService:UnbindFromRenderStep("AstaThumbVis")
end)
local ASSIST_MAX_RANGE = 60
local ASSIST_STOP_DIST = 2.3
local RESUME_GAP = 0.7
local TAKE_PAUSE = 0
local GRAB_RANGE = 14
local GRAB_COOLDOWN = 0.2
local REQUIRE_TARGET_TOOL = false
local LEAD_MAX = 0.35
local JOY_BASE_X = 0.20
local JOY_BASE_Y = 0.72
local autoActive = false
local autoGrab = false
AstaAssist.SetAssist = function(v)
autoActive = v and true or false
end
AstaAssist.SetGrab = function(v)
autoGrab = v and true or false
end
local BombTimer = {} do
local Players_ = game:GetService("Players")
local found, lastScan = nil, 0
local HINTS = {"timer", "time", "fuse", "countdown", "explode", "explosion", "seconds", "left"}
local function hint(n)
n = tostring(n):lower()
for _, h in ipairs(HINTS) do
if n:find(h, 1, true) then
return true
end
end
return false
end
local function parseText(s)
s = tostring(s or "")
local m, sec = s:match("^%s*(%d+):(%d+)%s*$")
if m then
return tonumber(m) * 60 + tonumber(sec)
end
local n = s:match("^%s*(%d+%.?%d*)%s*[sS]?%s*$")
return n and tonumber(n) or nil
end
local function guiVisible(o)
local p = o
while p and p ~= game do
if p:IsA("GuiObject") and not p.Visible then
return false
end
if p:IsA("LayerCollector") and p.Enabled == false then
return false
end
p = p.Parent
end
return true
end
local function reader(o)
if o:IsA("NumberValue") or o:IsA("IntValue") then
return function()
return o.Value
end
elseif (o:IsA("TextLabel") or o:IsA("TextButton")) and guiVisible(o) then
local v = parseText(o.Text)
if v and v >= 0 and v < 600 then
return function()
return guiVisible(o) and parseText(o.Text) or nil
end
end
end
return nil
end
local function attrReader(o)
for an, av in pairs(o:GetAttributes()) do
if type(av) == "number" and hint(an) then
return function()
return o:GetAttribute(an)
end
end
end
end
local function scanRoot(root)
for _, o in ipairs(root:GetDescendants()) do
if hint(o.Name) or (o.Parent and hint(o.Parent.Name)) then
local r = reader(o)
if r then
return r
end
end
local ar = attrReader(o)
if ar then
return ar
end
end
end
local function rescan()
local lp = Players_.LocalPlayer
for _, p in ipairs(Players_:GetPlayers()) do
if p.Character then
local r = scanRoot(p.Character)
if r then
return r
end
end
end
local pg = lp and lp:FindFirstChild("PlayerGui")
if pg then
local r = scanRoot(pg)
if r then
return r
end
end
for _, root in ipairs({workspace, game:GetService("ReplicatedStorage")}) do
local ar = attrReader(root)
if ar then
return ar
end
for _, o in ipairs(root:GetChildren()) do
if hint(o.Name) then
local r = reader(o) or attrReader(o)
if r then
return r
end
end
end
end
return nil
end
function BombTimer.read()
if found then
local ok, v = pcall(found)
if ok and type(v) == "number" then
return v
end
found = nil
end
local now = os.clock()
if now - lastScan < 1 then
return nil
end
lastScan = now
local ok, r = pcall(rescan)
if ok and r then
found = r
local ok2, v = pcall(found)
if ok2 and type(v) == "number" then
return v
end
end
return nil
end
end
local grabDelay = 10
local timerWarned = false
AstaAssist.SetGrabDelay = function(v)
grabDelay = math.clamp(tonumber(v) or 10, 1, 10)
end
local function gateOpen()
if grabDelay <= 0 then
return true
end
local t = BombTimer.read()
if t == nil then
if not timerWarned then
timerWarned = true
pcall(function()
WindUI:Notify({ Title = "اوتو قراب", Content = "ما قدرت أقرأ عداد القنبلة من اللعبة، العداد معطّل مؤقتاً والاوتو قراب يشتغل عادي", Duration = 5 })
end)
end
return true
end
timerWarned = false
return t <= grabDelay
end
AstaAssist.gateOpen = gateOpen
local autoJumpOn = false
AstaAssist.SetJump = function(v)
autoJumpOn = v and true or false
end
AstaAssist.isGrab = function()
return autoGrab and gateOpen()
end
local antiStickOn = false
AstaAssist.SetAntiStick = function(v)
antiStickOn = v and true or false
end
AstaAssist.isAntiStick = function()
return antiStickOn
end
AstaAssist.wallDist = 4
AstaAssist.SetWallDist = function(v)
AstaAssist.wallDist = math.clamp(tonumber(v) or 4, 1, 10)
end
local manualTouches = {}
local MOVE_KEYS = { Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Down, Enum.KeyCode.Left, Enum.KeyCode.Right, }
table.insert(_G.AstaManualConns, uis.InputBegan:Connect(function(input)
if input.UserInputType ~= Enum.UserInputType.Touch then
return
end
local cam = workspace.CurrentCamera
if not cam then
return
end
local vp = cam.ViewportSize
if input.Position.X < vp.X * 0.5 and input.Position.Y > vp.Y * 0.35 then
manualTouches[input] = true
end
end))
table.insert(_G.AstaManualConns, uis.InputEnded:Connect(function(input)
manualTouches[input] = nil
end))
local function manualHeld()
for input in pairs(manualTouches) do
local st = input.UserInputState
if st == Enum.UserInputState.End or st == Enum.UserInputState.Cancel then
manualTouches[input] = nil
end
end
if next(manualTouches) ~= nil then
return true
end
if not uis:GetFocusedTextBox() then
for _, k in ipairs(MOVE_KEYS) do
if uis:IsKeyDown(k) then
return true
end
end
end
return false
end
local isGreenTeammate do
local function isGreenColor(c)
return c and c.G > 0.45 and c.G > c.R * 1.35 and c.G > c.B * 1.35
end
local function colorsOf(inst)
local out = {}
if inst:IsA("Highlight") then
table.insert(out, inst.FillColor)
table.insert(out, inst.OutlineColor)
elseif inst:IsA("SelectionBox") or inst:IsA("SelectionSphere") then
table.insert(out, inst.Color3)
elseif inst:IsA("TextLabel") or inst:IsA("TextButton") then
table.insert(out, inst.TextColor3)
if inst.BackgroundTransparency < 0.9 then
table.insert(out, inst.BackgroundColor3)
end
elseif inst:IsA("ImageLabel") then
table.insert(out, inst.ImageColor3)
elseif inst:IsA("Frame") and inst.BackgroundTransparency < 0.9 then
table.insert(out, inst.BackgroundColor3)
elseif inst:IsA("UIStroke") then
table.insert(out, inst.Color)
end
return out
end
local function hasGreenMark(root)
for _, d in ipairs(root:GetDescendants()) do
for _, c in ipairs(colorsOf(d)) do
if isGreenColor(c) then
return true
end
end
end
return false
end
local cache, at = {}, 0
local function refresh()
local now = os.clock()
if now - at < 0.6 then
return
end
at = now
cache = {}
for _, p in ipairs(players:GetPlayers()) do
if p ~= localPlayer then
local green = false
pcall(function()
if p.Team and isGreenColor(p.TeamColor.Color) then
green = true
end
local ch = p.Character
if not green and ch then
for _, d in ipairs(ch:GetDescendants()) do
if d:IsA("Highlight") or d:IsA("SelectionBox") then
for _, c in ipairs(colorsOf(d)) do
if isGreenColor(c) then
green = true
end
end
elseif d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
if hasGreenMark(d) then
green = true
end
end
if green then
break
end
end
if not green then
for _, root in ipairs({workspace, playerGui}) do
if not green then
for _, d in ipairs(root:GetChildren()) do
if d:IsA("Highlight") or d:IsA("SelectionBox") or d:IsA("BillboardGui") then
local ad = d.Adornee
if ad and (ad == ch or ad:IsDescendantOf(ch)) then
if d:IsA("BillboardGui") then
if hasGreenMark(d) then
green = true
end
else
for _, c in ipairs(colorsOf(d)) do
if isGreenColor(c) then
green = true
end
end
end
end
end
end
end
end
end
end
end)
cache[p] = green
end
end
end
isGreenTeammate = function(p)
refresh()
return cache[p] == true
end
end
local function isTeammate(p)
if isGreenTeammate(p) then
return true
end
local myTeam = localPlayer.Team
if myTeam and p.Team == myTeam then
return true
end
if localPlayer.Neutral == false and p.Neutral == false and p.TeamColor == localPlayer.TeamColor then
return true
end
return false
end
AstaAssist.manualHeld = manualHeld
AstaAssist.isTeammate = isTeammate
local AX = {driveUp = false, lastDir = Vector3.zero, stuck = {pos = nil, t = 0}, lastJump = 0, pathState = {wps = nil, idx = 2, last = 0, busy = false}}
local driveTarget, driveUntil = nil, 0
local driveDir = Vector3.zero
local function setDrive(pos, wantUp)
driveTarget = pos
driveUntil = os.clock() + 0.2
AX.driveUp = wantUp and true or false
end
runService:BindToRenderStep("AstaAssistDrive", Enum.RenderPriority.Input.Value + 1, function()
driveDir = Vector3.zero
if not (autoActive or autoJumpOn) or manualHeld() or not driveTarget or os.clock() > driveUntil then
return
end
local char = localPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local root = char and char:FindFirstChild("HumanoidRootPart")
if not hum or not root or hum.Health <= 0 then
return
end
local d = Vector3.new(driveTarget.X - root.Position.X, 0, driveTarget.Z - root.Position.Z)
local dyT = driveTarget.Y - root.Position.Y
local needUp = AX.driveUp and dyT > 2
if d.Magnitude > 1.2 then
local dir = d.Unit
local nowB = os.clock()
if AX.avoidDir and nowB < (AX.avoidUntil or 0) then
dir = AX.avoidDir
end
if (antiStickOn or autoJumpOn) and AX.steer then
dir = AX.steer(root, dir, AX.driveUp, d.Magnitude)
end
driveDir = dir
AX.lastDir = dir
hum:Move(dir, false)
if (autoJumpOn or antiStickOn) and not AX.driveUp then
AX.bump(hum, root, dir, nowB)
end
if antiStickOn then
local now = os.clock()
local st = AX.stuck
if not st.pos or now - st.t > 0.6 then
if st.pos and (root.Position - st.pos).Magnitude < 0.8 and hum.FloorMaterial ~= Enum.Material.Air then
AX.jump(hum, root)
end
st.pos, st.t = root.Position, now
end
end
elseif needUp and AX.lastDir.Magnitude > 0.1 then
driveDir = AX.lastDir
hum:Move(AX.lastDir, false)
else hum:Move(Vector3.zero, false)
end
end)
local lastGrab = 0
local function findBomb(char)
local fallback
for _, it in ipairs(char:GetChildren()) do
if it:IsA("Tool") then
local n = it.Name:lower()
if n:find("bomb") or it.Name:find("قنبل") then
return it
end
fallback = fallback or it
end
end
return fallback
end
local function tryGrab(targetChar, targetRoot, myChar, myRoot)
local now = os.clock()
if now - lastGrab < GRAB_COOLDOWN then
return
end
lastGrab = now
for _, item in ipairs(myChar:GetChildren()) do
if item:IsA("Tool") then
pcall(function()
item:Activate()
end)
end
end
if fireproximityprompt then
for _, d in ipairs(targetChar:GetDescendants()) do
if d:IsA("ProximityPrompt") and d.Enabled then
pcall(fireproximityprompt, d)
end
end
end
if not firetouchinterest then
local flat = Vector3.new(targetRoot.Position.X - myRoot.Position.X, 0, targetRoot.Position.Z - myRoot.Position.Z)
if flat.Magnitude > 1.6 then
local step = math.min(flat.Magnitude - 1.4, 5)
local dest = myRoot.Position + flat.Unit * step
myRoot.CFrame = CFrame.new(dest) * (myRoot.CFrame - myRoot.CFrame.Position)
end
else
local bomb = findBomb(targetChar)
local parts = {targetRoot}
local handle = bomb and bomb:FindFirstChild("Handle")
if handle then
table.insert(parts, handle)
end
for _, n in ipairs({"Torso", "UpperTorso", "Head", "Right Arm", "RightHand"}) do
local pt = targetChar:FindFirstChild(n)
if pt then
table.insert(parts, pt)
end
end
pcall(function()
for _, pt in ipairs(parts) do
firetouchinterest(myRoot, pt, 0)
firetouchinterest(myRoot, pt, 1)
end
end)
end
end
local holding = false
local hadTool = false
local pauseUntil = 0
local function pickTarget(rootPart, preferBomb, range)
local best, bestD = nil, range or ASSIST_MAX_RANGE
local bomb, bombD = nil, range or ASSIST_MAX_RANGE
for _, p in ipairs(players:GetPlayers()) do
local ch = p.Character
local r = ch and ch:FindFirstChild("HumanoidRootPart")
local h = ch and ch:FindFirstChildOfClass("Humanoid")
if p ~= localPlayer and not isTeammate(p) and r and h and h.Health > 0 then
local d = (rootPart.Position - r.Position).Magnitude
if d < bestD then
best, bestD = r, d
end
if preferBomb and d < bombD and ch:FindFirstChildOfClass("Tool") then
bomb, bombD = r, d
end
end
end
return bomb or best
end
AstaAssist.pickTarget = pickTarget
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
local edgeCache, edgeAt, lastWH = nil, 0, 0
local function findEdge(root, tPos)
local now = os.clock()
if edgeCache and now - edgeAt < 0.35 then
return edgeCache
end
edgeAt, edgeCache = now, nil
local origin = root.Position
local bestScore = math.huge
for i = 0, 15 do
local ang = i * math.pi / 8
local dir = Vector3.new(math.cos(ang), 0, math.sin(ang))
local wall = workspace:Raycast(origin, dir * 36, rayParams)
local maxD = wall and (wall.Distance - 1.5) or 36
local dd = 2.5
while dd <= maxD do
local p = origin + dir * dd
local down = workspace:Raycast(p, Vector3.new(0, -9, 0), rayParams)
if (not down) or down.Position.Y < origin.Y - 6.5 then
local edgePos = origin + dir * math.max(dd - 1.5, 0)
local toT = Vector3.new(tPos.X - p.X, 0, tPos.Z - p.Z).Magnitude
local score = dd + toT * 0.7
if score < bestScore then
bestScore, edgeCache = score, edgePos
end
break
end
dd = dd + 2.5
end
end
return edgeCache
end
AX.jump = function(hum, root, push)
local now = os.clock()
if now - AX.lastJump < 0.25 then
return
end
AX.lastJump = now
hum.Jump = true
pcall(function()
hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)
local power = hum.UseJumpPower and hum.JumpPower or math.sqrt(2 * workspace.Gravity * hum.JumpHeight)
if power < 30 then
power = 50
end
local v = root.AssemblyLinearVelocity
if push then
root.AssemblyLinearVelocity = Vector3.new(push.X, power, push.Z)
else root.AssemblyLinearVelocity = Vector3.new(v.X, power, v.Z)
end
end
AX.isLadder = function(p)
if p:IsA("TrussPart") then
return true
end
local n = p.Name
if p.Parent then
n = n .. " " .. p.Parent.Name
end
local l = n:lower()
if l:find("ladder") or l:find("stair") or l:find("scaffold") or l:find("truss") or n:find("سلم") then
return true
end
return false
end
AX.ray = function(origin, dir, len)
local h = workspace:Raycast(origin, dir * len, rayParams)
if h and h.Instance.CanCollide then
local m = h.Instance:FindFirstAncestorOfClass("Model")
if m and m:FindFirstChildOfClass("Humanoid") then
return nil
end
return h
end
return nil
end
AX.steer = function(root, dir, allowLadder, goalDist)
local origin = root.Position
local keep = AstaAssist.isAntiStick()
local D = keep and (AstaAssist.wallDist or 4) or 3.5
if keep and (not goalDist or goalDist > 5) then
local push = Vector3.zero
for _, ang in ipairs({0, 40, -40, 80, -80}) do
local d = CFrame.Angles(0, math.rad(ang), 0) * dir
local hit = AX.ray(origin, d, D)
if hit and not (allowLadder and AX.isLadder(hit.Instance)) then
local n = Vector3.new(hit.Normal.X, 0, hit.Normal.Z)
if n.Magnitude > 0.1 then
local w = math.clamp((D - hit.Distance) / D, 0, 1)
if ang == 0 then
w = w * 1.4
end
push = push + n.Unit * w
end
end
end
if push.Magnitude > 0.05 then
local mixed = dir + push * 1.5
if mixed.Magnitude > 0.1 then
dir = mixed.Unit
end
end
end
local h = AX.ray(origin, dir, D)
if not h then
return dir
end
if allowLadder and AX.isLadder(h.Instance) then
return dir
end
local n = Vector3.new(h.Normal.X, 0, h.Normal.Z)
if n.Magnitude > 0.1 then
n = n.Unit
local slide = dir - n * dir:Dot(n)
if slide.Magnitude > 0.25 then
slide = slide.Unit
if not AX.ray(origin, slide, math.max(D - 0.5, 2)) then
return slide
end
end
end
for _, ang in ipairs({40, -40, 75, -75, 110, -110}) do
local d = CFrame.Angles(0, math.rad(ang), 0) * dir
if not AX.ray(origin, d, D) then
return d
end
end
return dir
end do
local mp = RaycastParams.new()
mp.FilterType = Enum.RaycastFilterType.Exclude
local function wray(origin, d, len, char)
mp.FilterDescendantsInstances = {char}
local h = workspace:Raycast(origin, d * len, mp)
if not (h and h.Instance.CanCollide) then
return nil
end
local m = h.Instance:FindFirstAncestorOfClass("Model")
if m and m:FindFirstChildOfClass("Humanoid") then
return nil
end
if AX.isLadder(h.Instance) then
return nil
end
if math.abs(h.Normal.Y) > 0.5 then
return nil
end
return h
end
RunService:BindToRenderStep("AstaWallKeep", Enum.RenderPriority.Input.Value + 3, function()
if closed or not AstaAssist.isAntiStick() then
return
end
local char = lp.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
local root = char and char:FindFirstChild("HumanoidRootPart")
if not hum or not root or hum.Health <= 0 then
return
end
local md = hum.MoveDirection
local dir = Vector3.new(md.X, 0, md.Z)
if dir.Magnitude < 0.1 then
return
end
dir = dir.Unit
local D = 0.5 + (math.clamp(AstaAssist.wallDist or 4, 1, 10) - 1) * 0.5
local origin = root.Position
local nsum, minGap = Vector3.zero, math.huge
for _, ang in ipairs({0, 35, -35}) do
local d = CFrame.Angles(0, math.rad(ang), 0) * dir
local h = wray(origin, d, D + 1.1, char)
if h then
local n = Vector3.new(h.Normal.X, 0, h.Normal.Z)
if n.Magnitude > 0.1 then
local gap = h.Distance - 1.0
if gap < D then
nsum = nsum + n.Unit * (1.2 - math.clamp(gap / D, 0, 1))
if gap < minGap then
minGap = gap
end
end
end
end
end
if nsum.Magnitude < 0.01 then
AX.wallSide = nil
return
end
local n = nsum.Unit
local slide = dir - n * math.min(dir:Dot(n), 0)
if slide.Magnitude < 0.2 then
hum:Move(Vector3.zero, false)
else hum:Move(slide.Unit, false)
end
end)
end
AX.hop = function(hum, root, dir, dyT)
if hum.FloorMaterial == Enum.Material.Air then
return
end
if os.clock() - AX.lastJump < 0.35 then
return
end
local pos = root.Position
local low = AX.ray(pos - Vector3.new(0, 2.2, 0), dir, 2.6)
if low then
if AX.isLadder(low.Instance) and not AX.driveUp then
return
end
if not AX.ray(pos + Vector3.new(0, 4.5, 0), dir, 2.6) then
AX.jump(hum, root)
end
return
end
if dyT > -3 then
local ground = workspace:Raycast(pos + dir * 3.2, Vector3.new(0, -12, 0), rayParams)
if not ground then
AX.jump(hum, root)
end
end
end
AX.bump = function(hum, root, dir, now)
local v = root.AssemblyLinearVelocity
local sp = Vector3.new(v.X, 0, v.Z).Magnitude
if hum.FloorMaterial == Enum.Material.Air or sp > 3 then
AX.bumpAt = nil
return
end
if not AX.bumpAt then
AX.bumpAt = now
return
end
if now - AX.bumpAt < 0.15 then
return
end
local pos = root.Position
local low = AX.ray(pos - Vector3.new(0, 2.2, 0), dir, 2.6)
if not low then
return
end
AX.bumpAt = nil
local ladder = AX.isLadder(low.Instance)
if (not ladder) and not AX.ray(pos + Vector3.new(0, 4.5, 0), dir, 2.6) then
AX.jump(hum, root, dir * 14)
else
local side = Vector3.new(-dir.Z, 0, dir.X)
local pick = AX.ray(pos, side, 4) and -side or side
AX.avoidDir = (pick + (-dir) * 0.3).Unit
AX.avoidUntil = now + 0.5
end
end
AX.path = function(goal, me)
local ps = AX.pathState
local now = os.clock()
if not ps.busy and now - ps.last > 0.6 then
ps.last = now
ps.busy = true
task.spawn(function()
local ok, path = pcall(function()
local p = game:GetService("PathfindingService"):CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, AgentCanClimb = true })
p:ComputeAsync(me, goal)
return p
end)
if ok and path and path.Status == Enum.PathStatus.Success then
ps.wps = path:GetWaypoints()
ps.idx = 2
else ps.wps = nil
end
ps.busy = false
end)
end
local wps = ps.wps
if not wps or #wps < 2 then
return nil
end
local idx = ps.idx
while idx < #wps do
local w = wps[idx]
local dflat = Vector3.new(w.Position.X - me.X, 0, w.Position.Z - me.Z).Magnitude
if dflat < 2.5 and math.abs(w.Position.Y - me.Y) < 4 then
idx = idx + 1
else break
end
end
ps.idx = idx
local w = wps[math.min(idx, #wps)]
return w.Position, w.Action == Enum.PathWaypointAction.Jump
end
_G.AstaConn = runService.Heartbeat:Connect(function()
if not autoActive and not autoGrab and not autoJumpOn then
holding = false
driveTarget = nil
return
end
local manual = manualHeld()
local character = localPlayer.Character
if not character then
return
end
local hasTool = false
for _, item in ipairs(character:GetChildren()) do
if item:IsA("Tool") then
hasTool = true
break
end
end
if hasTool and not hadTool then
pauseUntil = os.clock() + TAKE_PAUSE
end
hadTool = hasTool
local humanoid = character:FindFirstChildOfClass("Humanoid")
local rootPart = character:FindFirstChild("HumanoidRootPart")
if not humanoid or not rootPart or humanoid.Health <= 0 then
return
end
rayParams.FilterDescendantsInstances = {character}
local grabNow = autoGrab and (hasTool or gateOpen())
local nearestTarget = pickTarget(rootPart, grabNow and not hasTool)
if not nearestTarget then
holding = false
driveTarget = nil
return
end
local tPos = nearestTarget.Position
local me = rootPart.Position
local flat = Vector3.new(tPos.X - me.X, 0, tPos.Z - me.Z)
local dist = flat.Magnitude
if grabNow and not hasTool and dist <= GRAB_RANGE then
local tChar = nearestTarget.Parent
if tChar and (not REQUIRE_TARGET_TOOL or findBomb(tChar)) then
tryGrab(tChar, nearestTarget, character, rootPart)
end
end
if not (autoActive or autoJumpOn) or manual then
holding = false
driveTarget = nil
return
end
if os.clock() < pauseUntil then
holding = false
driveTarget = nil
driveUntil = 0
return
end
if not (hasTool or grabNow) then
holding = false
driveTarget = nil
return
end
if autoJumpOn then
AX.tj = AX.tj or {root = nil, vy = 0}
local tj = AX.tj
local vy = nearestTarget.AssemblyLinearVelocity.Y
if tj.root ~= nearestTarget then
tj.root = nearestTarget
tj.vy = vy
end
if dist <= 25 and vy > 25 and tj.vy <= 25 and humanoid.FloorMaterial ~= Enum.Material.Air then
AX.jump(humanoid, rootPart)
end
tj.vy = vy
end
if autoJumpOn or autoActive then
local dy = tPos.Y - me.Y
local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
if humanoid:GetState() == Enum.HumanoidStateType.Climbing and dy < 3 then
local toT = flat.Magnitude > 0.1 and flat.Unit or rootPart.CFrame.LookVector
AX.jump(humanoid, rootPart, toT * 24)
holding = false
setDrive(tPos)
return
end
if dy < -4 and grounded then
local edge = findEdge(rootPart, tPos)
if edge then
local ed = Vector3.new(edge.X - me.X, 0, edge.Z - me.Z).Magnitude
holding = false
if ed <= 1.8 then
AX.jump(humanoid, rootPart)
setDrive(tPos)
else setDrive(edge)
end
return
end
end
if dy > 3 and dist > 0.5 then
local fwd = flat.Unit
local hit = workspace:Raycast(me, fwd * 3.5, rayParams)
if not (hit and hit.Instance.CanCollide and math.abs(hit.Normal.Y) < 0.35) then
hit = nil
if (not grounded) and os.clock() < (AX.climbUntil or 0) then
local bestD = 3.5
for i8 = 0, 7 do
local a8 = math.rad(i8 * 45)
local h8 = workspace:Raycast(me, Vector3.new(math.cos(a8), 0, math.sin(a8)) * 3.5, rayParams)
if h8 and h8.Instance.CanCollide and math.abs(h8.Normal.Y) < 0.35 and h8.Distance < bestD then
hit, bestD = h8, h8.Distance
end
end
end
end
if hit and hit.Instance.CanCollide and math.abs(hit.Normal.Y) < 0.35 then
local now = os.clock()
AX.climbUntil = now + 1.0
if AX.isLadder(hit.Instance) then
holding = false
setDrive(Vector3.new(hit.Position.X, tPos.Y, hit.Position.Z), true)
return
end
local top = nil
for _, hh in ipairs({3, 5, 7, 9, 11}) do
local o = me + Vector3.new(0, hh, 0)
if not workspace:Raycast(o, fwd * 3.5, rayParams) then
top = workspace:Raycast(o + fwd * 2.5, Vector3.new(0, -(hh + 4), 0), rayParams)
break
end
end
if top and top.Normal.Y > 0.7 then
local h = top.Position.Y - (me.Y - 3)
if h > 0.5 and h <= 10 and now - lastWH > 0.35 then
lastWH = now
local vy = math.sqrt(2 * workspace.Gravity * (h + 2))
rootPart.AssemblyLinearVelocity = Vector3.new(fwd.X * 14, vy, fwd.Z * 14)
humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
holding = false
setDrive(tPos)
return
end
end
if grounded then
AX.jump(humanoid, rootPart)
end
if now - lastWH > 0.22 and not grounded then
lastWH = now
local power = humanoid.UseJumpPower and humanoid.JumpPower or math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight)
local n = Vector3.new(hit.Normal.X, 0, hit.Normal.Z)
if n.Magnitude > 0 then
n = n.Unit
end
rootPart.AssemblyLinearVelocity = Vector3.new(n.X * 6, power, n.Z * 6)
humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end
holding = false
setDrive(tPos, true)
return
end
local wp, jumpNow = AX.path(tPos, me)
if wp then
holding = false
if jumpNow and grounded then
AX.jump(humanoid, rootPart)
end
setDrive(wp, true)
return
end
end
end
if holding then
if dist > ASSIST_STOP_DIST + RESUME_GAP then
holding = false
end
elseif dist <= ASSIST_STOP_DIST then
holding = true
end
if holding then
driveTarget = nil
return
end
local rv = nearestTarget.AssemblyLinearVelocity
local vel = Vector3.new(rv.X, 0, rv.Z)
if vel.Magnitude > 80 then
vel = Vector3.zero
end
local lead = math.clamp(dist / 20, 0, LEAD_MAX)
local offset = vel * lead
if offset.Magnitude > 6 then
offset = offset.Unit * 6
end
setDrive(tPos + offset)
end)
end
return AstaAssist
end)()
do local function __iife38564()
local TS = TweenService
local AR = (LANG == "ar")
local TXT_ALIGN = AR and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left
local P = { bg0 = Color3.fromRGB(7, 9, 18), bg1 = Color3.fromRGB(14, 18, 36), card = Color3.fromRGB(21, 27, 50), card2 = Color3.fromRGB(28, 36, 66), line = Color3.fromRGB(46, 58, 104), a1 = Color3.fromRGB(64, 132, 255), a2 = Color3.fromRGB(150, 96, 255), ok = Color3.fromRGB(56, 214, 140), bad = Color3.fromRGB(255, 84, 104), text = Color3.fromRGB(240, 243, 255), sub = Color3.fromRGB(150, 162, 196), }
local GRAD = ColorSequence.new(P.a1, P.a2)
local function tw(o, t, props, style, dir)
local ok, tween = pcall(function()
return TS:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end)
if ok and tween then
tween:Play()
return tween
end
end
local function grad(o, rot, seq)
return new("UIGradient", {Color = seq or GRAD, Rotation = rot or 0}, o)
end
local FW, FH = 650, 410
local sliding = nil
local frame = new("Frame", {Name = "Window", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 22), Size = UDim2.new(0, FW, 0, FH), BackgroundColor3 = Color3.new(1, 1, 1), Active = true, ClipsDescendants = true, Visible = false}, gui)
corner(frame, 20)
local uiScale = new("UIScale", {Scale = 0.01}, frame)
grad(frame, 90, ColorSequence.new(P.bg1, P.bg0))
local glow1 = new("Frame", {Position = UDim2.new(1, -170, 0, -120), Size = UDim2.new(0, 320, 0, 320), BackgroundColor3 = P.a2, BackgroundTransparency = 0.88, BorderSizePixel = 0}, frame)
corner(glow1, 999)
local glow2 = new("Frame", {Position = UDim2.new(0, -140, 1, -170), Size = UDim2.new(0, 300, 0, 300), BackgroundColor3 = P.a1, BackgroundTransparency = 0.88, BorderSizePixel = 0}, frame)
corner(glow2, 999)
local rimHolder = new("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 50}, frame)
corner(rimHolder, 20)
local rimStroke = stroke(rimHolder, Color3.new(1, 1, 1), 2, 0)
local rimGrad = new("UIGradient", {Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, P.a1), ColorSequenceKeypoint.new(0.5, P.a2), ColorSequenceKeypoint.new(1, P.a1)})}, rimStroke)
table.insert(conns, RunService.RenderStepped:Connect(function()
if closed then
return
end
rimGrad.Rotation = (os.clock() * 45) % 360
end))
local toastHolder = new("Frame", {Name = "AstaToasts", AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -18), Size = UDim2.new(0, 360, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 200}, gui)
new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Center}, toastHolder)
local toastN = 0
toast = function(msg, kind)
if closed or not toastHolder.Parent then
return
end
if quietToast then
return
end
toastN = toastN + 1
local col = (kind == "ok" and P.ok) or (kind == "bad" and P.bad) or P.a1
local t = new("TextLabel", {Size = UDim2.new(0, 0, 0, 38), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = P.card, BackgroundTransparency = 1, Text = " " .. tostring(msg) .. " ", TextColor3 = P.text, TextTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 14, LayoutOrder = toastN, ZIndex = 201}, toastHolder)
corner(t, 12)
local st = stroke(t, col, 1.6, 1)
tw(t, 0.25, {BackgroundTransparency = 0.05, TextTransparency = 0})
tw(st, 0.25, {Transparency = 0.1})
task.delay(4.5, function()
if t and t.Parent then
tw(t, 0.3, {BackgroundTransparency = 1, TextTransparency = 1})
tw(st, 0.3, {Transparency = 1})
task.delay(0.35, function()
if t then
t:Destroy()
end
end)
end
end)
end
local header = new("Frame", {Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1, Active = true}, frame)
local badge = new("Frame", {Position = UDim2.new(0, 14, 0, 11), Size = UDim2.new(0, 36, 0, 36), BackgroundColor3 = Color3.new(1, 1, 1)}, header)
corner(badge, 11)
grad(badge, 45)
new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "A", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextSize = 22}, badge)
local title = new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, 58, 0, 7), Size = UDim2.new(0, 260, 0, 26), Text = "ASTA CRA v6", TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextSize = 21, TextXAlignment = Enum.TextXAlignment.Left}, header)
grad(title, 0)
new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, 58, 0, 32), Size = UDim2.new(0, 260, 0, 16), Text = T("أدوات القنبلة • نسخة مطوّرة", "Bomb tools • Premium build"), TextColor3 = P.sub, Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, header)
local function headBtn(x, text)
local b = new("TextButton", {Text = text, AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, x, 0, 13), Size = UDim2.new(0, 34, 0, 32), BackgroundColor3 = P.card2, TextColor3 = P.text, Font = Enum.Font.GothamBold, TextSize = 16}, header)
corner(b, 10)
stroke(b, P.line, 1, 0.4)
return b
end
local closeBtn = headBtn(-12, "✕")
local miniBtn = headBtn(-52, "–")
local lockBtn = headBtn(-92, "🔓")
local fpsChip = new("TextLabel", {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -136, 0, 15), Size = UDim2.new(0, 84, 0, 28), BackgroundColor3 = P.card, Text = "-- FPS", TextColor3 = P.ok, Font = Enum.Font.GothamBold, TextSize = 12}, header)
corner(fpsChip, 9)
stroke(fpsChip, P.line, 1, 0.5)
new("Frame", {Position = UDim2.new(0, 14, 1, -1), Size = UDim2.new(1, -28, 0, 1), BackgroundColor3 = P.line, BackgroundTransparency = 0.5, BorderSizePixel = 0}, header)
local fpsN = 0
table.insert(conns, RunService.RenderStepped:Connect(function()
fpsN = fpsN + 1
end))
task.spawn(function()
while not closed do
task.wait(1)
if fpsChip.Parent then
fpsChip.Text = tostring(fpsN) .. " FPS"
end
fpsN = 0
end
end)
local bubble = new("TextButton", {Text = "ASTA CRA v6", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 70), Size = UDim2.new(0, 142, 0, 38), BackgroundColor3 = P.card, TextColor3 = P.text, Font = Enum.Font.GothamBlack, TextSize = 13, Visible = false, ZIndex = 120}, gui)
corner(bubble, 19)
stroke(bubble, P.a1, 2, 0.1)
local locked = false
lockBtn.MouseButton1Click:Connect(function()
locked = not locked
lockBtn.Text = locked and "🔒" or "🔓"
end)
local savedPos
local function hideWin()
savedPos = frame.Position
tw(uiScale, 0.18, {Scale = 0.01})
task.delay(0.2, function()
frame.Visible = false
bubble.Visible = true
end)
end
local function showWin()
bubble.Visible = false
if savedPos then
frame.Position = savedPos
end
frame.Visible = true
tw(uiScale, 0.3, {Scale = WIDGET_SCALE}, Enum.EasingStyle.Back)
end
miniBtn.MouseButton1Click:Connect(hideWin)
closeBtn.MouseButton1Click:Connect(hideWin)
bubble.MouseButton1Click:Connect(showWin)
local SIDE_W = 150
local side = new("Frame", {Position = UDim2.new(0, 10, 0, 66), Size = UDim2.new(0, SIDE_W, 1, -76), BackgroundColor3 = P.card, BackgroundTransparency = 0.25}, frame)
corner(side, 14)
stroke(side, P.line, 1, 0.5)
local sideList = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new()}, side)
new("UIListLayout", {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder}, sideList)
new("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8)}, sideList)
local pages, tabBtns = {}, {}
local CONTENT_X = SIDE_W + 20
local function newPage(id)
local f = new("ScrollingFrame", {Position = UDim2.new(0, CONTENT_X, 0, 66), Size = UDim2.new(1, -(CONTENT_X + 10), 1, -76), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = P.a1, AutomaticCanvasSize = Enum.AutomaticSize.Y, CanvasSize = UDim2.new(), Visible = false, ScrollingDirection = Enum.ScrollingDirection.Y}, frame)
new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, f)
new("UIPadding", {PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 10)}, f)
pages[id] = f
return f
end
local function showTab(id)
for k, f in pairs(pages) do
f.Visible = (k == id)
end
for k, b in pairs(tabBtns) do
local on = (k == id)
tw(b.fill, 0.2, {BackgroundTransparency = on and 0 or 1})
b.lbl.TextColor3 = on and Color3.new(1, 1, 1) or P.sub
b.bar.Visible = on
end
end
local TABS = { {"main", "⚡", T("الاوتو والاسيست", "Auto & Assist")}, {"skins", "👤", T("السكنات", "Skins")}, {"fx", "✨", T("تأثيرات القتل", "Kill FX")}, {"songs", "🎵", T("الأغاني", "Songs")}, {"extra", "🎭", T("ميزات", "Extras")}, {"misc", "⚙", T("الإعدادات", "Settings")}, {"info", "ℹ", T("معلوماتي", "My Info")}, }
for n, t in ipairs(TABS) do
local b = new("TextButton", {Text = "", AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, LayoutOrder = n, ClipsDescendants = true}, sideList)
corner(b, 10)
local fill = new("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, BorderSizePixel = 0}, b)
corner(fill, 10)
grad(fill, 0)
local lbl = new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(1, -10, 1, 0), Text = t[2] .. " " .. t[3], TextColor3 = P.sub, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 2}, b)
local bar = new("Frame", {Position = UDim2.new(0, 0, 0.5, -9), Size = UDim2.new(0, 3, 0, 18), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, Visible = false, ZIndex = 3}, b)
corner(bar, 2)
tabBtns[t[1]] = {btn = b, fill = fill, lbl = lbl, bar = bar}
b.MouseButton1Click:Connect(function()
showTab(t[1])
end)
end
local order = setmetatable({}, {__mode = "k"})
local function nextOrder(parent)
order[parent] = (order[parent] or 0) + 1
return order[parent]
end
local function section(page, text)
local l = new("TextLabel", {Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Text = text, TextColor3 = P.a1, Font = Enum.Font.GothamBlack, TextSize = 13, TextXAlignment = TXT_ALIGN, LayoutOrder = nextOrder(page)}, page)
return l
end
local function note(page, text)
local l = new("TextLabel", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Text = text, TextColor3 = P.sub, Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true, TextXAlignment = TXT_ALIGN, LayoutOrder = nextOrder(page)}, page)
return l
end
local function cardFrame(page, h)
local c = new("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = P.card, LayoutOrder = nextOrder(page)}, page)
corner(c, 13)
stroke(c, P.line, 1, 0.55)
return c
end
local function press(b)
local sc = new("UIScale", {Scale = 1}, b)
b.MouseButton1Down:Connect(function()
tw(sc, 0.08, {Scale = 0.96})
end)
b.MouseButton1Up:Connect(function()
tw(sc, 0.12, {Scale = 1})
end)
b.MouseLeave:Connect(function()
tw(sc, 0.12, {Scale = 1})
end)
end
local function button(page, text, cb, color)
local b = new("TextButton", {Text = text, AutoButtonColor = false, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = color or P.card2, TextColor3 = P.text, Font = Enum.Font.GothamBold, TextSize = 14, LayoutOrder = nextOrder(page)}, page)
corner(b, 12)
stroke(b, P.line, 1, 0.5)
press(b)
b.MouseButton1Click:Connect(function()
pcall(cb)
end)
return b
end
local function toggle(page, titleText, desc, get, set)
local h = desc and desc ~= "" and 58 or 44
local c = cardFrame(page, h)
local btn = new("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, c)
local tx = AR and 70 or 14
local tx2 = AR and 14 or 70
new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, tx, 0, desc and 8 or 0), Size = UDim2.new(1, -(tx + tx2), 0, desc and 20 or h), Text = titleText, TextColor3 = P.text, Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = TXT_ALIGN}, btn)
if desc and desc ~= "" then
new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, tx, 0, 29), Size = UDim2.new(1, -(tx + tx2), 0, 24), Text = desc, TextColor3 = P.sub, Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, TextXAlignment = TXT_ALIGN, TextYAlignment = Enum.TextYAlignment.Top}, btn)
end
local sw = new("Frame", {AnchorPoint = Vector2.new(AR and 0 or 1, 0.5), Position = UDim2.new(AR and 0 or 1, AR and 14 or -14, 0.5, 0), Size = UDim2.new(0, 46, 0, 24), BackgroundColor3 = P.card2}, btn)
corner(sw, 12)
local swg = grad(sw, 0)
swg.Enabled = false
local knob = new("Frame", {Position = UDim2.new(0, 3, 0.5, -9), Size = UDim2.new(0, 18, 0, 18), BackgroundColor3 = Color3.new(1, 1, 1)}, sw)
corner(knob, 9)
local obj = {}
function obj.render()
local on = get() and true or false
swg.Enabled = on
tw(sw, 0.15, {BackgroundColor3 = on and Color3.new(1, 1, 1) or P.card2})
tw(knob, 0.18, {Position = on and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, Enum.EasingStyle.Back)
end
btn.MouseButton1Click:Connect(function()
pcall(set, not get())
obj.render()
end)
obj.render()
return obj
end
local function slider(page, titleText, minV, maxV, step, get, set, fmt)
local c = cardFrame(page, 56)
local nameL = new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 6), Size = UDim2.new(0.6, 0, 0, 20), Text = titleText, TextColor3 = P.text, Font = Enum.Font.GothamBold, TextSize = 13, TextXAlignment = TXT_ALIGN}, c)
local valL = new("TextLabel", {BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 6), Size = UDim2.new(0.3, 0, 0, 20), Text = "", TextColor3 = P.a1, Font = Enum.Font.GothamBlack, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right}, c)
if AR then
nameL.Position = UDim2.new(0.4, -14, 0, 6)
nameL.Size = UDim2.new(0.6, 0, 0, 20)
valL.AnchorPoint = Vector2.new(0, 0)
valL.Position = UDim2.new(0, 14, 0, 6)
valL.TextXAlignment = Enum.TextXAlignment.Left
end
local hit = new("TextButton", {Position = UDim2.new(0, 10, 0, 28), Size = UDim2.new(1, -20, 0, 24), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, c)
local bar = new("Frame", {Position = UDim2.new(0, 0, 0.5, -3), Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = P.card2}, hit)
corner(bar, 3)
local fill = new("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = Color3.new(1, 1, 1)}, bar)
corner(fill, 3)
grad(fill, 0)
local knob = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(0, 16, 0, 16), BackgroundColor3 = Color3.new(1, 1, 1)}, bar)
corner(knob, 8)
stroke(knob, P.a1, 2, 0)
local s = {}
function s.render()
local v = get()
local r = math.clamp((v - minV) / (maxV - minV), 0, 1)
fill.Size = UDim2.new(r, 0, 1, 0)
knob.Position = UDim2.new(r, 0, 0.5, 0)
valL.Text = fmt and fmt(v) or tostring(v)
end
function s.setFromX(px)
local aw = math.max(bar.AbsoluteSize.X, 1)
local r = math.clamp((px - bar.AbsolutePosition.X) / aw, 0, 1)
local v = minV + r * (maxV - minV)
v = math.floor(v / step + 0.5) * step
v = math.clamp(v, minV, maxV)
pcall(set, v)
s.render()
end
hit.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
sliding = s
s.setFromX(i.Position.X)
end
end)
s.render()
return s
end
local function inputRow(page, placeholder, btnText, cb)
local c = cardFrame(page, 48)
local box = new("TextBox", {Position = UDim2.new(0, 8, 0, 7), Size = UDim2.new(1, -112, 0, 34), BackgroundColor3 = P.bg0, TextColor3 = P.text, PlaceholderText = placeholder, PlaceholderColor3 = P.sub, Text = "", ClearTextOnFocus = false, Font = Enum.Font.GothamMedium, TextSize = 14, ClipsDescendants = true, TextXAlignment = Enum.TextXAlignment.Left}, c)
corner(box, 10)
stroke(box, P.line, 1, 0.4)
new("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)}, box)
local go = new("TextButton", {Text = btnText, AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 7), Size = UDim2.new(0, 94, 0, 34), BackgroundColor3 = P.a1, TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextSize = 13}, c)
corner(go, 10)
press(go)
local function fire()
cb(box.Text, box)
end
go.MouseButton1Click:Connect(fire)
box.FocusLost:Connect(function(enter)
if enter then
fire()
end
end)
return box, go
end
local pMain = newPage("main") do
local AutoGui = new("Frame", {Name = "AstaAutoMini", Position = UDim2.new(0.05, 0, 0.4, 0), Size = UDim2.new(0, 190, 0, 108), BackgroundColor3 = P.bg1, Active = true, Visible = false, ZIndex = 90}, gui)
corner(AutoGui, 16)
stroke(AutoGui, P.a1, 2, 0.15)
new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Text = T("الاوتو", "AUTO"), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextSize = 18, ZIndex = 91}, AutoGui)
local AutoBtn = new("TextButton", {Position = UDim2.new(0.07, 0, 0, 40), Size = UDim2.new(0.86, 0, 0, 52), Text = T("تفعيل", "START"), AutoButtonColor = false, BackgroundColor3 = P.ok, TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextSize = 20, ZIndex = 91}, AutoGui)
corner(AutoBtn, 12)
press(AutoBtn)
local FollowingState = false
local function renderAuto()
AutoBtn.Text = FollowingState and T("إيقاف", "STOP") or T("تفعيل", "START")
tw(AutoBtn, 0.15, {BackgroundColor3 = FollowingState and P.bad or P.ok})
end
AutoBtn.MouseButton1Click:Connect(function()
FollowingState = not FollowingState
renderAuto()
end) do
local drag, ds, sp = false, nil, nil
AutoGui.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
drag, ds, sp = true, i.Position, AutoGui.Position
end
end)
table.insert(conns, UserInputService.InputChanged:Connect(function(i)
if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
local d = i.Position - ds
AutoGui.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
end
end))
table.insert(conns, UserInputService.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
drag = false
end
end))
end
table.insert(conns, RunService.RenderStepped:Connect(function()
if closed or not (AutoGui.Visible and FollowingState) then
return
end
if AstaAssist.manualHeld() then
return
end
local MyChar = lp.Character
local MyHum = MyChar and MyChar:FindFirstChildOfClass("Humanoid")
local MyRoot = MyChar and MyChar:FindFirstChild("HumanoidRootPart")
if not (MyHum and MyRoot) or MyHum.Health <= 0 then
return
end
local HasTool = MyChar:FindFirstChildOfClass("Tool")
local grabOn = AstaAssist.isGrab()
if HasTool or grabOn then
local TargetRoot = AstaAssist.pickTarget(MyRoot, (not HasTool) and grabOn, 1e9)
if TargetRoot then
MyHum:MoveTo(TargetRoot.Position)
end
end
end))
local st = {assist = false, grab = false, jump = false, auto = false, grabDelay = 10}
section(pMain, T("الاوتو والاسيست", "AUTO & ASSIST"))
toggle(pMain, T("الاوتو", "Auto"), T("يطلع زر عائم تشغّل منه الاوتو وتحركه وين تبي", "Shows a floating button to start/stop Auto, drag it anywhere"), function()
return st.auto
end, function(v)
st.auto = v
AutoGui.Visible = v
if not v then
FollowingState = false
renderAuto()
end
end)
toggle(pMain, T("اسيست Asta top1", "Asta top1 Assist"), T("يلحق الخصم ويوقف قريب منه", "Chases the opponent and stops close"), function()
return st.assist
end, function(v)
st.assist = v
AstaAssist.SetAssist(v)
end)
toggle(pMain, T("اوتو قراب", "Auto Grab"), T("ياخذ القنبلة لما تقرب من الخصم، ومع الاسيست يروح له ياخذها", "Takes the bomb when you are close; with Assist it goes for it"), function()
return st.grab
end, function(v)
st.grab = v
AstaAssist.SetGrab(v)
end)
slider(pMain, T("عداد الاوتو قراب (ثواني)", "Auto Grab timer (sec)"), 1, 10, 1, function()
return st.grabDelay
end, function(v)
st.grabDelay = v
AstaAssist.SetGrabDelay(v)
end, function(v)
return tostring(v) .. "s"
end)
toggle(pMain, T("اوتو نط", "Auto Jump"), T("يلحق الخصم وإذا نط ينط معه", "Chases and jumps when the opponent jumps"), function()
return st.jump
end, function(v)
st.jump = v
AstaAssist.SetJump(v)
end)
toggle(pMain, T("بدون تعلق بالجدران", "No wall stick"), T("مثل جدار وهمي: يمنعك تقرب من الجدار أكتر من المسافة، بدون ما يحركك لوحده", "Acts like an invisible wall: stops you from getting closer than the distance, never moves you by itself"), function()
return st.stick
end, function(v)
st.stick = v
AstaAssist.SetAntiStick(v)
end)
slider(pMain, T("مسافة الجدار (1-10)", "Wall distance (1-10)"), 1, 10, 1, function()
return st.wallDist or 4
end, function(v)
st.wallDist = v
AstaAssist.SetWallDist(v)
end, function(v)
return tostring(v)
end)
note(pMain, T("كل الميزات مطفية لين تشغلها بنفسك. لو حركت العصا أو WASD بيدك الاسيست والاوتو يوقفون ويكملون لما تشيل يدك.", "Everything is off until you enable it. If you move with the joystick/WASD, Assist and Auto pause and resume when you let go."))
table.insert(conns, {Disconnect = function()
pcall(function()
AutoGui:Destroy()
end)
end})
end
local pSkins = newPage("skins") do
section(pSkins, T("جلب سكن أي لاعب", "COPY ANY PLAYER'S SKIN"))
local status
local box = inputRow(pSkins, T("اكتب يوزر اللاعب (مثال: Roblox)", "Type a username (e.g. Roblox)"), T("لبس السكن", "Wear"), function(txt, bx)
applyCustomUsername(txt, function(msg, good)
if status then
status.Text = msg
status.TextColor3 = (good == true and P.ok) or (good == false and P.bad) or P.sub
end
if good ~= nil then
toast(msg, good and "ok" or "bad")
end
end)
end)
status = note(pSkins, T("يجيب سكن اللاعب حتى لو اللعبة ما تدعم تغيير الشكل (يجرب عدة طرق).", "Works even if the game doesn't support avatar changes (tries several methods)."))
button(pSkins, T("↩ إرجاع سكني الأصلي", "↩ Restore my original skin"), function()
restoreSkin()
status.Text = T("رجع شكلك الأصلي", "Your original look is back")
status.TextColor3 = P.sub
toast(T("رجع شكلك الأصلي", "Your original look is back"), "ok")
end)
local head = section(pSkins, T("المعرض", "GALLERY"))
local grid = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nextOrder(pSkins)}, pSkins)
new("UIGridLayout", {CellSize = UDim2.new(0, 88, 0, 100), CellPadding = UDim2.new(0, 8, 0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, grid)
local skinBtns = {}
buildSkinGallery = function()
if closed then
return
end
for _, ch in ipairs(grid:GetChildren()) do
if ch:IsA("GuiObject") then
ch:Destroy()
end
end
skinBtns = {}
head.Text = T("المعرض", "GALLERY") .. " (" .. #SKINS .. ")"
for k, sk in ipairs(SKINS) do
local b = new("ImageButton", {AutoButtonColor = false, Image = "", ScaleType = Enum.ScaleType.Crop, BackgroundColor3 = P.card, LayoutOrder = k}, grid)
corner(b, 12)
local stk = stroke(b, P.a1, 1.5, 0.6)
new("TextLabel", {AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 18), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, Text = tostring(sk.label or ""), TextColor3 = P.text, Font = Enum.Font.GothamMedium, TextSize = 10, TextTruncate = Enum.TextTruncate.AtEnd}, b)
skinBtns[k] = {b = b, st = stk}
b.MouseButton1Click:Connect(function()
selectSkin(k)
end)
task.spawn(function()
if k > 8 then
task.wait((k - 8) * 0.08)
end
if sk.build then
b.BackgroundColor3 = sk.color or P.card
return
end
local uid = nil
if sk.username then
uid = userIdOf(sk.username)
elseif SKIN.userId > 0 then
uid = SKIN.userId
elseif SKIN.username ~= "" then
uid = userIdOf(SKIN.username)
end
if uid then
local ok, url = pcall(function()
return Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
end)
if not (ok and url) then
url = "rbxthumb://type=AvatarBust&id=" .. uid .. "&w=420&h=420"
end
if b.Parent then
b.Image = url
end
elseif skinTexture and b.Parent then
b.Image = skinTexture
end
end)
end
refreshSkinButtons()
end
refreshSkinButtons = function()
for k, p in ipairs(skinBtns) do
local on = (k == currentSkin)
p.st.Color = on and P.ok or P.a1
p.st.Thickness = on and 3 or 1.5
p.st.Transparency = on and 0 or 0.6
end
end
buildSkinGallery()
end
local selectEffect
local pFx = newPage("fx") do
local lbl = section(pFx, "")
local fxBtns = {}
local function refreshFx()
for k, pp in ipairs(fxBtns) do
local on = (k == KFX.current)
pp.st.Color = on and P.ok or P.a1
pp.st.Thickness = on and 3 or 1.5
pp.st.Transparency = on and 0 or 0.6
end
local e = KFX.list[KFX.current]
lbl.Text = T("تأثير القتل: ", "KILL EFFECT: ") .. ((e and e.id ~= "none") and (e.en .. " | " .. e.ar) or T("بدون", "None"))
end
selectEffect = function(k)
KFX.current = k
refreshFx()
end
local grid = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nextOrder(pFx)}, pFx)
new("UIGridLayout", {CellSize = UDim2.new(0.5, -4, 0, 54), CellPadding = UDim2.new(0, 8, 0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, grid)
for k, e in ipairs(KFX.list) do
local b = new("TextButton", {Text = "", AutoButtonColor = false, BackgroundColor3 = P.card, LayoutOrder = k}, grid)
corner(b, 12)
press(b)
local stk = stroke(b, P.a1, 1.5, 0.6)
new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 8), Size = UDim2.new(1, 0, 0, 18), Text = e.en, TextColor3 = P.text, Font = Enum.Font.GothamBold, TextSize = 14}, b)
new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 28), Size = UDim2.new(1, 0, 0, 18), Text = e.ar, TextColor3 = P.sub, Font = Enum.Font.Gotham, TextSize = 13}, b)
fxBtns[k] = {b = b, st = stk}
b.MouseButton1Click:Connect(function()
selectEffect(k)
end)
end
refreshFx()
end
local pSongs = newPage("songs") do
local SoundService = game:GetService("SoundService")
local SONGS_FILE = "AstaGG_songs.json"
local songs = { }
local nowName = nil
local songCache = {}
songSound = Instance.new("Sound")
songSound.Name = "AstaGGSong"
songSound.Volume = 0.6
songSound.Looped = false
songSound.Parent = SoundService
local function decodeAudio(s)
local clean = string.gsub(s, "[^%w%+/=]", "")
local native = (crypt and (crypt.base64decode or (crypt.base64 and crypt.base64.decode))) or (syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.decode) or base64_decode or (base64 and base64.decode)
if native then
local ok, res = pcall(native, clean)
if ok and type(res) == "string" and string.sub(res, 1, 4) == "OggS" then
return res
end
end
return b64decode(clean)
end
local function songAsset(s)
if songCache[s] then
return songCache[s]
end
local asset
if s.kind == "embed" then
local fname = "AstaGG_" .. s.value .. ".ogg"
writefile(fname, decodeAudio(SONG_DATA[s.value]))
asset = getcustomasset(fname)
elseif s.kind == "id" then
asset = "rbxassetid://" .. s.value
else
local ext = string.find(string.lower(s.value), "%.ogg") and "ogg" or "mp3"
local fname = "AstaGG_url_" .. tostring(#s.value) .. "_" .. tostring(os.time() % 100000) .. "." .. ext
writefile(fname, game:HttpGet(s.value))
asset = getcustomasset(fname)
end
songCache[s] = asset
return asset
end
local repeatCount, repeatLeft = 1, 0
section(pSongs, T("مشغل الأغاني", "SONG PLAYER"))
local nowLbl = note(pSongs, T("لا شي يشتغل", "Nothing playing"))
nowLbl.TextColor3 = P.a1
button(pSongs, "■ " .. T("إيقاف", "Stop"), function()
pcall(function()
songSound:Stop()
end)
repeatLeft = 0
nowName = nil
nowLbl.Text = T("لا شي يشتغل", "Nothing playing")
end, P.card2)
toggle(pSongs, T("تكرار لا نهائي", "Loop forever"), "", function()
return songSound.Looped
end, function(v)
songSound.Looped = v
end)
slider(pSongs, T("مستوى الصوت", "Volume"), 0, 100, 5, function()
return math.floor(songSound.Volume * 100 + 0.5)
end, function(v)
songSound.Volume = v / 100
end, function(v)
return tostring(v) .. "%"
end)
slider(pSongs, T("عدد التكرار", "Repeat count"), 1, 100, 1, function()
return repeatCount
end, function(v)
repeatCount = v
if nowName then
repeatLeft = v - 1
end
end, function(v)
return "x" .. tostring(v)
end)
songSound.Ended:Connect(function()
if closed or songSound.Looped or repeatLeft <= 0 or not nowName then
return
end
repeatLeft = repeatLeft - 1
pcall(function()
songSound.TimePosition = 0
songSound:Play()
end)
end)
local listFrame
local renderSongs
local function saveSongs()
pcall(function()
local out = {}
for _, s in ipairs(songs) do
if s.custom then
table.insert(out, {name = s.name, kind = s.kind, value = s.value})
end
end
writefile(SONGS_FILE, HttpSvc:JSONEncode(out))
end)
end
local function playSong(s)
nowLbl.Text = T("جاري التحميل: ", "Loading: ") .. s.name
task.spawn(function()
local ok = pcall(function()
local asset = songAsset(s)
songSound:Stop()
songSound.SoundId = asset
songSound:Play()
end)
if ok then
nowName = s.name
repeatLeft = repeatCount - 1
nowLbl.Text = T("يشتغل: ", "Playing: ") .. s.name
else nowLbl.Text = T("ما اشتغلت الأغنية (جرّب غيرها)", "Could not play this song")
toast(T("فشل تشغيل الأغنية", "Song failed to play"), "bad")
end
end)
end
inputRow(pSongs, T("رقم الصوت أو رابط mp3/ogg", "Sound ID or mp3/ogg link"), "+ " .. T("إضافة", "Add"), function(txt, bx)
txt = string.gsub(string.gsub(txt or "", "^%s+", ""), "%s+$", "")
if txt == "" then
return
end
local added = 0
for tok in string.gmatch(txt, "[^%s,;]+") do
local id = string.match(tok, "^(%d+)$") or string.match(tok, "rbxassetid://(%d+)")
if id then
table.insert(songs, {name = "ID " .. id, kind = "id", value = id, custom = true})
added = added + 1
elseif string.find(tok, "^https?://") then
local nm = string.match(tok, "([^/%?]+)%s*$") or "Link"
table.insert(songs, {name = nm, kind = "url", value = tok, custom = true})
added = added + 1
end
end
if added == 0 then
toast(T("اكتب رقم صوت أو رابط", "Enter a sound ID or a link"), "bad")
return
end
bx.Text = ""
saveSongs()
renderSongs()
end)
section(pSongs, T("القائمة", "PLAYLIST"))
listFrame = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = nextOrder(pSongs)}, pSongs)
new("UIListLayout", {Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder}, listFrame)
renderSongs = function()
for _, ch in ipairs(listFrame:GetChildren()) do
if ch:IsA("GuiObject") then
ch:Destroy()
end
end
for k, s in ipairs(songs) do
local row = new("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = P.card, LayoutOrder = k}, listFrame)
corner(row, 11)
stroke(row, P.line, 1, 0.6)
new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, s.custom and -120 or -76, 1, 0), Text = s.name, TextColor3 = P.text, Font = Enum.Font.GothamMedium, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, row)
local play = new("TextButton", {Text = "▶", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0), Size = UDim2.new(0, 46, 0, 28), BackgroundColor3 = P.a1, TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 14}, row)
corner(play, 9)
play.MouseButton1Click:Connect(function()
playSong(s)
end)
if s.custom then
local del = new("TextButton", {Text = "✕", AutoButtonColor = false, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -58, 0.5, 0), Size = UDim2.new(0, 40, 0, 28), BackgroundColor3 = Color3.fromRGB(120, 30, 44), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 13}, row)
corner(del, 9)
del.MouseButton1Click:Connect(function()
table.remove(songs, k)
saveSongs()
renderSongs()
end)
end
end
end
pcall(function()
if isfile and isfile(SONGS_FILE) then
local data = HttpSvc:JSONDecode(readfile(SONGS_FILE))
for _, d in ipairs(data) do
if d.name and d.kind and d.value then
table.insert(songs, {name = d.name, kind = d.kind, value = d.value, custom = true})
end
end
end
end)
renderSongs()
end
local pExtra = newPage("extra")
local X = {headless = HEADLESS, korblox = KORBLOX, wall = false, kbOrig = nil} do
local function charOf()
return lp.Character
end
local savedHead = {}
local function headlessStep()
local c = charOf()
local hd = c and c:FindFirstChild("Head")
if not hd then
return
end
local list = {hd}
for _, d in ipairs(hd:GetChildren()) do
if d:IsA("Decal") then
table.insert(list, d)
end
end
for _, o in ipairs(list) do
if savedHead[o] == nil then
savedHead[o] = o.Transparency
end
o.Transparency = 1
if o:IsA("BasePart") then
o.LocalTransparencyModifier = 1
end
end
end
local function headlessRestore()
for o, t in pairs(savedHead) do
pcall(function()
if o.Parent then
o.Transparency = t
if o:IsA("BasePart") then
o.LocalTransparencyModifier = 0
end
end
end)
end
savedHead = {}
end
local hlAcc = 0
table.insert(conns, RunService.RenderStepped:Connect(function(dt)
if closed or not X.headless then
return
end
hlAcc = hlAcc + dt
if hlAcc < 0.1 then
return
end
hlAcc = 0
pcall(headlessStep)
end))
local function korbloxSet(on)
local c = charOf()
if not c then
return
end
task.spawn(applyKorblox, c, on)
end
local lastHop = 0
local rp = RaycastParams.new()
rp.FilterType = Enum.RaycastFilterType.Exclude
table.insert(conns, UserInputService.JumpRequest:Connect(function()
if closed or not X.wall then
return
end
local c = charOf()
local hum = c and c:FindFirstChildOfClass("Humanoid")
local hrp = c and c:FindFirstChild("HumanoidRootPart")
if not (hum and hrp and hum.Health > 0) then
return
end
if hum.FloorMaterial ~= Enum.Material.Air then
return
end
if os.clock() - lastHop < 0.18 then
return
end
rp.FilterDescendantsInstances = {c}
local best, bestD = nil, 3.2
local cf = hrp.CFrame
for _, dir in ipairs({cf.LookVector, -cf.LookVector, cf.RightVector, -cf.RightVector}) do
local hit = workspace:Raycast(hrp.Position, dir * 3.2, rp)
if hit and math.abs(hit.Normal.Y) < 0.35 and hit.Distance < bestD then
best, bestD = hit, hit.Distance
end
end
if not best then
return
end
lastHop = os.clock()
local n = best.Normal
local jp = hum.UseJumpPower and hum.JumpPower or math.sqrt(2 * workspace.Gravity * hum.JumpHeight)
hrp.AssemblyLinearVelocity = Vector3.new(-n.X * 4, math.max(jp, 50), -n.Z * 4)
end))
local function applyAll()
if X.headless then
pcall(headlessStep)
end
if X.korblox then
korbloxSet(true)
end
end
table.insert(conns, lp.CharacterAdded:Connect(function()
X.kbOrig = nil
savedHead = {}
task.delay(1.5, function()
if not closed then
applyAll()
end
end)
end))
task.delay(2, function()
if not closed then
applyAll()
end
end)
local tHead, tKor
section(pExtra, T("المظهر (يظهر لك فقط)", "LOOKS (only you see them)"))
tHead = toggle(pExtra, "Headless", T("إخفاء الراس", "Hide your head"), function()
return X.headless
end, function(v)
X.headless = v
HEADLESS = v
if not v then
headlessRestore()
end
end)
tKor = toggle(pExtra, "Korblox", T("الرجل اليمين تصير Korblox", "Right leg becomes Korblox"), function()
return X.korblox
end, function(v)
X.korblox = v
KORBLOX = v
korbloxSet(v)
end)
SkinHooks.setHeadless = function(v)
if X.headless ~= v then
X.headless = v
HEADLESS = v
tHead.render()
end
end
SkinHooks.setKorblox = function(v)
if X.korblox ~= v then
X.korblox = v
KORBLOX = v
korbloxSet(v)
tKor.render()
end
end
X.kglow = false
toggle(pExtra, "Korblox Glow", T("توهج سماوي حول رجل Korblox (يظهر لك فقط)", "Teal glow on the Korblox leg (only you see it)"), function()
return X.kglow
end, function(v)
X.kglow = v
local c = charOf()
if c and X.korblox then
task.spawn(applyKorblox, c, true, v)
else applyKorblox(nil, false, v)
end
end)
section(pExtra, T("معلومات", "INFO")) do
local hud, hudOn, hudAcc, fpsSmooth = nil, false, 0, 60
local StatsSvc = game:GetService("Stats")
table.insert(conns, RunService.Heartbeat:Connect(function(dt)
if closed or not hudOn or not hud then
return
end
fpsSmooth = fpsSmooth + (1 / math.max(dt, 1e-4) - fpsSmooth) * 0.1
hudAcc = hudAcc + dt
if hudAcc < 0.4 then
return
end
hudAcc = 0
local ping = 0
pcall(function()
ping = StatsSvc.Network.ServerStatsItem["Data Ping"]:GetValue()
end)
hud.Text = string.format("FPS %d | PING %d ms", math.floor(fpsSmooth + 0.5), math.floor(ping + 0.5))
end))
toggle(pExtra, "FPS / Ping", T("عداد الفريمات والبنق أعلى الشاشة", "FPS and ping counter at the top"), function()
return hudOn
end, function(v)
hudOn = v
if v and not hud then
hud = new("TextLabel", {Name = "AstaHud", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 6), Size = UDim2.fromOffset(170, 22), BackgroundColor3 = C.bg, BackgroundTransparency = 0.3, BorderSizePixel = 0, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.text, Text = "...", ZIndex = 60}, gui)
corner(hud, 6)
stroke(hud, C.red, 1, 0.4)
end
if hud then
hud.Visible = v
end
end)
end
section(pExtra, T("حركة", "MOVEMENT"))
toggle(pExtra, "Wall Hop", T("قرّب من جدار وانت بالهوا واضغط نط بسرعة: كل ضغطة تطلعك فوق", "Near a wall in the air, tap Jump repeatedly to hop up"), function()
return X.wall
end, function(v)
X.wall = v
end)
section(pExtra, T("تدعيس", "STOMP"))
local StompGui = new("Frame", {Name = "AstaStompMini", Position = UDim2.new(0.05, 0, 0.62, 0), Size = UDim2.new(0, 190, 0, 108), BackgroundColor3 = P.bg1, Active = true, Visible = false, ZIndex = 90}, gui)
corner(StompGui, 16)
stroke(StompGui, P.a1, 2, 0.15)
new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 34), Text = T("تدعيس", "STOMP"), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextSize = 18, ZIndex = 91}, StompGui)
local StompBtn = new("TextButton", {Position = UDim2.new(0.07, 0, 0, 40), Size = UDim2.new(0.86, 0, 0, 52), Text = T("تفعيل", "START"), AutoButtonColor = false, BackgroundColor3 = P.ok, TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBlack, TextSize = 20, ZIndex = 91}, StompGui)
corner(StompBtn, 12)
press(StompBtn)
StompBtn.Text = T("دعس", "STOMP")
local stompRun, stompTok = false, 0
local function renderStomp()
StompBtn.Text = stompRun and T("جاري الدعس...", "STOMPING...") or T("دعس", "STOMP")
tw(StompBtn, 0.15, {BackgroundColor3 = stompRun and P.bad or P.ok})
end
local function startStomp()
if closed or stompRun then
return
end
stompTok = stompTok + 1
local my = stompTok
stompRun = true
renderStomp()
task.spawn(function()
local endT = os.clock() + 3
while not closed and my == stompTok and os.clock() < endT do
local ch = lp.Character
local hm = ch and ch:FindFirstChildOfClass("Humanoid")
local hr = ch and ch:FindFirstChild("HumanoidRootPart")
if hm and hr and hm.Health > 0 then
hm:MoveTo(hr.Position + hr.CFrame.LookVector * 2.5)
task.wait(0.07)
local ch2 = lp.Character
local hm2 = ch2 and ch2:FindFirstChildOfClass("Humanoid")
local hr2 = ch2 and ch2:FindFirstChild("HumanoidRootPart")
if hm2 and hr2 and hm2.Health > 0 and my == stompTok then
hm2:MoveTo(hr2.Position - hr2.CFrame.LookVector * 2.5)
end
end
task.wait(0.07)
end
if my == stompTok then
stompRun = false
end
renderStomp()
end)
end
StompBtn.MouseButton1Click:Connect(startStomp) do
local drag, ds, sp = false, nil, nil
StompGui.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
drag, ds, sp = true, i.Position, StompGui.Position
end
end)
table.insert(conns, UserInputService.InputChanged:Connect(function(i)
if drag and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
local d = i.Position - ds
StompGui.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
end
end))
table.insert(conns, UserInputService.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
drag = false
end
end))
end
toggle(pExtra, T("تدعيس", "Stomp"), T("يطلع زر عائم: كل كبسة تدعس 3 ثواني بمكانك (خطوة قدام وخطوة ورا)", "Shows a floating button: each press stomps for 3 seconds in place (step forward/back)"), function()
return StompGui.Visible
end, function(v)
StompGui.Visible = v
if not v then
stompTok = stompTok + 1
stompRun = false
renderStomp()
end
end)
slider(pExtra, T("سرعة الضغط (CPS)", "Click speed (CPS)"), 1, 20, 1, function()
return clickCPS
end, function(v)
clickCPS = v
end, function(v)
return tostring(v)
end)
end
local pMisc = newPage("misc") do
local function bombIndex()
for k, e in ipairs(KFX.list) do
if e.id == "redbomb" then
return k
end
end
return 1
end
section(pMisc, T("الجودة", "QUALITY"))
toggle(pMisc, T("جودة سينمائية + قنبلة حمراء", "Cinematic quality + red bomb"), T("جودة أعلى للماب وقنبلة تلمع أحمر/أبيض (عندك بس)", "Better map visuals and a glowing red/white bomb (only you)"), function()
return CINE.on
end, function(v)
local bi = bombIndex()
if v then
CINE.apply()
if KFX.current ~= bi then
KFX.prev = KFX.current
end
selectEffect(bi)
else CINE.restore()
if KFX.current == bi then
selectEffect(KFX.prev or 1)
end
end
BOMBSKIN.set(v)
end)
local function labelOf(list, id)
for _, e in ipairs(list) do
if e.id == id then
return T(e.ar, e.en)
end
end
return "?"
end
local function nextId(list, id)
for k, e in ipairs(list) do
if e.id == id then
return list[k % #list + 1].id
end
end
return list[1].id
end
local qBtn, bBtn
qBtn = button(pMisc, "", function()
CINE.setPreset(nextId(CINE.presetList, CINE.preset))
qBtn.Text = T("نوع الجودة: ", "Quality type: ") .. labelOf(CINE.presetList, CINE.preset)
end)
qBtn.Text = T("نوع الجودة: ", "Quality type: ") .. labelOf(CINE.presetList, CINE.preset)
toggle(pMisc, T("جودة NVIDIA", "NVIDIA quality"), T("ألوان حيّة + تباين وحدّة + إضاءة Future (عندك بس)", "Vivid colours, contrast and Future lighting (only you)"), function()
return CINE.on and CINE.preset == "nvidia"
end, function(v)
if v then
CINE.setPreset("nvidia")
if not CINE.on then
CINE.apply()
end
else CINE.restore()
end
qBtn.Text = T("نوع الجودة: ", "Quality type: ") .. labelOf(CINE.presetList, CINE.preset)
end)
toggle(pMisc, T("قنبلة ملونة فقط", "Coloured bomb only"), T("تلوين القنبلة اللي بيدك بدون تغيير الجودة (عندك بس)", "Recolour the bomb in hand without changing quality (only you)"), function()
return BOMBSKIN.on
end, function(v)
BOMBSKIN.set(v)
end)
bBtn = button(pMisc, "", function()
BOMBSKIN.setStyle(nextId(BOMBSKIN.styleList, BOMBSKIN.style))
bBtn.Text = T("لون القنبلة: ", "Bomb colour: ") .. labelOf(BOMBSKIN.styleList, BOMBSKIN.style)
end)
bBtn.Text = T("لون القنبلة: ", "Bomb colour: ") .. labelOf(BOMBSKIN.styleList, BOMBSKIN.style)
section(pMisc, "FOV")
table.insert(conns, RunService.RenderStepped:Connect(function()
if closed or not CINE.fovValue then
return
end
local cam = workspace.CurrentCamera
if cam and math.abs(cam.FieldOfView - CINE.fovValue) > 0.05 then
cam.FieldOfView = CINE.fovValue
end
end))
slider(pMisc, "FOV", 70, 120, 1, function()
return CINE.fovValue or 70
end, function(v)
CINE.fovValue = (v ~= 70) and v or nil
local cam = workspace.CurrentCamera
if cam then
cam.FieldOfView = v
end
end, function(v)
return tostring(math.floor(v + 0.5))
end)
section(pMisc, T("الواجهة", "INTERFACE"))
toggle(pMisc, T("قفل الواجهة", "Lock window"), T("تمنع تحريك النافذة", "Prevents dragging the window"), function()
return locked
end, function(v)
locked = v
lockBtn.Text = v and "🔒" or "🔓"
end)
slider(pMisc, T("حجم الواجهة", "UI size"), 0.5, 1.2, 0.05, function()
return WIDGET_SCALE
end, function(v)
WIDGET_SCALE = v
uiScale.Scale = v
end, function(v)
return string.format("%d%%", math.floor(v * 100 + 0.5))
end)
if CINE.on then
KFX.prev = KFX.current
selectEffect(bombIndex())
BOMBSKIN.set(true)
end
end
local pInfo = newPage("info") do
local Stats = game:GetService("Stats")
local function stat(words)
local ls = lp:FindFirstChild("leaderstats")
if not ls then
return "-"
end
for _, v in ipairs(ls:GetChildren()) do
local n = string.lower(v.Name)
for _, w in ipairs(words) do
if string.find(n, w, 1, true) and pcall(function()
return v.Value
end) then
return tostring(v.Value)
end
end
end
return "-"
end
local function ping()
local ok, v = pcall(function()
return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end)
return ok and tostring(math.floor(v)) .. " ms" or "-"
end
local function exec()
local ok, n = pcall(function()
return identifyexecutor and identifyexecutor()
end)
return (ok and n) and tostring(n) or "Unknown"
end
local ROWS = { {"👤", T("اسمك", "Name"), function()
return lp.DisplayName
end}, {"🏷", T("يوزرك", "Username"), function()
return lp.Name
end}, {"🆔", T("الآي دي", "ID"), function()
return tostring(lp.UserId)
end}, {"📅", T("عمر الحساب", "Account age"), function()
return tostring(lp.AccountAge) .. T(" يوم", " days")
end}, {"⚡", T("الهاك", "Executor"), exec}, {"🏆", T("فوزاتك", "Wins"), function()
return stat({"win", "فوز"})
end}, {"⚔", T("قتلاتك", "Kills"), function()
return stat({"kill", "قتل", "elim"})
end}, {"👥", T("اللاعبين", "Players"), function()
return tostring(#Players:GetPlayers())
end}, {"📡", T("البينق", "Ping"), ping}, }
section(pInfo, T("اضغط على أي سطر لنسخ القيمة", "TAP A ROW TO COPY THE VALUE"))
local labels = {}
for k, r in ipairs(ROWS) do
local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = P.card, Text = "", AutoButtonColor = false, LayoutOrder = nextOrder(pInfo)}, pInfo)
corner(b, 11)
stroke(b, P.line, 1, 0.6)
press(b)
local t = new("TextLabel", {BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 0), Size = UDim2.new(1, -28, 1, 0), Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = P.text, TextXAlignment = TXT_ALIGN, Text = ""}, b)
labels[k] = {t = t, v = ""}
b.MouseButton1Click:Connect(function()
pcall(function()
if setclipboard then
setclipboard(labels[k].v)
end
end)
toast(T("تم النسخ", "Copied"), "ok")
end)
end
local function refresh()
for k, r in ipairs(ROWS) do
local ok, v = pcall(r[3])
labels[k].v = ok and tostring(v) or "-"
labels[k].t.Text = r[1] .. " " .. r[2] .. ": " .. labels[k].v
end
end
refresh()
task.spawn(function()
while not closed do
task.wait(1)
if pInfo.Visible then
refresh()
end
end
end)
note(pInfo, "ASTA CRA v6 • by Asta")
end
local dragging, moved, dragStart, startPos = false, false, nil, nil
header.InputBegan:Connect(function(i)
if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
dragging, moved, dragStart, startPos = true, false, i.Position, frame.Position
end
end)
table.insert(conns, UserInputService.InputChanged:Connect(function(i)
if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement then
if sliding then
sliding.setFromX(i.Position.X)
elseif dragging then
local d = i.Position - dragStart
if d.Magnitude > 6 then
moved = true
end
if moved and not locked then
frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
end
end
end
end))
table.insert(conns, UserInputService.InputEnded:Connect(function(i)
if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then
sliding = nil
dragging = false
end
end))
showTab("main")
local intro = new("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.15, ZIndex = 300, Active = true}, gui)
local word = "ASTA CRA v6"
local letters = {}
local holder = new("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.45, 0), Size = UDim2.new(0, 520, 0, 70), BackgroundTransparency = 1, ZIndex = 301}, intro)
new("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 2)}, holder)
for k = 1, #word do
local ch = string.sub(word, k, k)
local l = new("TextLabel", {Size = UDim2.new(0, ch == " " and 16 or 34, 0, 64), BackgroundTransparency = 1, Text = ch, TextColor3 = Color3.new(1, 1, 1), TextTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 46, ZIndex = 302, LayoutOrder = k}, holder)
grad(l, 90)
letters[k] = l
end
local bar = new("Frame", {AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.45, 50), Size = UDim2.new(0, 0, 0, 3), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 302}, intro)
grad(bar, 0)
task.spawn(function()
for k = 1, #letters do
tw(letters[k], 0.18, {TextTransparency = 0})
task.wait(0.06)
end
tw(bar, 0.5, {Size = UDim2.new(0, 360, 0, 3)})
task.wait(0.8)
tw(intro, 0.4, {BackgroundTransparency = 1})
for _, l in ipairs(letters) do
tw(l, 0.4, {TextTransparency = 1})
end
tw(bar, 0.3, {BackgroundTransparency = 1})
frame.Visible = true
tw(uiScale, 0.45, {Scale = WIDGET_SCALE}, Enum.EasingStyle.Back)
task.wait(0.5)
intro:Destroy()
end) end __iife38564() end