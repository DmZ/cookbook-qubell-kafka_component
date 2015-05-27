#
# Cookbook Name:: cookbook-qubell-kafka_component
# Recipe:: default
#

service "iptables" do
  action :stop
  provider Chef::Provider::Service::Init::Redhat
end

include_recipe "apache_kafka::default"
