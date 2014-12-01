# Copyright (c) 2014 Mevan Samaratunga

include StackBuilder::Common::Helpers

module StackBuilder::Chef

    class VagrantNodeManager < StackBuilder::Chef::NodeManager

        def create_vm(name, knife_config)

            knife_cmd = Chef::Knife::VagrantServerCreate.new

            knife_cmd.config[:chef_node_name] = name

            # Set the defaults
            knife_cmd.config[:distro] = 'chef-full'
            knife_cmd.config[:template_file] = false

            knife_cmd.config[:vagrant_dir] = File.join(Dir.home, '/.vagrant')
            knife_cmd.config[:provider] = 'virtualbox'
            knife_cmd.config[:memsize] = 1024
            knife_cmd.config[:subnet] = '192.168.67.0/24'
            knife_cmd.config[:port_forward] = { }
            knife_cmd.config[:share_folders] = [ ]
            knife_cmd.config[:use_cachier] = false

            knife_cmd.config[:host_key_verify] = false
            knife_cmd.config[:ssh_user] = 'vagrant'
            knife_cmd.config[:ssh_port] = '22'

            config_knife(knife_cmd, knife_config['options'] || { })

            ip_address = knife_cmd.config[:ip_address]
            knife_cmd.config[:ip_address] = ip_address[/(\d+\.\d+\.\d+\.)/, 1] + \
                (ip_address[/\.(\d+)\+/, 1].to_i + name[/-(\d+)$/, 1].to_i).to_s \
                unless ip_address.nil? || !ip_address.end_with?('+')

            @@sync ||= Mutex.new
            @@sync.synchronize {
                run_knife(knife_cmd)
            }
        end

        def delete_vm(name, knife_config)

            knife_cmd = Chef::Knife::VagrantServerDelete.new
            knife_cmd.name_args = [ name ]
            knife_cmd.config[:yes] = true
            knife_cmd.config[:vagrant_dir] = File.join(Dir.home, '/.vagrant')

            @@sync ||= Mutex.new
            @@sync.synchronize {
                run_knife(knife_cmd, 3)
            }

        rescue Exception => msg

            if Dir.exist?(knife_cmd.config[:vagrant_dir] + '/' + name)

                knife_cmd = Chef::Knife::VagrantServerList.new
                knife_cmd.config[:vagrant_dir] = File.join(Dir.home, '/.vagrant')
                server_list = run_knife(knife_cmd)

                if server_list.lines.keep_if { |l| l=~/test-TEST-0/ }.first.chomp.end_with?('running')
                    raise msg
                else
                    FileUtils.rm_rf(knife_cmd.config[:vagrant_dir] + '/' + name)
                end
            end
        end
    end
end
