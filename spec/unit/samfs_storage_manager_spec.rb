require 'spec_helper'

describe SamfsStorageManager do
  subject { SamfsStorageManager }
  describe "live?" do
    describe "when the file is online" do
      before do
        `echo hi` # this works as a mock for $?
        output =<<END_CMD
testfile:
mode: -rw------T links: 1 owner: root group: root 
length: 1048576 admin id: 0 inode: 4640.1
archdone;
copy 1: ----- Mar 23 19:39 1.1 dk disk01 f1
copy 2: ----- Mar 23 19:58 1.1 dk disk03 f1
access: Mar 24 01:35 modification: Mar 23 19:28
changed: Mar 23 19:28 attributes: Mar 23 19:28
creation: Mar 23 19:28 residence: Mar 24 01:35
END_CMD
        expect(subject).to receive(:`).with("sls -D /opt/testfile").and_return(output)
      end
      it "should be true" do
        expect(subject.live?('/opt/testfile')).to eq true
      end
    end
    describe "when the file is offline" do
      before do
        `echo hi` # this works as a mock for $?
        expect(subject).to receive(:`).with("sls -D /opt/testfile").and_return(<<END_CMD
testfile:
mode: -rw------T links: 1 owner: root group: root 
length: 1048576 admin id: 0 inode: 4640.1
offline; archdone;
copy 1: ----- Mar 23 19:39 1.1 dk disk01 f1
copy 2: ----- Mar 23 19:58 1.1 dk disk03 f1
access: Mar 24 01:35 modification: Mar 23 19:28
changed: Mar 23 19:28 attributes: Mar 23 19:28
creation: Mar 23 19:28 residence: Mar 24 01:37
END_CMD
)
      end
      it "should be false" do
        expect(subject.live?('/opt/testfile')).to eq false
      end
    end
  end

end
