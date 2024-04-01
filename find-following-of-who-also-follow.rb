#!/usr/bin/ruby
require 'json'

following_of, *who_also_follow = ARGV

def json_fragments(filename)
  File.readlines(filename).collect {|json| JSON.parse(json)}
end

def user_following(username)
  return json_fragments("@#{username}/following.json")
end

def user_followers(username)
  return json_fragments("@#{username}/followers.json")
end

target_follows = user_following(following_of)
# map followed Twitter username to map of {following username: User JSON object}
who_follows = {}

who_also_follow.each {|who|
  wf = who_follows[who] = {}
  # either following or follower. could do mutuals (AND) instead.
  user_following(who).each {|f| wf[f["username"]] = f}
  user_followers(who).each {|f| wf[f["username"]] = f}
}

results_by_username = target_follows.collect {|who_target_follows|
  results = []
  wtfu = who_target_follows["username"]
  who_also_follow.each {|waf|
    if who_follows[waf][wtfu]
      results.push(waf)
    end
  }
  next if results.empty?
  results.unshift(wtfu, who_target_follows["id_str"]) # prepend username,id_str
}.keep_if {|x| x}

results_by_username.each {|res|
  puts("#{res[0]},#{res[1]},#{res[2..-1].join(' ')}")
}
