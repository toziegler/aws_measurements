sudo yum install -y git g++ clang make automake libtool numactl
git clone https://github.com/Mellanox/sockperf.git
cd sockperf
./autogen.sh
./configure
make -j
cd
