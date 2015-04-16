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
        expect(@file.downloads.size).to eq 0
        get :show, id: @file
        expect(response).to be_successful
        expect(@file.downloads.size).to eq 1
      end
    end

    describe "for a file larger than the threshold" do
      before do
        FileContentDatastream.any_instance.stub(:live?).and_return(true)
      end
      describe "when requesting content" do
        before do
          GenericFile.any_instance.stub(:unique_key).and_return('test_ftp_download')
          GenericFile.any_instance.stub(:characterize)
          GenericFile.any_instance.stub(:filename => ['Test.MOV'])
          @file.add_file(StringIO.new("A test file"), 'content', 'Test.MOV')
          File.unlink('tmp/test_ftp_download/Test.MOV') if File.exists?('tmp/test_ftp_download/Test.MOV')
          FileUtils.rm_r('tmp/test_ftp_download') if File.exists?('tmp/test_ftp_download')
        end

        it "should give an ftp link" do
          expect(File.exist?('tmp/test_ftp_download/Test.MOV')).to eq false
          expect(controller).to receive(:over_threshold?).and_return(true)
          get :show, id: @file
          expect(response).to be_successful
          expect(assigns[:ftp_link]).to match /^ftp:\/\/test.host\/[^\/]+\/Test.MOV$/
          expect(File.exist?('tmp/test_ftp_download/Test.MOV')).to eq true
        end
      end
      it "should not give an ftp link when they want a proxy" do
        expect(controller).to receive(:send_content).with(@file)
        get :show, id: @file, datastream_id: 'webm'
        expect(response).to be_successful
        expect(assigns[:ftp_link]).to be_nil
      end
    end

    describe "for a file that is not online" do
      before do
        allow_any_instance_of(FileContentDatastream).to receive(:live?).and_return(false)
        @file.add_file_datastream('proxymovie', :dsid=>'webm', :mimeType => 'video/webm')
        @file.save!
      end

      it "should give an ftp link" do
        expect_any_instance_of(FileContentDatastream).to receive(:online!).with(@user)
        get :show, id: @file
        expect(response).to be_successful
        expect(response).to render_template 'offline'
      end
      it "should show the proxy (proxies don't go offline)" do
        get :show, id: @file, datastream_id: 'webm'
        expect(response).to be_successful
        expect(response).to be_success
        expect(response.headers['Content-Type']).to eq "video/webm"
        expect(response.headers["Content-Disposition"]).to eq "inline; filename=\"webm\""
        expect(response.body).to eq 'proxymovie'
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
      expect(response).to redirect_to "/assets/NoAccess.png"
    end
  end

end
