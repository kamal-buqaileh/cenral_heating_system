Rails.application.routes.draw do
  resource :reading, only: %i[create show]
  get 'thermostats/readings_report', to: 'thermostats#readings_report'
  match '/404', to: 'application#not_found', via: :all
  match '/500', to: 'application#not_found', via: :all
end
