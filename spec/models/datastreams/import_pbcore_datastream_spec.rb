require 'spec_helper'

describe ImportPbcoreDatastream do
  describe 'from a template' do
    let(:file) { File.open(fixture_path + '/import/metadata/broadway_or_bust.pbcore.xml') }
    let(:datastream) { ImportPbcoreDatastream.from_xml(file) }

    describe "the full file" do
      subject { datastream }
      it "should have many description_documents" do
        subject.description_document.count.should == 65
      end
    end

    describe "the first document" do
      subject { datastream.description_document(0) }
      it "should have a series title" do
        subject.series_title.should == ['Broadway or Bust']
      end
      it "should have a episode title" do
        subject.episode_title.should == ['']
      end
      it "should have a program title" do
        subject.program_title.should == ['']
      end
      it "should have an item title" do
        subject.item_title.should == ['Atlanta Nominees Auditions Shuler Hensley Awards- Max Spencer, Payton Anderson, Rosa Campos,Evan Greenberg, Brittany Dankwa and Hazel Dankwa (mom), Chase, McKenzie Kurtz']
      end
      it "should have a description" do
        subject.description.should == ['See also physical log

Transcripts for 
Evan Greenberg
Brittany Dankwa
Shuler Hensley
Robert Connor
Ebony Finkley
Hazel Dankwa
Jody Greenberg
Phillip Greenberg


Auditions in Atlanta at Shuler Hensley Awards

Max Spencer, Payton Anderson, Rosa Campos, Evan Greenberg, Brittany Dankwa, Chase Alexander, McKenzie Kurtz, Hazel Dankwa

Red Carpet Shuler Hensley Awards

Backstage getting ready for show, kids getting ready, putting on makeup and costumes, chatting

Broll of Brittany Dankwa and Hazel Dankwa (mom) driving in car, sleeping in car "homeless" scenes
Interviews with Brittany and Hazel at home

Even Greenberg intv at home, broll of house, family, Evan making a nature film, Evan rehearsing ']
      end
      it "should have a list of files" do
        subject.filename.should == ['BB0612A01_C001 - BB0612A13_C022_']
      end
      it "should have a folder" do
        subject.folder.should == ['ATLANTA']
      end
      it "should have a drive" do
        subject.drive.should == ['G-DRIVE_BoB_Auditions']
      end
    end
  end
end
