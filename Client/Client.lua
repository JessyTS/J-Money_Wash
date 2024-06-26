local jessy = true
local open, transform_load, transform_lvl = false, nil, 0.0
local Wash__menu = RageUI.CreateMenu("J-Money", "INTERACTION")
Wash__menu.Display.Header = true
Wash__menu.Closed = function()
    open = false
    jessy = true
    transform_lvl = 0.0
    transform_load = false
    FreezeEntityPosition(PlayerPedId(), false)
end

function Wash_menu(money)
    if open then
        open = false
        RageUI.Visible(Wash__menu, false)
        return
    else
        open = true
        RageUI.Visible(Wash__menu, true)
        CreateThread(function()
            while open do

                RageUI.IsVisible(Wash__menu, function()

                    RageUI.Separator('Blanchiement')

                    if money > 1000 then
                        RageUI.Button('Blanchir', '', {RightLabel = "→"}, true, {
                            onSelected = function()
                                transform_load = true
                                jessy = false
                                TriggerServerEvent('Jessy:Wash:Remove')
                                Wash__menu.Closable = false
                            end
                        })
                    else
                        RageUI.Button('Blanchir', 'Il vous faut au moins 1000 $ (sale) pour blanchir', {RightLabel = "→"}, false, {
                            onSelected = function()
                            end
                        })
                    end

                    RageUI.Separator('Vous avez sur vous : '..money..' $ (sale)')

                    if transform_load == true then
                        RageUI.PercentagePanel(transform_lvl or 0.0, 'Blanchiement en cours'.." (~b~"..math.floor(transform_lvl * 100)..'~s~'.." %)", "", "",  function(Hovered, Active, Percent)
                            if transform_lvl < 1.0 then
                                transform_lvl = transform_lvl + 0.003
                            else
                                transform_load = false
                                TriggerServerEvent('Jessy:Wash:Add', money, ESX.PlayerData.job.name, GetPlayerServerId(PlayerId()))
                                money = 0
                                Wash__menu.Closable = true
                            end
                        end)
                    end

                    RageUI.Line()

                end)
            Wait(0)
            end
        end)
    end
end

Citizen.CreateThread(function()
    while true do
        for _,v in pairs(TS_Blanchiement.Pos_Blanchiement) do
            if TS_Blanchiement.Blanchiement then
                local playerPed = PlayerPedId()
                local lieu = vector3(v.Pos.x, v.Pos.y, v.Pos.z)
                local plyCoords3 = GetEntityCoords(GetPlayerPed(-1), false)
                local dist3 = Vdist(plyCoords3.x, plyCoords3.y, plyCoords3.z, lieu)
                if dist3 <= TS_Blanchiement.Marker_Distance then
                    if jessy then
                        DrawMarker(TS_Blanchiement.MarkerType, lieu, 0.0, 0.0, 0.0, 0.0,0.0,0.0, TS_Blanchiement.MarkerSizeLargeur, TS_Blanchiement.MarkerSizeEpaisseur, TS_Blanchiement.MarkerSizeHauteur, TS_Blanchiement.MarkerColorR, TS_Blanchiement.MarkerColorG, TS_Blanchiement.MarkerColorB, TS_Blanchiement.MarkerOpacite, TS_Blanchiement.MarkerSaute, true, p19, TS_Blanchiement.MarkerTourne)
                    end
                    if dist3 <= TS_Blanchiement.Interact_Distance then
                        if not IsPedInAnyVehicle(playerPed, true) then
                            if jessy then
                                ESX.ShowHelpNotification(TS_Blanchiement.Text_Interact)
                            end
                            if IsControlJustPressed(1, 51) then
                                if jessy then
                                    FreezeEntityPosition(PlayerPedId(), true)
                                    ESX.TriggerServerCallback('JessyTS:Wash:GetMoney', function(money)
                                        Wash_menu(money)
                                    end)
                                    jessy = false
                                    Wait(1000)
                                    jessy = true
                                end
                            end
                        end
                    end
                end
            end
        end
        Citizen.Wait(1)
    end
end)