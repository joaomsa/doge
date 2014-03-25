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
    caption.fill = colors.sample
    caption.font = 'Comic-Sans-MS-Bold'

    text = unless params['wow'].nil? then params['wow'] else phrases.sample end
    text_metrics = caption.get_type_metrics(text)

    caption.annotate(img, 
                     text_metrics.width,
                     text_metrics.height,
                     Random.rand(0..(img.x_resolution.to_i - text_metrics.width)),
                     Random.rand(0..(img.y_resolution.to_i - text_metrics.height)),
                     text)

    content_type 'image/jpeg'
    img.format = 'JPEG'
    img.to_blob
  end

  run! port: 4569 if app_file = $0
  end
end
