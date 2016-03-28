require_relative 'test_helper'

class POM_Example < Minitest::Test

  def setup
    @driver = Selenium::WebDriver.for :firefox
    ENV['base_url'] = 'http://trabulmonkee.com/the-app'
  end

  def teardown
    @driver.quit
  end
  
  def test_pom_example

    form_data = {
      'fname'    => 'trabul',
      'lname'    => 'monkee',
      'email'    => 'trabulmonkee@example.com',
      'profound' => 'Do or Do Not there is no try',
      'fcolor'   => 'green',
      'fvehicle' => 'Hybrid'    
    }

    login_page = LoginPage.new(@driver)
    home_page = login_page.login
    admin_page = home_page.menu_nav('Admin')
    js_page = admin_page.menu_nav('JS Popups')
    faq_page = js_page.menu_nav('FAQ')
    home_page = js_page.menu_nav('Home')
    result_page = home_page.populate_and_submit_form(form_data)
    b, m = result_page.verify_form_submission(form_data)
    assert(b, m)
    logout_page = result_page.logout
  end

end