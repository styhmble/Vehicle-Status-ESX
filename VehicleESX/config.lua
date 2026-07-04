return {
    -- Command permission group (use "admin" for admins only, or "user" for everyone)
    commandGroup = "user",
    
    -- Enable speed analytics (shows baseline vs upgraded speed in UI and reports)
    enableSpeedAnalytics = true,
    
    -- Speed upgrade multipliers by vehicle class
    -- These are approximate multipliers for full upgrades applied to the REALISTIC baseline
    classSpeedMultipliers = {
        [0] = 1.15,  -- Compacts
        [1] = 1.15,  -- Sedans
        [2] = 1.18,  -- SUVs
        [3] = 1.20,  -- Coupes
        [4] = 1.25,  -- Muscle
        [5] = 1.22,  -- Sports Classics
        [6] = 1.28,  -- Sports
        [7] = 1.32,  -- Super
        [8] = 1.15,  -- Motorcycles
        [9] = 1.15,  -- Off-road
        [10] = 1.15, -- Industrial
        [11] = 1.10, -- Utility
        [12] = 1.15, -- Vans
        [13] = 1.05, -- Cycles
        [14] = 1.20, -- Boats
        [15] = 1.15, -- Helicopters
        [16] = 1.15, -- Planes
        [17] = 1.10, -- Service
        [18] = 1.15, -- Emergency
        [19] = 1.20, -- Military
        [20] = 1.15, -- Commercial
        [21] = 1.15, -- Trains
    },
    
    -- Mod type names for display
    modTypeNames = {
        [0] = "Spoiler",
        [1] = "Front Bumper",
        [2] = "Rear Bumper",
        [3] = "Side Skirt",
        [4] = "Exhaust",
        [5] = "Frame",
        [6] = "Grille",
        [7] = "Hood",
        [8] = "Fender",
        [9] = "Right Fender",
        [10] = "Roof",
        [11] = "Engine",
        [12] = "Brakes",
        [13] = "Transmission",
        [14] = "Horn",
        [15] = "Suspension",
        [16] = "Armor",
        [17] = "Nitrous",
        [18] = "Turbo",
        [19] = "Subwoofer",
        [20] = "Tire Smoke",
        [21] = "Hydraulics",
        [22] = "Xenon Lights",
        [23] = "Wheels",
        [24] = "Rear Wheels",
        [25] = "Plate Holder",
        [26] = "Trim Design",
        [27] = "Ornaments",
        [28] = "Dashboard",
        [29] = "Dial Design",
        [30] = "Door Speaker",
        [31] = "Seats",
        [32] = "Steering Wheels",
        [33] = "Shifter Leavers",
        [34] = "Plaques",
        [35] = "Speakers",
        [36] = "Trunk",
        [37] = "Hydraulic",
        [38] = "Engine Cover",
        [39] = "Air Filter",
        [40] = "Struts",
        [41] = "Arch Cover",
        [42] = "Aerials",
        [43] = "Rims",
        [44] = "Side Mirror",
        [45] = "Tail Pipe",
        [46] = "Bonnet Pins",
        [47] = "Hydrolic",
        [48] = "Livery",
    },
}
