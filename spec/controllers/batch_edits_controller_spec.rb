require 'spec_helper'

describe BatchEditsController do
  before do
    controller.stub(:has_access?).and_return(true)
    @user = FactoryGirl.create(:user)
    sign_in @user
    User.any_instance.stub(:groups).and_return([])
    controller.stub(:clear_session_user) ## Don't clear out the authenticated session
  end

  describe "edit" do
    before do
      @one = GenericFile.new(creator_attributes:[{name: "Fred"}], :language=>'en')
      @one.apply_depositor_metadata('mjg36')
      @two = GenericFile.new(creator_attributes:[{name: "Wilma"}], publisher_attributes:[{name:'Rand McNally'}], :language=>'en')
      @two.apply_depositor_metadata('mjg36')
      @one.save!
      @two.save!
      controller.batch = [@one.pid, @two.pid]
      
      expect(controller).to receive(:can?).with(:edit, @one.pid).and_return(true)
      expect(controller).to receive(:can?).with(:edit, @two.pid).and_return(true)
    end
    it "should be successful" do
      get :edit
      expect(response).to be_successful
      expect(assigns[:terms]).to eq [ :contributor, :creator, :description, :event_location,
          :production_location, :date_portrayed, :source, :source_reference, :rights_holder,
          :rights_summary, :publisher, :date_created, :release_date, :review_date, :aspect_ratio,
          :frame_rate, :cc, :physical_location, :identifier, :metadata_filename, :notes,
          :originating_department, :subject, :language, :rights, :tag, :related_url]
    end
  end
end
