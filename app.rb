require 'sinatra'

require 'bundler/setup'
require 'passbook'
require 'sinatra/activerecord'
require './config/environments'

require './models/pass'
require './models/device'
require './models/registration'
require './models/log'

require './config/passbook'

require 'grocer'


# Endpoint to generate a pass file
post '/passbooks' do
  request.body.rewind
  data = JSON.parse request.body.read

  unless @pass = find_pass_with(data['serialNumber'])
    @pass = Pass.create(serial_number: data['serialNumber'], data: data)
  end
  passbook = Passbook::PKPass.new @pass.data.to_json.to_s
  passbook.addFiles ['assets/logo.png', 'assets/logo@2x.png', 'assets/icon.png', 'assets/icon@2x.png']
  gen_pass = passbook.file
  send_file(gen_pass.path, type: 'application/vnd.apple.pkpass', disposition: 'attachment', filename: "pass.pkpass")
end

post '/passbooks/update' do
  request.body.rewind
  data = JSON.parse request.body.read

  unless @pass = find_pass_with(data['serialNumber'])
    @pass = Pass.create(serial_number: data['serialNumber'], data: data)
    {:response => 'Pass newly created.'}.to_json
  else
    @pass.update(data: data, version: Time.now.utc.to_i)
    push_updates_for_pass
    {:response => 'Pass updated and sent push notifications.'}.to_json
  end
end


module Passbook
  class PassbookNotification
    def self.register_pass(options)
      status = verify_pass_and_token options
      if status
        return status
      end

      @device = Device.where(identifier: options['deviceLibraryIdentifier'], push_token: options['pushToken']).first_or_create
      if Registration.find_by(pass_id: @pass.id, device_id: @device.id).present?
        return {:status => 200}
      else
        Registration.create(pass_id: @pass.id, device_id: @device.id)
        return {:status => 201}
      end
    end

    def self.passes_for_device(options)
      unless valid_device? options['deviceLibraryIdentifier']
        return
      end

      update_tag = options['passesUpdatedSince'] || 0
      passes = @device.passes.where('version > ?', update_tag.to_i)
      if passes.present?
        {'lastUpdated' => Time.now.utc.to_i.to_s, 'serialNumbers' => passes.map{|p| p.serial_number}}
      else
        return
      end
    end

    def self.unregister_pass(options)
      status = verify_pass_and_token options
      if status
        return status[:status] == 401 ? status : {:status => 200}
      end

      unless valid_device? options['deviceLibraryIdentifier']
        return {:status => 401}
      end

      registrations = @device.registrations.where(pass_id: @pass.id)
      if registrations.present?
        registrations.destroy_all
      end
      return {:status => 200}
    end

    def self.latest_pass(options)
      @pass = find_pass_with options['serialNumber']
      unless @pass
        return
      end

      passbook = Passbook::PKPass.new @pass.data.to_json.to_s
      passbook.addFiles ['assets/logo.png', 'assets/logo@2x.png', 'assets/icon.png', 'assets/icon@2x.png']
      {:status => 200, :latest_pass => passbook.stream.string, :last_modified => Time.now.utc.to_i.to_s}
    end

    def self.passbook_log(log)
      log.values.flatten.compact.each do |l|
        Log.create(log: l)
      end
    end
  end
end

def verify_pass_and_token options
  token = ENV['AUTH_TOKEN']
  @pass = find_pass_with options['serialNumber']
  if options['authToken'] != token
    return {:status => 401}
  elsif !@pass
    return {:status => 404}
  else
    return
  end
end

def find_pass_with serial
  Pass.find_by(serial_number: serial)
end

def valid_device? identifier
  @device = Device.find_by(identifier: identifier)
end

def push_updates_for_pass
  @pass.devices.each do |device|
    puts "Sending push notification for device - #{device.push_token}"
    Passbook::PushNotification.send_notification device.push_token
  end
end
