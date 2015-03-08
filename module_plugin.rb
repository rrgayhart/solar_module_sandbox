# load 'solar_module_sandbox/module_plugin.rb'
require 'solar_module_sandbox/offset.rb'

#Steps

# [] Dropdown tool Solar Array Selected Face
#

def process_module_input(module_input)
  puts module_input
  # This is where the processing happens
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

if( not $module_input_loaded )
    add_separator_to_menu("Tools")
    module_menu = UI.menu("Tools").add_submenu("Module Input")

    module_menu.add_item("Add Solar Modules") { module_input_dialog }
    $module_input_loaded = true
end

#
#
# [] Grabs selected face
# [] Pops up UI prompt to input module information
# [] Make colors pretty!
# [] Array tilt
# [] Space between modules (default 1inch)
# [] Orients modules along southernmost line
# [] Fills in modules along line
# [] Backfills modules along calculated distance

#def process
  #surface = Sketchup.active_model.selection.entries.find{|ent| ent.class == Sketchup::Face}
  #if !surface
    #UI.messagebox('Please select the face and try again.')
  #else
    #fill_modules(surface)
  #end
#end











# TODO
# [] Color module
# [] Pop up prompt to outline location
# [] Orient wide angle south

#def fill_modules(surface)
  #generate_module
#end

#def module_prompt
  #prompts = ["Module Width?", "Module Run?", "Module Thickness?"]
  #defaults = ["12", "24", "1"]
  #UI.inputbox(prompts, defaults, "Enter Module Details (in inches)")
#end

#def style_module(original_face)
  #top_face = original_face.all_connected.find{|ent| ent.class == Sketchup::Face && ent.object_id != original_face.object_id && ent.area == original_face.area}
  ##top_face.material = 'blue'
  #border = top_face.offset(-0.5)
  #thickness = '-0.1'
  #new_face = border.pushpull(thickness.to_f)
  #puts new_face.class
  ## Color all faces silver
  ## Grab the inner face
  ## set inner_face.material = 'blue'
#end

#def rotate(angle)
  #tr = Geom::Transformation.rotation([0,0,0],[1,0,0],angle.degrees)
  #Sketchup.active_model.active_entities.transform_entities(tr,Sketchup.active_model.selection)
#end

#def generate_module
  #input = module_prompt

  #thickness = input[2]
  #width = input[0]
  #run = input[1]

  #coordinates = face_coordinates(width, run)
  #model = Sketchup.active_model
  #group = model.entities.add_group
  #entities = group.entities
  #new_panel = entities.add_face(coordinates[0],
                                #coordinates[1],
                                #coordinates[2],
                                #coordinates[3])
  #new_panel.reverse!
  #new_panel.pushpull(thickness.to_f, true)
  #group.to_component
  #style_module(new_panel)
#end

#def face_coordinates(width, run)
  ## [[0, 0], [12, 0], [12, 24], [0, 24]]
  #x1 = 0
  #x2 = width.to_f
  #y1 = 0
  #y2 = run.to_f
  #pts = []
  #pts[0] = [x1, y1]
  #pts[1] = [x2, y1]
  #pts[2] = [x2, y2]
  #pts[3] = [x1, y2]
  #pts
#end

# Create array of modules across a selected plain
#layers = model.layers
#layers.add("SolarModules") if (layers.at("SolarModules") == nil)
# Calculate stuff.......?
# Export an image.......?

#process
