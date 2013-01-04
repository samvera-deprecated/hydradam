require 'spec_helper'

describe Ability do
  let(:another_user) { FactoryGirl.create(:user) }

  describe "an admin user" do
    subject { Ability.new(FactoryGirl.create(:admin))}
    it "should be able to edit users" do
      subject.can?(:edit, another_user).should be_true
    end
  end

  describe "a non-admin user" do
    subject { Ability.new(FactoryGirl.create(:user))}
    it "should not be able to edit users" do
      subject.can?(:edit, another_user).should be_false
    end
  end

end
