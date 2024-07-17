require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def test_cascade_games_delete
    todd = users(:todd)
    todd.destroy!

    assert_raises ActiveRecord::RecordNotFound do
      games(:tes3)
    end
  end



end