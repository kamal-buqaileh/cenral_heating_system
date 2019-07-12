class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  before_action :fetch_elastic
  before_action :check_household_token_param, :check_thermostat

  def respond_to_json(success, respond, status)
    hash = fetch_respond(success, respond)

    respond_to do |format|
      format.json do
        render json: hash,
               status: status
      end
    end
  end

  private

  def not_found
    respond_to_json(false, 'invalid url', 404)
  end

  def fetch_respond(success, respond)
    if success
      { success: success, data: respond }
    else
      { success: success, error: respond }
    end
  end

  def check_household_token_param
    return if params[:household_token].present?

    respond_to_json(false, 'household_token is not presented', 404)
  end

  def check_thermostat
    @thermostat = Thermostat.find_by(household_token: params[:household_token])

    return if @thermostat.present?

    respond_to_json(false, 'thermostat not found', 404)
  end

  def fetch_elastic
    @elastic = Elasticsearch::Client.new url: 'http://localhost:9200', log: true
  end
end
