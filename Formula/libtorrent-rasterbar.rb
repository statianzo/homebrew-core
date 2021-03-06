class LibtorrentRasterbar < Formula
  desc "C++ bittorrent library by Rasterbar Software"
  homepage "https://www.libtorrent.org/"
  url "https://github.com/arvidn/libtorrent/releases/download/libtorrent_1_2_0/libtorrent-rasterbar-1.2.0.tar.gz"
  sha256 "428eefcf6a603abc0dc87e423dbd60caa00795ece07696b65f8ee8bceaa37c30"
  revision 1

  bottle do
    cellar :any
    sha256 "ff71a030b51e5adbbbf2bae945ca41c433c821e4bd5a92aff5c5b9a4fb33b028" => :mojave
    sha256 "563ff0f190b7ddbaa3c4752f157c8315b3447bb28706d54510a68905006f30ce" => :high_sierra
    sha256 "ef8cc205f769ee38de45a2f67a0da2f9b60c9f8c3603414164fce2a3500bad99" => :sierra
  end

  head do
    url "https://github.com/arvidn/libtorrent.git"
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "boost-python3"
  depends_on "openssl"
  depends_on "python"

  # Upstream commit for Boost 1.70.0
  patch do
    url "https://github.com/arvidn/libtorrent/commit/76c27949.diff?full_index=1"
    sha256 "c44db22b3eabcefc8e2ace5d8e0d39364c1a8a49dbee3d3f2223bee13395921a"
  end

  def install
    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --enable-encryption
      --enable-python-binding
      --with-boost=#{Formula["boost"].opt_prefix}
      --with-boost-python=boost_python37-mt
      PYTHON=python3
    ]

    if build.head?
      system "./bootstrap.sh", *args
    else
      system "./configure", *args
    end

    system "make", "install"
    libexec.install "examples"
  end

  test do
    system ENV.cxx, "-std=c++11", "-I#{Formula["boost"].include}/boost",
                    "-L#{lib}", "-ltorrent-rasterbar",
                    "-L#{Formula["boost"].lib}", "-lboost_system",
                    "-framework", "SystemConfiguration",
                    "-framework", "CoreFoundation",
                    libexec/"examples/make_torrent.cpp", "-o", "test"
    system "./test", test_fixtures("test.mp3"), "-o", "test.torrent"
    assert_predicate testpath/"test.torrent", :exist?
  end
end
