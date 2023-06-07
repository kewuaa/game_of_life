from os import environ
from distutils.unixccompiler import UnixCCompiler

from setuptools import Extension, setup
from setuptools.command.build_ext import build_ext
from Cython.Build import cythonize


class Build(build_ext):
    def build_extensions(self):
        if isinstance(self.compiler, UnixCCompiler):
            if 'zig' in self.compiler.cc:
                self.compiler.dll_libraries = []
                self.compiler.set_executable(
                    'compiler_so',
                    f'{self.compiler.cc} -Wall -O3 -lc++'
                )
                for ext in self.extensions:
                    ext.undef_macros = ['_DEBUG']
        super().build_extensions()


include_dirs = environ['INCLUDE'].split(';')
exts = [
    Extension(
        name='game_of_life.core',
        sources=['src\\game_of_life\\core.pyx'],
        include_dirs=include_dirs,
    )
]
setup(
    ext_modules=cythonize(exts),
    zip_safe=False,
    package_dir={'game_of_life': 'src\\game_of_life'},
    cmdclass={'build_ext': Build}
)
