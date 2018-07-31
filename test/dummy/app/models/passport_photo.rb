# frozen_string_literal: true

class PassportPhoto < Aggregate::Base
  attribute :photo_url, :string
  attribute :color,     :boolean
end
