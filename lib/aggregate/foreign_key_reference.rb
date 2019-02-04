# frozen_string_literal: true

class Aggregate::ForeignKeyReference
  attr_reader :id

  def initialize(klass, id_or_value)
    @class = klass

    if id_or_value.is_a?(ActiveRecord::Base)
      @value = id_or_value
      @id = @value.id
    else
      @id = id_or_value.to_i
    end
  end

  def value
    @value ||= @class.find(@id)
  end
end
