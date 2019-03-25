# gui.set_screen_position()

gui.set_screen_position() and gui.screen_pos_to_node_pos() function for Defold.
This library will be useful if you want to get screen position of the node and set this position for another node with the different parent of even in another component.

## Installation
You can use Defold-Screenshot in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

  https://github.com/AGulev/set_screen_position/archive/master.zip


First of all, we need to recalculate all coefficient when you change screen size, that why we need to add a few lines into render_script:

```lua
-- require the module
local gui_extra_functions = require "gui_extra_functions.gui_extra_functions"
...
function init(self)
  ...
  -- calculate coefficients when init the game
  gui_extra_functions.update_coef(render.get_window_width(), render.get_window_height())
end
...

function on_message(self, message_id, message)
  ...
  -- calculate coefficients when changing screen size
elseif message_id == hash("window_resized") then
  gui_extra_functions.update_coef(render.get_window_width(), render.get_window_height())
elseif
...
end
```

#### Without Layouts

If you don't use layouts, then just call init() method in any gui_script:
```lua
-- any gui_script file
local gui_extra_functions = require "gui_extra_functions.gui_extra_functions"
...
function init(self)
  ...
  gui_extra_functions.init()
end
```

#### With Layouts

We need to call init() method in any gui_script with all possible options for layouts:
```lua
-- any gui_script file
local gui_extra_functions = require "gui_extra_functions.gui_extra_functions"
...
function init(self)
  ...
  -- table with layouts should have next format:
  -- {[hashed_layout_id] = {width = layout_width, height = layout_height} }
  gui_extra_functions.init({
    [hash("Standart")] = {
      width = 960,
      height = 640
    },
    [hash("Portrait")] = {
      width = 720,
      height = 1280
    },
    [hash("Landscape")] = {
      width = 1280,
      height = 720
    },
  })
end
```
## Usage

```lua
-- get screen position of the node
local screen_pos = gui.get_screen_position(some_node_with_difficult_hierarchy)

-- set screen position for another node
gui.set_screen_position(some_other_node, screen_pos)

-- or convert screen position to position relative to this node,
-- for example,  for gui.animate()
local local_node_pos = gui.screen_pos_to_node_pos(screen_pos, some_other_node)
gui.animate(animation_node, gui.PROP_POSITION, local_node_pos, gui.EASING_LINEAR, 1)
```


## Issues and suggestions

If you have any issues, questions or suggestions please [create an issue](https://github.com/agulev/jstodef/issues) or contact me: me@agulev.com
