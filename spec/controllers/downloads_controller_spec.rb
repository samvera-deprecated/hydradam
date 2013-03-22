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
      end

      it "should give an ftp link" do
        FileContentDatastream.any_instance.should_receive(:online!).with(@user)
        get :show, id: @file
        response.should be_successful
        response.should render_template 'offline'
      end
      it "should show the proxy (proxies don't go offline)" do
        controller.should_receive(:send_content).with(@file)
        get :show, id: @file, datastream_id: 'webm'
        response.should be_successful
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

  describe "stream" do
    before do
      stub_response = stub()
      stub_response.stub(:read_body).and_yield("one1").and_yield('two2').and_yield('thre').and_yield('four')
      stub_repo = stub()
      stub_repo.stub(:datastream_dissemination).and_yield(stub_response)
      stub_ds = stub('datastream', :repository => stub_repo, :mimeType=>'video/webm', :dsSize=>16)
      stub_file = stub(datastreams: {'webm' => stub_ds}, pid:'sufia:test')
      ActiveFedora::Base.should_receive(:find).with('sufia:test', cast: true).and_return(stub_file)
      controller.stub(:can?).with(:read, 'sufia:test').and_return(true)
      controller.stub(:log_download)
    end
    it "head request" do
      request.env["Range"] = 'bytes=0-16'
      head :show, id: 'test', datastream_id: 'webm'
      response.headers['Content-Length'].should == 16
      response.headers['Accept-Ranges'].should == 'bytes'
      response.headers['Content-Type'].should == 'video/webm'
    end
    it "should send the whole thing" do
      request.env["Range"] = 'bytes=0-16'
      get :show, id: 'test', datastream_id: 'webm'
      response.body.should == 'one1two2threfour'
      response.headers["Content-Range"].should == 'bytes 0-16/16'
      response.headers["Content-Length"].should == '16'
      response.headers['Accept-Ranges'].should == 'bytes'
    end
    it "should send the whole thing when the range is open ended" do
      request.env["Range"] = 'bytes=0-'
      get :show, id: 'test', datastream_id: 'webm'
      response.body.should == 'one1two2threfour'
    end
    it "should get a range not starting at the beginning" do
      request.env["Range"] = 'bytes=3-16'
      get :show, id: 'test', datastream_id: 'webm'
      response.body.should == '1two2threfour'
      response.headers["Content-Range"].should == 'bytes 3-16/16'
      response.headers["Content-Length"].should == '13'
    end
    it "should get a range not ending at the end" do
      request.env["Range"] = 'bytes=4-12'
      get :show, id: 'test', datastream_id: 'webm'
      response.body.should == 'two2thre'
      response.headers["Content-Range"].should == 'bytes 4-12/16'
      response.headers["Content-Length"].should == '8'
    end
  end

end
