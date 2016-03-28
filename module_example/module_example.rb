require_relative 'test_helper'

class Module_Example < Minitest::Test

  include Utilities
  include HomeForm

  def setup
    launch('http://trabulmonkee.com/the-app/')
  end

  def teardown
    quit
  end
  
  def test_module_example

    form_data = {
      'fname'    => 'trabul',
      'lname'    => 'monkee',
      'email'    => 'trabulmonkee@example.com',
      'profound' => 'Do or Do Not there is no try',
      'fcolor'   => 'green',
      'fvehicle' => 'Hybrid'    
    }

    b, m = login
    assert(b, m)
    b, m = menu_nav('Admin')
    assert(b, m)
    b, m = menu_nav('JS Popups')
    assert(b, m)
    b, m = menu_nav('FAQ')
    assert(b, m)
    b, m = menu_nav('Home')
    assert(b, m)
    b, m = populate_and_submit_form(form_data)
    assert(b, m)
    b, m = verify_form_submission(form_data)
    assert(b, m)
    b, m = logout
    assert(b, m)
  end

end