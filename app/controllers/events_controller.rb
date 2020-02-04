class EventsController < ApplicationController
  layout "public_event"

  helper_method :resource_name, :resource, :devise_mapping

  before_action :store_current_location, unless: :devise_controller?

  def show
    event = Event.find_by_slug(params[:event_slug])
    @session_presenter = SessionPresenter.new(request.subdomains.last)

    if event.nil?
      redirect_to root_path
    else
      @source = encrypt({ signup_source: 'Event', signup_source_event_id: event.id })
      if user_signed_in?
        redirect_to traveler_event_path(event.id)
      else
        @event = EventPresenter.new(event)
      end
    end
  end

  def invite_traveler
    user = User.new(user_params)

    if user.invite_traveler_user(first_name, last_name, event.client_account)
      raw_token = user.set_reset_password_token
      Traveler::Builder.new(user, signup_source: "Event", signup_source_event_id: event.id).execute
      EventTraveler.create(user: user, event: event).update(confirmed: true)
      EventUserSignupMailer.email(user.id, raw_token, client_account.id, event.id, subdomain).deliver_later
      redirect_to show_public_event_path(event.slug), notice: __("Check your email to confirm your event registration<br/>and continue your journey.")
    else
      redirect_to show_public_event_path(event.slug), alert: __("Unable to invite.")
    end
  end

  private

  def encrypt(payload_to_encrypt)
    Crypto::Secrets.new(Rails.application.secrets.secret_key_base).encrypt(payload_to_encrypt)
  end

  def resource_name
    :user
  end

  def event
    @event ||= Event.find_by_id(event_params[:id])
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def store_current_location
    store_location_for(:user, request.url)
  end

  def user_params
    params.require(:user).permit(:email)
  end

  def event_params
    params.require(:event).permit(:id)
  end

  def first_name
    params[:first_name]
  end

  def last_name
    params[:last_name]
  end

  def client_account
    event.client_account
  end
end
