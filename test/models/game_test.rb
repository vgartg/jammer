class GameTest < ActiveSupport::TestCase
  def setup
    @game = games(:tes3)
    @todd = users(:todd)
  end

  def test_cover_attachment
    game = Game.new(name: "New Game", description: "Game Description", author: @todd)
    assert_not game.cover.attached?
    game.cover.attach(io: File.open(Rails.root.join('test/fixtures/files/cover.jpg')), filename: 'cover.jpg', content_type: 'image/jpg')
    assert game.cover.attached?
  end

  def test_game_deletion
    game = games(:tes3)
    assert_difference 'Game.count', -1 do
      game.destroy
    end
  end

  def test_game_with_tags
    game = Game.create(name: "Tagged Game", description: "Description", author: @todd)
    tag1 = Tag.create(name: "Action")
    tag2 = Tag.create(name: "Adventure")
    game.tags << [tag1, tag2]
    assert_includes game.tags, tag1
    assert_includes game.tags, tag2
  end

  def test_game_without_tags
    game = Game.create(name: "Untagged Game", description: "Description", author: @todd)
    assert_empty game.tags
  end
end
