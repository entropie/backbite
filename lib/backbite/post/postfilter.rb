#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  class Posts < Array

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
              Warn << "#{c}: No RepsondTo attribute, module is useles."
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
      
      module IdsFilter

        RespondsTo = :ids

        def filter(params, &blk)
          ids  = params[:ids]
          ids = [ids] unless ids.kind_of?(Array)
          reject!{ |post|
            not ids.include?(post.pid)
          }
        end
      end

      module TargetFilter

        RespondsTo = :target

        def filter(params, &blk)
          target = params[:target]
          target = target.to_sym
          reject!{ |p|
            target != p.config[:target]
          }
        end
      end

      module TagsFilter

        RespondsTo = :tags

        def filter(params, &blk)
          tags = params[:tags]
          reject!{ |post|
            not tags or tags.map{ |t| true if post.tags.include?(t) }.compact.empty?
          }
        end
      end

      module RangeFilter

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

      module DateFilter

        RespondsTo = :date

        def filter(params, &blk)
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
