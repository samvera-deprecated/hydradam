require 'fits'


namespace :fits do
  desc "Install FITS"
  task :install do
    Fits::Installer.new.install
  end
end