require 'spec_helper'

describe GenericFilesController do
  before do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @routes = Sufia::Engine.routes
  end
  describe "#show" do
    before do
      @file = GenericFile.new(:terms_of_service=>'1')
      @file.apply_depositor_metadata(@user.user_key)
      @file.save!
    end
    it "should log views" do
      @file.views.size.should == 0
      get :show, id: @file
      response.should be_successful
      @file.views.size.should == 1
    end
  end

  describe "#create" do
    before do
      @user.update_attribute(:directory, 'spec/fixtures')

    end
    after do
      GenericFile.destroy_all
    end
    it "should ingest files from the filesystem" do
      before = GenericFile.count
      post :create, local_file: ["world.png", "sheepb.jpg"], batch_id: "xw42n7934"
      response.should redirect_to Sufia::Engine.routes.url_helpers.batch_edit_path('xw42n7934')
      GenericFile.count.should == before + 2
    end
    it "should ingest uploaded files"
  end
end
