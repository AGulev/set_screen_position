local M = {
	inited = false,
	win_x = 0,
	win_y = 0,
	layouts = {},
	default_layout = nil
}

local EMPTY = hash("")

local function recalculate_layout(layout)
	local fit, zoom, stretch = layout[gui.ADJUST_FIT], layout[gui.ADJUST_ZOOM], layout[gui.ADJUST_STRETCH]
	local sx, sy = M.win_x / layout.config_x, M.win_y / layout.config_y
	local scale = math.min(sx, sy)
	fit.sx = scale
	fit.sy = scale
	fit.ox = (M.win_x - layout.config_x * scale) * 0.5 / scale
	fit.oy = (M.win_y - layout.config_y * scale) * 0.5 / scale

	scale = math.max(sx, sy)
	zoom.sx = scale
	zoom.sy = scale
	zoom.ox = (M.win_x - layout.config_x * scale) * 0.5 / scale
	zoom.oy = (M.win_y - layout.config_y * scale) * 0.5 / scale

	stretch.sx = sx
	stretch.sy = sy
	return layout
end

local function get_layout(name)
	if not name or name == EMPTY then return nil end
	
	local layout = M.layouts[name]
	if not layout then
		M.layouts[name] = {
			config_x = 0,
			config_y = 0,
			[gui.ADJUST_FIT] = {
				sx = 0,
				sy = 0,
				ox = 0,
				oy = 0
			},
			[gui.ADJUST_ZOOM] = {
				sx = 0,
				sy = 0,
				ox = 0,
				oy = 0
			},
			[gui.ADJUST_STRETCH] = {
				sx = 0,
				sy = 0,
				ox = 0,
				oy = 0
			},
		}
		layout = M.layouts[name]
	end
	return layout
end

--call this method in render_script when change windows size
function M.update_coef(width, height)
	M.win_x = width
	M.win_y = height
	for k, v in pairs(M.layouts) do
		recalculate_layout(v)
	end
end

local function screen_to_gui(pos, adj_mode, anch_x, anch_y, layout)
	local adj = layout[adj_mode]
	if anch_x then
		pos.x = pos.x / layout[gui.ADJUST_STRETCH].sx
	else
		pos.x = pos.x / adj.sx - adj.ox
	end
	if anch_y then
		pos.y = pos.y / layout[gui.ADJUST_STRETCH].sy
	else
		pos.y = pos.y / adj.sy - adj.oy
	end
end

local function set_screen_position(node, screen_position)
	local parent = gui.get_parent(node)
	gui.set_parent(node, nil)
	local mode = gui.get_adjust_mode(node)
	local anch_x = gui.get_xanchor(node) ~= gui.ANCHOR_NONE and true or false
	local anch_y = gui.get_yanchor(node) ~= gui.ANCHOR_NONE and true or false
	
	local layout = get_layout(gui.get_layout()) or M.default_layout
	local converted_v = vmath.vector3(screen_position)
	screen_to_gui(converted_v, mode, anch_x, anch_y, layout)
	gui.set_position(node, converted_v)
	gui.set_parent(node, parent, true)
end

local function screen_pos_to_node_pos(screen_position, node)
	local position_before = gui.get_position(node)
	local parent = gui.get_parent(node)
	gui.set_parent(node, nil)
	local mode = gui.get_adjust_mode(node)
	local anch_x = gui.get_xanchor(node) ~= gui.ANCHOR_NONE and true or false
	local anch_y = gui.get_yanchor(node) ~= gui.ANCHOR_NONE and true or false

	local layout = get_layout(gui.get_layout()) or M.default_layout
	local converted_v = vmath.vector3(screen_position)
	screen_to_gui(converted_v, mode, anch_x, anch_y, layout)
	gui.set_position(node, converted_v)
	gui.set_parent(node, parent, true)
	local result_position = gui.get_position(node)
	gui.set_position(node, position_before)
	return result_position
end

function M.init(layouts)
	if M.inited then return end
	M.inited = true
	local layout
	if layouts then
		for k, v in pairs(layouts) do
			layout = get_layout(k)
			layout.config_x = v.width
			layout.config_y = v.height
			recalculate_layout(layout)
		end
	end
	
	M.default_layout = get_layout(hash("_default_layout"))
	M.default_layout.config_x = sys.get_config("display.width")
	M.default_layout.config_y = sys.get_config("display.height")
	recalculate_layout(M.default_layout)
	
	_G.gui.set_screen_position = set_screen_position
	_G.gui.screen_pos_to_node_pos = screen_pos_to_node_pos
end

return M
