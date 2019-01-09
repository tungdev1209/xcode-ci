class IosCi < Formula
  desc "Build, archive & export iOS/MacOS app via command-line"
  homepage "https://github.com/tungdev1209/ios-ci"
  url "https://github.com/tungdev1209/ios-ci/archive/v1.0.7.tar.gz"
  version "1.0.7"
  sha256 "aa14894e5bb0b6e0810b3eaf11ecd0eb7977383c41302cc823294e598c2e47e5"

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
