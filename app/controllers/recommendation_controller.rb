class RecommendationController < ActionController::Base
  layout "recommendation"

  def show
    @recommendation = find_recommendation
    @presenter = presenter_for(@recommendation)

    if @recommendation
      render_recommendation(@recommendation)
    else
      redirect_to root_path, alert: "Recommendation request invalid. Please contact requester if you believe this is an error."
    end
  end

  def recommend
    recommendation = find_recommendation

    if recommendation && updatable?(recommendation)
      recommendation.update(submission_recommendation_data)
      redirect_to recommendation_confirmation_path(token)
    else
      redirect_to root_path
    end
  end

  def confirmation
    @recommendation = find_recommendation
    @presenter = presenter_for(@recommendation)
  end

  private

  def find_recommendation
    TappRecommendation.find_by_recommender_token(token)
  end

  def presenter_for(recommendation)
    Recommendations::RecommendationPresenter.new(recommendation)
  end

  def render_recommendation(recommendation)
    if updatable?(recommendation)
      render :show
    else
      render :already_submitted
    end
  end

  def updatable?(recommendation)
    recommendation.submitted == false
  end

  def submission_recommendation_data
    recommendation_data.merge(submitted: true, submitted_at: DateTime.now)
  end

  def token
    params[:token]
  end

  def recommendation_data
    params.require(:tapp_recommendation).permit(:recommender_details)
  end
end
