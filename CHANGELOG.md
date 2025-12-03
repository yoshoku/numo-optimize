## [[0.2.3](https://github.com/yoshoku/numo-optimize/compare/v0.2.2...v0.2.3)] - 2025-12-03

- Update CFLAGS and LDFLAGS for native extensions to match those in [lbfgsb.rb](https://github.com/yoshoku/lbfgsb.rb).

## [[0.2.2](https://github.com/yoshoku/numo-optimize/compare/v0.2.1...v0.2.2)] - 2025-11-18

- Fix to use require for compatibility with distributions installing extensions separately.

## [[0.2.1](https://github.com/yoshoku/numo-optimize/compare/v0.2.0...v0.2.1)] - 2025-11-18

- Set the required version of numo-narray-alt to 0.9.9 or higher.
- Change require statement to explicitly load numo/narray/alt.

## [[0.2.0](https://github.com/yoshoku/numo-optimize/compare/v0.1.0...v0.2.0)] - 2025-10-03

- Add the scaled conjugate gradient method for minimization method:

```ruby
result = Numo::Optimize.minimize(method: 'SCG', ...)
```

- Add the Nelder-Mead method for minimization method:

```ruby
result = Numo::Optimize.minimize(method: 'Nelder-Mead', ...)
```

## [0.1.0] - 2025-10-01

- First release.
