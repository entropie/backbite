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
      # rescue NoMethodError
      #   p 11
      #   Warn << $!
      # end
    end
    options
  end

  class Optionparser

    include Helper::Text
    
    UnknownArgument = Backbite::NastyDream(self) unless defined? UnknownArgument

    def banner(text)
      @banner = text << "\n"
    end
    
    def abbrevs_for(target)
      (target and target.keys.map{ |t| t.to_s }.abbrev) or { }
    end
    
    def parse(which = nil, *args)
      ret, target, skip = [], self[which], 0
      args << :index if args.empty?
      if not target
        target = self[ abbrevs_for(@responder)[which.to_s] ]
        return false unless target
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
          pargs = args[ni..(ni+arity)]
          ret << t.call(*pargs)
        else
          raise UnknownArgument, a unless defined? Spec
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
      if @banner
        ret << "\n" << paragraphify(@banner, 2).green << "\n\n"
      end
      @descs.sort_by{ |k,f| k}.each do |kw, f|
        ret << " #{"%-27s" % kw.to_s.upcase.yellow} #{(f.delete(:__desc__)||'Not Documented').magenta}\n"
        f.sort.each do |k,v|
          size = @responder[kw][k].arity
          ret << "   #{("%-10s"%k).bold.green}  #{("%2i"%size).cyan}   #{v.white}\n"
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
      handler = Object unless handler
      yield(self, handler.dup)
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
