#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'cgi'

module Backbite

  module Post::Export::ATOM

    include Contrib[:Pyr]
    
    def to_atom
      po, tl = self, tlog
      begin
        permurl = fields[:permalink].plugin.url.to_s
      rescue
        puts self
        exit
      end
      fs = fields
      ffs = fields.filter(:html, self)
      bdy = Pyr.build do
        ct = fs.each do |field|
          opts = { }
          opts[:tag] = field.definitions[:tag] unless
            field.definitions[:tag].to_s.empty?
          opts[:tag] ||= :div
          opts[:tag] = opts[:tag].to_s.capitalize.to_sym
          f, filtered = field.to_sym, ffs[field.to_sym]
          send(opts[:tag], filtered)
        end
      end

      str = Pyr.build do
        id(permurl)
        opts = { }
        title(po.identifier)
        author{ CGI.escapeHTML(name(tl.author(1).to_s)) }
        updated(po.metadata[:date].iso8601)
        content( CGI.escapeHTML(bdy.to_s), :type => 'html')
      end
    end
  end

  module Repository::Export::ATOM

    def self.export(tlog, params)
      @tree = Tree.new(tlog, params)
      @tree.write unless params[:nowrite]
      @tree
    end

    class Tree < Repository::ExportTree

      include Contrib[:Pyr]
      
      def initialize(tlog, params)
        super
        @file = 'atom.xml'
        @__result__ = head << make_body.to_s
      end

      def to_s
        @__result__.to_s
      end

      def head
        %Q(<?xml version="1.0" encoding="UTF-8"?>)
      end

      def escape(str)
        CGI.escapeHTML(str)
      end
      
      def make_body
        tlog = @tlog
        s = self
        Pyr.build do
          feed(:xmlns => "http://www.w3.org/2005/Atom") do
            title(tlog.title)
            link(:href => tlog.url, :rel => 'alternate', :type => 'text/html')
            link(:href => tlog.http_path('atom.xml').to_s, :rel => 'self', :type => "application/atom+xml")
            updated(CGI.escapeHTML(Time.now.iso8601))
            id(tlog.http_path.to_s.strip)
            tlog.posts.with_export(:atom, :tree => self).each{ |post|
              entry {
                build(&post.to_atom.build_block)
              }
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
