#!/usr/bin/ruby
require 'json'

following_of, *who_also_follow = ARGV

def json_fragments(filename)
  File.readlines(filename).collect {|json| JSON.parse(json)}
end

def user_follows(username)
  return json_fragments("@#{username}/following.json")
end

target_follows = user_follows(following_of)
# map followed Twitter username to map of {following username: User JSON object}
who_follows = {}

who_also_follow.each {|who|
  wf = who_follows[who] = {}
  user_follows(who).each {|f| wf[f["username"]] = f}
}

results_by_username = target_follows.collect {|who_target_follows|
  results = []
  wtfu = who_target_follows["username"]
  who_also_follow.each {|waf|
#    p "trying #{wtfu}"
#    p who_follows[waf][wtfu]
    if who_follows[waf][wtfu]
      results.push(waf)
    end
  }
  next if results.empty?
  results.unshift(wtfu, who_target_follows["id_str"]) # prepend username,id_str
  p results
}.keep_if {|x| x}

results_by_username.each {|res|
  puts("#{res[0]},#{res[1]},#{res[2..-1].join(' ')}")
}
