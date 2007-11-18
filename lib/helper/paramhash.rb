#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Helper

    module KeywordArguments
      OPTIONAL = :optional
      REQUIRED = :required

      def options_to_instance_variables(options)
        options.each_pair do |key, val|
          instance_variable_set("@#{key.to_s}", val)
        end
      end
      alias :options_to_iv :options_to_instance_variables
    end

    module ParamHash
      def process!(*params)
        params_c = []
        params.each {|param|
          if param.kind_of?(Symbol)
            raise ArgumentError, "#{param} is missing" unless self.include?(param)
            params_c << param
          elsif param.kind_of?(Hash)
            param.each_pair {|k,v|
              if v == KeywordArguments::REQUIRED
                raise ArgumentError, "#{k} is not in argument list" unless self.include?(k)
              elsif not v.kind_of?(Symbol)
                params_c << k
              end
              params_c << k
            }
          end
        }
        self.reject! {|k,v| not params_c.include?(k) }
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
