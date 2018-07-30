# frozen_string_literal: true

Rails.application.routes.draw do
  mount Aggregate::Engine => "/aggregate"
end
