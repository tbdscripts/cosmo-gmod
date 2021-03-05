local PANEL = {}

local scale
local function registerFonts()
  local scrH = ScrH()
  scale = function(num)
    return scrH / 1080 * num
  end

  surface.CreateFont("Cosmo.Notification.Title", {
    font = "Roboto",
    size = scale(20)
  })

  surface.CreateFont("Cosmo.Notification.Content", {
    font = "Roboto",
    size = scale(18)
  })
end

registerFonts()
hook.Add("OnScreenSizeChanged", "Cosmo.ReRegisterFonts", registerFonts)

local is_valid = IsValid
local surface_SetDrawColor = surface.SetDrawColor
local surface_DrawRect = surface.DrawRect
local draw_SimpleText = draw.SimpleText

function PANEL:Init()
  self.theme = Cosmo.Config.NotificationTheme
  self.lang = Cosmo.Config.Language
  self.margin = scale(8)

  self.header = self:Add("Panel")
  self.header:Dock(TOP)
  
  self.header.Paint = function(pnl, w, h)
    surface_SetDrawColor(self.theme.header)
    surface_DrawRect(0, 0, w, h)

    draw_SimpleText(self.lang.notification_title, "Cosmo.Notification.Title", self.margin, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end

  self.content = self:Add("DLabel")
  self.content:Dock(TOP)
  self.content:DockMargin(self.margin, self.margin, self.margin, self.margin)
  self.content:SetFont("Cosmo.Notification.Content")
  self.content:SetText("Pending...")
  self.content:SetWrap(true)
  self.content:SetAutoStretchVertical(true)
end

function PANEL:SetData(ply, packageName)
  if not is_valid(ply) then
    return self:Remove()
  end

  self.plyName = ply:Nick()
  self.packageName = packageName

  self.content:SetText(
    self.lang.notification_content
      :Replace(":package", self.packageName)
      :Replace(":player", self.plyName)
  )
end

function PANEL:Paint(w, h)
  local aX, aY = self:LocalToScreen()

  Cosmo.Shadows.BeginShadow()
    surface_SetDrawColor(self.theme.background)
    surface_DrawRect(aX, aY, w, h)
  Cosmo.Shadows.EndShadow(1, 1, 1)
end

function PANEL:PerformLayout(w, h)
  self.header:SetTall(scale(30))
end

vgui.Register("Cosmo.Notification", PANEL, "EditablePanel")

local activeNotifs = {}

function Cosmo:pushNotification(ply, packageName)
  local pos = -1
  repeat
    pos = pos + 1
  until (not is_valid(activeNotifs[pos]))

  local notifH, margin = scale(100), scale(25)
  local scrW, notifW, yPos = ScrW(), scale(300), margin + (margin + notifH) * pos

  local notif = vgui.Create("Cosmo.Notification")
  notif:SetData(ply, packageName)

  notif:SetSize(notifW, notifH)
  notif:SetPos(scrW, yPos)
  notif:MoveTo(scrW - notifW - 25, yPos, .3)

  notif:AlphaTo(0, .3, Cosmo.Config.NotificationTime, function()
    if is_valid(notif) then
      notif:Remove()
    end
  end)

  activeNotifs[pos] = notif
end