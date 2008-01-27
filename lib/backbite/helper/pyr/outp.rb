#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper
    
    module Builder

      module Pyr

        module Outputter  # :nodoc: All
          
          ELEMENTS = {
            :blocklevel => %w(ul p table div body html head),
            :inline     => %w(a title li span bold i accronym strong img link meta h1 h2 h3 h4 h5 h6 script)
          }

          def Outputter.fmt_args(args)
            rh = { }
            args.each do |a|
              case a
              when Hash
                rh.merge!(a)
              else
                rh.merge!(Hash[*a])
              end
            end
            args = rh.map{ |a,b| "#{a}=\"#{b}\""}.join(' ')
            args.empty? ? '' : " "+args
          end

          def Outputter.inline_element?(ele)
            case ele.to_s
            when *ELEMENTS[:inline]
              true
            when *ELEMENTS[:blocklevel]
              false
            end
          end

          def to_html
            ret = ''
            childs = if self.kind_of?(Element) then children else self end
            case self
            when Elements
            when Element
              nargs = Outputter.fmt_args(args)
              ret << "" <<  "<#{self.name}#{nargs}>"
              ret << value
            end

            childs.each do |ele|
              ret << ele.to_html
            end if childs
            ret << "</#{self.name}>" if self.kind_of?(Element)
            ret.strip
          end
          alias :to_s :to_html
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
