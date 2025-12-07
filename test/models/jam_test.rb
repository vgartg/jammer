require 'test_helper'

class JamTest < ActiveSupport::TestCase
  def setup
    @jam = jams(:jtes3)
    @todd = users(:todd)
  end

  def test_cover_attachment
    jam = Jam.new(name: "New Jam", description: "Jam Description", author: @todd)
    assert_not jam.cover.attached?
    jam.cover.attach(io: File.open(Rails.root.join('test/fixtures/files/cover.jpg')), filename: 'cover.jpg', content_type: 'image/jpg')
    assert jam.cover.attached?
  end

  def test_jam_deletion
    jam = jams(:jtes3)
    assert_difference 'Jam.count', -1 do
      jam.destroy
    end
  end

  def test_jam_with_tags
    jam = Jam.create(name: "Tagged Jam", description: "Description", author: @todd)
    tag1 = Tag.create(name: "Action")
    tag2 = Tag.create(name: "Adventure")
    jam.tags << [tag1, tag2]
    assert_includes jam.tags, tag1
    assert_includes jam.tags, tag2
  end

  def test_jam_without_tags
    jam = Jam.create(name: "Untagged Jam", description: "Description", author: @todd)
    assert_empty jam.tags
  end
end
