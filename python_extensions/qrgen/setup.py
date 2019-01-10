from setuptools import setup
setup(
    name='qrgen',
    version='0.0.1',
    entry_points={
        'console_scripts': [
            'qrgen=qrgen:run'
        ]
    }
)