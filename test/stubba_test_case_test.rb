require 'test_helper'
require 'mocha/stubba_test_case'
require 'mocha/mock'

class StubbaTestCaseTest < Test::Unit::TestCase
  
  include Mocha
  
  def test_should_instantiate_new_stubba
    test_class = Class.new(Test::Unit::TestCase) { def test_me; end }
    test = test_class.new(:test_me)
    replace_stubba(nil) do
      test.setup
      assert $stubba.is_a?(Stubba)
    end
  end

  def test_should_unstub_all_stubbed_methods
    test_class = Class.new(Test::Unit::TestCase) { def test_me; end }
    test = test_class.new(:test_me)
    stubba = Mock.new(:unstub_all => nil)
    replace_stubba(stubba) do
      test.teardown
    end
    stubba.verify(:unstub_all)
  end

  def test_should_set_stubba_to_nil
    test_class = Class.new(Test::Unit::TestCase) { def test_me; end }
    test = test_class.new(:test_me)
    stubba = Mock.new(:unstub_all => nil)
    replace_stubba(stubba) do
      test.teardown
      assert_nil $stubba
    end
  end

end

