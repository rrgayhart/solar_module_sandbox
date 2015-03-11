# load 'solar_module_sandbox/module_plugin.rb'
require 'solar_module_sandbox/offset.rb'

if( not $module_input_loaded )
    add_separator_to_menu("Tools")
    module_menu = UI.menu("Tools").add_submenu("Module Input")

    module_menu.add_item("Add Solar Modules") { module_input_dialog }
    $module_input_loaded = true
end

def module_input_dialog
  surface = Sketchup.active_model.selection.entries.find{|ent| ent.class == Sketchup::Face}
  if !surface
    UI.messagebox('Please select the face and try again.')
  else
    dialog = UI::WebDialog.new("Solar Module Plugin", false, "", 410, 875, 1030, 0, false)

    dialog.add_action_callback("generateModules") do |wdialog,value|
      surface_data = process_surface_data(surface)
      module_data = process_module_input(wdialog)
      generate_module(module_data, surface_data)
    end

    html_path = Sketchup.find_support_file "solar_module_sandbox/module_input.html" ,"Plugins"
    dialog.set_file(html_path)
    dialog.show
  end
end

def process_surface_data(surface)
  grouped_by_x = surface.vertices.group_by{ |v| v.position.x }
  lowest_line = grouped_by_x.min
  south_west = lowest_line[1].min_by{ |v| v.position.y.to_f }
  {
    starting_point: south_west
  }
end

def process_module_input(dialog)
  {
    width: dialog.get_element_value('mwidth'),
    run: dialog.get_element_value('mrun'),
    thickness: dialog.get_element_value('mthickness')
  }
end

def generate_module(module_data, surface_data)
  thickness = module_data[:thickness]
  width = module_data[:width]
  run = module_data[:run]

  coordinates = face_coordinates(surface_data, width, run)
  model = Sketchup.active_model
  group = model.entities.add_group
  entities = group.entities
  new_panel = entities.add_face(coordinates[0],
                                coordinates[1],
                                coordinates[2],
                                coordinates[3])
  new_panel.pushpull(thickness.to_f, true)
  comp = group.to_component
  comp_definition = comp.definition
  style_module(new_panel, comp_definition)
end

def style_module(original_face, comp)
  top_face = original_face.all_connected.find{|ent| ent.class == Sketchup::Face && ent.object_id != original_face.object_id && ent.area == original_face.area}
  border = top_face.offset(-0.5)
  panel_size = border.area
  thickness = '-0.1'
  border.pushpull(thickness.to_f)
  top_face.all_connected.each do |ent| 
    if ent.class == Sketchup::Face 
      ent.area === panel_size ? ent.material = "blue" : ent.material = "silver"
    end
  end
end

def face_coordinates(module_data, width, run)
  # [[0, 0], [12, 0], [12, 24], [0, 24]]
  puts module_data
  starting_point = module_data[:starting_point]
  starting_x = starting_point.position.x.to_f
  starting_y = starting_point.position.y.to_f
  starting_z = starting_point.position.z.to_f
  x1 = starting_x
  x2 = starting_x + run.to_f
  y1 = starting_y
  y2 = starting_y + width.to_f
  z = starting_z
  pts = []
  pts[0] = [x1, y1, z]
  pts[1] = [x2, y1, z]
  pts[2] = [x2, y2, z]
  pts[3] = [x1, y2, z]
  pts
end

# TODO

# [x] Grabs selected face
# [x] Pops up UI prompt to input module information
# [] Make colors pretty!
# [] Array tilt
# [] Space between modules (default 1inch)
# [x] Orients modules along southernmost line
# [] Fills in modules along line
# [] Backfills modules along calculated distance
# [] Close UI element after button click

#TODO additional
# [] Cleanup UI interface
# [] Pop up prompt to outline location

#def rotate(angle)
  #tr = Geom::Transformation.rotation([0,0,0],[1,0,0],angle.degrees)
  #Sketchup.active_model.active_entities.transform_entities(tr,Sketchup.active_model.selection)
#end

# Create array of modules across a selected plain
#layers = model.layers
#layers.add("SolarModules") if (layers.at("SolarModules") == nil)
# Calculate stuff.......?
# Export an image.......?

#process
