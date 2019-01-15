class IosCi < Formula
  desc "Build, Archive & Export iOS/MacOS app via command-line"
  homepage "https://tungdev1209.github.io/homebrew-ios-ci/"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.20.tar.gz"
  sha256 "4d44e052c5946d56d7062f25d609a5c4ae7f4f5e5d581a9159e601edf0285564"

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
