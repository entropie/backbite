#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#
module Backbite

  # FIXME: use mtime
  class Register < Hash
    
    RegisterFile = File.expand_path('~/.backbite.reg.yaml')

    def initialize
      self.file = RegisterFile
    end

    # <tt>default=</tt> wants an tumblog object and safes a
    # <tt>{:DEFAULT => "name:cfgfile"}</tt>.
    def default=(tlog)
      cfgf = self.fetch(tlog.name)
      self[:DEFAULT] = "#{tlog.name}:#{cfgf}"
    end

    # returns true if there is a default tumblog
    def default?
      not self[:DEFAULT].nil?
    end

    # returns default tumblog
    def default
      if default?
        self[:DEFAULT]
      end
    end

    # sets registerfile
    def file=(regfile)
      @register = Pathname.new(regfile)
      reload
      @register
    end

    def []=(obj, val)
      super
      save
    end

    def to_s
      reload
      self.map {|a,b|
        "#{"%-10s".send(a==:DEFAULT ? 'bold' : 'cyan') % a} = #{b.white}"
      }.join("\n")
    end
    
    def [](obj)
      return nil unless include?(obj)
      f = self.fetch(obj)
      n, v = if obj == :DEFAULT then [*f.split(':')] else [obj, f] end
      Tumblelog.new(n, v)
    end
    
    def reload
      save unless @register.exist?
      merge! File.open(@register.to_s, 'r'){ |r| YAML::load(r.readlines.to_s)}
      self
    end

    def save
      @register.open('w+'){ |reg|
        reg.write(YAML::dump(self))
      }
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
