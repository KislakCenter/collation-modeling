require "rails_helper"

RSpec.describe ManuscriptsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/manuscripts").to route_to("manuscripts#index")
    end

    it "routes to #new" do
      expect(:get => "/manuscripts/new").to route_to("manuscripts#new")
    end

    it "routes to #show" do
      expect(:get => "/manuscripts/1").to route_to("manuscripts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/manuscripts/1/edit").to route_to("manuscripts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/manuscripts").to route_to("manuscripts#create")
    end

    it "routes to #update" do
      expect(:put => "/manuscripts/1").to route_to("manuscripts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/manuscripts/1").to route_to("manuscripts#destroy", :id => "1")
    end

  end
end
