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
      #`curl -d token="#{params[:token]}" -d channel=@#{user.slack_handle} -d text=#{command[:args].inspect} -d username=Munchie -d pretty=1 https://slack.com/api/chat.postMessage`
      #`curl -X POST --data-urlencode 'payload={"channel": "#general", "username": "webhookbot", "text": "This is posted to #general and comes from a bot named webhookbot.", "icon_emoji": ":ghost:"}' https://hooks.slack.com/services/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
      #message = command[:args]
      #`curl -X POST --data-urlencode 'payload={"channel": "@#{user.slack_handle}", "username": "munchie", "text": #{message.inspect}, "icon_emoji": ":ghost:"}' https://hooks.slack.com/services/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`
      message("munchie", command[:args])
    else
      "I got @#{user.slack_handle} type: `#{command[:type]}` args: `#{command[:args]}`"
    end
  end

  def self.message(channel, message)
    payload = {
      "channel" => channel,
      "username" => "munchie",
      "icon_emoji" => ":ghost:",
      "text" => message,
    }

    data = "payload=#{payload.to_json}"

    Rails.logger.info(data)

    `curl -X POST --data-urlencode #{data.inspect} https://hooks.slack.com/services/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`
  end

  def self.munch_total(params, user, command)
    plan = Plan.where(:user => user, :total => nil).last

    if command[:args] =~ /(\d+\.?\d*)/
      if plan
        total = $1
        plan.update_attributes!(:total => total)

        amnt = (Float(total) / (plan.users.size + 1)).ceil

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
    /munchie imin <location> = joins a pre-existing plan\n
    /munchie imout = leaves whatever plan you're apart of"
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
    time = args[1].to_i.minutes.from_now


    if location
      if Plan.active.where(:location => location).exists?
        "#{location.to_short_slack_s} has already been suggested!"
      else
        Plan.create({
          :user     => user,
          :location => location,
          :eta_at   => time,
        })

        message = "#{location.to_short_slack_s} has been suggested! Leaving in #{ActionController::Base.helpers.distance_of_time_in_words(Time.now, time)}...".inspect

        User.all.each do |u|
          if u != user
            output = `curl -d token="#{params[:token]}" -d channel=@#{user.slack_handle} -d text=#{message} -d username=Munchie -d pretty=1 https://slack.com/api/chat.postMessage`
            Rails.logger.info(output)
            #https://slack.com/api/chat.postMessage?token=xoxp-2233001589-3250296071-6798263879-47b6b4&channel=munchie&text=hi!&username=Munchie&pretty=1
          end
        end

        message
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
