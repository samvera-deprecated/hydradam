require 'spec_helper'

describe RDF::EbuCore::Datastream do

  describe 'properties' do
    @all_properties = [
        :is_part_of,
        :date_modified,
        :date_created,
        :contributors,
        :creators,
        :publishers,
        :video_tracks,
        :captioning,
        :description,
        :has_event,
        :has_depicted_event,
        :is_covered_by,
        :filename,
        :file_byte_size,
        :subject,
        :keyword,
        :summary,
        :duration,
        :rights,
        :resource_type,
        :has_source,
        :related_publication_event,
        :annotations,
        :identifier,
        :language,
        :tag
    ]
    
    @all_properties.each do |property|
      it "has reader/writer for property #{property}" do
        expect(subject).to respond_to(property)
      end
    end
  end

end