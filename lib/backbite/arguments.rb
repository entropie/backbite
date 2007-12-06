#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  class Options < Hash # :nodoc: All
  end
  
  def self.optionparser
    options = Optionparser.new
    begin
      yield options if block_given?
    rescue NoMethodError
      p $!
    end
    options
  end

  class Optionparser

    def abbrevs_for(target)
      target.keys.map{ |t| t.to_s }.abbrev
    end
    
    def parse(which = nil, *args)
      ret, target, skip = [], self[which], 0
      args << :index if args.empty?
      unless target
        target = self[ abbrevs_for(@responder)[which.to_s] ]
      end
      nargs = args.map{ |a| a.to_sym }
      nargs.each_with_index  do |a, i|
        unless skip.zero?
          skip -= 1
          next
        end
        abs = abbrevs_for(target)
        if t = target[a] or
            (abs[a.to_s] and t = target[ abs[a.to_s].to_sym ])
          arity = t.arity.abs-1
          skip, ni = arity+1, i.succ
          pargs =args[ni..(ni+arity)]
          ret << t.call(*pargs)
        else
          Info << "Arguments: not known #{a}"
        end
      end
      ret.flatten
    end

    def [](obj)
      return nil unless obj
      @responder[obj.to_sym]
    end
    
    def each(&blk)
      @responder.each(&blk)
    end

    def to_s
      ret = ''
      @descs.each do |kw, f|
        ret << "> #{kw} '#{f.delete(:__desc__)||'Not Documented'}'\n"
        f.each do |k,v|
          size = @responder[kw][k].arity
          ret << " * #{"%-10s"%k}  #{"%2i"%size}  #{v}\n"
        end
        ret << "\n"
      end
      ret
    end
    
    def desc(str)
      @descs[@current_keyword][:__desc__] = str
    end
    
    def keyword(kw, handler = Object)
      @current_keyword = kw
      @definition = @responder[@current_keyword]
      yield(self, handler)
    end
    
    def declare(keyw, desc = '', &blk)
      @responder[@current_keyword] ||= { }
      @descs[@current_keyword][keyw] = desc
      @responder[@current_keyword][keyw] = blk
    end
    
    def initialize
      @responder = Options.new
      @descs = Hash.new{ |hash, key| hash[key] = { } }
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
