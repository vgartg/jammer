every 1.day, at: '11:59 pm' do
  runner 'DailyActivityJob.perform_later'
end
