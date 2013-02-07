require 'spec_helper'

describe GenericFilesController do
  before do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @routes = Sufia::Engine.routes
  end
  describe "#show" do
    before do
      @file = GenericFile.new
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
      @mock_upload_directory = 'spec/mock_upload_directory'
      Dir.mkdir @mock_upload_directory unless File.exists? @mock_upload_directory
      FileUtils.copy('spec/fixtures/world.png', @mock_upload_directory)
      FileUtils.copy('spec/fixtures/sheepb.jpg', @mock_upload_directory)
      @user.update_attribute(:directory, @mock_upload_directory)
    end
    after do
      GenericFile.destroy_all
    end
    it "should ingest files from the filesystem" do
      lambda { post :create, local_file: ["world.png", "sheepb.jpg"], batch_id: "xw42n7934"}.should change(GenericFile, :count).by(2)
      response.should redirect_to Sufia::Engine.routes.url_helpers.batch_edit_path('xw42n7934')
      # These files should have been moved out of the upload directory
      File.exist?("#{@mock_upload_directory}/sheepb.jpg").should be_false
      File.exist?("#{@mock_upload_directory}/world.png").should be_false
      # And into the storage directory
      files = GenericFile.find(Solrizer.solr_name("is_part_of",:symbol) => 'info:fedora/sufia:xw42n7934')
      files.each do |gf|
        File.exist?(gf.content.filename).should be_true
        gf.thumbnail.mimeType.should == 'image/png'
      end
      files.first.label.should == 'world.png'
      files.last.label.should == 'sheepb.jpg'
    end
    it "should ingest uploaded files"
  end

  describe "#update" do
    before do
      @file = GenericFile.new
      @file.apply_depositor_metadata(@user.user_key)
      @file.save!
    end
    it "should update the creator" do
      post :update, id: @file, generic_file: {creator: ["Frank", "Dave"] }
      response.should redirect_to(Sufia::Engine.routes.url_helpers.edit_generic_file_path(@file))
      @file.reload
      @file.descMetadata.creator[0].name.should == ['Frank']
      @file.descMetadata.creator[1].name.should == ['Dave']
      
    end
  end
end
