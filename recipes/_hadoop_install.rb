# install and setup hadoop
tar_name = "hadoop-#{node['hadoop']['version']}"
remote_file "#{Chef::Config['file_cache_path']}/#{tar_name}.tar.gz" do
  source "http://archive.cloudera.com/cdh/3/#{tar_name}.tar.gz"
  checksum node['hadoop']['checksum']
  # notifies :run, 'bash[install_tmux]', :immediately
end

hadoop_parent_dir = File.expand_path(File.join(node['hadoop']['home'], '..'))
directory hadoop_parent_dir do
  owner node['hadoop']['dir_owner']
  group node['hadoop']['dir_group']
  mode 00755
  recursive true
  action :create

  not_if { ::File.exist?(hadoop_parent_dir) }
end


bash 'install_hadoop' do
  cwd Chef::Config['file_cache_path']
  code <<-EOH
    tar xzf #{tar_name}.tar.gz
    mv #{tar_name} #{node['hadoop']['home']}
    chown -R #{node['hadoop']['dir_owner']}:#{node['hadoop']['dir_group']} #{node['hadoop']['home']}
  EOH

  not_if { ::File.exist?(node['hadoop']['home']) }
end

template "#{node['hadoop']['home']}/conf/hadoop-env.sh" do
  hadoop_user =
    if node['hadoop'] && node['hadoop']['user_name']
      node['hadoop']['user_name']
    end

  java_home =
    if node['java'] && node['java']['java_home']
      node['java']['java_home']
    elsif node['jdk'] && node['jdk']['home']
      node['jdk']['home']
    end

  variables hadoop_user: hadoop_user,
            java_home: java_home
end

template "#{node['hadoop']['home']}/conf/core-site.xml" do
  host =
    if node['hadoop'] && node['hadoop']['fs_default']
      node['hadoop']['fs_default']['host']
    end

  port =
    if node['hadoop'] && node['hadoop']['fs_default']
      node['hadoop']['fs_default']['port']
    end

  fs_default = nil
  if host && port
    fs_default = "hdfs://#{host}:#{port}"
  end

  variables fs_default: fs_default
end

template "#{node['hadoop']['home']}/conf/mapred-site.xml" do
  host =
    if node['hadoop'] && node['hadoop']['mapred_tracker']
        node['hadoop']['mapred_tracker']['host']
    end

  port =
    if node['hadoop'] && node['hadoop']['mapred_tracker']
      node['hadoop']['mapred_tracker']['port']
    end

  mapred_tracker = nil
  if host && node
    mapred_tracker = "#{host}:#{port}"
  end

  variables mapred_tracker: mapred_tracker
end
