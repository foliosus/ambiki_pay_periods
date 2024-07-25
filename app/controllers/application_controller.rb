class ApplicationController < ActionController::Base
  around_action :set_user_time_zone

  private def set_user_time_zone
    # In real life, we check the User record and set it's time zone, but we don't have users yet, so we're gonna default
    # to the dev's time zone.

    Time.use_zone("Pacific Time (US & Canada)") do
      yield
    end
  end
end
