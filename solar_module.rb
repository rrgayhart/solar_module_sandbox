#load 'solar_module_sandbox/solar_module.rb'
require 'solar_module_sandbox/offset.rb'

class SolarModule

  attr_reader :width, :length, :start, :thickness,
    :panel_definition, :panel_definition, :name,
    :panel_color, :border_color

  def initialize(args)
    @start = args[:start] || [0, 0, 0.01]
    @width = args[:width] || 24
    @length = args[:length] || 12
    @thickness = args[:thickness] || 1
    @name = args[:name] || 'Custom Solar Module'
    @panel_color = args[:panel_color] || '#3063A5'
    @border_color = args[:border_color] || 'silver'
    @panel_definition ||= nil
  end

  def draw(location=start)
    if !panel_definition
      draw_new_module
    else
      add_new_instance(location)
    end
  end

  private

  def draw_new_module
    group = Sketchup.active_model.entities.add_group
    entities = group.entities
    panel_face = entities.add_face(face_coordinates[0],
                                   face_coordinates[1],
                                   face_coordinates[2],
                                   face_coordinates[3])
    panel_face.pushpull(thickness.to_f, true)
    panel_instance = make_component(group)
    style_module(panel_face)
    panel_instance
  end

  def add_new_instance(location)
    ents = Sketchup.active_model.entities
    pt = Geom::Point3d.new(location)
    trans = Geom::Transformation.new( pt )
    ents.add_instance(panel_definition, trans)
  end

  def face_coordinates
    starting_point = Geom::Point3d.new(start)

    x1 = starting_point.x.to_f
    x2 = x1 + width.to_f
    y1 = starting_point.y.to_f
    y2 = y1 + length.to_f
    z = starting_point.z.to_f

    [
      [x1, y1, z],
      [x2, y1, z],
      [x2, y2, z],
      [x1, y2, z]
    ]
  end

  def make_component(group)
    comp = group.to_component
    @panel_definition = comp.definition
    panel_definition.name = name
    comp
  end

  def style_module(original_face)
    top_face = find_opposite_face(original_face)
    border = top_face.offset(-0.5)
    panel_size = border.area
    thickness = '-0.1'
    border.pushpull(thickness.to_f)
    color_panel(panel_size)
  end

  def find_opposite_face(face)
    panel_definition.entities.find do |ent|
      ent.class == Sketchup::Face &&
      ent.object_id != face.object_id &&
      ent.area == face.area
    end
  end

  def color_panel(panel_size)
    panel_definition.entities.each do |ent|
      if ent.class == Sketchup::Face
        ent.area === panel_size ? ent.material = panel_color : ent.material = border_color
      end
    end
  end


end
