require 'spec_helper'

describe DownloadsController do
  before do
    @user = FactoryGirl.create(:user)
    @file = GenericFile.new
    @file.apply_depositor_metadata(@user.user_key)
    @file.add_file(StringIO.new("A test file"), 'content', 'test.txt')
    sign_in @user
    @routes = Sufia::Engine.routes
  end
  it "should log downloads" do
    @file.downloads.size.should == 0
    get :show, id: @file
    response.should be_successful
    @file.downloads.size.should == 1
  end

  describe "for a big file" do
    before do
      @controller.should_receive(:over_threshold?).and_return(true)
      @controller.stub(:unique_key).and_return('test_ftp_download')
      @file.filename = "Test.MOV"
      @file.save!
      File.unlink('tmp/test_ftp_download/Test.MOV') if File.exists?('tmp/test_ftp_download/Test.MOV')
      Dir.rmdir('tmp/test_ftp_download') if File.exists?('tmp/test_ftp_download')
    end

    it "should give an ftp link if the file is over threshold" do
      File.exist?('tmp/test_ftp_download/Test.MOV').should be_false
      get :show, id: @file
      response.should be_successful
      assigns[:ftp_link].should match /^ftp:\/\/test.host\/[^\/]+\/Test.MOV$/
      File.exist?('tmp/test_ftp_download/Test.MOV').should be_true
    end
  end

end
