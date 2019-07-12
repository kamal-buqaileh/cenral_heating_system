class ReadingsController < ApplicationController
  before_action :check_create_params, only: :create
  before_action :check_show_params, only: :show

  def create
    @tracking_number =
      begin
        @elastic.count(index: "*-#{params[:household_token]}")['count'] + 1
      rescue
        1
      end
    data = reading_params
    index_data(data)
    ReadingJob.perform_later(data.merge(tracking_number: @tracking_number), @thermostat.id)
    respond_to_json(true, { tracking_number: @tracking_number }, 200)
  end

  def show
    if @elastic.exists?(index: "#{params[:tracking_number]}-#{params[:household_token]}", id: params[:tracking_number])
      respond_to_json(true, fetch_reading_record, 200)
    else
      respond_to_json(false, 'data does not exist', 404)
    end
  end

  private

  def index_data(data)
    @elastic.index index: "#{@tracking_number}-#{params[:household_token]}",
                   type: 'mytype',
                   id: @tracking_number,
                   body: data
  end

  def fetch_reading_record
    @elastic.search(index: "#{params[:tracking_number]}-#{params[:household_token]}")['hits']['hits'][0]['_source']
  end

  def check_create_params
    return if params[:temperature].present? &&
              params[:humidity].present? &&
              params[:battery_charge] .present?

    respond_to_json(false, 'missing parameter(s)', 404)
  end

  def check_show_params
    return if params.key?('tracking_number')

    respond_to_json(false, 'missing parameter(s)', 404)
  end

  def reading_params
    { temperature: params[:temperature].to_f,
      humidity: params[:humidity].to_f,
      battery_charge: params[:battery_charge].to_f }
  end
end
