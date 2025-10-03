# frozen_string_literal: true

require 'test_helper'

module Numo
  class TestOptimize < Minitest::Test # rubocop:disable Metrics/ClassLength
    def test_minimize_lbfgsb_driver1
      n = 25
      m = 5
      x = Numo::DFloat.zeros(n) + 3
      b = Numo::DFloat.zeros(n, 2)
      0.step(n - 1, 2) do |i|
        b[i, 0] = 1
        b[i, 1] = 100
      end
      1.step(n - 1, 2) do |i|
        b[i, 0] = -100
        b[i, 1] = 100
      end
      fnc = proc do |x, n|
        f = 0.25 * ((x[0] - 1)**2)
        (1...n).each do |i|
          f += (x[i] - (x[i - 1]**2))**2
        end
        f * 4.0
      end
      jcb = proc do |x, n|
        g = Numo::DFloat.zeros(n)
        t1 = x[1] - (x[0]**2)
        g[0] = (2.0 * (x[0] - 1.0)) - (16.0 * x[0] * t1)
        (1...(n - 1)).each do |i|
          t2 = t1
          t1 = x[i + 1] - (x[i]**2)
          g[i] = (8.0 * t2) - (16.0 * x[i] * t1)
        end
        g[n - 1] = t1 * 8.0
        g
      end
      result = Numo::Optimize.minimize(fnc: fnc, x_init: x, jcb: jcb, args: n,
                                       bounds: b, maxcor: m, verbose: -1)

      assert(result[:success])
      assert(result[:task].start_with?('CONV'))
      assert_equal(23, result[:n_iter])
      assert_in_delta(1.0834900834300615e-09, result[:fnc], 1e-10)
      assert_kind_of(Numo::DFloat, result[:x])
      assert_kind_of(Numo::DFloat, result[:jcb])

      fnc = proc do |x, n|
        # calculate function value
        f = 0.25 * ((x[0] - 1)**2)
        (1...n).each do |i|
          f += (x[i] - (x[i - 1]**2))**2
        end
        f *= 4.0
        # calculate gradient vector
        g = Numo::DFloat.zeros(n)
        t1 = x[1] - (x[0]**2)
        g[0] = (2.0 * (x[0] - 1.0)) - (16.0 * x[0] * t1)
        (1...(n - 1)).each do |i|
          t2 = t1
          t1 = x[i + 1] - (x[i]**2)
          g[i] = (8.0 * t2) - (16.0 * x[i] * t1)
        end
        g[n - 1] = t1 * 8.0
        # return set of value and vector
        [f, g]
      end
      result = Numo::Optimize.minimize(fnc: fnc, x_init: x, jcb: true, args: n,
                                       bounds: b, maxcor: m, verbose: -1)

      assert(result[:success])
      assert(result[:task].start_with?('CONV'))
      assert_equal(23, result[:n_iter])
      assert_in_delta(1.0834900834300615e-09, result[:fnc], 1e-10)
      assert_kind_of(Numo::DFloat, result[:x])
      assert_kind_of(Numo::DFloat, result[:jcb])
    end

    def test_minimize_lbfgsb_driver2
      n = 25
      m = 5
      pgtol = (5.80702e-15 + 1) * 1e-10
      x = Numo::DFloat.zeros(n) + 3
      b = Numo::DFloat.zeros(n, 2)
      0.step(n - 1, 2) do |i|
        b[i, 0] = 1
        b[i, 1] = 100
      end
      1.step(n - 1, 2) do |i|
        b[i, 0] = -100
        b[i, 1] = 100
      end
      fnc = proc do |x, n|
        f = 0.25 * ((x[0] - 1)**2)
        (1...n).each do |i|
          f += (x[i] - (x[i - 1]**2))**2
        end
        f * 4.0
      end
      jcb = proc do |x, n|
        g = Numo::DFloat.zeros(n)
        t1 = x[1] - (x[0]**2)
        g[0] = (2.0 * (x[0] - 1.0)) - (16.0 * x[0] * t1)
        (1...(n - 1)).each do |i|
          t2 = t1
          t1 = x[i + 1] - (x[i]**2)
          g[i] = (8.0 * t2) - (16.0 * x[i] * t1)
        end
        g[n - 1] = t1 * 8.0
        g
      end
      result = Numo::Optimize.minimize(fnc: fnc, x_init: x, jcb: jcb, args: n,
                                       bounds: b, maxcor: m, factr: 0, pgtol: pgtol,
                                       verbose: -1)

      assert(result[:success])
      assert(result[:task].start_with?('CONVERGENCE: NORM_OF_PROJECTED_GRADIENT_<=_PGTOL'))
      assert_equal(46, result[:n_iter])
      assert_in_delta(5.80702e-15, result[:fnc], 1e-15)
      assert_kind_of(Numo::DFloat, result[:x])
      assert_kind_of(Numo::DFloat, result[:jcb])
    end

    def test_minimize_lbfgsb_driver3
      n = 1000
      m = 10
      pgtol = (5.35267e-22 + 1) * 1e-10
      x = Numo::DFloat.zeros(n) + 3
      b = Numo::DFloat.zeros(n, 2)
      0.step(n - 1, 2) do |i|
        b[i, 0] = 1
        b[i, 1] = 100
      end
      1.step(n - 1, 2) do |i|
        b[i, 0] = -100
        b[i, 1] = 100
      end
      fnc = proc do |x|
        n = x.size
        f = 0.25 * ((x[0] - 1)**2)
        (1...n).each do |i|
          f += (x[i] - (x[i - 1]**2))**2
        end
        f * 4.0
      end
      jcb = proc do |x|
        n = x.size
        g = Numo::DFloat.zeros(n)
        t1 = x[1] - (x[0]**2)
        g[0] = (2.0 * (x[0] - 1.0)) - (16.0 * x[0] * t1)
        (1...(n - 1)).each do |i|
          t2 = t1
          t1 = x[i + 1] - (x[i]**2)
          g[i] = (8.0 * t2) - (16.0 * x[i] * t1)
        end
        g[n - 1] = t1 * 8.0
        g
      end
      result = Numo::Optimize.minimize(fnc: fnc, x_init: x, jcb: jcb, args: n,
                                       bounds: b, maxcor: m, factr: 0, pgtol: pgtol,
                                       verbose: -1)

      assert(result[:success])
      assert(result[:task].start_with?('CONVERGENCE: NORM_OF_PROJECTED_GRADIENT_<=_PGTOL'))
      assert_equal(49, result[:n_iter])
      assert_in_delta(5.35267e-22, result[:fnc], 1e-22)
      assert_kind_of(Numo::DFloat, result[:x])
      assert_kind_of(Numo::DFloat, result[:jcb])
      assert_equal(n, result[:x].size)
      assert_equal(n, result[:jcb].size)
    end

    def test_minimize_scg
      x = Numo::DFloat.zeros(2)
      args = [2, 3, 7, 8, 9, 10]
      fnc = proc do |x, a, b, c, d, e, f|
        u = x[0]
        v = x[1]
        (a * (u**2)) + (b * u * v) + (c * (v**2)) + (d * u) + (e * v) + f
      end
      jcb = proc do |x, a, b, c, d, e, _f|
        u = x[0]
        v = x[1]
        gu = (2 * a * u) + (b * v) + d
        gv = (b * u) + (2 * c * v) + e
        Numo::DFloat[gu, gv]
      end
      result = Numo::Optimize.minimize(method: 'SCG', fnc: fnc, x_init: x, jcb: jcb, args: args)
      error = (result[:x] - Numo::DFloat[-1.80847, -0.25533]).abs.max

      assert_operator(error, :<, 1e-4)
      assert_in_delta(1.61702127, result[:fnc], 1e-6)
      assert_equal(9, result[:n_iter])
      assert_equal(10, result[:n_fev])
      assert_equal(18, result[:n_jev])

      fnc = proc do |x, a, b, c, d, e, f|
        # function value
        u = x[0]
        v = x[1]
        f = (a * (u**2)) + (b * u * v) + (c * (v**2)) + (d * u) + (e * v) + f
        # gradient vector
        gu = (2 * a * u) + (b * v) + d
        gv = (b * u) + (2 * c * v) + e
        g = Numo::DFloat[gu, gv]
        # return set of value and vector
        [f, g]
      end
      result = Numo::Optimize.minimize(method: 'SCG', fnc: fnc, x_init: x, jcb: true, args: args)
      error = (result[:x] - Numo::DFloat[-1.80847, -0.25533]).abs.max

      assert_operator(error, :<, 1e-4)
      assert_in_delta(1.61702127, result[:fnc], 1e-6)
      assert_equal(9, result[:n_iter])
      assert_equal(10, result[:n_fev])
      assert_equal(18, result[:n_jev])
    end

    def test_fmin_nelder_mead
      x = Numo::DFloat.zeros(2)
      args = [2, 3, 7, 8, 9, 10]
      fnc = proc do |x, a, b, c, d, e, f|
        u = x[0]
        v = x[1]
        (a * (u**2)) + (b * u * v) + (c * (v**2)) + (d * u) + (e * v) + f
      end
      result = Numo::Optimize::NelderMead.fmin(fnc, x, args)
      error = (result[:x] - Numo::DFloat[-1.80847, -0.25533]).abs.max

      assert_operator(error, :<, 1e-4)
      assert_in_delta(1.61702127, result[:fnc], 1e-6)
      assert_equal(78, result[:n_iter])
      assert_equal(154, result[:n_fev])
    end
  end
end
