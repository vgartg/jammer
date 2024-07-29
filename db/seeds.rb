default_tags = [
  { name: 'Action' },
  { name: 'Adventure' },
  { name: 'Puzzle' },
  { name: 'RPG' },
  { name: 'Strategy' },
  { name: 'Simulation' },
  { name: 'Sports' },
  { name: 'Racing' },
  { name: 'Shooter' },
  { name: 'Casual' },
  { name: 'Horror' },
  { name: 'Fantasy' },
  { name: 'Multiplayer' },
  { name: 'Singleplayer' },
  { name: 'Open World' },
  { name: 'Sandbox' },
  { name: 'Indie' },
  { name: 'Platformer' },
  { name: 'Arcade' },
  { name: 'Board Game' },
  { name: 'Card Game' },
  { name: 'Educational' },
  { name: 'Fighting' },
  { name: 'Music' },
  { name: 'Survival' }
]

default_tags.each do |tag|
  Tag.find_or_create_by(name: tag[:name])
end

puts "Default tags added."
