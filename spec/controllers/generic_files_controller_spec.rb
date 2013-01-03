require 'spec_helper'

describe GenericFilesController do
  before do
    @user = FactoryGirl.create(:user)
    @file = GenericFile.new(:terms_of_service=>'1')
    @file.apply_depositor_metadata(@user.user_key)
    @file.save!
    sign_in @user
    @routes = Sufia::Engine.routes
  end
  it "should log views" do
    @file.views.size.should == 0
    get :show, id: @file
    response.should be_successful
    @file.views.size.should == 1

  end
end
