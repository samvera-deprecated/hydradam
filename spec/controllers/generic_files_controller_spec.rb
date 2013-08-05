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
      @file.views.size.should == 0
      get :show, id: @file
      response.should be_successful
      @file.views.size.should == 1
    end

    it "should show xml" do
      get :show, id: @file, format: 'xml'
      response.should be_successful
      Nokogiri::XML(response.body).xpath('/pbcoreDescriptionDocument/pbcoreTitle').text.should == 'The title'
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

      lambda { post :create, local_file: ["world.png", "sheepb.jpg"], batch_id: "xw42n7934"}.should change(GenericFile, :count).by(2)
      response.should redirect_to Sufia::Engine.routes.url_helpers.batch_edit_path('xw42n7934')
      # These files should have been moved out of the upload directory
      File.exist?("#{@mock_upload_directory}/sheepb.jpg").should be_false
      File.exist?("#{@mock_upload_directory}/world.png").should be_false
      # And into the storage directory
      files = GenericFile.find(Solrizer.solr_name("is_part_of",:symbol) => 'info:fedora/sufia:xw42n7934')
      files.each do |gf|
        File.exist?(gf.content.filename).should be_true
        gf.thumbnail.mimeType.should == 'image/png'
      end
      files.first.label.should == 'world.png'
      files.first.unarranged.should == false
      files.last.label.should == 'sheepb.jpg'
    end
    it "should ingest directories from the filesystem" do
      #TODO this test is very slow because it kicks off CharacterizeJob.
      lambda { post :create, local_file: ["world.png", "import"], batch_id: "xw42n7934"}.should change(GenericFile, :count).by(4)
      response.should redirect_to Sufia::Engine.routes.url_helpers.batch_edit_path('xw42n7934')
      # These files should have been moved out of the upload directory
      File.exist?("#{@mock_upload_directory}/import/manifests/manifest-broadway-or-bust.txt").should be_false
      File.exist?("#{@mock_upload_directory}/import/manifests/manifest-nova-smartest-machine-1.txt").should be_false
      File.exist?("#{@mock_upload_directory}/import/metadata/broadway_or_bust.pbcore.xml").should be_false
      File.exist?("#{@mock_upload_directory}/world.png").should be_false
      # And into the storage directory
      files = GenericFile.find(Solrizer.solr_name("is_part_of",:symbol) => 'info:fedora/sufia:xw42n7934')
      files.each do |gf|
        File.exist?(gf.content.filename).should be_true
      end
      files.first.label.should == 'world.png'
      files.first.unarranged.should be_true
      files.first.thumbnail.mimeType.should == 'image/png'
      files.last.relative_path.should == 'import/metadata/broadway_or_bust.pbcore.xml'
      files.last.unarranged.should be_true
      files.last.label.should == 'broadway_or_bust.pbcore.xml'
    end
    it "should ingest uploaded files"
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
           date_portrayed: ['12/24/1913'],
           'event_location' => ['france', 'portugual'],
           'production_location' => ['Boston', 'Minneapolis'],
           source: ['Some shady looking character'],
           resource_type: ["Article", "Audio", "Book"]
          }
      response.should redirect_to(Sufia::Engine.routes.url_helpers.edit_generic_file_path(@file))
      @file.reload
      @file.creator[0].name.should == ['Frank']
      @file.creator[0].role.should == ['Producer']
      @file.creator[1].name.should == ['Dave']
      @file.creator[1].role.should == ['Director']
      @file.event_location.first.has_location[0].location_name.should == ['france']
      @file.event_location.first.has_location[1].location_name.should == ['portugual']
      @file.production_location.first.has_location[0].location_name.should == ['Boston']
      @file.production_location.first.has_location[1].location_name.should == ['Minneapolis']
      @file.source.should == ['Some shady looking character']
      @file.title[0].title_type.should == ['Series']
      @file.title[0].value.should == ['Frontline']
      @file.title[1].value.should == ['How did this happen?']
      @file.title[1].title_type.should == ['Program']
      @file.description[0].value.should == ["it's a documentary show"]
      @file.description[0].type.should == ['summary']
      @file.resource_type.should == [ "Article", "Audio", "Book"]      
      @file.date_portrayed.should == ['12/24/1913']
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
      response.should redirect_to(Sufia::Engine.routes.url_helpers.edit_generic_file_path(@file))
      @file.reload
      @file.publisher.size.should == 2
      @file.publisher[0].name.should == ['Test']
      @file.publisher[1].role.should == ['Foo']
      @file.description.size.should == 2
      @file.description[0].value.should == ["Justin's desc"]
      @file.description[1].type.should == ['valuable']
      @file.event_location.first.has_location[0].location_name.should == ['Brazil']
      # @file.event_location.first.has_location[1].location_name.should == ['portugual']
      @file.production_location.first.has_location[0].location_name.should == ['Cuba']
      # @file.production_location.first.has_location[1].location_name.should == ['Minneapolis']


    end
  end
end
