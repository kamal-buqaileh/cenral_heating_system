class ThermostatsController < ApplicationController
  def readings_report
    respond_to_json(true, fetch_data, 200)
  end

  private

  def fetch_data
    @elastic.search(index: "*-#{params[:household_token]}",
                    body: {
                      aggs: {
                        max_temperature: {
                          max: {
                            field: 'temperature'
                          }
                        },
                        min_temperature: {
                          min: {
                            field: 'temperature'
                          }
                        },
                        avg_temperature: {
                          avg: {
                            field: 'temperature'
                          }
                        },
                        max_humidity: {
                          max: {
                            field: 'humidity'
                          }
                        },
                        min_humidity: {
                          min: {
                            field: 'humidity'
                          }
                        },
                        avg_humidity: {
                          avg: {
                            field: 'humidity'
                          }
                        },
                        max_battery_charge: {
                          max: {
                            field: 'battery_charge'
                          }
                        },
                        min_battery_charge: {
                          min: {
                            field: 'battery_charge'
                          }
                        },
                        avg_battery_charge: {
                          avg: {
                            field: 'battery_charge'
                          }
                        }
                      }
                    })['aggregations']
  end
end
