require 'spec_helper'

describe ImportPbcoreDatastream do
  describe 'from a template' do
    let(:file) { File.open(fixture_path + '/import/metadata/broadway_or_bust.pbcore.xml') }
    let(:datastream) { ImportPbcoreDatastream.from_xml(file) }

    describe "the full file" do
      subject { datastream }
      it "should have many description_documents" do
        expect(subject.description_document.count).to eq 65
      end
    end

    describe "the first document" do
      subject { datastream.description_document(0) }
      it "should have a series title" do
        expect(subject.series_title).to eq ['Broadway or Bust']
      end
      it "should have a episode title" do
        expect(subject.episode_title).to eq ['']
      end
      it "should have a program title" do
        expect(subject.program_title).to eq ['']
      end
      it "should have an item title" do
        expect(subject.item_title).to eq ['Atlanta Nominees Auditions Shuler Hensley Awards- Max Spencer, Payton Anderson, Rosa Campos,Evan Greenberg, Brittany Dankwa and Hazel Dankwa (mom), Chase, McKenzie Kurtz']
      end
      it "should have a description" do
        expect(subject.description).to eq ['See also physical log

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
        expect(subject.filenames).to eq ['BB0612A01_C001 - BB0612A13_C022_']
      end
      it "should have a folder" do
        expect(subject.folder).to eq ['ATLANTA']
      end
      it "should have a drive" do
        expect(subject.drive).to eq ['G-DRIVE_BoB_Auditions']
      end
    end
  end


  describe "a file with one record" do
    let(:file) { File.open(fixture_path + '/single_import_metadata.pbcore.xml') }
    let(:datastream) { ImportPbcoreDatastream.from_xml(file) }
    describe "to_solr" do
      subject {datastream.to_solr }
      it "should have some fields" do
        expect(subject['series_title_tesim']).to eq ['Broadway or Bust']
        expect(subject['episode_title_tesim']).to eq ['']
        expect(subject['program_title_tesim']).to eq ['']
        expect(subject['item_title_tesim']).to eq ["Rehearsals, Coaching, Solos, Medley's and Choreography, Kids take NYC tour bus\n\n\n"]
        expect(subject['filenames_tesim']).to eq ['BB0621E01_C0001 - BB0621E04_C0012']
        expect(subject['folder_name_tesim']).to eq ['NY Footage/0621 NY']
        expect(subject['drive_name_tesim']).to eq ['Broadway_or_Bust_NYC']
      end
    end
    describe "setting fields" do
      subject { datastream }
      it "should set episode_title" do
        subject.episode_title = "Bam"
        expect(subject.episode_title).to eq ["Bam"]
      end
      it "should set filename" do
        subject.filenames = "Bam"
        expect(subject.filenames).to eq ["Bam"]
      end
      it "should set folder" do
        subject.folder_name = "Bam"
        expect(subject.folder_name).to eq ["Bam"]
      end
      it "should set drive" do
        subject.drive_name = "Bam"
        expect(subject.drive_name).to eq ["Bam"]
      end
      it "should set location" do
        subject.event_location = "NY"
        expect(subject.event_location).to eq ["NY"]
      end
      it "should set date portrayed" do
        subject.date_portrayed = '06/21/2012'
        expect(subject.date_portrayed).to eq ['06/21/2012']
      end
    end
  end
end
