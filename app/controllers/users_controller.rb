class UsersController < ApplicationController
  layout 'profile'

  before_filter :require_current_user, only: [:show, :edit, :update]

  def show
    @user = User.find(current_user.id)
  end

  def new
    @user = User.new
    render :layout => 'signup'
  end

  def create
    @user = User.new(params[:user].merge(params[:date]))
    if @user.save
      UserMailer.signup_confirmation_email(@user).deliver
      session[:user_id] = @user.id

      if session[:bid_data] && session[:bid_data][:auction_id]
        route_user(@user)
      else
        flash[:notice] = "Thanks for signin up! Click here to make changes to your account:
                        #{self.class.helpers.link_to( 'Edit Your Account', edit_profile_path) }".html_safe
        redirect_to auctions_path
      end
    else
      flash.now[:alert] = "You entered invalid information, please try again"
      render :new, :layout => 'signup'
    end
  end


  def edit
    @user = User.find(current_user.id)
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user].merge(params[:date]))
      if session[:bid_data] && session[:bid_data][:auction_id]
        route_user(@user)
      else
        redirect_to profile_path, notice: "Profile updated!"
      end
    else
      render :edit
    end
  end

end
