class IosCi < Formula
  desc "Build, Archive & Export iOS/MacOS app via command-line"
  homepage "https://github.com/tungdev1209/homebrew-ios-ci"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.4.tar.gz"
  sha256 "3a6a9b9bc02af8da4c15695b0cc686cbc28239735f41e01a0845008340966a3b"

  def install
    bin.install "ios-ci.sh"
    prefix.install "Author"
    prefix.install "README.md"
    prefix.install "hooks"
    prefix.install "config"
    prefix.install "helper"
  end

  test do
    system "#{bin}/ios-ci", "--version"
  end
end
