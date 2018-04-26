# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authorize_user!

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new
    @user.assign_attributes(user_params)

    if @user.valid?
      @user.save
      flash[:notice] = t('contribute.users.flash.create.success')
      redirect_to action: :index
    else
      render action: :new, status: 400
    end
  end

  def edit
    @user = User.find(params[:id])
    render action: :new
  end

  def update
    @user = User.find(params[:id])
    @user.assign_attributes(user_params)

    if @user.valid?
      @user.save
      flash[:notice] = t('contribute.users.flash.update.success')
      redirect_to action: :index
    else
      render action: :new, status: 400
    end
  end

  def delete
    @user = User.find(params[:id])
    unless @user.destroyable?
      render_http_status(400)
      return
    end
  end

  def destroy
    @user = User.find(params[:id])
    begin
      @user.destroy
      flash[:notice] = t('contribute.users.flash.destroy.success')
    rescue Mongoid::Errors::DeleteRestriction
      flash[:notice] = t('contribute.users.flash.destroy.failure')
    end
    redirect_to action: :index
  end

  private

  def user_params
    params.require(:user).permit(
      [
        :email, :password, :password_confirmation, :role, event_ids: []
      ]
    ).reject! { |key, value| key.start_with?('password') && value.blank? }
  end

  def authorize_user!
    authorize! :manage, User
  end
end
