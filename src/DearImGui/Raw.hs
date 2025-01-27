{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PatternSynonyms #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}

{-|
Module: DearImGui

Main ImGui module, exporting the functions to create a GUI.
-}

module DearImGui.Raw
  ( -- * Context Creation and Access
    Context(..)
  , createContext
  , destroyContext

    -- * Main
  , newFrame
  , endFrame
  , render
  , DrawData(..)
  , getDrawData
  , checkVersion

    -- * Demo, Debug, Information
  , showDemoWindow
  , showMetricsWindow
  , showAboutWindow
  , showUserGuide
  , getVersion

    -- * Styles
  , styleColorsDark
  , styleColorsLight
  , styleColorsClassic

  , scaleAllSizes
  , Font
  , addFontFromFileTTF
  , pushFont
  , popFont
  , setFontGlobalScale

    -- * Windows
  , begin
  , end
  , setNextWindowPos
  , setNextWindowSize
  , setNextWindowContentSize
  , setNextWindowSizeConstraints
  , setNextWindowCollapsed
  , setNextWindowBgAlpha

    -- * Child Windows
  , beginChild
  , endChild

    -- * Parameter stacks
  , pushStyleColor
  , popStyleColor
  , pushStyleVar
  , popStyleVar

    -- * Cursor/Layout
  , separator
  , sameLine
  , newLine
  , spacing
  , dummy
  , indent
  , unindent
  , setNextItemWidth
  , pushItemWidth
  , popItemWidth
  , beginGroup
  , endGroup
  , setCursorPos
  , alignTextToFramePadding

    -- * Widgets
    -- ** Text
  , text
  , textWrapped
  , textUnformatted

    -- ** Main
  , button
  , smallButton
  , arrowButton
  , checkbox
  , progressBar
  , bullet

    -- ** Combo Box
  , beginCombo
  , endCombo
  , combo

    -- ** Drag Sliders
  , dragFloat
  , dragFloat2
  , dragFloat3
  , dragFloat4

    -- ** Slider
  , sliderFloat
  , sliderFloat2
  , sliderFloat3
  , sliderFloat4

    -- ** Text Input
  , inputText
  , inputTextEnterReturnsTrue

    -- * Color Editor/Picker
  , colorPicker3
  , colorButton

    -- * Trees
  , treeNode
  , treePush
  , treePop

    -- ** Selectables
  , selectable

    -- ** List Boxes
  , listBox

    -- * Data Plotting
  , plotHistogram

    -- ** Menus
  , beginMenuBar
  , endMenuBar
  , beginMainMenuBar
  , endMainMenuBar
  , beginMenu
  , endMenu
  , menuItem

    -- ** Tabs, tab bar
  , beginTabBar
  , endTabBar
  , beginTabItem
  , endTabItem
  , tabItemButton
  , setTabItemClosed

    -- * Tooltips
  , beginTooltip
  , endTooltip

    -- * Popups/Modals
  , beginPopup
  , beginPopupModal
  , endPopup
  , openPopup
  , closeCurrentPopup

    -- * Item/Widgets Utilities
  , isItemHovered

  , setScrollHereY

    -- * Types
  , module DearImGui.Enums
  , module DearImGui.Structs
  )
  where

-- base
import Control.Monad.IO.Class
  ( MonadIO, liftIO )
import Foreign
import Foreign.C

-- dear-imgui
import DearImGui.Context
  ( imguiContext )
import DearImGui.Enums
import DearImGui.Structs

-- inline-c
import qualified Language.C.Inline as C

-- inline-c-cpp
import qualified Language.C.Inline.Cpp as Cpp

C.context (Cpp.cppCtx <> C.bsCtx <> imguiContext)
C.include "imgui.h"
Cpp.using "namespace ImGui"


-- | Wraps @ImGuiContext*@.
newtype Context = Context (Ptr ())

-- | Wraps @ImFont*@.
newtype Font = Font (Ptr ())


-- | Wraps @ImGui::CreateContext()@.
createContext :: (MonadIO m) => m Context
createContext = liftIO do
  Context <$> [C.exp| void* { CreateContext() } |]


-- | Wraps @ImGui::DestroyContext()@.
destroyContext :: (MonadIO m) => Context -> m ()
destroyContext (Context contextPtr) = liftIO do
  [C.exp| void { DestroyContext((ImGuiContext*)$(void* contextPtr)); } |]


-- | Start a new Dear ImGui frame, you can submit any command from this point
-- until 'render'/'endFrame'.
--
-- Wraps @ImGui::NewFrame()@.
newFrame :: (MonadIO m) => m ()
newFrame = liftIO do
  [C.exp| void { NewFrame(); } |]


-- | Ends the Dear ImGui frame. automatically called by 'render'. If you don't
-- need to render data (skipping rendering) you may call 'endFrame' without
-- 'render'... but you'll have wasted CPU already! If you don't need to render,
-- better to not create any windows and not call 'newFrame' at all!
endFrame :: (MonadIO m) => m ()
endFrame = liftIO do
  [C.exp| void { EndFrame(); } |]


-- | Ends the Dear ImGui frame, finalize the draw data. You can then get call
-- 'getDrawData'.
render :: (MonadIO m) => m ()
render = liftIO do
  [C.exp| void { Render(); } |]


-- | Wraps @ImDrawData*@.
newtype DrawData = DrawData (Ptr ())


-- | Valid after 'render' and until the next call to 'newFrame'. This is what
-- you have to render.
getDrawData :: (MonadIO m) => m DrawData
getDrawData = liftIO do
  DrawData <$> [C.exp| void* { GetDrawData() } |]


-- | Wraps @IMGUI_CHECKVERSION()@
checkVersion :: (MonadIO m) => m ()
checkVersion = liftIO do
  [C.exp| void { IMGUI_CHECKVERSION(); } |]


-- | Create demo window. Demonstrate most ImGui features. Call this to learn
-- about the library! Try to make it always available in your application!
showDemoWindow :: (MonadIO m) => m ()
showDemoWindow = liftIO do
  [C.exp| void { ShowDemoWindow(); } |]


-- | Create Metrics/Debugger window. Display Dear ImGui internals: windows, draw
-- commands, various internal state, etc.
showMetricsWindow :: (MonadIO m) => m ()
showMetricsWindow = liftIO do
  [C.exp| void { ShowMetricsWindow(); } |]


-- | Create About window. display Dear ImGui version, credits and build/system
-- information.
showAboutWindow :: (MonadIO m) => m ()
showAboutWindow = liftIO do
  [C.exp| void { ShowAboutWindow(); } |]


-- | Add basic help/info block (not a window): how to manipulate ImGui as a
-- end-user (mouse/keyboard controls).
showUserGuide :: (MonadIO m) => m ()
showUserGuide = liftIO do
  [C.exp| void { ShowUserGuide() } |]


-- | Get the compiled version string e.g. "1.80 WIP" (essentially the value for
-- @IMGUI_VERSION@ from the compiled version of @imgui.cpp@).
getVersion :: (MonadIO m) => m CString
getVersion = liftIO do
  [C.exp| const char* { GetVersion() } |]


-- | New, recommended style (default).
--
-- Wraps @ImGui::StyleColorsDark()@.
styleColorsDark :: (MonadIO m) => m ()
styleColorsDark = liftIO do
  [C.exp| void { StyleColorsDark(); } |]


-- | Best used with borders and a custom, thicker font.
--
-- Wraps @ImGui::StyleColorsLight()@.
styleColorsLight :: (MonadIO m) => m ()
styleColorsLight = liftIO do
  [C.exp| void { StyleColorsLight(); } |]


-- | Classic ImGui style.
--
-- Wraps @ImGui::StyleColorsClasic()@.
styleColorsClassic :: (MonadIO m) => m ()
styleColorsClassic = liftIO do
  [C.exp| void { StyleColorsClassic(); } |]


scaleAllSizes :: (MonadIO m) => Float -> m ()
scaleAllSizes factor_ = liftIO do
  let factor = CFloat factor_
  [C.exp| void { GetStyle().ScaleAllSizes($(float factor)); } |]

addFontFromFileTTF :: (MonadIO m) => CString -> Float -> m Font
addFontFromFileTTF path sizePixels_ = liftIO do
  let sizePixels = CFloat sizePixels_
  Font <$> [C.exp| void* { GetIO().Fonts->AddFontFromFileTTF($(char* path), $(float sizePixels)) }|]

setFontGlobalScale :: (MonadIO m) => Float -> m ()
setFontGlobalScale scale_ = liftIO do
  let scale = CFloat scale_
  [C.exp| void { GetIO().FontGlobalScale = $(float scale); } |]

pushFont :: (MonadIO m) => Font -> m ()
pushFont (Font font) = liftIO do
  [C.exp| void { PushFont((ImFont*) $(void* font)); } |]

popFont :: (MonadIO m) => m ()
popFont = liftIO do
  [C.exp| void { PopFont(); }|]

-- | Push window to the stack and start appending to it.
--
-- Returns 'False' to indicate the window is collapsed or fully clipped, so you
-- may early out and omit submitting anything to the window. Always call a
-- matching 'end' for each 'begin' call, regardless of its return value!
--
-- Wraps @ImGui::Begin()@.
begin :: (MonadIO m) => CString -> m Bool
begin namePtr = liftIO do
  (0 /=) <$> [C.exp| bool { Begin($(char* namePtr)) } |]


-- | Pop window from the stack.
--
-- Wraps @ImGui::End()@.
end :: (MonadIO m) => m ()
end = liftIO do
  [C.exp| void { End(); } |]


-- | Wraps @ImGui::BeginChild()@.
beginChild :: (MonadIO m) => CString -> m Bool
beginChild namePtr = liftIO do
  (0 /=) <$> [C.exp| bool { BeginChild($(char* namePtr)) } |]


-- | Wraps @ImGui::EndChild()@.
endChild :: (MonadIO m) => m ()
endChild = liftIO do
  [C.exp| void { EndChild(); } |]


-- | Separator, generally horizontal. inside a menu bar or in horizontal layout
-- mode, this becomes a vertical separator.
--
-- Wraps @ImGui::Separator()@
separator :: (MonadIO m) => m ()
separator = liftIO do
  [C.exp| void { Separator(); } |]


-- | Call between widgets or groups to layout them horizontally.
--
-- Wraps @ImGui::SameLine@.
sameLine :: (MonadIO m) => m ()
sameLine = liftIO do
  [C.exp| void { SameLine(); } |]


-- | Formatted text.
--
-- Wraps @ImGui::Text()@.
text :: (MonadIO m) => CString -> m ()
text textPtr = liftIO do
  [C.exp| void { Text("%s", $(char* textPtr)) } |]

-- | Formatted text.
--
-- Wraps @ImGui::TextWrapped()@.
textWrapped :: (MonadIO m) => CString -> m ()
textWrapped textPtr = liftIO do
  [C.exp| void { TextWrapped("%s", $(char* textPtr)) } |]

-- | Unformatted text.
--
-- Wraps @ImGui::TextUnformatted()@.
textUnformatted :: (MonadIO m) => CStringLen -> m ()
textUnformatted (textPtr, textLen) = liftIO do
  let textEnd = plusPtr textPtr textLen
  [C.exp| void { TextUnformatted($(char* textPtr), $(char* textEnd)) } |]

-- | A button. Returns 'True' when clicked.
--
-- Wraps @ImGui::Button()@.
button :: (MonadIO m) => CString -> m Bool
button labelPtr = liftIO do
  (0 /=) <$> [C.exp| bool { Button($(char* labelPtr)) } |]


-- | Button with @FramePadding=(0,0)@ to easily embed within text.
--
-- Wraps @ImGui::SmallButton()@.
smallButton :: (MonadIO m) => CString -> m Bool
smallButton labelPtr = liftIO do
  (0 /=) <$> [C.exp| bool { SmallButton($(char* labelPtr)) } |]


-- | Square button with an arrow shape.
--
-- Wraps @ImGui::ArrowButton()@.
arrowButton :: (MonadIO m) => CString -> ImGuiDir -> m Bool
arrowButton strIdPtr dir = liftIO do
  (0 /=) <$> [C.exp| bool { ArrowButton($(char* strIdPtr), $(ImGuiDir dir)) } |]


-- | Wraps @ImGui::Checkbox()@.
checkbox :: (MonadIO m) => CString -> Ptr CBool -> m Bool
checkbox labelPtr boolPtr = liftIO do
  (0 /=) <$> [C.exp| bool { Checkbox($(char* labelPtr), $(bool* boolPtr)) } |]


-- TODO: publish ImVec2(-FLT_MIN, 0)
-- | Wraps @ImGui::ProgressBar()@.
progressBar :: (MonadIO m) => CFloat -> CString -> m ()
progressBar progress overlayPtr = liftIO do
    [C.exp| void { ProgressBar($(float progress), ImVec2(-FLT_MIN, 0), $(char* overlayPtr)) } |]


-- | Draw a small circle + keep the cursor on the same line. Advance cursor x
-- position by 'getTreeNodeToLabelSpacing', same distance that 'treeNode' uses.
bullet :: (MonadIO m) => m ()
bullet = liftIO do
  [C.exp| void { Bullet() } |]


-- | Begin creating a combo box with a given label and preview value.
--
-- Returns 'True' if the combo box is open. In this state, you should populate
-- the contents of the combo box - for example, by calling 'selectable'.
--
-- Wraps @ImGui::BeginCombo()@.
beginCombo :: (MonadIO m) => CString -> CString -> m Bool
beginCombo labelPtr previewValuePtr = liftIO do
  (0 /=) <$> [C.exp| bool { BeginCombo($(char* labelPtr), $(char* previewValuePtr)) } |]


-- | Only call 'endCombo' if 'beginCombo' returns 'True'!
--
-- Wraps @ImGui::EndCombo()@.
endCombo :: (MonadIO m) => m ()
endCombo = liftIO do
  [C.exp| void { EndCombo() } |]


-- | Wraps @ImGui::Combo()@.
combo :: (MonadIO m) => CString -> Ptr CInt -> Ptr CString -> CInt -> m Bool
combo labelPtr iPtr itemsPtr itemsLen = liftIO do
  (0 /=) <$> [C.exp| bool { Combo($(char* labelPtr), $(int* iPtr), $(char** itemsPtr), $(int itemsLen)) }|]


-- | Wraps @ImGui::DragFloat()@
dragFloat :: (MonadIO m) => CString -> Ptr CFloat -> CFloat -> CFloat -> CFloat -> m Bool
dragFloat descPtr floatPtr speed minValue maxValue = liftIO do
  (0 /=) <$> [C.exp| bool { DragFloat( $(char* descPtr), $(float* floatPtr), $(float speed), $(float minValue), $(float maxValue)) } |]


-- | Wraps @ImGui::DragFloat2()@
dragFloat2 :: (MonadIO m) => CString -> Ptr CFloat -> CFloat -> CFloat -> CFloat -> m Bool
dragFloat2 descPtr floatPtr speed minValue maxValue = liftIO do
  (0 /=) <$> [C.exp| bool { DragFloat2( $(char* descPtr), $(float* floatPtr), $(float speed), $(float minValue), $(float maxValue)) } |]


-- | Wraps @ImGui::DragFloat3()@
dragFloat3 :: (MonadIO m) => CString -> Ptr CFloat -> CFloat -> CFloat -> CFloat -> m Bool
dragFloat3 descPtr floatPtr speed minValue maxValue = liftIO do
  (0 /=) <$> [C.exp| bool { DragFloat3( $(char* descPtr), $(float* floatPtr), $(float speed), $(float minValue), $(float maxValue)) } |]


-- | Wraps @ImGui::DragFloat4()@
dragFloat4 :: (MonadIO m) => CString -> Ptr CFloat -> CFloat -> CFloat -> CFloat -> m Bool
dragFloat4 descPtr floatPtr speed minValue maxValue = liftIO do
  (0 /=) <$> [C.exp| bool { DragFloat4( $(char* descPtr), $(float* floatPtr), $(float speed), $(float minValue), $(float maxValue)) } |]


-- | Wraps @ImGui::SliderFloat()@
sliderFloat :: (MonadIO m) => CString -> Ptr CFloat -> CFloat -> CFloat -> m Bool
sliderFloat descPtr floatPtr minValue maxValue = liftIO do
  (0 /=) <$> [C.exp| bool { SliderFloat( $(char* descPtr), $(float* floatPtr), $(float minValue), $(float maxValue)) } |]


-- | Wraps @ImGui::SliderFloat2()@
sliderFloat2 :: (MonadIO m) => CString -> Ptr CFloat -> CFloat -> CFloat -> m Bool
sliderFloat2 descPtr floatPtr minValue maxValue = liftIO do
  (0 /=) <$> [C.exp| bool { SliderFloat2( $(char* descPtr), $(float* floatPtr), $(float minValue), $(float maxValue)) } |]


-- | Wraps @ImGui::SliderFloat3()@
sliderFloat3 :: (MonadIO m) => CString -> Ptr CFloat -> CFloat -> CFloat -> m Bool
sliderFloat3 descPtr floatPtr minValue maxValue = liftIO do
  (0 /=) <$> [C.exp| bool { SliderFloat3( $(char* descPtr), $(float* floatPtr), $(float minValue), $(float maxValue)) } |]


-- | Wraps @ImGui::SliderFloat4()@
sliderFloat4 :: (MonadIO m) => CString -> Ptr CFloat -> CFloat -> CFloat -> m Bool
sliderFloat4 descPtr floatPtr minValue maxValue = liftIO do
  (0 /=) <$> [C.exp| bool { SliderFloat4( $(char* descPtr), $(float* floatPtr), $(float minValue), $(float maxValue)) } |]


-- | Wraps @ImGui::InputText()@.
inputText :: (MonadIO m) => CString -> CString -> CInt -> m Bool
inputText descPtr refPtr refSize = liftIO do
  (0 /= ) <$> [C.exp| bool { InputText( $(char* descPtr), $(char* refPtr), $(int refSize) ) } |]

-- | Wraps @ImGui::InputText()@.
inputTextEnterReturnsTrue :: (MonadIO m) => CString -> CString -> CInt -> m Bool
inputTextEnterReturnsTrue descPtr refPtr refSize = liftIO do
  (0 /= ) <$> [C.exp| bool { InputText( $(char* descPtr), $(char* refPtr), $(int refSize), ImGuiInputTextFlags_EnterReturnsTrue ) } |]

-- | Wraps @ImGui::ColorPicker3()@.
colorPicker3 :: (MonadIO m) => CString -> Ptr CFloat -> m Bool
colorPicker3 descPtr refPtr = liftIO do
  (0 /= ) <$> [C.exp| bool { ColorPicker3( $(char* descPtr), $(float* refPtr) ) } |]


-- | Display a color square/button, hover for details, return true when pressed.
--
-- Wraps @ImGui::ColorButton()@.
colorButton :: (MonadIO m) => CString -> Ptr ImVec4 -> m Bool
colorButton descPtr refPtr = liftIO do
  (0 /=) <$> [C.exp| bool { ColorButton( $(char* descPtr), *$(ImVec4* refPtr) ) } |]


-- | Wraps @ImGui::TreeNode()@.
treeNode :: (MonadIO m) => CString -> m Bool
treeNode labelPtr = liftIO do
  (0 /=) <$> [C.exp| bool { TreeNode($(char* labelPtr)) } |]


-- | Wraps @ImGui::TreePush()@.
treePush :: (MonadIO m) => CString -> m ()
treePush labelPtr = liftIO do
  [C.exp| void { TreePush($(char* labelPtr)) } |]


-- | Wraps @ImGui::TreePop()@.
treePop :: (MonadIO m) => m ()
treePop = liftIO do
  [C.exp| void { TreePop() } |]


-- | Wraps @ImGui::Selectable()@.
selectable :: (MonadIO m) => CString -> m Bool
selectable labelPtr = liftIO do
  (0 /=) <$> [C.exp| bool { Selectable($(char* labelPtr)) } |]


-- | Wraps @ImGui::ListBox()@.
listBox :: (MonadIO m) => CString -> Ptr CInt -> Ptr CString -> CInt -> m Bool
listBox labelPtr iPtr itemsPtr itemsLen = liftIO do
  (0 /=) <$> [C.exp| bool { ListBox($(char* labelPtr), $(int* iPtr), $(char** itemsPtr), $(int itemsLen)) }|]


-- | Wraps @ImGui::PlotHistogram()@.
plotHistogram :: (MonadIO m) => CString -> Ptr CFloat -> CInt -> m ()
plotHistogram labelPtr valuesPtr valuesLen = liftIO do
  [C.exp| void { PlotHistogram($(char* labelPtr), $(float* valuesPtr), $(int valuesLen)) } |]


-- | Append to menu-bar of current window (requires 'ImGuiWindowFlagsMenuBar'
-- flag set on parent window).
--
-- Wraps @ImGui::BeginMenuBar()@.
beginMenuBar :: (MonadIO m) => m Bool
beginMenuBar = liftIO do
  (0 /=) <$> [C.exp| bool { BeginMenuBar() } |]


-- | Only call 'endMenuBar' if 'beginMenuBar' returns true!
--
-- Wraps @ImGui::EndMenuBar()@.
endMenuBar :: (MonadIO m) => m ()
endMenuBar = liftIO do
  [C.exp| void { EndMenuBar(); } |]


-- | Create and append to a full screen menu-bar.
--
-- Wraps @ImGui::BeginMainMenuBar()@.
beginMainMenuBar :: (MonadIO m) => m Bool
beginMainMenuBar = liftIO do
  (0 /=) <$> [C.exp| bool { BeginMainMenuBar() } |]


-- | Only call 'endMainMenuBar' if 'beginMainMenuBar' returns true!
--
-- Wraps @ImGui::EndMainMenuBar()@.
endMainMenuBar :: (MonadIO m) => m ()
endMainMenuBar = liftIO do
  [C.exp| void { EndMainMenuBar(); } |]


-- | Create a sub-menu entry.
--
-- Wraps @ImGui::BeginMenu()@.
beginMenu :: (MonadIO m) => CString -> m Bool
beginMenu labelPtr = liftIO do
  (0 /=) <$> [C.exp| bool { BeginMenu($(char* labelPtr)) } |]


-- | Only call 'endMenu' if 'beginMenu' returns true!
--
-- Wraps @ImGui::EndMenu()@.
endMenu :: (MonadIO m) => m ()
endMenu = liftIO do
  [C.exp| void { EndMenu(); } |]


-- | Return true when activated. Shortcuts are displayed for convenience but not
-- processed by ImGui at the moment
--
-- Wraps @ImGui::MenuItem()@
menuItem :: (MonadIO m) => CString -> m Bool
menuItem labelPtr = liftIO do
  (0 /=) <$> [C.exp| bool { MenuItem($(char* labelPtr)) } |]


-- | Create a @TabBar@ and start appending to it.
--
-- Wraps @ImGui::BeginTabBar@.
beginTabBar :: (MonadIO m) => CString -> ImGuiTabBarFlags -> m Bool
beginTabBar tabBarID flags = liftIO do
  (0 /=) <$> [C.exp| bool { BeginTabBar($(char* tabBarID), $(ImGuiTabBarFlags flags) ) } |]


-- | Finish appending elements to a tab bar. Only call if 'beginTabBar' returns @True@.
--
-- Wraps @ImGui::EndTabBar@.
endTabBar :: (MonadIO m) => m ()
endTabBar = liftIO do
  [C.exp| void { EndTabBar(); } |]


-- | Create a new tab. Returns @True@ if the tab is selected.
--
-- Wraps @ImGui::BeginTabItem@.
beginTabItem :: (MonadIO m) => CString -> Ptr CBool -> ImGuiTabBarFlags -> m Bool
beginTabItem namePtr refPtr flags = liftIO do
  (0 /=) <$> [C.exp| bool { BeginTabItem($(char* namePtr), $(bool* refPtr), $(ImGuiTabBarFlags flags) ) } |]


-- | Finish appending elements to a tab. Only call if 'beginTabItem' returns @True@.
--
-- Wraps @ImGui::EndTabItem@.
endTabItem :: (MonadIO m) => m ()
endTabItem = liftIO do
  [C.exp| void { EndTabItem(); } |]


-- | Create a tab that behaves like a button. Returns @True@ when clicked. Cannot be selected in the tab bar.
--
-- Wraps @ImGui.TabItemButton@.
tabItemButton :: (MonadIO m) => CString -> ImGuiTabItemFlags -> m Bool
tabItemButton namePtr flags = liftIO do
  (0 /=) <$> [C.exp| bool { TabItemButton($(char* namePtr), $(ImGuiTabItemFlags flags) ) } |]


-- | Notify the tab bar (or the docking system) that a tab/window is about to close.
-- Useful to reduce visual flicker on reorderable tab bars.
--
-- __For tab-bar__: call after 'beginTabBar' and before tab submission. Otherwise, call with a window name.
setTabItemClosed :: (MonadIO m) => CString -> m ()
setTabItemClosed namePtr = liftIO do
  [C.exp| void { SetTabItemClosed($(char* namePtr)); } |]


-- | Begin/append a tooltip window to create full-featured tooltip (with any
-- kind of items).
--
-- Wraps @ImGui::BeginTooltip()@
beginTooltip :: (MonadIO m) => m ()
beginTooltip = liftIO do
  [C.exp| void { BeginTooltip() } |]


-- | Wraps @ImGui::EndTooltip()@
endTooltip :: (MonadIO m) => m ()
endTooltip = liftIO do
  [C.exp| void { EndTooltip() } |]


-- | Returns 'True' if the popup is open, and you can start outputting to it.
--
-- Wraps @ImGui::BeginPopup()@
beginPopup :: (MonadIO m) => CString -> m Bool
beginPopup popupIdPtr = liftIO do
  (0 /=) <$> [C.exp| bool { BeginPopup($(char* popupIdPtr)) } |]


-- | Returns 'True' if the modal is open, and you can start outputting to it.
--
-- Wraps @ImGui::BeginPopupModal()@
beginPopupModal :: (MonadIO m) => CString -> m Bool
beginPopupModal popupIdPtr = liftIO do
  (0 /=) <$> [C.exp| bool { BeginPopupModal($(char* popupIdPtr)) } |]


-- | Only call 'endPopup' if 'beginPopup' or 'beginPopupModal' returns 'True'!
--
-- Wraps @ImGui::BeginPopupModal()@
endPopup :: (MonadIO m) => m ()
endPopup = liftIO do
  [C.exp| void { EndPopup() } |]


-- | Call to mark popup as open (don't call every frame!).
--
-- Wraps @ImGui::OpenPopup()@
openPopup :: (MonadIO m) => CString -> m ()
openPopup popupIdPtr = liftIO do
  [C.exp| void { OpenPopup($(char* popupIdPtr)) } |]


-- | Manually close the popup we have begin-ed into.
--
-- Wraps @ImGui::ClosePopup()@
closeCurrentPopup :: (MonadIO m) => m ()
closeCurrentPopup = liftIO do
  [C.exp| void { CloseCurrentPopup() } |]


-- | Is the last item hovered? (and usable, aka not blocked by a popup, etc.).
--
-- Wraps @ImGui::IsItemHovered()@
isItemHovered :: (MonadIO m) => m Bool
isItemHovered = liftIO do
  (0 /=) <$> [C.exp| bool { IsItemHovered() } |]


-- | Set next window position. Call before `begin` Use pivot=(0.5,0.5) to center on given point, etc.
--
-- Wraps @ImGui::SetNextWindowPos()@
setNextWindowPos :: (MonadIO m) => Ptr ImVec2 -> ImGuiCond -> Ptr ImVec2 -> m ()
setNextWindowPos posPtr cond pivotPtr = liftIO do
  [C.exp| void { SetNextWindowPos(*$(ImVec2* posPtr), $(ImGuiCond cond), *$(ImVec2* pivotPtr)) } |]


-- | Set next window size. Call before `begin`
--
-- Wraps @ImGui::SetNextWindowSize()@
setNextWindowSize :: (MonadIO m) => Ptr ImVec2 -> ImGuiCond -> m ()
setNextWindowSize sizePtr cond = liftIO do
  [C.exp| void { SetNextWindowSize(*$(ImVec2* sizePtr), $(ImGuiCond cond)) } |]


-- | Set next window content size (~ scrollable client area, which enforce the range of scrollbars). Not including window decorations (title bar, menu bar, etc.) nor WindowPadding. call before `begin`
--
-- Wraps @ImGui::SetNextWindowContentSize()@
setNextWindowContentSize :: (MonadIO m) => Ptr ImVec2 -> m ()
setNextWindowContentSize sizePtr = liftIO do
  [C.exp| void { SetNextWindowContentSize(*$(ImVec2* sizePtr)) } |]


-- | Set next window size limits. use -1,-1 on either X/Y axis to preserve the current size. Sizes will be rounded down.
--
-- Wraps @ImGui::SetNextWindowContentSize()@
setNextWindowSizeConstraints :: (MonadIO m) => Ptr ImVec2 -> Ptr ImVec2 -> m ()
setNextWindowSizeConstraints sizeMinPtr sizeMaxPtr = liftIO do
  [C.exp| void { SetNextWindowSizeConstraints(*$(ImVec2* sizeMinPtr), *$(ImVec2* sizeMaxPtr)) } |]


-- | Set next window collapsed state. call before `begin`
--
-- Wraps @ImGui::SetNextWindowCollapsed()@
setNextWindowCollapsed :: (MonadIO m) => CBool -> ImGuiCond -> m ()
setNextWindowCollapsed b cond = liftIO do
  [C.exp| void { SetNextWindowCollapsed($(bool b), $(ImGuiCond cond)) } |]


-- | Set next window background color alpha. helper to easily override the Alpha component of `ImGuiCol_WindowBg`, `ChildBg`, `PopupBg`. you may also use `ImGuiWindowFlags_NoBackground`.
--
-- Wraps @ImGui::SetNextWindowBgAlpha()@
setNextWindowBgAlpha :: (MonadIO m) => CFloat -> m ()
setNextWindowBgAlpha alpha = liftIO do
  [C.exp| void { SetNextWindowBgAlpha($(float alpha)) } |]


-- | undo a sameLine or force a new line when in an horizontal-layout context.
--
-- Wraps @ImGui::NewLine()@
newLine :: (MonadIO m) => m ()
newLine = liftIO do
  [C.exp| void { NewLine() } |]


-- | Add vertical spacing.
--
-- Wraps @ImGui::Spacing()@
spacing :: (MonadIO m) => m ()
spacing = liftIO do
  [C.exp| void { Spacing() } |]


-- | Add a dummy item of given size. unlike `invisibleButton`, `dummy` won't take the mouse click or be navigable into.
--
-- Wraps @ImGui::Dummy()@
dummy :: (MonadIO m) => Ptr ImVec2 -> m ()
dummy sizePtr = liftIO do
  [C.exp| void { Dummy(*$(ImVec2* sizePtr)) } |]


-- | Move content position toward the right, by indent_w, or style.IndentSpacing if indent_w <= 0
--
-- Wraps @ImGui::Indent()@
indent :: (MonadIO m) => CFloat -> m ()
indent indent_w = liftIO do
  [C.exp| void { Indent($(float indent_w)) } |]


-- | Move content position back to the left, by indent_w, or style.IndentSpacing if indent_w <= 0
--
-- Wraps @ImGui::Unindent()@
unindent :: (MonadIO m) => CFloat -> m ()
unindent indent_w = liftIO do
  [C.exp| void { Unindent($(float indent_w)) } |]


-- | Affect large frame+labels widgets only.
--
-- Wraps @ImGui::SetNextItemWidth()@
setNextItemWidth :: (MonadIO m) => CFloat -> m ()
setNextItemWidth itemWidth = liftIO do
  [C.exp| void { SetNextItemWidth($(float itemWidth)) } |]


-- Wraps @ImGui::PushItemWidth()@
pushItemWidth :: (MonadIO m) => CFloat -> m ()
pushItemWidth itemWidth = liftIO do
  [C.exp| void { PushItemWidth($(float itemWidth)) } |]


-- Wraps @ImGui::PopItemWidth()@
popItemWidth :: (MonadIO m) => m ()
popItemWidth = liftIO do
  [C.exp| void { PopItemWidth() } |]


-- | lock horizontal starting position
--
--  Wraps @ImGui::BeginGroup()@
beginGroup :: (MonadIO m) => m ()
beginGroup = liftIO do
  [C.exp| void { BeginGroup() } |]


-- | unlock horizontal starting position + capture the whole group bounding box into one "item" (so you can use `isItemHovered` or layout primitives such as `sameLine` on whole group, etc.)
--
-- Wraps @ImGui::EndGroup()@
endGroup :: (MonadIO m) => m ()
endGroup = liftIO do
  [C.exp| void { EndGroup() } |]


-- | Vertically align upcoming text baseline to FramePadding.y so that it will align properly to regularly framed items (call if you have text on a line before a framed item)
--
-- Wraps @ImGui::AlignTextToFramePadding()@
alignTextToFramePadding :: (MonadIO m) => m ()
alignTextToFramePadding = liftIO do
  [C.exp| void { AlignTextToFramePadding() } |]


-- | Set cursor position in window-local coordinates
--
-- Wraps @ImGui::SetCursorPos()@
setCursorPos :: (MonadIO m) => Ptr ImVec2 -> m ()
setCursorPos posPtr = liftIO do
  [C.exp| void { SetCursorPos(*$(ImVec2* posPtr)) } |]


-- | Modify a style color by pushing to the shared stack. always use this if you modify the style after `newFrame`
--
-- Wraps @ImGui::PushStyleColor()@
pushStyleColor :: (MonadIO m) => ImGuiCol -> Ptr ImVec4 -> m ()
pushStyleColor col colorPtr = liftIO do
  [C.exp| void { PushStyleColor($(ImGuiCol col), *$(ImVec4 *colorPtr)) } |]


-- | Remove style color modifications from the shared stack
--
-- Wraps @ImGui::PopStyleColor()@
popStyleColor :: (MonadIO m) => CInt -> m ()
popStyleColor n = liftIO do
  [C.exp| void { PopStyleColor($(int n)) } |]


-- | Modify a style variable by pushing to the shared stack. always use this if you modify the style after `newFrame`
--
-- Wraps @ImGui::PushStyleVar()@
pushStyleVar :: (MonadIO m) => ImGuiStyleVar -> Ptr ImVec2 -> m ()
pushStyleVar style valPtr = liftIO do
  [C.exp| void { PushStyleVar($(ImGuiStyleVar style), *$(ImVec2* valPtr)) } |]


-- | Remove style variable modifications from the shared stack
--
-- Wraps @ImGui::PopStyleVar()@
popStyleVar :: (MonadIO m) => CInt -> m ()
popStyleVar n = liftIO do
  [C.exp| void { PopStyleVar($(int n)) } |]


-- SetScrollHereY
--
-- Wraps @ImGui::SetScrollHereY()@
setScrollHereY :: (MonadIO m) => CFloat -> m ()
setScrollHereY pos = liftIO do
  [C.exp| void { SetScrollHereY($(float pos)) } |]
