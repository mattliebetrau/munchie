class MunchInteractor
  def self.munch(params)
    user = user_from_params(params)
    command = parse_command(params[:text])

    "I got @#{user.slack_handle} type: `#{command[:type]}` args: `#{command[:args]}`"
  end

  def self.parse_command(text)
    text = text.to_s.strip

    if text =~ /([^\s]*)\s*(.*)/
      {
        :type => $1,
        :args => $2.strip,
      }
    end
  end

  def self.user_from_params(params)
    User.where({
      :slack_handle => params[:user_name].downcase
    }).first_or_create
  end
end
