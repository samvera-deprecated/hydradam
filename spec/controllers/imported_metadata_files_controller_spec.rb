require 'spec_helper'

describe ImportedMetadataFilesController do
  before do
    GenericFile.any_instance.stub(:terms_of_service).and_return('1')
    User.any_instance.stub(:groups).and_return([])
    controller.stub(:clear_session_user) ## Don't clear out the authenticated session
  end
  before (:each) do
    @user = FactoryGirl.create(:user)
    @file = ImportedMetadata.new
    @file.apply_depositor_metadata(@user.user_key)
    @file.save!
  end
  describe "logged in user" do
    before(:each) do
      sign_in @user
      controller.stub(:clear_session_user) ## Don't clear out the authenticated session
      User.any_instance.stub(:groups).and_return([])
    end
    describe "#show" do
      before (:each) do
        xhr :get, :show, id: @file.noid
      end
      it "should be a success" do
        response.should be_success
        response.should render_template('imported_metadata_files/show')
        assigns[:imported_metadata].should == @file
      end
    end
    describe "#edit" do
      before (:each) do
        xhr :get, :edit, id: @file.noid
      end
      it "should be a success" do
        response.should be_success
        response.should render_template('imported_metadata_files/edit')
        assigns[:imported_metadata].should == @file
      end
    end
    describe "#destroy" do
      before (:each) do
        ImportedMetadata.find(@file.pid).should == @file
        xhr :delete, :destroy, id: @file.noid
      end
      it "should be a success" do
        response.should redirect_to(imported_metadata_manager_index_path)
        expect { ActiveFedora::Base.find(@file.pid) }.to raise_error(ActiveFedora::ObjectNotFoundError)
      end
    end
  end
  describe "not logged in as a user" do
    describe "#show" do
      it "should return an error" do
        xhr :get, :show, id: @file.noid
        response.should_not be_success
      end
    end
  end
end
