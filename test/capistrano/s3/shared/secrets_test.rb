require 'test_helper'

class Capistrano::S3::Shared::SecretsTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Capistrano::S3::Shared::Secrets::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
