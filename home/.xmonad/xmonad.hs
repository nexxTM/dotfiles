import XMonad
import XMonad.Config.Gnome
import XMonad.Actions.CycleWS

import Data.Monoid
import System.Exit

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

main = do
    xmonad $ gnomeConfig { keys = myKeys <+> keys gnomeConfig
                         , manageHook = myManageHook <+> manageHook gnomeConfig
                         , modMask = mod4Mask }

myManageHook = composeAll . concat $
   [ [(className =? "Firefox" <&&> resource =? "Navigator") --> doShift "web" ]
   , [(className =? "Firefox" <&&> (resource =? "Dialog" <||>
                                    resource =? "Toolkit" <||>
                                    resource =? "Browser")) --> doFloat]
   , [(className =? "Update-manager" <&&> resource =? "update-manager") --> doFloat]
   ]

-- nicer keybindings on NEO2
-- influenced by http://web.ist.utl.pt/rtra/comp/usability/colemak/keybindings/xmonad/
myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $

    -- launch a terminal
    [ ((modMask .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modMask,               xK_h     ), spawn "dmenu_run")

    -- launch gmrun
    , ((modMask .|. shiftMask, xK_h     ), spawn "gmrun")

    -- close focused window
    , ((modMask .|. shiftMask, xK_s     ), kill)

     -- Rotate through the available layout algorithms
    , ((modMask,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modMask .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modMask,               xK_ssharp ), refresh)

    -- Move focus to the next window
    , ((modMask,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modMask,               xK_r     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modMask,               xK_n     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modMask,               xK_t     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modMask .|. shiftMask, xK_t     ), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modMask .|. shiftMask, xK_r     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modMask .|. shiftMask, xK_n     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modMask .|. shiftMask, xK_f     ), sendMessage Shrink)

    -- Expand the master area
    , ((modMask,               xK_f     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modMask,               xK_d), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modMask              , xK_g     ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modMask .|. shiftMask, xK_g     ), sendMessage (IncMasterN (-1)))
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_b, xK_m, xK_comma] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++

     -- CycleWS setup
    [ ((modMask,               xK_j),      moveTo Next NonEmptyWS)
    , ((modMask,               xK_period), moveTo Prev NonEmptyWS)
    , ((modMask .|. shiftMask, xK_j),      shiftToNext)
    , ((modMask .|. shiftMask, xK_period), shiftToPrev)
    , ((modMask,               xK_Right),  nextScreen)
    , ((modMask,               xK_Left),   prevScreen)
    , ((modMask .|. shiftMask, xK_Right),  shiftNextScreen)
    , ((modMask .|. shiftMask, xK_Left),   shiftPrevScreen)
    , ((modMask,               xK_y),      toggleWS)
    , ((modMask,               xK_k),      moveTo Next EmptyWS)  -- find a free workspace
    , ((modMask .|. shiftMask, xK_k),      shiftTo Next EmptyWS)
    ]
