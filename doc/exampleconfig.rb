#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
# Example configuration file for backbite, the tumblog controller.
#
#

Config[:__name__].setup do

  defaults do

    root         '/path/to/your/repos'

    title        "lazy dog - %title%"

    author.name  "Seppmeier"
    author.email "lazy@dog.com"
    author.nick  "Sepp"

    description  "'Tumblelog'.unpack('a5x2a2').join"

    editor       "emacs"

    base_href    'http://dog.com/~lazy/tumbleog'

    upload do
      shell "ftpsync --user %ftpuser% --password %password% %localdir% %target%"
    end

    archive_date_format  '%Y%m%d'

    automatic do
      # this is used to list plugins with definitions which are
      # atomaticaly added to every component
      plugins { 
        tags
        date 
        permalink { value lambda{ style{ background_color :silver } } }
      }
    end

    # no value of key means use config value.
    replace do
      author      'Seppmeier'
      title       'title'
      description
      password    'd0g'
      ftpuser     'lazy'
      target      'ftp://ftp.ackro.com/www.ackro.de/tlog'

      colors_bg_body     'red'
      colors_bg_red      'green'
      colors_bg_black    'blue'
    end

  end

  # not mandatory
  stylesheets do
    # files will parsed in different ways depending on extension
    # known extensions are: haml, css
    files['rspec.haml'].media = :screen
  end

  # not mandatory
  javascript do
    # files[:jquery]
    # files[:foo]
  end

  # use this to define your html body
  html do
    # mandatory
    body do
      style do
        color :black
        background_color '%colors_bg_black%'
      end

      red do
        # items.max = 100
        # items.min = 10
        style do
          background_color '%colors_bg_red%'
          padding 40.px
        end
      end
      
      black do
        # ...
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
