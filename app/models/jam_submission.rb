# frozen_string_literal: true

class JamSubmission < ActiveRecord::Base
  belongs_to :game
  belongs_to :jam
  belongs_to :user

  def create
    @submission = JamSubmission.new(game_id: params[:game_id], jam_id: params[:jam_id])
    @submission.save
  end
end
