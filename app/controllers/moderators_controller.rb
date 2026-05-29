class ModeratorsController < ApplicationController
  before_action :authenticate_user
  before_action :moderator?
  def index; end
end
