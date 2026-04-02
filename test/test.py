import pytest
from src import main

@pytest.fixture(scope='module')
def setup_data():
    data = {'key': 'value'}
    return data

def test_module_setup(setup_data):
    assert setup_data['key'] == 'value'

if __name__ == '__main__':
    pytest.main()