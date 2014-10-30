# Copyright (c) 2014 Mevan Samaratunga

require 'chef/knife/stackbuilder_base'

class Chef
    class Knife

        class StackUploadRole < Knife

            include Knife::StackBuilderBase

            deps do
            end

            banner "knife stack .."

            def run
            end
        end

        class StackUploadRoles < Knife
        end

    end
end
