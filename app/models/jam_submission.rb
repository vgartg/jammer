# frozen_string_literal: true

class JamSubmission < ActiveRecord::Base
  belongs_to :game, optional: true
  belongs_to :jam
  belongs_to :user
end
