require 'spec_helper'

describe Ftp::Driver do
  describe "a registered user" do
    let :user do
      FactoryGirl.create :user, directory: '/tmp'
    end
    before do
      subject.authenticate(user.email, 'password') {|n| n.should be_true}
    end

    describe "uploading files" do
      let :file do
        file = Tempfile.new('foo')
        file.write("hello world")
        file.rewind
        file
      end
      after do
        file.unlink
      end
      it "should be able to upload files" do
        subject.put_file("foo", file.path) {|n| n.should == 11}
      end
    end

    it "should handle a bad upload" do
      subject.put_file("foo", 'two') {|n| n.should be_false}
    end

    it "should not be able to see files" do
      subject.dir_contents('/') {|n| n.should == []}
    end

    it "should not be able to get files" do
    end
  end

  it "should not allow login for a non-registered user" do
    subject.authenticate('bad_user', 'password') {|n| n.should be_false}
  end

  describe "an anonymous user" do
    before do
      subject.authenticate('anonymous', '') {|n| n.should be_true}
    end

    describe "uploading files" do
      let :file do
        file = Tempfile.new('foo')
        file.write("hello world")
        file.rewind
        file
      end
      after do
        file.unlink
      end
      it "should get an error" do
        subject.put_file("foo", file.path) {|n| n.should be_false}
      end
    end

    it "should not be able to see files" do
      subject.dir_contents('/') {|n| n.should == []}
    end

    describe "with an existing file" do
      before do
        @file = GenericFile.new
        @file.apply_depositor_metadata('justin')
        @file.add_file(StringIO.new("A test file"), 'content', 'test.txt')
        @file.filename = 'text.txt'
        key = @file.export_to_ftp('test.host')
        @path = key.sub('ftp://test.host', '')
      end
      it "should be able to download it" do
        subject.get_file(@path) {|n| n.read.should == "A test file"}
      end

      it "should be able to download it by cd to the directory" do
        dir = File.dirname(@path)#.sub(/\/[^\/]+$/, '')
        filename = @path.sub("#{dir}/", '')
        subject.change_dir(dir) {|n| n.should be_true}
        subject.dir_contents(dir) do |n|
          n.size.should == 1
          n.first.should be_kind_of EM::FTPD::DirectoryItem
          n.first.name.should == filename
        end
        subject.bytes(filename) {|n| n.should == 11}
        subject.get_file(filename) {|n| n.read.should == "A test file"}
      end

      it "should be able to get its size" do
        subject.bytes(@path) {|n| n.should == 11}
      end
    end

    it "should not download files that don't exist" do
      subject.get_file('foo') {|n| n.should be_false}
    end
  end

end
