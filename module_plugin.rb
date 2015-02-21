# load 'solar_module_sandbox/module_plugin.rb'

def process
  generate_module
end

def module_prompt
  prompts = ["Module Width?", "Module Run?", "Module Thickness?"]
  defaults = ["12", "24", "1"]
  UI.inputbox(prompts, defaults, "Enter Module Details (in inches)")
end

def generate_module
  input = module_prompt

  thickness = input[-1]
  width = input[0]
  run = input[1]

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
end

def face_coordinates(width, run)
  width = 12
  run = 24

  x1 = 0
  x2 = width
  y1 = 0
  y2 = run
  pts = []
  pts[0] = [x1, y1]
  pts[1] = [x2, y1]
  pts[2] = [x2, y2]
  pts[3] = [x1, y2]
  pts
end

# Create array of modules across a selected plain
#layers = model.layers
#layers.add("SolarModules") if (layers.at("SolarModules") == nil)

# Calculate stuff.......?

# Export an image.......?

process
