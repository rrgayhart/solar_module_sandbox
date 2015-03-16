# load 'solar_module_sandbox/module_plugin.rb'
require 'solar_module_sandbox/offset.rb'
#require 'solar_module_sandbox/move_copy.rb'

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
      #draw_module_rows('Placeholder for Edge')
      surface_data = process_surface_data(surface)
      module_data = process_module_input(wdialog)
      generate_module(module_data, surface_data)
    end

    html_path = Sketchup.find_support_file "solar_module_sandbox/module_input.html" ,"Plugins"
    dialog.set_file(html_path)
    dialog.show
  #end
end

def draw_module_rows(edge)
  edge_start_x = 0
  edge_start_y = 0
  edge_start_z = 0

  length_of_edge = 300.to_i # How long does the edge line go

  module_x = 24.to_i # How wide is the module
  module_y = 12 # How long is the module
  module_z = -1

  x_spacer = 1 # space between modules on x
  y_spacer = 30 # space between modules on y

  module_count = length_of_edge / (module_x + x_spacer) # Calculates how many modules can fit along line

  padding = 0

  first_module = 

  module_count = 10
  for solar_module in 1..module_count
    puts "We're at module " + solar_module.to_s + "\n"
    x1 = edge_start_x + padding + (module_x * solar_module)
    puts "x1 " + x1.to_s
    x2 = x1 + module_x
    puts "x2 " + x2.to_s
    y1 = edge_start_y
    puts y1
    y2 = edge_start_y + module_y
    puts y2
    z = edge_start_z
    puts "z " + z.to_s

    padding += x_spacer
    
    # Create a series of "points", each a 3-item array containing x, y, and z.
    pt1 = [x1, y1, z]
    pt2 = [x2, y1, z]
    pt3 = [x2, y2, z]
    pt4 = [x1, y2, z]

    all_points = [pt1, pt2, pt3, pt4]

    puts "Here are all the points #{all_points.to_s}"

    model = Sketchup.active_model
    entities = model.entities
    # Call methods on the Entities collection to draw stuff.
    new_face = entities.add_face pt1, pt2, pt3, pt4
    new_face.pushpull(module_z, true)
  end

end

def process_surface_data(surface)
  grouped_by_x = surface.vertices.group_by{ |v| v.position.x }
  lowest_line = grouped_by_x.min
  south_west = lowest_line[1].min_by{ |v| v.position.y.to_f }
  first_edge = surface.edges.select{|e| e.end === south_west}[0]
  y_edge = surface.edges.select{|e| e.end === south_west}[0]
  first_edge.other_vertex(south_west)
  {
    starting_point: south_west,
    first_edge: first_edge,
    y_edge: y_edge,
    row_length: first_edge.length.to_inch,
    y_length: y_edge.length.to_inch
  }
end

def get_boundries(surface)
  starts = surface.edges.collect{|e| e.start}
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
  new_panel.pushpull(thickness.to_f, false)
  comp = group.to_component
  populate_rows(comp, run, surface_data[:row_length])
  comp_definition = comp.definition
  style_module(new_panel, comp_definition)
  rotate_module(comp_definition)
end

def style_module(original_face, comp)
  top_face = comp.entities.find{|ent| ent.class == Sketchup::Face && ent.object_id != original_face.object_id && ent.area == original_face.area}
  border = top_face.offset(-0.5)
  panel_size = border.area
  thickness = '-0.1'
  border.pushpull(thickness.to_f)
  comp.entities.each do |ent| 
    if ent.class == Sketchup::Face 
      ent.area === panel_size ? ent.material = "blue" : ent.material = "silver"
    end
  end
end

def populate_rows(comp, run, row_length)
  spacer = run.to_i + 1
  module_count = (row_length / spacer).to_i
  copy_count = module_count - 1
  move_copy(comp, [spacer, 0, 0], copy_count)
end

def rotate_module(comp)
  puts comp
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

  def move_copy( component, distance, number_of_copies )

=begin
CODE EXCERPTS TAKEN FROM http://www.martinrinehart.com/models/tutorial/tutorial_13.html
Creates an outer array, moving a component "distance" as many times as
specified.

"distance" is a vector, an array of [r, g, b].

"number_of_copies" is like the "Nx" in the VCB after a Move/Copy.
For 15 steps, you make 14 copies.
=end

    ents = Sketchup.active_model.entities

    defi = component.definition # the original component's definition
    trans = component.transformation # the original's transformation
    pt = trans.origin # the original's location, a Point3d

    for i in ( 1..number_of_copies )
      pt += distance
      # add vector to Point3d getting new Point3d
      trans = Geom::Transformation.new( pt )
      # create new Transformation at the new Point3d
      ents.add_instance( defi, trans )
      # add another instance at the new Point3d
    end
  end
end
# Rotation

# [] Option to delete all modules in model

# [] Grab the selected face
# [] Calculate vector lines with space between rows
# [] Loop per vector
# [] Divide length that can fit per vector
# [] Loop per num modules to create and move
# [] Name all modules 


# TODO

# [x] Grabs selected face
# [x] Pops up UI prompt to input module information
# [x] Make colors pretty!
# [] Array tilt
# [] Space between modules (default 1inch)
# [x] Orients modules along southernmost line
# [] Fills in modules along line
# [] Backfills modules along calculated distance
# [] Close UI element after button click

#TODO additional
# [] Cleanup UI interface
# [] Pop up prompt to outline location
# [] Add nicer colors or textures to panel

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
