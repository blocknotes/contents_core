Rails.application.routes.draw do
  mount ContentsCore::Engine => "/contents_core"
end
