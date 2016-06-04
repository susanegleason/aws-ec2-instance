Rails.application.routes.draw do

  resources :instances, only: [:index, :show] do
    get "/start" => "instances#start", :as => :start
    get "/stop" => "instances#stop", :as => :stop
  end
end
