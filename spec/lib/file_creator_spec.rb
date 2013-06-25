require 'spec_helper'

describe WGBH::FileCreator do
  before do
    subject.should_receive(:file_list).and_return(
      ["./NOVA3806_SmartestMachine_Dan/Stanford Transfer /Stanford 1/C0001.mov",
       "./NOVA3806_SmartestMachine_Dan/Stanford Transfer /Stanford 1/C0002.mov",
       "./NOVA3806_SmartestMachine_Dan/Stanford Transfer /Stanford 1/C0003.mov",
       "./NOVA3806_SmartestMachine_Dan/Stanford Transfer /Stanford 1/C0004.mov",
       "./NOVA3806_SmartestMachine_Dan/Stanford Transfer /Stanford 1/C0005.mov",
       "./NOVA3806_SmartestMachine_Dan/Stanford Transfer /Stanford 1/C0006.mov",
       "./NOVA3806_SmartestMachine_Dan/Stanford Transfer /Stanford 1/C0007.mov"])
    GenericFile.destroy_all
  end
  it "should create one file for every line in the list" do
    expect { subject.instantiate_files }.to change{GenericFile.count}.by(7)
    GenericFile.first.relative_path.should == "./NOVA3806_SmartestMachine_Dan/Stanford Transfer /Stanford 1/C0001.mov"
  end
end
