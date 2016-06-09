#!/usr/bin/env ruby
#
# Sensu Handler: mailer-ses
#
# This handler formats alerts as mails and sends them off to a pre-defined recipient.
# Copyright 2013 github.com/foomatty
# Copyright 2012 Pal-Kristian Hamre (https://github.com/pkhamre | http://twitter.com/pkhamre)
#
# Requires aws-sdk gem 'gem install aws-sdk'
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

require 'sensu-handler'
require 'aws-sdk'
require 'timeout'

class Mailer < Sensu::Handler
  def short_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? 'RESOLVED' : 'ALERT'
  end

  def prefix_subject
    if params[:subject_prefix]
      params[:subject_prefix] + ' '
    else
      ''
    end
  end

  def status_to_string
    case @event['check']['status']
    when 0
      'OK'
    when 1
      'WARNING'
    when 2
      'CRITICAL'
    else
      'UNKNOWN'
    end
  end

  def handle
    admin_gui = settings['mailer-ses']['admin_gui'] || 'http://localhost:8080/'
    playbook = "Playbook:  #{@event['check']['playbook']}" if @event['check']['playbook']

    params = {
      mail_to: settings['mailer-ses']['mail_to'],
      mail_from: settings['mailer-ses']['mail_from'],
      aws_access_key: settings['mailer-ses']['aws_access_key'],
      aws_secret_key: settings['mailer-ses']['aws_secret_key'],
      aws_region: settings['mailer-ses']['aws_region'],
      subject_prefix: settings['mailer-ses']['subject_prefix']
    }

    # try to redact passwords from output and command
    output = "#{@event['check']['output']}".gsub(/(\s-p|\s-P|\s--password)(\s*\S+)/, '\1 <password omitted>')
    command = "#{@event['check']['command']}".gsub(/(\s-p|\s-P|\s--password)(\s*\S+)/, '\1 <password omitted>')

    body = <<-BODY.gsub(/^\s+/, '')
            #{output}
            Admin GUI: #{admin_gui}
            Host: #{@event['client']['name']}
            Timestamp: #{Time.at(@event['check']['issued'])}
            Address:  #{@event['client']['address']}
            Check Name:  #{@event['check']['name']}
            Command:  #{command}
            Status:  #{status_to_string}
            Occurrences:  #{@event['occurrences']}
            #{playbook}
          BODY
    subject = "#{prefix_subject}#{action_to_string} - #{short_name}: #{@event['check']['notification']}"

    ses = Aws::SES::Client.new(
      region: params[:aws_region],
      access_key_id: params[:aws_access_key],
      secret_access_key: params[:aws_secret_key]
    )

    begin
      Timeout.timeout 10 do
        ses.send_email(
          source: params[:mail_from],
          destination: {
            to_addresses: [params[:mail_to]]
          },
          message: {
            subject: {
              data: subject
            },
            body: {
              text: {
                data: body
              }
            }
          }
        )
        puts 'mail -- sent alert for ' + short_name + ' to ' + params[:mail_to]
      end
    rescue Timeout::Error
      puts 'mail -- timed out while attempting to ' + @event['action'] + ' an incident -- ' + short_name
    end
  end
end
