class IosCi < Formula
  desc "Build, Archive & Export iOS/MacOS app via command-line"
  homepage "https://github.com/tungdev1209/homebrew-ios-ci"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.14.tar.gz"
  sha256 "0b332600487e39ea133dbe4aab3d5a59848d6340793775663886d4b8a312c7c8"

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
