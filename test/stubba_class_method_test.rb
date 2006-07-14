require 'test_helper'
require 'mocha/stubba_class_method'
require 'mocha/mock'

class StubbaClassMethodTest < Test::Unit::TestCase
  
  include Mocha

  def test_should_provide_hidden_version_of_method_name
    method = StubbaClassMethod.new(nil, :original_method_name)
    assert_equal '__stubba__original_method_name__stubba__', method.hidden_method
  end
  
  def test_should_provide_hidden_version_of_method_name_with_question_mark
    method = StubbaClassMethod.new(nil, :original_method_name?)
    assert_equal '__stubba__original_method_name_question_mark__stubba__', method.hidden_method
  end
  
  def test_should_provide_hidden_version_of_method_name_with_exclamation_mark
    method = StubbaClassMethod.new(nil, :original_method_name!)
    assert_equal '__stubba__original_method_name_exclamation_mark__stubba__', method.hidden_method
  end
  
  def test_should_hide_original_method
    klass = Class.new { def self.method_x; end }
    method = StubbaClassMethod.new(klass, :method_x)
    hidden_method_x = method.hidden_method
    
    method.hide_original_method

    assert klass.respond_to?(hidden_method_x)
  end
  
  def test_should_not_hide_original_method_if_method_not_defined
    klass = Class.new
    method = StubbaClassMethod.new(klass, :method_x)
    hidden_method_x = method.hidden_method
    
    method.hide_original_method

    assert_equal false, klass.respond_to?(hidden_method_x)
  end
  
  def test_should_define_a_new_method_which_should_call_mocha_method_missing
    klass = Class.new { def self.method_x; end }
    mocha = Mock.new
    klass.define_instance_method(:mocha) { mocha }
    mocha.expects(:method_x).with(:param1, :param2).returns(:result)
    method = StubbaClassMethod.new(klass, :method_x)
    
    method.define_new_method
    result = klass.method_x(:param1, :param2)
    
    assert_equal :result, result
    mocha.verify
  end
  
  def test_should_remove_new_method
    klass = Class.new { def self.method_x; end }
    method = StubbaClassMethod.new(klass, :method_x)
    
    method.remove_new_method
    
    assert_equal false, klass.respond_to?(:method_x)
  end

  def test_should_restore_original_method
    klass = Class.new { def self.method_x; end }
    method = StubbaClassMethod.new(klass, :method_x)
    hidden_method_x = method.hidden_method.to_sym
    klass.define_instance_method(hidden_method_x) { :original_result }

    method.restore_original_method
    
    assert_equal :original_result, klass.method_x 
    assert !klass.respond_to?(hidden_method_x)
  end

  def test_should_not_restore_original_method_if_hidden_method_is_not_defined
    klass = Class.new { def self.method_x; :new_result; end }
    method = StubbaClassMethod.new(klass, :method_x)

    method.restore_original_method
    
    assert_equal :new_result, klass.method_x
  end

  def test_should_call_hide_original_method
    klass = Class.new { def self.method_x; end }
    method = StubbaClassMethod.new(klass, :method_x)
    method.define_instance_accessor(:hide_called)
    method.replace_instance_method(:hide_original_method) { self.hide_called = true }
    
    method.stub
    
    assert method.hide_called
  end

  def test_should_call_define_new_method
    klass = Class.new { def self.method_x; end }
    method = StubbaClassMethod.new(klass, :method_x)
    method.define_instance_accessor(:define_called)
    method.replace_instance_method(:define_new_method) { self.define_called = true }
    
    method.stub
    
    assert method.define_called
  end
  
  def test_should_call_remove_new_method
    klass = Class.new { def self.method_x; end }
    klass.define_instance_method(:reset_mocha) { }
    method = StubbaClassMethod.new(klass, :method_x)
    method.define_instance_accessor(:remove_called)
    method.replace_instance_method(:remove_new_method) { self.remove_called = true }
    
    method.unstub
    
    assert method.remove_called
  end

  def test_should_call_restore_original_method
    klass = Class.new { def self.method_x; end }
    klass.define_instance_method(:reset_mocha) { }
    method = StubbaClassMethod.new(klass, :method_x)
    method.define_instance_accessor(:restore_called)
    method.replace_instance_method(:restore_original_method) { self.restore_called = true }
    
    method.unstub
    
    assert method.restore_called
  end

  def test_should_call_reset_mocha
    klass = Class.new { def self.method_x; end }
    klass.define_instance_accessor(:reset_called)
    klass.define_instance_method(:reset_mocha) { self.reset_called = true }
    method = StubbaClassMethod.new(klass, :method_x)
    method.replace_instance_method(:restore_original_method) { }
    
    method.unstub
    
    assert klass.reset_called
  end

end