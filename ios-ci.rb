class IosCi < Formula
  desc "Build, Archive & Export iOS/MacOS app via command-line"
  homepage "https://github.com/tungdev1209/homebrew-ios-ci"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.13.tar.gz"
  sha256 "20d26e8284454e865593ea5a01a3c6514d2c3f2d9f893c2955e022fa460ab4c2"

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
