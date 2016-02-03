require "language/go"

class Terraform < Formula
  desc "Tool to build, change, and version infrastructure"
  homepage "https://www.terraform.io/"
  url "https://github.com/hashicorp/terraform/archive/v0.6.11.tar.gz"
  sha256 "374f69a5b2c32073a493a88cd9c55580b30dcf345437f4a8f6c46d87bdc5f0eb"

  bottle do
    cellar :any_skip_relocation
    sha256 "ad4fa082a1d877400a42778565990641594ef3fccc9bb178a1680b7a74327d93" => :el_capitan
    sha256 "5ea88e3b126a7645bf81d1864942e2ce7b9a7a173fcc2ef5e1f6080bbaaff8b3" => :yosemite
    sha256 "cec5341659b9141c7772bd52b63c9bf6ccc184e2946f576986aa7633ad89bf63" => :mavericks
  end

  depends_on "go" => :build
  depends_on "godep" => :build

  terraform_deps = %w[
    github.com/mitchellh/gox 770c39f64e66797aa46b70ea953ff57d41658e40
    github.com/mitchellh/iochan 87b45ffd0e9581375c491fef3d32130bb15c5bd7
    github.com/Azure/azure-sdk-for-go bc148c2c7ee5113748941126b465e4ad6eee8e1d
    github.com/aws/aws-sdk-go bc2c5714d312337494394909e7cc3a19a2e68530
    github.com/cenkalti/backoff 4dc77674aceaabba2c7e3da25d4c823edfb73f99
    github.com/davecgh/go-spew 5215b55f46b2b919f50a1df0eaa5886afe4e3b3d
    gopkg.in/yaml.v2 f7716cbe52baa25d2e9b0d0da546fcf909fc16b4
    github.com/golang/protobuf 45bba206dd5270d96bac4942dcfe515726613249
  ]

  terraform_deps.each_slice(2) do |x, y|
    go_resource x do
      url "https://#{x}.git", :revision => y
    end
  end

  go_resource "golang.org/x/tools" do
    url "https://go.googlesource.com/tools.git", :revision => "977844c7af2aa555048a19d28e9fe6c392e7b8e9"
  end

  go_resource "google.golang.org/grpc" do
    url "https://github.com/grpc/grpc-go", :revision => "5d64098b94ee9dbbea8ddc130208696bcd199ba4"
  end

  def install
    ENV["GOPATH"] = buildpath
    ENV["GO15VENDOREXPERIMENT"] = "1"
    # For the gox buildtool used by terraform, which doesn't need to
    # get installed permanently
    ENV.append_path "PATH", buildpath

    terrapath = buildpath/"src/github.com/hashicorp/terraform"
    terrapath.install Dir["*"]
    Language::Go.stage_deps resources, buildpath/"src"

    cd "src/github.com/mitchellh/gox" do
      system "go", "build"
      buildpath.install "gox"
    end

    cd "src/golang.org/x/tools/cmd/stringer" do
      system "go", "build"
      buildpath.install "stringer"
    end

    # https://github.com/golang/go/issues/11659
    cd terrapath do
      system "go test $(go list ./... | grep -v /vendor/)"
      mkdir "bin"
      arch = MacOS.prefer_64_bit? ? "amd64" : "386"
      system "gox -arch #{arch} -os darwin -output bin/terraform-{{.Dir}} $(go list ./... | grep -v /vendor/)"
      bin.install "bin/terraform-terraform" => "terraform"
      bin.install Dir["bin/*"]
    end
  end

  test do
    minimal = testpath/"minimal.tf"
    minimal.write <<-EOS.undent
      variable "aws_region" {
          default = "us-west-2"
      }

      variable "aws_amis" {
          default = {
              eu-west-1 = "ami-b1cf19c6"
              us-east-1 = "ami-de7ab6b6"
              us-west-1 = "ami-3f75767a"
              us-west-2 = "ami-21f78e11"
          }
      }

      # Specify the provider and access details
      provider "aws" {
          access_key = "this_is_a_fake_access"
          secret_key = "this_is_a_fake_secret"
          region = "${var.aws_region}"
      }

      resource "aws_instance" "web" {
        instance_type = "m1.small"
        ami = "${lookup(var.aws_amis, var.aws_region)}"
        count = 4
      }
    EOS
    system "#{bin}/terraform", "graph", testpath
  end
end
