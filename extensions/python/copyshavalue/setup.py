from setuptools import setup
setup(
    name='copyshavalue',
    version='0.0.1',
    entry_points={
        'console_scripts': [
            'copyshavalue=copyshavalue:run'
        ]
    }
)