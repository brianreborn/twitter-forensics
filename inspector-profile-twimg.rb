#!/usr/bin/ruby
# Usage: inspector-profile-twimg.rb "profile_glob" [...]
# Uses: wget
# Provides: "pbs.twimg.com/**"
# Provides: "profile-twimg.csv"

require 'tempfile'

user_json_patterns = ARGV.collect {|arg| "@#{arg}/user.json"}
USER_FIELDS = %w(id_str username profileImageUrl profileBannerUrl)
USER_NAME_INDEX = 1
USER_IMAGE_INDEX = 2
USER_BANNER_INDEX = 3
entries = []
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

Tempfile.create {|profile_twimg_urls_file|
  links = []
  entries.each {|entry|
    who = entry[USER_NAME_INDEX]
    pull = lambda {|what, location|
      unless location.nil?
        location = location["https://".length()..-1]
        unless File.exists?(location)
          profile_twimg_urls_file.puts(location)
        end
        ["ln", "-fs", "#{Dir.pwd}/#{location}", "@#{who}/#{what}"]
      end
    }
    links.push(pull.call("image", entry[USER_IMAGE_INDEX]))
    links.push(pull.call("banner", entry[USER_BANNER_INDEX]))
  }
  profile_twimg_urls_file.flush()
  system("wget", "-mi", profile_twimg_urls_file.path)
  links.each {|link_command|
    next if link_command.nil?
    system(*link_command)
  }
}
File.open("profile-twimg.csv", "w") {|w|
  w.puts(USER_FIELDS.join(","))
  entries.each {|entry| w.puts(entry.join(","))}
}
