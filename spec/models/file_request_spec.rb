require 'spec_helper'

describe FileRequest do
  let (:user) { FactoryGirl.create(:user) }
  let (:pid) { 'sufia:12345' }

  it "should not permit two open requests for the same file by the same user" do
    FileRequest.create!(user: user, pid: pid)

    expect{ FileRequest.create!(user: user, pid: pid) }.to raise_error ActiveRecord::RecordInvalid
  end

  # TODO: This example seems to contradict what it purports to test.
  it "should not permit more than one closed requests for the same file by the same user" do
    FileRequest.create!(user: user, pid: pid, fulfillment_date: Date.today)
    expect{ FileRequest.create!(user: user, pid: pid) }.to_not raise_error
  end
end
