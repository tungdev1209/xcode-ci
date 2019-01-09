class IosCi < Formula
  desc "Build, Archive & Export iOS/MacOS app via command-line"
  homepage "https://github.com/tungdev1209/homebrew-ios-ci"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.5.tar.gz"
  sha256 "04a9bc990f71310ab6298209478523b0fea0fe2058aeb3f15399f513bf99fdd6"

  def install
    bin.install "ios-ci"
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
