require 'sinatra/base'
require 'RMagick'
require 'pry'
require_relative 'lib/bounds'

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
    caption.font = 'Comic-Sans-MS-Bold'

    texts = unless params['wow'].nil? then params['wow'].split(',') else [phrases.sample] end

    available_bounds = [Bounds.new(0, 0, 
                                   img.columns, img.rows)]

    texts.each do |text|
      caption.pointsize = Random.rand(20..25)
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
