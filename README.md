## InSpec profile for CIS RedHat 8 Benchmark

### Pre-requisites
Install InSpec on your workstations (Dowload from [here](https://www.inspec.io/downloads/))

### Run this profile
Two ways to execute this profile<br>
1. Clone this repo
    - git clone https://github.com/Sreekanth-BM/cis_redhat8.git
    - inspec exec cis_redhat8 #local
    - inspec exec cis_redhat -t ssh://user_name@host_ip -i host_key.pem #remote
2. Without cloning this repo
    - inspec exec https://github.com/Sreekanth-BM/cis_redhat8.git #local
    - inspec exec https://github.com/Sreekanth-BM/cis_redhat8.git -t ssh://user_name@host_ip -i host_key.pem #remote
