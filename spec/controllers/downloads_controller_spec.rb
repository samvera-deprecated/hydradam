require 'spec_helper'

describe DownloadsController do
  before do
    @user = FactoryGirl.create(:user)
    @file = GenericFile.new
    @file.content.content = "A test file"
    @file.apply_depositor_metadata(@user.user_key)
    @file.save!
    sign_in @user
    @routes = Sufia::Engine.routes
  end
  it "should log downloads" do
    @file.downloads.size.should == 0
    get :show, id: @file
    response.should be_successful
    @file.downloads.size.should == 1

  end

end
