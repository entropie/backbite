#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

$default_config = <<EOF
    Config[:rspec].setup do

      defaults do

        style do
        end

        root         '~/Tmp/rspec'

        title        "rspec - %title%"

        author.name  "Michael Trommer"
        author.email "mictro@gmail.com"
        author.nick  "entropie"

        description  "'Tumblelog'.unpack('a5x2a2').join"

        editor       "e"

        base_href  'http://particle.enti.ty/~mit/Ackro.suc'

        upload do
          shell "ftpsync --user %ftpuser% --password %password% %localdir% %target%"
        end

        replace do # no value of key means use config value.
          author      'Michael Trommer'
          title       'foobar title'
          description
          password     'foobarbatz'
          ftpuser     'ftp27676'
          target      'ftp://ftp.ackro.com/www.ackro.de/tlog'
        end

        export do
          ways do
            html {
              interval 1.days
            }
            plain
            xml
            atom
          end
        end

      end

      stylesheets do
        files[:base].media = :screen
        files[:generated].media = :screen
      end

      javascript do
        files[:jquery]
        files[:foo]
      end


      html do
        body do |bdy|

          bdy.style do
            margin 0.px
            padding 0.px
            color :navy
            background_color "#105099"
            font_family 'verdena courier arial'
          end

          bdy.red do
            items.max = 100
            items.min = 10
            style do
              background_color "#fab444"
              width '42%'
              float :left
              margin 40.px
              border_top '3px solid navy'
              border_right '3px solid navy'
              padding 10.px
            end
          end
          
          bdy.black do
           items.min = 10
            style do
              padding_right 40.px
              padding_top 42.px
              padding_left 20.px
              background_color "#105099"
            end
          end         
        end
      end
    end
EOF

require 'lib/backbite'
@a = Backbite::Tumblelog.new(:rspec, $default_config)


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
