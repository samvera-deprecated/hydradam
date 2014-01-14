require 'spec_helper'

describe CatalogController do

  let(:user) { FactoryGirl.create(:user) }
  before do
    sign_in user
    GenericFile.delete_all
  end
  let!(:file) do
    GenericFile.new.tap do |f|
      f.title_attributes =  [value: 'The title', title_type: 'Program']
      f.apply_depositor_metadata(user.user_key)
      f.save!
    end
  end

  it "should return results when a wildcard is supplied" do
    get :index, q: 'titl*'
    expect(response).to be_success
    expect(response).to render_template('catalog/index')
    expect(assigns(:document_list).map(&:id)).to eq [file.id]
  end
end
