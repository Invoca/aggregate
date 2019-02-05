# frozen_string_literal: true

class Passenger < Aggregate::Base
  attribute :name,    :string
  belongs_to :passport, class_name: "Passport"
end
