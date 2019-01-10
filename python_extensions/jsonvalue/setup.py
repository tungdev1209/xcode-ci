from setuptools import setup
setup(
    name='jsonvalue',
    version='0.0.1',
    entry_points={
        'console_scripts': [
            'jsonvalue=jsonvalue:run'
        ]
    }
)