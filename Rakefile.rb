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
RDOC_OPTS = ['-I', 'png', '--quiet', '--title', 'The Backbite RDoc Reference', '--main', 'README', '--inline-source', '-x', '(spec|skel)']
SPATH = Backbite::Source


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
  s.bindir = "bin"
  s.executables = %w(backbite)
end

sp=Dir['spec/*.rb'].sort.each do |f|
  FileUtils.touch(f)
end

task :spec do
  ENV['DEBUG'] = '1'
  system "spec -r lib/backbite #{sp.join(' ')}"
end


task :gem => [:mvpkg]

task :make_gem do
  builder = Gem::Builder.new(SPEC)
  builder.build
  SPATH.dirname.entries.grep(/.gem$/).each do |gem|
    FileUtils.mv(gem, path, :verbose => true)
  end
end

task :mvpkg => :make_gem do
  path = SPATH.join('pkg')
  path.mkdir unless path.exist?
  path.dirname.entries.grep(/.gem$/).each do |gem|
    FileUtils.mv(gem, path, :verbose => true)
  end
end

task :install => :gem do
  puts `gem install pkg/Backbite-#{VERS[/\w+\-(.*)/, 1]}`
end



task :specdoc => [:spechtml] do
  ENV['DEBUG'] = '1'
  sh "spec -r lib/backbite #{sp.join(' ')} -d --format specdoc"
end

task :spechtml do
  ENV['DEBUG'] = '1'
  system("rm #{file = "/home/mit/public_html/doc/backbite/spec.html"}")
  system("touch #{file}")
  system "spec #{sp.join(' ')} -r lib/backbite -f h:#{file}"
end

task :rdoc do
  system('rm ~/public_html/doc/backbite/rdoc -rf')
  system('rdoc -T rubyavailable -a -I png -S -m Backbite -o ~/public_html/doc/backbite/rdoc -x "(spec)"')
end

task :advance do
  file = File.open(tf = Backbite::Source.join('lib/backbite.rb'))
  fcs = file.readlines
  v = ''
  new = fcs.map do |line|
    if vs = line.grep(/Version =.*$/) and not vs.empty?
      newv = vs.to_s.scan(/\d/).join('.')
      vs = vs.to_s.gsub(newv.split('.').join(' '), v=newv.succ.succ.split('.').join(' '))
    else
      line
    end
  end
  v = v.split(' ').join('.')
  tf.open('w+'){ |f| f.write(new)}
  `hg tag \"Version #{v}\"`
  `hg commit -m \"Version #{v}\"`
end

task :rdia do
  system('rm ~/public_html/doc/backbite/rdoc -rf')
  system('rdoc -T rubyavailable -a -I png -S -m Backbite -o ~/public_html/doc/backbite/rdoc -x "(spec)" -d')
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
