class IosCi < Formula
  desc "Build, Archive & Export iOS/MacOS app via command-line"
  homepage "https://tungdev1209.github.io/homebrew-ios-ci/"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.23.tar.gz"
  sha256 "6b1987398fea1d4971f81a42f6681bd7b6df61ed5cdf1d2bc1048d34539e6637"

  def install
    bin.install "ios-ci"
    prefix.install "Author"
    prefix.install "README.md"
    prefix.install "hooks"
    prefix.install "config"
    prefix.install "helper"
  end

  test do
    system "#{bin}/ios-ci", "__test_cmd"
  end
end
