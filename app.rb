require 'sinatra/base'
require 'RMagick'
require 'pry'

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

    bounds = Bounds.new(0, 0, img.columns, img.rows)

    texts.each do |text|
      metrics = caption.get_multiline_type_metrics(text)

      min_x = bounds.min_x
      max_x = bounds.max_x - metrics.width
      x = Random.rand(min_x..max_x)

      min_y = 0 + metrics.ascent
      max_y = bounds.max_y - metrics.height + metrics.ascent
      y = Random.rand(min_y..max_y)

      caption.fill = colors.sample
      caption.annotate(img, 
                      metrics.width,
                      metrics.height,
                      x, y,
                      text)

      y = y - metrics.ascent

      square_a = Magick::Draw.new
      square_a.fill(colors[0])
      square_a.fill_opacity(0.5)
      square_a.rectangle(bounds.min_x,
                         bounds.min_y,
                         x,
                         img.rows)
      square_a.draw(img)

      square_b = Magick::Draw.new
      square_b.fill(colors[1])
      square_b.fill_opacity(0.5)
      square_b.rectangle(bounds.min_x,
                         bounds.min_y,
                         bounds.max_x,
                         y)
      square_b.draw(img)

      square_c = Magick::Draw.new
      square_c.fill(colors[2])
      square_c.fill_opacity(0.5)
      square_c.rectangle(0,
                         y + metrics.height,
                         bounds.max_x,
                         bounds.max_y)
      square_c.draw(img)
      
      square_d = Magick::Draw.new
      square_d.fill(colors[3])
      square_d.fill_opacity(0.5)
      square_d.rectangle(x + metrics.width,
                         0,
                         bounds.max_x,
                         bounds.max_y)
      square_d.draw(img)
    end

    content_type 'image/jpeg'
    img.format = 'JPEG'
    img.to_blob
  end

  run! port: 4569 if app_file = $0
  end
end
