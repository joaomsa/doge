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

      # Bounds to the left
      rect = Bounds.new(bounds.min_x, bounds.min_y,
                        x, img.rows)
      available_bounds.sorted_insert(rect) {|b| b.area <= rect.area }

      # Bounds above
      rect = Bounds.new(bounds.min_x, bounds.min_y,
                        bounds.max_x, y)
      available_bounds.sorted_insert(rect) {|b| b.area <= rect.area }

      # Bounds below
      rect = Bounds.new(bounds.min_x, y + metrics.height,
                        bounds.max_x, bounds.max_y)
      available_bounds.sorted_insert(rect) {|b| b.area <= rect.area }
      
      # Bounds to the right
      rect = Bounds.new(x + metrics.width, bounds.min_y,
                        bounds.max_x, bounds.max_y)
      available_bounds.sorted_insert(rect) {|b| b.area <= rect.area }

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
