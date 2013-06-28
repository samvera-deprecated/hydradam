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

  it "should have an apply_to accessor" do
    subject.apply_to.should == []  
    subject.apply_to = ["zw132p31r", "zw132p321", "zw132p339"]  
    subject.apply_to.should == ["zw132p31r", "zw132p321", "zw132p339"]  
  end

  describe "applying the metadata" do
    before do
      @user = FactoryGirl.create(:user)
      @file1 = GenericFile.new(relative_path: "G-DRIVE_BoB_Auditions/ATLANTA/001.wav")
      @file2 = GenericFile.new(relative_path: "G-DRIVE_BoB_Auditions/ATLANTA/002.wav")
      @file3 = GenericFile.new(relative_path: "TheDRIVE/SEATTLE/001.wav")
      [@file1, @file2, @file3].each do |f| 
        f.apply_depositor_metadata(@user.user_key)
        f.save!
      end
      subject.series_title = 'Nova'
      subject.apply_depositor_metadata(@user.user_key)
      subject.save!
    end
    it "should apply the metadata" do
      subject.apply_to = [@file1.id, @file2.id, @file3.id]  
      subject.apply!
      @file1.reload.series_title.should == ['Nova']
      @file1.reload.applied_template_id.should == subject.pid
      @file2.reload.series_title.should == ['Nova']
      @file2.reload.applied_template_id.should == subject.pid
    end
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
