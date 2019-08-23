#!/usr/bin/env python
"""
    python -c "import setup, ubelt; print(ubelt.repr2(setup.KWARGS))"
"""
from __future__ import absolute_import, division, print_function
from collections import OrderedDict
import os
import skbuild_template  # TODO: integrate into skbuild  # NOQA
import skbuild as skb
import ubelt as ub


NAME = 'pyflann'
AUTHORS = list(ub.oset(['Marius Muja']) | skb.utils.parse_authors())
AUTHOR_EMAIL = 'mariusm@cs.ubc.ca'
URL = 'http://www.cs.ubc.ca/~mariusm/flann/'
LICENSE = 'BSD'
DESCRIPTION = 'FLANN - Fast Library for Approximate Nearest Neighbors'
VERSION = '1.10.0'  # TODO: parse


KWARGS = OrderedDict(
    name=NAME,
    version=VERSION,
    author=', '.join(AUTHORS[0:1]),
    author_email=AUTHOR_EMAIL,
    description=DESCRIPTION,
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    url=URL,
    license=LICENSE,
    install_requires=skb.utils.parse_requirements('requirements/runtime.txt'),
    packages=skb.utils.find_packages('src/python'),
    extras_require={
        'all': skb.utils.parse_requirements('requirements.txt'),
        'tests': skb.utils.parse_requirements('requirements/tests.txt'),
        'build': skb.utils.parse_requirements('requirements/build.txt'),
        'runtime': skb.utils.parse_requirements('requirements/runtime.txt'),
    },
    include_package_data=True,
    package_dir={
        'pyflann': 'src/python/pyflann',
        # 'lib': 'lib',  # hack
    },
    package_data={
        NAME: (
            ['*{}'.format(skb.utils.get_lib_ext())] +
            ['lib.*{}'.format(skb.utils.get_lib_ext())] +
            ['*{}*'.format(skb.utils.get_lib_ext())] +
            ['lib.*{}*'.format(skb.utils.get_lib_ext())] +
            (['Release\\*.dll'] if os.name == 'nt' else []) +
            (['lib/Release\\*.dll'] if os.name == 'nt' else [])
        ),
    },
    # packages=['pyflann', 'pyflann.lib'],
    # package_dir={'pyflann.lib': find_path() },
    # package_data={'pyflann.lib': ['libflann.so', 'flann.dll', 'libflann.dll', 'libflann.dylib']},
    # List of classifiers available at:
    # https://pypi.python.org/pypi?%3Aaction=list_classifiers
    classifiers=[
        skb.utils.CLASSIFIER_STATUS_OPTIONS['mature'],
        skb.utils.CLASSIFIER_LICENSE_OPTIONS['bsd'],
        'Intended Audience :: Developers',
        'Intended Audience :: Developers',
        'Intended Audience :: Science/Research',
        'Operating System :: MacOS :: MacOS X',
        'Operating System :: Unix',
        'Topic :: Software Development :: Libraries :: Python Modules',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Topic :: Scientific/Engineering :: Artificial Intelligence',
        'Topic :: Scientific/Engineering :: Image Recognition'
    ],
    cmake_args=[
        '-DBUILD_MATLAB_BINDINGS=OFF',
        '-DBUILD_DOC=OFF',
    ],
    ext_modules=skb.utils.EmptyListWithLength(),  # hack for including ctypes bins
)

if __name__ == '__main__':
    skb.setup(**KWARGS)
