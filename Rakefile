VERSION = '7u17'
BUILD   = '-b02'

DEBIAN = 'vendor/oracle-java7/debian'

require 'rubygems'
require 'bundler'
Bundler.setup

require 'dcf'
require 'evoker'
require 'evoker/local_cache'

CONTROL = Dcf.parse(File.read("#{DEBIAN}/control"))
SOURCE = CONTROL.find { |e| e.key?('Source') }
PACKAGES = CONTROL.select { |e| e.key?('Package') }
CHANGELOG = Dcf.parse(`dpkg-parsechangelog -l#{DEBIAN}/changelog -n1`).first

PKG_VERSION = CHANGELOG['Version']
PKG_BUILD_DEPS = SOURCE['Build-Depends'].
  split(/,\s*/).
  map { |dep| dep.sub(/\s*\([^\)]*\)\s*$/, '') }

DPKG_ARCHITECTURE = `dpkg --print-architecture`.strip
def _arch(spec)
  spec == 'all' ? 'all' : DPKG_ARCHITECTURE
 end

PKG_FILES = PACKAGES.map do |pkg|
  desc "The #{pkg['Package']} package"
  file "#{pkg['Package']}_#{PKG_VERSION}_#{_arch(pkg['Architecture'])}.deb" => :build
end

def src(path)
  Evoker::cached_wget "http://download.oracle.com/otn-pub/java/#{path}",
    :args => '--no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com"'
end


desc 'Build the packages'
task :build => [ src("jdk/#{VERSION}#{BUILD}/jdk-#{VERSION}-linux-x64.tar.gz"),
                 src("jce/7/UnlimitedJCEPolicyJDK7.zip") ] do
  rm_rf 'build'
  mkdir 'build'
  chdir 'build' do
    ln_s Dir['../vendor/oracle-java7/debian', '../*.tar.gz', '../*.zip'], '.'
    sh 'dpkg-buildpackage -uc -us'
  end
end

desc 'Install build dependencies'
task :deps do
  sh 'sudo', 'apt-get', '-y', 'install', *PKG_BUILD_DEPS
end

desc 'List build dependencies'
task :show_deps do
  puts PKG_BUILD_DEPS.join("\n")
end

task :default => [:deps, :build]
