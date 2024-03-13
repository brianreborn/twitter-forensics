#!/usr/bin/ruby
# Usage: inspector-profile-twimg.rb "profile_glob" [...]

require 'tempfile'

user_json_patterns = ARGV.collect {|arg| "@#{arg}/user.json"}
urls = {}
Dir[*user_json_patterns].each {|user_json|
  user_json = File.read(user_json)
  user_json.scan(/"profile(?:Image|Banner)Url": "([^"]+)"/) {|url| urls[url] = true}
}
Tempfile.create {|profile_twimg_urls|
  urls.keys.each {|url| profile_twimg_urls.puts(url)}
  profile_twimg_urls.flush()
  system("wget", "-mi", profile_twimg_urls.path)
}
