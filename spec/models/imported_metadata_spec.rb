require 'spec_helper'

describe ImportedMetadata do
  subject {ImportedMetadata.new}
  let(:file) { File.open(fixture_path + '/import/metadata/broadway_or_bust.pbcore.xml') }

  after do
    subject.destroy unless subject.new_record?
  end

  it "should respond to noid" do
    subject.apply_depositor_metadata("frank")
    subject.save!
    expect(subject.noid).to_not be_empty
  end

  it "should apply_depositor_metadata" do
    subject.apply_depositor_metadata("frank")
    expect(subject.edit_users).to eq ['frank']
    expect(subject.depositor).to eq 'frank'
    subject.save!
  end

  it "should have an apply_to accessor" do
    expect(subject.apply_to).to eq []  
    subject.apply_to = ["zw132p31r", "zw132p321", "zw132p339"]  
    expect(subject.apply_to).to eq ["zw132p31r", "zw132p321", "zw132p339"]  
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
        expect(f.series_title).to eq ['Nova']
        expect(f.program_title).to eq ['The Smartest Machine']
        expect(f.item_title).to eq ['sample item']
        expect(f.episode_title).to eq ['sample episode']
        expect(f.description.first.value).to eq ['my description']
        expect(f.event_location).to eq ['New York, NY']
        expect(f.has_event.first.date_time).to eq ['06/21/2012']
        expect(f.applied_template_id).to eq subject.pid
        expect(f.unarranged).to eq false
      end
    end
  end
  
  describe "match_files_with_path" do
    it "should combine drive_name and folder_name" do
      subject.descMetadata.content = file.read
      expect(subject.drive_name).to eq "G-DRIVE_BoB_Auditions"
      expect(subject.folder_name).to eq "ATLANTA"
      expect(subject.match_files_with_path).to eq "G-DRIVE_BoB_Auditions/ATLANTA"
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
      expect(subject.matching_files.count).to eq 2
      expect(subject.matching_files).to include(@file1)
      expect(subject.matching_files).to include(@file2)
      expect(subject.matching_files).to_not include(@file3)
    end
  end
end
