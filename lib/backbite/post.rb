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

    def +(posts)
      dup.push(*posts)
    end

    
    def self.tags(tlog)
      tags = Hash.new { |hash, key| hash[key] = 0 }
      (tlog.posts + tlog.archive).each{ |post|
        post.tags.each{ |t| tags[t]+=1 }
      }
      tags
    end
    
    def self.parse_args(args)
      case args
      when nil
        { }
      when /(\d+)\.\.(\d+)/
        { :ids => Range.new($1.to_i, $2.to_i).to_a }
      when /\d+,\d+/
        { :ids => args.to_s.split(',').map{ |k| k.to_i } }
      when /(\d+)/
        { :ids => $1.to_i }
      when /^(\w+)/
        { :tags =>
          if args.include?(',')
            args.split(',')
          else
            [$1]
          end
        }
      when /^:(\w+)/
        { :target => $1.to_sym }
      else
        { }
      end
    end

    def group_by(target = :target, &blk)
      inject([]){ |m, post|
        m << post.send(target)
      }.uniq.each do |t|
        yield t, dup.replace(select{ |post| post.send(target) == t })
      end
    end
    
    def archive!
      limits = { }
      group_by { |target, posts|
        limit = begin
                  tlog.config[:html][:body][target][:items]
                rescue
                  nil
                end
        #min = limit[:min] or tlog.config[:defaults][:archive_limit]
        max = (limit && limit[:max] or tlog.config[:defaults][:archive_limit])
        target_posts = posts.by_id!.reverse

        if posts.size > max
          posts[0..(posts.size - max)-1].each do |post|
            post.archive!(tlog)
          end
        end
      }
    end

    def archive_spool
      tlog.repository.export(:archive, :date => map{ |p| p.date })
      tlog.repository.export(:tags, :tags => map{ |p| p.tags }.flatten.uniq)
    end
    
    def next_id
      update!
      aps = tlog.archive(:force => true) + self
      return 1 if aps.empty?
      id = aps.map{ |post| post.pid }
      pid = id.max+1
      pid
    end
    
    def initialize(tlog)
      @tlog = tlog
    end
    
    def limit!(max, min = nil, archived = Posts.new(tlog))
      if max
        replace(self[0...max])
      else
        self
      end
    end
    
    def with_export(type, params = { })
      const = Post::Export[type]
      map{ |post|
        post.with_export(const, params)
      }
    end
    
    def with_export!(type, params = { })
      const = Post::Export[type]
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
      clear
      read
    end

    def read(what = :spool)
      Debug << "#{self.class}: read #{what}"
      postfiles = (par = tlog.repository.join(what)).entries.
        reject{ |e| e.to_s =~ /^\.+/ }
      postfiles.inject(self) { |mem, file|
        Debug << "read: #{file}"
        post = Post.read(tlog, par.join(file))
        mem << post
      }
      self
    end

  end
  
  class Post < Delegator

    def __getobj__
      @component
    end

    def self.read(tlog, file)
      Post::Ways.dispatch(:yaml) do |way|
        way.tlog = tlog
        way.file = Pathname.new(file.to_s)
        way.source = way.src
      end.process
    end
    
    attr_reader   :component
    attr_reader   :pid
    attr_accessor :neighbors
    attr_accessor :file
    attr_accessor :path_deep
    def author
      metadata[:author] or tlog.author
    end

    def with_export(const, params)
      const = Post::Export[const] if const.kind_of?(Symbol)
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

    def remove!(with_export = true)
      Info << "rm $ #{pid} #{file}"
      file.unlink
      tlog.posts.delete(self)
      #tlog.repository.reload! if with_export
      tlog.archive.filter(:target => target).by_date!.last.unarchive!
      if with_export
        tlog.repository.export(:html) 
        tlog.repository.export(:archive, { :date => date} )
        tlog.repository.export(:tags,    { :tags => tags} )
      end
    end

    def archive!(with_export = true)
      ret = Archive.archive_post(tlog, self)
      #tlog.repository.reload! if with_export
      if with_export
        tlog.repository.export(:html) 
        tlog.repository.export(:archive, { :date => date} )
        tlog.repository.export(:tags,    { :tags => tags} )
      end
      ret
    end

    def unarchive!(with_export = true)
      ret = Archive.unarchive_post(tlog, self)
      tlog.repository.reload! if with_export
      if with_export
        tlog.repository.export(:html) 
        tlog.repository.export(:tags,    { :tags => tags} )
        tlog.repository.export(:archive, { :date => date} )
      end
      ret
    end
    
    def archived?
      Archive.archived?(tlog, self)
    end

    def edit!(way = :editor)
      n = nil
      rw = Ways.dispatch(way) do |w|
        w.values = YAML::load(open(file.to_s))
        n = w.fileskel(component)
        w.tlog = tlog
        w.fields = fields
      end.process(n, component)
      rw.save and remove!
    end
    
    
    # setup! sets various attributes on our Plugin instances.
    def setup!(params)
      params.extend(Helper::ParamHash).
        process!(:tree => :required, :path_deep => :optional)
      self.path_deep = params[:path_deep]
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
      adf = metadata[:date].strftime(tlog.config[:defaults][:archive_date_format])
      "/archive/#{adf}/##{identifier}"
    end
    
    def to_s
      prfx = "\n  "
      adds = [["$", pid], [:I, identifier], ['#', url], ['', file]]
      adds = adds.map{ |an,av| "#{an.to_s.upcase.yellow} #{av.to_s.cyan}"}.join(";  #{"".bold.green}")
      clr = archived? ? :cyan : :white
      ret = "#{name.to_s.capitalize.send(clr).bold} #{"[".red} #{prfx}" <<
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
