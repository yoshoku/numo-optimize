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
