#
# Cookbook name:: apache_kafka
# Recipe:: manager
#

download_path = ::File.join(Chef::Config[:file_cache_path], "kafka-manager.zip")
remote_file download_path do
  source node["apache_kafka"]["manager_url"]
  notifies :run, "execute[unzip kafka manager]"
end

execute "unzip kafka manager" do
  command "unzip -o #{download_path} -d #{node["apache_kafka"]["install_dir"]}"
end
  
execute "change owner for kafka home" do
  command "chown -R #{node["apache_kafka"]["user"]}:#{node["apache_kafka"]["user"]} #{node["apache_kafka"]["install_dir"]}"
end

bash "run kafka-manager" do
  user node["apache_kafka"]["user"]
  code <<-EOH
  ZK_HOSTS=#{node["apache_kafka"]["zookeeper.connect"]} #{node["apache_kafka"]["install_dir"]}/kafka-manager-1.2.3/bin/kafka-manager -Dconfig.file=#{node["apache_kafka"]["install_dir"]}/kafka-manager-1.2.3/conf/application.conf -Dhttp.port=#{node["apache_kafka"]["manager_port"]} > /tmp/kf-manager.log 2>&1 &
  EOH
end
#bash "check manager" do
#  i=0; while [ $$i -le 77 -a "`curl -s -w \"%{http_code}\" \"http://#{node["ipaddress"]}:#{node["apache_kafka"]["manager_port"]}\" -o /dev/null`" == "000" ]; do echo "$$i"; sleep 10; ((i++)); done; if [ "`curl -s -w \"%{http_code}\" \"http://#{node["ipaddress"]}:#{node["apache_kafka"]["manager_port"]}\" -o /dev/null`" == "200" ]; then exit 0; else exit 1; fi;
#  EOH
#end
remote_file "/tmp/dummy.manager" do
  source "http://#{node["ipaddress"]}:#{node["apache_kafka"]["manager_port"]}"
  backup false
  retries 60
  retry_delay 10
end

bash "setup kafka-manager" do
  code <<-EOH
  set -x
  zk_hosts=`echo #{node["apache_kafka"]["zookeeper.connect"]} | sed 's/:/%3A/g;s/,/%2C/g'`
  curl --data "name=kafka-cluster&zkHosts=$zk_hosts&kafkaVersion=0.8.2.0" http://#{node["ipaddress"]}:#{node["apache_kafka"]["manager_port"]}/clusters
  EOH
end
