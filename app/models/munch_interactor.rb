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
    elsif command[:type] == 'total'
      munch_total(params, user, command)
    elsif command[:type] == 'imout'
      munch_leave(params, user, command)
    elsif command[:type] == 'help'
      munch_help(params, user, command)  
    elsif command[:type] == 'debug'
      #`curl -X POST --data-urlencode 'payload={"channel": "#general", "username": "webhookbot", "text": "This is posted to #general and comes from a bot named webhookbot.", "icon_emoji": ":ghost:"}' https://hooks.slack.com/services/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
      message("#{user.to_slack_s}", command[:args])
    elsif command[:type] == 'myvenmo'
      munch_myvenmo(params, user, command)         
    else
      "I got #{user.to_slack_s} type: `#{command[:type]}` args: `#{command[:args]}`"
    end
  end

  def self.message(channel, message)
    payload = {
      "channel" => channel,
      "username" => "munchie",
      "icon_emoji" => ":munchie:",
      "text" => message,
    }

    data = "payload=#{payload.to_json}"
    string = data.inspect.gsub("$", '\$')

    Rails.logger.info(string)

    `curl -X POST --data-urlencode #{string} https://hooks.slack.com/services/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`
  end

  def self.munch_total(params, user, command)
    plan = Plan.where(:user => user, :total => nil).last

    if command[:args] =~ /(\d+\.?\d*)/
      if plan
        total = $1
        plan.update_attributes!(:total => total)

        amnt = (Float(total) / (plan.users.size + 1)).ceil

        plan.users.each do |u|
          username = "#{u.to_slack_s}"
          venmo_handle = URI.escape(plan.user.venmo_handle)
          identifier = plan.location.identifier

          if u.venmo_handle.present? && plan.user.venmo_handle.present?
            venmo_url = "https://venmo.com/?txn=payment&recipients=#{venmo_handle}&amount=#{amnt}&note=#{identifier}&audience=public"

            message(username, "Please use vemmo to pay #{plan.user.to_slack_s} <#{venmo_url}|$#{amnt}>")
          else
            message(username, "Please use cash to pay #{plan.user.to_slack_s} $#{amnt}")
          end
        end

        "Charged each user $#{amnt}"
      else
        "Already had a total set!"
      end
    else
      "Bad total!"
    end
  end

  def self.munch_options(params, user, command)
    Location.all.map(&:to_short_slack_s).join("\n\n")
  end

  def self.munch_help(params, user, command)
    "Hungry? Here's some stuff you can do with Munchie!\n
    /munchie options = list of the available locations to eat\n
    /munchie suggestions = list of plans people have already made\n
    /munchie suggest <location> = creates a plan for others to join\n
    /munchie imin <location> <order> = joins a pre-existing plan\n
    /munchie total <amount ex. $24.50> = divides order total among people in group\n
    /munchie myvenmo <venmo username> = adds your venmo name to your account"
  end

  def self.munch_join(params, user, command)
    args = command[:args].split
    location = Location.where(:identifier => args.first).first
    order = args[1..-1].join(" ")

    if location && location.plans.active.exists?
      user.plan_users.create({
        :plan => location.plans.active.first,
        :order => order,
      })

      "Enjoy #{location.to_short_slack_s}"
    else
      "No plan for "
    end
  end
  
  def self.munch_leave(params, user, command)
    args = command[:args].split
    location = Location.where(:identifier => args.first).first

    user.plans.find(location).destroy
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
    time = if args[1].present?
      args[1].to_i.minutes.from_now
    else
      10.minutes.from_now
    end


    if location
      if Plan.active.where(:location => location).exists?
        "#{location.to_short_slack_s} has already been suggested!"
      else
        Plan.create({
          :user     => user,
          :location => location,
          :eta_at   => time,
        })

        msg = "#{location.to_short_slack_s} has been suggested by #{user.to_slack_s}! Leaving in #{ActionController::Base.helpers.distance_of_time_in_words(Time.now, time)}...".inspect
        message("#munchie", msg)

        nil
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

  def self.munch_myvenmo(params, user, command)
    venmo = args
    user.update_attributes!({
      :venmo_handle => venmo
    })

    "Thanks for setting up Venmo!" 
  end
  
end
