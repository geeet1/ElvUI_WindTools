local W, F, E, L = unpack((select(2, ...)))
local S = W.Modules.Skins

local _G = _G
local hooksecurefunc = hooksecurefunc

local InCombatLockdown = InCombatLockdown

local trackers = {
    _G.ScenarioObjectiveTracker,
    _G.UIWidgetObjectiveTracker,
    _G.CampaignQuestObjectiveTracker,
    _G.QuestObjectiveTracker,
    _G.AdventureObjectiveTracker,
    _G.AchievementObjectiveTracker,
    _G.MonthlyActivitiesObjectiveTracker,
    _G.ProfessionsRecipeTracker,
    _G.BonusObjectiveTracker,
    _G.WorldQuestObjectiveTracker
}

function S:SkinOjectiveTrackerHeader(header)
    if not header or not header.Text then
        return
    end

    if E.private and E.private.WT and E.private.WT.quest.objectiveTracker.enable then
        return
    end

    F.SetFontOutline(header.Text)
end

function S:ReskinBlock(_, block)
    for _, button in pairs {block.ItemButton, block.itemButton} do
        if button then
            if button.backdrop then
                self:CreateBackdropShadow(button)
            else
                self:CreateShadow(button)
            end
        end
    end

    if block.AddRightEdgeFrame then
        hooksecurefunc(
            block,
            "AddRightEdgeFrame",
            function(self)
                local frame = self.rightEdgeFrame
                if frame and frame.used then
                    if frame.template == "QuestObjectiveFindGroupButtonTemplate" and not frame.__windSkin then
                        frame:GetNormalTexture():SetAlpha(0)
                        frame:GetPushedTexture():SetAlpha(0)
                        frame:GetHighlightTexture():SetAlpha(0)
                        S:ESProxy("HandleButton", frame, nil, nil, nil, true)
                        frame.backdrop:SetInside(frame, 4, 4)
                        S:CreateBackdropShadow(frame)
                        frame.__windSkin = true
                    end
                end
            end
        )
    end
end

function S:SkinProgressBar(tracker, key)
    local progressBar = tracker.usedProgressBars[key]
    if not progressBar or not progressBar.Bar or progressBar.__windSkin then
        return
    end

    self:CreateBackdropShadow(progressBar.Bar)

    if progressBar.Bar.Icon then
        self:CreateBackdropShadow(progressBar.Bar.Icon)
    end

    -- move text to center
    if progressBar.Bar.Label then
        progressBar.Bar.Label:ClearAllPoints()
        progressBar.Bar.Label:Point("CENTER", progressBar.Bar, 0, 0)
        F.SetFontOutline(progressBar.Bar.Label)
    end

    -- change font style of header
    if not E.private.WT.quest.objectiveTracker.menuTitle.enable then
        F.SetFontOutline(_G.ObjectiveTrackerFrame.HeaderMenu.Title)
    end

    progressBar.__windSkin = true
end

function S:SkinTimerBar(tracker, key)
    local timerBar = tracker.usedTimerBars[key]
    self:CreateBackdropShadow(timerBar and timerBar.Bar)
end

function S:Blizzard_ObjectiveTracker()
    if not self:CheckDB("objectiveTracker") then
        return
    end

    local MainHeader = _G.ObjectiveTrackerFrame.Header
    self:SkinOjectiveTrackerHeader(MainHeader)

    for _, tracker in pairs(trackers) do
        self:SkinOjectiveTrackerHeader(tracker.Header)

        for _, block in pairs(tracker.usedBlocks or {}) do
            self:ReskinBlock(tracker, block)
        end

        self:SecureHook(tracker, "AddBlock", "ReskinBlock")
        self:SecureHook(tracker, "GetProgressBar", "SkinProgressBar")
        self:SecureHook(tracker, "GetTimerBar", "SkinTimerBar")
    end
end

S:AddCallback("Blizzard_ObjectiveTracker")
