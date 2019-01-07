from setuptools import setup
setup(
    name='py_qrgen',
    version='0.0.1',
    entry_points={
        'console_scripts': [
            'py_qrgen=py_qrgen:run'
        ]
    }
)