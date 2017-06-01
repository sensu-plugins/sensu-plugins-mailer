#!/usr/bin/env ruby
#
# Sensu Handler: mailer
#
# This handler formats alerts as mails and sends them off to a pre-defined recipient.
#
# Copyright 2012 Pal-Kristian Hamre (https://github.com/pkhamre | http://twitter.com/pkhamre)
#
# Released under the same terms as Sensu (the MIT license); see LICENSE
# for details.

# Note: The default mailer config is fetched from the predefined json config file which is "mailer.json" or any other
#       file defined using the "json_config" command line option. The mailing list could also be configured on a per client basis
#       by defining the "mail_to" attribute in the client config file. This will override the default mailing list where the
#       alerts are being routed to for that particular client.

require 'sensu-handler'
require 'mail'
require 'timeout'
require 'erubis'
require 'set'
require 'ntlm/smtp'

# patch to fix Exim delivery_method: https://github.com/mikel/mail/pull/546
# #YELLOW
module ::Mail # rubocop:disable Style/ClassAndModuleChildren
  class Exim < Sendmail
    def self.call(path, arguments, _destinations, encoded_message)
      popen "#{path} #{arguments}" do |io|
        io.puts encoded_message.to_lf
        io.flush
      end
    end
  end
end

class Mailer < Sensu::Handler
  option :json_config_name,
         description: 'Name of the JSON Configuration block in Sensu',
         short: '-j JsonConfig',
         long: '--json_config JsonConfig',
         required: false,
         default: 'mailer'

  option :template,
         description: 'Message template to use',
         short: '-t TemplateFile',
         long: '--template TemplateFile',
         required: false

  option :content_type,
         description: 'Content-type of message',
         short: '-c ContentType',
         long: '--content_type ContentType',
         required: false

  option :subject_prefix,
         description: 'Prefix message subjects with this string',
         short: '-s prefix',
         long: '--subject_prefix prefix',
         required: false

  # JSON configuration settings typically defined in the handler
  # file for mailer. JSON Config Name defaultly looks for a block
  # named 'mailer', as seen in the Installation step of the README
  #
  # @example
  #
  # ```json
  # {
  #   "admin_gui":                 "http://localhost:3000",
  #   "mail_from":                 "from@email.com",
  #   "mail_to":                   "to@email.com",
  #   "delivery_method":           "smtp",
  #   "smtp_address":              "localhost",
  #   "smtp_port":                 "25",
  #   "smtp_domain":               "localhost.local_domain",
  #   "smtp_enable_starttls_auto": "true",
  #   "smtp_username":             "username",
  #   "smtp_password":             "XXXXXXXX"
  # }
  # ```
  #
  # @return [Hash]
  def json_config_settings
    settings[config[:json_config_name]]
  end

  def short_name
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def action_to_string
    @event['action'].eql?('resolve') ? 'RESOLVED' : 'ALERT'
  end

  def prefix_subject
    if config[:subject_prefix]
      config[:subject_prefix] + ' '
    elsif json_config_settings['subject_prefix']
      json_config_settings['subject_prefix'] + ' '
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

  def parse_content_type
    use = if config[:content_type]
            config[:content_type]
          elsif @event['check']['content_type']
            @event['check']['content_type']
          elsif json_config_settings['content_type']
            json_config_settings['content_type']
          else
            'plain'
          end

    if use.casecmp('html').zero?
      'text/html; charset=UTF-8'
    else
      'text/plain; charset=ISO-8859-1'
    end
  end

  def build_mail_to_list
    mail_to = Set.new
    mail_to.add(@event['client']['mail_to'] || json_config_settings['mail_to'])
    if json_config_settings.key?('subscriptions') && @event['check']['subscribers']
      @event['check']['subscribers'].each do |sub|
        if json_config_settings['subscriptions'].key?(sub)
          mail_to.add(json_config_settings['subscriptions'][sub]['mail_to'].to_s)
        end
      end
    end
    mail_to.to_a.join(', ')
  end

  def message_template
    return config[:template] if config[:template]
    return @event['check']['template'] if @event['check']['template']
    return json_config_settings['template'] if json_config_settings['template']
    nil
  end

  def build_body
    admin_gui = json_config_settings['admin_gui'] || 'http://localhost:8080/'
    # try to redact passwords from output and command
    output = (@event['check']['output']).to_s.gsub(/(\s-p|\s-P|\s--password)(\s*\S+)/, '\1 <password omitted>')
    command = (@event['check']['command']).to_s.gsub(/(\s-p|\s-P|\s--password)(\s*\S+)/, '\1 <password omitted>')
    playbook = "Playbook:  #{@event['check']['playbook']}" if @event['check']['playbook']

    template = if message_template && File.readable?(message_template)
                 File.read(message_template)
               else
                 <<-BODY.gsub(/^\s+/, '')
        <%= output %>
        Admin GUI: <%= admin_gui %>
        Host: <%= @event['client']['name'] %>
        Timestamp: <%= Time.at(@event['check']['issued']) %>
        Address:  <%= @event['client']['address'] %>
        Check Name:  <%= @event['check']['name'] %>
        Command:  <%= command %>
        Status:  <%= status_to_string %>
        Occurrences:  <%= @event['occurrences'] %>
        <%= playbook %>
      BODY
               end
    eruby = Erubis::Eruby.new(template)
    eruby.result(binding)
  end

  def handle
    body = build_body
    content_type = parse_content_type
    mail_to = build_mail_to_list
    mail_from = json_config_settings['mail_from']
    reply_to = json_config_settings['reply_to'] || mail_from

    delivery_method = json_config_settings['delivery_method'] || 'smtp'
    smtp_address = json_config_settings['smtp_address'] || 'localhost'
    smtp_port = json_config_settings['smtp_port'] || '25'
    smtp_domain = json_config_settings['smtp_domain'] || 'localhost.localdomain'

    smtp_username = json_config_settings['smtp_username'] || nil
    smtp_password = json_config_settings['smtp_password'] || nil
    smtp_authentication = json_config_settings['smtp_authentication'] || :plain
    smtp_use_tls = json_config_settings['smtp_use_tls'] || nil
    smtp_enable_starttls_auto = json_config_settings['smtp_enable_starttls_auto'] == 'false' ? false : true

    timeout_interval = json_config_settings['timeout'] || 10

    headers = {
      'X-Sensu-Host'        => (@event['client']['name']).to_s,
      'X-Sensu-Timestamp'   => Time.at(@event['check']['issued']).to_s,
      'X-Sensu-Address'     => (@event['client']['address']).to_s,
      'X-Sensu-Check-Name'  => (@event['check']['name']).to_s,
      'X-Sensu-Status'      => status_to_string.to_s,
      'X-Sensu-Occurrences' => (@event['occurrences']).to_s
    }

    subject = if @event['check']['notification'].nil?
                "#{prefix_subject}#{action_to_string} - #{short_name}: #{status_to_string}"
              else
                "#{prefix_subject}#{action_to_string} - #{short_name}: #{@event['check']['notification']}"
              end

    Mail.defaults do
      delivery_options = {
        address: smtp_address,
        port: smtp_port,
        domain: smtp_domain,
        openssl_verify_mode: 'none',
        tls: smtp_use_tls,
        enable_starttls_auto: smtp_enable_starttls_auto
      }

      unless smtp_username.nil?
        auth_options = {
          user_name: smtp_username,
          password: smtp_password,
          authentication: smtp_authentication
        }
        delivery_options.merge! auth_options
      end

      delivery_method delivery_method.intern, delivery_options
    end

    begin
      Timeout.timeout timeout_interval do
        Mail.deliver do
          to mail_to
          from mail_from
          reply_to reply_to
          subject subject
          body body
          headers headers
          content_type content_type
        end

        puts 'mail -- sent alert for ' + short_name + ' to ' + mail_to.to_s
      end
    rescue Timeout::Error
      puts 'mail -- timed out while attempting to ' + @event['action'] + ' an incident -- ' + short_name
    end
  end
end
