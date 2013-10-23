require 'spec_helper'

describe ImportedMetadataFilesController do
  before do
    GenericFile.any_instance.stub(:terms_of_service).and_return('1')
    User.any_instance.stub(:groups).and_return([])
    controller.stub(:clear_session_user) ## Don't clear out the authenticated session
  end
  before (:each) do
    @user = FactoryGirl.create(:user)
  end

  let (:file) do
    ImportedMetadata.new.tap do |f|
      f.apply_depositor_metadata(@user.user_key)
      f.save!
    end
  end

  describe "logged in user" do
    before(:each) do
      sign_in @user
      controller.stub(:clear_session_user) ## Don't clear out the authenticated session
      User.any_instance.stub(:groups).and_return([])
    end
    describe "#show" do
      before (:each) do
        GenericFile.delete_all
        file.drive_name = "G-DRIVE_BoB_Auditions"
        file.folder_name = "ATLANTA"
        file.save!
        @file1 = GenericFile.new(relative_path: "G-DRIVE_BoB_Auditions/ATLANTA/001.wav")
        @file2 = GenericFile.new(relative_path: "G-DRIVE_BoB_Auditions/ATLANTA/002.wav")
        @file3 = GenericFile.new(relative_path: "TheDRIVE/SEATTLE/001.wav")
        [@file1, @file2, @file3].each do |f| 
          f.apply_depositor_metadata(@user.user_key)
          f.save!
        end
      end
      it "should be a success" do
        xhr :get, :show, id: file.noid
        response.should be_success
        response.should render_template('imported_metadata_files/show')
        assigns[:imported_metadata].should == file
        assigns[:matches].size.should == 2
        assigns[:matches].first.id.should == @file1.id
      end
      it "should support querying paths" do
        xhr :get, :show, id: file.noid, q: "G-DRIVE_BoB_Auditions/ATLANTA/002.wav"
        assigns[:matches].size.should == 1
        assigns[:matches].first.id.should == @file2.id
      end
      it "should support querying noids" do
        xhr :get, :show, id: file.noid, q: @file2.noid
        assigns[:matches].size.should == 1
        assigns[:matches].first.id.should == @file2.id
      end
      
    end
    describe "#edit" do
      before (:each) do
        xhr :get, :edit, id: file.noid
      end
      it "should be a success" do
        response.should be_success
        response.should render_template('imported_metadata_files/edit')
        assigns[:imported_metadata].should == file
      end
    end
    describe "#destroy" do
      before (:each) do
        ImportedMetadata.find(file.pid).should == file
        xhr :delete, :destroy, id: file.noid
      end
      it "should be a success" do
        response.should redirect_to(imported_metadata_manager_index_path)
        expect { ActiveFedora::Base.find(file.pid, cast:true) }.to raise_error(ActiveFedora::ObjectNotFoundError)
      end
    end

    describe "#update" do
      before do
        put :update, id: file.noid, imported_metadata: { program_title: 'new program title', 
          series_title: 'new series title', item_title: 'new item title', episode_title: 'new episode title' } 
      end
      it "should be a success" do
        response.should redirect_to(imported_metadata_file_path(file))
        file.reload
        file.program_title.should == 'new program title'
        file.item_title.should == 'new item title'
        file.series_title.should == 'new series title'
        file.episode_title.should == 'new episode title'
      end
    end

    describe "#apply" do
      before do
        file.series_title = "This Old House"
        file.save!
        @file1 = GenericFile.new(relative_path: "G-DRIVE_BoB_Auditions/ATLANTA/001.wav")
        @file2 = GenericFile.new(relative_path: "G-DRIVE_BoB_Auditions/ATLANTA/002.wav")
        @file3 = GenericFile.new(relative_path: "TheDRIVE/SEATTLE/001.wav")
        [@file1, @file2, @file3].each do |f| 
          f.apply_depositor_metadata(@user.user_key)
          f.save!
        end
      end
      it "should be a success" do
        post :apply, id: file.noid, imported_metadata: { apply_to: [@file1.id, @file2.id, @file3.id]} 
        response.should redirect_to(imported_metadata_manager_index_path)
        @file1.reload.series_title.should == ["This Old House"]
      end
    end
  end
  describe "not logged in as a user" do
    describe "#show" do
      it "should return an error" do
        xhr :get, :show, id: file.noid
        response.should_not be_success
      end
    end
  end
end
