#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

module Backbite

  module Post::Export::HTML

    include Helper::Builder

    def to_html(name)
      target = tlog.components[self.metadata[:component]]
      fields = self.fields
      ident = identifier
      nam = self.name
      res = lambda{
        div(:class => "post #{nam}", :id => "#{ident}") {
          fields.each do |field|
            f, filtered = field.to_sym, field.apply_filter(:html)
            filtered = field.apply_markup(:html, filtered)
            name = f.to_s.split('_').last.to_sym
            tag = field.definitions[:tag]
            tag ||= :div
            send(tag, filtered.to_s, :class => "field #{name}")
          end
        }
      }
    end
  end
  

  module Repository::Export::HTML # :nodoc: All
    
    def self.export(tlog, params)
      @tree = Tree.new(tlog, params)
      @tree.write unless params[:nowrite]
      @tree
    end

    class Tree < Repository::ExportTree
      include Contrib[:Pyr]

      include Helper::Builder
      #include Helper::CacheAble

      attr_reader :pyr
      attr_accessor :doctype

      def doctype
        @doctype ||= "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"DTD/xhtml1-transitional.dtd\">"
      end

      def encoding
        %Q(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>)
      end
      
      def timestamp
        %Q(<!-- \n  Generated by Backbite at: #{Time.now}.\n  Have a nice Day.\n-->)
      end
      
      def initialize(tlog, params)
        super
        @file = 'index.html'
        @pyr = mktree
        mkbody
      end
      
      def to_s
        encoding + "\n" + doctype + "\n\n" + timestamp + "\n" + @pyr.to_html
      end
      alias :to_html :to_s
      
      def mktree
        params = @params
        alternate, _title, = "#{params[:path_deep]}everythingatom.xml", @params[:title]

        jss = tlog.config[:javascript][:files] rescue { }
        ssheets = tlog.config[:stylesheets]
        bsheets = { :screen => [:base, :generated] }
        
        Pyr.build{
          html(:xmlns => "http://www.w3.org/1999/xhtml", "xml:lang" => :en, :lang => :en) {
            head do

              title(_title)
              link(:type => 'application/atom+XML', :rel => 'alternate', :href => alternate)

              [bsheets, ssheets].each do |_sheets|
                _sheets.each_pair do |media, sheets|
                  sheets.each do |sheet|
                    link(:href => "#{params[:path_deep]}include/#{sheet}.css",
                         :media => media, :type => 'text/css', :rel => 'stylesheet')
                  end
                end
              end

              # javascript
              script(:charset => 'utf-8', :type => 'text-javascript')
              jss.each do |js|
                script(:src => "#{params[:path_deep]}include/#{js}.js",
                       :type => "text/javascript" )
              end
            end
          }
        }
      end

      def automate(where, node, &blk)
        if target = node[where]
          yield(target)
        end
      end

      def mkindy(where, node)
        return nil unless node
        if target = node[where]
          Plugins.independent(self, tlog, target, @params) do |indy|
            case cont = indy.content
            when nil
            when Proc
              yield(cont)
            when Pyr::Element, Pyr::Elements
              yield(cont.build_block)
            else
              raise "?"
            end
          end
        end

      end

      def mkplugin_node_maybe(which, node, &blk)
        if plugin = node[:plugin] # and plugin == which
          Plugins.independent(pyr, tlog, { which => node}, @params) do |iplugin|
            res =
              case nt = iplugin.result.first
              when Pyr::Element, Pyr::Elements
                nt.build_block
              when String
                tag = iplugin.class.const_defined?(:TAG) ? iplugin.class.const_get(:TAG) : :div
                lambda { send(tag, nt)}
              else
                warn "?"
              end
            yield res
          end
        else
          yield nil
        end
      end
      private :mkplugin_node_maybe

      # builds contents of a content node +node+ with name +name+.
      def mknode(name, node)
        mkplugin_node_maybe(name, node) do |pcontents|
          if pcontents
            yield lambda{ build(&pcontents) }
          else
            ps = @params.merge( :tree => self, :target => name )

            posts = tlog.posts.filter(ps)
            
            if @params[:archive]
              posts = posts + tlog.archive.filter(ps)
            end
            posts = posts.by_date!.reverse

            if node[:items] and not @params[:nolimit]
              posts.limit!(node[:items][:max], node[:items][:min])
            end

            posts.with_export!(:html, @params.merge(ps))
            posts.each do |post|
              tag = node[:tag] or :div
              pyr = lambda{
                build(&post.to_html(name))
              }
              yield pyr
            end
          end
        end
      end
      
      # builds entire body
      def mkbody
        target, bdys = self, tlog.config[:html][:body]
        indy = bdys[:independent]
        
        bdy = Pyr.build {
          body {
            target.mkindy(  :before, indy) { |pyr| build(&pyr) }
            bdys.each do |name, node|
              next if Repository::IgnoredBodyFields.include?(name)
              tag = node[:tag] || :div
              
              target.automate(:before, node) { |pyr| build(&pyr) }
              
              send(tag, :id => name) do
                target.automate(:inner_before, node) { |pyr| build(&pyr) }
                target.mknode(name, node) do |pyr|
                  build(&pyr)
                end
                target.automate(:inner_append, node) { |pyr| build(&pyr) }
              end
              target.automate(:append, node) { |pyr| build(&pyr) }
              
            end
            target.mkindy(  :append, indy) { |pyr| build(&pyr) }
          }
        }
        @pyr[:html].push(bdy)
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
