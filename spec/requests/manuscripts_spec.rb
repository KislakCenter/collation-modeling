require 'rails_helper'

RSpec.describe "Manuscripts", :type => :request do
  describe "GET /manuscripts" do
    it "works! (now write some real specs)" do
      get manuscripts_path
      expect(response).to have_http_status(200)
    end
  end
end
