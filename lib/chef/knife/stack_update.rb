# Copyright (c) 2014 Mevan Samaratunga

require 'chef/knife/stackbuilder_base'

class Chef
    class Knife

        class StackUpdate < Knife

            include Knife::StackBuilderBase

            deps do
            end

            banner 'knife stack update REPO_PATH (options)'

            def run
            end
        end

    end
end
