require "rails_helper"

describe EventsController do
  include ActiveJob::TestHelper

  let(:client_account) { FactoryGirl.create(:client_account, status: "enrollment") }
  let(:event) {
    FactoryGirl.create(:event, {
      client_account_id: client_account.id,
      name: 'the name',
      start: DateTime.new(2016, 06, 13, 11, 30),
      timezone: "UTC",
      slug: "the-event-slug"
    })
  }

  before do
    ActionMailer::Base.deliveries.clear
    event
  end

  context "#show" do
    it 'redirects to root for unknown events' do
      get :show, event_slug: 'unknown-event'

      expect(response).to redirect_to root_path
    end

    it 'assigns session presenter' do
      get :show, event_slug: event.slug

      expect(assigns(:session_presenter)).to be_a(SessionPresenter)
    end

    it 'assigns a source' do
      get :show, event_slug: event.slug

      expect(assigns(:source)).not_to be_nil
    end

    context 'traveler signed in' do
      before(:each) do
        set_devise_env
        sign_in FactoryGirl.create(:traveler), scope: :user
      end

      it 'redirects to traveler view of event' do
        get :show, event_slug: event.slug

        expect(response).to redirect_to traveler_event_path(event.id)
      end
    end

    context 'traveler not signed in' do
      it "shows the public event overview" do
        get :show, event_slug: event.slug

        expect(response).to have_http_status(:success)
        expect(response).to render_template('events/show')
      end

      it 'assigns the event presenter' do
        get :show, event_slug: event.slug

        expect(assigns(:event)).to be_a(EventPresenter)
      end
    end
  end

  context 'invite_traveler' do
    def do_post
      post :invite_traveler, {"user" => {"first_name" =>  'first', "last_name" => 'last', "email" => 'user@example.com'}, "event" => {"id" => event.id}}
    end

    it 'sends signup e-mails' do
      allow(Rails.application.secrets).to receive(:default_sender_email).and_return('email@example.com')
      perform_enqueued_jobs do
        do_post
      end

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it 'signs traveler up to an event' do
      do_post
      user = User.last
      event_traveler = EventTraveler.last
      expect(user.id).to eq(event_traveler.user_id)
    end

    it 'signs up traveler as confirmed' do
      do_post
      event_traveler = EventTraveler.last
      expect(event_traveler.confirmed?).to be true
    end

    it 'redirects to event page again' do
      do_post

      expect(response).to redirect_to show_public_event_path(event.slug)
    end

    it 'tracks the signup source' do
      do_post
      user = User.last
      expect(user.profile.signup_source).to eq("Event")
      expect(user.profile.signup_source_event_id).to eq(event.id)
    end

    it 'notifies traveler' do
      do_post

      expect(flash[:notice]).to include("Check your email to confirm your event registration")
    end

    it 'creates a traveler info' do
      do_post
      user = User.last
      expect(user.traveler_info).not_to be_nil
    end
  end
end
