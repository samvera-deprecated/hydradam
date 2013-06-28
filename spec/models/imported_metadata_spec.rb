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
      @file1 = GenericFile.new(relative_path: "G-DRIVE_BoB_Auditions/ATLANTA/001.wav", unarranged: true)
      @file2 = GenericFile.new(relative_path: "G-DRIVE_BoB_Auditions/ATLANTA/002.wav", unarranged: true)
      @file3 = GenericFile.new(relative_path: "TheDRIVE/SEATTLE/001.wav", unarranged: true)
      [@file1, @file2, @file3].each do |f| 
        f.apply_depositor_metadata(@user.user_key)
        f.save!
      end
      subject.series_title = 'Nova'
      subject.program_title = 'The Smartest Machine'
      subject.item_title = 'sample item'
      subject.episode_title = 'sample episode'
      subject.description = 'my description'
      subject.event_location = 'New York, NY'
      subject.date_portrayed = '06/21/2012'
      subject.apply_depositor_metadata(@user.user_key)
      subject.save!
    end
    it "should apply the metadata" do
      subject.apply_to = [@file1.id, @file2.id, @file3.id]  
      subject.apply!
      [@file1, @file2, @file3].each do |f|
        f.reload
        f.series_title.should == ['Nova']
        f.program_title.should == ['The Smartest Machine']
        f.item_title.should == ['sample item']
        f.episode_title.should == ['sample episode']
        f.description.first.value.should == ['my description']
        f.has_location.first.location_name.should == ['New York, NY']
        f.applied_template_id.should == subject.pid
        f.unarranged.should be_false
      end
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
