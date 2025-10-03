# frozen_string_literal: true

module Numo
  module Optimize
    # Lbfgsb module provides functions for minimization using L-BFGS-B algorithm.
    module Lbfgsb
      module_function

      # @!visibility private
      def fnc(fnc, x, args)
        if args.is_a?(Hash)
          fnc.call(x, **args)
        elsif args.is_a?(Array)
          fnc.call(x, *args)
        elsif args.nil?
          fnc.call(x)
        else
          fnc.call(x, args)
        end
      end

      # @!visibility private
      def jcb(jcb, x, args)
        if args.is_a?(Hash)
          jcb.call(x, **args)
        elsif args.is_a?(Array)
          jcb.call(x, *args)
        elsif args.nil?
          jcb.call(x)
        else
          jcb.call(x, args)
        end
      end

      private_class_method :fnc, :jcb
    end
  end
end
