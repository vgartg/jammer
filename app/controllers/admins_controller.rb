class AdminsController < ApplicationController
  before_action :admin?
  def index
  end
end