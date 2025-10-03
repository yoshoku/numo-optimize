# frozen_string_literal: true

module Numo
  module Optimize
    # NelderMead module provides functions for minimization using the Nelder-Mead simplex algorithm.
    module NelderMead
      # @!visibility private
      ZERO_TAU = 0.00025

      # @!visibility private
      NONZERO_TAU = 0.05

      module_function

      # Minimize a function using the Nelder-Mead simplex algorithm.
      # This module function is for internal use. It is recommended to use `Numo::Optimize.minimize`.
      #
      # @param f [Method/Proc]
      # @param x [Numo::DFloat]
      # @param args [Object]
      # @param maxiter [Integer]
      # @param xtol [Float]
      # @param ftol [Float]
      def fmin(f, x, args, maxiter = nil, xtol = 1e-6, ftol = 1e-6) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        n = x.size
        maxiter ||= 200 * n

        alpha = 1.0
        beta = n > 1 ? 1 + 2.fdiv(n) : 2.0
        gamma = n > 1 ? 0.75 - 1.fdiv(2 * n) : 0.5
        delta = n > 1 ? 1 - 1.fdiv(n) : 0.5

        sim = x.class.zeros(n + 1, n)
        sim[0, true] = x
        n.times do |k|
          y = x.dup
          y[k] = y[k].zero? ? ZERO_TAU : (1 + NONZERO_TAU) * y[k]
          sim[k + 1, true] = y
        end

        fsim = Numo::DFloat.zeros(n + 1)

        (n + 1).times { |k| fsim[k] = fnc(f, sim[k, true], args) }
        n_fev = n + 1

        res = {}

        n_iter = 0
        while n_iter < maxiter
          break if ((sim[1..-1,
                         true] - sim[0, true]).abs.flatten.max <= xtol) && ((fsim[0] - fsim[1..]).abs.max <= ftol)

          xbar = sim[0...-1, true].sum(axis: 0) / n
          xr = xbar + (alpha * (xbar - sim[-1, true]))
          fr = fnc(f, xr, args)
          n_fev += 1

          shrink = true
          if fr < fsim[0]
            xe = xbar + (beta * (xr - xbar))
            fe = fnc(f, xe, args)
            n_fev += 1
            shrink = false
            if fe < fr
              sim[-1, true] = xe
              fsim[-1] = fe
            else
              sim[-1, true] = xr
              fsim[-1] = fr
            end
          elsif fr < fsim[-2]
            shrink = false
            sim[-1, true] = xr
            fsim[-1] = fr
          elsif fr < fsim[-1]
            xoc = xbar + (gamma * (xr - xbar))
            foc = fnc(f, xoc, args)
            n_fev += 1
            if foc <= fr
              shrink = false
              sim[-1, true] = xoc
              fsim[-1] = foc
            end
          else
            xic = xbar - (gamma * (xr - xbar))
            fic = fnc(f, xic, args)
            n_fev += 1
            if fic < fsim[-1]
              shrink = false
              sim[-1, true] = xic
              fsim[-1] = fic
            end
          end

          if shrink
            (1..n).to_a.each do |j|
              sim[j, true] = sim[0, true] + (delta * (sim[j, true] - sim[0, true]))
              fsim[j] = fnc(f, sim[j, true], args)
              n_fev += 1
            end
          end

          ind = fsim.sort_index
          sim = sim[ind, true].dup
          fsim = fsim[ind].dup

          res[:x] = sim[0, true]
          res[:fnc] = fsim[0]
          res[:n_iter] = n_iter
          res[:n_fev] = n_fev

          n_iter += 1
        end

        res
      end

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
    end
  end
end
