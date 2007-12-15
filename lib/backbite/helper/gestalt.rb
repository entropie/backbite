#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper

    module Builder
      
      # Gestalt is the custom HTML/XML builder for Ramaze, based on a very simple
      # DSL it will build your markup.

      class Gestalt
        attr_accessor :out

        # The default way to start building your markup.
        # Takes a block and returns the markup.
        #
        # Example:
        #   html =
        #     Gestalt.build do
        #       html do
        #         head do
        #           title "Hello, World!"
        #         end
        #         body do
        #           h1 "Hello, World!"
        #         end
        #       end
        #     end
        #

        def self.build &block
          self.new(&block).to_s
        end

        # Gestalt.new is like ::build but will return itself.
        # you can either access #out or .to_s it, which will
        # return the actual markup.
        #
        # Useful for distributed building of one page.

        def initialize &block
          @out = ''
          instance_eval(&block) if block_given?
        end

        # catching all the tags. passing it to _gestalt_build_tag

        def method_missing meth, *args, &block
          _gestalt_call_tag meth, args, &block
        end

        # workaround for Kernel#p to make <p /> tags possible.

        def p *args, &block
          _gestalt_call_tag :p, args, &block
        end
        def id *args, &block
          _gestalt_call_tag :id, args, &block
        end

        
        def _gestalt_call_tag name, args, &block
          if args.size == 1 and args[0].kind_of? Hash
            # args are just attributes, children in block...
            _gestalt_build_tag name, args[0], &block
          else
            # no attributes, but text
            _gestalt_build_tag name, {}, args, &block
          end
        end

        # build a tag for `name`, using `args` and an optional block that
        # will be yielded

        def _gestalt_build_tag name, attr={}, text=[]
          @out << "<#{name}"
          @out << attr.inject(''){ |s,v| s << %{ #{v[0]}="#{_gestalt_escape_entities(v[1])}"} }
          if text != [] or block_given?
            @out << ">"
            @out << _gestalt_escape_entities(text.to_s)
            if block_given?
              text = yield
              @out << text.to_str if text != @out and text.respond_to?(:to_str)
            end
            @out << "</#{name}>"
          else
            @out << ' />'
          end
        end

        def _gestalt_escape_entities(s)
          s.to_s.gsub(/&/, '&amp;').
            gsub(/"/, '&quot;').
            gsub(/'/, '&apos;').
            gsub(/</, '&lt;').
            gsub(/>/, '&gt;')
        end

        # @out.to_s

        def to_s
          @out.to_s
        end
        alias to_str to_s
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
