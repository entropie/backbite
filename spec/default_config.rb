#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

$default_config = <<EOF
    Config[:rspec].setup do

      defaults do

        root         '~/Tmp/rspec'

        title        "rspec - %title%"

        author.name  "Michael Trommer"
        author.email "mictro@gmail.com"
        author.nick  "entropie"

        description  "'Tumblelog'.unpack('a5x2a2').join"

        editor       "e"

        base_href = 'http://particle.enti.ty/~mit/Ackro.suc'

        upload do
          shell "ftpsync --user %ftpuser% --password %password% %localdir% %target%"
        end

        replace do # no value of key means use config value.
          author
          working_title
          description
          password     lamda{ File.open('/home/mit/Data/Secured/ackro.org.pw').readlines.join.strip }
          ftpuser     'ftp27676'
          target      'ftp://ftp.ackro.com/www.ackro.de/tlog'
        end

        export do
          ways do
            html
            plain
            xml
            atom
          end
        end

      end

      stylesheets do
        files[:base].media = :screen
        files[:extended]..media = :screen
        generate :generated #, :media => :screen
      end

      html do
        body do |bdy|
          bdy.red do
            items.max = 100
            items.min = 10
            style do
              width 424.px
              float :left
              margin 0.px
              padding 0.px
              background 'url(../images/left_bg.jpg) repeat-y'  
            end
          end
          
          bdy.black do
            items.min = 10
            style do
              margin_left 424.px
            end
          end         
        end
      end
    end
EOF




=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
