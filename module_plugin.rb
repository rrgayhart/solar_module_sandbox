# load 'solar_module_sandbox/module_plugin.rb'
require 'solar_module_sandbox/offset.rb'

if( not $module_input_loaded )
    add_separator_to_menu("Tools")
    module_menu = UI.menu("Tools").add_submenu("Module Input")

    module_menu.add_item("Add Solar Modules") { module_input_dialog }
    $module_input_loaded = true
end

def module_input_dialog
  dialog = UI::WebDialog.new("Solar Module Plugin", false, "", 410, 875, 1030, 0, false)

  dialog.add_action_callback("generateModules") do |wdialog,value|
    process_module_input(wdialog)
  end

  html_path = Sketchup.find_support_file "solar_module_sandbox/module_input.html" ,"Plugins"
  dialog.set_file(html_path)
  dialog.show
end

def process_module_input(dialog)
  module_data = {
    width: dialog.get_element_value('mwidth'),
    run: dialog.get_element_value('mrun'),
    thickness: dialog.get_element_value('mthickness')
  }

  generate_module(module_data)
end

def generate_module(module_data)
  thickness = module_data[:thickness]
  width = module_data[:width]
  run = module_data[:run]

  coordinates = face_coordinates(width, run)
  model = Sketchup.active_model
  group = model.entities.add_group
  entities = group.entities
  new_panel = entities.add_face(coordinates[0],
                                coordinates[1],
                                coordinates[2],
                                coordinates[3])
  new_panel.reverse!
  new_panel.pushpull(thickness.to_f, true)
  group.to_component
  style_module(new_panel)
end

def style_module(original_face)
  top_face = original_face.all_connected.find{|ent| ent.class == Sketchup::Face && ent.object_id != original_face.object_id && ent.area == original_face.area}
  border = top_face.offset(-0.5)
  thickness = '-0.1'
  new_face = border.pushpull(thickness.to_f)
  puts new_face.class
end

def face_coordinates(width, run)
  # [[0, 0], [12, 0], [12, 24], [0, 24]]
  x1 = 0
  x2 = width.to_f
  y1 = 0
  y2 = run.to_f
  pts = []
  pts[0] = [x1, y1]
  pts[1] = [x2, y1]
  pts[2] = [x2, y2]
  pts[3] = [x1, y2]
  pts
end

# TODO

# [] Grabs selected face
# [] Pops up UI prompt to input module information
# [] Make colors pretty!
# [] Array tilt
# [] Space between modules (default 1inch)
# [] Orients modules along southernmost line
# [] Fills in modules along line
# [] Backfills modules along calculated distance


# [] Color module
# [] Pop up prompt to outline location
# [] Orient wide angle south

#def process
  #surface = Sketchup.active_model.selection.entries.find{|ent| ent.class == Sketchup::Face}
  #if !surface
    #UI.messagebox('Please select the face and try again.')
  #else
    #fill_modules(surface)
  #end
#end

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
