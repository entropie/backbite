#
#
# Author:  Michael 'entropie' Trommer <mictro@gmail.com>
#

require 'lib/backbite'

require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'fileutils'
include FileUtils

REV = `hg head`[/changeset: +(\d+)/, 1].to_i
PKG = VERS = Backbite::version + ".#{REV}"
RDOC_OPTS = ['-I', 'png', '--quiet', '--title', 'The Backbite RDoc Reference', '--main', 'README', '--inline-source', '-x', 'spec']

PKG_FILES = %w(LICENSE README Rakefile.rb) +
  Dir.glob("{bin,doc,spec,lib,spec_skel}/**/*") +
  Dir.glob("ext/**/*.{h,java,c,rb,rl}")

SPEC =
  Gem::Specification.new do |s|
  s.name = 'Backbite'
  s.version = VERS[/\w+\-(.*)/, 1]
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.rdoc_options += RDOC_OPTS
  s.extra_rdoc_files = ["README", 'LICENSE']
  s.summary = "A tumblog controller"
  s.description = s.summary
  s.author = "Michael 'mictro' Trommer"
  s.email = '<mictro@gmail.com>'
  s.homepage = 'http://code.ackro.org/Backbite'
  s.files = PKG_FILES
  #s.require_paths = [ARCHLIB, "lib"]
  #s.extensions = FileList["ext/**/extconf.rb"].to_a
  s.bindir = "bin"
end

task :spec do
  
  ENV['DEBUG'] = '1'
  sh 'spec spec -r spec/default_config'
end

task :gem do
  path = Backbite::Source.join('pkg')
  path.mkdir unless path.exist?
  builder = Gem::Builder.new(SPEC)
  builder.build
  path.dirname.entries.grep(/.gem$/).each do |gem|
    FileUtils.mv(gem, path)
  end
end

task :install => :gem do
end


task :specdoc => [:spechtml] do
  ENV['DEBUG'] = '1'
  sh 'spec spec -d --format specdoc -r spec/default_config -r lib/backbite'
end

task :spechtml do
  ENV['DEBUG'] = '1'
  sh("rm #{file = "/home/mit/public_html/doc/ackro.suc/spec.html"}")
  sh("touch #{file}")
  sh "spec spec -r spec/default_config -r lib/backbite -f h:#{file}"
end

task :rdoc do
  system('rm ~/public_html/doc/ackro.suc/rdoc -rf')
  system('rdoc -T rubyavailable -a -I png -S -m Backbite -o ~/public_html/doc/ackro.suc/rdoc -x "spec"')
end

task :console do
  puts "You may want to to @a an ready to use tumblog object"
  ENV['DEBUG'] = '1'
  system("irb -r spec/default_config.rb")
end


=begin
Local Variables:
  mode:ruby
  fill-column:70
  indent-tabs-mode:nil
  ruby-indent-level:2
End:
=end
