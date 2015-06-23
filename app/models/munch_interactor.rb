class MunchInteractor
  def self.munch(params)
    user = user_from_params(params)

    "Hey @#{user.slack_handle} `#{params[:text]}` yourself!"
  end

  def user_from_params(params)
    User.where({
      :slack_handle => params[:user_name].downcase
    }).first_or_create
  end
end
