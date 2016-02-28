require 'sprite_factory'

namespace :assets do
  desc 'recreate sprite images and css'
  task resprite: :environment do
    icon_sizes = {
      small: 16,
    }

    icon_sizes.each do |size, width|
      source_path = "app/assets/sprites/#{size}"
      sprite_configuration = {
        library: :chunkypng,
        style: :scss,
        layout: :packed,
        selector: '.icon_',
        margin: 10,
        padding: 0,
        output_style: "app/assets/stylesheets/sprites/_sprite-#{size}.scss",
        output_image: "app/assets/images/sprites/#{size}.png",
        nocomments: true,
      }

      SpriteFactory.run!(source_path, sprite_configuration) do |images|
        layout_map = images.map{ |key, image| image }
        layout_name = sprite_configuration[:layout].to_s.titleize
        layout_size = "SpriteFactory::Layout::#{layout_name}".constantize.layout(layout_map, {
          hmargin: sprite_configuration[:margin],
          vmargin: sprite_configuration[:margin],
          hpadding: sprite_configuration[:padding],
          vpadding: sprite_configuration[:padding],
        })

        rules = []
        rules << <<-EOF.strip_heredoc
          /*
            Generated using `bundle exec rake assets:resprite`

            source path: "#{source_path}"
            layout     : "#{sprite_configuration[:layout]}"
            width      : "#{layout_size[:width]}px"
            height     : "#{layout_size[:height]}px"
          */

          .icf.icf_#{size} {
            background: image-url('sprites/#{size}.png');
            background-size: #{layout_size[:width] / 2}px auto;
            background-repeat: no-repeat;
            width: #{width}px;
            height: #{width}px;
            vertical-align: middle;
            display: inline-block;
            zoom: 1;
        EOF
        images.each do |image|
          properties = image[1]
          rules << "&#{properties[:selector]}#{properties[:name]} { background-position: #{-properties[:x]/2}px #{-properties[:y]/2}px; }".indent(2)
        end
        rules << "}"
        rules.join("\n")
      end
    end
  end
end
