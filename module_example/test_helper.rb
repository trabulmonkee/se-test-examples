require 'rubygems'
require 'minitest/autorun'
require 'selenium-webdriver'

module Utilities

  def launch(url)
    @b = Selenium::WebDriver.for :firefox
    @b.manage.timeouts.implicit_wait = 10
    @b.manage.window.maximize
    @b.manage.delete_all_cookies
    @b.get url
  end

  def quit
    @b.quit unless @b.nil?
  end

  def login(u='test', p='test')
    b, m = false, "default msg [#{__method__}] failed"
    b, m = verify_title('the-app - Login')
    if b
      @b.find_element( id: 'edtLogin' ).send_keys u
      @b.find_element( id: 'edtPassword' ).send_keys p
      @b.find_element( id: 'btnLogin' ).click
      b, m = verify_title( 'the-app - Home' )
    end
    return b, m
  end

  def logout
    b, m = false, "default msg [#{__method__}] failed"
    @b.find_element( link_text: 'Logout' ).click
    b, m = verify_title( 'the-app - Logout' )
    return b, m
  end

  def verify_title(exp_title)
    b, m = false, "default msg [#{__method__}] failed"
    act_title = @b.title
    if act_title.to_s.downcase != exp_title.to_s.downcase
      m = "expected page title not found\n" +
          "actual title   : #{act_title}\n" +
          "expected title : #{exp_title}"
    else
      b, m = true, 'success'
    end
    return b, m
  end

  def menu_nav(menu)
    b, m = false, "default msg [#{__method__}] failed"
    @b.find_element( link_text: menu ).click
    b, m = verify_title( "the-app - #{menu}" )
    return b, m
  end

end

module HomeForm

  def populate_and_submit_form(data)
    b, m = false, "default msg [#{__method__}] failed"
    @b.find_element( id: 'edtFirstName' ).send_keys data['fname']
    @b.find_element( id: 'edtLastName' ).send_keys data['lname']
    @b.find_element( id: 'edtEmail' ).send_keys data['email']
    @b.find_element( id: 'taProfound' ).send_keys data['profound']
    @b.find_element( css: "input[name='rGrpFavColors'][value='#{data['fcolor']}']" ).click
    list = Selenium::WebDriver::Support::Select.new( @b.find_element( id: 'lstFavCar' ) )
    list.select_by( :text, data['fvehicle'] )
    @b.find_element( id: 'btnSubmit' ).click
    b, m = verify_title( 'the-app - Results')
    return b, m
  end
  
  def verify_form_submission(exp_data)
    b, m = false, "default msg [#{__method__}] failed"
    b, m = verify_title( 'the-app - Results')
    if b
      b = false
      act_data = Hash.new('unknown/not found')
      table = @b.find_element( id: 'tblResults' )
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
    end
    return b, m
  end

end