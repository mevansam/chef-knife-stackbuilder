# Copyright (c) 2014 Mevan Samaratunga

module StackBuilder::Common

    class StackBuilderError < StandardError; end
    class NotImplemented < StackBuilderError; end
    class NotSupported < StackBuilderError; end

end
