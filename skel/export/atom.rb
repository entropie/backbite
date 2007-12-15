#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'cgi'

module Backbite

  module Post::Export::ATOM

    include Helper::Builder
    
    def to_atom
      ordered = tlog.components[metadata[:component]].order.dup
      ordered.map!{ |o|
        fname = o.to_s.gsub(/\w+_(\w+)/, '\1')
        fields[fname]
      }
      po, tl = self, tlog
      permurl = CGI.escapeHTML(fields[:permalink].plugin.atom_url)

      res = Gestalt.build do
        ct = ordered.map do |field|
          opts = { }
          opts[:tag] = field.definitions[:tag] unless
            field.definitions[:tag].to_s.empty?
          opts[:tag] ||= :div
          f, filtered = field.to_sym, field.apply_filter(:atom)
          "<#{opts[:tag]}>#{filtered}</#{opts[:tag]}>"
        end

        title { po.identifier }
        author{ name(tl.author) }
        updated(po.metadata[:date].iso8601)
        id(:html => true){ permurl }
        content(:type => :html){ CGI.escapeHTML(ct.to_s) }
      end
      res
    end
  end

  module Repository::Export::ATOM

    def self.export(tlog, params)
      @tree = Tree.new(tlog, params)
      @tree.write unless params[:nowrite]
      @tree
    end

    class Tree < Repository::ExportTree

      include Helper::Builder
      
      def initialize(tlog, params)
        super
        @file = 'atom.xml'
        @__result__ = head << make_body
      end

      def to_s
        @__result__.to_s
      end

      def head
        %Q(<?xml version="1.0" encoding="UTF-8"?>)
      end
      
      def make_body
        tlog = @tlog
        Gestalt.build do
          feed(:xmlns => "http://www.w3.org/2005/Atom") do
            title{ tlog.title }
            link(:href => tlog.url, :rel => 'alternate', :type => 'text/html')
            link(:href => tlog.http_path('atom.xml'), :rel => 'self', :type => "application/atom+xml")
            updated(Time.now.iso8601)
            author{ name(tlog.author(0)) }
            id(tlog.http_path.to_s.strip)
            tlog.posts.with_export(:atom, :tree => self).each{ |post|
              entry do
                post.to_atom
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
