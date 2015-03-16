# load 'solar_module_sandbox/module_plugin.rb'
require 'solar_module_sandbox/move_copy.rb'
require 'solar_module_sandbox/solar_module.rb'

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
      input = process_module_input(wdialog)
      surface_data = process_surface_data(surface)
      input[:start] = surface_data[:starting_point]
      solar_module = SolarModule.new(input)
      instance = solar_module.draw
      populate_rows(instance, input[:width], surface_data[:row_length])
    end

    html_path = Sketchup.find_support_file "solar_module_sandbox/module_input.html" ,"Plugins"
    dialog.set_file(html_path)
    dialog.show
    #end
  end

  def process_module_input(dialog)
    {
      width: dialog.get_element_value('mwidth'),
      length: dialog.get_element_value('mlength'),
      thickness: dialog.get_element_value('mthickness'),
      name: dialog.get_element_value('mname'),
      panel_color: dialog.get_element_value('mpcolor'),
      border_color: dialog.get_element_value('mbcolor')
    }
  end

  def process_surface_data(surface)
    grouped_by_x = surface.vertices.group_by{ |v| v.position.x }
    lowest_line = grouped_by_x.min
    south_west = lowest_line[1].min_by{ |v| v.position.y.to_f }
    first_edge = surface.edges.select{|e| e.end === south_west}[0]
    {
      starting_point: south_west.position,
      row_length: first_edge.length.to_inch
    }
  end

  def populate_rows(comp, run, row_length)
    spacer = run.to_i + 1
    module_count = (row_length / spacer).to_i
    copy_count = module_count - 1
    move_copy(comp, [spacer, 0, 0], copy_count)
  end

  def get_boundries(surface)
    starts = surface.edges.collect{|e| e.start}
  end

  def move_copy( component, distance, number_of_copies )
    # CODE EXCERPTS TAKEN FROM http://www.martinrinehart.com/models/tutorial/tutorial_13.html

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
