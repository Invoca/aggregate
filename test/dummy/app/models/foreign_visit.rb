class ForeignVisit < Aggregate::Base
  attribute :country,    :string
  attribute :visited_at, :datetime
end
