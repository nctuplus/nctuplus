require 'helper'

class TestEmResolvReplace < Test::Unit::TestCase

  should "resolve address without eventmachine" do
    Resolv.any_instance.expects(:em_getaddress).times(0)

    assert_match ::Resolv::AddressRegex, Resolv.getaddress('www.google.com')
  end

  should "resolve address with eventmachine" do
    Resolv.any_instance.expects(:orig_getaddress).times(0)

    EM.run do
      Fiber.new do
        assert_match ::Resolv::AddressRegex, Resolv.getaddress('www.google.com')
        EM.stop
      end.resume
    end
  end

  should "resolve addresses without eventmachine" do
    Resolv.any_instance.expects(:em_getaddress).times(0)

    results = Resolv.getaddresses('www.google.com')
    assert_match ::Resolv::AddressRegex, results.first
  end

  should "resolve addresses with eventmachine" do
    Resolv.any_instance.expects(:orig_getaddresses).times(0)

    EM.run do
      Fiber.new do
        results = Resolv.getaddresses('www.google.com')
        assert_match ::Resolv::AddressRegex, results.first
        EM.stop
      end.resume
    end
  end

  should "resolve localhost with eventmachine" do
    Resolv.any_instance.expects(:orig_getaddresses).times(0)

    EM.run do
      Fiber.new do
        results = Resolv.getaddresses('localhost')
        assert (results.first =~ ::Resolv::AddressRegex || results.first =~ /::/), "Invalid IP #{results}"
        EM.stop
      end.resume
    end
  end

  should "not try to resolve an IP address" do
    Resolv.any_instance.expects(:orig_getaddresses).times(0)

    EM.run do
      Fiber.new do
        results = Resolv.getaddresses('127.0.0.1') # IPv4
        assert (results.first == '127.0.0.1')
        results = Resolv.getaddresses('::1') # IPv6
        assert (results.first == '::1')
        EM.stop
      end.resume
    end
  end

  should "reverse hostname without eventmachine" do
    Resolv.any_instance.expects(:em_getname).times(0)

    assert_equal 'localhost', Resolv.getname('127.0.0.1')
  end

  should "reverse hostname with eventmachine" do
    Resolv.any_instance.expects(:orig_getname).times(0)

    EM.run do
      Fiber.new do
        assert_equal 'localhost', Resolv.getname('127.0.0.1')
        EM.stop
      end.resume
    end
  end
end
