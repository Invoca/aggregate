Rails.application.routes.draw do
  mount Aggregate::Engine => "/aggregate"
end
