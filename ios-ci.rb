class IosCi < Formula
  desc "Build, Archive & Export iOS/MacOS app via command-line"
  homepage "https://github.com/tungdev1209/homebrew-ios-ci"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.4.tar.gz"
  sha256 "adc7192ebd09dbb994b3245739ec7eb0a4c8b76030dbbae85fe94ddff36637b7"

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
