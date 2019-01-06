class HelloWorld < Formula
    desc "usefull script that prints Hello World to your Console"
    homepage "https://github.com/tungdev1209/iOS-Universal-Framework"
  
  
    url "https://github.com/tungdev1209/iOS-Universal-Framework/blob/master/HEAD.zip", :using => :curl
  
    def install
        bin.install "test"
    end
  end