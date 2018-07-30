# frozen_string_literal: true

require_relative '../test_helper'

class Aggregate::BitfieldTest < ActiveSupport::TestCase
  context "bitfield" do
    should "support array operations" do
      bitfield = Aggregate::Bitfield.new("")

      bitfield[0] = true
      assert_equal true, bitfield[0]

      bitfield[1] = false
      assert_equal false, bitfield[1]

      bitfield[2] = nil
      assert_nil bitfield[2]

      assert_equal "tf", bitfield.to_s
    end

    should "fill in details indexing past the length of the string" do
      bitfield = Aggregate::Bitfield.new("")

      bitfield[10] = true
      assert_equal([nil] * 10 + [true], (0..10).map { |i| bitfield[i] })
    end

    should "trim trailing nils when reporting the string value" do
      bitfield = Aggregate::Bitfield.new("")
      bitfield[10] = nil
      assert_equal "", bitfield.to_s
    end

    context "length limited classes" do
      should "allow values below the limit" do
        bitfield = Aggregate::Bitfield.limit(10).new("")

        bitfield[9] = true
        assert_equal true, bitfield[9]
      end

      should "warn when reading from to bitfields outside the limit" do
        bitfield = Aggregate::Bitfield.limit(5).new("")

        ex = assert_raises ArgumentError do
          bitfield[5]
        end
        assert_equal "index out of bounds, index(5) >= limit(5)", ex.message
      end

      should "warn when writing to bitfields outside the limit" do
        bitfield = Aggregate::Bitfield.limit(5).new("")

        ex = assert_raises ArgumentError do
          bitfield[5] = false
        end
        assert_equal "index out of bounds, index(5) >= limit(5)", ex.message
      end

      should "allow comparison between bitfields" do
        first = Aggregate::Bitfield.limit(5).new("")
        second = Aggregate::Bitfield.limit(5).new("")

        assert_equal first, second

        first[0] = true
        assert_not_equal first, second
      end

      should "allow comparision between bitfields of different limits" do
        first = Aggregate::Bitfield.limit(5).new("")
        second = Aggregate::Bitfield.limit(50).new("")

        assert_equal first, second

        first[0] = true
        assert_not_equal first, second
      end

      should "allow aggregates containing bitfields to be copied" do
        passport = sample_passport

        passport.stamps[0] = true
        passport.stamps[5] = false

        passport.save!

        passport2 = Passport.new(passport.aggregate_attributes)
        passport2.save!
      end
    end
  end

end
