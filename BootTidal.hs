:set -fno-warn-orphans -Wno-type-defaults -XMultiParamTypeClasses -XOverloadedStrings
:set prompt ""

-- Import all the boot functions and aliases.
import Sound.Tidal.Boot

default (Rational, Integer, Double, Pattern String)

:{
let target = Target {   oName = "visualiser",   -- A friendly name for the target (only used in error messages)
						oAddress = "127.0.0.1", -- The target's network address, normally "localhost"
                        oPort = 7002,           -- The network port the target is listening on
                        oLatency = 0.2,         -- Additional delay, to smooth out network jitter/get things in sync
                        oSchedule = Live,       -- The scheduling method - see below
                        oWindow = Nothing,      -- Not yet used
                        oHandshake = False,     -- SuperDirt specific
                        oBusPort = Nothing      -- Also SuperDirt specific
                    }
    oscplay = OSC "/{oscName}" $ ArgList [("oscF", Just $ VF 0.0), ("oscS", Just $ VS ""), ("oscI", Just $ VI 0)] -- setting defaults as otherwise need to include all in patterns
    oscName = pS "oscName"
    oscF = pF "oscF" -- float values
    oscS = pS "oscS" -- string values
    oscI = pI "oscI" -- int values
    oscmap = (target, [oscplay])
:}

-- Create a Tidal Stream with the default settings.
-- To customize these settings, use 'mkTidalWith' instead
-- tidalInst <- mkTidal

tidalInst <- mkTidalWith [(superdirtTarget { oLatency = 0.01 }, [superdirtShape]), oscmap] (defaultConfig)

-- This orphan instance makes the boot aliases work!
-- It has to go after you define 'tidalInst'.
instance Tidally where tidal = tidalInst

-- `enableLink` and `disableLink` can be used to toggle synchronisation using the Link protocol.
-- Uncomment the next line to enable Link on startup.
-- enableLink

-- You can also add your own aliases in this file. For example:
-- fastsquizzed pat = fast 2 $ pat # squiz 1.5

:set prompt "tidal> "
:set prompt-cont ""
