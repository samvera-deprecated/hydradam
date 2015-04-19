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
    expect(mail.subject).to eq 'File ready for download'
  end

  it 'has the receivers email' do
    expect(mail.to).to eq [user.email]
  end

  it 'has the sender email' do
    expect(mail.from).to eq ['no-reply@example.com']
  end

  it 'has a link to the file' do
    expect(mail.body.encoded).to match(/\/downloads\/#{file.noid}/)
  end
end
