control 'Disable unused filesystems' do
  impact 0.7
  title 'Ensure mounting of cramfs, squashfs, udf filesystems is disabled'
  %w(cramfs squashfs udf).each do |fs_name|
    describe command("sudo modprobe -n -v #{fs_name} | grep '^install'") do
      its('stdout') { should match /install\s*\/bin\/true/ }
    end
  end
end
