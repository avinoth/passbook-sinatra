## passbook-sinatra

A Ruby/Sinatra app that serves for iOS Passbook pass generation and pass updation through push notifications.

#### Getting Started:-
1. Clone the app `git clone https://github.com/avinoth/passbook-sinatra`
2. Create `certificates` folder and add the following certificates to it,
    ```
    p12_certificate.pem
    p12_key.pem
    wwdr.pem
    push_notification_certificate.pem
    ```

3. Run `bundle install`
4. Run `rake db:create && rake db:migrate`
5. Start the server `ruby app.rb`

#### Endpoints :-
`/passbooks` - POST - JSON with pass details in body
    To create Pass. Returns `pass.pkpass` file

`/passbooks/update` - POST - JSON with pass details in body
    To update pass and send push notification for registered devices if pass is already present.

And other passbook server standard endpoitns that Apple / Device will use.
