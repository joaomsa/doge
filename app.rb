require 'sinatra/base'
require 'RMagick'
require 'pry'

class Array
  def sorted_insert(x)
    pos = index {|e| yield(e, x) }
    unless pos.nil? then
      insert(pos, x)
    else
      push(x)
    end
    self
  end
end

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

    # Return array of bounds within that don't overlap with the bounds passed
    def split(bounds)
      split_bounds = []
      # Bounds to the left
      split_bounds << Bounds.new(@min_x, @min_y,
                                 bounds.min_x, @max_y)
      # Bounds above
      split_bounds << Bounds.new(@min_x, @min_y,
                                 @max_x, bounds.min_y)
      # Bounds below
      split_bounds << Bounds.new(@min_x, bounds.max_y,
                                 @max_x, @max_y)
      # Bounds to the right
      split_bounds << Bounds.new(bounds.max_x, @min_y,
                                 @max_x, @max_y)
    end

    def contains?(x, y)
      @min_x <= x and x <= @max_x and @min_y <= y and y <= @max_y
    end
  end

  class App < Sinatra::Base

  get '/' do
    img = Magick::Image::read("doge.jpeg").first

    phrases = [
      'wow',
      'Neatorama',
      'Neato',
      'much Neat',
      'much fun',
      'very nice',
      'so wow',
      'much wow' ]

    colors = [ '#15fcf2', '#fc04f8', '#7f85ff', '#14f305', '#ea0f15']

    caption = Magick::Draw.new
    caption.pointsize = 25
    caption.font = 'Comic-Sans-MS-Bold'

    texts = unless params['wow'].nil? then params['wow'].split(',') else [phrases.sample] end

    available_bounds = [Bounds.new(0, 0, 
                                   img.columns, img.rows)]

    texts.each do |text|
      metrics = caption.get_multiline_type_metrics(text)

      # Find first bounds that text can fit in
      i = available_bounds.index do |b|
        b.width >= metrics.width and b.height >= metrics.height
      end
      next if i.nil?
      bounds = available_bounds.delete_at(i)

      min_x = bounds.min_x
      max_x = bounds.max_x - metrics.width
      x = Random.rand(min_x..max_x)

      min_y = bounds.min_y
      max_y = bounds.max_y - metrics.height
      y = Random.rand(min_y..max_y)

      text_bounds = Bounds.new(x, y,
                               x + metrics.width, y + metrics.height)

      bounds.split(text_bounds).each do |b|
        available_bounds.sorted_insert(b) {|e| e.area <= b.area }
      end

      caption.fill = colors.sample
      caption.annotate(img, 
                      metrics.width, metrics.height,
                      x, y + metrics.ascent,
                      text)
    end

    content_type 'image/jpeg'
    img.format = 'JPEG'
    img.to_blob
  end

  run! port: 4569 if app_file = $0
  end
end
