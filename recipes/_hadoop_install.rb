# install and setup hadoop
tar_name = "hadoop-#{node['hadoop']['version']}"
remote_file "#{Chef::Config['file_cache_path']}/#{tar_name}.tar.gz" do
  source "http://archive.cloudera.com/cdh/3/#{tar_name}.tar.gz"
  checksum node['hadoop']['checksum']
  # notifies :run, 'bash[install_tmux]', :immediately
end

bash 'install_hadoop' do
  cwd Chef::Config['file_cache_path']
  code <<-EOH
    tar xzf #{tar_name}.tar.gz
    mv #{tar_name} #{node['hadoop']['home']}
  EOH
  not_if { ::File.exist?(node['hadoop']['home']) }
end

template "#{node['hadoop']['home']}/conf/hadoop-env.sh" do
  hadoop_user = nil
  if node['hadoop'] && node['hadoop']['user_name']
    hadoop_user = node['hadoop']['user_name']
  end

  variables hadoop_user: hadoop_user
end

template "#{node['hadoop']['home']}/conf/core-site.xml" do
  host = node['hadoop']['fs_default']['host']
  port = node['hadoop']['fs_default']['port']

  fs_default = nil
  if host && port
    fs_default = "hdfs://#{host}:#{port}"
  end

  variables fs_default: fs_default
end

template "#{node['hadoop']['home']}/conf/mapred-site.xml" do
  host = node['hadoop']['mapred_tracker']['host']
  port = node['hadoop']['mapred_tracker']['port']

  mapred_tracker = nil
  if host && node
    mapred_tracker = "#{host}:#{port}"
  end

  variables mapred_tracker: mapred_tracker
end
