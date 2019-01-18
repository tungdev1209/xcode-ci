class IosCi < Formula
  desc "Build, Archive & Export iOS/MacOS app via command-line"
  homepage "https://tungdev1209.github.io/homebrew-ios-ci/"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.28.tar.gz"
  sha256 "58c4cee0650c284c32e07c8fd0154e4cfbf0a01a9812c9cb3104528f5e6238e2"

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
