require 'spec_helper'

describe FileRequest do
  let (:user) { FactoryGirl.create(:user) }
  let (:pid) { 'sufia:12345' }

  it "should not permit two open requests for the same file by the same user" do
    FileRequest.create!(user: user, pid: pid)
    lambda {FileRequest.create!(user: user, pid: pid)}.should raise_error ActiveRecord::RecordInvalid
  end
  it "should not permit more than on closed requests for the same file by the same user" do
    FileRequest.create!(user: user, pid: pid, fulfillment_date: Date.today)
    lambda {FileRequest.create!(user: user, pid: pid)}.should_not raise_error
  end
end
