class MunchInteractor
  def self.munch(params)
    user = user_from_params(params)
    command = parse_command(params[:text])

    Rails.logger.info(params.inspect)
    Rails.logger.info(command.inspect)

    if command[:type] == 'options'
      munch_options(params, user, command)
    elsif command[:type] == 'suggest'
      munch_suggest(params, user, command)
    elsif command[:type] == 'suggestions'
      munch_suggestions(params, user, command)
    elsif command[:type] == 'imin'
      munch_join(params, user, command)
    else
      "I got @#{user.slack_handle} type: `#{command[:type]}` args: `#{command[:args]}`"
    end
  end

  def self.munch_options(params, user, command)
    Location.all.map(&:to_slack_s).join("\n\n")
  end

  def self.munch_join(params, user, command)
    args = command[:args].split
    location = Location.where(:identifier => args.first).first

    if location && location.plans.active.exists?
      user.plans << location.plans.active.first

      "Enjoy #{location.to_short_slack_s}"
    else
      "No plan for "
    end
  end

  def self.munch_suggestions(params, user, command)
    plans = Plan.active

    if plans.empty?
      location = Location.all.sample

      "There are no current suggestions. How about #{location.to_short_slack_s}?"
    else
      [
        "The following places have been suggested",
        *Plan.active.all.map(&:to_slack_s)
      ].join("\n\n")
    end
  end

  def self.munch_suggest(params, user, command)
    args = command[:args].split
    location = Location.where(:identifier => args.first).first

    if location
      if Plan.active.where(:location => location).exists?
        "#{location.to_short_slack_s} has already been suggested!"
      else
        Plan.create({
          :user     => user,
          :location => location,
          :eta_at   => 5.minutes.from_now,
        })

        "#{location.to_short_slack_s} has been suggested!"
      end
    else
      "Location `#{args.first}` not found."
    end
  end

  def self.parse_command(text)
    text = text.to_s.strip

    if text =~ /([^\s]*)\s*(.*)/
      {
        :type => $1.downcase,
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