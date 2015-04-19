require 'spec_helper'

describe GenericFilesController do
  before do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @routes = Sufia::Engine.routes
  end
  describe "#show" do
    before do
      @file = GenericFile.new(title_attributes: [value: 'The title', title_type: 'Program'])
      @file.apply_depositor_metadata(@user.user_key)
      @file.save!
    end
    it "should log views" do
      expect(@file.views.size).to eq 0
      get :show, id: @file
      expect(response).to be_successful
      expect(@file.views.size).to eq 1
    end

    it "should show xml" do
      get :show, id: @file, format: 'xml'
      expect(response).to be_successful
      expect(Nokogiri::XML(response.body).xpath('/pbcoreDescriptionDocument/pbcoreTitle').text).to eq 'The title'
    end
  end

  describe "#create" do
    before do
      GenericFile.delete_all
      @mock_upload_directory = 'spec/mock_upload_directory'
      Dir.mkdir @mock_upload_directory unless File.exists? @mock_upload_directory
      FileUtils.copy('spec/fixtures/world.png', @mock_upload_directory)
      FileUtils.copy('spec/fixtures/sheepb.jpg', @mock_upload_directory)
      FileUtils.cp_r('spec/fixtures/import', @mock_upload_directory)
      @user.update_attribute(:directory, @mock_upload_directory)
    end
    after do
      FileContentDatastream.any_instance.stub(:live?).and_return(true)
      GenericFile.destroy_all
    end
    it "should ingest files from the filesystem" do
      #TODO this test is very slow because it kicks off CharacterizeJob.
      
      # s1 = stub()
      # s2 = stub()
      # CharacterizeJob.should_receive(:new).and_return(s1, s2)
      # Sufia.queue.should_receive(:push).with(s1)
      # Sufia.queue.should_receive(:push).with(s2)

      expect{ post :create, local_file: ["world.png", "sheepb.jpg"], batch_id: "xw42n7934"}.to change(GenericFile, :count).by(2)
      expect(response).to redirect_to Sufia::Engine.routes.url_helpers.batch_edit_path('xw42n7934')
      # These files should have been moved out of the upload directory
      expect(File.exist?("#{@mock_upload_directory}/sheepb.jpg")).to eq false
      expect(File.exist?("#{@mock_upload_directory}/world.png")).to eq false
      # And into the storage directory
      files = GenericFile.find(Solrizer.solr_name("is_part_of",:symbol) => 'info:fedora/sufia:xw42n7934')
      files.each do |gf|
        expect(File.exist?(gf.content.filename)).to eq true
        expect(gf.thumbnail.mimeType).to eq 'image/png'
      end
      expect(files.first.label).to eq 'world.png'
      expect(files.first.unarranged).to eq false
      expect(files.last.label).to eq 'sheepb.jpg'
    end
    it "should ingest directories from the filesystem" do
      #TODO this test is very slow because it kicks off CharacterizeJob.
      expect(lambda { post :create, local_file: ["world.png", "import"], batch_id: "xw42n7934"}).to change(GenericFile, :count).by(4)
      expect(response).to redirect_to Sufia::Engine.routes.url_helpers.batch_edit_path('xw42n7934')
      # These files should have been moved out of the upload directory
      expect(File.exist?("#{@mock_upload_directory}/import/manifests/manifest-broadway-or-bust.txt")).to eq false
      expect(File.exist?("#{@mock_upload_directory}/import/manifests/manifest-nova-smartest-machine-1.txt")).to eq false
      expect(File.exist?("#{@mock_upload_directory}/import/metadata/broadway_or_bust.pbcore.xml")).to eq false
      expect(File.exist?("#{@mock_upload_directory}/world.png")).to eq false
      # And into the storage directory
      files = GenericFile.find(Solrizer.solr_name("is_part_of",:symbol) => 'info:fedora/sufia:xw42n7934')
      files.each do |gf|
        expect(File.exist?(gf.content.filename)).to eq true
      end
      expect(files.first.label).to eq 'world.png'
      expect(files.first.unarranged).to eq true
      expect(files.first.thumbnail.mimeType).to eq 'image/png'
      expect(files.last.relative_path).to eq 'import/metadata/broadway_or_bust.pbcore.xml'
      expect(files.last.unarranged).to eq true
      expect(files.last.label).to eq 'broadway_or_bust.pbcore.xml'
    end
    it "should ingest uploaded files"
  end

  describe "#edit" do
    before do
      @file = GenericFile.new.tap do |f|
        f.apply_depositor_metadata(@user.user_key)
        f.creator = "Samantha"
        f.title = "A good day"
        f.save!
      end
    end
    it "should be successful" do
      get :edit, id: @file
      expect(response).to be_successful
    end
  end


  describe "#update" do
    before do
      @file = GenericFile.new
      @file.apply_depositor_metadata(@user.user_key)
      @file.creator = "Samantha"
      @file.title = "A good day"
      @file.save!
    end
    it "should update the creator and location" do
      #TODO we can't just do: @file.descMetadata.creator = [], because that will leave an orphan person
      # this works: @file.descMetadata.creator.each { |c| c.destroy }
      post :update, id: @file, generic_file: {
           title_attributes: {'0' => {"value" => "Frontline", "title_type"=>"Series"}, '1' => {"value"=>"How did this happen?", "title_type"=>"Program"}},
           creator_attributes: {'0' => {"name" => "Frank", "role"=>"Producer"}, '1' => {"name"=>"Dave", "role"=>"Director"}},
           description_attributes: {'0' => {"value"=> "it's a documentary show", "type" => 'summary'}},
           subject: ['Racecars'],
           'event_location' => ['france', 'portugual'],
           'production_location' => ['Boston', 'Minneapolis'],
           date_portrayed: ['12/24/1913'],
           language: ['french', 'english'],
           resource_type: ["Article", "Audio", "Book"],
           source: ['Some shady looking character'],
           source_reference: ['Less shady guy'],
           rights_holder: ['WGBH', 'WNYC'],
           rights_summary: ["Don't copy me bro"],
           release_date: ['12/15/2012'],
           review_date: ['1/18/2013'],
           aspect_ratio: ['4:3'],
           frame_rate: ['25'],
           cc: ['English', 'French'], 
           physical_location: ['Down in the vault'], 
           identifier_attributes: {'0' =>{"value" => "123-456789", "identifier_type"=>"NOLA_CODE"},
                                   '1' =>{"value" => "777", "identifier_type"=>"ITEM_IDENTIFIER"},
                                   '2' =>{"value" => "929343", "identifier_type"=>"PO_REFERENCE"}},
           metadata_filename: ['a_movie.mov'],
           notes: ['foo bar'],
           originating_department: ['Accounts receivable']
          }
      expect(response).to redirect_to(Sufia::Engine.routes.url_helpers.edit_generic_file_path(@file))
      @file.reload
      expect(@file.title[0].title_type).to eq ['Series']
      expect(@file.title[0].value).to eq ['Frontline']
      expect(@file.title[1].value).to eq ['How did this happen?']
      expect(@file.title[1].title_type).to eq ['Program']
      expect(@file.subject).to eq ["Racecars"]
      expect(@file.description[0].value).to eq ["it's a documentary show"]
      expect(@file.description[0].type).to eq ['summary']
      expect(@file.event_location).to eq ['france', 'portugual']
      expect(@file.production_location).to eq ['Boston', 'Minneapolis']
      expect(@file.date_portrayed).to eq ['12/24/1913']
      expect(@file.language).to eq ['french', 'english']
      expect(@file.resource_type).to eq [ "Article", "Audio", "Book"]      
      expect(@file.source).to eq ['Some shady looking character']
      expect(@file.source_reference).to eq ['Less shady guy']
      expect(@file.rights_holder).to eq [ "WGBH", 'WNYC']      
      expect(@file.rights_summary).to eq ["Don't copy me bro"]
      expect(@file.creator[0].name).to eq ['Frank']
      expect(@file.creator[0].role).to eq ['Producer']
      expect(@file.creator[1].name).to eq ['Dave']
      expect(@file.creator[1].role).to eq ['Director']
      expect(@file.release_date).to eq ['12/15/2012']
      expect(@file.review_date).to eq ['1/18/2013']
      expect(@file.aspect_ratio).to eq ['4:3']
      expect(@file.frame_rate).to eq ['25']
      expect(@file.cc).to eq ['English', 'French']
      expect(@file.physical_location).to eq ['Down in the vault']
      expect(@file.nola_code).to eq ['123-456789']
      expect(@file.tape_id).to eq ['777']
      expect(@file.barcode).to eq ['929343']
      expect(@file.metadata_filename).to eq ['a_movie.mov']
      expect(@file.notes).to eq ['foo bar']
      @file.originating_department = ['Accounts receivable']
    end

    it "should remove blank assertions" do
      post :update, id: @file, generic_file: {
        "publisher_attributes"=>{"0"=>{"name"=>"", "role"=>""}, "1"=>{"name"=>"Test", "role"=>""},
                                 "2"=>{"name"=>"", "role"=>"Foo"}, "3"=>{"name"=>"", "role"=>""}},
        "description_attributes"=>{"0"=>{"value"=>"", "type"=>""}, "1"=>{"value"=>"Justin's desc", "type"=>""}, 
                                   "2"=>{"value"=>"", "type"=>"valuable"}},
        'event_location' => ['', 'Brazil'],
        'production_location' => ['', 'Cuba']
      }
      expect(response).to redirect_to(Sufia::Engine.routes.url_helpers.edit_generic_file_path(@file))
      @file.reload
      expect(@file.publisher.size).to eq 2
      expect(@file.publisher[0].name).to eq ['Test']
      expect(@file.publisher[1].role).to eq ['Foo']
      expect(@file.description.size).to eq 2
      expect(@file.description[0].value).to eq ["Justin's desc"]
      expect(@file.description[1].type).to eq ['valuable']
      expect(@file.event_location).to eq ['Brazil']
      expect(@file.production_location).to eq ['Cuba']


    end
  end
end
