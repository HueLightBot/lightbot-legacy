def chan_to_user(m)
  len = m.channel.to_s.length
  return m.channel.name.slice(1,len).to_s
end

def mod?(m)
  if m.tags["mod"].to_i == 1
    return true
  elsif m.user.name == $brain.users[0]["nick"]
    return true
  else
    if chan_to_user(m) == m.user.nick
      return true
    else
      return false
    end
  end
end

def sub?(m)
  if m.tags["subscriber"].to_i == 1
    return true
  else
    if chan_to_user(m) == m.user.nick
      return true
    else
      return false
    end
  end
end

def channel_to_key(channel)
  return channel if channel.is_a?(Symbol)
  channel[/\w+/].to_sym
end
