#!/usr/bin/ruby
# Usage: inspector-profile-twimg.rb "profile_glob" [...]
# Uses: wget
# Provides: "pbs.twimg.com/**"
# Provides: "profile-twimg.csv"

require 'tempfile'

user_json_patterns = ARGV.collect {|arg| "@#{arg}/user.json"}
entries = []
USER_FIELDS = %w(id_str username profileImageUrl profileBannerUrl)
USER_URL_FIELDS_INDEX = 2..3
Dir[*user_json_patterns].each {|user_json|
  user_json = File.read(user_json)
  entries.push(USER_FIELDS.collect {|field|
    if user_json =~ /"#{field}": "([^"]+)"/
      $1
    else
      next
    end
  })
}
Tempfile.create {|profile_twimg_urls|
  entries.each {|entry|
    entry[USER_URL_FIELDS_INDEX].each {|local|
      unless local.nil? or File.exists?(local["https://".length()..-1])
        profile_twimg_urls.puts(local)
      end
    }
  }
  profile_twimg_urls.flush()
  system("wget", "-mi", profile_twimg_urls.path)
}
File.open("profile-twimg.csv", "w") {|w|
  w.puts(USER_FIELDS.join(","))
  entries.each {|entry| w.puts(entry.join(","))}
}
