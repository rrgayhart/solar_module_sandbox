module MoveCopy

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
