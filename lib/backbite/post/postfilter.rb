#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  class Posts < Array

    # Filter is used to select specific posts from the list,
    # known Filter atm:
    # * NodeFilter -- filter by node (responds to :node)
    # * IdsFilter -- filter by id (responds to :ids)
    # * TargetFilter -- filter by tags (responds to :tags)
    # * RangeFilter -- filter by a given Date range (responds to :between)
    #
    # Additional there are descrutive methods for sorting defined
    # in Posts.
    # * by_id! -- sort by id
    # * by_date! -- sort by date
    #
    # == Example
    #
    #  tlog.posts.filter(:target => name.to_sym).by_date!.reverse
    #  tlog.posts.filter(:between => 4.days..3.days)
    #
    module Filter

      def self.select(params, posto)
        consts = self.constants.select{ |fc| fc =~ /Filter$/ }.map{ |fc|
          const_get(fc)
        }
        posto = posto.dup
        params.keys.each do |param|
          cos = consts.select{ |c|
            if c.const_defined?(:RespondsTo)
              t = c.const_get(:RespondsTo)
              t = [t] unless t.kind_of?(Array)
              t.include?(param)
            else
              Warn << "#{c}: No RepsondTo attribute, module is useless."
              false
            end
          }.each do |co|
            fs = posto.size
            posto.extend(co).filter(params)
            (ps = params.dup)
            ps.delete(:tree)
            Debug << "Postfilter: #{co.name.to_s.split(':').last} [#{fs}:#{posto.size}] #{ps.inspect}"
          end
        end
        posto
      end

      module NodeFilter # :nodoc: All

        RespondsTo = :node

        def filter(params, &blk)
          name = params[:name]
          reject!{ |post|
            not post.config[:target].include?(name)
          }
        end
      end
      
      module IdsFilter  # :nodoc: All

        RespondsTo = :ids

        def filter(params, &blk)
          ids  = params[:ids]
          ids = [ids] unless ids.kind_of?(Array)
          reject!{ |post|
            not ids.include?(post.pid)
          }
        end
      end

      module TargetFilter  # :nodoc: All

        RespondsTo = :target

        def filter(params, &blk)
          target = params[:target]
          target = target.to_sym
          reject!{ |p|
            target != p.config[:target].first
          }
        end
      end

      module TagsFilter  # :nodoc: All

        RespondsTo = :tags

        def filter(params, &blk)
          tags = params[:tags]
          reject!{ |post|
            not tags or tags.map{ |t| true if post.tags.include?(t) }.compact.empty?
          }
        end
      end

      module RangeFilter # :nodoc: All

        RespondsTo = [:range, :between]

        def filter(params, &blk)
          if bet = params[:between]
            reject!{ |p|
              if bet.kind_of?(Range)
                if bet.include?(p.metadata[:date])
                  false
                else
                  true
                end
              else
                Time.now.to_i-bet >= p.metadata[:date].to_i
              end
            }
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
