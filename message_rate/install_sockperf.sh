sudo yum install git g++ clang automake libtools numactl
git clone https://github.com/Mellanox/sockperf.git
cd sockperf
./autogen.sh
./configure
make -j
cd
