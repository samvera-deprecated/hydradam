require 'spec_helper'

describe ImportedMetadata do
  subject {ImportedMetadata.new}
  let(:file) { File.open(fixture_path + '/import/metadata/broadway_or_bust.pbcore.xml') }

  after do
    subject.destroy unless subject.new_record?
  end

  it "should respond to noid" do
    subject.save
    subject.noid.should_not be_empty
  end

  it "should apply_depositor_metadata" do
    subject.apply_depositor_metadata("frank")
    subject.edit_users.should == ['frank']
    subject.depositor.should == 'frank'
    subject.save!
  end
  
  
  describe "match_files_with_path" do
    it "should combine drive_name and folder_name" do
      subject.descMetadata.content = file.read
      subject.drive_name.should == "G-DRIVE_BoB_Auditions"
      subject.folder_name.should == "ATLANTA"
      subject.match_files_with_path.should == "G-DRIVE_BoB_Auditions/ATLANTA"
    end
  end

  describe "matching_files" do 
    before do
      GenericFile.delete_all
    end
    it "should be able to look up matching files" do
      subject.apply_depositor_metadata("somedepositor@foo.com")
      subject.descMetadata.content = file.read
      @user = FactoryGirl.create(:user)
      @file1 = GenericFile.new(relative_path: "G-DRIVE_BoB_Auditions/ATLANTA/001.wav")
      @file2 = GenericFile.new(relative_path: "G-DRIVE_BoB_Auditions/ATLANTA/002.wav")
      @file3 = GenericFile.new(relative_path: "TheDRIVE/SEATTLE/001.wav")
      [@file1, @file2, @file3].each do |f| 
        f.apply_depositor_metadata(@user.user_key)
        f.save
      end
      subject.matching_files.count.should == 2
      subject.matching_files.should include(@file1)
      subject.matching_files.should include(@file2)
      subject.matching_files.should_not include(@file3)
    end
  end
end
