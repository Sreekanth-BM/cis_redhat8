# Control filesystem
control 'Disable unused filesystems' do
  impact 1.0
  title 'Ensure mounting of cramfs, squashfs, udf filesystems is disabled'
  %w(cramfs squashfs udf).each do |fs_name|
    describe command("sudo modprobe -n -v #{fs_name} | grep '^install'") do
      its('stdout') { should match /install\s*\/bin\/true/ }
    end
  end
end

control 'Configure /tmp' do
  impact 1.0
  title 'Ensure /tmp is seperate filesystem and have noexec option'
  describe mount('/tmp') do
    it { should be_mounted }
    its('options') { should match /noexec/ }
  end
  describe command('systemctl is-enabled tmp.mount') do
    its('stdout') { should match /disabled/ }
  end
end

control 'Configure /var, /var/tmp, /var/log, /var/log/audit' do
  impact 1.0
  title 'Ensure /var, /var/tmp, /var/log, /var/log/audit had seperate filesystem and possess nodev, noexec, nosuid option'
  %w(/var /var/tmp /var/log /var/log/audit).each do |fs_name|
    describe mount(fs_name) do
      it { should be_mounted }
      its('stdout') { should match /nodev/ }
      its('stdout') { should match /noexec/ }
      its('stdout') { should match /nosuid/ }
  end
  end
end

control 'Configure /home' do
  impact 1.0
  title 'Ensure /home is seperate filesystem and have nodev, nosuid, usrquota, grpquota option'
  describe mount('/home') do
    it { should be_mounted }
    its('options') { should match /nodev/ }
    its('options') { should match /nosuid/ }
    its('options') { should match /usrquota/ }
    its('options') { should match /grpquota/ }
  end
end

control 'Configure /dev/shm' do
  impact 1.0
  title 'Ensure /dev/shm have nodev, nosuid, noexec options if partition exists'
  only_if('/dev/shm partition doesn\'t exists') do
    command('findmnt --kernel /dev/shm').exit_status == 0
  end
  # Verifies only when /dev/shm partition exists
  describe mount('/dev/shm') do
    its('options') { should match /noexec/ }
    its('options') { should match /nosuid/ }
    its('options') { should match /nodev/ }
  end
end

control 'Disable autofs' do
  impact 1.0
  title 'Ensure autofs is disabled if its installed'
  describe.one do
    describe command('sudo systemctl is-enabled autofs') do
      its('exit_status') { should eq 1 }
    end
    describe command('sudo systemctl is-enabled autofs') do
      its('stdout') { should match /disabled/ }
    end    
  end
end

control 'Disable USB Storage' do
  impact 1.0
  title 'Restrict USB access on the system'
  describe command("sudo modprobe -n -v usb-storage") do
    its('stdout') { should match /install\s*\/bin\/true/ }
  end
  describe command('lsmod | grep usb-storage') do
    its('exit_status') { should_not eq 0 }
  end
end

control 'Ensure gpgcheck is globally activated' do
  impact 1.0
  title 'Verify in global configuration'
  describe file('/etc/dnf/dnf.conf') do
    its('content') { should match /gpgcheck\s*=\s*1/ }
  end
  describe command('grep -P "^gpgcheck\h*=\h*[^1].*\h*$" /etc/yum.repos.d/*') do
    its('exit_status') { should_not eq 0 }
  end
end

control 'Filesystem Integrity checks' do
  impact 1.0
  title 'Ensure aide package is installed and respective services are up'
  describe package('aide') do
    it { should be_installed }
  end
  %w(aidecheck.service aidecheck.timer).each do |aide_service|
    describe systemd_service(aide_service) do
      it { should be_enabled }
    end
  end
  describe systemd_service('aidecheck.timer') do
    it { should be_running }
  end
end

control 'Mandatroy Access Control' do
  impact 1.0
  title 'Ensure SELinux is installed, SELinux policy is configured and SELinux mode is not disabled'
  describe package('libselinux') do
    it { should be_installed }
  end
  describe file('/etc/selinux/config') do
    its('content') { should match /SELINUXTYPE\s*=\s*targeted/ }
    its('content') { should match /SELINUX\s*=\s*enforcing|SELINUX\s*=\s*permissive/ }
  end
end

describe processes('unconfined_service_t') do
  it { should_not exist }
end

control 'Packages shouldn\'t exists' do
  impact 0.7
  title 'Ensure setrobleshoot mcstrans are not installed'
  %w(setroubleshoot mcstrans).each do |package_name|
    describe package(package_name) do
      it { should_not be_installed }
    end
  end  
end
