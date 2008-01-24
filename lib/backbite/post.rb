#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#



module Backbite

  require 'backbite/post/postfilter'
  
  require 'backbite/post/metadata'
  require 'backbite/post/fields'
  
  # Posts handles access to the different Posts in our Repository.
  class Posts < Array
    
    attr_reader :tlog

    def next_id
      self.size+1
    end
    
    def initialize(tlog)
      @tlog = tlog
      read
    end

    def limit!(max, min, archived = Posts.new(tlog))
      if max
        replace(self[0...max]) if max
      else
        self
      end
    end
    
    def with_export(type, params = { })
      const = Post::Export.const_get(type.to_s.upcase)
      map{ |post|
        post.with_export(const, params)
      }
    end

    def with_export!(type, params = { })
      const = Post::Export.const_get(type.to_s.upcase)
      map!{ |post|
        post.with_export(const, params)
      }
    end
    
    def filter(params, &blk)
      ret = Filter.select(params, self) #.by_date!.reverse
      ret.each(&blk) if block_given?
      ret
    end

    def by_date!
      self.replace(sort_by{ |po| po.metadata[:date] })
    end

    def by_id!
      self.replace(sort_by{ |po| po.pid })
    end
    
    def update!
      read
    end

    def read(what = :spool)
      postfiles = (par = tlog.repository.join(what)).entries.
        reject{ |e| e.to_s =~ /^\.+/ }
      postfiles.inject(self) { |mem, f|
        postway = Post::Ways.dispatch(:yaml) { |way|
          way.tlog   = self.tlog
          way.source = YAML::load(par.join(f).readlines.join)
        }.process
        mem << postway
      }.with_ids
    end
    private :read

    def with_ids
      # i = -1
      # replace(self.map{ |pst| pst.pid = i+=1 and pst })
      # each(&blk) if block_given?
      # self
    end
  end
  
  class Post < Delegator
    
    # Export contains a list of Modules to extend the Post class. E.g.
    # to use the +:html+ way to export the Repository, you first need
    # to define a Repository::Export sublcass, named HTML, which
    # responds to :export, therein your ExportTree will be evaluated
    # and uses via +with_export+ the +to_foo+ method of the extend
    # Post instance.
    # 
    # Got it? nope? see lib/export/*.rb for examples.
    class Export
    end

    def __getobj__
      @component
    end
    
    attr_reader   :component
    attr_reader   :pid
    attr_accessor :neighbors

    def author
      metadata[:author] or tlog.author
    end

    def with_export(const, params)
      npost = dup.extend(const)
      npost.setup!(params)
      npost
    end

    def pid
      metadata[:pid]
    end
    
    def <=>(o)
      metadata[:date] <=> o.date
    end
    
    def initialize(component)
      @component = component
    end
    
    def identifier
      @identifier ||= "#{component.name}#{pid}"
    end

    # setup! sets various attributes on our Plugin instances.
    def setup!(params)
      params.extend(Helper::ParamHash).
        process!(:tree => :required, :path_deep => :optional)
      self.neighbors = [tlog.posts.filter( :ids => [pid-1] ),
                        tlog.posts.filter( :ids => [pid+1] )].
        map{ |n| n.first }
      component.metadata = metadata
      self.fields.each do |fld|
        if fld.respond_to?(:plugin)
          fld.plugin.field = fld
          fld.plugin.neighbors = self.neighbors
          fld.plugin.component = @component
          fld.plugin.tlog = @component.tlog
          fld.plugin.pid = self.pid
          fld.plugin.identifier = identifier
          params.each_pair do |pnam, pval|
            fld.plugin.send("#{pnam}=", pval)
          end
        end
      end
    end
    

    def method_missing(m, *args, &blk)
      if @component.fields.include?(m)
        @component.send(:fields)[m].value
      else
        super
      end
    end

    
    def inspect
      ret = "<Post::#{name.to_s.capitalize} #{metadata.inspect} [" <<
        fields.inject([]) { |m, field|
        m << field.to_s
      }.join(', ') << "]>"
    end

    def url
      df = metadata[:date].strftime(tlog.config[:defaults][:archive_date_format])
      "/archive/#{df}/##{identifier}"
    end
    
    def to_s
      prfx = "\n  "
      adds = [[:pid, pid], [:ident, identifier], [:url, url]]
      adds = adds.map{ |an,av| "#{an.to_s.upcase.yellow}: #{av.to_s.cyan}"}.join(";  #{"".bold.green}")
      ret = "#{name.to_s.capitalize.white.bold} #{"[".red} #{prfx}" <<
        fields.inject([]) { |m, field|
        m << if field.value.to_s.empty? then nil else field.to_s(10) end
      }.compact.join("#{prfx}") << "\n#{"]".red} #{"".bold.green}#{adds}"
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
