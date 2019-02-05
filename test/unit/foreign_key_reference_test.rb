# frozen_string_literal: true

require_relative '../test_helper'

class Aggregate::ForeignKeyReferenceTest < ActiveSupport::TestCase

  context "when constructed with an ID" do
    setup do
      @passport = sample_passport
      Passport.initialization_count = 0

      @reference = Aggregate::ForeignKeyReference.new(Passport, @passport.id)
    end

    should "not load the instance to read the id" do
      assert_equal @passport.id, @reference.id
      assert_equal 0, Passport.initialization_count
    end

    should "load the instance when returning the instance" do
      assert_equal @passport.name, @reference.value.name
      assert_equal 1, Passport.initialization_count
    end
  end

  context "when constructed with an instance" do
    setup do
      @passport = sample_passport
      Passport.initialization_count = 0

      @reference = Aggregate::ForeignKeyReference.new(Passport, @passport)
    end

    should "not load the instance when reading the instance or the id" do
      assert_equal @passport.id, @reference.id
      assert_equal @passport.name, @reference.value.name

      assert_equal 0, Passport.initialization_count
    end
  end
end
