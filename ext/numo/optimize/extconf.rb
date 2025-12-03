# frozen_string_literal: true

require 'mkmf'
require 'numo/narray/alt'

$LOAD_PATH.each do |lp|
  if File.exist?(File.join(lp, 'numo/numo/narray.h'))
    $INCFLAGS = "-I#{lp}/numo #{$INCFLAGS}"
    break
  end
end

abort 'numo/narray.h not found.' unless have_header('numo/narray.h')

if RUBY_PLATFORM.match?(/mswin|cygwin|mingw/)
  $LOAD_PATH.each do |lp|
    if File.exist?(File.join(lp, 'numo/narray/libnarray.a'))
      $LDFLAGS = "-L#{lp}/numo/narray #{$LDFLAGS}"
      break
    end
  end
  abort 'libnarray.a not found.' unless have_library('narray', 'nary_new')
end

$defs << '-DUSE_INT64' if with_config('use-int64', false)

$srcs = Dir.glob("#{$srcdir}/**/*.c").map { |path| File.basename(path) }

blas_dir = with_config('blas-dir')
$LDFLAGS = "-L#{blas_dir} #{$LDFLAGS}" unless blas_dir.nil?

if RUBY_PLATFORM.include?('darwin') && Gem::Version.new('3.1.0') <= Gem::Version.new(RUBY_VERSION) && try_link(
  'int main(void){return 0;}', '-Wl,-undefined,dynamic_lookup'
)
  $LDFLAGS << ' -Wl,-undefined,dynamic_lookup'
end

blas_lib = with_config('blas-lib')
unless blas_lib.nil?
  abort "#{blas_lib} not found." unless have_library(blas_lib)
  $srcs.delete('blas.c')
end

$VPATH << '$(srcdir)/src'

create_makefile('numo/optimize/optimize')
