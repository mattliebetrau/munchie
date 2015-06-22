class MunchieController < ApplicationController
  def munch
    render :text => "Hey @#{params[:user_name]} `#{params[:text]}` yourself!"
  end
end
