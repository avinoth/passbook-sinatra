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


# Endpoint to generate a pass file
post '/passbooks' do
  request.body.rewind
  data = JSON.parse request.body.read

  unless @pass = Pass.find_by(serial_number: data['serialNumber'])
    @pass = Pass.create(serial_number: data['serialNumber'], data: data)
  end
  passbook = Passbook::PKPass.new @pass.data.to_json.to_s
  passbook.addFiles ['assets/logo.png', 'assets/logo@2x.png', 'assets/icon.png', 'assets/icon@2x.png']
  gen_pass = passbook.file
  send_file(gen_pass.path, type: 'application/vnd.apple.pkpass', disposition: 'attachment', filename: "pass.pkpass")
end
