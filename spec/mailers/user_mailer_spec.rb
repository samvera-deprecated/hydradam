require "spec_helper"

describe UserMailer do
  let(:user) { FactoryGirl.create(:user) }
  let(:file) do
    gf = GenericFile.new
    gf.apply_depositor_metadata('justin')
    gf.save!
    gf
  end

  let(:mail) { UserMailer.file_online_notice(user, file) }

  it 'has the subject' do
    mail.subject.should == 'File ready for download'
  end

  it 'has the receivers email' do
    mail.to.should == [user.email]
  end

  it 'has the sender email' do
    mail.from.should == ['no-reply@example.com']
  end

  it 'has a link to the file' do
    mail.body.encoded.should match(/\/files\/#{file.noid}/)
  end
end
