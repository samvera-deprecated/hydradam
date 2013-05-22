require 'spec_helper'

describe DownloadsController do

  before do
    @routes = Sufia::Engine.routes
  end

  describe "when signed in" do
    before do
      @user = FactoryGirl.create(:user)
      @file = GenericFile.new
      @file.apply_depositor_metadata(@user.user_key)
      @file.save
      sign_in @user
    end

    describe "logging" do
      before do
        FileContentDatastream.any_instance.stub(:live?).and_return(true)
        controller.stub :send_content
      end
      it "should log downloads" do
        @file.downloads.size.should == 0
        get :show, id: @file
        response.should be_successful
        @file.downloads.size.should == 1
      end
    end

    describe "for a file larger than the threshold" do
      before do
        FileContentDatastream.any_instance.stub(:live?).and_return(true)
      end
      describe "when requesting content" do
        before do
          GenericFile.any_instance.stub(:unique_key).and_return('test_ftp_download')
          @file.add_file(StringIO.new("A test file"), 'content', 'Test.MOV')
          File.unlink('tmp/test_ftp_download/Test.MOV') if File.exists?('tmp/test_ftp_download/Test.MOV')
          FileUtils.rm_r('tmp/test_ftp_download') if File.exists?('tmp/test_ftp_download')
        end

        it "should give an ftp link" do
          File.exist?('tmp/test_ftp_download/Test.MOV').should be_false
          controller.should_receive(:over_threshold?).and_return(true)
          get :show, id: @file
          response.should be_successful
          assigns[:ftp_link].should match /^ftp:\/\/test.host\/[^\/]+\/Test.MOV$/
          File.exist?('tmp/test_ftp_download/Test.MOV').should be_true
        end
      end
      it "should not give an ftp link when they want a proxy" do
        controller.should_receive(:send_content).with(@file)
        get :show, id: @file, datastream_id: 'webm'
        response.should be_successful
        assigns[:ftp_link].should be_nil
      end
    end

    describe "for a file that is not online" do
      before do
        FileContentDatastream.any_instance.stub(:live?).and_return(false)
        @file.add_file_datastream('proxymovie', :dsid=>'webm', :mimeType => 'video/webm')
        @file.save!
      end

      it "should give an ftp link" do
        FileContentDatastream.any_instance.should_receive(:online!).with(@user)
        get :show, id: @file
        response.should be_successful
        response.should render_template 'offline'
      end
      it "should show the proxy (proxies don't go offline)" do
        get :show, id: @file, datastream_id: 'webm'
        response.should be_successful
        response.should be_success
        response.headers['Content-Type'].should == "video/webm"
        response.headers["Content-Disposition"].should == "inline; filename=\"webm\""
        response.body.should == 'proxymovie'
      end
    end
  end

  describe "when not signed in" do
    before do
      @file = GenericFile.new
      @file.apply_depositor_metadata('bob')
      @file.save
      FileContentDatastream.any_instance.stub(:live?).and_return(true)
      controller.stub :send_content
    end

    it "should say 401 unauthorized" do
      get :show, id: @file
      response.should redirect_to "/assets/NoAccess.png"
    end
  end

end
