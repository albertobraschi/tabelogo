# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tabelogo_session',
  :secret      => '390b95d9e00f41052dd78b0f26342bf1c113da4d62227cc6aa8e86097389c34386aae6a1e82b47db5e1a90b0f46b8b0fed1bd66fd807561c1affc48ef3b92a1e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
