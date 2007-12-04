#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

Config[:rspec].setup do

  defaults do

    root         '/tmp/rspec'

    title        "rspec - %title%"

    author.name  "Michael Trommer"
    author.email "mictro@gmail.com"
    author.nick  "entropie"

    description  "'Tumblelog'.unpack('a5x2a2').join"

    editor       "e"

    base_href    'http://particle.enti.ty/~mit/backbite'

    upload do
      shell "ftpsync --user %ftpuser% --password %password% %localdir% %target%"
    end

    automatic do
      plugins { 
        tags
        date { value lambda{ style{ foobar :red } } }
        #permalink
      }
    end
    
    replace do # no value of key means use config value.
      author      'Michael Trommer'
      title       'foobar title'
      description
      password    'foobarbatz'
      ftpuser     'ftp27676'
      target      'ftp://ftp.ackro.com/www.ackro.de/tlog'

      colors_bg_body     '#105099'
      colors_bg_red      '#fab444'
      colors_bg_black    '#105099'
    end

  end

  stylesheets do
    files['rspec.haml'].media = :screen
  end

  javascript do
    files[:jquery]
    files[:foo]
  end

  html do
    body do |bdy|

      style do
        margin 0.px
        padding 0.px
        color :navy
        background_color '%colors_bg_body%'
        font_family 'verdena courier arial'
      end

      red do
        items.max = 100
        items.min = 10
        style do
          background_color '%colors_bg_red%'
          width '42%'
          float :left
          margin 40.px
          border_top '3px solid navy'
          border_right '3px solid navy'
          padding 10.px
        end
      end
      
      black do
        items.min = 10
        style do
          padding_right 40.px
          padding_top 42.px
          padding_left 20.px
          background_color '%colors_bg_black%'
        end
      end         
    end
  end
end



=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
