
class Passport < ActiveRecord::Base
  # This is stored in the database
  attr_accessible :name

  attr_accessible :gender, :city, :state, :birthdate, :height, :weight, :photo


  include Aggregate::Container

  aggregate_attribute :gender,           :enum, limit: [:male, :female], required: true
  aggregate_attribute :city,             :string,   required: true
  aggregate_attribute :state,            :string,   required: true
  aggregate_attribute :birthdate,        :datetime, required: true
  aggregate_attribute :height,           :decimal
  aggregate_attribute :weight,           :decimal
  aggregate_attribute :photo,            "PassportPhoto"
  aggregate_has_many  :foreign_visits,   "ForeignVisit"
end
