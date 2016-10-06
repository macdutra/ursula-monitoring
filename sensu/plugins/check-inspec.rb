#!/opt/sensu/embedded/bin/ruby
#
#   check-inspec
#
# DESCRIPTION:
#   Runs inspec tests against your servers.
#   Fails with a warning or a critical if tests are failing, depending
#     on the severity level set.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: json
#
# USAGE:
#   Run entire suite of testd
#   check-inspec --controls /etc/inspec/controls
#
# NOTES:
#   Critical severity level is set as the default 
#
# LICENSE:
#   Copyright 2016 IBM
#   Copyright 2014 Sonian, Inc. and contributors. <support@sensuapp.org>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'json'

class CheckInspec < Sensu::Plugin::Check::CLI
  option :controls,
         short: '-c /tmp/dir',
         long: '--controls /tmp/dir',
         required: true,
         default: '/etc/inspec/controls'

  option :severity,
         short: '-s severity',
         long: '--severity severity',
         default: 'critical'

  def inspec(path)
    inspec = `inspec exec --format=json-min #{path}`
    JSON.parse(inspec)
  end   

  def run
    results = inspec(config[:controls])
    passed = 0
    failed = 0
    msg = ""
    results['controls'].each do |control|
      #puts control
      if control['status'] == "passed"
        passed += 1
      else
        failed += 1
        msg += "#{control['id']} #{control['code_desc']} - #{control['status']}\n"
      end
    end

    if failed
      if config[:severity] == 'warning'
        warning msg
      else
        critical msg
      end
    else
      ok msg
    end
  end

end