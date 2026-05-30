namespace :achievements do
  desc "Award achievements retroactively to all users who already meet the conditions"
  task backfill: :environment do
    users = User.all
    puts "Checking #{users.count} users..."
    awarded_total = 0

    users.find_each do |user|
      before = user.user_achievements.count
      AchievementService.check_and_award(user)
      after = user.user_achievements.reload.count
      diff = after - before
      if diff > 0
        puts "  #{user.name} (id=#{user.id}): +#{diff} achievement(s)"
        awarded_total += diff
      end
    end

    puts "Done. Awarded #{awarded_total} achievement(s) in total."
  end
end
