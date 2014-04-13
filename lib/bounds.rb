module Doge
  class Bounds
    attr_reader :min_x, :min_y, :max_x, :max_y 

    def initialize(min_x, min_y, max_x, max_y)
      @min_x = min_x
      @min_y = min_y
      @max_x = max_x
      @max_y = max_y
    end

    def width
      @width ||=  @max_x - @min_x
    end

    def height
      @height ||=  @max_y - @min_y
    end

    def area
      @area ||= height * width
    end

    # Test if self encapsulates bounds passed
    def contains?(bounds)
      @min_x <= bounds.min_x and  bounds.min_x <= @max_x and
      @min_y <= bounds.min_y and  bounds.min_y <= @max_y and
      @min_x <= bounds.max_x and  bounds.max_x <= @max_x and
      @min_y <= bounds.max_y and  bounds.max_y <= @max_y
    end

    def intersects?(bounds)
      !(@min_x > bounds.max_x or 
        bounds.min_x > @max_x or 
        bounds.min_y > @max_y or 
        @min_x > bounds.max_x)
    end

    # Return array of bounds within that don't overlap with the bounds passed
    def split(bounds)
      return nil unless intersects?(bounds)

      min_x, max_x = [bounds.min_x, bounds.max_x, @min_x, @max_x].sort[1..2]
      min_y, max_y = [bounds.min_y, bounds.max_y, @min_y, @max_y].sort[1..2]
      intersecting_bounds = Bounds.new(min_x, min_y, max_x, max_y)

      split_bounds = []
      # Bounds to the left
      rect = Bounds.new(@min_x, @min_y,
                        intersecting_bounds.min_x, @max_y)
      split_bounds << rect if rect.area > 0

      # Bounds above
      rect = Bounds.new(@min_x, @min_y,
                        @max_x, intersecting_bounds.min_y)
      split_bounds << rect if rect.area > 0

      # Bounds below
      rect = Bounds.new(@min_x, intersecting_bounds.max_y,
                        @max_x, @max_y)
      split_bounds << rect if rect.area > 0

      # Bounds to the right
      rect = Bounds.new(intersecting_bounds.max_x, @min_y,
                        @max_x, @max_y)
      split_bounds << rect if rect.area > 0
      split_bounds
    end
  end

end
