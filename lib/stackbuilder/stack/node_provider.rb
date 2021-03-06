# Copyright (c) 2014 Mevan Samaratunga

include StackBuilder::Common::Helpers

module StackBuilder::Stack

    class NodeProvider

        def set_stack(stack, id)
            raise StackBuilder::Common::NotImplemented, 'NodeProvider.set_stack_id'
        end

        def get_env_vars
            return { }
        end

        def get_node_manager(node_config)
            raise StackBuilder::Common::NotImplemented, 'NodeProvider.get_node_manager'
        end
    end
end