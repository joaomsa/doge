require 'sinatra/base'
require 'RMagick'
require 'pry'

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
    caption.pointsize = 25
    caption.font = 'Comic-Sans-MS-Bold'

    texts = unless params['wow'].nil? then params['wow'].split(',') else [phrases.sample] end

    texts.each do |text|
      metrics = caption.get_multiline_type_metrics(text)

      min_x = 0
      max_x = img.columns - metrics.width
      x = Random.rand(min_x..max_x)

      min_y = 0 + metrics.ascent
      max_y = img.rows - metrics.height + metrics.ascent
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
      square_a.rectangle(0,
                         0,
                         x,
                         img.rows)
      square_a.draw(img)

      square_b = Magick::Draw.new
      square_b.fill(colors[1])
      square_b.fill_opacity(0.5)
      square_b.rectangle(0,
                         0,
                         img.columns,
                         y)
      square_b.draw(img)

      square_c = Magick::Draw.new
      square_c.fill(colors[2])
      square_c.fill_opacity(0.5)
      square_c.rectangle(0,
                         y + metrics.height,
                         img.columns,
                         img.rows)
      square_c.draw(img)
      
      square_d = Magick::Draw.new
      square_d.fill(colors[3])
      square_d.fill_opacity(0.5)
      square_d.rectangle(x + metrics.width,
                         0,
                         img.columns,
                         img.rows)
      square_d.draw(img)
    end

    content_type 'image/jpeg'
    img.format = 'JPEG'
    img.to_blob
  end

  run! port: 4569 if app_file = $0
  end
end
