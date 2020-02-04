require 'rails_helper'

describe RecommendationController do
  let(:recommendation) {FactoryGirl.create(:tapp_recommendation, recommender_token: "123", submitted: false)}

  context 'show' do
    it 'show a confirmation' do
      get :confirmation, token: recommendation.recommender_token

      expect(response).to render_template("recommendation/confirmation")
    end

    it 'renders the template with form' do
      get :show, token: recommendation.recommender_token

      expect(response).to render_template("recommendation/show")
      expect(response).to be_ok
    end

    it 'renders already submitted notification' do
      recommendation.update(submitted: true)
      get :show, token: recommendation.recommender_token

      expect(response).to render_template("recommendation/already_submitted")
    end

    it 'assigns a recommendation' do
      get :show, token: recommendation.recommender_token

      expect(assigns(:recommendation)).to be_truthy
    end

    it 'assigns a presenter' do
      get :show, token: recommendation.recommender_token

      expect(assigns(:presenter)).to be_truthy
    end

    it 'redirects to index for invalid token and displays alert' do
      get :show, token: "invalid"

      expect(flash[:alert]).to be_present
      expect(response).to redirect_to root_path
    end
  end

  context 'recommend' do
    it 'updates recommendation with content' do
      params = {
        "token" => recommendation.recommender_token,
        "tapp_recommendation" => {
          "recommender_details" => "content"
        }
      }
      patch :recommend, params

      updated_recommendation = recommendation.reload

      expect(updated_recommendation.recommender_details).to eq("content")
      expect(updated_recommendation.submitted).to be_truthy
      expect(updated_recommendation.submitted_at.to_date.to_s).to eq(Time.zone.now.to_date.to_s)
    end

    it 'does not update non-existing recommendation' do
      params = {
        "token" => "non-existing-recommendation",
        "tapp_recommendation" => {
          "recommender_details" => "content"
        }
      }
      patch :recommend, params

      expect(response).to redirect_to root_path
    end

    it 'does not update previously submitted recommendation' do
      recommendation = FactoryGirl.create(:tapp_recommendation, recommender_details: "old content", recommender_token: "123", submitted: true)
      params = {
        "token" => recommendation.recommender_token,
        "tapp_recommendation" => {
          "recommender_details" => "content"
        }
      }

      patch :recommend, params

      expect(recommendation.reload.recommender_details).to eq("old content")
    end

    it 'redirects to confirmation' do
      params = {
        "token" => recommendation.recommender_token,
        "tapp_recommendation" => {
          "recommender_details" => "content"
        }
      }
      patch :recommend, params

      expect(response).to redirect_to recommendation_confirmation_path(recommendation.recommender_token)
    end
  end

  context 'confirmation' do
    it 'assigns recommendation' do
      get :confirmation, token: recommendation.recommender_token

      expect(assigns(:recommendation)).to be_truthy
    end

    it 'assigns presenter' do
      get :confirmation, token: recommendation.recommender_token

      expect(assigns(:presenter)).to be_truthy
    end
  end
end
