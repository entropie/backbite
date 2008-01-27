#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper
    
    module Builder

      module Pyr

        module Tidy

          begin
            require 'tidy'
            
            def tidy(show_warnings = false)
              ::Tidy.path = '/usr/lib/libtidy.so'
              xml = ::Tidy.open(:show_warnings => show_warnings) do |tidy|
                tidy.options.show_body_only = true
                tidy.options.output_xhtml = true
                tidy.options.xml = true
                tidy.options.char_encoding = 'utf8'
                tidy.options.indent = true
                xml = tidy.clean(to_html)
                if show_warnings
                  $stderr.puts tidy.errors, tidy.diagnostics
                end
                xml
              end            
            end
          rescue LoadError
          end
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
