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
      assert_equal nil, bitfield[2]

      assert_equal "tf", bitfield.to_s
    end

    should "fill in details indexing past the length of the string" do
      bitfield = Aggregate::Bitfield.new("")

      bitfield[10] = true
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

        begin
          bitfield[5]
          fail "Didn't raise like I expected"
        rescue ArgumentError => ex
          assert_equal "index out of bounds, index(5) >= limit(5)", ex.message
        end
      end

      should "warn when writing to bitfields outside the limit" do
        bitfield = Aggregate::Bitfield.limit(5).new("")

        begin
          bitfield[5] = false
          fail "Didn't raise like I expected"
        rescue ArgumentError => ex
          assert_equal "index out of bounds, index(5) >= limit(5)", ex.message
        end
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
    end
  end

end
