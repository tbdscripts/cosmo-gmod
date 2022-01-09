local PANEL = {}

local IsValid = IsValid
local draw_RoundedBox = draw.RoundedBox
local draw_RoundedBoxEx = draw.RoundedBoxEx
local draw_SimpleText = draw.SimpleText

local scale
local function registerFonts()
  local scrH = ScrH()
  scale = function(num)
    return scrH / 1080 * num
  end

  surface.CreateFont("Cosmo.Notification.Title", {
    font = "Roboto",
    size = scale(20),
  })

  surface.CreateFont("Cosmo.Notification.Content", {
    font = "Roboto",
    size = scale(18),
  })
end

registerFonts()
hook.Add("OnScreenSizeChanged", "Cosmo.ReRegisterFonts", registerFonts)

function PANEL:Init()
  self.Theme = Cosmo.Config.NotificationTheme
  self.Lang = Cosmo.Config.Language

  local margin = scale(8)

  self.Header = self:Add("Panel")
  self.Header:Dock(TOP)
  
  self.Header.Paint = function(pnl, w, h)
    draw.RoundedBoxEx(self.Theme.Roundness, 0, 0, w, h, self.Theme.Header, true, true, false, false)
    draw_SimpleText(self.Lang.NotificationTitle, "Cosmo.Notification.Title", margin, h * 0.5, self.Theme.HeaderTitle, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end

  self.Content = self:Add("DLabel")
  self.Content:Dock(TOP)
  self.Content:DockMargin(margin, margin, margin, margin)
  self.Content:SetFont("Cosmo.Notification.Content")
  self.Content:SetText("Pending...")
  self.Content:SetWrap(true)
  self.Content:SetAutoStretchVertical(true)
end

function PANEL:SetData(ply, packageName)
  if not IsValid(ply) then
    return self:Remove()
  end

  self.PlayerName = ply:Nick()
  self.PackageName = packageName

  self.Content:SetText(
    self.Lang.NotificationContent
      :Replace(":package", self.PackageName)
      :Replace(":player", self.PlayerName)
  )
end

function PANEL:Paint(w, h)
  local aX, aY = self:LocalToScreen()

  Cosmo.Shadows.BeginShadow()
    draw.RoundedBox(self.Theme.Roundness, aX, aY, w, h, self.Theme.Background)
  Cosmo.Shadows.EndShadow(1, 1, 1)
end

function PANEL:PerformLayout(w, h)
  self.Header:SetTall(scale(30))
end

vgui.Register("Cosmo.Notification", PANEL, "EditablePanel")

local activeNotifs = {}

function Cosmo.PushNotification(ply, packageName)
  local pos = -1
  repeat
    pos = pos + 1
  until (not IsValid(activeNotifs[pos]))

  local notifH, margin = scale(100), scale(25)
  local scrW, notifW, yPos = ScrW(), scale(300), margin + (margin + notifH) * pos

  local notif = vgui.Create("Cosmo.Notification")
  notif:SetData(ply, packageName)

  notif:SetSize(notifW, notifH)
  notif:SetPos(scrW, yPos)
  notif:MoveTo(scrW - notifW - 25, yPos, .3)

  notif:AlphaTo(0, .3, Cosmo.Config.NotificationTime, function()
    if IsValid(notif) then
      notif:Remove()
    end
  end)

  activeNotifs[pos] = notif
end