# Copyright (c) 2014 Mevan Samaratunga

require 'chef/knife/stackbuilder_base'

class Chef
    class Knife

        class StackInitializeRepo < Knife

            include Knife::StackBuilderBase

            deps do
            end

            banner 'knife stack initialize repo (options)'

            def run
            end
        end

    end
end