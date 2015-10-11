Passbook.configure do |passbook|
  passbook.p12_password = 'myP@ssword'
  passbook.p12_key = 'certificates/p12_key.pem'
  passbook.p12_certificate = 'certificates/p12_certificate.pem'
  passbook.wwdc_cert = 'certificates/wwdr.pem'
  passbook.notification_gateway = 'gateway.push.apple.com'
  passbook.notification_cert = 'certificates/push_notificfation_certificate.pem'
end
