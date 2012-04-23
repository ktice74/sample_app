class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end
  def create
    @user = User.new(params[:user])
    if @user.save
<<<<<<< HEAD
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
=======
      # Handle a successful save.
>>>>>>> sign-up
    else
      render 'new'
    end
  end
end