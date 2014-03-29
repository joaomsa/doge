require 'sinatra/base'
require 'RMagick'

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

      caption.fill = colors.sample

      min_x = 0
      max_x = img.columns - metrics.width
      x = Random.rand(min_x..max_x)

      min_y = 0 + metrics.ascent
      max_y = img.rows - metrics.height + metrics.ascent
      y = Random.rand(min_y..max_y)

      caption.annotate(img, 
                      metrics.width,
                      metrics.height,
                      x, y,
                      text)
    end

    content_type 'image/jpeg'
    img.format = 'JPEG'
    img.to_blob
  end

  run! port: 4569 if app_file = $0
  end
end
