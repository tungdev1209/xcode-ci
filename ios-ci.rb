class IosCi < Formula
  desc "Build, archive & export iOS/MacOS app via command-line"
  homepage "https://github.com/tungdev1209/homebrew-ios-ci"
  version "1.0.3"
  url "https://github.com/tungdev1209/homebrew-ios-ci/archive/v1.0.3.tar.gz"
  sha256 "adc7192ebd09dbb994b3245739ec7eb0a4c8b76030dbbae85fe94ddff36637b7"

  def install
    bin.install "ios-ci"
    prefix.install "Author"
    prefix.install "README.md"
    prefix.install "hooks"
    prefix.install "config"
  end

  test do
    system "#{bin}/ios-ci", "--version"
  end
end
