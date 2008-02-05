#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite
  class Post::Ways::Editor < Post::Ways::Way
    
    def tfilename
      tlog.repository.join("tmp", filename.to_s+'.tmp')
    end

    def header
      "# #{component.name} for #{filename}\n" +
        "# #{component.inspect}\n\n"
    end

    def mkfield(field)
      ret = ''
      ret << "# #{field.plugin.input}\n" if field.interactive?
      ret << "[#{field.to_sym}_start]\n#{field.predefined}\n[#{field.to_sym}_end]\n"
      ret
    end
    
    def fileskel(comp)
      file = header
      comp.fields.each do |field|
        unless field.interactive?
          file << mkfield(field) << "\n\n"
        else
        end
      end
      file
    end

    def yes_no?(text = 'Done? %s/%s', p = 'Y', s = 'n', &blk)
      loop do
        ret = blk.call
        r = Readline.readline((text.to_s + " ") % [p, s]).strip
        r = p if r.empty?
        false
        return ret if r =~ /^#{p}/i
      end
    end

    def edit!
      system("%s '%s'" % [tlog.config[:defaults][:editor], tfilename])
      ::File.open(tfilename.to_s).readlines.to_s
    end

    def process(params, comp)
      @component = comp
      tfilename.open('w+'){ |res| res.write(@fcontents = fileskel(component)) }
      @fcontents = yes_no?{
        edit!
      }
      super
      self
    end

    def run(field, params)
      result = @fcontents.scan(/\[#{field.to_sym}_start\](.*)\[#{field.to_sym}_end\]/m).
        flatten.join.strip
      super(field, result)
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
