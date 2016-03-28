require 'rubygems'
require 'minitest/autorun'
require 'selenium-webdriver'

class Base < Minitest::Test
  
  attr_reader :driver
  
  def initialize(driver)
    @driver = driver
  end
  
  def goto(url='/')
    driver.manage.timeouts.implicit_wait = 10
    driver.manage.window.maximize
    driver.manage.delete_all_cookies
    driver.get("#{ENV['base_url']}#{url}")
  end
  
  def verify_title(exp_title)
    act_title = driver.title
    if exp_title.to_s.downcase != act_title.to_s.downcase
       raise "expected page title not found\n" +
             "actual title   : #{act_title}\n" +
             "expected title : #{exp_title}"
    else
      true
    end
  end

  def menu_nav(menu)
    driver.find_element( link_text: menu ).click
    verify_title( "the-app - #{menu}" )
    case menu.to_s.downcase
      when 'home'
        return HomePage.new(driver)
      when 'admin'
        return AdminPage.new(driver)
      when 'js popups'
        return JSPopupsPage.new(driver)
      when 'faq'
        return FAQPage.new(driver)
      when 'logout'
        return LogoutPage.new(driver)
      else # unknown
        raise ArgumentError, "no case found for menu: #{menu}"
    end
  end
  
  def logout
    menu_nav('Logout')
  end

end

class LoginPage < Base

  def initialize(driver)
    super
    @driver = driver
    goto
  end
 
  def login(u='test', p='test')
    verify_title('the-app - Login')
    driver.find_element( id: 'edtLogin' ).send_keys u
    driver.find_element( id: 'edtPassword' ).send_keys p
    driver.find_element( id: 'btnLogin' ).click
    return HomePage.new(driver)
  end
  
end

class LogoutPage < Base

  def initialize(driver)
    super
    @driver = driver
    verify_title( 'the-app - Logout' )
  end
  
end

class AdminPage < Base

  def initialize(driver)
    super
    @driver = driver
    verify_title( 'the-app - Admin' )
  end
  
end

class JSPopupsPage < Base

  def initialize(driver)
    super
    @driver = driver
    verify_title( 'the-app - JS Popups' )
  end
  
end

class FAQPage < Base

  def initialize(driver)
    super
    @driver = driver
    verify_title( 'the-app - FAQ' )
  end
  
end

class HomePage < Base

  def initialize(driver)
    super
    @driver = driver
    verify_title( 'the-app - Home' )
  end

  def populate_and_submit_form(data)
    driver.find_element( id: 'edtFirstName' ).send_keys data['fname']
    driver.find_element( id: 'edtLastName' ).send_keys data['lname']
    driver.find_element( id: 'edtEmail' ).send_keys data['email']
    driver.find_element( id: 'taProfound' ).send_keys data['profound']
    driver.find_element( css: "input[name='rGrpFavColors'][value='#{data['fcolor']}']" ).click
    list = Selenium::WebDriver::Support::Select.new( driver.find_element( id: 'lstFavCar' ) )
    list.select_by( :text, data['fvehicle'] )
    driver.find_element( id: 'btnSubmit' ).click
    return ResultsPage.new(driver)
  end

end

class ResultsPage < Base

  def initialize(driver)
    super
    @driver = driver
    verify_title( 'the-app - Results' )
  end
  
  def verify_form_submission(exp_data)
    b, m = false, "default msg [#{__method__}] failed"
    act_data = Hash.new('unknown/not found')
    table = driver.find_element( id: 'tblResults' )
    head_columns = table.find_elements( css: 'th' )
    data_columns = table.find_elements( css: 'td' )
    head_columns.each_with_index do | val, index |
      case val.text.to_s.downcase.strip
        when 'first name:'
          act_data['fname'] = data_columns[index].text
        when 'last name:'
          act_data['lname'] = data_columns[index].text
        when 'email:'
          act_data['email'] = data_columns[index].text
        when 'profound saying:'
          act_data['profound'] = data_columns[index].text
        when 'favorite color:'
          act_data['fcolor'] = data_columns[index].text
        when 'favorite vehicle:'
          act_data['fvehicle'] = data_columns[index].text
        else
          # unknown column heading not checking as part of the example
      end
    end 
    if act_data != exp_data
      m = "expected data not found\n" +
          "actual data   : #{act_data.inspect}\n" +
          "expected data : #{exp_data.inspect}"
    else
      b, m = true, 'success'
    end
    return b, m
  end

end