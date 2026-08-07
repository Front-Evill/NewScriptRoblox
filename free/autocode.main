local Codes = {
    "1LOSTADMIN",
    "ADMINFIGHT",
    "GIFTING_HOURS",
    "NOMOREHACK",
    "BANEXPLOIT",
    "EARN_FRUITS",
    "FIGHT4FRUIT",
    "NOEXPLOITER",
    "KITT_RESET",
    "SUB2GAMERROBOT_EXP1",
    "SUB2GAMERROBOT_RESET1",
    "SUB2UNCLEKIZARU",
    "SUB2FER999",
    "SUB2DAIGROCK",
    "AXIORE",
    "TANTAIGAMING",
    "STRAWHATMAINE",
    "BLUXXY",
    "THEGREATACE",
    "FUDD10",
    "FUDD10_V2",
    "BIGNEWS",
    "JCWK",
    "KITTGAMING",
    "ENYU_IS_PRO",
    "MAGICBUS",
    "STARCODEHEO",
    "CHANDLER",
}
for _, code in ipairs(Codes) do
    local success, result = pcall(function()
        return game:GetService("ReplicatedStorage").Remotes.Redeem:InvokeServer(code)
    end)
    print(code, success, result)
    task.wait(0.2)
end
