local board
local clock
local timer
local housesBag
local hotelsBag

local lastRoll
local lastMove

function onLoad(save_state)


  initializePlayerData()
  initializeBoardPoints()
  nextTurn({"Black"})
  Wait.time(function()
      for i = 1, 8 do
          if playerData[i].SortBusy > 0 then
              if zoneStill(i) then
                  playerData[i].SortBusy = playerData[i].SortBusy - 1
              end
          end
      end
  end, 0.1, -1)

  local dayMessage = 'Behrad to Diooney?'
  if getObjectFromGUID('b00ef8')~=nil then
      getObjectFromGUID('b00ef8').setValue(dayMessage)
  else
      print(dayMessage)
  end
  clock = getObjectFromGUID('d33f7e')
  clock.Clock.startStopwatch()
  clock.interactable = false
  timer = getObjectFromGUID('3765ea')

  housesBag = getObjectFromGUID('834836')
  hotelsBag = getObjectFromGUID('505113')

  board = getObjectFromGUID('d52685')
  board.createButton({
      function_owner = nil, click_function='shuffleCards', label='Shuffle Cards',
      position = {7.5,0,10.5}, width = 1500, height = 400, font_size = 250
  })

  if save_state~=nil and save_state~='' then
      local load_data = JSON.decode(save_state)

      for i=1,8 do
          playerData[i].Token = getObjectFromGUID(load_data.token_GUIDs[i])
          playerData[i].TurnInJail = load_data.turnInJail[i]
      end
      cardsShuffled = load_data.cardsShuffled
      lastRoll = load_data.lastRoll
      lastMove = load_data.lastMove
  end

end

function onSave()
    local token_GUIDs = {}
    local turnInJail = {}
    for i=1,8 do
        token_GUIDs[i] = playerData[i].Token~=nil and playerData[i].Token.getGUID() or nil
        turnInJail[i] = playerData[i].TurnInJail
    end
    local save_data = {
        cardsShuffled = cardsShuffled,
        token_GUIDs = token_GUIDs,
        turnInJail = turnInJail,
        lastRoll = lastRoll,
        lastMove = lastMove
    }
    return JSON.encode(save_data)
end

function zoneStill(i)
    for j, v in ipairs(playerData[i].WalletZone.getObjects()) do
        if (v.tag == "Card" or v.tag == "Deck") and (v.spawning or not v.resting) then
            return false
        end
    end
    return true
end

local tick = 0

function update()
    updateWallets()
    retrieveDice()
    for i=1,8 do
    if playerData[i].RollTimeout>0 then playerData[i].RollTimeout=playerData[i].RollTimeout-1 end
    end
    if clock.getValue() ~= tick then
        onTick()
        tick = clock.getValue()
    end
    checkHouses()
end

function onTick()
    for i=1,8 do
        if playerData[i].RollTimeoutSeconds ~= 0 then
          playerData[i].RollTimeoutSeconds = playerData[i].RollTimeoutSeconds-1
        end
    end
end

function updateLRLM()
    getObjectFromGUID('8c1270').setValue("Last roll="..(lastRoll~=nil and lastRoll or "None").."\nLast move="..(lastMove~=nil and lastMove or "None"))
end

function checkHouses()
    local objects = housesBag.getObjects()
    for i=1,#objects do
        if objects[i].description~='House' then
            if objects[i].description=='Hotel' then
                local takenObject = housesBag.takeObject({guid = objects[i].guid, position = {40,-1,40}})
                Wait.frames(function()
                    hotelsBag.putObject(takenObject)
                end, 1)
            else
                housesBag.takeObject({guid = objects[i].guid, position = {0,2,0}})
            end
        end
    end
    local objects = hotelsBag.getObjects()
    for i=1,#objects do
        if objects[i].description~='Hotel' then
            if objects[i].description=='House' then
                local takenObject = hotelsBag.takeObject({guid = objects[i].guid, position = {40,-1,40}})
                Wait.frames(function()
                    housesBag.putObject(takenObject)
                end, 1)
            else
                hotelsBag.takeObject({guid = objects[i].guid, position = {0,2,0}})
            end
        end
    end

end


function shuffleCards()
    if not cardsShuffled then
        --Community Chest
        getObjectFromGUID('ef1c67').shuffle()
        --Chance
        getObjectFromGUID('15d990').shuffle()
        Wait.frames(function()
          cardsShuffled = false
        end, 10)
    end
end

local bagJSON = '{\n  "Name": "Bag",\n  "Transform": {\n    "posX": 0.239887953,\n    "posY": 0.774966359,\n    "posZ": -0.554694235,\n    "rotX": 1.41859493E-06,\n    "rotY": 346.89502,\n    "rotZ": -2.124479E-05,\n    "scaleX": 0.01,\n    "scaleY": 0.01,\n    "scaleZ": 0.01\n  },\n  "Nickname": "",\n  "Description": "",\n  "ColorDiffuse": {\n    "r": 0.7058823,\n    "g": 0.366520882,\n    "b": 0.0\n  },\n  "Locked": true,\n  "Grid": true,\n  "Snap": true,\n  "Autoraise": true,\n  "Sticky": true,\n  "Tooltip": true,\n  "GridProjection": false,\n  "HideWhenFaceDown": false,\n  "Hands": false,\n  "MaterialIndex": -1,\n  "MeshIndex": -1,\n  "XmlUI": "",\n  "ContainedObjects": [],\n  "GUID": "6a6e9b"\n}'

local cardJSONs = {
    [1] = [=[{
      "Name": "Card",
      "Transform": {
        "posX": 0,
        "posY": -5,
        "posZ": 0,
        "rotX": 2.79154968,
        "rotY": 179.935516,
        "rotZ": 359.876465,
        "scaleX": 1.0,
        "scaleY": 1.0,
        "scaleZ": 1.0
      },
      "Nickname": "",
      "Description": "1",
      "ColorDiffuse": {
        "r": 0.713235259,
        "g": 0.713235259,
        "b": 0.713235259
      },
      "Locked": false,
      "Grid": true,
      "Snap": true,
      "IgnoreFoW": false,
      "Autoraise": true,
      "Sticky": true,
      "Tooltip": true,
      "GridProjection": false,
      "HideWhenFaceDown": false,
      "Hands": true,
      "CardID": 200,
      "SidewaysCard": true,
      "CustomDeck": {
        "2": {
          "FaceURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "BackURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "NumWidth": 4,
          "NumHeight": 2,
          "BackIsHidden": false,
          "UniqueBack": true
        }
      },
      "XmlUI": "",
      "LuaScript": "",
      "LuaScriptState": "",
      "PhysicsMaterial": {
        "StaticFriction": 0.2,
        "DynamicFriction": 0.2,
        "Bounciness": 0.0,
        "FrictionCombine": 0,
        "BounceCombine": 0
      },
      "Rigidbody": {
        "Mass": 0.5,
        "Drag": 0.1,
        "AngularDrag": 0.1,
        "UseGravity": true
      },
      "GUID": "5b36a5"
  }]=],
    [5] = [=[{
      "Name": "Card",
      "Transform": {
        "posX": 0,
        "posY": -5,
        "posZ": 0,
        "rotX": 2.8666327,
        "rotY": 180.013824,
        "rotZ": 359.87616,
        "scaleX": 1.0,
        "scaleY": 1.0,
        "scaleZ": 1.0
      },
      "Nickname": "",
      "Description": "5",
      "ColorDiffuse": {
        "r": 0.713235259,
        "g": 0.713235259,
        "b": 0.713235259
      },
      "Locked": false,
      "Grid": true,
      "Snap": true,
      "IgnoreFoW": false,
      "Autoraise": true,
      "Sticky": true,
      "Tooltip": true,
      "GridProjection": false,
      "HideWhenFaceDown": false,
      "Hands": true,
      "CardID": 201,
      "SidewaysCard": true,
      "CustomDeck": {
        "2": {
          "FaceURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "BackURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "NumWidth": 4,
          "NumHeight": 2,
          "BackIsHidden": false,
          "UniqueBack": true
        }
      },
      "XmlUI": "",
      "LuaScript": "",
      "LuaScriptState": "",
      "PhysicsMaterial": {
        "StaticFriction": 0.2,
        "DynamicFriction": 0.2,
        "Bounciness": 0.0,
        "FrictionCombine": 0,
        "BounceCombine": 0
      },
      "Rigidbody": {
        "Mass": 0.5,
        "Drag": 0.1,
        "AngularDrag": 0.1,
        "UseGravity": true
      },
      "GUID": "b917a7"
  }]=],
    [10] = [=[{
      "Name": "Card",
      "Transform": {
        "posX": 0,
        "posY": -5,
        "posZ": 0,
        "rotX": 2.867191,
        "rotY": 180.013626,
        "rotZ": 359.8766,
        "scaleX": 1.0,
        "scaleY": 1.0,
        "scaleZ": 1.0
      },
      "Nickname": "",
      "Description": "10",
      "ColorDiffuse": {
        "r": 0.713235259,
        "g": 0.713235259,
        "b": 0.713235259
      },
      "Locked": false,
      "Grid": true,
      "Snap": true,
      "IgnoreFoW": false,
      "Autoraise": true,
      "Sticky": true,
      "Tooltip": true,
      "GridProjection": false,
      "HideWhenFaceDown": false,
      "Hands": true,
      "CardID": 202,
      "SidewaysCard": true,
      "CustomDeck": {
        "2": {
          "FaceURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "BackURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "NumWidth": 4,
          "NumHeight": 2,
          "BackIsHidden": false,
          "UniqueBack": true
        }
      },
      "XmlUI": "",
      "LuaScript": "",
      "LuaScriptState": "",
      "PhysicsMaterial": {
        "StaticFriction": 0.2,
        "DynamicFriction": 0.2,
        "Bounciness": 0.0,
        "FrictionCombine": 0,
        "BounceCombine": 0
      },
      "Rigidbody": {
        "Mass": 0.5,
        "Drag": 0.1,
        "AngularDrag": 0.1,
        "UseGravity": true
      },
      "GUID": "02bdc0"
  }]=],
    [20] = [=[{
      "Name": "Card",
      "Transform": {
        "posX": 0,
        "posY": -5,
        "posZ": 0,
        "rotX": 2.96412778,
        "rotY": 180.014664,
        "rotZ": 359.876678,
        "scaleX": 1.0,
        "scaleY": 1.0,
        "scaleZ": 1.0
      },
      "Nickname": "",
      "Description": "20",
      "ColorDiffuse": {
        "r": 0.713235259,
        "g": 0.713235259,
        "b": 0.713235259
      },
      "Locked": false,
      "Grid": true,
      "Snap": true,
      "IgnoreFoW": false,
      "Autoraise": true,
      "Sticky": true,
      "Tooltip": true,
      "GridProjection": false,
      "HideWhenFaceDown": false,
      "Hands": true,
      "CardID": 203,
      "SidewaysCard": true,
      "CustomDeck": {
        "2": {
          "FaceURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "BackURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "NumWidth": 4,
          "NumHeight": 2,
          "BackIsHidden": false,
          "UniqueBack": true
        }
      },
      "XmlUI": "",
      "LuaScript": "",
      "LuaScriptState": "",
      "PhysicsMaterial": {
        "StaticFriction": 0.2,
        "DynamicFriction": 0.2,
        "Bounciness": 0.0,
        "FrictionCombine": 0,
        "BounceCombine": 0
      },
      "Rigidbody": {
        "Mass": 0.5,
        "Drag": 0.1,
        "AngularDrag": 0.1,
        "UseGravity": true
      },
      "GUID": "840624"
  }]=],
    [50] = [=[{
      "Name": "Card",
      "Transform": {
        "posX": 0,
        "posY": -5,
        "posZ": 0,
        "rotX": 3.11859584,
        "rotY": 180.014648,
        "rotZ": 359.876678,
        "scaleX": 1.0,
        "scaleY": 1.0,
        "scaleZ": 1.0
      },
      "Nickname": "",
      "Description": "50",
      "ColorDiffuse": {
        "r": 0.713235259,
        "g": 0.713235259,
        "b": 0.713235259
      },
      "Locked": false,
      "Grid": true,
      "Snap": true,
      "IgnoreFoW": false,
      "Autoraise": true,
      "Sticky": true,
      "Tooltip": true,
      "GridProjection": false,
      "HideWhenFaceDown": false,
      "Hands": true,
      "CardID": 204,
      "SidewaysCard": true,
      "CustomDeck": {
        "2": {
          "FaceURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "BackURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "NumWidth": 4,
          "NumHeight": 2,
          "BackIsHidden": false,
          "UniqueBack": true
        }
      },
      "XmlUI": "",
      "LuaScript": "",
      "LuaScriptState": "",
      "PhysicsMaterial": {
        "StaticFriction": 0.2,
        "DynamicFriction": 0.2,
        "Bounciness": 0.0,
        "FrictionCombine": 0,
        "BounceCombine": 0
      },
      "Rigidbody": {
        "Mass": 0.5,
        "Drag": 0.1,
        "AngularDrag": 0.1,
        "UseGravity": true
      },
      "GUID": "533560"
  }]=],
    [100] = [=[{
      "Name": "Card",
      "Transform": {
        "posX": 0,
        "posY": -5,
        "posZ": 0,
        "rotX": 3.11713481,
        "rotY": 180.013611,
        "rotZ": 359.877,
        "scaleX": 1.0,
        "scaleY": 1.0,
        "scaleZ": 1.0
      },
      "Nickname": "",
      "Description": "100",
      "ColorDiffuse": {
        "r": 0.713235259,
        "g": 0.713235259,
        "b": 0.713235259
      },
      "Locked": false,
      "Grid": true,
      "Snap": true,
      "IgnoreFoW": false,
      "Autoraise": true,
      "Sticky": true,
      "Tooltip": true,
      "GridProjection": false,
      "HideWhenFaceDown": false,
      "Hands": true,
      "CardID": 205,
      "SidewaysCard": true,
      "CustomDeck": {
        "2": {
          "FaceURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "BackURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "NumWidth": 4,
          "NumHeight": 2,
          "BackIsHidden": false,
          "UniqueBack": true
        }
      },
      "XmlUI": "",
      "LuaScript": "",
      "LuaScriptState": "",
      "PhysicsMaterial": {
        "StaticFriction": 0.2,
        "DynamicFriction": 0.2,
        "Bounciness": 0.0,
        "FrictionCombine": 0,
        "BounceCombine": 0
      },
      "Rigidbody": {
        "Mass": 0.5,
        "Drag": 0.1,
        "AngularDrag": 0.1,
        "UseGravity": true
      },
      "GUID": "b6a66b"
  }]=],
    [500] = [=[{
      "Name": "Card",
      "Transform": {
        "posX": 0,
        "posY": -5,
        "posZ": 0,
        "rotX": 3.11777544,
        "rotY": 180.002518,
        "rotZ": 359.876923,
        "scaleX": 1.0,
        "scaleY": 1.0,
        "scaleZ": 1.0
      },
      "Nickname": "",
      "Description": "500",
      "ColorDiffuse": {
        "r": 0.713235259,
        "g": 0.713235259,
        "b": 0.713235259
      },
      "Locked": false,
      "Grid": true,
      "Snap": true,
      "IgnoreFoW": false,
      "Autoraise": true,
      "Sticky": true,
      "Tooltip": true,
      "GridProjection": false,
      "HideWhenFaceDown": false,
      "Hands": true,
      "CardID": 206,
      "SidewaysCard": true,
      "CustomDeck": {
        "2": {
          "FaceURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "BackURL": "http://cloud-3.steamusercontent.com/ugc/93848290826538623/9EF4F0AF142FC009C158188C3E545C3FC69068B5/",
          "NumWidth": 4,
          "NumHeight": 2,
          "BackIsHidden": false,
          "UniqueBack": true
        }
      },
      "XmlUI": "",
      "LuaScript": "",
      "LuaScriptState": "",
      "PhysicsMaterial": {
        "StaticFriction": 0.2,
        "DynamicFriction": 0.2,
        "Bounciness": 0.0,
        "FrictionCombine": 0,
        "BounceCombine": 0
      },
      "Rigidbody": {
        "Mass": 0.5,
        "Drag": 0.1,
        "AngularDrag": 0.1,
        "UseGravity": true
      },
      "GUID": "d57fc8"
  }]=],
}

local billValues = {1, 5, 10, 20, 50, 100, 500}
local getChangeCounts = {5, 5, 5, 6, 2, 2, 2}

colorToNum = {
    ["white"]   = 1,
    ["red"]     = 2,
    ["orange"]  = 3,
    ["yellow"]  = 4,
    ["green"]   = 5,
    ["blue"]    = 6,
    ["purple"]  = 7,
    ["pink"]    = 8,

}

local luxuryTax = 75

local bankBagsGUID = {
    [1]   = "014990",
    [5]   = "550845",
    [10]  = "b4022f",
    [20]  = "9ccaab",
    [50]  = "356266",
    [100] = "8d4d8b",
    [500] = "762abf"
}

local whiteSortPositions = {
    ["1"]   = { 3.00, 0.5, -40.00},
    ["5"]   = { 5.00, 0.5, -40.00},
    ["10"]  = { 7.00, 0.5, -40.00},
    ["20"]  = { 9.00, 0.5, -40.00},
    ["50"]  = {11.00, 0.5, -40.00},
    ["100"] = {13.00, 0.5, -40.00},
    ["500"] = {15.00, 0.5, -40.00},

    ["Dark"]                          = { 4, 0.5, -44},
    ["Zeynabie"]                      = { 4, 0.5, -47},

    ["Kohandej"]                      = { 7, 0.5, -44},
    ["Marchin"]                       = { 7, 0.5, -47},
    ["Joozdan"]                       = { 7, 0.5, -50},

    ["Tokhchi"]                       = {10, 0.5, -44},
    ["Asgarie"]                       = {10, 0.5, -47},
    ["Kaveh"]                         = {10, 0.5, -50},

    ["Ahmad Abad"]                    = {13, 0.5, -44},
    ["Jeyshir"]                       = {13, 0.5, -47},
    ["Takhti"]                        = {13, 0.5, -50},

    ["Hosein Abad"]                   = {16, 0.5, -44},
    ["Vahid"]                         = {16, 0.5, -47},
    ["Sepahan Shahr"]                 = {16, 0.5, -50},

    ["Hakim Nezami"]                  = {19, 0.5, -44},
    ["Bagh Daryache"]                 = {19, 0.5, -47},
    ["Moshtagh"]                      = {19, 0.5, -50},

    ["Tohid"]                         = {22, 0.5, -44},
    ["Chahar Bagh"]                   = {22, 0.5, -47},
    ["Mardavij"]                      = {22, 0.5, -50},

    ["Abas Abad"]                     = {25, 0.5, -44},
    ["Mehr Abad"]                     = {25, 0.5, -47},


    ["Halal Khorie Hajie"]            = {28, 0.5, -44},
    ["Mey Khane Ashkan"]              = {31, 0.5, -44},
    ["Amoozesh Gahe Khaste"]          = {28, 0.5, -47},
    ["Elektriky Dorvash"]             = {31, 0.5, -47},

    ["Karkhane Feshare Jafari"]       = {34, 0.5, -44},
    ["Mojasame Sazi Malekpour"]       = {34, 0.5, -47},

    ["Miscellaneous"]                 = {20, 0.5, -40},
}

local propertyPrices = {
    ["Dark"]                     = 60,
    ["Zeynabie"]                 = 60,

    ["Kohandej"]                 = 100,
    ["Marchin"]                  = 100,
    ["Joozdan"]                  = 120,

    ["Tokhchi"]                  = 140,
    ["Asgarie"]                  = 140,
    ["Kaveh"]                    = 160,

    ["Ahmad Abad"]               = 180,
    ["Jeyshir"]                  = 180,
    ["Takhti"]                   = 200,

    ["Hosein Abad"]              = 220,
    ["Vahid"]                    = 220,
    ["Sepahan Shahr"]            = 240,

    ["Hakim Nezami"]             = 260,
    ["Bagh Daryache"]            = 260,
    ["Moshtagh"]                 = 280,

    ["Tohid"]                    = 300,
    ["Chahar Bagh"]              = 300,
    ["Mardavij"]                 = 320,


    ["Abas Abad"]                = 350,
    ["Mehr Abad"]                = 400,


    ["Halal Khorie Hajie"]       = 200,
    ["Mey Khane Ashkan"]         = 200,
    ["Amoozesh Gahe Khaste"]     = 200,
    ["Elektriky Dorvash"]        = 200,

    ["Karkhane Feshare Jafari"]  = 150,
    ["Mojasame Sazi Malekpour"]  = 150,
}

local propertyRentPrices = {
    ["Dark"]    = { 2,  10,  30,   90,  160,  250},
    ["Zeynabie"]           = { 4,  20,  60,  180,  320,  450},

    ["Kohandej"]         = { 6,  30,  90,  270,  400,  550},
    ["Marchin"]          = { 6,  30,  90,  270,  400,  550},
    ["Joozdan"]      = { 8,  40, 100,  300,  450,  600},

    ["Tokhchi"]       = {10,  50, 150,  450,  625,  750},
    ["Asgarie"]           = {10,  50, 150,  450,  625,  750},
    ["Kaveh"]         = {12,  60, 180,  500,  700,  900},

    ["Ahmad Abad"]         = {14,  70, 200,  550,  750,  950},
    ["Jeyshir"]        = {14,  70, 200,  550,  750,  950},
    ["Takhti"]         = {16,  80, 220,  600,  800, 1000},

    ["Hosein Abad"]         = {18,  90, 250,  700,  875, 1050},
    ["Vahid"]          = {18,  90, 250,  700,  875, 1050},
    ["Sepahan Shahr"]         = {20, 100, 300,  750,  925, 1100},

    ["Hakim Nezami"]         = {22, 110, 330,  800,  975, 1150},
    ["Bagh Daryache"]          = {22, 110, 330,  800,  975, 1150},
    ["Moshtagh"]          = {24, 120, 360,  850, 1025, 1200},

    ["Tohid"]          = {26, 130, 390,  900, 1100, 1275},
    ["Chahar Bagh"]   = {26, 130, 390,  900, 1100, 1275},
    ["Mardavij"]     = {28, 150, 450, 1000, 1200, 1400},

    ["Abas Abad"]              = {35, 175, 500, 1100, 1300, 1500},
    ["Mehr Abad"]               = {50, 200, 600, 1400, 1700, 2000},

    ["Halal Khorie Hajie"]            = {25, 50, 100, 200},
    ["Mey Khane Ashkan"]              = {25, 50, 100, 200},
    ["Amoozesh Gahe Khaste"]        = {25, 50, 100, 200},
    ["Elektriky Dorvash"]   = {25, 50, 100, 200},

    ["Karkhane Feshare Jafari"] = 0, -- 4 or 10 * dice
    ["Mojasame Sazi Malekpour"] = 0,      -- 4 or 10 * dice
}
local propertyNameToColor = {
    ["Dark"]    = "Brown",
    ["Zeynabie"]           = "Brown",

    ["Kohandej"]         = "White-Blue",
    ["Marchin"]          = "White-Blue",
    ["Joozdan"]      = "White-Blue",

    ["Tokhchi"]       = "Pink",
    ["Asgarie"]           = "Pink",
    ["Kaveh"]         = "Pink",

    ["Ahmad Abad"]         = "Orange",
    ["Jeyshir"]        = "Orange",
    ["Takhti"]         = "Orange",

    ["Hosein Abad"]         = "Red",
    ["Vahid"]          = "Red",
    ["Sepahan Shahr"]         = "Red",

    ["Hakim Nezami"]         = "Yellow",
    ["Bagh Daryache"]          = "Yellow",
    ["Moshtagh"]          = "Yellow",

    ["Tohid"]          = "Green",
    ["Chahar Bagh"]   = "Green",
    ["Mardavij"]     = "Green",

    ["Abas Abad"]              = "Dark-Blue",
    ["Mehr Abad"]               = "Dark-Blue",

    ["Halal Khorie Hajie"]            = "Railroad",
    ["Mey Khane Ashkan"]              = "Railroad",
    ["Amoozesh Gahe Khaste"]        = "Railroad",
    ["Elektriky Dorvash"]   = "Railroad",

    ["Karkhane Feshare Jafari"]        = "Utility",
    ["Mojasame Sazi Malekpour"]             = "Utility"
}

local housePrice = {
    ["Dark"]    = 50,
    ["Zeynabie"]           = 50,
    ["Kohandej"]         = 50,
    ["Marchin"]          = 50,
    ["Joozdan"]      = 50,

    ["Tokhchi"]       = 100,
    ["Asgarie"]           = 100,
    ["Kaveh"]         = 100,
    ["Ahmad Abad"]         = 100,
    ["Jeyshir"]        = 100,
    ["Takhti"]         = 100,

    ["Hosein Abad"]         = 150,
    ["Vahid"]          = 150,
    ["Sepahan Shahr"]         = 150,
    ["Hakim Nezami"]         = 150,
    ["Bagh Daryache"]          = 150,
    ["Moshtagh"]          = 150,

    ["Tohid"]          = 200,
    ["Chahar Bagh"]   = 200,
    ["Mardavij"]     = 200,
    ["Abas Abad"]              = 200,
    ["Mehr Abad"]               = 200
}

playerData = {nil}
function initializePlayerData()
  playerData[1] = {
    Color="White"
    ,Token=nil
    ,LastSquare=nil
    ,ClaimTokenZone=getObjectFromGUID('761a31')
    ,ButtonChip=getObjectFromGUID('d3075d')
    ,TokenInitialPosition={15,2.2,-16}
    ,WalletZoneObjectCount = 0
    ,WalletZone=getObjectFromGUID('539e70')
    ,WalletCounter=getObjectFromGUID('a0b05d')
    ,Die1=getObjectFromGUID('30c53f')
    ,Die2=getObjectFromGUID('e6440b')
    ,Die1Position={10,1.64,-34}
    ,Die2Position={10,1.64,-36}
    ,RollTimeout=0
    ,RollTimeoutSeconds=0
    ,TurnInJail=0
    ,Die1Resting=true
    ,Die2Resting=true
    ,SortPositions = {}
    ,SortBusy = 0
  }
	playerData[2] = {
    Color="Red"
    ,Token=nil
    ,LastSquare=nil
    ,ClaimTokenZone=getObjectFromGUID('8ee3ba')
    ,ButtonChip=getObjectFromGUID('4331c6')
    ,TokenInitialPosition={13,2.2,-16}
    ,WalletZoneObjectCount = 0
    ,WalletZone=getObjectFromGUID('1ca32e')
    ,WalletCounter=getObjectFromGUID('21722e')
    ,Die1=getObjectFromGUID('a9ed8a')
    ,Die2=getObjectFromGUID('0a55f5')
    ,Die1Position={-10,1.64,-34}
    ,Die2Position={-10,1.64,-36}
    ,RollTimeout=0
    ,RollTimeoutSeconds=0
    ,TurnInJail=0
    ,Die1Resting=true
    ,Die2Resting=true
    ,SortPositions = {}
    ,SortBusy = 0
  }
  playerData[3] = {
    Color="Orange"
    ,Token=nil
    ,LastSquare=nil
    ,ClaimTokenZone=getObjectFromGUID('b47a92')
    ,ButtonChip=getObjectFromGUID('bbdee4')
    ,TokenInitialPosition={14,2.2,-15}
    ,WalletZoneObjectCount = 0
    ,WalletZone=getObjectFromGUID('c81e71')
    ,WalletCounter=getObjectFromGUID('31d15f')
    ,Die1=getObjectFromGUID('ce3ddc')
    ,Die2=getObjectFromGUID('b05623')
    ,Die1Position={-34,1.64,-10}
    ,Die2Position={-36,1.64,-10}
    ,RollTimeout=0
    ,RollTimeoutSeconds=0
    ,TurnInJail=0
    ,Die1Resting=true
    ,Die2Resting=true
    ,SortPositions = {}
    ,SortBusy = 0
  }
  playerData[4] = {
    Color="Yellow"
    ,Token=nil
    ,LastSquare=nil
    ,ClaimTokenZone=getObjectFromGUID('9210ac')
    ,ButtonChip=getObjectFromGUID('aaa099')
    ,TokenInitialPosition={13,2.2,-14}
    ,WalletZoneObjectCount = 0
    ,WalletZone=getObjectFromGUID('fb0a0e')
    ,WalletCounter=getObjectFromGUID('520c81')
    ,Die1=getObjectFromGUID('12b90d')
    ,Die2=getObjectFromGUID('c87ec1')
    ,Die1Position={-34,1.64,10}
    ,Die2Position={-36,1.64,10}
    ,RollTimeout=0
    ,RollTimeoutSeconds=0
    ,TurnInJail=0
    ,Die1Resting=true
    ,Die2Resting=true
    ,SortPositions = {}
    ,SortBusy = 0
  }
	playerData[5] = {
    Color="Green"
    ,Token=nil
    ,LastSquare=nil
    ,ClaimTokenZone=getObjectFromGUID('aeb024')
    ,ButtonChip=getObjectFromGUID('620fe1')
    ,TokenInitialPosition={14,2.2,-13}
    ,WalletZoneObjectCount = 0
    ,WalletZone=getObjectFromGUID('a6c341')
    ,WalletCounter=getObjectFromGUID('a34c1a')
    ,Die1=getObjectFromGUID('cb9b65')
    ,Die2=getObjectFromGUID('1879c7')
    ,Die1Position={-10,1.64,34}
    ,Die2Position={-10,1.64,36}
    ,RollTimeout=0
    ,RollTimeoutSeconds=0
    ,TurnInJail=0
    ,Die1Resting=true
    ,Die2Resting=true
    ,SortPositions = {}
    ,SortBusy = 0
  }
	playerData[6] = {
    Color="Blue"
    ,Token=nil
    ,LastSquare=nil
    ,ClaimTokenZone=getObjectFromGUID('f6d27a')
    ,ButtonChip=getObjectFromGUID('df6646')
    ,TokenInitialPosition={16,2.2,-13}
    ,WalletZoneObjectCount = 0
    ,WalletZone=getObjectFromGUID('fbbdc0')
    ,WalletCounter=getObjectFromGUID('44e6b2')
    ,Die1=getObjectFromGUID('ad79c0')
    ,Die2=getObjectFromGUID('376617')
    ,Die1Position={10,1.64,34}
    ,Die2Position={10,1.64,36}
    ,RollTimeout=0
    ,RollTimeoutSeconds=0
    ,TurnInJail=0
    ,Die1Resting=true
    ,Die2Resting=true
    ,SortPositions = {}
    ,SortBusy = 0
  }
	playerData[7] = {
    Color="Purple"
    ,Token=nil
    ,LastSquare=nil
    ,ClaimTokenZone=getObjectFromGUID('9335dd')
    ,ButtonChip=getObjectFromGUID('0dc584')
    ,TokenInitialPosition={15,2.2,-14}
    ,WalletZoneObjectCount = 0
    ,WalletZone=getObjectFromGUID('48fdea')
    ,WalletCounter=getObjectFromGUID('de5fd3')
    ,Die1=getObjectFromGUID('3a57b0')
    ,Die2=getObjectFromGUID('37aebc')
    ,Die1Position={34,1.64,10}
    ,Die2Position={36,1.64,10}
    ,RollTimeout=0
    ,RollTimeoutSeconds=0
    ,TurnInJail=0
    ,Die1Resting=true
    ,Die2Resting=true
    ,SortPositions = {}
    ,SortBusy = 0
  }
	playerData[8] = {
    Color="Pink"
    ,Token=nil
    ,LastSquare=nil
    ,ClaimTokenZone=getObjectFromGUID('ce306f')
    ,ButtonChip=getObjectFromGUID('ba0e66')
    ,TokenInitialPosition={16,2.2,-15}
    ,WalletZoneObjectCount = 0
    ,WalletZone=getObjectFromGUID('1c29e4')
    ,WalletCounter=getObjectFromGUID('16aa98')
    ,Die1=getObjectFromGUID('054ea3')
    ,Die2=getObjectFromGUID('6e0d6f')
    ,Die1Position={34,1.64,-10}
    ,Die2Position={36,1.64,-10}
    ,RollTimeout=0
    ,RollTimeoutSeconds=0
    ,TurnInJail=0
    ,Die1Resting=true
    ,Die2Resting=true
    ,SortPositions = {}
    ,SortBusy = 0
  }
  playerData[9] = {
    Color="Black"
    ,Token=nil
    ,ClaimTokenZone=nil
    ,ButtonChip=nil
    ,WalletZoneObjectCount = 0
    ,WalletZone=getObjectFromGUID('0bba1e')
    ,WalletCounter=getObjectFromGUID('543fce')
    ,Die1=nil
    ,Die2=nil
    ,Die1Position={0,0,0}
    ,Die2Position={0,0,0}
    ,Die1Resting=true
    ,Die2Resting=true
  }

  for i = 1, 7, 2 do
      for j, v in pairs(whiteSortPositions) do
          playerData[i].SortPositions[j] = playerData[i].WalletCounter.positionToWorld(playerData[1].WalletCounter.positionToLocal(v))
      end
  end
  for i = 2, 8, 2 do
      for j, v in pairs(whiteSortPositions) do
          local localPosition = playerData[1].WalletCounter.positionToLocal(v)
          playerData[i].SortPositions[j] = playerData[i].WalletCounter.positionToWorld({
            -localPosition.x,
            localPosition.y,
            localPosition.z,
          })
      end
  end

  local parameters = {
      click_function='setToken', function_owner=nil, label='Claim Token',
      position={-2.5,0.2,0}, rotation={0,180,180}, width=1500, height=500, font_size=200
  }
  playerData[1].ButtonChip.createButton(parameters)
  playerData[2].ButtonChip.createButton(parameters)
  playerData[3].ButtonChip.createButton(parameters)
  playerData[4].ButtonChip.createButton(parameters)
  playerData[5].ButtonChip.createButton(parameters)
  playerData[6].ButtonChip.createButton(parameters)
  playerData[7].ButtonChip.createButton(parameters)
  playerData[8].ButtonChip.createButton(parameters)

  parameters = {
      click_function='rollDice', function_owner=nil, label='Roll',
      position={3,0.2,2}, rotation={0,180,180}, width=1400, height=1400, font_size=500
  }
  playerData[1].ButtonChip.createButton(parameters)
  playerData[3].ButtonChip.createButton(parameters)
  playerData[5].ButtonChip.createButton(parameters)
  playerData[7].ButtonChip.createButton(parameters)
  parameters = {
      click_function='rollDice', function_owner=nil, label='Roll',
      position={-6,0.2,2}, rotation={0,180,180}, width=1400, height=1400, font_size=500
  }
  playerData[2].ButtonChip.createButton(parameters)
  playerData[4].ButtonChip.createButton(parameters)
  playerData[6].ButtonChip.createButton(parameters)
  playerData[8].ButtonChip.createButton(parameters)

  parameters = {
      click_function='moveToken', function_owner=nil, label='Move',
      position={7.5,0.2,2}, rotation={0,180,180}, width=1000, height=900, font_size=350
  }
  playerData[1].ButtonChip.createButton(parameters)
  playerData[3].ButtonChip.createButton(parameters)
  playerData[5].ButtonChip.createButton(parameters)
  playerData[7].ButtonChip.createButton(parameters)
  parameters = {
      click_function='moveToken', function_owner=nil, label='Move',
      position={-10.5,0.2,2}, rotation={0,180,180}, width=1000, height=900, font_size=350
  }
  playerData[2].ButtonChip.createButton(parameters)
  playerData[4].ButtonChip.createButton(parameters)
  playerData[6].ButtonChip.createButton(parameters)
  playerData[8].ButtonChip.createButton(parameters)

  parameters = {
      click_function='sortWallet', function_owner=nil, label='Sort',
      position={10.5,0.2,2}, rotation={0,180,180}, width=1000, height=900, font_size=350
  }
  playerData[1].ButtonChip.createButton(parameters)
  playerData[3].ButtonChip.createButton(parameters)
  playerData[5].ButtonChip.createButton(parameters)
  playerData[7].ButtonChip.createButton(parameters)
  parameters = {
      click_function='sortWallet', function_owner=nil, label='Sort',
      position={-13.5,0.2,2}, rotation={0,180,180}, width=1000, height=900, font_size=350
  }
  playerData[2].ButtonChip.createButton(parameters)
  playerData[4].ButtonChip.createButton(parameters)
  playerData[6].ButtonChip.createButton(parameters)
  playerData[8].ButtonChip.createButton(parameters)

  parameters = {
      click_function='convertWallet', function_owner=nil, label='Convert',
      position={14,0.2,2}, rotation={0,180,180}, width=1300, height=900, font_size=350
  }
  playerData[1].ButtonChip.createButton(parameters)
  playerData[3].ButtonChip.createButton(parameters)
  playerData[5].ButtonChip.createButton(parameters)
  playerData[7].ButtonChip.createButton(parameters)
  parameters = {
      click_function='convertWallet', function_owner=nil, label='Convert',
      position={-17,0.2,2}, rotation={0,180,180}, width=1300, height=900, font_size=350
  }
  playerData[2].ButtonChip.createButton(parameters)
  playerData[4].ButtonChip.createButton(parameters)
  playerData[6].ButtonChip.createButton(parameters)
  playerData[8].ButtonChip.createButton(parameters)

  parameters = {
      click_function='buy', function_owner=nil, label='Buy',
      position={17,0.2,2}, rotation={0,180,180}, width=900, height=900, font_size=350
  }
  playerData[1].ButtonChip.createButton(parameters)
  playerData[3].ButtonChip.createButton(parameters)
  playerData[5].ButtonChip.createButton(parameters)
  playerData[7].ButtonChip.createButton(parameters)
  parameters = {
      click_function='buy', function_owner=nil, label='Buy',
      position={-20,0.2,2}, rotation={0,180,180}, width=900, height=900, font_size=350
  }
  playerData[2].ButtonChip.createButton(parameters)
  playerData[4].ButtonChip.createButton(parameters)
  playerData[6].ButtonChip.createButton(parameters)
  playerData[8].ButtonChip.createButton(parameters)
  parameters = {
      click_function='plusOneInJail', function_owner=nil, label='0',
      position={3,0.2,4.9}, rotation={0,180,180}, width=900, height=900, font_size=700,
      scale = {0,0,0}
  }
  playerData[1].ButtonChip.createButton(parameters)
  playerData[3].ButtonChip.createButton(parameters)
  playerData[5].ButtonChip.createButton(parameters)
  playerData[7].ButtonChip.createButton(parameters)
  parameters = {
      click_function='plusOneInJail', function_owner=nil, label='0',
      position={-6,0.2,4.9}, rotation={0,180,180}, width=900, height=900, font_size=700,
      scale = {0,0,0}
  }
  playerData[2].ButtonChip.createButton(parameters)
  playerData[4].ButtonChip.createButton(parameters)
  playerData[6].ButtonChip.createButton(parameters)
  playerData[8].ButtonChip.createButton(parameters)

  -- board.createButton({
  --     click_function='shuffleCards', function_owner=nil, label='Shuffle Cards',
  --     position={-6,0.2,4.9}, rotation={0,180,180}, width=900, height=900, font_size=700,
  -- })

  local housesList = {'1','2','3','4','5','6','7','8','9','10','11','12','1Ht','2Ht','3Ht'}

  for i=1,15 do
      getObjectFromGUID('834836').createButton({
          click_function='takeHouse'..i, function_owner=nil, label=housesList[i],
          position={-3.5+math.floor((i-1)/4)*-1.75,-1,5+1.75*((i-1)%4)}, rotation={0,90,0}, width=300, height=300, font_size=150,
          scale = {3,3,3}
      })
  end
end

-- Claiming Player's Tokens ---------------------------------------------
function setToken(theButton, theClicker)
    local playerNum = getPlayerNum(theButton)
    if playerNum == 0 then
        print('ERROR: Claim: How did you click this?')
        return
    end

    if playerData[playerNum].Color ~= theClicker and theClicker ~= "Black" then
        broadcastToColor("This is not yours", theClicker, {1,1,1})
        return
    end

    local newToken = nil

    local objectsList = playerData[playerNum].ClaimTokenZone.getObjects()
    if #objectsList < 2 then
        broadcastToColor("No Token in Zone", theClicker, {1,1,1})
        return
    else
        if #objectsList > 2 then
            broadcastToColor("Too many objects in Zone", theClicker, {1,1,1})
            return
        else
            local hasFoundButton = false
            for k, v in next, objectsList do
                    if v == theButton then
                        hasFoundButton = true
                    else
                        newToken = getObjectFromGUID(v.getGUID())
                    end
            end
            if hasFoundButton == false then
                broadcastToColor("Put the pedestal back", theClicker, {1,1,1})
                return
            end
        end
    end

    if newToken.getQuantity() ~= -1 then
        broadcastToColor("Please do not use a Bag or Deck", theClicker, {1,1,1})
        return
    end

    if newToken.getStatesCount() ~= -1 then
        broadcastToColor("Please remove States from this Object first", theClicker, {1,1,1})
        return
    end

    local cloneToken = newToken.clone()
    if playerData[playerNum].Token == nil then
        cloneToken.setPosition(playerData[playerNum].TokenInitialPosition)
        cloneToken.setRotation({0,0,0})
    else
        cloneToken.setPosition(playerData[playerNum].Token.getPosition())
        cloneToken.setRotation(playerData[playerNum].Token.getRotation())
        playerData[playerNum].Token.destruct()
    end

    cloneToken.drag = 0.1
    cloneToken.angular_drag = 0.1
    cloneToken.static_friction = 1
    cloneToken.dynamic_friction = 1
    cloneToken.bounciness = 0
    cloneToken.mass = 100
    cloneToken.unlock()

    playerData[playerNum].Token = cloneToken
    newToken.lock()

    playerData[playerNum].LastSquare=0
    giveStart(playerNum)

end

function convertWallet(theButton, theClicker)
  local playerNum = getPlayerNum(theButton)
  if playerNum == 0 then
    print('ERROR: Claim: How did you click this?')
    return
  end

  if playerData[playerNum].Color ~= theClicker and theClicker ~= "Black" and not Player[theClicker].admin then
      broadcastToColor("This is not yours", theClicker, {1,1,1})
      return
  end

  if playerData[playerNum].SortBusy > 0 or not zoneStill(playerNum) then
      broadcastToColor("Please wait before trying again so soon.", theClicker, {1,1,1})
      return
  end


  for i, v in ipairs(playerData[playerNum].WalletZone.getObjects()) do
      if v.tag == "Card" or v.tag == "Deck" then
          if not v.resting or v.spawning then
              broadcastToColor("Make sure nothing in your wallet zone is moving.", theClicker, {1,1,1})
              return
          end
      end
  end
  setWalletValue(countWallet(playerNum), playerNum)

end

function setWalletValue(amount, playerNum)
    playerData[playerNum].SortBusy = 5

    local objectsList = playerData[playerNum].WalletZone.getObjects()
    local moneySum = 0

    local waitFrames = 1
    for k, v in ipairs(objectsList) do
          if (tonumber(v.getDescription()) == nil) then
              if (v.getQuantity() ~= -1) then
                  local deckContents = v.getObjects()
                  if deckContents ~= nil then
                      for ke = #deckContents, 1, -1 do
                          if (tonumber(deckContents[ke].description) ~= nil) then
                              moneySum = moneySum + tonumber(deckContents[ke].description)
                              Wait.frames(function()
                                  v.takeObject({
                                      position          = {0, -5, 0},
                                      rotation          = {0, 0, 0},
                                      callback_function = function(obj) obj.destruct() end,
                                      smooth            = false,
                                      index             = deckContents[ke].index,
                                  })
                              end, waitFrames)
                          end
                      end
                      waitFrames = waitFrames + 1
                      playerData[playerNum].SortBusy = playerData[playerNum].SortBusy + 0.2
                  end
              end
          else
              moneySum = moneySum + tonumber(v.getDescription())
              Wait.frames(function()
                  v.destruct()
              end, waitFrames)
              waitFrames = waitFrames + 1
              playerData[playerNum].SortBusy = playerData[playerNum].SortBusy + 0.2
          end
      end
      Wait.frames(function()
          dispenseChange(moneySum, playerNum)
      end, waitFrames)
end

function onObjectRandomize(object, player_color)
    if object.type=="Card" or object.type=="Deck" then
        group(Player[player_color].getSelectedObjects())
    end
end

function onChat(message, player)
    if string.sub(message, 1, 1) == "!" then
      splitMessage = splitString(string.lower(message))
      if splitMessage[1] == "!pay" then
          splitMessage = splitString(message)
          if #splitMessage == 2 then
              table.insert(splitMessage, 2, "bank")
          end
          if #splitMessage < 3 then
              player.broadcast("Error: incomplete command.")
              return
          end
          print(tostring(player.color))
          local payerNum = colorToNum[string.lower(player.color)]
          if not payerNum then
              player.broadcast("Error: you are not seated.")
              return
          end
          local payeeNum = colorToNum[string.lower(splitMessage[2])]
          if not payeeNum then
              if string.lower(splitMessage[2]) == "bank" then
                  payeeNum = 0
              end
          end
          if not payeeNum then
              player.broadcast("Error: cannot read player color")
              return
          end
          if payerNum == payeeNum then
              player.broadcast("Error: cannot pay yourself")
              return
          end
          local amount = math.floor(tonumber(splitMessage[3]) + 0.5)
          if not amount or amount < 1 then
              player.broadcast("Error: cannot read amount to pay")
              return
          end

          if (playerData[payerNum].SortBusy > 0 or not zoneStill(payerNum)) or (payeeNum ~= 0 and (playerData[payeeNum].SortBusy > 0 or not zoneStill(payeeNum))) then
              broadcastToColor("Make sure nothing in both players' wallet zones is moving.", playerData[payerNum].Color, {1,1,1})
              return
          end
          local paid = pay(payerNum, payeeNum, amount)
          if paid then
            if string.lower(splitMessage[2]) ~= "bank" then
              broadcastToAll(playerData[payerNum].Color.." paid $"..tostring(amount).." to "..playerData[payeeNum].Color..".", {1,1,1})
            else
              broadcastToAll(playerData[payerNum].Color.." paid $"..tostring(amount).." to the Bank.", {1,1,1})
            end
          end
      elseif splitMessage[1] == "!give" then
          splitMessage = splitString(message)
          local players = 1
          if #splitMessage == 2 then
              players = 2
              local giverNum = colorToNum[string.lower(player.color)]
              if not giverNum then
                  player.broadcast("Error: you are not seated.")
                  return
              end
              table.insert(splitMessage, 2, string.lower(player.color))
          elseif #splitMessage < 3 then
              player.broadcast("Error: incomplete command.")
              return
          end
          local getterNum = colorToNum[string.lower(splitMessage[2])]
          local amount = math.floor(tonumber(splitMessage[3]) + 0.5)
          if not amount or amount < 1 then
              player.broadcast("Error: cannot read amount to give")
              return
          end
          if playerData[getterNum].SortBusy > 0 or not zoneStill(getterNum) then
              broadcastToColor("Make sure nothing in player's wallet zones is moving.", playerData[getterNum].Color, {1,1,1})
              return
          end
          local got = giveManually(getterNum, amount)
          if got then
            broadcastToAll("The bank paid $"..tostring(amount).." to "..playerData[getterNum].Color..".", {1,1,1})
          end
      end
    end
end


function countWallet(playerNum)
    local objectsList = playerData[playerNum].WalletZone.getObjects()
    local moneySum = 0

    for k, v in ipairs(objectsList) do
        if (tonumber(v.getDescription()) == nil) then
            if (v.getQuantity() ~= -1) then
                local deckContents = v.getObjects()
                if deckContents ~= nil then
                    for ke = #deckContents, 1, -1 do
                        if (tonumber(deckContents[ke].description) ~= nil) then
                            moneySum = moneySum + tonumber(deckContents[ke].description)
                        end
                    end
                end
            end
        else
            moneySum = moneySum + tonumber(v.getDescription())
        end
    end
    return moneySum
end


function pay(payerNum, payeeNum, amount)

    if payeeNum == 0 then
        return payBank(payerNum, amount)
    end

    playerData[payerNum].SortBusy = 5
    playerData[payeeNum].SortBusy = 5

    local payerBefore = countWallet(payerNum)
    local payeeBefore = countWallet(payeeNum)

    if amount > payerBefore then
        broadcastToColor("You can't afford to pay that much.", playerData[payerNum].Color, {1,1,1})
        return false
    end

    local objectsList = playerData[payerNum].WalletZone.getObjects()
    local moneySum = 0

    local waitFrames = 1

    for k, v in ipairs(objectsList) do
        if (tonumber(v.getDescription()) == nil) then
            if (v.getQuantity() ~= -1) then
                local deckContents = v.getObjects()
                if deckContents ~= nil then
                    for ke = #deckContents, 1, -1 do
                        if (tonumber(deckContents[ke].description) ~= nil) then
                            moneySum = moneySum + tonumber(deckContents[ke].description)
                            Wait.frames(function()
                                ---[[
                                v.takeObject({
                                    position          = {0, -5, 0},
                                    rotation          = {0, 0, 0},
                                    callback_function = function(obj) obj.destruct() end,
                                    smooth            = false,
                                    index             = deckContents[ke].index,
                                })
                                --]]
                            end, waitFrames)
                        end
                    end
                    waitFrames = waitFrames + 1
                    playerData[payerNum].SortBusy = playerData[payerNum].SortBusy + 0.2
                    playerData[payeeNum].SortBusy = playerData[payeeNum].SortBusy + 0.2
                end
            end
        else
            moneySum = moneySum + tonumber(v.getDescription())
            Wait.frames(function()
                v.destruct()
            end, waitFrames)
            waitFrames = waitFrames + 1
            playerData[payerNum].SortBusy = playerData[payerNum].SortBusy + 0.2
            playerData[payeeNum].SortBusy = playerData[payeeNum].SortBusy + 0.2
        end
    end

    Wait.frames(function()
        dispenseChange(payerBefore - amount, payerNum)

        Wait.condition(function()
            Wait.time(function() updateWallets_pay() end, 1)

        end, function()
            for k, v in ipairs(playerData[payerNum].WalletZone.getObjects()) do
                if (v.tag == "Card" or v.tag == "Deck") and not v.resting then
                    return false
                end
            end
            for k, v in ipairs(playerData[payeeNum].WalletZone.getObjects()) do
                if (v.tag == "Card" or v.tag == "Deck") and not v.resting then
                    return false
                end
            end
            return true
        end, 5, function()
            Wait.time(function() updateWallets_pay() end, 1)

        end)
    end, waitFrames)

    giveManually(payeeNum, amount)
    return true
end


function payBank(payerNum, amount)

    if playerData[payerNum].SortBusy > 0 or not zoneStill(payerNum) then
        broadcastToColor("Make sure nothing in your wallet zone is moving.", playerData[payerNum].Color, {1,1,1})
        return false
    end
    playerData[payerNum].SortBusy = 5

    local payerBefore = countWallet(payerNum)

    if amount > payerBefore then
        broadcastToColor("You can't afford to pay that much.", playerData[payerNum].Color, {1,1,1})
        return false
    end


    local objectsList = playerData[payerNum].WalletZone.getObjects()
    local moneySum = 0

    local waitFrames = 1
    for k, v in ipairs(objectsList) do
        if (tonumber(v.getDescription()) == nil) then
            if (v.getQuantity() ~= -1) then
                local deckContents = v.getObjects()
                if deckContents ~= nil then
                    for ke = #deckContents, 1, -1 do
                        if (tonumber(deckContents[ke].description) ~= nil) then
                            moneySum = moneySum + tonumber(deckContents[ke].description)
                            Wait.frames(function()
                                ---[[
                                v.takeObject({
                                    position          = {0, -5, 0},
                                    rotation          = {0, 0, 0},
                                    callback_function = function(obj) obj.destruct() end,
                                    smooth            = false,
                                    index             = deckContents[ke].index,
                                })
                                --]]
                            end, waitFrames)
                        end
                    end
                    waitFrames = waitFrames + 1
                    playerData[payerNum].SortBusy = playerData[payerNum].SortBusy + 0.2
                end
            end
        else
            moneySum = moneySum + tonumber(v.getDescription())
            Wait.frames(function()
                v.destruct()
            end, waitFrames)
            waitFrames = waitFrames + 1
            playerData[payerNum].SortBusy = playerData[payerNum].SortBusy + 0.2
        end
    end
    Wait.frames(function()
        dispenseChange(payerBefore - amount, payerNum)

        Wait.condition(function()
            Wait.time(function() updateWallets_pay() end, 1)

        end, function()
            for k, v in ipairs(playerData[payerNum].WalletZone.getObjects()) do
                if (v.tag == "Card" or v.tag == "Deck") and not v.resting then
                    return false
                end
            end
            return true
        end, 5, function()
            Wait.time(function() updateWallets_pay() end, 1)

        end)
    end, waitFrames)
    return true
end

function give(getterNum, amount)
    if playerData[getterNum].SortBusy > 0 or not zoneStill(getterNum) then
        broadcastToColor("Make sure nothing in your wallet zone is moving.", playerData[getterNum].Color, {1,1,1})
        return false
    end
    playerData[getterNum].SortBusy = 5

    local getterBefore = countWallet(getterNum)

    if amount > 15690 then
        broadcastToColor("You can't get more than $15690 in single message.\n$15690 is the maximum sum of assents without cash.", playerData[getterNum].Color, {1,1,1})
        return false
    end


    local objectsList = playerData[getterNum].WalletZone.getObjects()
    local moneySum = 0

    local waitFrames = 1
    for k, v in ipairs(objectsList) do
        if (tonumber(v.getDescription()) == nil) then
            if (v.getQuantity() ~= -1) then
                local deckContents = v.getObjects()
                if deckContents ~= nil then
                    for ke = #deckContents, 1, -1 do
                        if (tonumber(deckContents[ke].description) ~= nil) then
                            moneySum = moneySum + tonumber(deckContents[ke].description)
                            Wait.frames(function()
                                ---[[
                                v.takeObject({
                                    position          = {0, -5, 0},
                                    rotation          = {0, 0, 0},
                                    callback_function = function(obj) obj.destruct() end,
                                    smooth            = false,
                                    index             = deckContents[ke].index,
                                })
                                --]]
                            end, waitFrames)
                        end
                    end
                    waitFrames = waitFrames + 1
                    playerData[getterNum].SortBusy = playerData[getterNum].SortBusy + 0.2
                end
            end
        else
            moneySum = moneySum + tonumber(v.getDescription())
            Wait.frames(function()
                v.destruct()
            end, waitFrames)
            waitFrames = waitFrames + 1
            playerData[getterNum].SortBusy = playerData[getterNum].SortBusy + 0.2
        end
    end
    Wait.frames(function()
        dispenseChange(getterBefore + amount, getterNum)

        Wait.condition(function()
            Wait.time(function() updateWallets_pay() end, 1)

        end, function()
            for k, v in ipairs(playerData[getterNum].WalletZone.getObjects()) do
                if (v.tag == "Card" or v.tag == "Deck") and not v.resting then
                    return false
                end
            end
            return true
        end, 5, function()
            Wait.time(function() updateWallets_pay() end, 1)

        end)
    end, waitFrames)
    return true
end

function giveManually(getterNum, amount)
    local getterBefore = countWallet(getterNum)

    if amount > 15690 then
        broadcastToColor("You can't get more than $15690 in single message.\n$15690 is the maximum sum of assents without cash.", playerData[getterNum].Color, {1,1,1})
        return false
    end

    local rotation = playerData[getterNum].WalletCounter.getRotation()["y"]
    rotation = math.floor(rotation/90+0.5)*90

    local billsDenominations = {"1", "5", "10", "20", "50", "100", "500"}
    local countsGive = valueToBigCounts(amount)

    for i=1,7 do
        local bag = getObjectFromGUID(bankBagsGUID[billValues[i]])
        for j=1,countsGive[i] do
            getObjectFromGUID(bankBagsGUID[billValues[i]]).takeObject({
                smooth = false,
                position = playerData[getterNum].SortPositions[billsDenominations[i]],
                rotation = {0, rotation, 0}
            })
        end
    end
    return true
end

function giveStart(playerNum)
    local billsDenominations = {"1", "5", "10", "20", "50", "100", "500"}
    if countWallet(playerNum) == 0 then
        local rotation = playerData[playerNum].WalletCounter.getRotation()["y"]
        rotation = math.floor(rotation/90+0.5)*90

        countsGive = {5,5,5,6,2,2,2}
        for i=1,7 do
            local bag = getObjectFromGUID(bankBagsGUID[billValues[i]])
            for j=1,countsGive[i] do
                getObjectFromGUID(bankBagsGUID[billValues[i]]).takeObject({
                    smooth = false,
                    position = playerData[playerNum].SortPositions[billsDenominations[i]],
                    rotation = {0, rotation, 0}
                })
            end
        end
    end
end

function buy(theButton, theClicker)
  local playerNum = getPlayerNum(theButton)
  if playerNum == 0 then
    print('ERROR: Claim: How did you click this?')
    return
  end

  if playerData[playerNum].Color ~= theClicker then
    broadcastToColor("This is not yours", theClicker, {1,1,1})
    return
  end

  if playerData[playerNum].SortBusy > 0 or not zoneStill(playerNum) then
      broadcastToColor("Please wait before trying again so soon.", theClicker, {1,1,1})
      return
  end


  for i, v in ipairs(playerData[playerNum].WalletZone.getObjects()) do
      if v.tag == "Card" or v.tag == "Deck" then
          if not v.resting or v.spawning then
              broadcastToColor("Make sure nothing in your wallet zone is moving.", theClicker, {1,1,1})
              return
          end
      end
  end

  local token = playerData[playerNum].Token
  if not token then
      broadcastToColor("Error: Token not found.", theClicker, {1,1,1})
      return
  end

  local currSquare = getSquare(token.getPosition())
  if not currSquare then
      broadcastToColor("Error: Token not found on board.", theClicker, {1,1,1})
      return
  end

  local propertyObject = propertyFromBank(currSquare)
  local available = propertyObject ~= nil
  if not available then
    if propertyNameToColor[boardPoints[currSquare][2]] ~= nil then

      for dataId, data in ipairs(playerData) do
          if theClicker~=data.Color then
              for _, v in pairs(data.WalletZone.getObjects()) do
                  if v.getName() == boardPoints[currSquare][2] then
                      local ownerPos = getSquare(data.Token.getPosition())

                      -- CardOwner is in jail
                      if ownerPos == 40 then
                          broadcastToAll(data.Color.." is in jail", {1,1,1})
                          return
                      end

                      -- CardOwner is mortgaged
                      if ((v.getRotation()['z']+90)%360) >= 180 then
                          broadcastToAll("The Card is mortgaged", {1,1,1})
                          return
                      end


                      if propertyNameToColor[boardPoints[currSquare][2]] == "Railroad" then
                          local railroadCount = 0
                          for i5, property2 in pairs(data.WalletZone.getObjects()) do
                              if propertyNameToColor[property2.getName()]==propertyNameToColor[v.getName()] then
                                  railroadCount = railroadCount + 1
                              end
                          end
                          local amount = 25*math.pow(2, railroadCount-1)
                          local paid = pay(playerNum, colorToNum[string.lower(data.Color)], amount)

                          if paid then
                              broadcastToAll(playerData[playerNum].Color.." paid $"..tostring(amount).." to "..data.Color..'.', {1,1,1})
                          end
                          break

                      elseif propertyNameToColor[boardPoints[currSquare][2]] == "Utility" then
                          if playerData[playerNum].LastMove ~= nil and
                                  playerData[playerNum].LastMove == playerData[playerNum].Die1.getValue() + playerData[playerNum].Die2.getValue() then
                              local utilityCount = 0
                              for i5, property2 in pairs(data.WalletZone.getObjects()) do
                                  if propertyNameToColor[property2.getName()]==propertyNameToColor[v.getName()] then
                                      utilityCount = utilityCount + 1
                                  end
                              end

                              local amount = playerData[playerNum].LastMove*(utilityCount*6-2)
                              local paid = pay(playerNum, colorToNum[string.lower(data.Color)], amount)
                              if paid then
                                  broadcastToAll(playerData[playerNum].Color.." paid $"..tostring(amount).." to "..data.Color..'.', {1,1,1})
                              end
                              break
                          else
                              broadcastToColor("You can only pay rent on utilities after moving to the space with the \"Move\" command.", theClicker, {1,1,1})
                          end

                      else
                          -- player has to pay a rent
                          for dataId, data in ipairs(playerData) do
                              if theClicker~=data.Color then
                                  for _, v in pairs(data.WalletZone.getObjects()) do
                                      if v.getName() == boardPoints[currSquare][2] and ((v.getRotation()['z']+90)%360)<180 then
                                          local housesCount = 0
                                          for i3, house in pairs(getAllObjects()) do
                                              -- find houses
                                              if house.getDescription() == "House" and currSquare == getSquare(house.getPosition()) then
                                                  housesCount = housesCount + 1
                                              elseif house.getDescription() == "Hotel" and currSquare == getSquare(house.getPosition()) then
                                                  housesCount = housesCount + 5
                                              end
                                          end
                                          -- trying to double rent
                                          local multiplier = 1
                                          local deedCount = 0
                                          if(housesCount == 0) then
                                              for i5, property2 in pairs(data.WalletZone.getObjects()) do
                                                  if propertyNameToColor[property2.getName()]==propertyNameToColor[v.getName()] then
                                                      deedCount = deedCount + 1
                                                  end
                                              end
                                              if deedCount == 3 or (propertyNameToColor[v.getName()]=='Brown' or propertyNameToColor[v.getName()]=='Dark-Blue') and deedCount == 2 then multiplier = 2 end
                                          end

                                          local amount = propertyRentPrices[v.getName()][housesCount+1]*multiplier
                                          local paid = pay(playerNum, colorToNum[string.lower(data.Color)], amount)
                                          if paid then
                                              broadcastToAll(playerData[playerNum].Color.." paid $"..tostring(amount).." to "..data.Color..'.', {1,1,1})
                                          end
                                          break
                                      end
                                  end
                              end
                          end
                      end
                  end
              end
          end
      end

    elseif currSquare == 40 then
      local paid =  payBank(playerNum, 50)
      if paid then
        broadcastToAll(playerData[playerNum].Color.." paid $"..tostring(50).." to get out of jail.", {1,1,1})
        playerData[playerNum].Token.setPositionSmooth(boardPoints[10][1])
      end
    elseif currSquare == 38 then
      local paid =  payBank(playerNum, luxuryTax)
      if paid then
        broadcastToAll(playerData[playerNum].Color.." paid $"..tostring(luxuryTax).." for luxury tax.", {1,1,1})
      end
    elseif currSquare == 4 then
      -- INCOME TAX
      local assets = 0
      -- cash
      assets = assets + countWallet(playerNum)
      -- properties
      local properties = {}
      for i, v in ipairs(playerData[playerNum].WalletZone.getObjects()) do
        if propertyPrices[v.getName()] ~= nil then
          table.insert(properties, v.getName())
          local mortgaged = ((v.getRotation()['z']+90)%360)>180
          assets = assets + propertyPrices[v.getName()]*(mortgaged and 0.5 or 1)
        end
      end
      -- houses and hotels
      for i, v in ipairs(getAllObjects()) do
        if v.getDescription() == "House" or v.getDescription() == "Hotel" then
          local housePlace = boardPoints[getSquare(v.getPosition())][2]
          local multiplier = 1
          if v.getDescription() == "Hotel" then multiplier = 5 end
          for i2, v2 in ipairs(properties) do
            if v2 == housePlace then assets = assets + housePrice[housePlace]*multiplier end
          end
        end
      end
      local amount =  (math.floor(assets*0.1+0.5))
      local paid = payBank(playerNum, amount)
      if paid then
        broadcastToAll(playerData[playerNum].Color.." paid $"..tostring(amount).." for income tax.", {1,1,1})
      else
        broadcastToAll(playerData[playerNum].Color.." can't afford $"..tostring(amount).." to pay for income tax.", {1,1,1})
      end
    else
      broadcastToColor("Error: Property not found in bank.", theClicker, {1,1,1})
      return
    end
  else
    local amount = propertyPrices[boardPoints[currSquare][2]]

    local success = payBank(playerNum, amount)
    if success then
        takeDeed(propertyObject, currSquare, playerNum)
        broadcastToAll(playerData[playerNum].Color.." bought "..propertyObject.getName(), {1,1,1})
    end
  end
end


function propertyAvailable(square)
    if not boardPoints[square] or not propertyPrices[boardPoints[square][2]] then
        return false
    end
    for i, v in ipairs(getAllObjects()) do
        if v.tag == "Card" then
            local position = v.getPosition()
            if (position.x > 20 and position.x < 24 or position.x > -24 and position.x < 20)
            and position.z > -18 and position.z < 17 then
                if v.getName() == boardPoints[square][2] then
                    return true
                end
            end
        end
    end
    return false
end

function propertyFromBank(square)
    if not boardPoints[square] or not propertyPrices[boardPoints[square][2]] then
        return nil
    end
    for i, v in ipairs(getAllObjects()) do
        if v.tag == "Card" then
            local position = v.getPosition()
            if (position.x > 20 and position.x < 24 or position.x > -24 and position.x < 20)
            and position.z > -18 and position.z < 17 then
                if v.getName() == boardPoints[square][2] then
                    return v
                end
            end
        end
    end
    return nil
end


function takeDeed(object, square, playerNum)
    object.setPositionSmooth(playerData[playerNum].SortPositions[boardPoints[square][2]])
    local upRotation = playerData[playerNum].WalletCounter.getRotation()
    object.setRotationSmooth({
        upRotation.x,
        upRotation.y + 180,
        upRotation.z,
    })
    return
end


function dispenseChange(sum, playerNum)
    local counts = valueToChangeCounts(sum)
    local counterRotation = playerData[playerNum].WalletCounter.getRotation()
    local waitFrames = 1
    for i, v in ipairs(counts) do
        for j = 1, v do
            local cardJSON = cardJSONs[billValues[i]]
            Wait.frames(function()
                spawnObjectJSON({
                    json = cardJSON,
                    position = playerData[playerNum].SortPositions[tostring(billValues[i])],
                    rotation = counterRotation,
                    callback_function = function() return end,
                })
            end, waitFrames)
            waitFrames = waitFrames + 1
            playerData[playerNum].SortBusy = playerData[playerNum].SortBusy + 0.2
        end
    end
end

function valueToChangeCounts(value)
    local counts = {0, 0, 0, 0, 0, 0, 0}
    for i, v in ipairs(getChangeCounts) do
        value, counts = valueToChangeStep(value, counts, i, v)
    end
    local tradeUpCounts = valueToTradeUpCounts(value)
    for i = 1, #counts do
        counts[i] = counts[i] + tradeUpCounts[i]
    end
    return counts
end

function valueToBigCounts(value)
    local counts = {0, 0, 0, 0, 0, 0, 0}
    local valueLeft = value
    for i=7,1,-1 do
        counts[i] = math.floor(valueLeft/billValues[i])
        valueLeft = valueLeft-billValues[i]*counts[i]
    end
    return counts
end

function valueToChangeCounts(value)
    local counts = {0, 0, 0, 0, 0, 0, 0}
    for i, v in ipairs(getChangeCounts) do
        value, counts = valueToChangeStep(value, counts, i, v)
    end
    local tradeUpCounts = valueToTradeUpCounts(value)
    for i = 1, #counts do
        counts[i] = counts[i] + tradeUpCounts[i]
    end
    return counts
end

function valueToChangeStep(value, counts, type, number)
    while value > billValues[type] and number > 0 do
        value = value - billValues[type]
        counts[type] = counts[type] + 1
        number = number - 1
    end
    return value, counts
end

function valueToTradeUpCounts(value)
    local counts = {0, 0, 0, 0, 0, 0, 0}
    for i = #counts, 1, -1 do
        if value == 0 then
            break
        end
        if getChangeCounts[i] ~= 0  or i == 1 then
            local chipNumber = math.floor(value / billValues[i])
            value = value - billValues[i]*chipNumber
            counts[i] = chipNumber
        end
    end
    return counts
end


function sortWallet(theButton, theClicker)
    local playerNum = getPlayerNum(theButton)
    if playerNum == 0 then
    print('ERROR: Claim: How did you click this?')
    return
    end

    for i, v in ipairs(playerData[playerNum].WalletZone.getObjects()) do
        if v.tag == "Card" or v.tag == "Deck" then
          if not v.resting or v.spawning then
              broadcastToColor("Make sure nothing in your wallet zone is moving.", theClicker, {1,1,1})
              return
          end
        end
    end

    local rotation = playerData[playerNum].WalletCounter.getRotation()["y"]
    rotation = math.floor(rotation/90+0.5)*90

    for i, v in ipairs(playerData[playerNum].WalletZone.getObjects()) do
        if v.tag == "Deck" and #v.getObjects()>1 then
            local bill = false
            local billsDenominations = {"1", "5", "10", "20", "50", "100", "500"}

            for j, w in ipairs(billsDenominations) do
                if math.max(   math.abs(playerData[playerNum].SortPositions[w]['x']-v.getPosition()['x']),
                               math.abs(playerData[playerNum].SortPositions[w]['z']-v.getPosition()['z'])) <= 0.25 then
                    bill = true
                    if math.abs(v.getRotation()["y"]-rotation)>1 then
                        v.setRotation({0, rotation, 0})
                    end
                    local toTake = {}
                    local stackDenomination = ""
                    for k, wv in ipairs(v.getObjects()) do
                        local desc = wv.description
                        if desc == nil then desc = "" end
                        if desc == "1" or desc == "5" or desc == "10" or desc == "20" or desc == "50" or desc == "100" or desc == "500" then
                            if desc ~= w then
                                table.insert(toTake, {wv.guid, playerData[playerNum].SortPositions[desc], {0, rotation, 0}, desc})
                                stackDenomination = (stackDenomination == "" or stackDenomination == desc) and desc or nil
                            end
                        else
                            stackDenomination = nil
                            local nickname = wv.nickname
                            if nickname and string.len(nickname) > 0 then
                                table.insert(toTake, {wv.guid, playerData[playerNum].SortPositions[nickname], {0,rotation+180,0}, nickname})
                            else
                                table.insert(toTake, {wv.guid, playerData[playerNum].SortPositions.Miscellaneous, {0,rotation+180,0}, nickname})
                            end
                        end
                    end
                    local cardsCount = #v.getObjects()
                    for k, wv in ipairs(toTake) do
                        if v~=nil and cardsCount>1 then
                            if tonumber(wv[4]) ~= nil then
                              v.takeObject({guid = wv[1], position = wv[2], rotation = wv[3]})
                            else
                              broadcastToAll(playerData[playerNum].Color..' put '..wv[4]..' in a deck. This is not allowed!', {1,1,1})
                              v.takeObject({guid = wv[1], position = wv[2], rotation = wv[3]})
                            end
                            cardsCount = cardsCount - 1
                        end
                    end
                    break
                end
            end
        if not bill then
            local toTake = {}
            local stackDenomination = ""
            local stackCounts = {["1"]=0,["5"]=0,["10"]=0,["20"]=0,["50"]=0,["100"]=0,["500"]=0}
            for k, wv in ipairs(v.getObjects()) do
                local desc = wv.description
                if desc == "1" or desc == "5" or desc == "10" or desc == "20" or desc == "50" or desc == "100" or desc == "500" then
                    table.insert(toTake, {wv.guid, playerData[playerNum].SortPositions[desc], {0, rotation, 0}, desc})
                    stackDenomination = (stackDenomination == "" or stackDenomination == desc) and desc or nil
                    stackCounts[desc] = stackCounts[desc] + 1
                else
                    stackDenomination = nil
                    local nickname = wv.nickname
                    if nickname and string.len(nickname) > 0 then
                        table.insert(toTake, {wv.guid, playerData[playerNum].SortPositions[nickname], {0,rotation+180,0}, nickname})
                    else
                        table.insert(toTake, {wv.guid, playerData[playerNum].SortPositions.Miscellaneous, {0,rotation+180,0}, nickname})
                    end
                end
            end
            local mostCommonDenomination = "1"
            for di = 2,7 do
                if stackCounts[tostring(billValues[di])]>stackCounts[mostCommonDenomination] then
                    mostCommonDenomination = tostring(billValues[di])
                end
            end
            local cardsCount = #v.getObjects()
            local toTakeLength = #toTake
            local stackPosition = {0,0,0}
            local stackRotation = {0,0,0}
            for k, wv in ipairs(toTake) do
                if v~=nil and cardsCount>1 then
                    if wv[4] ~= mostCommonDenomination then
                      if tonumber(wv[4]) == nil and wv[4]~='' then
                          broadcastToAll(playerData[playerNum].Color..' put '..wv[4]..' in a deck. This is not allowed!', {1,1,1})
                      end
                      v.takeObject({guid = wv[1], position = wv[2], rotation = wv[3]})
                      cardsCount = cardsCount - 1
                      toTakeLength = toTakeLength - 1
                    else
                        stackPosition = wv[2]
                        stackRotation = wv[3]
                    end
                end
            end
            if cardsCount==toTakeLength then
                v.setPosition(stackPosition)
                v.setRotation(stackRotation)
            end
        end
    end
end
    Wait.frames(function()
    local walletObjects = playerData[playerNum].WalletZone.getObjects()
    local toTake = {}
    for i, v in ipairs(walletObjects) do
        if v ~= nil and v.tag == "Card" then
            local desc = v.getDescription()
            if desc == "1" or desc == "5" or desc == "10" or desc == "20" or desc == "50" or desc == "100" or desc == "500" then
                table.insert(toTake, {v.guid, playerData[playerNum].SortPositions[desc], {v.getRotation()["x"], rotation, 0}})
            else
                local nickname = v.getName()
                if nickname and string.len(nickname) > 0 then
                  table.insert(toTake, {v.guid, playerData[playerNum].SortPositions[nickname], {v.getRotation()["x"], rotation+180, v.getRotation()["z"]}})
                else
                  table.insert(toTake, {v.guid, playerData[playerNum].SortPositions.Miscellaneous, {0,rotation+180,0}})
                end
            end
        end
            for i, v in ipairs(toTake) do
                local object = getObjectFromGUID(v[1])
                local pos = object.getPosition()
                if math.max(math.abs(pos['x']-v[2]['x']), math.abs(pos['z']-v[2]['z']))>0.25 then object.setPosition(v[2]) end

                if math.max(math.abs(object.getRotation()["y"]-v[3][2]))>1 then
                    object.setRotation(v[3])
                end
            end
        end
    end, 2)
end


function dispense_callback(obj, positions, rotations, playerNum)
    local bagPosition = obj.getPosition()
    local containedCount = #obj.getObjects()
    for i = 1, containedCount - 1 do
        Wait.frames(function()
            obj.takeObject({
                index = 0,
                position = bagPosition,
                rotation = rotations[i],
                smooth = false,
                callback_function = function(chip)
                    dispense_chip_callback(chip, positions[i])
                end,
            })
        end, i)
    end
    Wait.frames(function()
        obj.takeObject({
            index = 0,
            position = bagPosition,
            rotation = rotations[containedCount],
            smooth = false,
            callback_function = function(chip)
                dispense_chip_callback(chip, positions[containedCount])
            end,
        })
    end, containedCount - 1)
end


function dispense_chip_callback(chip, position)
    chip.setPositionSmooth(position, false, false)
end



function getPlayerNum(theButton)
  local playerNum = 0
  local ctr = 0
  for k, v in next, playerData do
    ctr = ctr + 1
    if theButton == v.ButtonChip then
        playerNum = ctr
    end
  end
  return playerNum
end
-------------------------------------------------------------------------

-- Counting Player's Wallets --------------------------------------------
function updateWallets()
    for k, v in next, playerData do
        if v.WalletZoneObjectCount ~= #(v.WalletZone.getObjects()) then
            local objectsList = v.WalletZone.getObjects()
            local moneySum = 0

            for k, v in next, objectsList do
            	if (tonumber(v.getDescription()) == nil) then
            		if (v.getQuantity() ~= -1) then
            			local deckContents = v.getObjects()
            			if deckContents ~= nil then
            				for ke, va in next, deckContents do
            					if (tonumber(va.description) ~= nil) then
            						moneySum = moneySum + tonumber(va.description)
            					end
            				end
            			end
            		end
            	else
            		moneySum = moneySum + tonumber(v.getDescription())
            	end
            end
            if moneySum~= v.WalletCounter.getValue() then
                v.WalletCounter.setValue(moneySum)
            end
            v.WalletZoneObjectCount = #(v.WalletZone.getObjects())
        end
    end
    -- mortgaged properties
    local mortgagedCounter = getObjectFromGUID('6a49df')
    local amount = 0
    for k, property in ipairs(playerData[9].WalletZone.getObjects()) do
        if propertyPrices[property.getName()]~=nil and property.tag == 'Card' and math.floor( property.getRotation()['z']/180+0.5)%2==1 then
            amount=amount + math.floor(propertyPrices[property.getName()]*0.05+0.55)
        end
    end
    if mortgagedCounter.getValue()~=amount then
        mortgagedCounter.setValue(amount)
    end
end

function updateWallets_pay()
  for k, v in next, playerData do
--    if v.WalletZoneObjectCount ~= #(v.WalletZone.getObjects()) then
      local objectsList = v.WalletZone.getObjects()
      local moneySum = 0

      for k, v in next, objectsList do
    		if (tonumber(v.getDescription()) == nil) then
    			if (v.getQuantity() ~= -1) then
    				local deckContents = v.getObjects()
    				if deckContents ~= nil then
    					for ke, va in next, deckContents do
    						if (tonumber(va.description) ~= nil) then
    							moneySum = moneySum + tonumber(va.description)
    						end
    					end
    				end
    			end
    		else
    			moneySum = moneySum + tonumber(v.getDescription())
    		end
    	end

    	v.WalletCounter.setValue(moneySum)
      v.WalletZoneObjectCount = #(v.WalletZone.getObjects())
--    end
  end
end
-------------------------------------------------------------------------

-- Retrieving Player's Dice ---------------------------------------------
function retrieveDice()
    for k, v in next, playerData do
        if v.Die1 ~= nil and v.Die2 ~= nil then
            if v.Die1Resting == true then
                if v.Die1.resting ~= true then
                    v.Die1Resting = false
                    if v.Color == turnData.Color then
                        turnData.HasRolled1 = false
                    end
                end
            else
                if v.Die1.resting == true then
                    v.Die1.setPositionSmooth(v.Die1Position)
                    v.Die1Resting = true
                    if v.Color == turnData.Color then
                        turnData.HasRolled1 = true
                    end
                end
            end

            if v.Die2Resting == true then
                if v.Die2.resting ~= true then
                    v.Die2Resting = false
                    if v.Color == turnData.Color then
                        turnData.HasRolled2 = false
                    end
                end
            else
                if v.Die2.resting == true then
                    v.Die2.setPositionSmooth(v.Die2Position)
                    v.Die2Resting = true
                    if v.Color == turnData.Color then
                        turnData.HasRolled2 = true
                    end
                end
            end
            -- checking if player in jail
            if v.Token ~= nil then
                local currSquare = getSquare(v.Token.getPosition())
                if not( v.Token.resting and v.Die1.resting and v.Die2.resting) then
                    if currSquare == 40 and v.Die1.getValue() ~= v.Die2.getValue() then
                        v.ButtonChip.editButton({index = 2, color = "Orange", label = "In\nJail"})
                    else
                        v.ButtonChip.editButton({index = 2, color = "White", label = "Move"})
                        v.TurnInJail = 0
                    end

                    if currSquare == 40 then
                        v.ButtonChip.editButton({index = 6, scale={1,1,1}})
                    else
                        v.TurnInJail = 0
                        v.ButtonChip.editButton({index = 6, label = "0", scale={0,0,0}})
                    end

                    local available = propertyFromBank(currSquare) ~= nil
                    if not available then
                        if currSquare==40 then
                            v.ButtonChip.editButton({index = 5, label = "Pay\n$50"})
                        elseif currSquare==38 then
                            v.ButtonChip.editButton({index = 5, label = "Pay\ntax"})
                        elseif currSquare==4    then
                            v.ButtonChip.editButton({index = 5, label = "Pay\n10%"})
                        elseif currSquare ~= 0 and propertyNameToColor[boardPoints[currSquare][2]] ~= nil then
                            for _, c in pairs(v.WalletZone.getObjects()) do
                                if  c.getName() == boardPoints[currSquare][2] then
                                    v.ButtonChip.editButton({index = 5, label = "Own"})
                                    break;
                                else
                                    v.ButtonChip.editButton({index = 5, label = "Pay\nrent"})
                                end
                            end
                        else
                            v.ButtonChip.editButton({index = 5, label = "Buy"})
                        end
                    else
                        v.ButtonChip.editButton({index = 5, label = "Buy"})
    		        end
                else
                    -- checking if token moved manually
                    if v.LastSquare~=nil and currSquare ~= v.LastSquare then
                        if currSquare == v.LastSquare + v.Die1.getValue() + v.Die2.getValue() then
                            lastMove = v.Color
                            updateLRLM()
                            v.LastSquare = currSquare
                        end
                    end
                end
            end
        end
    end
end
-------------------------------------------------------------------------

-- Moving Token By Rolled Amount ----------------------------------------
function getSquare(position)
  local X = position.x
  local Z = position.z

  if X > 12.10 and X < 17 and Z < 17 and Z > -17 then
    --Token is on Right
    if Z >  12.20 then return 30 end
    if Z >   9.45 then return 31 end
    if Z >   6.70 then return 32 end
    if Z >   4.00 then return 33 end
    if Z >   1.25 then return 34 end
    if Z >  -1.45 then return 35 end
    if Z >  -4.15 then return 36 end
    if Z >  -6.90 then return 37 end
    if Z >  -9.55 then return 38 end
    if Z > -12.25 then return 39 end
    return 0
  end
  if X < -12.25 and X > -17 and Z < 17 and Z > -17 then
    --Token is on Left
    if Z < -12.25 then
      if X > -15.5 and Z > -15.5 then
        return 40
      else
      return 10
      end
    end --Need to detect Jail vs Visiting
    if Z <  -9.55 then return 11 end
    if Z <  -6.90 then return 12 end
    if Z <  -4.15 then return 13 end
    if Z <  -1.45 then return 14 end
    if Z <   1.25 then return 15 end
    if Z <   4.00 then return 16 end
    if Z <   6.70 then return 17 end
    if Z <   9.45 then return 18 end
    if Z <  12.20 then return 19 end
    return 20
  end
  if Z > 12.20 and Z < 17 and X < 17 and X > -17 then
    --Token is on Top
    if X < -9.45 then return 21 end
    if X < -6.58 then return 22 end
    if X < -4.10 then return 23 end
    if X < -1.40 then return 24 end
    if X <  1.30 then return 25 end
    if X <  4.10 then return 26 end
    if X <  6.80 then return 27 end
    if X <  9.50 then return 28 end
    return 29
  end
  if Z < -12.25 and Z > -17 and X < 17 and X > -17 then
    --Token is on Bottom
    if X >  9.35 then return 1 end
    if X >  6.80 then return 2 end
    if X >  4.10 then return 3 end
    if X >  1.40 then return 4 end
    if X > -1.30 then return 5 end
    if X > -4.05 then return 6 end
    if X > -6.75 then return 7 end
    if X > -9.50 then return 8 end
    return 9
  end

  --Token is not on the board.
  return 0
end

boardPoints = {nil}
function initializeBoardPoints(save_state)
  boardPoints[01] = {{ 10.8, 2.5, -15.4}, 'Dark'}
  boardPoints[02] = {{  8.1, 2.5, -15.4}, 'Community Chest'}
  boardPoints[03] = {{  5.5, 2.5, -15.4}, 'Zeynabie'}
  boardPoints[04] = {{  2.7, 2.5, -14.1}, 'Income Tax: $200'}
  boardPoints[05] = {{  0  , 2.5, -15.4}, 'Amoozesh Gahe Khaste'}
  boardPoints[06] = {{ -2.7, 2.5, -15.4}, 'Kohandej'}
  boardPoints[07] = {{ -5.4, 2.5, -15.4}, 'Chance'}
  boardPoints[08] = {{ -8  , 2.5, -15.4}, 'Marchin'}
  boardPoints[09] = {{-10.9, 2.5, -15.4}, 'Joozdan'}
  boardPoints[10] = {{-15.9, 2.5, -15.9}, 'Just Visiting'}
  boardPoints[11] = {{-15.4, 2.5, -10.9}, 'Tokhchi'}
  boardPoints[12] = {{-15.4, 2.5,  -8.2}, 'Karkhane Feshare Jafari'}
  boardPoints[13] = {{-15.4, 2.5,  -5.5}, 'Asgarie'}
  boardPoints[14] = {{-15.4, 2.5,  -2.7}, 'Kaveh'}
  boardPoints[15] = {{-15.4, 2.5,   0  }, 'Elektriky Dorvash'}
  boardPoints[16] = {{-15.4, 2.5,   2.7}, 'Ahmad Abad'}
  boardPoints[17] = {{-15.4, 2.5,   5.4}, 'Community Chest'}
  boardPoints[18] = {{-15.4, 2.5,   8  }, 'Jeyshir'}
  boardPoints[19] = {{-15.4, 2.5,  10.9}, 'Takhti'}
  boardPoints[20] = {{-14.5, 2.5,  14.5}, 'Free Parking'}
  boardPoints[21] = {{-10.9, 2.5,  15.4}, 'Hosein Abad'}
  boardPoints[22] = {{ -8.1, 2.5,  15.4}, 'Chance'}
  boardPoints[23] = {{ -5.5, 2.5,  15.4}, 'Vahid'}
  boardPoints[24] = {{ -2.7, 2.5,  15.4}, 'Sepahan Shahr'}
  boardPoints[25] = {{  0  , 2.5,  15.4}, 'Halal Khorie Hajie'}
  boardPoints[26] = {{  2.7, 2.5,  15.4}, 'Hakim Nezami'}
  boardPoints[27] = {{  5.5, 2.5,  15.4}, 'Bagh Daryache'}
  boardPoints[28] = {{  8  , 2.5,  15.4}, 'Mojasame Sazi Malekpour'}
  boardPoints[29] = {{ 10.9, 2.5,  15.4}, 'Moshtagh'}
  boardPoints[30] = {{ 14.5, 2.5,  14.5}, 'Go To Jail'}
  boardPoints[31] = {{ 15.4, 2.5,  10.9}, 'Tohid'}
  boardPoints[32] = {{ 15.4, 2.5,   8  }, 'Chahar Bagh'}
  boardPoints[33] = {{ 15.4, 2.5,   5.4}, 'Community Chest'}
  boardPoints[34] = {{ 15.4, 2.5,   2.7}, 'Mardavij'}
  boardPoints[35] = {{ 15.4, 2.5,   0  }, 'Mey Khane Ashkan'}
  boardPoints[36] = {{ 15.4, 2.5,  -2.7}, 'Chance'}
  boardPoints[37] = {{ 15.4, 2.5,  -5.5}, 'Abas Abad'}
  boardPoints[38] = {{ 15.4, 2.5,  -8  }, 'Luxury Tax: $100'}
  boardPoints[39] = {{ 15.4, 2.5, -10.9}, 'Mehr Abad'}
  boardPoints[40] = {{-13.8, 2.5, -13.8}, 'Jail'}
end


function tryObjectRandomize(object, player)
    if playerData[1]~=nil then
        local playerNum = 1
        while playerData[playerNum].Color ~= player and playerNum<=8 do playerNum = playerNum + 1 end
        if object == playerData[playerNum].Die1 or object == playerData[playerNum].Die2 then
            if (playerData[playerNum].RollTimeoutSeconds~=0 and playerData[playerNum].RollTimeout < 999998) then
                return false
            else
                playerData[playerNum].RollTimeout = 1000000
                playerData[playerNum].RollTimeoutSeconds = 2
            end
        end
    end
    if (object.getGUID() == 'ef1c67' or object.getGUID() == '15d990') and cardsShuffled then
       return false
    end
end

function rollDice(theButton, theClicker)
  local playerNum = getPlayerNum(theButton)
  if playerNum == 0 then
    print('ERROR: Move: How did you click this?')
    return
  end

  if playerData[playerNum].Color ~= theClicker and theClicker ~= "Black" then
    broadcastToColor("This is not yours", theClicker, {1,1,1})
    return
  end

  if playerData[playerNum].Token == nil then
    broadcastToColor("You have no token to move", theClicker, {1,1,1})
    return
  end

  if not (playerData[playerNum].RollTimeoutSeconds~=0 and playerData[playerNum].RollTimeout < 999998) then
      playerData[playerNum].RollTimeout = 1000000
      playerData[playerNum].RollTimeoutSeconds = 2
      playerData[playerNum].Die1.roll()
      playerData[playerNum].Die2.roll()

      lastRoll = playerData[playerNum].Color
      updateLRLM()
  end
end

function onObjectRandomize(object, player_Color)
    for i=1,8 do
        if object==playerData[i].Die1 or object==playerData[i].Die2 then
            lastRoll=playerData[i].Color
            updateLRLM()
        end
    end
end

function plusOneInJail(theButton, theClicker)
    local playerNum = getPlayerNum(theButton)
    if playerNum == 0 then
        print('ERROR: Move: How did you click this?')
        return
    end

    if playerData[playerNum].Token == nil then
        broadcastToColor("You have no token to move", theClicker, {1,1,1})
        return
    end

    if not playerData[playerNum].Token.resting then
        broadcastToColor("Make sure your token isn't moving.", theClicker, {1,1,1})
        return
    end
    if getSquare(playerData[playerNum].Token.getPosition()) == 40 then
        playerData[playerNum].TurnInJail=(playerData[playerNum].TurnInJail+1)%3
        playerData[playerNum].ButtonChip.editButton({index=6, label=tostring(playerData[playerNum].TurnInJail)})
    end
end

function moveToken(theButton, theClicker)
    local playerNum = getPlayerNum(theButton)
    if playerNum == 0 then
        print('ERROR: Move: How did you click this?')
        return
    end

    if playerData[playerNum].Color ~= theClicker and theClicker ~= "Black" then
        broadcastToColor("This is not yours", theClicker, {1,1,1})
        return
    end

    if playerData[playerNum].Token == nil then
        broadcastToColor("You have no token to move", theClicker, {1,1,1})
        return
    end

    if not playerData[playerNum].Token.resting then
        broadcastToColor("Make sure your token isn't moving.", theClicker, {1,1,1})
        return
    end

    -- for i=1,8 do
    --     playerData[i].ButtonChip.editButton({index = 1, Color = 'White'})
    -- end
    -- Wait.frames(function()
    --     playerData[playerNum].ButtonChip.editButton({index = 1, Color = {110/255, 158/255, 236/255}})
    -- end, 2)

    local printColor = stringColorToRGB( playerData[playerNum].Color )
    local prevSquare = getSquare(playerData[playerNum].Token.getPosition())
    local currSquare = getSquare(playerData[playerNum].Token.getPosition())

    turnData.HasRolled1 = false
    turnData.HasRolled2 = false
    turnData.HasMoved = true

    lastMove = playerData[playerNum].Color
    updateLRLM()

    if currSquare ~= 40 or playerData[playerNum].Die1.getValue() == playerData[playerNum].Die2.getValue() then
        if currSquare == 40 then currSquare = 10 end

        playerData[playerNum].LastMove = playerData[playerNum].Die1.getValue() + playerData[playerNum].Die2.getValue()
        currSquare = currSquare + playerData[playerNum].LastMove

        if currSquare > 39 then
            currSquare = currSquare - 40
            local success = giveManually(playerNum, 200)
            if success then
                broadcastToAll(playerData[playerNum].Color.." collected $200 for passing GO.", {1,1,1})
            end
        end

        if currSquare == 30 then currSquare = 40 end
    end

    playerData[playerNum].LastSquare = currSquare

    if currSquare == 0 then
        playerData[playerNum].Token.setPositionSmooth(playerData[playerNum].TokenInitialPosition)
    else
        local tokens = {}
        local prevTokens = {}
        for i = 1,8 do
            if playerData[i].Token ~= nil then
                if getSquare(playerData[i].Token.getPosition()) == currSquare then
                    table.insert(tokens, playerData[i].Token)
                elseif getSquare(playerData[i].Token.getPosition()) == prevSquare then
                    if playerData[i].Token ~= playerData[playerNum].Token then
                        table.insert(prevTokens, playerData[i].Token)
                    end
                end
            end
        end
        table.insert(tokens, playerData[playerNum].Token)
        local offset
        if #tokens == 1 and currSquare~=10 then
            playerData[playerNum].Token.setPositionSmooth(boardPoints[currSquare][1])
        elseif #tokens > 1 and #tokens < 5 then
            if currSquare~=10 then
                if #tokens == 2 then
                    offset = {{0.6, -0.6}, {-0.6, 0.6}}
                elseif #tokens == 3 then
                    offset = {{-0.9, -0.2}, {0, 0.2}, {0.9, -0.2}}
                elseif #tokens == 4 then
                    offset = {{0, -0.3}, {0, 1}, {-1.1, 0.6}, {1.1, 0.6}}
                end
            else
                offset = {{0.9, -0.2}, {-0.2, 0.9}, {2.7, -0.2}, {-0.2, 2.7}}
            end
            local pos = {0,0,0}
            for i,v in ipairs(tokens) do
                pos[1] = boardPoints[currSquare][1][1]
                pos[2] = boardPoints[currSquare][1][2]
                pos[3] = boardPoints[currSquare][1][3]
                if i <= #offset then
                    pos[1] = pos[1]+offset[i][1] -- x & z don't work
                    pos[3] = pos[3]+offset[i][2]
                    v.setPositionSmooth(pos)
                else
                    v.setPositionSmooth(boardPoints[currSquare][1])
                end
            end
        else
            playerData[playerNum].Token.setPositionSmooth(boardPoints[currSquare][1])
        end
        if prevSquare ~= 0 then
            Wait.frames(function()
                if #prevTokens == 2 then
                    offset = {{0.6, -0.6}, {-0.6, 0.6}}
                elseif #prevTokens == 3 then
                    offset = {{-0.9, -0.2}, {0, 0.2}, {0.9, -0.2}}
                elseif #prevTokens >= 4 then
                    offset = {{0, -0.3}, {0, 1}, {-1.1, 0.6}, {1.1, 0.6}}
                else
                    offset = {{0, 0}}
                end
                local pos = {0,0,0}
                for i,v in ipairs(prevTokens) do
                    if v ~= playerData[playerNum].Token then
                        pos[1] = boardPoints[prevSquare][1][1]
                        pos[2] = boardPoints[prevSquare][1][2]
                        pos[3] = boardPoints[prevSquare][1][3]
                        if i <= #offset then
                            pos[1] = pos[1]+offset[i][1] -- x & z don't work
                            pos[3] = pos[3]+offset[i][2]
                            v.setPositionSmooth(pos)
                        else
                            v.setPositionSmooth(boardPoints[currSquare][1])
                        end
                    end
                end
            end, 10)
        end
    end

end

function onPlayerTurnStart(player_Color_start, player_Color_previous)
  nextTurn({player_Color_start})
end

turnData = {nil}
function nextTurn(theData)
  turnData = {
    Color=theData[1]
    ,HasRolled1 = false
    ,HasRolled2 = false
    ,HasMoved = false
    ,firstDoubles = false
    ,secondDoubles = false
  }
end

function takeHouse(number)
    for i=1,number do
        housesBag.takeObject({position = {
            0.73*(((i-1)%3)-1),2.67,0.73*(math.floor((i-1)/3))
        }})
    end
end

function takeHotel(number)
    for i=1,number do
        hotelsBag.takeObject({position = {
            1.55*((i-1)-1),2.67,-1.77
        }})
    end
end


function takeHouse1() takeHouse(1) end
function takeHouse2() takeHouse(2) end
function takeHouse3() takeHouse(3) end
function takeHouse4() takeHouse(4) end
function takeHouse5() takeHouse(5) end
function takeHouse6() takeHouse(6) end
function takeHouse7() takeHouse(7) end
function takeHouse8() takeHouse(8) end
function takeHouse9() takeHouse(9) end
function takeHouse10() takeHouse(10) end
function takeHouse11() takeHouse(11) end
function takeHouse12() takeHouse(12) end
function takeHouse13() takeHotel(1) end
function takeHouse14() takeHotel(2) end
function takeHouse15() takeHotel(3) end

-------------------------------------------------------------------------

function splitString(input)
    local outputs = {}
    --for output in input:gmatch("%w+") do
    for output in input:gmatch("[^%s]+") do
        table.insert(outputs, output)
    end
    return outputs
end
