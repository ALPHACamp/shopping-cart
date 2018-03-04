class Admin::AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!

  layout "admin"
end
