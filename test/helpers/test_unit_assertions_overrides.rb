# Remove this before checkin.
module Test
  module Unit
    module Assertions
      def assert_raise(klass, message = nil, regex = nil, &block)
        if message.is_a?(Regexp)
          regex, message = message, regex
        end
        message ||= ""
        actual_exception = original_raise(klass, message, &block)
        if regex
          assert_match regex, actual_exception.to_s, message
        end
        actual_exception
      end

      def assert_equal_with_diff(arg1, arg2, msg = '')
        if arg1 == arg2
          assert true # To keep the assertion count accurate
        else
          assert_equal arg1, arg2, "#{msg}\n#{Diff.compare(arg1, arg2)}"
        end
      end

      private
      def original_raise(*args, &block)
        assert_expected_exception = Proc.new do |*_args|
          message, assert_exception_helper, actual_exception = _args
          expected = assert_exception_helper.expected_exceptions
          diff = AssertionMessage.delayed_diff(expected, actual_exception)

          full_message = build_message(message,
                                       "<?> exception expected but was\n<?>.?",
                                       expected, actual_exception, diff)
          begin
            assert_block(full_message) do
              expected == [] or
                assert_exception_helper.expected?(actual_exception)
            end
          rescue AssertionFailedError => failure
            _set_failed_information(failure, expected, actual_exception,
                                    message)
            raise failure # For JRuby. :<
          end
        end

        _assert_raise(assert_expected_exception, *args, &block)
      end
    end
  end
end
