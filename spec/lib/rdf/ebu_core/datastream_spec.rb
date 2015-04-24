require 'spec_helper'



describe RDF::EbuCore::Datastream do
  subject { RDF::EbuCore::Datastream.new }

  describe '#contributors' do

    it 'allows multile ' do
      c1 = RDF::EbuCore::Datastream::Person.new
      c2 = RDF::EbuCore::Datastream::Person.new
      subject.contributors = [c1, c2]
      expect(subject.contributors).to eq [c1, c2]
    end

    it 'raises an error if you try to assign something other than RDF::EbuCore::Datastream::Person' do
      expect{ subject.contributors = ["not a real person"] }.to raise_error
    end
  end
end


describe RDF::EbuCore::Datastream::Person do
  
  subject { RDF::EbuCore::Datastream::Person.new }

  describe '#full_name' do
    it 'exists' do
      expect{ subject.full_name }.to_not raise_error
    end
  end
end