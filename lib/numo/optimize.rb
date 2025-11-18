# frozen_string_literal: true

require 'numo/narray/alt'

# On distributions like Rocky Linux, native extensions are installed in a separate
# directory from Ruby code, so use require to load them.
require 'numo/optimize/optimize'

require_relative 'optimize/version'
require_relative 'optimize/lbfgsb'
require_relative 'optimize/scg'
require_relative 'optimize/nelder_mead'

# Ruby/Numo (NUmerical MOdules)
module Numo
  # Numo::Optimize provides functions for minimizing objective functions.
  module Optimize
    module_function

    # Minimize the given function.
    #
    # @param fnc [Method/Proc] Method for calculating the function to be minimized.
    # @param x_init [Numo::DFloat] (shape: [n_elements]) Initial point.
    # @param jcb [Method/Proc/Boolean] Method for calculating the gradient vector.
    #   If true is given, fnc is assumed to return the function value and gardient vector as [f, g] array.
    # @param method [String] Type of algorithm. 'L-BFGS-B', 'SCG', or 'Nelder-Mead' is available.
    # @param args [Object] Arguments pass to the 'fnc' and 'jcb'.
    # @param bounds [Numo::DFloat/Nil] (shape: [n_elements, 2])
    #   \[lower, upper\] bounds for each element x. If nil is given, x is unbounded.
    #   This argument is only used 'L-BFGS-B' method.
    # @param factr [Float] The iteration will be stop when
    #
    #   (f^k - f^\{k+1\})/max{|f^k|,|f^\{k+1\}|,1} <= factr * Lbfgsb::DBL_EPSILON
    #
    #   Typical values for factr: 1e12 for low accuracy; 1e7 for moderate accuracy; 1e1 for extremely high accuracy.
    #   This argument is only used 'L-BFGS-B' method.
    # @param pgtol [Float] The iteration will be stop when
    #
    #   max{|pg_i| i = 1, ..., n} <= pgtol
    #
    #   where pg_i is the ith component of the projected gradient.
    #   This argument is only used 'L-BFGS-B' method.
    # @param maxcor [Integer] The maximum number of variable metric corrections used to define the limited memory matrix. This argument is only used 'L-BFGS-B' method.
    # @param xtol [Float] Tolerance for termination by the change of the optimal vector norm. This argument is used 'SCG' and 'Nelder-Mead' methods.
    # @param ftol [Float] Tolerance for termination by the change of the objective function value. This argument is used 'SCG' and 'Nelder-Mead' methods
    # @param jtol [Float] Tolerance for termination by the norm of the gradient vector. This argument is only used 'SCG' method.
    # @param maxiter [Integer] The maximum number of iterations.
    # @param verbose [Integer/Nil] If negative value or nil is given, no display output is generated. This argument is only used 'L-BFGS-B' method.
    # @return [Hash] Optimization results; { x:, n_fev:, n_jev:, n_iter:, fnc:, jcb:, task:, success: }
    #   - x [Numo::DFloat] Updated vector by optimization.
    #   - n_fev [Interger] Number of calls of the objective function.
    #   - n_jev [Integer] Number of calls of the jacobian.
    #   - n_iter [Integer] Number of iterations.
    #   - fnc [Float] Value of the objective function.
    #   - jcb [Numo::Narray] Values of the jacobian
    #   - task [String] Description of the cause of the termination.
    #   - success [Boolean] Whether or not the optimization exited successfully.
    def minimize(fnc:, x_init:, jcb:, method: 'L-BFGS-B', args: nil, bounds: nil, factr: 1e7, pgtol: 1e-5,
                 maxcor: 10, xtol: 1e-6, ftol: 1e-8, jtol: 1e-7, maxiter: 15_000, verbose: nil)
      case method.downcase.delete('-')
      when 'lbfgsb'
        n_elements = x_init.size
        l = Numo::DFloat.zeros(n_elements)
        u = Numo::DFloat.zeros(n_elements)
        nbd = if Numo::Optimize::Lbfgsb::SZ_F77_INTEGER == 64
                Numo::Int64.zeros(n_elements)
              else
                Numo::Int32.zeros(n_elements)
              end

        unless bounds.nil?
          n_elements.times do |n|
            lower = bounds[n, 0]
            upper = bounds[n, 1]
            l[n] = lower
            u[n] = upper
            if lower.finite? && !upper.finite?
              nbd[n] = 1
            elsif lower.finite? && upper.finite?
              nbd[n] = 2
            elsif !lower.finite? && upper.finite?
              nbd[n] = 3
            end
          end
        end

        Numo::Optimize::Lbfgsb.fmin(fnc, x_init.dup, jcb, args, l, u, nbd, maxcor,
                                    factr, pgtol, maxiter, verbose)
      when 'neldermead'
        Numo::Optimize::NelderMead.fmin(fnc, x_init.dup, args, maxiter, xtol, ftol)
      when 'scg'
        Numo::Optimize::Scg.fmin(fnc, x_init.dup, jcb, args, xtol, ftol, jtol, maxiter)
      else
        raise ArgumentError, "Unknown method: #{method}"
      end
    end
  end
end
