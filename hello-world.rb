class HelloWorld < Formula
    desc "usefull script that prints Hello World to your Console"
    homepage "https://bitbucket.org/user/repo"
  
  
    url "https://bitbucket.org/user/repo/get/HEAD.zip", :using => :curl
  
    def install
      bin.install "innovid/hello-world"
    end
  end