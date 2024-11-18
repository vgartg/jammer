class ModeratorsController < ApplicationController
  before_action :moderator?
  def index
  end
end