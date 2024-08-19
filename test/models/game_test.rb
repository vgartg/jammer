require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @game = games(:tes3)
    @todd = users(:todd)
  end
  def test_author_association
    assert_equal @todd, @game.author
  end

  def test_tags_limit
    game = games(:tes3)
    11.times do |i|
      game.tags.build(name: "Tag#{i}")
    end
    assert_not game.valid?
    assert_includes game.errors[:tags], "Можно выбрать не более 10 тегов"
  end
end
