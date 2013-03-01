# Chef recipe to install Java from built Debian packages. It is
# assumed that the packages are available to apt-get.
#
# Copy or symlink this file to Opscode `java` cookbook as
# `recipes/oracle-deb.rb` and set node['java']['install_flavor'] to
# "oracle-deb".
#
# You can also execute this file directly with chef-apply.

node.set['java']['java_home'] = "/usr/lib/jvm/java-7-oracle"

execute "update-java-alternatives" do
  command "update-java-alternatives -s java-7-oracle"
  returns [0,2]
  action :nothing
end

package 'oracle-java7-jdk' do
  action :install
  notifies :run, "execute[update-java-alternatives]"
end

ruby_block  "set-env-java-home" do
  block do
    ENV["JAVA_HOME"] = node['java']['java_home']
  end
  not_if { ENV["JAVA_HOME"] == node['java']['java_home'] }
end

file "/etc/profile.d/jdk.sh" do
  content <<-EOS
    export JAVA_HOME=#{node['java']['java_home']}
  EOS
  mode 0755
end
