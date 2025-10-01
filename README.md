# Numo::Optimize

Numo::Optimize (numo-optimize) provides functions for minimizing objective functions.
This gem is based on [Lbfgsb.rb](https://github.com/yoshoku/lbfgsb.rb) and
[mopti](https://github.com/yoshoku/mopti) by the same author.
As for optimization algorithms, only L-BFGS-B is currently supported.

Please note that numo-optimize depends on [numo-narray-alt](https://github.com/yoshoku/numo-narray-alt), not Numo::NArray.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add numo-optimize
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install numo-optimize
```

## Usage

TODO: Write usage instructions here

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yoshoku/numo-optimize.
This project is intended to be a safe, welcoming space for collaboration,
and contributors are expected to adhere to the [code of conduct](https://github.com/yoshoku/numo-optimize/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [BSD-3-Clause License](https://opensource.org/licenses/BSD-3-Clause).
In addition, L-BFGS-B carries the following condition for use:

This software is freely available, but we expect that all publications describing  work using this software ,
or all commercial products using it, quote at least one of the references given below.
This software is released under the "New BSD License" (aka "Modified BSD License" or "3-clause license").

## Code of Conduct

Everyone interacting in the Numo::Optimize project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yoshoku/numo-optimize/blob/main/CODE_OF_CONDUCT.md).
