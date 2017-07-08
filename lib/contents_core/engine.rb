if defined? ::Rails
  module ContentsCore
    class Engine < ::Rails::Engine
      isolate_namespace ContentsCore
    end
  end
end
